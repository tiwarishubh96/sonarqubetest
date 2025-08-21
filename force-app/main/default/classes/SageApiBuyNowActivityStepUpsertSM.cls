/**
 * Activity Step definition which creates an Subscription Master
 * @author Shekhar Patnaik
 * @param step of the activity being executed
 * @param activities list which needs to be processed
 * @param sessionId
 **/ 
public class SageApiBuyNowActivityStepUpsertSM extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            System.debug('SageApiBuyNowActivityStepUpsertSM: Check for required steps');
            if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
                System.debug('required steps are not complete, return to queue');
                continue;
            }
            
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID)){
                activitiesCompleted.add(activity);
                continue;
            }

            System.debug('SageApiBuyNowActivityStepUpsertSM: Check for existing Entitlement_Message__c');
            if (String.isNotBlank(activity.Entitlement_Message__c) && activity.Entitlement_Message__r.Status__c == 'processed') {
                System.debug('Entitlement_Message__c: '+activity.Entitlement_Message__c);
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
            system.debug('SageApiBuyNowActivityStepUpsertSM exit without actions');
            return;
        }
        system.debug('SageApiBuyNowActivityStepUpsertSM step: '+step);
        system.debug('SageApiBuyNowActivityStepUpsertSM activitiesToProcess: '+activitiesToProcess);
        SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster(step, activitiesToProcess);
        system.debug('SageApiBuyNowActivityStepUpsertSM: '+JSON.serialize(activities));
    }
}