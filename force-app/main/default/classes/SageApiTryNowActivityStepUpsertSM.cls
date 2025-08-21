/**
 * Activity Step definition which creates an asset
 * @author Shekhar Patnaik
 * @param step of the activity being executed
 * @param activities list which needs to be processed
 * @param sessionId
 **/ 
public class SageApiTryNowActivityStepUpsertSM extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
    	    System.debug('SageApiTryNowActivityStepUpsertSM: Check for required steps');
        	if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
        	    System.debug('required steps are not complete, return to queue');
            	continue;
        	}
        	
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID))
                continue;

            if (SageApiActivityUtils.reachedMaxAttempts(activity, step)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Activity Step ' + step.StepID, ' max allowed retry attemps reached');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
    
                continue;
            }
			
			activitiesToProcess.add(activity);            
        }
        
        if (activitiesCompleted.size() > 0)
            SageApiActivityUtils.updateActivities(activitiesCompleted);
        
        if (activitiesToProcess.size() == 0) {
            system.debug('SageApiTryNowActivityStepUpsertSM exit without actions');
            return;
        }
        system.debug('SageApiTryNowActivityStepUpsertSM step: '+step);
        system.debug('SageApiTryNowActivityStepUpsertSM activitiesToProcess: '+activitiesToProcess);
        SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster(step, activitiesToProcess);
        system.debug('SageApiTryNowActivityStepUpsertSM: '+JSON.serialize(activities));
    }
}