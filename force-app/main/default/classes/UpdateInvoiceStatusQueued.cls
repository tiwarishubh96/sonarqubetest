/**
 * This class "unposts" the newly created invoice in Zuora
 * then it updates various account settings to allow Zuora to email out the invoice and process payment
 * then it inserts the regional invoice number into the invoice,
 * then it regenerates the invoice pdf
 * then it "reposts" the invoice which will result in Zuora emailing it to the customer
 * then it takes an immediate payment (rather than waiting for the Zuora overnight payment run)
 */
public class UpdateInvoiceStatusQueued implements Queueable {
    /**
    * @param zQuote [zqu__quote__c object]
    * @param autoInvoiceId [SFDC invoice number]
    * @param invoiceTemplateId [Zuora Id of the invoice template]
    * @param communicationProfileId [Zuora Id of the communication profile]
    * @param defaultPaymentMethodId [Zuora Id of the default payment method]
    * @param defaultPaymentGateway [Name of the default payment gateway]
    */
    private String zQuoteId;
    private String autoInvoiceId;
    private String invoiceTemplateId;
    private String communicationProfileId;
    private String defaultPaymentMethodId;
    private String defaultPaymentGateway;
    
    /**
    * [Class constructor]
    * @param zQuoteId [SFDC quote id]
    * @param autoInvoiceId [SFDC invoice number]
    * @param invoiceTemplateId [Zuora Id of the invoice template]
    * @param communicationProfileId [Zuora Id of the communication profile]
    * @param defaultPaymentMethodId [Zuora Id of the default payment method]
    * @param defaultPaymentGateway [Name of the default payment gateway]
    */
    public UpdateInvoiceStatusQueued(String zQuoteId, String autoInvoiceId, String invoiceTemplateId, String communicationProfileId, String defaultPaymentMethodId, String defaultPaymentGateway) {
        this.zQuoteId = zQuoteId;
        this.autoInvoiceId = autoInvoiceId;
        this.invoiceTemplateId = invoiceTemplateId;
        this.communicationProfileId = communicationProfileId;
        this.defaultPaymentMethodId = defaultPaymentMethodId;
        this.defaultPaymentGateway = defaultPaymentGateway;
    }
    
    /**
    * [Queueable interface method]
    * @param context [Queueable interface internal parameter]
    */
    public void execute (QueueableContext context){
        updateZuoraFuture(zQuoteId, autoInvoiceId, invoiceTemplateId, communicationProfileId, defaultPaymentMethodId, defaultPaymentGateway);
    }

    /**
    * [updateZuoraFuture logins and calls methods, which updates fields on account, invoice in zuora and invoice in salesforce, related to the quote]
    * @param zQuoteId [SFDC quote id]
    * @param autoInvoiceId [SFDC invoice number]
    * @param invoiceTemplateId [Zuora Id of the invoice template]
    * @param communicationProfileId [Zuora Id of the communication profile]
    * @param defaultPaymentMethodId [Zuora Id of the default payment method]
    * @param defaultPaymentGateway [Name of the default payment gateway]
    */
    @future(callout=true)
    public static void updateZuoraFuture(String zQuoteId, String autoInvoiceId, String invoiceTemplateId, String communicationProfileId, String defaultPaymentMethodId, String defaultPaymentGateway)
    {   
        Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('UpdateInvoiceStatusQueued.updateZuoraFuture'); //loginToZuora parameter is used to track errors
        zqu__quote__c zQuote; //future methods cannot have SObject as parameters, so zQuote cannot be passed from SendToZBillingAJAXController class.
        try {
            zQuote = [SELECT zqu__Account__r.Sales_Office__c,zqu__Account__r.VAT_Number__c,zqu__Previewed_Total__c,zqu__InvoiceID__c,zqu__ZuoraAccountID__c FROM zqu__Quote__c WHERE Id=:zQuoteId];
        } catch (Exception e){     
            ExceptionHandler.CatchException('UpdateInvoiceStatusQueued', 'updateZuoraFuture', e); 
            return; 
        }
        Zuora.zApi.QueryResult queryResult = callZuoraForInvoiceNumber(zApiInstance, zQuote);
        if(queryResult == null || Test.isRunningTest()) return;
        String errorInvoiceMessage = updateZuoraInvoice(zApiInstance, zQuote, autoInvoiceId, invoiceTemplateId, communicationProfileId, (Decimal)queryResult.records.get(0).getValue('Balance'), defaultPaymentMethodId, defaultPaymentGateway);
        updateRegionalInvoiceObject(zQuote, autoInvoiceId, errorInvoiceMessage, (String)queryResult.records.get(0).getValue('InvoiceNumber'));
    }
    
    /**
    * [callZuoraForInvoiceNumber is calling zuora for invoice fields: balance and invoice number
    *  Balance is used for the immediate payment and invoice number is written back to the regional invoice object for audit purposes]
    * @param zApiInstance [instance for using the zuora api]
    * @param zQuote [SFDC cquote object]
    * @return [zuora result query]
    */
    private static Zuora.zApi.QueryResult callZuoraForInvoiceNumber(Zuora.zApi zApiInstance, zqu__quote__c zQuote){
    	if(Test.isRunningTest()) return null;
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'SELECT InvoiceNumber, Balance FROM Invoice WHERE Id=\'' + zQuote.zqu__InvoiceID__c + '\'';
        Zuora.zApi.QueryResult queryResult = zApiInstance.zquery(qr);
        if(queryResult.records.size() == 0){
            Map<String, String> errorMessageMap = new Map<String, String>();
            errorMessageMap.put(zQuote.Id, 'Cannot find invoice with Id: ' + zQuote.zqu__InvoiceID__c + ' in Zuora');
            ExceptionHandler.logZuoraRecordProcessingErrors('UpdateInvoiceStatusQueued', 'callZuoraForInvoiceNumber', errorMessageMap); 
            return null;
        }
        return queryResult;
    }

