/**
 * Activity Step definition which converts an SM from Trial to Active
 * @author Shekhar Patnaik
 * @param step of the activity being executed
 * @param activities list which needs to be processed
 * @param sessionId
 **/ 
public class SageApiTryNowConvertStepConvertSM extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            SageApiActivityUtils.debug('SageApiTryNowConvertStepConvertSM: Check for required steps');
            if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
                SageApiActivityUtils.debug('required steps are not complete, return to queue');
                continue;
            }
            
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID)){
                activitiesCompleted.add(activity);
                continue;
            }

            SageApiActivityUtils.debug('SageApiTryNowConvertStepConvertSM: Check for existing Entitlement_Message__c');
            if (String.isNotBlank(activity.Entitlement_Message__c) && activity.Entitlement_Message__r.Status__c == 'processed') {
                SageApiActivityUtils.debug('Entitlement_Message__c: '+activity.Entitlement_Message__c);
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
            SageApiActivityUtils.debug('SageApiTryNowConvertStepConvertSM exit without actions');
            return;
        }
        SageApiActivityUtils.debug('SageApiTryNowConvertStepConvertSM step: '+step);
        SageApiActivityUtils.debug('SageApiTryNowConvertStepConvertSM activitiesToProcess: '+activitiesToProcess);
        if (activitiesToProcess[0].ActivityType__c == SageApiActivityTriggerHandler.TetrisConvertTrialActivityType)
            SageApiTryNowActivityUtils.convertTrialToPaid(step, activitiesToProcess);
        else
            SageApiTryNowActivityUtils.convertSubscriptionMaster(step, activitiesToProcess);
        SageApiActivityUtils.debug('SageApiTryNowConvertStepConvertSM: '+JSON.serialize(activities));
    }
}