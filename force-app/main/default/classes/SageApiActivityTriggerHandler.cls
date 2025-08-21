public with sharing class SageApiActivityTriggerHandler {
    public final static string LeadActivityType = 'TryNowLead';
    public final static string TryNowActivityType = 'TryNow';
    public final static string TryNowConvertActivityType = 'TryNowConvert';
    public final static string TryNow2ActivityType = 'TryNow2';
    public final static string TryNowConvert2ActivityType = 'TryNowConvert2';
    public final static string BuyNowActivityType = 'BuyNow';
    public final static string BuyNow2ActivityType = 'BuyNow2';
    public final static string AddCommunityUserType = 'AddCommunityUser';
    public final static string TetrisStartTrialActivityType = 'TetrisStartTrial';
    public final static string TetrisConvertTrialActivityType = 'TetrisConvertTrial';
    public final static string TetrisStartPaidActivityType = 'TetrisStartPaid';
    public final static string CreateSubscriptionActivityType = 'CreateSubscription';
    public final static string DeleteSubscriptionActivityType = 'DeleteSubscription';
    public final static string SuspendSubscriptionActivityType = 'SuspendSubscription';
    public final static string ReactivateSubscriptionActivityType = 'ReactivateSubscription';
    public final static string RegradeSubscriptionActivityType = 'RegradeSubscription';
    public final static string ConvertSubscriptionActivityType = 'ConvertSubscription';
    public final static string AmendSubscriptionActivityType = 'AmendSubscription';
    public final static string UpdateSubscriptionActivityType = 'UpdateSubscription';
    public final static string UpdateSubscriptionEffectivePeriodActivityType = 'UpdateSubscriptionEffectivePeriod';
    public final static string CreateAccountActivityType = 'CreateAccount';
    public final static List<String> ActivityTypes = new List<String> {
            LeadActivityType, TryNowActivityType, TryNowConvertActivityType, BuyNowActivityType, AddCommunityUserType, 
            TetrisStartTrialActivityType, TetrisConvertTrialActivityType, TetrisStartPaidActivityType, CreateSubscriptionActivityType, 
            DeleteSubscriptionActivityType, SuspendSubscriptionActivityType, ReactivateSubscriptionActivityType,
            RegradeSubscriptionActivityType, ConvertSubscriptionActivityType, UpdateSubscriptionEffectivePeriodActivityType,
            AmendSubscriptionActivityType, UpdateSubscriptionActivityType, CreateAccountActivityType
        };

    private static boolean isOnce = true;
    public static boolean runOnce(){
        if (isOnce)
            isOnce = false;

        return isOnce;
    }
        
    public void onAfterInsert(List<SageApiActivity__c> newActivities, Map<Id, SageApiActivity__c> newActivitiesMap)
    {
        system.debug('SageApiActivity__c insert trigger starts');

        List<SageApiActivity__c> allActivities = SageApiActivityUtils.refreshActivities(newActivities);
        for (String activityType : ActivityTypes) {
            List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
            List<SageApiActivity__c> activitiesV2 = new List<SageApiActivity__c>();
            for (SageApiActivity__c activity : allActivities)
                if (activity.ActivityType__c == activityType && activity.ActivityStatus__c != SageApiStatus.InProgressExternal)
                    if (activityType == SageApiActivityTriggerHandler.CreateSubscriptionActivityType && activity.ActivityTypeVersion__c == 2)
                        activitiesV2.add(activity);
                    else if (activity.ActivityTypeVersion__c > 2)
                        system.debug('do nothing with activity.ActivityTypeVersion__c > 2');
                    else
                        activities.add(activity);

            if (activities.size() > 0)
                System.enqueueJob(new SageApiActivityHandler(activityType, null, activities, UserInfo.getSessionId()));
            if (activitiesV2.size() > 0)
                System.enqueueJob(new SageApiActivityHandler(2, activityType, null, activitiesV2, UserInfo.getSessionId()));
        }
        
        system.debug('SageApiActivity__c insert trigger should be triggered');
    }
    
    public void onAfterUpdate(final List<SageApiActivity__c> oldActivities, final Map<Id, SageApiActivity__c> oldActivitiesMap,
                          final List<SageApiActivity__c> newActivities, final Map<Id, SageApiActivity__c> newActivitiesMap)
    {
        system.debug('SageApiActivity__c update trigger starts');

        List<SageApiActivity__c> restartingActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : newActivities) {
            SageApiActivity__c oldActivity = oldActivitiesMap.get(activity.ID);
            if (oldActivity.ActivityStatus__c != activity.ActivityStatus__c && activity.ActivityStatus__c == SageApiStatus.Restarting)
                restartingActivities.add(activity);
        }

        if (restartingActivities.size() == 0) {
            system.debug('SageApiActivity__c update trigger no activities to process, exit');
            return;
        }

        system.debug('SageApiActivity__c update trigger starts activities: ' + restartingActivities);

        List<SageApiActivity__c> allActivities = SageApiActivityUtils.refreshActivities(restartingActivities);
        for (String activityType : ActivityTypes) {
            List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
            List<SageApiActivity__c> activitiesV2 = new List<SageApiActivity__c>();
            for (SageApiActivity__c activity : allActivities)
                if (activity.ActivityType__c == activityType)
                    if (activityType == SageApiActivityTriggerHandler.CreateSubscriptionActivityType && activity.ActivityTypeVersion__c == 2)
                        activitiesV2.add(activity);
                    else if (activity.ActivityTypeVersion__c > 2)
                        system.debug('do nothing with activity.ActivityTypeVersion__c > 2');
                    else
                        activities.add(activity);

            if (activities.size() > 0)
                System.enqueueJob(new SageApiActivityHandler(activityType, null, activities, UserInfo.getSessionId()));
            if (activitiesV2.size() > 0)
                System.enqueueJob(new SageApiActivityHandler(2, activityType, null, activitiesV2, UserInfo.getSessionId()));
        }

        system.debug('SageApiActivity__c update trigger should be triggered');

    }
}