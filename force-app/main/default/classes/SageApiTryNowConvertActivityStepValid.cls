public class SageApiTryNowConvertActivityStepValid extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        List<PayNowToken__c> tokens = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
/*
        Map<PayNowToken__c, SageApiActivity__c> tokenActivityMap = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
        List<PayNowToken__c> tokens = (tokenActivityMap == null ? null : new List<PayNowToken__c>(tokenActivityMap.keySet()));
*/
        List<SageApiActivityRequestObjects.Product> allProducts = new List<SageApiActivityRequestObjects.Product>();
        Map<String, List<SageApiActivityRequestObjects.Product>> tokenProductsMap = new Map<String, List<SageApiActivityRequestObjects.Product>>();
        Map<String, SageApiActivity__c> tokenTryNowActivityMap = new Map<String, SageApiActivity__c>();
        Map<String, Subscription_Master__c> subscriptionMasterMap = new Map<String, Subscription_Master__c>();

        if (tokens != null) {
            for (PayNowToken__c token : tokens) {
                if (String.isBlank(token.Products__c)) continue;

                List<SageApiActivityRequestObjects.ProductConfig> productConfigs = (List<SageApiActivityRequestObjects.ProductConfig>) JSON.deserialize(token.Products__c, List<SageApiActivityRequestObjects.ProductConfig>.class);
                if (productConfigs == null || productConfigs.size() == 0) continue;

                List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
                for (SageApiActivityRequestObjects.ProductConfig productConfig : productConfigs) {
                    SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
                    product.tierCode = productConfig.tierCode;
                    product.pricingCode = productConfig.pricingCode;
                    if (productConfig.tierRatePlanCodes!=null && productConfig.tierRatePlanCodes.size()>0)
                        product.tierRatePlanCode = productConfig.tierRatePlanCodes[0].tierRatePlanCode;
                    products.add(product);
                    allProducts.add(product);
                }
                tokenProductsMap.put(token.Name, products);
                tokenTryNowActivityMap.put(token.Name, null);
            }

            tokenTryNowActivityMap.putAll([SELECT Id, Account__c, Contact__c, Opportunity__c, User__c, PayNowToken__r.Name FROM SageApiActivity__c WHERE ActivityType__c=:SageApiActivityTriggerHandler.TryNowActivityType AND PayNowToken__r.Name IN: tokenTryNowActivityMap.keyset()]);
        }

        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(allProducts);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(allProducts);

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowConvertActivityRequest req = null;
            try {
                req = (SageApiTryNowConvertActivityRequest)JSON.deserialize(payload, SageApiTryNowConvertActivityRequest.class);
                if (req == null || String.isBlank(req.cbcTrialId)) continue;

                subscriptionMasterMap.put(req.cbcTrialId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowConvertActivityStepValid', 'payload issue', ex);
            }
        }

        if (subscriptionMasterMap.size() > 0) {
            List<Subscription_Master__c> sms = [SELECT Account__c,Id,Sage_API_Activity__c,Sage_API_Activity__r.Opportunity__c,CbcSubscriptionId__c FROM Subscription_Master__c WHERE CbcSubscriptionId__c IN: subscriptionMasterMap.keyset()];
            for (Subscription_Master__c sm : sms)
                if (subscriptionMasterMap.containsKey(sm.CbcSubscriptionId__c))
                    subscriptionMasterMap.put(sm.CbcSubscriptionId__c, sm);
        }

        for(SageApiActivity__c activity : activities) {
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID))
                continue;

            SageApiActivityStep runningStep = step.deepClone();
            SageApiTryNowConvertActivityUtils.validatePayload(activity, runningStep, productTiers, (listTierMap == null ? null :listTierMap.values()), tokens, tokenProductsMap, tokenTryNowActivityMap, subscriptionMasterMap);
        }

        update activities;
        system.debug('SageApiTryNowConvertActivityStepValid: '+JSON.serialize(activities));
    }
}