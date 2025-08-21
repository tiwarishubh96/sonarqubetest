public class SageApiTryNowLeadActivityStepCreateLead extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID))
                continue;
            
            activitiesToProcess.add(activity);
        }

        SageApiTryNowLeadActivityUtils.createLead(step, activitiesToProcess);
        system.debug('SageApiTryNowLeadActivityStepCreateLead : '+JSON.serialize(activities));
        
        //update activities;
    }
}