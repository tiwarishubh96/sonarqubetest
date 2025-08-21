public class SageApiTryNowLeadActivityStepValidate extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);

        for(SageApiActivity__c activity : activities) {
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID))
                continue;

            SageApiActivityStep runningStep = step.deepClone();
            SageApiTryNowLeadActivityUtils.validatePayload(activity, runningStep, productTiers, (listTierMap == null ? null :listTierMap.values()));
        }
        system.debug('SageApiTryNowLeadActivityStepValidate: '+JSON.serialize(activities));
    }
}