/**********************************************************************
 Name:  SPPQuoteTriggerHandler

======================================================
======================================================
Purpose: Handle the logic for trigger SPPQuoteTrigger
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Yue Lu     			05/16/2018          Initial Development
***********************************************************************/
public class SPPQuoteTriggerHandler {
    
    public static void populateOppID(List<zqu__Quote__c> lstQuote){
        
        Set<string> setSubName = new Set<string>();
    
        Map<string,string> mapSubOpp = new Map<string,string>();
        
        Map<string, string> subsMap = new Map<string, string>();
        
        Map<string, string> ratePlansMap = new Map<string, string>();
        
        for(Integer i=0; i<lstQuote.size(); i++)
        {
            if(lstQuote[i].zqu__Subscription_Name__c != null)
            {
            	setSubName.add(lstQuote[i].zqu__Subscription_Name__c);
            
            	mapSubOpp.put(lstQuote[i].zqu__Subscription_Name__c, lstQuote[i].zqu__Opportunity__c);
            }
        }
    
        system.debug('setSubName'+setSubName);
        
        system.debug('mapSubOpp'+mapSubOpp);
    
        List<Zuora__SubscriptionProductCharge__c> lstsubprodCharge = [Select Id,Zuora__Subscription__c,Opp_Id__c,Zuora__Subscription__r.Name, Zuora__RatePlanId__c
        																FROM Zuora__SubscriptionProductCharge__c 
                                                                      	WHERE Zuora__Subscription__r.Name IN : setSubName];
        
        system.debug('lstsubprodCharge: ################### '+lstsubprodCharge);
		//One subscription can have more than one Product and Charge
        for(Zuora__SubscriptionProductCharge__c objSub : lstsubprodCharge)
        {
            
            system.debug('mapSubOpp.get(objSub.Zuora__Subscription__r.Name)'+mapSubOpp.get(objSub.Zuora__Subscription__r.Name));
          
            if(mapSubOpp.Containskey(objSub.Zuora__Subscription__r.Name))
            {
                objSub.Opp_Id__c = mapSubOpp.get(objSub.Zuora__Subscription__r.Name);
                                
                ratePlansMap.put(objSub.Zuora__RatePlanId__c, objSub.Zuora__Subscription__r.Name);
            }
          
        }
        System.debug('ratePlansMap####################: ' + ratePlansMap);
        //sets if the quote needs to 'link' to an external app
        List<zqu__ProductRatePlan__c> productRatePlanItems = [select ID, zqu__ZuoraId__c, ExternalApplication__c FROM zqu__ProductRatePlan__c where zqu__ZuoraId__c IN : ratePlansMap.keySet() AND ExternalApplication__c != null];
        System.debug('productRatePlanItems########################: ' + productRatePlanItems);
        //sets if the quote needs to 'link' to an external app
         for(zqu__ProductRatePlan__c productRatePlanItem : [select ID, zqu__ZuoraId__c, ExternalApplication__c FROM zqu__ProductRatePlan__c where zqu__ZuoraId__c IN : ratePlansMap.keySet() AND ExternalApplication__c != null]) {
            
             
             if(ratePlansMap.containsKey(productRatePlanItem.zqu__ZuoraId__c)) {

                 subsMap.put(ratePlansMap.get(productRatePlanItem.zqu__ZuoraId__c), ratePlansMap.get(productRatePlanItem.ExternalApplication__c));
             }
        }
        
        for(zqu__Quote__c quoteItem : lstQuote) {
            System.debug('quoteItem.External_Application__c: ' +quoteItem.External_Application__c);
            
            if(subsMap.containsKey(quoteItem.zqu__Subscription_Name__c) && !quoteItem.zqu__Status__c.equals('Sent to Z-Billing') && !quoteItem.External_Application__c.Equals(Global_Constants.TETRIS)) {
                
                string output = subsMap.get(quoteItem.zqu__Subscription_Name__c);
                System.debug('output:::: ' +output);
                
                
                quoteItem.External_Application__c = subsMap.get(quoteItem.zqu__Subscription_Name__c);
                System.debug('subsMap.get(quoteItem.zqu__Subscription_Name__c): ' + subsMap.get(quoteItem.zqu__Subscription_Name__c));
                System.debug('quoteItem.External_Application__c: ' +quoteItem.External_Application__c);
                quoteItem.zqu__Subscription_Term_Type__c = 'Evergreen';
                String quoteOwnerID = quoteItem.OwnerId;
                System.debug('Im in');
                if(!quoteOwnerID.equals(Global_Constants.TETRIS_USER_ID)) {
                	quoteItem.SalesRepID__c = quoteOwnerID;
                    quoteItem.SalesChannel__c = Global_Constants.TETRIS_SALES_CHANNEL_DIRECT;
                }
            }
            System.debug('quoteItem.External_Application__c: ' + quoteItem.External_Application__c);
            System.debug('quoteItem.zqu__Subscription_Term_Type__c: ' +quoteItem.zqu__Subscription_Term_Type__c);
        }
        
        update lstsubprodCharge;
    }
    
