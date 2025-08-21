/*-------------------------------------------------------------
Author:         Yue Lu
Date :          04/18/2018
Company:       
Description:    
Inputs:        None
History
<Date>            <Authors Name>                <Brief Description of Change>


------------------------------------------------------------*/

global class QuoteRatePlanChargeOnAdd implements zqu.SelectProductComponentOptions.IAddRemoveRatePlanPlugin{
    
    public void onAdd(String quoteId, List<String> addedRatePlans){
        
        if(addedRatePlans!=Null && !addedRatePlans.isempty()){
            
            try {
                system.debug('quoteId'+quoteId);
                
                system.debug('addedRatePlans'+addedRatePlans);
                
                Boolean needPartnerMargin = False;
                
                Set<String> setPeriod = new Set<String>();
                
                // Get recurring period from product rate plan charge
                List<zqu__ProductRatePlanCharge__c> lstPRPC = [SELECT Id, name, zqu__RecurringPeriod__c
                                                               FROM zqu__ProductRatePlanCharge__c
                                                               WHERE zqu__ProductRatePlan__c IN: addedRatePlans];                
                
                system.debug('lstPRPC::'+lstPRPC);
                // Get quote
                zqu__Quote__c zQuote = [SELECT Id, zqu__Opportunity__c, zqu__Opportunity__r.Type, zqu__Opportunity__r.Account.Type,
                                        zqu__Opportunity__r.Account.Partner_Agreement__c,zqu__Opportunity__r.Account.RecordType.Name,
                                        zqu__Opportunity__r.Account.Partner_Accountant__c,zqu__Opportunity__r.Account.Partner_Reseller__c,
                                        zqu__Opportunity__r.Account.Partner_Implementation__c,zqu__Opportunity__r.Account.Accountant_Partner_Tier__c,
                                        zqu__Opportunity__r.Account.Reseller_Partner_Tier__c,zqu__Opportunity__r.Account.SI_Partner_Tier__c,
                                        zqu__Opportunity__r.Account.Partner_Reseller_TnC__c,zqu__Opportunity__r.Account.Partner_Implementation_TnC__c,
                                        zqu__Opportunity__r.Account.Partner_Accountant_TnC__c,zqu__SubscriptionType__c,zqu__Opportunity__r.Account.Locale__r.Country_Code__c,
                                        External_Application__c, OwnerId, zqu__Subscription_Term_Type__c
                                        FROM zqu__Quote__c
                                        WHERE Id =: quoteId];
                
                system.debug('zQuote::'+zQuote);
                // Get quote rate plan charge
                List<zqu__QuoteRatePlanCharge__c> lstQRPC = [SELECT Name,Quote__c
                                                             FROM zqu__QuoteRatePlanCharge__c
                                                             WHERE Quote__c =:quoteId];
                system.debug('lstQRPC::'+lstQRPC);
                
                
                //sets the callout to external application if exists
                List<zqu__ProductRatePlan__c> lstPRP = [SELECT Id, ExternalApplication__c
                                                        FROM zqu__ProductRatePlan__c
                                                        WHERE ID IN: addedRatePlans and ExternalApplication__c != null];
                
                boolean isChanged = false;
                
                for(zqu__ProductRatePlan__c productRatePlan : lstPRP) {
                    zQuote.External_Application__c = productRatePlan.ExternalApplication__c;
                    
                    if(zQuote.External_Application__c.equals(Global_Constants.TETRIS)) {
                        String quoteOwnerID = zQuote.OwnerId;
                        if(!quoteOwnerID.equals(Global_Constants.TETRIS_USER_ID)) {
                            zQuote.SalesRepID__c = quoteOwnerID;
                            zQuote.SalesChannel__c = Global_Constants.TETRIS_SALES_CHANNEL_DIRECT;
                        }
                        zQuote.zqu__Subscription_Term_Type__c = 'Evergreen';
                        System.debug(' zQuote.zqu__Subscription_Term_Type__c: ' +  zQuote.zqu__Subscription_Term_Type__c);
                    }
                    
                    isChanged = true;
                }
                
                if(isChanged) {
                    update zQuote;
                }
                
                
                
                // Partner Type
                String partnerType;
                
                // Legal Agreement
                String partnerAgreement;
                
                // Partner Type Tiers
                String partnerTypeTier;
                
                //Discount for partner margin
                Decimal discountValue;
                
                //variable to control if discount is for financials
                boolean isFinancials = false;
                
                //variable to control if discount is for foundation
                boolean isFoundation = false;
                
                //variable to control if we need ISV margin
                boolean isISV = false;


                //Is tretris product?
                boolean isTetris = false;
                
                //count number of Partner margins that need to be added to the quote
                Integer countNbrPartnerMargins = 0;
                
                //Quote Rate Plans from Quote
                List<Id> quoteProductRatePlans=new List<ID>();
                
                //get margin discount values only for Partner account types
                if (zQuote.zqu__Opportunity__r.Account.Type == 'Partner' && zQuote.zqu__Opportunity__r.Account.RecordType.Name == 'Partner Account' ){
                    
                    system.debug('Patner accountant' +  zQuote.zqu__Opportunity__r.Account.Partner_Accountant__c);
                    //get partner type
                    partnerType= zQuote.zqu__Opportunity__r.Account.Partner_Reseller__c == true ? 'Reseller':
                    zQuote.zqu__Opportunity__r.Account.Partner_Implementation__c == true ? 'SI':
                    zQuote.zqu__Opportunity__r.Account.Partner_Accountant__c == true ? 'Accountant' : '';
                    
                    //get legal agreement acceptance
                    
                    partnerAgreement = zQuote.zqu__Opportunity__r.Account.Partner_Reseller_TnC__c == true ? 'Reseller':
                    zQuote.zqu__Opportunity__r.Account.Partner_Implementation_TnC__c == true ? 'SI':
                    zQuote.zqu__Opportunity__r.Account.Partner_Accountant_TnC__c == true ? 'Accountant' : '';
                    
                    //get partner tier based on partner type
                    //Partner_Accountant__c, Partner_Reseller__c,
                    partnerTypeTier = partnerType == 'Reseller' ? zQuote.zqu__Opportunity__r.Account.Reseller_Partner_Tier__c :
                    partnerType == 'SI'   ? zQuote.zqu__Opportunity__r.Account.SI_Partner_Tier__c :
                    partnerType == 'Accountant' ? zQuote.zqu__Opportunity__r.Account.Accountant_Partner_Tier__c  : '' ;
                    
                    //Partner Agreement and Partner Type need to be aligned
                    
                    if (partnerAgreement ==partnerType) {
                        
                        
                        //get partner margin configuration
                        List<PartnerMarginTierConfiguration__c> marginConfigs = [
                            SELECT id, Name,Contains_API_Key_Keywords__c, Not_Contains_API_Keywords__c,Authorized__c,Silver__c,Platinum__c,Suported_Locales__c
                            FROM PartnerMarginTierConfiguration__c
                            where Version__c = :zQuote.zqu__Opportunity__r.Account.Partner_Agreement__c and Partner_Type__c = :partnerType
                        ];
                        
                        
                        system.debug('Partner Agreement:' + zQuote.zqu__Opportunity__r.Account.Partner_Agreement__c);
                        system.debug('PArtner Type:' + partnerType);
                        system.debug('PArtner Type Tier:' + partnerTypeTier);
                        List<zqu__ProductRatePlan__c> addedProductRatePlans = [
                            SELECt Id,name,APIServiceId__c
                            FROM zqu__ProductRatePlan__c
                            WHERE Id IN:addedRatePlans
                        ];
                        
                        system.debug('marginConfigs::' + marginConfigs);
                        system.debug('addedProductRatePlans::' + addedProductRatePlans);
                        
                        
                        //get supported locales for generic usage
                        List<PartnerMarginGenericSuportedLocales__c> genericSuportedLocales = [
                            SELECT id, Suported_Locales__c
                            FROM PartnerMarginGenericSuportedLocales__c
                        ];
                        
                        for (zqu__ProductRatePlan__c addedProductRatePlan : addedProductRatePlans) {
                            for (PartnerMarginTierConfiguration__c marginConfig : marginConfigs) {
                                
                                String suportedLocalesSpecific = '';
                                
                                if (marginConfig.Suported_Locales__c == null)
                                    //I set this value to empty because if I set it to '' it could be true in the next if statement
                                    suportedLocalesSpecific = 'empty';
                                else
                                    suportedLocalesSpecific = marginConfig.Suported_Locales__c;
                                
                                String notContainsAPIKeywords;
                                if (marginConfig.Not_Contains_API_Keywords__c == null)
                                    //I set this value to empty because if I set it to '' it could be true in the next if statement
                                    notContainsAPIKeywords = 'empty';
                                else
                                    notContainsAPIKeywords = marginConfig.Not_Contains_API_Keywords__c;
                                
                                
                                system.debug('suportedLocales::' + suportedLocalesSpecific);
                                system.debug('zQuote.zqu__Opportunity__r.Account.Locale__r.Country_Code__c::' + zQuote.zqu__Opportunity__r.Account.Locale__r.Country_Code__c);
                                
                                if (addedProductRatePlan.APIServiceId__c.contains(marginConfig.Contains_API_Key_Keywords__c) && addedProductRatePlan.APIServiceId__c.contains(notContainsAPIKeywords) == false && suportedLocalesSpecific.contains(zQuote.zqu__Opportunity__r.Account.Locale__r.Country_Code__c)) {
                                    System.debug('Get discount for partner margin');
                                    
                                    if (marginConfig.Contains_API_Key_Keywords__c == 'foundation') {
                                        isFoundation = true;
                                        // countNbrPartnerMargins++;
                                    }
                                    if (marginConfig.Contains_API_Key_Keywords__c == 'sagelife') {
                                        isFinancials = true;
                                        // countNbrPartnerMargins++;
                                    }
                                    
                                    /*   if (PartnerTypeTier == 'Authorized') {
discountValue = marginConfig.Authorized__c;
}
else if (PartnerTypeTier == 'Silver'){
discountValue = marginConfig.Silver__c;
}
else if (PartnerTypeTier == 'Gold'){
discountValue = marginConfig.Gold__c;
}
else if (PartnerTypeTier == 'Platinum'){
discountValue = marginConfig.Platinum__c;
}*/
                                    needPartnerMargin = true;
                                    System.debug(discountValue);
                                }
                            }
                            
                            //Generic suported locales being used
                            
                            String suportedLocalesGeneric = '';
                            
                            if (genericSuportedLocales.size()>0)
                                if (String.isBlank(genericSuportedLocales[0].Suported_Locales__c ))
                                suportedLocalesGeneric = '';
                            else
                                suportedLocalesGeneric = genericSuportedLocales[0].Suported_Locales__c;
                            else
                                suportedLocalesGeneric = '';
                            
                            if (addedProductRatePlan.APIServiceId__c.contains('isv') && suportedLocalesGeneric.contains(zQuote.zqu__Opportunity__r.Account.Locale__r.Country_Code__c)) {
                                isISV = true;
                                needPartnerMargin = true;
                                //countNbrPartnerMargins++;
                            }
                        }
                        
                        
                        System.debug('Before verify margin ------>>><<<<<');
                        //Verify if partner margin already exists in quote
                        
                        List<zqu__QuoteRatePlan__c> lstQRP = [
                            SELECT Name,zqu__Quote__c,zqu__ProductRatePlan__c
                            FROM zqu__QuoteRatePlan__c
                            WHERE zqu__Quote__c = :quoteId
                        ];
                        
                        System.debug(lstQRP);
                        
                        
                        for (zqu__QuoteRatePlan__c qRP : lstQRP) {
                            quoteProductRatePlans.add(qRP.zqu__ProductRatePlan__c);
                        }
                        
                        if (zQuote.zqu__SubscriptionType__c == 'Amend Subscription') {
                            
                            List<zqu.zChargeGroup> zcgAmendments = zqu.zQuoteUtil.getChargeGroups(quoteId);
                            
                            System.debug('Amendment ???' + zcgAmendments);
                            
                            for (zqu.zChargeGroup zcgAmendment : zcgAmendments) {
                                
                                quoteProductRatePlans.add(zcgAmendment.productRatePlanId);
                            }
                        }
                        
                        System.debug('Before get zqu__ProductRatePlan__c ------>>><<<<<: ' +quoteProductRatePlans);
                        List<zqu__ProductRatePlan__c> addedProductQRP = [
                            SELECt Id,name,APIServiceId__c, ExternalApplication__c
                            FROM zqu__ProductRatePlan__c
                            WHERE Id IN:quoteProductRatePlans
                        ];
                        
                        
                        boolean hasPartnerMarginFinancials;
                        boolean hasPartnerMarginFoundation;
                        boolean hasPartnerMarginISV;
                        
                        
                        System.debug('Before look at APISERVICEID ------>>><<<<<' + addedProductQRP);
                        for (zqu__ProductRatePlan__c aPRP : addedProductQRP) {
                            if (aPRP.APIServiceId__c.contains('sage:partner:margin:isv')) {
                                hasPartnerMarginISV = true;
                            }
                            
                            else if (aPRP.APIServiceId__c.contains('sage:partner:margin:foundation')) {
                                hasPartnerMarginFoundation = true;
                            }
                            
                            else if (aPRP.APIServiceId__c.contains('sage:partner:margin')) {
                                hasPartnerMarginFinancials = true;
                            }

                            if(aPRP.ExternalApplication__c.equals(Global_Constants.TETRIS)) {
                                isTetris = true;
                            }
                        }
                        
                        
                        System.debug('How many margins are needed? ------>>><<<<<' + countNbrPartnerMargins);
                        
                        /*  if (needPartnerMargin == true && isFinancials == true  && hasPartnerMarginFinancials == true){
countNbrPartnerMargins--;
}

if (needPartnerMargin == true && isFoundation == true  && hasPartnerMarginFoundation == true){
countNbrPartnerMargins--;
}

if (needPartnerMargin == true && isISV == true  && hasPartnerMarginISV == true){
countNbrPartnerMargins--;
}

System.debug('How many margins are needed after validate partner margin needs? ------>>><<<<<' + countNbrPartnerMargins);


if (countNbrPartnerMargins==0)
needPartnerMargin = false;*/
                        
                        
                        //we only add partner margin when opportunity type is resell business
                        //this was before Jira ticket EAD-817 was implemented
                        /* needPartnerMargin = zQuote.zqu__Opportunity__r.Type !='Resell Business'? False:
zQuote.zqu__Opportunity__r.Account.Type != 'Partner'? False:
zQuote.zqu__Opportunity__r.Account.Partner_Agreement__c != 'V3'? False:True;
*/
                        
                        
                        System.debug('countNbrPartnerMargins::::::' + countNbrPartnerMargins);
                        System.debug('Need Partner Margin:' + needPartnerMargin);
                        
                        if (needPartnerMargin) {
                            
                            // Get recurring period
                            if (!lstprpc.isEmpty()) {
                                
                                for (zqu__ProductRatePlanCharge__c prpc : lstPRPC) {
                                    
                                    setPeriod.add(prpc.zqu__RecurringPeriod__c);
                                }
                            }
                            
                            
                            List<String> sPeriod = new List<String>();
                            String sPeriodAux;
                            
                            for (Integer i = 0; i < setPeriod.size(); i++) {
                                if (isFinancials) {
                                    sPeriodAux = 'sage:partner:margin:' + new List<String>(setPeriod)[i];
                                    sPeriodAux = sPeriodAux == 'sage:partner:margin:Month' ? 'sage:partner:margin:monthly' : sPeriodAux;
                                    sPeriod.add(sPeriodAux);
                                }
                                
                                if (isFoundation) {
                                    sPeriodAux = 'sage:partner:margin:foundation:' + new List<String>(setPeriod)[i];
                                    sPeriodAux = sPeriodAux == 'sage:partner:margin:foundation:Month' ? 'sage:partner:margin:foundation:monthly' : sPeriodAux;
                                    sPeriod.add(sPeriodAux);
                                }
                                
                                if (isISV) {
                                    sPeriodAux = 'sage:partner:margin:isv:' + new List<String>(setPeriod)[i];
                                    sPeriodAux = sPeriodAux == 'sage:partner:margin:isv:Month' ? 'sage:partner:margin:isv:monthly' : sPeriodAux;
                                    sPeriod.add(sPeriodAux);
                                    
                                }
                            }
                            // String sPeriod = isFoundation == true ? 'sage:partner:margin:foundation:'+ new List<String>(setPeriod)[0] : 'sage:partner:margin:'+ new List<String>(setPeriod)[0];
                            
                            System.debug('sPeriod::' + sPeriod);
                            
                            /* sPeriod = sPeriod == 'sage:partner:margin:Month'? 'sage:partner:margin:monthly': sPeriod;
sPeriod = sPeriod == 'sage:partner:margin:foundation:Month'? 'sage:partner:foundation:margin:monthly': sPeriod;*/
                            
                            // system.debug('sPeriod>>>'+sPeriod);
                            
                            List<zqu__ProductRatePlan__c> productRatePlanFromQuote = [
                                SELECt Id,name
                                FROM zqu__ProductRatePlan__c
                                WHERE APIServiceId__c = :sPeriod
                                AND zqu__Deleted__c = False
                                AND zqu__EffectiveEndDate__c >= Today
                                AND ID not in:quoteProductRatePlans
                            ];
                            
                            System.debug('productRatePlanFromQuote::' + productRatePlanFromQuote);
                            
                            /* if (countNbrPartnerMargins==1) {


zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup((ID) quoteId, (ID) productRatePlanFromQuote[0].Id);

System.debug('zcg::'+ zcg);

if (!Test.isRunningTest()) {

zqu.zQuoteUtil.addChargeGroup(zcg);
}
}
else if (countNbrPartnerMargins>1){*/
                            
                            If (productRatePlanFromQuote.size() > 0) {
                                List<zqu.zChargeGroup> zcgs = new List<zqu.zChargeGroup>();
                                
                                for (zqu__ProductRatePlan__c prp1 : productRatePlanFromQuote) {
                                    zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup((ID) quoteId, (ID) prp1.Id);
                                    zcgs.add(zcg);
                                }
                                
                                System.debug('zcgs::' + zcgs);
                                
                                zqu.zQuoteUtil.addChargeGroups(zcgs);
                            }
                            
                            // }
                        }
                    }
                    
                    
                }
                if(isTetris) {
                    boolean toUpdate = setsExternalApplication(lstPRP, zQuote);
                    if(toUpdate) {
                        update zQuote;
                    }
                }
                
            } catch(Exception ex) {
                System.debug('error in QuoteRatePlanChargeOnAdd: ' + ex.getStackTraceString());
                System.debug('Exception message:'+ex.getMessage());
                ex.getStackTraceString();
                throw new AddRemoveException(ex.getStackTraceString()+':'+ex.getMessage());
            }
            
        }
        
        
    }
    
    public void onRemove(String quoteId, List<String> removedRatePlans){
        
    }
    public class AddRemoveException extends Exception {}

    private boolean setsExternalApplication(List<zqu__ProductRatePlan__c> lstPRP, zqu__Quote__c zQuote) {
        boolean changed = false;
        for (zqu__ProductRatePlan__c productRatePlan : lstPRP) {
            zQuote.External_Application__c = productRatePlan.ExternalApplication__c;

            if (zQuote.External_Application__c != null && zQuote.External_Application__c.equals(Global_Constants.TETRIS)) {
                String quoteOwnerID = zQuote.OwnerId;
                if (!quoteOwnerID.equals(Global_Constants.TETRIS_USER_ID)) {
                    zQuote.SalesRepID__c = QuoteOwnerID;
                    zQuote.SalesChannel__c = Global_Constants.TETRIS_SALES_CHANNEL_DIRECT;
                }
                zQuote.zqu__Subscription_Term_Type__c = 'Evergreen';
                System.debug(' zQuote.zqu__Subscription_Term_Type__c: ' + zQuote.zqu__Subscription_Term_Type__c);
                changed = true;
            }
        }
        return changed;
    }
}