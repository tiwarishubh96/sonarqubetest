public class SageApiBuyNowActivityStepMultiSteps extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        if (step == null || activities == null || activities.isEmpty()) return;

        if (step.ActionID == 1) {
            List<PayNowToken__c> tokens = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
            List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
            if (products == null) products = new List<SageApiActivityRequestObjects.Product>();
            if (tokens != null)
                for (PayNowToken__c token : tokens) {
                    if (String.isBlank(token.Products__c)) continue;

                    List<SageApiActivityRequestObjects.ProductConfig> productConfigs = (List<SageApiActivityRequestObjects.ProductConfig>) JSON.deserialize(token.Products__c, List<SageApiActivityRequestObjects.ProductConfig>.class);
                    if (productConfigs == null || productConfigs.size() == 0) continue;

                    for (SageApiActivityRequestObjects.ProductConfig productConfig : productConfigs) {
                        SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
                        product.tierCode = productConfig.tierCode;
                        if (String.isNotBlank(productConfig.pricingCode))
                            product.pricingCode = productConfig.pricingCode;
                        else if (String.isNotBlank(token.ReferrerPromotion__r.PricingCode__r.Name))
                            product.pricingCode = token.ReferrerPromotion__r.PricingCode__r.Name;
                        if (String.isBlank(product.pricingCode))
                            product.pricingCode = '_LIST';
                        if (productConfig.tierRatePlanCodes!=null && productConfig.tierRatePlanCodes.size()>0)
                            product.tierRatePlanCode = productConfig.tierRatePlanCodes[0].tierRatePlanCode;
                        products.add(product);
                    }
                }
            List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
            Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);

            Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
            Map<Id, Account> accounts = SageApiTryNowActivityUtils.getValidRequestAccounts(activities);
            Map<Id, Contact> contacts = SageApiTryNowActivityUtils.getValidRequestContacts(activities);
            Map<string, SageUserIdentityProvider__c> identities = SageApiTryNowActivityUtils.getValidRequestIdentities(activities);
            Map<ID, Community_Membership__c> contactCommunitiesMap = null;
            if (identities != null && identities.size() > 0) {
                List<ID> ids = new List<ID>();
                for (SageUserIdentityProvider__c identity : identities.values())
                    if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                        ids.add(identity.User__r.ContactId);
                SageApiActivityUtils.debug('ids: '+ids);
                if (ids.size() > 0)
                    contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
                SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
            }
            Map<ID, ID> activitySubMasterMap = SageApiTryNowActivityUtils.getActivitySubscriptionMasters(activities);
            Map<ID, ID> activitySubMap = SageApiBuyNowActivityUtils.getZuoraSubscriptions(activities);

            for(SageApiActivity__c activity : activities)
                SageApiBuyNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, activitySubMasterMap, activitySubMap);
        } else if (step.ActionID == 2) {
            System.debug('createOrUpdateLead activities: ' + activities.size());
            if (activities[0].ActivityType__c == SageApiActivityTriggerHandler.TetrisStartPaidActivityType)
                SageApiTryNowActivityUtils.createOrUpdateLeadFromContact(step, activities);
            else
                    SageApiTryNowActivityUtils.createOrUpdateLead(step, activities);
        } else if (step.ActionID == 3) {
            System.debug('convertLead activities: ' + activities.size());
            SageApiTryNowActivityUtils.convertLead(step, activities);
        } else if (step.ActionID == 4) {
            System.debug('createUser activities: ' + activities.size());
            SageApiTryNowActivityUtils.provisionUser(step, activities);
        } else if (step.ActionID == 5) {
            System.debug('createQuote activities: ' + activities.size());
            SageApiTryNowActivityUtils.createQuote(step, activities);
        } else {
            System.debug('no action: ' + activities.size());
            return;
        }

        SageApiActivityUtils.updateActivities(step, activities);
        System.debug('activities: ' + activities);
    }