    public static void AfterUpdate(List<zqu__Quote__c> lstQuoteNew, List<zqu__Quote__c> lstQuoteOld){
        
        System.debug('After Update');
		Set<ID> quoteIds = new Set<ID>();
        for(Integer i=0; i<lstQuoteNew.size(); i++){
           // quoteIds.add(lstQuoteNew[i].id);
            if(lstQuoteNew[i].zqu__ZuoraSubscriptionID__c != null && lstQuoteNew[i].zqu__Status__c == 'Sent to Z-Billing' && lstQuoteOld[i].zqu__Status__c == 'New' && lstQuoteNew[i].External_Application__c != null && lstQuoteNew[i].External_Application__c == Global_Constants.TETRIS  )
            {
                System.debug('Adding Quote to list');
                quoteIds.add(lstQuoteNew[i].id);
            }
        }
        /* @Rishu Garg Docmation (CC Decomm) */
        //if(quoteIds.size()>0) TetrisUtility.callSendQuoteToTetrisQueue(quoteIds);
    }
    
    
    public static void BeforeUpdate(List<zqu__Quote__c> lstQuoteNew) {

        Map<Id, String> quoteIdRecordTypeName = new Map<Id, String>();
        for (zqu__Quote__c quoteItem :lstQuoteNew) {
            zqu__Quote__c recordTypeName = [SELECT Id, RecordType.name FROM zqu__Quote__c where Id =: quoteItem.ID limit 1];
            quoteIdRecordTypeName.put(recordTypeName.Id, recordTypeName.RecordType.name);
        }

        for(zqu__Quote__c quoteItem : lstQuoteNew) {

            string recordTypeName = null;
            if(quoteIdRecordTypeName.containsKey(quoteItem.Id)) {
                recordTypeName = quoteIdRecordTypeName.get(quoteItem.Id);
            }

             if(quoteItem.External_Application__c != null && quoteItem.External_Application__c.equals(Global_Constants.TETRIS)) {
                    quoteItem.zqu__Subscription_Term_Type__c = 'Evergreen';
                    quoteItem.zqu__InvoiceProcessingOption__c = 'Account';

                     System.debug('quoteItemdetails: ' + quoteItem);
                     System.debug('templatesId##############: Not yet');

                 	List<zqu__Quote_Template__c> templatesId;

                 	if(!recordTypeName.isWhitespace() && recordTypeName.equals('Amendment')) {
                      templatesId = [SELECT ID from zqu__Quote_Template__c where CurrencyIsoCode =: quoteItem.CurrencyIsoCode and Name = 'en_GB Amendment'];
                 	}
                 	else {
                        templatesId = [SELECT ID from zqu__Quote_Template__c where CurrencyIsoCode =: quoteItem.CurrencyIsoCode and Name = 'en_GB New Subscription'];
                    }

                     //[SELECT ID from zqu__Quote_Template__c where CurrencyIsoCode =: quoteItem.CurrencyIsoCode and zqu__Quote_Type__c =: quoteItem.zqu__SubscriptionType__c and Name = 'en_GB New Subscription'];

                     System.debug('templatesId##############: ' +templatesId);

                     if(templatesId != null && templatesId.size() == 1) {
                         quoteItem.zqu__QuoteTemplate__c = templatesId[0].Id;
                     }
             }
        }
    }
}