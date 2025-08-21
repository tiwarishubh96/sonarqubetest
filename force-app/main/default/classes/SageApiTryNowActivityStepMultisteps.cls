public class SageApiTryNowActivityStepMultisteps extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        if (step == null || activities == null || activities.isEmpty()) return;
        
        if (step.ActionID == 1) {
            Map<string, SageApiActivityReferrerPromotion__c> promotions = SageApiActivityUtils.getPromotions(activities);
            List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
            List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
            Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
            Map<Id, Lead> leadMap = SageApiTryNowActivityUtils.getRequestLeads(activities);
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
            for(SageApiActivity__c activity : activities)
                SageApiTryNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), leadMap, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, activitySubMasterMap, promotions);
        } else if (step.ActionID == 2) {
            System.debug('createOrUpdateLead activities: ' + activities.size());
            if (activities[0].ActivityType__c == SageApiActivityTriggerHandler.TetrisStartTrialActivityType)
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
}