    /**
    * [updateRegionalInvoiceObject is updating the regional invoice object(s) in SFDC. (The regional invoice objects are used to generate a sequential 
    *  regional invoice number.  Currently there is a US Invoice object and a UK Invoice object and there may be additional objects in the future (e.g. ASIAPAC)
    *  The update is to write back the Zuora Invoice number for audit purposes along with an error message if there was any issue with updating the Invoice in this class]
    * @param autoInvoiceId [regional invoice number]
    * @param errorInvoiceMessage [error message, null if no error occured in this class]
    * @param invoiceNumber [zuora invoice number, obtained from callZuoraForInvoiceNumber method]
    */
    private static void updateRegionalInvoiceObject(zqu__quote__c zQuote, String autoInvoiceId, String errorInvoiceMessage, String invoiceNumber){
        try {   
            String invoiceObjApi = Zuora_Invoice_Mapping__c.getAll().get(zQuote.zqu__Account__r.Sales_Office__c).Invoice_Object__c;
            sObject invoice = Database.query('SELECT Id, Z_Invoice_Number__c FROM ' + invoiceObjApi + ' WHERE Name=\'' + autoInvoiceId + '\'');
            invoice.put('Z_Invoice_Number__c', invoiceNumber);
            invoice.put('Z_Invoice_Error_Message__c', errorInvoiceMessage);
            update invoice;
        } catch(Exception e){     
            ExceptionHandler.CatchException('UpdateInvoiceStatusQueued', 'updateRegionalInvoiceObject', e);
        }
    }

    /**
     * [updateStatusAndCommProfile updates in zuora the following fields related to the quote:
     * 1) updates the status of the invoice to 'draft'
     * 2) updates the communication profile of the account to be 'active', and the batch to 'batch1'.  
     *    Also inserts the vat number and sets the default payment method and gateway and sets autopay to true. 
     * 3) updates the Invoice_Sequence_Number__c of the invoice to the regional invoice number generated
     * 4) tells zuora to regenerate the invoice pdf (so that it includes the regional invoice number when it is emailed out)
     * 5) and finally sets the invoice status back to 'posted'
     * Method also collect payment]
     * @param zApiInstance  [instance for using the zuora api]
     * @param zQuoteId [SFDC quote id]
     * @param autoInvoiceId [SFDC invoice number]
     * @param invoiceTemplateId [Zuora Id of the invoice template]
     * @param communicationProfileId [Zuora Id of the communication profile]     
     * @param balance [Invoice balance]
     * @param defaultPaymentMethodId [Zuora Id of the default payment method] 
     * @param defaultPaymentGateway [Name of the default payment gateway]   
     */
    public static String updateZuoraInvoice(Zuora.zApi zApiInstance, zqu__quote__c zQuote, String autoInvoiceId, String invoiceTemplateId, String communicationProfileId, Decimal balance, String defaultPaymentMethodId, String defaultPaymentGateway){     
        List<Zuora.zObject> objs = new List<Zuora.zObject> {};
        String invoiceId = zQuote.zqu__InvoiceID__c;   
        String accountId = zQuote.zqu__ZuoraAccountID__c;                     
            
        if(!ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Invoice', new Map<String,Object> {'Id'=>invoiceId,'Status'=>'Draft'}, 'UpdateInvoiceStatusQueued')) return Label.lbl_Invoice_Draft_Failed;
        if(!ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>accountId,'InvoiceTemplateId'=>invoiceTemplateId,'CommunicationProfileId'=>communicationProfileId,'Batch'=>'Batch2','VAT_Number__c'=>zQuote.zqu__Account__r.VAT_Number__c,'DefaultPaymentMethodId'=>defaultPaymentMethodId,'PaymentGateway'=>defaultPaymentGateway,'AutoPay'=>true}, 'UpdateInvoiceStatusQueued')) return Label.lbl_Comm_Profile_Batch_2_Failed; 

        if(String.isNotBlank(autoInvoiceId)){
            if(!ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Invoice', new Map<String,Object> {'Id'=>invoiceId, 'Invoice_Sequence_Number__c'=>autoInvoiceId}, 'UpdateInvoiceStatusQueued')) return Label.lbl_RegionalInvoiceNumberCalloutError;
            if(!ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Invoice', new Map<String,Object> {'Id'=>invoiceId, 'RegenerateInvoicePDF'=>true}, 'UpdateInvoiceStatusQueued')) return Label.lbl_RegionalInvoicePDFCalloutError;
            if(!ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Invoice', new Map<String,Object> {'Id'=>invoiceId, 'Status'=>'Posted'}, 'UpdateInvoiceStatusQueued')) return Label.lbl_InvoiceStatusToPostedCalloutError;
        }
        
        // create a payment record in zuora to collect payment immediately
        Zuora.zObject payment = new Zuora.zObject('Payment');
        payment.setValue('AccountId', zQuote.zqu__ZuoraAccountID__c);
        payment.setValue('Amount', balance);
        payment.setValue('AppliedInvoiceAmount', balance);
        payment.setValue('EffectiveDate',system.now().format('yyyy-MM-dd\'T\'hh:mm:ss'));
        payment.setValue('InvoiceId',zQuote.zqu__InvoiceID__c);
        payment.setValue('PaymentMethodId', defaultPaymentMethodId);
        payment.setValue('Status','Processed');
        payment.setValue('Type','Electronic');

        objs = new List<Zuora.zObject> {payment};
        List<Zuora.zApi.SaveResult> results = zApiInstance.zcreate(objs);
 
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
            return Label.lbl_Immediately_Payment_Failed;
        }
        return null; //no error message
    }
}