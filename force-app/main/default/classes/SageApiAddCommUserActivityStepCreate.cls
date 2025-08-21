public class SageApiAddCommUserActivityStepCreate extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID))
                continue;
            
			activitiesToProcess.add(activity);
        }

        SageApiAddCommUserActivityUtils.createUser(step, activitiesToProcess);
        system.debug('SageApiAddCommUserActivityStepCreate: '+JSON.serialize(activities));
    }
}