/**
* Created by taa on 05/05/2020.
* Class created to manage Zuora rules engine with custom code.
* Atribute "scenario" should allow us to implement different scenario using this class
* This class was originally implemented for Jira ticket EAD-1396
*/


global with sharing class ZRulesEngineCustomActions implements zqu.CustomActionPlugin{
    
    global void perform(zqu.DataObject masterObject, Map < String, Object > attributes, String[] logs){
        // Read values from Quote Object
        String quoteId = (String)masterObject.get('Id');
        logs.add('QuoteId=' + quoteId);
        
        System.debug(attributes);
        // Read values set in Rule Configuration
        String attributeMsg = (String)attributes.get('msg');
        logs.add('Attribute Message=' + attributeMsg);
        
        String scenario = (String)attributes.get('scenario');

        logs.add('scenario=' + scenario);

        // on this scenario validate API from tetris will be called to make sure the selected product is allowed on a new subscription scenario with an existing billing account
        if (scenario=='cross-sell' || scenario == 'new subscription'){
            System.debug('cross-sell');
            TetrisValidateResult.Response calloutResponse;
            
            zqu__Quote__c zQuoteNew = [Select Id, zqu__BillToContact__r.ID, zqu__BillToContact__r.Email, zqu__Opportunity__r.ID,
                                       zqu__Account__r.ID, Account_Locale__c ,zqu__ZuoraSubscriptionID__c,zqu__Status__c,
                                       External_Application__c,	zqu__StartDate__c
                                       FROM zqu__Quote__c
                                       WHERE Id =: quoteId];
            
            System.debug('zQuoteNew ::::'+zQuoteNew);
            
            TetrisUtility.ZQuotesValidateCallout zqValidateCallout = new TetrisUtility.ZQuotesValidateCallout();
            
            zqValidateCallout.accountId = zQuoteNew.zqu__Account__c;
            zqValidateCallout.userLocale = zQuoteNew.Account_Locale__c;
            zqValidateCallout.emailAddress = zQuoteNew.zqu__BillToContact__r.Email;
            zqValidateCallout.contactId = zQuoteNew.zqu__BillToContact__c;
            zqValidateCallout.opportunityId = zQuoteNew.zqu__Opportunity__c;
            if (test.isRunningTest())
                zqValidateCallout .contractEffectiveDate = string.valueof(date.Today()).SubStringBefore(' ');
            else
                zqValidateCallout .contractEffectiveDate = string.valueof(zQuoteNew.zqu__StartDate__c).SubStringBefore(' ');
            System.debug('zqValidateCallout :::'+zqValidateCallout);
            
            
            
            
            
            List<TetrisUtility.ZQuotesValidateProducts> products = new List<TetrisUtility.ZQuotesValidateProducts>();
            List<QuoteRatePlanHelper> quoteRatePlans = new List<QuoteRatePlanHelper>();
            
            List < zqu.DataObject > plans =
                masterObject.getChildren('zqu__QuoteRatePlan__c');
            Set<ID> setProductIds = new Set<ID>();
            
            system.debug('plans ::'+ plans);
            system.debug('# of plans: ' + plans.size());
            
            
            for (zqu.DataObject plan : plans) {
                
                System.debug('zqu__ProductRatePlan__c)'+ plan.get('zqu__ProductRatePlan__c'));
                zqu.DataObject   prodRatePlan = plan.getParent('zqu__ProductRatePlan__c');
                system.debug('prod' + prodRatePlan);
                // for (zqu.DataObject prod : prods) {
                system.debug('zqu__Product__c :::' + prodRatePlan.get('zqu__Product__c'));
                //}
                
                
                system.debug('inside plans');
                system.debug('plan :::' + plan);
                system.debug('plan.get(Id)' + (String) plan.get('zqu__QuoteRatePlan__c'));
                System.debug('name)'+ plan.get('Name'));
                QuoteRatePlanHelper quoteRatePlan =  new QuoteRatePlanHelper();
                
                quoteRatePlan.productId = (Id) prodRatePlan.get('zqu__Product__c');
                quoteRatePlans.add(quoteRatePlan);
                setProductIds.add(quoteRatePlan.productId);
                
                List < zqu.DataObject > charges =
                    plan.getChildren('zqu__QuoteRatePlanCharge__c');
                for (zqu.DataObject charge : charges) {
                    zqu.ZChargeDataObject chargeObject = (zqu.ZChargeDataObject) charge;
                    zqu__QuoteRatePlanCharge__c charge2 = (zqu__QuoteRatePlanCharge__c) chargeObject.getCharge().chargeObject;
                    
                    System.debug(charge2);
                    System.debug('zqu__Model__c' + charge.get('zqu__Model__c'));
                    
                    if (charge.get('zqu__Model__c') == 'Flat Fee Pricing' || charge.get('zqu__Model__c') == 'Volume Pricing'){
                        quoteRatePlan.quoteRatePlanChargeName =  (String) charge.get('Name');
                    }
                }
                
            }
            
            System.debug('quoteRatePlans :::'+ quoteRatePlans);
            System.debug('setProductIds :::'+ setProductIds);
            
            //SELECT zqu__Product__r.zqu__SKU2__c from zqu__ProductRatePlan__c where ID = 'a0s1X000000OU4GQAW'
            if (setProductIds.size()>0){
                List<Product2> quoteProducts = [SELECT Id,zqu__SKU2__c
                                                FROM Product2
                                                WHERE Id IN:setProductIds];
                
                for(Product2 product: quoteProducts){
                    for (integer i = 0; i < quoteRatePlans.size(); i++){
                        if (quoteRatePlans[i].productId==product.Id){
                            quoteRatePlans[i].sku = product.zqu__SKU2__c;
                        }
                    }
                }
            }
            
            System.debug('quoteRatePlans :::'+ quoteRatePlans);
            
            if (quoteRatePlans.size()>0){
                TetrisUtility.ZQuotesValidateProducts productValidate = new TetrisUtility.ZQuotesValidateProducts();
                List < zqu.DataObject > charges =
                    masterObject.getChildren('zqu__QuoteRatePlanCharge__c');
                for (zqu.DataObject charge : charges) {
                    
                    if (charge.get('zqu__Model__c') == 'Flat Fee Pricing'){
                        
                        productValidate.quantity = 1;
                        for (integer i = 0; i < quoteRatePlans.size(); i++){
                            if(quoteRatePlans[i].quoteRatePlanChargeName ==  (String) charge.get('Name')){
                                productValidate.sku =  quoteRatePlans[i].sku;
                            }
                        }
                        products.add(productValidate);
                    }
                    if (charge.get('zqu__Model__c') == 'Volume Pricing') {
                        
                        List<TetrisUtility.ZQuotesValidateProductTier> productTiers = new List<TetrisUtility.ZQuotesValidateProductTier>();
                        TetrisUtility.ZQuotesValidateProductTier productTier = new TetrisUtility.ZQuotesValidateProductTier();
                        
                        for (integer i = 0; i < quoteRatePlans.size(); i++){
                            if(quoteRatePlans[i].quoteRatePlanChargeName ==  (String) charge.get('Name')){
                                productValidate.sku =  quoteRatePlans[i].sku;
                            }
                        }
                        
                        productTier.tierAttribute = (String) charge.get('zqu__UOM__c');
                        productTier.tierQuantity  = String.valueOf( charge.get('zqu__Quantity__c'));
                        productTiers.add(productTier);
                        productValidate.tier = productTiers;
                        
                        products.add(productValidate);
                    }
                }
                zqValidateCallout.products = products;
                
                System.debug('zqValidateCallout :::'+ zqValidateCallout);
                
                calloutResponse = TetrisUtility.callZquotesValidateOrderToQueue(zqValidateCallout);

                if (scenario == 'new subscription' && calloutResponse.result.warning == true){

                    String baseUrl =System.URL.getOrgDomainUrl().toExternalForm();
                    System.debug('baseUrl =' + baseUrl);
                    baseUrl = baseUrl.replace( 'my.salesforce.com','lightning.force.com/lightning');

                    System.debug('account url '+ baseUrl + '/r/Account/' + calloutResponse.result.warningMessage.Left(calloutResponse.result.warningMessage.indexOfAny(':'))+'/view');
                    baseUrl = baseUrl + '/r/Account/' + calloutResponse.result.warningMessage.Left(calloutResponse.result.warningMessage.indexOfAny(':'))+'/view';

                    account acc = [SELECT Name from account where ID  =: calloutResponse.result.warningMessage.Left(calloutResponse.result.warningMessage.indexOfAny(':'))];
                    String errorMessage =  'There is already a salesforce account with email ' + zqValidateCallout.emailAddress + ' on Account: ' + acc.Name + '. Please copy/paste link to access the account: ' + '\r\n'  + baseUrl ;

                    throw new zqu.CustomValidationException(
                            errorMessage);
                }
                
                if (calloutResponse.result.valid == false){
					if(calloutResponse.result.requestType=='invalid')
						throw new zqu.CustomValidationException(Label.lbl_Tetris_API_Invalid_Message);
					else if(calloutResponse.result.requestType=='down_sell')
						throw new zqu.CustomValidationException(Label.lbl_Tetris_API_DownSell_Message);
					else if(calloutResponse.result.requestType=='duplicate_active')
						throw new zqu.CustomValidationException(Label.lbl_Tetris_API_Duplicate_Active_Message);
					else if(calloutResponse.result.requestType=='duplicate_inactive')
						throw new zqu.CustomValidationException(Label.lbl_Tetris_API_Duplicate_Inactive_Message);
					else
						throw new zqu.CustomValidationException(calloutResponse.result.message);
                    
                }
                if (calloutResponse.result.valid==true && calloutResponse.result.requestType != 'cross_sell' && scenario == 'cross-sell'){
                    throw new zqu.CustomValidationException( Label.lbl_Tetris_API_Cross_Sell_Message);
                }
                
                if (calloutResponse.result.valid==true && calloutResponse.result.warning == true ){
                    throw new zqu.CustomValidationException(
                        calloutResponse.result.warningMessage);
                }
            }
        }
        

        logs.add('===');
    }
    
    global Boolean isUpdateAction() { return true; }
    global Boolean isAddRemoveAction() { return true; }
    global Boolean isValidateAction() { return true; }
    
    public  class QuoteRatePlanHelper {
        //Quote Rate Plan Name
        public String quoteRatePlanChargeName;
        //Product ID
        public ID productId;
        //Product SKU
        public String sku;
        
    }
    
    
}