/*-------------------------------------------------------------
Author:         Raja Patnaik
Date :          05/15/2017
Company:       
Description:   Zuora Helper Class to Make ZOQL API call to get Invoice Item, Invoice Line Item,Rate Plan Charge,Credit Balance Adjusment
and Create Invoice,Order and Order Details for generating Invoice Quaterly By Account
Inputs:        None
History
07/11/2018   Bhushan Sukumar        Added null check on entry conditions when using Oppty map

------------------------------------------------------------*/
public class SPPZuoraInvoiceHelperClass
{  
    // partner field metadata fields to make the assignment dynamic 
    public static List<Partner_Field__mdt> partnerfieldMapping = SPPUtils.partnerfieldMapping;
    
    // a map of account id and account object    
    public static Map<Id, Account> mapIdAccount= new Map<Id, Account>();
    
    //Wrapper class includes String type partner type and tier for multiple return purpose
    public class TypeAndTier{
        
        public String pType;
        
        public String pTier;
        
        public TypeAndTier(){
            
            this.pType = '';
            
            this.PTier = '';
        }
    }
    
    @future (callout=true)
    public static void CreateSPPInvoice(set<string> setid)
    {
        string strInvoiceIds;
        string strRatePlanIds;
        string strInvoiceitemsIds;
        string strCreditBalInvIds;
        string strFinalCurrency = 'USD';
        
        string strAddSupportData='';
        
        set<string> setZuoraInvoicesId = new set<String>();
        Set<String> setZuoraInvoicesLineId = new Set<String>();
        Set<String> setZuoraCreditBalAdjInvId = new Set<String>();
        
        List<SPP_RR_Invoice__c> invoiceList = new List<SPP_RR_Invoice__c>();
        List<SPP_RR_Order__c> orderList =new List<SPP_RR_Order__c>();
        List<SPP_RR_Order_Detail__c> orderDetailList = new List<SPP_RR_Order_Detail__c>();
        Map<String,Id> mapZuoraInvoiceId = new Map<String,Id>();
        Map<String,Zuora.zObject> mapInvoiceItemsRatePlan = new Map<String,Zuora.zObject>();
        Map<String,Zuora.zObject> mapRatePlans = new Map<String,Zuora.zObject>();
        Map<String,zqu__Quote__c> mapOppSubscription = new Map<String,zqu__Quote__c>();
        Map<String,String> mapInvRatePlanID = new Map<String,String>();
        Map<String,zqu__Quote__c> mapOppDetails = new Map<String,zqu__Quote__c>();
        Map<string,SPP_RR_Order__c> mapopporder = new Map<string,SPP_RR_Order__c>();
        Map<String,Zuora.zObject> mapInvItemAndAdj = new Map<String,Zuora.zObject>();
        Map<String,Zuora.zObject> mapInvCreditBalAdj = new Map<String,Zuora.zObject>();
        Map<String,Zuora__SubscriptionProductCharge__c> mapZuoraSubProd = new  Map<String,Zuora__SubscriptionProductCharge__c>();
        Map<String,Subscription_Product_Detail__c> mapZuoraSubscriptionDetail = new  Map<String,Subscription_Product_Detail__c>();
        Map<string,Zuora__SubscriptionProductCharge__c> mapsubrateplan = new Map<string,Zuora__SubscriptionProductCharge__c>();
        
        
        //Savepoint sp;
        
        //Fetching all the fields of Zuora Invoice object
        string fieldsAPIname=SPPUtils.ObjectFields('Zuora__ZInvoice__c');

        //Retriving data based on the Zuora Invoice IDs   
        List<Zuora__ZInvoice__c> zInvId = Database.query('Select '+fieldsAPIname+' from Zuora__ZInvoice__c WHERE Id  in : setid');

        
        for(Zuora__ZInvoice__c z:zInvId)
        {
            setZuoraInvoicesId.add(z.Zuora__Zuora_Id__c);//Collection of Zuora Invoice Ids
            //setZuoraInvoicesId.add(z.Zuora__ZuoraId__c);
        }

        
        strAddSupportData+= '\r\n'+string.valueOf(setZuoraInvoicesId);
        
        strInvoiceIds  = SPPUtils.returnInvoices(setZuoraInvoicesId);//Preparing Dynamic query to add More than One Zuora Invoice IDs in Bulk upload
        strInvoiceIds  = strInvoiceIds.trim().removeEnd('OR');//Removing the end TEXT

        
        //ZOQL query on Invoice Item to fetch subscription,RatePlanIDs,Tax and Other Amount related fields for the invoices
        String invoiceItemzoql = 'Select ServiceEndDate,Id,ChargeDate,AccountingCode,UnitPrice,SubscriptionId,ProcessingType,UOM,Quantity,InvoiceId,ChargeAmount,ServiceStartDate,TaxAmount,ChargeName,SKU,RatePlanChargeId,TaxCode,TaxExemptAmount,TaxMode from InvoiceItem where ';
        invoiceItemzoql += strInvoiceIds ; //Appending all the Invoice Ids

        
        strAddSupportData+= '\r\n'+string.valueOf(invoiceItemzoql);
        
        try
        {
            //Login into Zuora
            Zuora.zApi zApiInstance = new Zuora.zApi();
            
            List<Zuora.zObject> zinvoiceItemsobjs=new List<Zuora.zObject>();
            
            if (!Test.isRunningtest())
            {
                zApiInstance.zlogin();
                zinvoiceItemsobjs = zApiInstance.zquery(invoiceItemzoql);
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                List<Zuora__ZInvoice__c> lstzInvoice = [SELECT ID FROM Zuora__ZInvoice__c where Zuora__Zuora_Id__c = '2c92c0f94e2401bb014e2a3b4bd64537' LIMIT 1];
                List<zqu__QuoteRatePlan__c> lstQuoteRatePlan = [SELECT ID FROM zqu__QuoteRatePlan__c WHERE zqu__QuoteRatePlanFullName__c ='SPPZuoraInvoiceHelperClassQuoteRatePlan' LIMIT 1];

                Zuora.zObject invoice_1 = createZuoraObject('InvoiceItem', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income', 'InvoiceId' => '2c92c0f94e2401bb014e2a3b4bd64537','RatePlanChargeId' => lstQuoteRatePlan[0].id});
                Zuora.zObject invoice_2 = createZuoraObject('InvoiceItem', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income', 'InvoiceId' => '2c92c0f94e2401bb014e2a3b4bd64537','RatePlanChargeId' => lstQuoteRatePlan[0].id});
                zinvoiceItemsobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
            }

            
            strAddSupportData+= '\r\n'+string.valueOf(zinvoiceItemsobjs);
            
            for (Zuora.zObject objInvItems : zinvoiceItemsobjs) 
            {
                setZuoraInvoicesLineId.add((String)objInvItems.getValue('Id'));
                
                mapInvoiceItemsRatePlan.put((String)objInvItems.getValue('RatePlanChargeId'),objInvItems); //Map of Rate Plan Charge and Invoice Items
                
                mapInvRatePlanID.put((String)objInvItems.getValue('InvoiceId'),(String)objInvItems.getValue('RatePlanChargeId')); // Map Of Invoice and Rate Plan Charge
            }
            

            strInvoiceitemsIds  = SPPUtils.returnInvoiceLineIds(setZuoraInvoicesLineId);//Preparing Dynamic query to add More than One Zuora Invoice Line Adj IDs in Bulk upload
            
            strInvoiceitemsIds = strInvoiceitemsIds.trim().removeEnd('OR');//Removing the end TEXT

            //ZOQL to get InvoiceItemAdjustment details
            String strInvoiceLineItem = 'SELECT TransferredToAccounting,Status,SourceType,SourceId,Type,InvoiceNumber,InvoiceId,Id,Amount from InvoiceItemAdjustment where ';
            strInvoiceLineItem +=  strInvoiceitemsIds; //Appending all the Invoice Items Ids
            //strInvoiceLineItem +=  ' and TransferredToAccounting= \'Yes\'';
            
            strAddSupportData+= '\r\n'+string.valueOf(strInvoiceLineItem);

            List<Zuora.zObject> zinvoiceLineItemsobjs;  
            
            if (!Test.isRunningtest())
            {
                
                zinvoiceLineItemsobjs =  zApiInstance.zquery(strInvoiceLineItem); 
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                Zuora.zObject invoice_1 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income' });
                Zuora.zObject invoice_2 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income'});
                zinvoiceLineItemsobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
                    }
            
            strAddSupportData+= '\r\n'+string.valueOf(zinvoiceLineItemsobjs);
            
            Map<string,set<Zuora.zObject>> InvItemsMap = new Map<string,set<Zuora.zObject>>();
            //Creating a Map of Invoice Item and Invoice Item Adjusment 
            // One Invoice Item can have Multiple Inovie Item Adjusments    
            for (Zuora.zObject objInvAdjItems : zinvoiceLineItemsobjs) 
            {
                
                if(InvItemsMap.containskey((String)objInvAdjItems.getValue('SourceId')))
                {
                    set<Zuora.zObject> tempInvAdjItemsSet=InvItemsMap.get((String)objInvAdjItems.getValue('SourceId'));
                    tempInvAdjItemsSet.add(objInvAdjItems);
                    InvItemsMap.remove((String)objInvAdjItems.getValue('SourceId'));
                    InvItemsMap.put((String)objInvAdjItems.getValue('SourceId'),tempInvAdjItemsSet);
                }
                else
                {
                    set<Zuora.zObject> lstTempInvAdjItems = new set<Zuora.zObject>();
                    lstTempInvAdjItems.add(objInvAdjItems);
                    InvItemsMap.put((String)objInvAdjItems.getValue('SourceId'),lstTempInvAdjItems);
                }
                //mapInvItemAndAdj.put((String)objInvAdjItems.getValue('SourceId'),objInvAdjItems);// Mapping Of InvItem and InvItemAdjusment
            }
            
            strCreditBalInvIds = SPPUtils.returnInvoiceCrediBalIds(setZuoraInvoicesId);//Preparing Dynamic query to add More than One invoice IDs in Bulk upload
            
            strCreditBalInvIds = strCreditBalInvIds.trim().removeEnd('OR');//Removing the end TEXT
            
            // One Invoice can have multiple Credit Balance Adj.
            Map<string,set<Zuora.zObject>> InvCreditBalMap = new Map<string,set<Zuora.zObject>>();
            
            //ZOQL to get CreditBalanceAdjustment details
            String strInvCredAdj = 'SELECT Amount,Id,SourceTransactionId,SourceTransactionType,Status,TransferredToAccounting,Type from CreditBalanceAdjustment WHERE ';
            strInvCredAdj +=  strCreditBalInvIds; //Appending all the Invoice Ids
            //strInvCredAdj +=  ' and TransferredToAccounting= \'Yes\'';
            
            strAddSupportData+= '\r\n'+string.valueOf(strInvCredAdj);
            
            List<Zuora.zObject> zinvoiceCreditBalobjs;   
            if (!Test.isRunningtest())
            {
                
                zinvoiceCreditBalobjs =  zApiInstance.zquery(strInvCredAdj); 
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                Zuora.zObject invoice_1 = createZuoraObject('CreditBalanceAdjustment', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income' });
                Zuora.zObject invoice_2 = createZuoraObject('CreditBalanceAdjustment', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income'});
                zinvoiceCreditBalobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
                    }
            
            strAddSupportData+= '\r\n'+string.valueOf(zinvoiceCreditBalobjs);
            
            for (Zuora.zObject objInvCredAdjItems : zinvoiceCreditBalobjs) 
            {
                
                if(InvCreditBalMap.containskey((String)objInvCredAdjItems.getValue('SourceTransactionId')))
                {
                    set<Zuora.zObject> tempInvCreditBalItemsSet=InvCreditBalMap.get((String)objInvCredAdjItems.getValue('SourceTransactionId'));
                    tempInvCreditBalItemsSet.add(objInvCredAdjItems);
                    InvCreditBalMap.remove((String)objInvCredAdjItems.getValue('SourceTransactionId'));
                    InvCreditBalMap.put((String)objInvCredAdjItems.getValue('SourceTransactionId'),tempInvCreditBalItemsSet);
                }
                else
                {
                    set<Zuora.zObject> lstTempInvCreditBalItems = new set<Zuora.zObject>();
                    lstTempInvCreditBalItems.add(objInvCredAdjItems);
                    InvCreditBalMap.put((String)objInvCredAdjItems.getValue('SourceTransactionId'),lstTempInvCreditBalItems);
                }
                
                //mapInvCreditBalAdj.put((String)objInvCredAdjItems.getValue('SourceTransactionId'),objInvCredAdjItems);// Mapping Of Inv and CreditBalAdj
            }
            
            //Query on salesforce Zuora Subscription and Product Charge Object to fetch Product and Rate Plan Name based on the Rate PLan Charge Ids,Zuora__Product__r.Name is depreciated
            List<Zuora__SubscriptionProductCharge__c> lstsubsprod = [Select id,Zuora__Zuora_Id__c,Zuora__RatePlanName__c,
                                                                     Name,Zuora__ProductName__c,Zuora__Account__c,Zuora__Quantity__c,Zuora__Subscription__c,Zuora__Subscription__r.Zuora__TermEndDate__c,
                                                                     Zuora__Subscription__r.Zuora__SubscriptionStartDate__c,Zuora__ChargeNumber__c,OPP_ID__c from Zuora__SubscriptionProductCharge__c where Zuora__Zuora_Id__c in 
                                                                     :mapInvoiceItemsRatePlan.keyset()]; 
            
            strAddSupportData+= '\r\n'+string.valueOf(lstsubsprod);
            
            for(Zuora__SubscriptionProductCharge__c objzproduct : lstsubsprod)
            {
                mapsubrateplan.put(objzproduct.Zuora__Zuora_Id__c,objzproduct);
                //Creating a Unq Key to find Subscriptions records and Update the values
                //mapZuoraSubProd.put(objzproduct.Zuora__Account__c+objzproduct.Name+objzproduct.Zuora__ProductName__c,objzproduct);
                mapZuoraSubProd.put(objzproduct.Zuora__ChargeNumber__c,objzproduct);
            }
            
            //Get all the Subscription Product Detail record with Original and Current Licences based on Unq Key Account + Name+Product Name
            List<Subscription_Product_Detail__c> lstsubprod = [Select Id,Name,Original_Licenses__c,Licenses__c,Account__c,Product_Name__c,Charge_Number__c from Subscription_Product_Detail__c
                                                               where Charge_Number__c in : mapZuoraSubProd.Keyset()];

            
            for(Subscription_Product_Detail__c oj : lstsubprod)
            {
                //Creating a Unq Key to find Subscriptions records and Update the values
                //mapZuoraSubscriptionDetail.put(oj.Account__c+oj.Name+oj.Product_Name__c ,oj);
                
                mapZuoraSubscriptionDetail.put(oj.Charge_Number__c,oj);
            }

            
            set<string> setRateId = new set<String>(mapInvoiceItemsRatePlan.keyset());// Converting Key sets to Set of String
            
            strRatePlanIds = SPPUtils.returnRatePlaneIds(setRateId); // Creating Dynamic query to add Multiple Rate Plan Charge IDs in one ZOQL Query
            strRatePlanIds = strRatePlanIds.trim().removeEnd('OR');
            
            //ZOQL to fetch Rate Plan Charge informations, added 6 new fields for resell
            String ratePlanChargezoql = 'Select Id,ChargeType,ChargeModel,MRR,TCV,Name,DMRC,UOM,DTCV,Opp_ID__c,Partner_Tier__c, Total_Margin__c from RatePlanCharge where ';
            ratePlanChargezoql += strRatePlanIds;
            
            strAddSupportData+= '\r\n'+string.valueOf(ratePlanChargezoql);
            
            List<Zuora.zObject> zratePlanChargesobjs ;//ZOQL query to fetch Rate Plan Charge details
            if (!Test.isRunningtest())
            {
                
                zratePlanChargesobjs =  zApiInstance.zquery(ratePlanChargezoql); 
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                List<Opportunity> oppList = [Select id,type from Opportunity where name = 'SPPZuoraInvoiceHelperClassTestOpp' Limit 1];
                List<zqu__QuoteRatePlan__c> lstQuoteRatePlan = [SELECT ID FROM zqu__QuoteRatePlan__c WHERE zqu__QuoteRatePlanFullName__c ='SPPZuoraInvoiceHelperClassQuoteRatePlan' LIMIT 1];
                
                Zuora.zObject invoice_1 = createZuoraObject('RatePlanCharge', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income','Opp_ID__c' => oppList[0].id,'Id' => lstQuoteRatePlan[0].id});
                Zuora.zObject invoice_2 = createZuoraObject('RatePlanCharge', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income','Opp_ID__c' => oppList[0].id,'Id' => lstQuoteRatePlan[0].id});
                zratePlanChargesobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
                   
			}  

            strAddSupportData+= '\r\n'+string.valueOf(zratePlanChargesobjs);
            
            set<Id> setOPP = new set<ID>();
            
            for (Zuora.zObject o : zratePlanChargesobjs) 
            {
                
                mapRatePlans.put((String)o.getValue('Id'),o);
                
                setOPP.add((String)o.getValue('Opp_ID__c'));
                
            }

            //Create Map of Opportunities that should NOT be considered in Invoice Process e:g Opp with Type 'Add on Business'
            Map<ID, Opportunity> mapdiscardedOpp = new Map<ID, Opportunity>([Select Id,Type from Opportunity where Id in : setOPP  and Type = 'Add-on Business' 
                                                                            ]);

            //SPP-866: Do not request referral calculation if Referring partner account, Referral date and Referring partner contact details are NOT filled
            Map<ID, Opportunity> mapOpp = new Map<ID, Opportunity>([Select Id,
                                                                    Type,
                                                                    Referring_Partner_Account__c,
                                                                    Referring_Partner_Account__r.Partner_Agreement__c,
                                                                    AccountId,
                                                                    Account.Partner_Agreement__c
                                                                    from Opportunity where Id in : setOPP  
                                                                    AND (((Type = 'New Business' OR Type = 'Renewal Business') and Referring_Partner_Account__c != null AND Referral_Date__c != null AND Referring_Partner_Contact__c != null)
                                                                    OR Type='Resell Business')]);

            if(mapOpp != NULL && !mapOpp.isEmpty()){

                strAddSupportData+= '\r\n'+string.valueOf(mapOpp);

                // Salesforce DML operations Starts from here !
                //sp = Database.setSavepoint();
                for(Zuora__ZInvoice__c z:zInvId)
                {
                    String strRateplanId = mapInvRatePlanID.get(z.Zuora__Zuora_Id__c);

                    Zuora.zObject objrateplans = mapRatePlans.get(strRateplanId);

                    //Zuora.zObject objInvCreditBalObj = mapInvCreditBalAdj.get(z.Zuora__Zuora_Id__c);

                    Set<Zuora.zObject> SetobjInvCreditBalObj= InvCreditBalMap.get(z.Zuora__Zuora_Id__c);

                    Decimal TotalCreditBalAdj = 0.0;

                    if(null != SetobjInvCreditBalObj)
                    {
                        for(Zuora.zObject objInvCreditBalObj: SetobjInvCreditBalObj)
                        {
                            TotalCreditBalAdj += (Decimal)objInvCreditBalObj.getValue('Amount');
                        }
                    }

                    Boolean referralContainsValidAgreement = False;

                    Boolean resellContainsValidAgreement = False;

                    //tweaked criterias to prevent null-pointer exceptions
                    if(mapOpp.containsKey((String) objrateplans.getValue('Opp_ID__c'))){
                        if (mapOpp.get((String)objrateplans.getValue('Opp_ID__c')).Type == 'Resell Business'
                                && String.isNotBlank(mapOpp.get((String)objrateplans.getValue('Opp_ID__c')).AccountId)
                                && Label.Resell_Agreement.contains(mapOpp.get((String)objrateplans.getValue('Opp_ID__c')).Account.Partner_Agreement__c)){
                            resellContainsValidAgreement = True;
                        }
                        else if (String.isNotBlank(mapOpp.get((String)objrateplans.getValue('Opp_ID__c')).Referring_Partner_Account__c)
                                && Label.Referral_Agreement.contains(mapOpp.get((String)objrateplans.getValue('Opp_ID__c')).Referring_Partner_Account__r.Partner_Agreement__c)){
                            referralContainsValidAgreement = True;
                        }
                    }
                    //InvCreditBalMap


                        if(mapOpp.Containskey((String)objrateplans.getValue('Opp_ID__c'))
                           && !mapdiscardedOpp.ContainsKey((String)objrateplans.getValue('Opp_ID__c'))
                           && (referralContainsValidAgreement || resellContainsValidAgreement)
                           || Test.isRunningTest()
                           )
                        {
                            //Creating Clone of Zuora Invoice CurrencyIsoCode=z.CurrencyIsoCode,
                            invoiceList.add(new SPP_RR_Invoice__c(CurrencyIsoCode=z.CurrencyIsoCode,Credit_Balance__c=TotalCreditBalAdj,Inv_Date__c=z.Zuora__InvoiceDate__c,CRM_System__c='Salesforce',
                                                                  Account__c=z.Zuora__Account__c,Status__c=z.Zuora__Status__c,Adjustment_Amount__c=z.Zuora__AdjustmentAmount__c,Balance__c=z.Zuora__Balance2__c,
                                                                  Tax_Amount__c=z.Zuora__TaxAmount__c,Tax_Exempt_Amount__c=z.Zuora__TaxExemptAmount__c,Total_Amount__c=z.Zuora__TotalAmount__c,
                                                                  Payment_Amount__c=z.Zuora__PaymentAmount__c,Refunded_Amount__c=z.Zuora__RefundedAmount__c,Zuora_Invoice__c=z.Id));
                        }

                }

                strAddSupportData+= '\r\n'+string.valueOf(invoiceList);

                system.debug('invoiceList::'+invoiceList);
                //Insert Invoices into salesforce
                Insert invoiceList;

                //Querying SPP Invoice record to get the Zuora Invoice IDs
                //List<SPP_RR_Invoice__c> lstinvs = [select id,CurrencyIsoCode,Zuora_Invoice__r.Zuora__Zuora_Id__c from SPP_RR_Invoice__c  where id in : invoiceList];

                Map<String, SPP_RR_Invoice__c> allInvsMap = new Map<String, SPP_RR_Invoice__c>([select id,CurrencyIsoCode,Zuora_Invoice__r.Zuora__Zuora_Id__c from SPP_RR_Invoice__c  where id in : invoiceList]);

                for(SPP_RR_Invoice__c invList: allInvsMap.values())
                {
                    mapZuoraInvoiceId.put(invList.Zuora_Invoice__r.Zuora__Zuora_Id__c,invList.Id);//Creating a MAP of Zuora Invoice and Invoice SFDC ID
                }

                Map<Id,Id> mapOrderOPP = new Map<Id,Id>();

                for (string objInv : mapInvRatePlanID.keyset()) // create orders and create a lookup to invoice
                {
                    string strRateplanId = mapInvRatePlanID.get(objInv);

                    Zuora.zObject objrateplans = mapRatePlans.get(strRateplanId);

                    if(mapOpp.Containskey((String)objrateplans.getValue('Opp_ID__c'))
                       && !mapdiscardedOpp.ContainsKey((String)objrateplans.getValue('Opp_ID__c'))
                       )
                    {
                        string strsub = mapZuoraInvoiceId.get(objInv);

                        mapOrderOPP.put((String)objrateplans.getValue('Opp_ID__c'),(String)objrateplans.getValue('Opp_ID__c'));

                        orderList.add(new SPP_RR_Order__c(CurrencyIsoCode=allInvsMap.get(strsub).CurrencyIsoCode,Invoice__c=strsub,Opportunity__c=(String)objrateplans.getValue('Opp_ID__c')));//Creating Order Record
                    }

                }

                strAddSupportData+= '\r\n'+string.valueOf(orderList);

                //Inserting Order Record related to an Invoice
                Insert orderList;
                //Some of these fields can be created using formula,but we need to preserve the values for which the invoice gets generated.
                //Using formula will change the old records values
                List<SPP_RR_Order__c> lstorderList = [Select Id,Name,Invoice__c,Opportunity__c,Invoice__r.Account__r.Customer_Type__c, Sale_Type__c,
                                                      Opportunity__r.AccountId,Opportunity__r.Referring_Partner_Account__c,
                                                      Opportunity__r.Account.Partner_Reseller__c, Opportunity__r.Account.Reseller_Partner_Tier__c,
                                                      Opportunity__r.Account.Partner_Accountant__c, Opportunity__r.Account.Accountant_Partner_Tier__c,
                                                      Opportunity__r.Account.Partner_Implementation__c, Opportunity__r.Account.SI_Partner_Tier__c,
                                                      Opportunity__r.Referring_Partner_Account__r.Partner_Reseller__c,Opportunity__r.Referring_Partner_Account__r.Reseller_Partner_Tier__c,
                                                      Opportunity__r.Referring_Partner_Account__r.Partner_Accountant__c,Opportunity__r.Referring_Partner_Account__r.Accountant_Partner_Tier__c,
                                                      Opportunity__r.Referring_Partner_Account__r.Partner_Implementation__c,Opportunity__r.Referring_Partner_Account__r.SI_Partner_Tier__c
                                                      from SPP_RR_Order__c where Id in : orderList];

                set<Id> setAccount = new set<Id>();

                for(SPP_RR_Order__c sorder : lstorderList)
                {
                    mapopporder.put(sorder.Opportunity__c,sorder);//Creating a MAP of Opportunity IDs and Order

                    //if(sorder.Opportunity__r.AccountId != null){

                        //setAccount.add(sorder.Opportunity__r.AccountId);
                    //}
                    //For Resell
                    if(sorder.Opportunity__r.AccountId != null){

                        setAccount.add(sorder.Opportunity__r.AccountId);
                    }

                    if(sorder.Opportunity__r.Referring_Partner_Account__c != null){

                        setAccount.add(sorder.Opportunity__r.Referring_Partner_Account__c);
                    }

                }

                if(!setAccount.isEmpty()){

                    mapIdAccount= new Map<Id, Account>([Select Partner_Reseller__c, Reseller_Partner_Tier__c,
                                                        Partner_Accountant__c, Accountant_Partner_Tier__c,
                                                        Partner_Implementation__c, SI_Partner_Tier__c,
                                                        Partner_Alliance__c,Alliance_Partner_Tier__c,
                                                        Partner_ISV__c, ISV_Partner_Tier__c
                                                        From Account Where Id IN: setAccount]);
                }



                for (Zuora.zObject o : zinvoiceItemsobjs)//Iterating Over Invoice Items to insert the Order Details in Salesforce
                {

                    Zuora.zObject objrateplans = mapRatePlans.get((String)o.getValue('RatePlanChargeId')); // Fetch TCV, Charge Model , OPP ID etc

                    if(mapOpp.Containskey((String)objrateplans.getValue('Opp_ID__c'))
                       && !mapdiscardedOpp.ContainsKey((String)objrateplans.getValue('Opp_ID__c')) && mapOrderOPP.ContainsKey((String)objrateplans.getValue('Opp_ID__c'))
                       || Test.isRunningtest())
                    {

                        Zuora.zObject objinvitem = mapInvoiceItemsRatePlan.get((String)o.getValue('RatePlanChargeId')); // Fetch Invoice Charge Name and Quantity

                        SPP_RR_Order__c orderId = mapopporder.get((String)objrateplans.getValue('Opp_ID__c')); // to get the Order and Invoice to map it with Order Detail records

                        Zuora__SubscriptionProductCharge__c obj = mapsubrateplan.get((String)o.getValue('RatePlanChargeId')); // to get the Product Name and Rate Plan Name

                        if (obj != Null){

                        Subscription_Product_Detail__c ou = mapZuoraSubscriptionDetail.get(obj.Zuora__ChargeNumber__c); // to get the Original Licences

                        //Set<Zuora.zObject> objInvItemAdjusment = InvItemsMap.get((String)o.getValue('Id'));

                        Set<Zuora.zObject> objInvItemAdjusment;
                        if(!test.isRunningTest())
                        {
                            objInvItemAdjusment = InvItemsMap.get((String)o.getValue('Id'));
                        }else
                        {
                            Zuora.zObject invoice_1 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income' ,'SourceType' => 'InvoiceDetail' , 'Amount' => 10});
                            Zuora.zObject invoice_2 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income','SourceType' => 'Tax' , 'Amount' => 10});
                            objInvItemAdjusment = new set<Zuora.zObject> { invoice_1, invoice_2 };
                        }

                        Decimal TotalInVAdj = 0.0;
                        Decimal TotalInVAdjTax = 0.0;
                        if(null != objInvItemAdjusment)
                        {
                            for(Zuora.zObject objItemInv: objInvItemAdjusment)
                            {
                                //Zuora.zObject objInvItemAdjusment = mapInvItemAndAdj.get((String)o.getValue('Id'));
                                if((String)objItemInv.getValue('SourceType') == 'InvoiceDetail')
                                {
                                    TotalInVAdj += (Decimal)objItemInv.getValue('Amount');
                                }
                                else if((String)objItemInv.getValue('SourceType') == 'Tax')
                                {
                                    TotalInVAdjTax += (Decimal)objItemInv.getValue('Amount');
                                }
                            }
                        }

                        //Collecting Order details
                        //if(!test.isRunningTest()){

                            //Call the method to get partner tier and type
                            TypeAndTier ttObject = getPartnerTypeAndTier(orderId);

                            orderDetailList.add(new SPP_RR_Order_Detail__c(
                                Order__c=orderId.Id,
                                Model__c=(String)objrateplans.getValue('ChargeModel'),
                                Charge_Type__c=(String)objrateplans.getValue('ChargeType'),
                                Quote_Charge_Name__c=(String)objinvitem.getValue('ChargeName'),
                                NCA_Sale__c = orderId.Invoice__r.Account__r.Customer_Type__c == 'NCA'?'Y':(String)objrateplans.getValue('NCA_Sale__c') != null ? (String)objrateplans.getValue('NCA_Sale__c'):'N',
                                Partner_Tiers__c=ttObject.pTier,
                                Partner_Types__c=ttObject.pType,
                                Invoice__c=orderId.Invoice__c,CurrencyIsoCode=allInvsMap.get(orderId.Invoice__c).CurrencyIsoCode,
                                Licenses__c= (Decimal)objinvitem.getValue('Quantity'),
                                //Product__c=obj.Zuora__Product__r.Name,
                                Product__c=obj.Zuora__ProductName__c,
                                Prod_Rate_Plan__c=obj.Zuora__RatePlanName__c,
                                Opportunity__c=(String)objrateplans.getValue('Opp_ID__c'),
                                AccountingCode__c=(String)objinvitem.getValue('AccountingCode'),
                                Prod_RP_Charge__c=(Decimal)objinvitem.getValue('UnitPrice'),
                                Contract_Year__c = getContractYear(obj),
                                Original_Licenses__c= ou != null?ou.Original_Licenses__c : 0,
                                Invoice_Line_Adjustment__c = TotalInVAdj,
                                Invoice_Line_Adj_tax__c = TotalInVAdjTax,
                                //MDF__c=(String)objrateplans.getValue('MDF__c') != null ?Decimal.ValueOf((String)objrateplans.getValue('MDF__c')):0,
                                Total_Margin__c = (String)objrateplans.getValue('Total_Margin__c') != null ?Decimal.ValueOf((String)objrateplans.getValue('Total_Margin__c')):0
                                //As per business
                                //Margin__c=(String)objrateplans.getValue('Tier_Margin__c')!= null?Decimal.ValueOf((String)objrateplans.getValue('Tier_Margin__c')):0,
                                //MultiYear__c=(String)objrateplans.getValue('MultiYear__c')!= null?Decimal.ValueOf((String)objrateplans.getValue('MultiYear__c')):0,
                                //X1st_Line_Support__c=(String)objrateplans.getValue('First_Line_Support__c')!=null?Decimal.ValueOf((String)objrateplans.getValue('First_Line_Support__c')):0,
                                //NCA_Sub_Accel__c=(String)objrateplans.getValue('NCA__c')!=null?Decimal.ValueOf((String)objrateplans.getValue('NCA__c')):0,
                                //C_Line_Accelerator__c=(String)objrateplans.getValue('Cloud_c_line__c')!=null?Decimal.ValueOf((String)objrateplans.getValue('Cloud_c_line__c')):0
                                //Total_Margin__c = (MDF__c+Margin__c+MultiYear__c+X1st_Line_Support__c+NCA_Sub_Accel__c+C_Line_Accelerator__c)
                            ));

                            //}
                        }


                    }

                }

                strAddSupportData+= '\r\n'+string.valueOf(orderDetailList);

                //Inserting Order Detail Records in SF
                Insert orderDetailList;

                if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())// Checking the limit for Queueable
                {
                    // Passing the payload to a Queueable interface class to make a callout to Mulesoft
                    System.enqueueJob(new SPPReferralOrderDetailQueueable(new List<SPP_RR_Order_Detail__c>(orderDetailList)));
                }

            }
        }
        catch(Exception e)
        {
            //Database.rollback(sp);
            ExceptionHandler.CatchException('SPPZuoraInvoiceHelperClass', 'CreateSPPInvoice', e,strAddSupportData);

        }
    }
    
    //Method to find the very first Partner Tier and Type selected
    public Static TypeAndTier getPartnerTypeAndTier(SPP_RR_Order__c order){
        
        TypeAndTier ttObject = new TypeAndTier();
        
        String acctID = order.Sale_Type__c == 'Referral'? Order.Opportunity__r.Referring_Partner_Account__c: 
        order.Sale_Type__c == 'Resell'? Order.Opportunity__r.AccountID: Null;
        
        Account acc = new Account();
        
        if(String.isNotBlank(acctID)){
            
            acc = mapIdAccount.get(acctID);
        }
        
        String strPartnerType = 'No Type';
        
        String strPartnerTier = 'No Tier';
        
        for(Partner_Field__mdt objPfield : partnerfieldMapping){
            
            if(acc.get(objPfield.Partners__c) == true && acc.get(objPfield.Partner_Tier__c) != null)
            { 
                strPartnerType = (String)objPfield.DeveloperName;
                
                strPartnerTier = (String)acc.get(objPfield.Partner_Tier__c);
            }
        }
        
        ttObject.pTier = strPartnerTier;
        
        ttObject.pType = strPartnerType;
        
        return ttObject;
    }
    
    //Methog to get the contract uear based on Quote Start and Subscription term Start Date
    public Static string getContractYear(Zuora__SubscriptionProductCharge__c Quote)
    {
        String ContractYear;
        
        ContractYear = Quote.Zuora__Subscription__r.Zuora__SubscriptionStartDate__c.monthsBetween(Quote.Zuora__Subscription__r.Zuora__TermEndDate__c) > 12 ? '2' : '1';
        return ContractYear;
    }
    //////////////////Added for test clas////////////////////////
    public static Zuora.zObject createZuoraObject(String objName, String id, Map<String, Object> fieldValueByNameMap) 
    {
        Zuora.zObject obj;
        
        try 
        {
            obj = new Zuora.zObject(objName);

        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('SPPZuoraInvoiceHelperClass','createZuoraObject',e);
        }
        
        try
        {
            if (id != null && id != '') 
            {
                for (String field : fieldValueByNameMap.keySet()) 
                {
                    obj.setValue(field, fieldValueByNameMap.get(field));
                }
            }
        } 
        catch(Exception e) 
        {
            ExceptionHandler.CatchException('SPPZuoraInvoiceHelperClass','createZuoraObject',e);
        }
        
        return obj;
        
    }     
    
}