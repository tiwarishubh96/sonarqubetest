public class SageApiTryNowLeadActivityStepMultisteps extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
        Map<Id, Lead> leadMap = SageApiTryNowActivityUtils.getRequestLeads(activities);
        
        //ACTION 1.
        step.ActionID = 1;
        step.Action = 'validatePayload';
        step.NextActionID = 2;
        for(SageApiActivity__c activity : activities)
            SageApiTryNowLeadActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()));
        SageApiActivityUtils.updateActivities(step, activities);
        System.debug('activities: ' + activities);
        List<SageApiActivity__c> nextActivities = SageApiActivityUtils.getPendingActivitiesForNextAction(step, activities);
        
        //ACTION 2
        step.ActionID = 2;
        step.Action = 'createOrUpdateLead';
        step.NextActionID = 0;
        System.debug('createOrUpdateLead nextActivities: ' + nextActivities);
        if (nextActivities != null && !nextActivities.isEmpty()) {
            SageApiTryNowLeadActivityUtils.createLead(step, nextActivities);
            SageApiActivityUtils.updateActivities(step, nextActivities);
	        nextActivities = SageApiActivityUtils.getPendingActivitiesForNextAction(step, nextActivities);
        }

        system.debug('SageApiTryNowActivityStepValidatePayload: '+JSON.serialize(activities));
    }
}