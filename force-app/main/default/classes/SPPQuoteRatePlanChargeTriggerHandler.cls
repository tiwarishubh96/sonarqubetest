/**
* Created by taa on 08/02/2019.
*/
/**
@author 	Tiago Almeida
@date 	08-Fev-2019
@description 	trigger for Quote Rate Plan Charge object. There should only be one trigger per object.
Initially this trigger handler was implemented to calculate partner margin
@Jira Number EAD-817
*/

public without sharing class SPPQuoteRatePlanChargeTriggerHandler  implements TriggerHandlerInterface{
    
    public  class QuoteRatePlanHelper {
        //Quote ID
        public ID quoteID;
        //Quote Rate Plan ID
        public ID quoteRatePlanID;
        //Product Rate Plan
        public ID productRatePlanID;
        //Partner Margin
        public Decimal partnerMargin;
        //Partner Tier
        public String partnerTier;
        //End Customer Name when it's a Partner Resell
        public String endCustomerName;
        
    }
    
    public class QuoteHelper {
        // Partner Type Tiers
        public String partnerTypeTier;
        //Quote ID
        public ID quoteID;
        //Partner Agreement (Version)
        public String partnerAgreement;
        // Partner Type
        public String partnerType;
        //List of Produtct Rate Plans for Financials
        public List<ID> quoteRatePlanFinancials;
        //List of Produtct Rate Plans for Foundation
        public List<ID> quoteRatePlanFoundation;
        //List of Produtct Rate Plans for ISV
        public List<ID> quoteRatePlanISV;
        //Discount for partner margin Financials
        public Decimal discountValueFinancials;
        //End Customer Name when it's a Partner Resell
        public String endCustomerName;
        //Discount for partner margin Foundation
        public Decimal discountValueFoundation;
        
        //Account Locale
        public String locale;
    }
    
    public void BeforeInsert(List<SObject> newItems){
        
        System.debug('BeforeInsert');
        
        
        List<QuoteHelper> quotesInfo = new List<QuoteHelper>();
        
        
        List<Id> quoteIds = new List<ID>();
        
        
        System.debug('New Items:::: ' +newItems);
        
        for(zqu__QuoteRatePlanCharge__c objRatePlan : (List<zqu__QuoteRatePlanCharge__c>) newItems){
            
            System.debug('Quote:::' + objRatePlan.quote__c);
            
            if (!quoteIds.Contains(objRatePlan.quote__c)){
                quoteIds.add(objRatePlan.quote__c);
            }
        }
        
        
        try {
            
            system.debug('Here I am on before insert quoterateplancharge!');
            
            if (Trigger.new.size()>0){
                
                
                QuoteHelper quoteInfo = new QuoteHelper();
                
                
                // Partner Type
                String partnerType;
                
                // Legal Agreement
                String partnerLegalAgreement;
                
                // Partner Type Tiers
                String partnerTypeTier;
                
                //Discount for partner margin Financials
                Decimal discountValueFinancials;
                
                //Discount for partner margin Foundation
                Decimal discountValueFoundation;
                
                //Discount Aux
                Decimal discountValue;
                
                //get discount value
                List<zqu__Quote__c> zQuotes = [SELECT Id, zqu__Opportunity__c, zqu__Opportunity__r.Type, zqu__Opportunity__r.Account.Type,
                                               zqu__Opportunity__r.Account.Partner_Agreement__c,zqu__Opportunity__r.Account.RecordType.Name,
                                               zqu__Opportunity__r.Account.Partner_Accountant__c,zqu__Opportunity__r.Account.Partner_Reseller__c,
                                               zqu__Opportunity__r.Account.Partner_Implementation__c,zqu__Opportunity__r.Account.Accountant_Partner_Tier__c,
                                               zqu__Opportunity__r.Account.Reseller_Partner_Tier__c,zqu__Opportunity__r.Account.SI_Partner_Tier__c,
                                               zqu__Opportunity__r.Account.Partner_Reseller_TnC__c,zqu__Opportunity__r.Account.Partner_Implementation_TnC__c,
                                               zqu__Opportunity__r.Account.Partner_Accountant_TnC__c,zqu__Opportunity__r.Account.Locale__r.Country_Code__c,
                                               zqu__Opportunity__r.End_Customers_Account__r.Name
                                               FROM zqu__Quote__c
                                               WHERE Id IN: quoteIds];
                
                System.debug('All Quotes::: ' + zQuotes);
                
                
                for (zqu__Quote__c zQuote : zQuotes) {
                    //get margin discount values only for Partner account types
                    if (zQuote.zqu__Opportunity__r.Account.Type == 'Partner' && zQuote.zqu__Opportunity__r.Account.RecordType.Name == 'Partner Account') {
                        system.debug('Patner accountant:::' + zQuote.zqu__Opportunity__r.Account.Partner_Accountant__c);
                        //get partner type
                        partnerType = zQuote.zqu__Opportunity__r.Account.Partner_Reseller__c == true ? 'Reseller' :
                        zQuote.zqu__Opportunity__r.Account.Partner_Implementation__c == true ? 'SI' :
                        zQuote.zqu__Opportunity__r.Account.Partner_Accountant__c == true ? 'Accountant' : '';
                        
                        //get legal agreement acceptance
                        
                        partnerLegalAgreement = zQuote.zqu__Opportunity__r.Account.Partner_Reseller_TnC__c == true ? 'Reseller' :
                        zQuote.zqu__Opportunity__r.Account.Partner_Implementation_TnC__c == true ? 'SI' :
                        zQuote.zqu__Opportunity__r.Account.Partner_Accountant_TnC__c == true ? 'Accountant' : '';
                        
                        //get partner tier based on partner type
                        //Partner_Accountant__c, Partner_Reseller__c,
                        partnerTypeTier = partnerType == 'Reseller' ? zQuote.zqu__Opportunity__r.Account.Reseller_Partner_Tier__c :
                        partnerType == 'SI' ? zQuote.zqu__Opportunity__r.Account.SI_Partner_Tier__c :
                        partnerType == 'Accountant' ? zQuote.zqu__Opportunity__r.Account.Accountant_Partner_Tier__c : '' ;
                        
                        //Partner Agreement and Partner Type need to be aligned
                        
                        if (partnerLegalAgreement == partnerType) {
                            
                            quoteInfo.partnerTypeTier = partnerTypeTier;
                            quoteInfo.quoteID = zQuote.Id;
                            quoteInfo.partnerAgreement =  zQuote.zqu__Opportunity__r.Account.Partner_Agreement__c;
                            quoteInfo.partnerType = PartnerType;
                            quoteInfo.quoteRatePlanFinancials = new List<ID>();
                            quoteInfo.locale = zQuote.zqu__Opportunity__r.Account.Locale__r.Country_Code__c;
                            quoteInfo.endCustomerName = zQuote.zqu__Opportunity__r.End_Customers_Account__r.Name;
                            quotesInfo.add(QuoteInfo);
                            
                            //get partner margin configuration
                            
                            //Show alert message if partner agreement is not set?
                            
                            // system.debug('Partner Agreement:' + zQuote.zqu__Opportunity__r.Account.Partner_Agreement__c);
                            // system.debug('PArtner Type:' + PartnerType);
                            //  system.debug('PArtner Type Tier:' + PartnerTypeTier);
                            
                        }
                    }
                }
                
                System.debug('Quotes Info--------'+quotesInfo);
                if (quotesInfo.size()>0) {
                    List<PartnerMarginTierConfiguration__c> marginConfigs = [
                        SELECT id, Name,Contains_API_Key_Keywords__c, Not_Contains_API_Keywords__c,Authorized__c,Silver__c,Gold__c,Platinum__c,Version__c,Partner_Type__c,Suported_Locales__c
                        FROM PartnerMarginTierConfiguration__c
                    ];
                    
                    //variable to control if discount is for financials
                    boolean isFinancials = false;
                    
                    //variable to control if discount is for foundation
                    boolean isFoundation = false;
                    
                    //variable to control if we need ISV margin
                    boolean isISV = false;
                    
                    System.debug('Margin Config Info--------' + marginConfigs);
                    
                    List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT Id,Name, zqu__Quote__c, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c IN :quoteIds];
                    
                    System.debug(' QuoteRatePlans --------' + quoteRatePlans);
                    
                    List <QuoteRatePlanHelper> quoteRatePlansInfo = new List<QuoteRatePlanHelper>();
                    
                    Set<ID> setProductRatePlanID = new Set<ID>();
                    
                    List<ID> quoteRatePlanFinancials;
                    List<ID> quoteRatePlanFoundation;
                    List<ID> quoteRatePlanISV;
                    for (zqu__QuoteRatePlan__c quoteRatePlan : quoteRatePlans) {
                        
                        QuoteRatePlanHelper quoteRatePlanInfo = new QuoteRatePlanHelper();
                        
                        System.debug('QuoteRatePlan--------' + quoteRatePlan);
                        quoteRatePlanInfo.quoteID = quoteRatePlan.zqu__Quote__c;
                        quoteRatePlanInfo.productRatePlanID = quoteRatePlan.zqu__ProductRatePlan__c;
                        quoteRatePlanInfo.quoteRatePlanID = quoteRatePlan.Id;
                        setProductRatePlanID.add(quoteRatePlan.zqu__ProductRatePlan__c);
                        quoteRatePlansInfo.add(quoteRatePlanInfo);
                        
                    }
                    
                    System.debug('QuoteRatePlansInfo--------' + quoteRatePlansInfo);
                    System.debug('setProductRatePlanID----------' + setProductRatePlanID);
                    
                    List<zqu__ProductRatePlan__c> productRatePlans = [SELECT Id,name,APIServiceId__c
                                                                      FROM zqu__ProductRatePlan__c
                                                                      WHERE Id IN:setProductRatePlanID];
                    
                    
                    System.debug('ProductRatePlans----------' + productRatePlans);
                    
                    for (Integer i = 0; i < quotesInfo.size(); i++) {
                        
                        quoteRatePlanFinancials = new List<ID>();
                        quoteRatePlanFoundation = new List<ID>();
                        quoteRatePlanISV = new List<ID>();
                        
                        for (integer j = 0; j < quoteRatePlansInfo.size(); j++) {
                            
                            if (quotesInfo[i].QuoteID == quoteRatePlansInfo[j].QuoteID) {
                                System.debug('equal Quote id' + quotesInfo[i].QuoteID);
                                
                                for (zqu__ProductRatePlan__c addedProductRatePlan : ProductRatePlans) {
                                    
                                    // System.debug('addedProductRatePlan------>' + addedProductRatePlan);
                                    // System.debug('QuoteRatePlansInfo[j].ProductRatePlanID---->' + QuoteRatePlansInfo[j].ProductRatePlanID);
  
                                    if (quoteRatePlansInfo[j].productRatePlanID == addedProductRatePlan.Id) {
                                        System.debug('equal product rate plan id' + quoteRatePlansInfo[j].productRatePlanID);
                                        
                                        if (addedProductRatePlan.APIServiceId__c.contains('partner:margin:foundation')) {
                                            quoteRatePlanFoundation.Add(quoteRatePlansInfo[j].quoteRatePlanID);
                                        } else if (addedProductRatePlan.APIServiceId__c.contains('partner:margin:isv')) {
                                            quoteRatePlanISV.add( quoteRatePlansInfo[j].quoteRatePlanID);
                                        } else if (addedProductRatePlan.APIServiceId__c.contains('partner:margin')) {
                                            quoteRatePlanFinancials.add( quoteRatePlansInfo[j].quoteRatePlanID);
                                        }
                                        
                                        discountValue = 0;
                                        for (PartnerMarginTierConfiguration__c marginConfig : marginConfigs) {
                                            String suportedLocales = '';
                                            
                                            if (marginConfig.Suported_Locales__c == null)
                                                suportedLocales = 'empty';
                                            else
                                                suportedLocales = marginConfig.Suported_Locales__c;
                                            
                                            if (marginConfig.Version__c == quotesInfo[i].partnerAgreement && marginConfig.Partner_Type__c ==  quotesInfo[i].partnerType && suportedLocales.contains(quotesInfo[i].locale)){
                                                String notContainsAPIKeywords;
                                                if (marginConfig.Not_Contains_API_Keywords__c == null)
                                                    notContainsAPIKeywords = 'empty';
                                                else
                                                    notContainsAPIKeywords = marginConfig.Not_Contains_API_Keywords__c;
                                                
                                                System.debug('addedProductRatePlan.APIServiceId__c.contains(marginConfig.Contains_API_Key_Keywords__c)::: ' +addedProductRatePlan.APIServiceId__c.contains(marginConfig.Contains_API_Key_Keywords__c));
                                                System.debug('addedProductRatePlan.APIServiceId__c.contains(notContainsAPIKeywords)::: ' +addedProductRatePlan.APIServiceId__c.contains(notContainsAPIKeywords));
                                                if (addedProductRatePlan.APIServiceId__c.contains(marginConfig.Contains_API_Key_Keywords__c) && addedProductRatePlan.APIServiceId__c.contains(notContainsAPIKeywords) == false) {
                                                    System.debug('Get discount for partner margin:::');
                                                    
                                                    if (quotesInfo[i].partnerTypeTier == 'Authorized') {
                                                        discountValue = marginConfig.Authorized__c;
                                                    } else if (quotesInfo[i].partnerTypeTier == 'Silver') {
                                                        discountValue = marginConfig.Silver__c;
                                                    } else if (quotesInfo[i].partnerTypeTier == 'Gold') {
                                                        system.debug('GOLD:::: ' + marginConfig.Gold__c);
                                                        discountValue = marginConfig.Gold__c;
                                                    } else if (quotesInfo[i].partnerTypeTier == 'Platinum') {
                                                        discountValue = marginConfig.Platinum__c;
                                                    }
                                                    
                                                    
                                                    if (marginConfig.Contains_API_Key_Keywords__c == 'foundation') {
                                                        isFoundation = true;
                                                        discountValueFoundation = discountValue;
                                                        System.debug('Discount Foundation to be applied::::' + discountValueFoundation);
                                                    }
                                                    if (marginConfig.Contains_API_Key_Keywords__c == 'sagelife') {
                                                        isFinancials = true;
                                                        discountValueFinancials = discountValue;
                                                        System.debug('Discount Financials to be applied::::' + discountValueFinancials);
                                                    }
                                                    //fill array with discount and to which partner margin
                                                    System.debug('Discount to be applied::::' +discountValue);
                                                }
                                                
                                            }
                                        }
                                        
                                        quoteRatePlansInfo[j].partnerMargin = discountValue;
                                        quoteRatePlansInfo[j].partnerTier = quotesInfo[i].partnerTypeTier;
                                        quoteRatePlansInfo[j].endCustomerName = quotesInfo[i].endCustomerName;
                                    }
                                }
                            }
                        }
                        
                        quotesInfo[i].quoteRatePlanFinancials = quoteRatePlanFinancials;
                        quotesInfo[i].quoteRatePlanFoundation = quoteRatePlanFoundation;
                        quotesInfo[i].quoteRatePlanISV = quoteRatePlanISV;
                        quotesInfo[i].discountValueFinancials = discountValueFinancials;
                        quotesInfo[i].discountValueFoundation = discountValueFoundation;
                        System.debug('#### endCustomerName:: ' +quotesInfo[i].endCustomerName);
                    }
                    
                    
                    
                    System.debug('Discount Final Foundation to be applied::::' + String.valueOf(discountValueFoundation) + 'Quote RatePlan '+ quoteRatePlanFoundation);
                    System.debug('Discount Final Financials to be applied::::' + String.valueOf(discountValueFinancials) + 'Quote RatePlan ' + quoteRatePlanFinancials);
                    List<ID> quoteRatePlansIDStoUpdate = new List<ID>();
                    
                    for (Integer i = 0; i < quotesInfo.size(); i++) {
                        quoteRatePlansIDStoUpdate.addAll(quotesInfo[i].quoteRatePlanFinancials);
                        quoteRatePlansIDStoUpdate.addAll(quotesInfo[i].quoteRatePlanFoundation);
                        quoteRatePlansIDStoUpdate.addAll(quotesInfo[i].quoteRatePlanISV);
                    }
                    
                    System.debug('QuoteRatePlansIDStoUpdate:::::'+quoteRatePlansIDStoUpdate);
                    
                    List<zqu__QuoteRatePlanCharge__c> quoteRatePlanstoUpdate = [SELECT Id,Name,zqu__EffectivePrice__c,zqu__QuoteRatePlan__c,Total_Margin__c,Partner_Tier__c,zqu__DiscountPercentage__c,Quote__c,zqu__Discount__c, zqu__Description__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__c IN: quoteRatePlansIDStoUpdate];
                    
                    System.debug('QuoteRatePlanstoUpdate::::::'+quoteRatePlanstoUpdate);
                    
                    for( zqu__QuoteRatePlanCharge__c quoteRatePlanCharge : quoteRatePlanstoUpdate){
                        for (Integer i = 0; i < quotesInfo.size(); i++) {
                            if(String.isNotBlank(quoteRatePlanCharge.zqu__Description__c)) {
                                quoteRatePlanCharge.zqu__Description__c = quotesInfo[i].endCustomerName;
                            }
                            if (quotesInfo[i].quoteID == quoteRatePlanCharge.Quote__c){
                                for (Integer j = 0; j < quotesInfo[i].quoteRatePlanFinancials.size(); j++) {
                                    if (quotesInfo[i].quoteRatePlanFinancials[j] == quoteRatePlanCharge.zqu__QuoteRatePlan__c && quoteRatePlanCharge.zqu__EffectivePrice__c ==0){
                                        system.debug('####QuoteRatePlanCharge Partner Margin Financials::::' + quoteRatePlanCharge);
                                        quoteRatePlanCharge.zqu__EffectivePrice__c = quotesInfo[i].discountValueFinancials;
                                        quoteRatePlanCharge.zqu__DiscountPercentage__c = quotesInfo[i].discountValueFinancials;
                                        quoteRatePlanCharge.Total_Margin__c = quotesInfo[i].discountValueFinancials;
                                        quoteRatePlanCharge.Partner_Tier__c = quotesInfo[i].PartnerTypeTier;
                                        quoteRatePlanCharge.zqu__Discount__c =  quotesInfo[i].discountValueFinancials;
                                    }
                                }
                                
                                for (Integer j = 0; j < quotesInfo[i].quoteRatePlanFoundation.size(); j++) {
                                    if (quotesInfo[i].quoteRatePlanFoundation[j] == quoteRatePlanCharge.zqu__QuoteRatePlan__c && quoteRatePlanCharge.zqu__EffectivePrice__c == 0){
                                        system.debug('QuoteRatePlanCharge Partner Margin Foundation::::' + quoteRatePlanCharge);
                                        quoteRatePlanCharge.zqu__EffectivePrice__c = quotesInfo[i].discountValueFoundation;
                                        quoteRatePlanCharge.zqu__DiscountPercentage__c = quotesInfo[i].discountValueFoundation;
                                        quoteRatePlanCharge.Total_Margin__c = quotesInfo[i].discountValueFoundation;
                                        quoteRatePlanCharge.Partner_Tier__c = quotesInfo[i].PartnerTypeTier;
                                        quoteRatePlanCharge.zqu__Discount__c =  quotesInfo[i].discountValueFoundation;
                                    }
                                }
                            }
                        }
                    }
                    
                    update quoteRatePlanstoUpdate;
                    
                    //update quote charge summary
                    
                    List<zqu__QuoteChargeSummary__c> quoteChargeSummariestoUpdate = [SELECT Id,Name,zqu__EffectivePrice__c,zqu__QuoteRatePlan__c,Total_Margin__c,zqu__Discount__c FROM zqu__QuoteChargeSummary__c WHERE zqu__QuoteRatePlan__c IN: quoteRatePlansIDStoUpdate];
                    
                    for (zqu__QuoteChargeSummary__c quoteChargeSummary : quoteChargeSummariestoUpdate){
                        for (Integer i = 0; i < quotesInfo.size(); i++) {
                            for (Integer j = 0; j < quotesInfo[i].quoteRatePlanFinancials.size(); j++) {
                                if (quotesInfo[i].quoteRatePlanFinancials[j] == quoteChargeSummary.zqu__QuoteRatePlan__c && quoteChargeSummary.zqu__EffectivePrice__c == 0){
                                    system.debug('Quote Charge Summary Partner Margin Financials::::' + quoteChargeSummary);
                                    quoteChargeSummary.zqu__EffectivePrice__c = quotesInfo[i].discountValueFinancials;
                                    quoteChargeSummary.zqu__Discount__c = quotesInfo[i].discountValueFinancials;
                                    // QuoteChargeSummary.Total_Margin__c = quotesInfo[i].discountValueFinancials;
                                    
                                }
                            }
                            
                            for (Integer j = 0; j < quotesInfo[i].quoteRatePlanFoundation.size(); j++) {
                                if (quotesInfo[i].quoteRatePlanFoundation[j] == quoteChargeSummary.zqu__QuoteRatePlan__c && quoteChargeSummary.zqu__EffectivePrice__c == 0){
                                    system.debug('Quote Charge Summary Partner Margin Foundation::::' + quoteChargeSummary);
                                    quoteChargeSummary.zqu__EffectivePrice__c = quotesInfo[i].discountValueFoundation;
                                    quoteChargeSummary.zqu__Discount__c = quotesInfo[i].discountValueFoundation;
                                    //QuoteChargeSummary.Total_Margin__c = quotesInfo[i].discountValueFoundation;
                                    
                                }
                            }
                        }
                    }
                    
                    update quoteChargeSummariestoUpdate;
                    
                    //Update non Margin QuoteRatePlans
                    
                    quoteRatePlansIDStoUpdate.clear();
                    
                    for (integer j = 0; j < quoteRatePlansInfo.size(); j++) {
                        if (quoteRatePlansInfo[j].partnerTier <> '' && quoteRatePlansInfo[j].partnerMargin>0){
                            quoteRatePlansIDStoUpdate.add(quoteRatePlansInfo[j].quoteRatePlanID);
                        }
                    }
                    
                    //This piece of code needs to be uncommented if it's decided to update partner margin and partner tier for the partner margin products. Update needs
                    // to be changed to reflect this type of change as well
                    
                    
                    if (quoteRatePlansIDStoUpdate.size()>0){
                        
                        system.debug('Update non Margin QuoteRatePlans::::' + quoteRatePlansIDStoUpdate);
                        
                        List<zqu__QuoteRatePlanCharge__c> QuoteRatePlanstoUpdateMargin = [SELECT Id,Name,zqu__EffectivePrice__c,zqu__QuoteRatePlan__c,Total_Margin__c,Partner_Tier__c,zqu__DiscountPercentage__c,Quote__c,zqu__Discount__c, zqu__Description__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__c IN: quoteRatePlansIDStoUpdate];
                        
                        system.debug('Update non Margin QuoteRatePlanstoUpdate::::' + QuoteRatePlanstoUpdateMargin);
                        for( zqu__QuoteRatePlanCharge__c quoteRatePlanCharge : QuoteRatePlanstoUpdateMargin){
                            for (Integer i = 0; i < quoteRatePlansInfo.size(); i++) {
                                if (quoteRatePlansInfo[i].QuoteRatePlanID == quoteRatePlanCharge.zqu__QuoteRatePlan__c && quoteRatePlansInfo[i].PartnerMargin > 0 ){
                                    quoteRatePlanCharge.Total_Margin__c = quoteRatePlansInfo[i].PartnerMargin;
                                    if(String.isNotBlank(quoteRatePlanCharge.zqu__Description__c)) {
                                        quoteRatePlanCharge.zqu__Description__c = quoteRatePlansInfo[i].endCustomerName;
                                    }
                                }
                                if (quoteRatePlansInfo[i].QuoteRatePlanID == quoteRatePlanCharge.zqu__QuoteRatePlan__c && quoteRatePlansInfo[i].PartnerTier <> '' ){
                                    quoteRatePlanCharge.Partner_Tier__c = quoteRatePlansInfo[i].PartnerTier;
                                    if(String.isNotBlank(quoteRatePlanCharge.zqu__Description__c)) {
                                        quoteRatePlanCharge.zqu__Description__c = quoteRatePlansInfo[i].endCustomerName;
                                    }
                                }
                            }
                        }
                        
                        update QuoteRatePlanstoUpdateMargin;
                        
                        for(zqu__QuoteRatePlanCharge__c objRatePlan : (List<zqu__QuoteRatePlanCharge__c>) newItems){
                            
                            for (Integer i = 0; i < quoteRatePlansInfo.size(); i++) {
                                
                                system.debug('Its going to update new quote rate plan charge?');
                                
                                if (quoteRatePlansInfo[i].QuoteRatePlanID == objRatePlan.zqu__QuoteRatePlan__c && quoteRatePlansInfo[i].PartnerMargin > 0 ){
                                    system.debug('Yes:Total Margin' +  quoteRatePlansInfo[i].PartnerMargin);
                                    objRatePlan.Total_Margin__c = quoteRatePlansInfo[i].PartnerMargin;
                                    objRatePlan.zqu__Description__c = quoteRatePlansInfo[i].endCustomerName;
                                }
                                if (QuoteRatePlansInfo[i].QuoteRatePlanID == objRatePlan.zqu__QuoteRatePlan__c && quoteRatePlansInfo[i].PartnerTier <> '' ){
                                    system.debug('Yes:Partner Tier' +  quoteRatePlansInfo[i].PartnerTier);
                                    objRatePlan.Partner_Tier__c = quoteRatePlansInfo[i].PartnerTier;
                                    if(String.isNotBlank(objRatePlan.zqu__Description__c)) {
                                        objRatePlan.zqu__Description__c = quoteRatePlansInfo[i].endCustomerName;
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
            }
            
        } catch(Exception ex) {
            System.debug('error in QuoteRatePlanChargeOnAdd: ' + ex.getStackTraceString());
            System.debug('Exception message:'+ex.getMessage());
            ex.getStackTraceString();
            //throw new AddRemoveException(ex.getStackTraceString()+':'+ex.getMessage());
        }
        
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        System.debug('Before Update');
        
        for(zqu__QuoteRatePlanCharge__c objRatePlanNew : (List<zqu__QuoteRatePlanCharge__c>) newItems.values()){
            for(zqu__QuoteRatePlanCharge__c objRatePlanOld : (List<zqu__QuoteRatePlanCharge__c>) oldItems.values()){
                if (objRatePlanNew.ID == objRatePlanOld.ID){
                    System.debug('New Effective Price '+ objRatePlanNew.zqu__EffectivePrice__c);
                    System.debug('Old Effective Price '+ objRatePlanOld.zqu__EffectivePrice__c);
                    if (objRatePlanNew.Total_Margin__c <> 0 && objRatePlanNew.Partner_Tier__c <> '' && objRatePlanNew.zqu__Model__c == 'Discount-Percentage'){
                        System.debug('Its gonna update Total Margin');
                        objRatePlanNew.Total_Margin__c = objRatePlanNew.zqu__EffectivePrice__c;
                    }
                }
            }
        }
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems){
        
    }
    
    public void AfterInsert(Map<Id, SObject> newItems){
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Set<ID> setQuoteID = new Set<ID>();
        
        Set<ID>  setQuoteIDs = new Set<ID>();
        
        for(zqu__QuoteRatePlanCharge__c objRatePlan :  (List<zqu__QuoteRatePlanCharge__c>) newItems.values()){
            
            system.debug('INSIDE TRIGGER');
            System.debug('Quote' + objRatePlan.quote__c);
            
            if(!setQuoteIDs.Contains(objRatePlan.quote__c) && !system.isFuture())
            {
                //setQuoteID.add(objRatePlan.quote__c);
                
                setQuoteIDs.add(objRatePlan.quote__c);
            }
        }
        
        if(!setQuoteIDs.isempty())
        {
            
            SPPUtils.updateResellMarginFromTrigger(setQuoteIDs);
        }
        
        
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems){
        
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems){
        
    }
    
}