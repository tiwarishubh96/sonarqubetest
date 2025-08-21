public class SageApiTryNowActivityStepGetPaymentUrl extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
    	    System.debug('SageApiTryNowActivityStepGetPaymentUrl: Check for required steps');
        	if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
        	    System.debug('required steps are not complete, return to queue');
            	continue;
        	}
        	
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID)){
                activitiesCompleted.add(activity);
                continue;
            }

            System.debug('SageApiTryNowActivityStepGetPaymentUrl: Check for existing PayNowRedirectUrl__c');
            if (String.isNotBlank(activity.PayNowToken__c) && String.isNotBlank(activity.PayNowToken__r.PayNowRedirectUrl__c)) {
                System.debug('PayNowRedirectUrl__c: '+activity.PayNowToken__r.PayNowRedirectUrl__c);
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
            system.debug('SageApiTryNowActivityStepGetPaymentUrl exit without actions');
            return;
        }
        system.debug('SageApiTryNowActivityStepGetPaymentUrl step: '+step);
        system.debug('SageApiTryNowActivityStepGetPaymentUrl activitiesToProcess: '+activitiesToProcess);
        SageApiTryNowActivityUtils.getPaymentUrl(step, activitiesToProcess, sessionId);
        system.debug('SageApiTryNowActivityStepGetPaymentUrl exiting');
    }
}