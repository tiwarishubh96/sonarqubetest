//
// This class is called as part of setting up a new Payment Method in Salesforce
// It is called from Zuora after the Payment Method has successfully been submitted
// Its purpose is to update the Default Payment Method and Gateway for the Customer 
// Account in Zuora (equivilent to the Billing Account in Salesforce).  It does this
// via a Callout to Zuora.  It also updates the Electronic Payment Method Id on the 
// Billing Account in Salesforce.
//
public with sharing class PaymentPageCallbackExtension {

    private static Zuora.zApi zapi;
    
    public String objectId {get;set;}
    public String paymentId {get;set;}
    public boolean isQuote{get;set;}
    
    public PaymentPageCallbackExtension(zqu.PaymentPageCallbackController controller){
    }
    
    public static Zuora.zApi getApiStub() {
        if (zapi == null && !Test.isRunningTest()) {
            zapi = ZuoraUpdateUtility.loginToZuora('PaymentPageCallbackExtension');
        }
        return zapi;
    }
    
    public PageReference setParams()
    {
        // Check whether the Object Id is for a Quote
        if(objectId!=null){
            String objectAPIName = ((Id)objectId).getSObjectType().getDescribe().getName();
            if (objectAPIName.toLowerCase().contains('quote')){
                 isQuote = true;
            } else isQuote = false;
        }

        // If the new Payment is not for a Quote, assume that it is for a Billing Account
        // and call the updatePaymentMethod future class to update the Default Payment Method 
        // and Default Payment Gateway on the Account in Zuora 
        if(!isQuote) {
            Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
            ba.Id = objectId;
            ba.ElectronicPaymentMethodId__c = paymentId;
            update ba;
            
            updatePaymentMethod(objectId, paymentId);
        }
        
        return null;
    }
    
    // Method to update the Default Payment Method and Default Payment Gateway on the Account in Zuora. Mthod is public only for test purpose
    @future(callout=true)
    public static void updatePaymentMethod(String accountId, String paymentId){
        List <Zuora.zObject> recordsToUpdate = new List<Zuora.zObject> ();

        // Read the Zuora Account Id and the Zuora Country Code from the Billing Account
        List<Zuora__CustomerAccount__c> acc = [select Zuora__Zuora_Id__c, Zuora__Account__r.Zuora_Country_Code__c from Zuora__CustomerAccount__c where Id = :accountId];
        if(acc.size()==1){
            
            String zuoraId = acc.get(0).Zuora__Zuora_Id__c;
            String countryPrefix = acc.get(0).Zuora__Account__r.Zuora_Country_Code__c;

            // Call Zuora to get the Type of the newly created Payment Method
            // (Can't rely on getting it from the Salesforce object as it may not have been sync'd across from Zuora yet)
            String paymentMethodType;
            Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
            qr.zoql = 'SELECT Type FROM PaymentMethod WHERE Id=\'' + paymentId + '\'';
            
            if(!Test.isRunningTest()) // Only call Zuora if not in test mode
            {
                getApiStub();
                Zuora.zApi.QueryResult queryResult = zapi.zquery(qr);
                System.Debug('**** Zuora Account Payment Method Query Result: ' + queryResult);
                
                if(queryResult.records.size() == 1){
                    // Need to add spaces into the Payment Type Name so that the Hosted Payment Page Setting query below works successfully
                    if ((String)queryResult.records.get(0).getValue('Type') == 'CreditCard') {
                         paymentMethodType = 'Credit Card';
                    } else if ((String)queryResult.records.get(0).getValue('Type') == 'ACH') {
                         paymentMethodType = 'ACH';
                    } else if ((String)queryResult.records.get(0).getValue('Type') == 'BankTransfer') {
                         paymentMethodType = 'Bank Transfer';
                    }                    
                }
            } else //Set the Payment Method Type to "Credit Card" for testing purposes
            {
                paymentMethodType = 'Credit Card';
            }
            
            // If the Payment Method Type was found, read the Hosted Payment Page object to find the Gateway Name
            if(paymentMethodType != null) {
            
                List<zqu__HostedPageLiteSetting__c> pageSettings = (List<zqu__HostedPageLiteSetting__c>)Database.query('SELECT  Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE Name Like \'' + 'CBC ' + countryPrefix + ' ' + paymentMethodType + '%\'');
                if(pageSettings.size()==1){
            
                    String gateway = pageSettings.get(0).Payment_Gateway_Name__c;
                    
                    // We checked that the Gateway Name was populated in the DefaultPaymentMethodCreationController 
                    // before displaying the payment page so it shouldn't be null here, but check again before calling Zuora
                    if (gateway != null) {

                        Zuora.zObject zo = new Zuora.zObject('Account');
                        zo.setValue('Id', zuoraId);
                        zo.setValue('DefaultPaymentMethodId', paymentId);
                        zo.setValue('PaymentGateway', gateway);
                        recordsToUpdate.add(zo);
                    
                        if(!Test.isRunningTest()) // Only call Zuora if not in test mode
                        {
                            getApiStub();
                            List <Zuora.zApi.SaveResult> results = zapi.zUpdate(recordsToUpdate);
                            System.Debug('**** Zuora Account Default Payment Update Results: ' + results);
                            
                            Map<String, String> errorMessageMap = new Map<String, String>();
                            for(Zuora.zApi.SaveResult result : results){
                                 if (!result.Success){
                                    //failure
                                    for(Zuora.zObject error : result.errors){   
                                        errorMessageMap.put(result.Id, (String)error.getValue('Message'));
                                    }
                                }
                            }
                            if(errorMessageMap.keySet().size() > 0){
                                ExceptionHandler.logZuoraRecordProcessingErrors('UpdateInvoiceStatusQueued', 'updateZuoraInvoice', errorMessageMap);
                            }
                        }
                    }
                }
            }
        }
    }
}