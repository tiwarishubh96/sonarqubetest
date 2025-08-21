@IsTest(SeeAllData=false)
public class SageApiActivityTriggerHandlerTest {
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
    }

    @IsTest static void testRunOnce()
    {
        Test.startTest();
        
	        System.assertEquals( false, SageApiActivityTriggerHandler.runOnce() );

        Test.stopTest();
    }

    @IsTest static void testLeadOnAfterInsert()
    {
        String activityType = SageApiActivityTriggerHandler.LeadActivityType;
        SageApiTryNowLeadActivityRequest payload = SageApiTestUtils.createTryNowLeadPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        Map<ID, SageApiActivity__c> activitiesMap = new Map<ID, SageApiActivity__c>();
        activitiesMap.putAll(activities);
        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterInsert(activities, activitiesMap);

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);

        System.assertNotEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testTryNowOnAfterInsert()
    {
        String activityType = SageApiActivityTriggerHandler.TryNowActivityType;
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createTryNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        Map<ID, SageApiActivity__c> activitiesMap = new Map<ID, SageApiActivity__c>();
        activitiesMap.putAll(activities);
        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterInsert(activities, activitiesMap);

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);

        System.assertNotEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testTryNowConvertOnAfterInsert()
    {
        String activityType = SageApiActivityTriggerHandler.TryNowConvertActivityType;

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test';
        insert quote;

        SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTryNowConvertPayload(acct.Id, quote.Id);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        Map<ID, SageApiActivity__c> activitiesMap = new Map<ID, SageApiActivity__c>();
        activitiesMap.putAll(activities);
        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterInsert(activities, activitiesMap);

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);

        System.assertNotEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowOnAfterInsert()
    {
        String activityType = SageApiActivityTriggerHandler.BuyNowActivityType;
        SageApiBuyNowActivityRequest payload = SageApiTestUtils.createBuyNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        Map<ID, SageApiActivity__c> activitiesMap = new Map<ID, SageApiActivity__c>();
        activitiesMap.putAll(activities);
        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterInsert(activities, activitiesMap);

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);

        System.assertNotEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testAddCommUserOnAfterInsert()
    {
        String activityType = SageApiActivityTriggerHandler.AddCommunityUserType;

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        SageApiAddCommUserActivityRequest payload = SageApiTestUtils.createAddCommUserPayload(acct.Id);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        Map<ID, SageApiActivity__c> activitiesMap = new Map<ID, SageApiActivity__c>();
        activitiesMap.putAll(activities);
        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterInsert(activities, activitiesMap);

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);

        System.assertNotEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testLeadOnAfterUpdate()
    {
        String activityType = SageApiActivityTriggerHandler.LeadActivityType;
        SageApiTryNowLeadActivityRequest payload = SageApiTestUtils.createTryNowLeadPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> oldActivities = new List<SageApiActivity__c> { activity };
        Map<ID, SageApiActivity__c> oldActivitiesMap = new Map<ID, SageApiActivity__c>();
        oldActivitiesMap.putAll(oldActivities);
        List<SageApiActivity__c> newActivities = new List<SageApiActivity__c> { SageApiTestUtils.cloneActivity(activity) };
        newActivities[0].ActivityStatus__c = SageApiStatus.Restarting;
        Map<ID, SageApiActivity__c> newActivitiesMap = new Map<ID, SageApiActivity__c>();
        newActivitiesMap.putAll(newActivities);

        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterUpdate(oldActivities, oldActivitiesMap, newActivities, newActivitiesMap);

        Test.stopTest();

        newActivities = SageApiActivityUtils.refreshActivities(newActivities);

        System.assertNotEquals( SageApiStatus.Restarting, newActivities[0].ActivityStatus__c );
    }

    @IsTest static void testTryNowOnAfterUpdate()
    {
        String activityType = SageApiActivityTriggerHandler.TryNowActivityType;
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createTryNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> oldActivities = new List<SageApiActivity__c> { activity };
        Map<ID, SageApiActivity__c> oldActivitiesMap = new Map<ID, SageApiActivity__c>();
        oldActivitiesMap.putAll(oldActivities);
        List<SageApiActivity__c> newActivities = new List<SageApiActivity__c> { SageApiTestUtils.cloneActivity(activity) };
        newActivities[0].ActivityStatus__c = SageApiStatus.Restarting;
        Map<ID, SageApiActivity__c> newActivitiesMap = new Map<ID, SageApiActivity__c>();
        newActivitiesMap.putAll(newActivities);

        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterUpdate(oldActivities, oldActivitiesMap, newActivities, newActivitiesMap);

        Test.stopTest();

        newActivities = SageApiActivityUtils.refreshActivities(newActivities);

        System.assertNotEquals( SageApiStatus.Restarting, newActivities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowOnAfterUpdate()
    {
        String activityType = SageApiActivityTriggerHandler.BuyNowActivityType;
        SageApiBuyNowActivityRequest payload = SageApiTestUtils.createBuyNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> oldActivities = new List<SageApiActivity__c> { activity };
        Map<ID, SageApiActivity__c> oldActivitiesMap = new Map<ID, SageApiActivity__c>();
        oldActivitiesMap.putAll(oldActivities);
        List<SageApiActivity__c> newActivities = new List<SageApiActivity__c> { SageApiTestUtils.cloneActivity(activity) };
        newActivities[0].ActivityStatus__c = SageApiStatus.Restarting;
        Map<ID, SageApiActivity__c> newActivitiesMap = new Map<ID, SageApiActivity__c>();
        newActivitiesMap.putAll(newActivities);

        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterUpdate(oldActivities, oldActivitiesMap, newActivities, newActivitiesMap);

        Test.stopTest();

        newActivities = SageApiActivityUtils.refreshActivities(newActivities);

        System.assertNotEquals( SageApiStatus.Restarting, newActivities[0].ActivityStatus__c );
    }

    @IsTest static void testTryNowConvertOnAfterUpdate()
    {
        String activityType = SageApiActivityTriggerHandler.TryNowConvertActivityType;

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test';
        insert quote;

        SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTryNowConvertPayload(acct.Id, quote.Id);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> oldActivities = new List<SageApiActivity__c> { activity };
        Map<ID, SageApiActivity__c> oldActivitiesMap = new Map<ID, SageApiActivity__c>();
        oldActivitiesMap.putAll(oldActivities);
        List<SageApiActivity__c> newActivities = new List<SageApiActivity__c> { SageApiTestUtils.cloneActivity(activity) };
        newActivities[0].ActivityStatus__c = SageApiStatus.Restarting;
        Map<ID, SageApiActivity__c> newActivitiesMap = new Map<ID, SageApiActivity__c>();
        newActivitiesMap.putAll(newActivities);

        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterUpdate(oldActivities, oldActivitiesMap, newActivities, newActivitiesMap);

        Test.stopTest();

        newActivities = SageApiActivityUtils.refreshActivities(newActivities);

        System.assertNotEquals( SageApiStatus.Restarting, newActivities[0].ActivityStatus__c );
    }

    @IsTest static void testAddCommUserOnAfterUpdate()
    {
        String activityType = SageApiActivityTriggerHandler.AddCommunityUserType;

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        SageApiAddCommUserActivityRequest payload = SageApiTestUtils.createAddCommUserPayload(acct.Id);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        insert activity;
        List<SageApiActivity__c> oldActivities = new List<SageApiActivity__c> { activity };
        Map<ID, SageApiActivity__c> oldActivitiesMap = new Map<ID, SageApiActivity__c>();
        oldActivitiesMap.putAll(oldActivities);
        List<SageApiActivity__c> newActivities = new List<SageApiActivity__c> { SageApiTestUtils.cloneActivity(activity) };
        newActivities[0].ActivityStatus__c = SageApiStatus.Restarting;
        Map<ID, SageApiActivity__c> newActivitiesMap = new Map<ID, SageApiActivity__c>();
        newActivitiesMap.putAll(newActivities);

        SageApiActivityTriggerHandler handler = new SageApiActivityTriggerHandler();

        Test.startTest();
        
            handler.onAfterUpdate(oldActivities, oldActivitiesMap, newActivities, newActivitiesMap);

        Test.stopTest();

        newActivities = SageApiActivityUtils.refreshActivities(newActivities);

        System.assertNotEquals( SageApiStatus.Restarting, newActivities[0].ActivityStatus__c );
    }
}