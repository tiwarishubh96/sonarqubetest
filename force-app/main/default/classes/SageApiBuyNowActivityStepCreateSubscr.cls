public class SageApiBuyNowActivityStepCreateSubscr extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
    	    SageApiActivityUtils.debug('SageApiBuyNowActivityStepCreateSubscr: Check for required steps');
        	if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
        	    SageApiActivityUtils.debug('required steps are not complete, return to queue');
            	continue;
        	}
        	
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID)){
                activitiesCompleted.add(activity);
                continue;
            }

            SageApiActivityUtils.debug('SageApiBuyNowActivityStepCreateSubscr: Check for existing ZuoraSubscriptionId__c');
            if (String.isNotBlank(activity.ZuoraSubscriptionId__c)) {
                SageApiActivityUtils.debug('ZuoraSubscriptionId__c: '+activity.ZuoraSubscriptionId__c);
                //SageApiTryNowActivityUtils.updateArtifactWithPaymentMethodUrl(activity, activity.PayNowToken__r.PayNowRedirectUrl__c);
                activity.LockedForProcess__c = SageApiProcessLocks.None;
                SageApiActivityUtils.setSuccess(activity, step);
                activitiesCompleted.add(activity);
                continue;
            }

            if (SageApiActivityUtils.reachedMaxAttempts(activity, step)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Activity Step ' + step.StepID, ' max allowed retry attemps reached');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                activitiesCompleted.add(activity);
                continue;
            }
			
			activitiesToProcess.add(activity);            
        }
        
        if (activitiesCompleted.size() > 0)
            SageApiActivityUtils.updateActivities(activitiesCompleted);
        
        if (activitiesToProcess.size() == 0) {
            SageApiActivityUtils.debug('SageApiBuyNowActivityStepCreateSubscr exit without actions');
            return;
        }
        SageApiActivityUtils.debug('SageApiBuyNowActivityStepCreateSubscr step: '+step);
        SageApiBuyNowActivityUtils.createSubscription(step, activitiesToProcess, sessionId);
    }
}