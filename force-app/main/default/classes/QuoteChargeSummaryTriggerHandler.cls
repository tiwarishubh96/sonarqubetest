/**********************************************************************
Name:  QuoteChargeSummaryTriggerHandler

======================================================
======================================================
Purpose: 1. This trigger handler is used to update the product Name to the Translated product Name, Based on the Locale and the Original Product name
         
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR                 DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Veni/Cláudio/Mike     08/03/2018          EAD-415

*********************************************************************/

public class QuoteChargeSummaryTriggerHandler {
    
    public void updateProductTranslatedName(List<zqu__QuoteChargeSummary__c> newQuoteChargeSummary) {
        
        if(RecursiveTriggerHandler.isFirstTime){  
            System.debug('I am already there');
            RecursiveTriggerHandler.isFirstTime = false;
            
            Map <String, String> productLocaleMap = new Map <String,String> ();
            Set <ID> quoteIds = new Set <ID>();
            Set <ID> quoteRatePlanIds = new Set<ID>();
            List<zqu__QuoteChargeSummary__c> updateRemoveRateplanCharges = new  List<zqu__QuoteChargeSummary__c>(); 
            
            for(zqu__QuoteChargeSummary__c qcs: newQuoteChargeSummary)
            {
                quoteRatePlanIds.add(qcs.zqu__QuoteRatePlan__c);
                system.debug('QCS: '+qcs.zqu__QuoteRatePlan__c);
            }
//debug - tests
 /*           List<zqu__QuoteRatePlan__c> thelist = [SELECT ID, NAME, zqu__ProductRatePlan__r.ExternalApplication__c, zqu__Quote__c FROM zqu__QuoteRatePlan__c where id in :quoteRatePlanIds];
            System.debug('thelist: ' +thelist[0].zqu__Quote__c);


            Map<Id, zqu__Quote__c> productRatePlanIdsAndQuote = new Map<Id, zqu__Quote__c>();
            Set<ID> ids = new Set<ID>();
            for (zqu__QuoteRatePlan__c item : thelist) {
                System.debug('EXternal application: ' +item.zqu__ProductRatePlan__r.ExternalApplication__c);
                ids.add(item.zqu__ProductRatePlan__c);
                productRatePlanIdsAndQuote.put(item.zqu__ProductRatePlan__c, item.zqu__Quote__c);
            }*/


 /*           List<zqu__QuoteRatePlan__c> theIDSlist = [SELECT ID FROM zqu__QuoteRatePlan__c where id in :quoteRatePlanIds];

            List<zqu__ProductRatePlan__c> the2ndList = [SELECT ID, ExternalApplication__c, NAME from zqu__ProductRatePlan__c where id ='a0s1X000000OU4GQAW'];
            System.debug('the2ndList: ' +the2ndList);


            List<zqu__ProductRatePlan__c> the3ndList = [SELECT ID, ExternalApplication__c, NAME from zqu__ProductRatePlan__c where id in :ids];
            System.debug('the3ndList: ' +the3ndList);*/
//end debug -tests

            //Get the full list of the Naming mapping Object  "ZProductChargeNameMapping__c"
            List <ZProductChargeNameMapping__c> zProductName = [select TranslatedProductName__c,
                                                                Locale__r.name, ZProduct__r.name
                                                                from ZProductChargeNameMapping__c
                                                               ];
            
            // Unique Key for Original Value Locale+ProductName
            if(zProductName!=null &&zProductName.size() >0 )
            {
                for (ZProductChargeNameMapping__c zpcnm: zProductName) {
                    productLocaleMap.put(zpcnm.Locale__r.name + zpcnm.ZProduct__r.name, zpcnm.TranslatedProductName__c);
                }
            }
            
            //Get the Locale from the quotes and Product Name from QuoteRatePlan
            
            
            List<zqu__QuoteChargeSummary__c > quoteRateplanChargeSummaryRec = 
                [select id ,zqu__QuoteRatePlan__r.zqu__Quote__c,
                 zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Account__r.Locale__r.name,
                 zqu__QuoteRatePlan__r.zqu__QuoteProductName__c,
                 zqu__QuoteRatePlan__c,TranslatedProductName__c from zqu__QuoteChargeSummary__c
                 where zqu__QuoteRatePlan__c in: quoteRatePlanIds
                ];
            
            for(zqu__QuoteChargeSummary__c zqcs : quoteRateplanChargeSummaryRec)
            {
                quoteIds.add(zqcs.zqu__QuoteRatePlan__r.zqu__Quote__c);
                
            }
            
            //Get all the QuoteChargeSummary for the Quote and update Translated Product Name
            List<zqu__QuoteChargeSummary__c > quoteChargeSummaryRec = 
                [select id ,zqu__QuoteRatePlan__r.zqu__Quote__c,
                 zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Account__r.Locale__r.name,
                 zqu__QuoteRatePlan__r.zqu__QuoteProductName__c,
                 zqu__ChangeLog__c,
                 zqu__QuoteRatePlan__c,TranslatedProductName__c from zqu__QuoteChargeSummary__c
                 where zqu__QuoteRatePlan__r.zqu__Quote__c in: quoteIds
                ];
            
            System.debug('QuoteChargeSummary Size'+ quoteChargeSummaryRec.size());
            
            for(zqu__QuoteChargeSummary__c zqcs : quoteChargeSummaryRec)
            {
                System.debug('zqcs '+zqcs);
                String ProductLocaleName= zqcs.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Account__r.Locale__r.name+
                    zqcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c;
                zqcs.TranslatedProductName__c = productLocaleMap.get(ProductLocaleName)==null?
                    							zqcs.zqu__QuoteRatePlan__r.zqu__QuoteProductName__c:
                								productLocaleMap.get(ProductLocaleName);
                updateRemoveRateplanCharges.add(zqcs);  
                system.debug('zqcs.TranslatedProductName__c'+zqcs.TranslatedProductName__c);
                system.debug('zqcs.QuoteCharge'+zqcs.id);
                system.debug('zqcs.QUoteID'+zqcs.zqu__QuoteRatePlan__r.zqu__Quote__c);
                system.debug('zqcs.ChangeLog'+zqcs.zqu__ChangeLog__c);
            }
            
            if(updateRemoveRateplanCharges!=null&&updateRemoveRateplanCharges.size()>0)
            {
                update updateRemoveRateplanCharges;
            }


            //External application
            List<zqu__Quote__c> quotesList = [SELECT Id, External_Application__c, OwnerId, SalesRepID__c, SalesChannel__c FROM zqu__Quote__c WHERE Id IN :quoteIds];

            List<zqu__QuoteRatePlan__c> quoteRatePlanList = [SELECT ID, NAME, zqu__ProductRatePlan__r.ExternalApplication__c, zqu__Quote__c FROM zqu__QuoteRatePlan__c where id in :quoteRatePlanIds];
            System.debug('thelist: ' +quoteRatePlanList[0].zqu__Quote__c);

            Map<Id, zqu__Quote__c> productRatePlanIdsAndQuote = new Map<Id, zqu__Quote__c>();
            for (zqu__QuoteRatePlan__c item : quoteRatePlanList) {
                System.debug('EXternal application: ' +item.zqu__ProductRatePlan__r.ExternalApplication__c);
                for(zqu__Quote__c quote : quotesList) {
                    if(quote.Id.equals(item.zqu__Quote__c)) {
                        productRatePlanIdsAndQuote.put(item.zqu__ProductRatePlan__c, quote);
                    }
                }
            }
            Map<Id, zqu__Quote__c> quotesListToUpdate = setsExternalApplication(productRatePlanIdsAndQuote);
            if(!quotesListToUpdate.isEmpty()) {
                update quotesListToUpdate.values();
            }
        } 
        
    }
    private Map<Id, zqu__Quote__c> setsExternalApplication(Map<Id, zqu__Quote__c> productRatePlanIdsAndQuote) {

        Map<Id, zqu__Quote__c> quotesListToUpdate = new Map<Id, zqu__Quote__c>();
        system.debug('productRatePlanIdsAndQuote: ' +productRatePlanIdsAndQuote);
        List<zqu__ProductRatePlan__c> productRatePlanList = [SELECT Id, ExternalApplication__c from zqu__ProductRatePlan__c where Id IN: productRatePlanIdsAndQuote.keySet()];

        system.debug('productRatePlanList: ' +productRatePlanList);
        for (zqu__ProductRatePlan__c productRatePlanItem : productRatePlanList) {

            zqu__Quote__c zQuote = productRatePlanIdsAndQuote.get(productRatePlanItem.Id);
            zQuote.External_Application__c = productRatePlanItem.ExternalApplication__c;

            if (zQuote.External_Application__c != null && zQuote.External_Application__c.equals(Global_Constants.TETRIS)) {
                String quoteOwnerID = zQuote.OwnerId;
                if (!quoteOwnerID.equals(Global_Constants.TETRIS_USER_ID)) {
                    zQuote.SalesRepID__c = QuoteOwnerID;
                    zQuote.SalesChannel__c = Global_Constants.TETRIS_SALES_CHANNEL_DIRECT;
                }
                zQuote.zqu__Subscription_Term_Type__c = 'Evergreen';
                System.debug(' zQuote.zqu__Subscription_Term_Type__c: ' + zQuote.zqu__Subscription_Term_Type__c);
                quotesListToUpdate.put(zQuote.Id, zQuote);
            }
        }
        return quotesListToUpdate;
    }
}