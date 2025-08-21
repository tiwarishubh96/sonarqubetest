public class SageApiTryNowConvertStepUpdateQuote  extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            SageApiActivityUtils.debug('SageApiTryNowConvertStepUpdateQuote: Check for required steps');
            if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
                SageApiActivityUtils.debug('required steps are not complete, return to queue');
                continue;
            }
            
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID)){
                activitiesCompleted.add(activity);
                continue;
            }

            SageApiActivityUtils.debug('SageApiTryNowConvertStepUpdateQuote: Check for processed quotes');
            if (String.isNotBlank(activity.Quote__c) && activity.QuoteMetricsCalculated__c) {
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
            SageApiActivityUtils.debug('SageApiTryNowConvertStepUpdateQuote exit without actions');
            return;
        }

        SageApiActivityUtils.debug('SageApiTryNowConvertStepUpdateQuote step: '+step);
        SageApiActivityUtils.debug('SageApiTryNowConvertStepUpdateQuote activitiesToProcess: '+activitiesToProcess);
        SageApiTryNowConvertActivityUtils.UpdateQuote(step, activitiesToProcess);
        SageApiActivityUtils.debug('SageApiTryNowConvertStepUpdateQuote: '+JSON.serialize(activities));
    }
}