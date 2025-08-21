/**********************************************************************
Name:  QuoteRatePlanChargeOnSavePlugin

======================================================
======================================================
Purpose: 1. This plugin is used to update the product Name to the Translated product Name, Based on the Locale and the Original Product name
         
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR                 DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Veni/Cláudio/Mike     08/03/2018          EAD-415

*********************************************************************/
global class QuoteRatePlanChargeOnSavePlugin implements zqu.SelectProductComponentOptions.ISaveRatePlanPlugin {


    public void onSave(List <zqu.zChargeGroup> addedChargeGroups, List <zqu.zChargeGroup> updatedChargeGroups,
                       List <zqu.zChargeGroup> removedChargeGroups, List <zqu.zChargeGroup> persistedChargeGroups) {

        //UpdateChargeGroup Methods is not available on grouptype  1,3,6,7,10

        Map<Integer, Integer> mapexculdeGrpTypes = new Map<Integer, Integer>{
                1 => 1, 3 => 3, 6 => 6, 7 => 7, 10 => 10
        };

        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();

        Map<Id, zqu__Quote__c> productRatePlanIdsAndQuote = new Map<Id, zqu__Quote__c>();
        List<zqu__Quote__c> quotesListToUpdate = new List<zqu__Quote__c>();

        //https://knowledgecenter.zuora.com/CA_Commerce/I_Development_Resources/C_Component_Library/C_Global_Classes/J_GlobalCustomFieldDefinition_Class
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set <String>{
                'TranslatedProductName__c'
        };

        system.debug('zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS' + zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS);

        if (addedChargeGroups != null && addedChargeGroups.size() > 0) {
            chargeGroups.addALL(addedChargeGroups);
        }
        if (updatedChargeGroups != null && updatedChargeGroups.size() > 0) {
            chargeGroups.addALL(updatedChargeGroups);
        }

        if (persistedChargeGroups != null && persistedChargeGroups.size() > 0) {
            chargeGroups.addALL(persistedChargeGroups);
        }

        system.debug('chargeGroups::' + chargeGroups);

        Map <String, String> productLocaleMap = new Map <String, String> ();

        Set <ID> quoteIds = new Set <ID>();

        //Get the full list of the Naming mapping Object  "ZProductChargeNameMapping__c"
        List <ZProductChargeNameMapping__c> zProductName = [
                select TranslatedProductName__c,
                        Locale__r.name, ZProduct__r.name
                from ZProductChargeNameMapping__c
        ];

        for (zqu.zChargeGroup zcg : chargeGroups) {

            system.debug('zcg.quote.id::' + zcg.quote.id);

            system.debug('zcg.quote.id::' + zcg);

            //Adds the produst rate plan Ids so we can get them all and set the External application if existing
            //productRatePlanIdsList.add(zcg.productRatePlanId);

            productRatePlanIdsAndQuote.put(zcg.productRatePlanId, zcg.quote);

            quoteIds.add(zcg.quote.id);
            quotesListToUpdate.add(zcg.quote);
        }

        system.debug('productRatePlanIdsAndQuote: ' +productRatePlanIdsAndQuote);
        //set is External Application
        quotesListToUpdate = setsExternalApplication(productRatePlanIdsAndQuote);


        List<ID> listQuoteIds = new List<ID>(quoteIds);

        // Unique Key for Original Value Locale+ProductName
        if (zProductName != null && zProductName.size() > 0) {
            for (ZProductChargeNameMapping__c zpcnm : zProductName) {
                productLocaleMap.put(zpcnm.Locale__r.name + zpcnm.ZProduct__r.name, zpcnm.TranslatedProductName__c);
            }
        }

        //Get the Locales base on the quotes ID's
        Map < ID, zqu__Quote__c > quoteLocale = new Map < ID, zqu__Quote__c > (
        [
                select id, zqu__Account__r.Locale__r.name,zqu__SubscriptionType__c,zqu__Opportunity__r.Type
                        ,zqu__Opportunity__r.Account.RecordType.Name
                from zqu__Quote__c
                where id in:quoteIds
        ]);


        for (zqu.zChargeGroup zcg : chargeGroups) {

            for (zqu.zCharge zc : zcg.zCharges) {
                //WE NEED TO GET THE TRANSLATED NAME
                zqu__Quote__c quote = quoteLocale.get(zcg.quote.id);
                String productLocale = quote.zqu__Account__r.Locale__r.name + zcg.productName;

                //the chargeObject can be one of two objects: zqu__QuoteRatePlanCharge__c OR zqu__QuoteCharge__c
                Boolean isQuoteRatePlanChargeObj = zc.chargeObject instanceof zqu__QuoteRatePlanCharge__c;

                if (!isQuoteRatePlanChargeObj) {
                    productLocale = quoteLocale.get(zcg.quote.id).zqu__Account__r.Locale__r.name + zc.chargeObject.get('TranslationZuoraProductName__c');
                }

                System.debug('productLocale:  ' + productLocale);

                if (String.isBlank(productLocaleMap.get(productLocale))) {
                    if (!isQuoteRatePlanChargeObj) {
                        zc.chargeObject.put('TranslatedProductName__c', zc.chargeObject.get('TranslationZuoraProductName__c'));
                    } else {
                        zc.chargeObject.put('TranslatedProductName__c', zcg.productName);
                        System.debug('zcg.productName: ' + zcg.productName);
                    }
                } else {
                    zc.chargeObject.put('TranslatedProductName__c', productLocaleMap.get(productLocale));
                }

            }

            System.debug('zcg.grouptype: ' + zcg.grouptype);

            //grouptype : The life cycle value of the charge group.
            if (!mapexculdeGrpTypes.containsKey(zcg.grouptype)) {
                System.debug('zcg::: ' + zcg);
                zqu.zQuoteUtil.updateChargeGroup(zcg);//update the given charge group.
            }

        }

        if(!quotesListToUpdate.isEmpty()) {
            update quotesListToUpdate;
        }
    }


    private List<zqu__Quote__c> setsExternalApplication(Map<Id, zqu__Quote__c> productRatePlanIdsAndQuote) {

        List<zqu__Quote__c> quotesListToUpdate = new List<zqu__Quote__c>();

        List<zqu__ProductRatePlan__c> productRatePlanList = [SELECT Id, ExternalApplication__c from zqu__ProductRatePlan__c where Id IN: productRatePlanIdsAndQuote.keySet()];

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
                quotesListToUpdate.add(zQuote);
            }
        }
        return quotesListToUpdate;
    }



}