/*
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        if (step == null || activities == null || activities.isEmpty()) return;

        if (step.ActionID == 1) {
            Map<PayNowToken__c, SageApiActivity__c> tokenActivityMap = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
            List<PayNowToken__c> tokens = (tokenActivityMap == null ? null : new List<PayNowToken__c>(tokenActivityMap.keySet()));
            List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
            if (products == null) products = new List<SageApiActivityRequestObjects.Product>();
            for (PayNowToken__c token : tokens) {
                if (String.isBlank(token.Products__c)) continue;

                List<SageApiActivityRequestObjects.ProductConfig> productConfigs = (List<SageApiActivityRequestObjects.ProductConfig>) JSON.deserialize(token.Products__c, List<SageApiActivityRequestObjects.ProductConfig>.class);
                if (productConfigs == null || productConfigs.size() == 0) continue;

                SageApiActivity__c activity = tokenActivityMap.get(token);
                String activityType = (activity == null ? null : activity.ActivityType__c);
                SageApiActivityUtils.debug('activity type: '+activityType);
                Boolean isTryNowConvert = (activityType == SageApiActivityTriggerHandler.TryNowConvertActivityType);

                for (SageApiActivityRequestObjects.ProductConfig productConfig : productConfigs) {
                    SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
                    product.tierCode = productConfig.tierCode;

                    //Convert case: expiration date is not checked
                    if (isTryNowConvert && String.isNotBlank(token.ReferrerPromotion__r.PricingCode__r.Name))
                        product.pricingCode = token.ReferrerPromotion__r.PricingCode__r.Name;
                    //BuyNow and TryNow check if still valid at the moment
                    else if (!isTryNowConvert && String.isNotBlank(token.ReferrerPromotion__r.PricingCode__r.Name) && token.ReferrerPromotion__r.StartDate__c<=Date.today() && token.ReferrerPromotion__r.EndDate__c>=Date.today())
                        product.pricingCode = token.ReferrerPromotion__r.PricingCode__r.Name;
                    else if (String.isBlank(token.ReferrerPromotion__r.PricingCode__r.Name) && String.isNotBlank(productConfig.pricingCode))
                        product.pricingCode = productConfig.pricingCode;

                    if (String.isBlank(product.pricingCode))
                        product.pricingCode = '_LIST';
                    if (productConfig.tierRatePlanCodes!=null && productConfig.tierRatePlanCodes.size()>0)
                        product.tierRatePlanCode = productConfig.tierRatePlanCodes[0].tierRatePlanCode;
                    products.add(product);
                }
            }
            List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
            Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);

            Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
            Map<Id, Account> accounts = SageApiTryNowActivityUtils.getValidRequestAccounts(activities);
            Map<Id, Contact> contacts = SageApiTryNowActivityUtils.getValidRequestContacts(activities);
            Map<string, SageUserIdentityProvider__c> identities = SageApiTryNowActivityUtils.getValidRequestIdentities(activities);
            Map<ID, Community_Membership__c> contactCommunitiesMap = null;
            if (identities != null && identities.size() > 0) {
                List<ID> ids = new List<ID>();
                for (SageUserIdentityProvider__c identity : identities.values())
                    if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                        ids.add(identity.User__r.ContactId);
                SageApiActivityUtils.debug('ids: '+ids);
                if (ids.size() > 0)
                    contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
                SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
            }
            Map<ID, ID> activitySubMasterMap = SageApiTryNowActivityUtils.getActivitySubscriptionMasters(activities);
            Map<ID, ID> activitySubMap = SageApiBuyNowActivityUtils.getZuoraSubscriptions(activities);

            for(SageApiActivity__c activity : activities)
                SageApiBuyNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, activitySubMasterMap, activitySubMap);
        } else if (step.ActionID == 2) {
            System.debug('createOrUpdateLead activities: ' + activities.size());
            if (activities[0].ActivityType__c == SageApiActivityTriggerHandler.TetrisStartPaidActivityType)
                SageApiTryNowActivityUtils.createOrUpdateLeadFromContact(step, activities);
            else
                SageApiTryNowActivityUtils.createOrUpdateLead(step, activities);
        } else if (step.ActionID == 3) {
            System.debug('convertLead activities: ' + activities.size());
            SageApiTryNowActivityUtils.convertLead(step, activities);
        } else if (step.ActionID == 4) {
            System.debug('createUser activities: ' + activities.size());
            SageApiTryNowActivityUtils.provisionUser(step, activities);
        } else if (step.ActionID == 5) {
            System.debug('createQuote activities: ' + activities.size());
            SageApiTryNowActivityUtils.createQuote(step, activities);
        } else {
            System.debug('no action: ' + activities.size());
            return;
        }

        SageApiActivityUtils.updateActivities(step, activities);
        System.debug('activities: ' + activities);
    }
 */
}