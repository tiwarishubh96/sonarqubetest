@isTest(SeeAllData=false)
private class SageApiSubsActivityControllerTest {
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
    }
    
    @IsTest static void testCanFulfilSuccess()
    {
        Test.startTest();

	        String event = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanFulfil.name();
	        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
	        String newSubGroupId = GenericUtilities.getRandomUUIDv4();
            SageApiSubscriptionActivityController.ResponseData res = SageApiSubscriptionActivityController.createSubscrptionActivity(event, activity, newSubGroupId);
	        System.assertEquals(SageApiStatus.Success, res.status);
        
        Test.stopTest();
    }

    @IsTest static void testCanFulfilErrors()
    {
        Test.startTest();

	        String event = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanFulfil.name();
	        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
	        String newSubGroupId = GenericUtilities.getRandomUUIDv4();

	        // null activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event, activity1, newSubGroupId);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // invalid activity type
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.ActivityType__c = SageApiActivityTriggerHandler.RegradeSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event, activity2, newSubGroupId);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

	        // no effectivePeriod
	        SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(activity);
			SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity3.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
	        req.effectivePeriod = null;
	        activity3.Payload__c = JSON.serialize(req);
            SageApiSubscriptionActivityController.ResponseData res3 = SageApiSubscriptionActivityController.createSubscrptionActivity(event, activity3, newSubGroupId);
	        System.assertEquals(SageApiStatus.ValidationErrors, res3.status);
        
        Test.stopTest();

    }
	
    @IsTest static void testFulfilSuccess1()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createCreateSubscriptionV2Activity();
	        String newSubGroupId1 = GenericUtilities.getRandomUUIDv4();
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Commit.name();
	        SageApiActivity__c activity2 = res1.activity;
	        String newSubGroupId2 = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.assertEquals(SageApiStatus.Success, res2.status);

        Test.stopTest();
    }
	
    @IsTest static void testFulfilSuccess2()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createCreateSubscriptionV2Activity();
	        String newSubGroupId1 = GenericUtilities.getRandomUUIDv4();
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Commit.name();
	        SageApiActivity__c activity2 = res1.activity;
	        activity2.id = null;
	        String newSubGroupId2 = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.assertEquals(SageApiStatus.Success, res2.status);

        Test.stopTest();
    }
	
    @IsTest static void testFulfilErrors1()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createCreateSubscriptionV2Activity();
	        String newSubGroupId1 = GenericUtilities.getRandomUUIDv4();
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Commit.name();
	        String newSubGroupId2 = null;

	        // invalid activity type
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity2.ActivityType__c = SageApiActivityTriggerHandler.RegradeSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

	        // null activity id - mixed DML exception
	        SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity3.id = null;
	        delete res1.activity;
            SageApiSubscriptionActivityController.ResponseData res3 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity3, newSubGroupId2);
	        System.assertEquals(SageApiStatus.ValidationErrors, res3.status);

        Test.stopTest();
    }

    @IsTest static void testFulfilErrors2()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createCreateSubscriptionV2Activity();
	        String newSubGroupId1 = GenericUtilities.getRandomUUIDv4();
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Commit.name();
	        String newSubGroupId2 = null;

	        // no entitlement data
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(res1.activity);
			SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity2.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
	        req.entitlement = null;
	        activity2.Payload__c = JSON.serialize(req);
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.assertEquals(SageApiStatus.ManualInterventionRequired, res2.status);

        Test.stopTest();
    }

    @IsTest static void testCanRegradeSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanRegrade.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

        Test.stopTest();
    }

    @IsTest static void testCanRegradeErrors()
    {
        Test.startTest();

	        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String event = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanRegrade.name();
	        String newSubGroupId = null;

	        // wrong activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event, activity1, newSubGroupId);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // missing subscription id
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.SubscriptionId__c = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event, activity2, newSubGroupId);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

        Test.stopTest();
    }

    @IsTest static void testRegradeSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Commit.name();
	        String newSubGroupId2 = null;

	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(res1.activity);
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.Success, res2.status);

	        SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity3.Id = null;
            SageApiSubscriptionActivityController.ResponseData res3 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity3, newSubGroupId2);
	        System.debug('res2.message: '+res3.message);
	        System.assertEquals(SageApiStatus.Success, res3.status);

        Test.stopTest();
    }

    @IsTest static void testRegradeErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Commit.name();
	        String newSubGroupId2 = null;

	        // wrong activity type
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity2.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

	        // invalid activity id
	        SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity3.id = null;
	        activity3.ActivityID__c = 'invalid';
            SageApiSubscriptionActivityController.ResponseData res3 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity3, newSubGroupId2);
	        System.debug('res3.message: '+res3.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res3.status);

	        // invalid subscription id
	        SageApiActivity__c activity4 = SageApiTestUtils.cloneActivity(res1.activity);
			activity4.SubscriptionId__c = null;
            SageApiSubscriptionActivityController.ResponseData res4 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity4, newSubGroupId2);
	        System.debug('res4.message: '+res4.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res4.status);

	        // no entitlement data
	        SageApiActivity__c activity5 = SageApiTestUtils.cloneActivity(res1.activity);
			SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity2.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
	        req.isTrial = null;
	        activity5.Payload__c = JSON.serialize(req);
            SageApiSubscriptionActivityController.ResponseData res5 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity5, newSubGroupId2);
	        System.assertEquals(SageApiStatus.ManualInterventionRequired, res5.status);

        Test.stopTest();
    }

    @IsTest static void testConvertSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Converted.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createConvertSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

        Test.stopTest();
    }

    @IsTest static void testConvertErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Converted.name();
	        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
	        String newSubGroupId1 = null;

	        // wrong activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // invalid payload
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.Payload__c = '{';
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity2, newSubGroupId1);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

        Test.stopTest();
    }

    @IsTest static void testSuspendSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Suspended.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createSuspendSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

        Test.stopTest();
    }

    @IsTest static void testSuspendErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Suspended.name();
	        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
	        String newSubGroupId1 = null;

	        // wrong activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // invalid subscription id
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.SubscriptionId__c = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity2, newSubGroupId1);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

        Test.stopTest();
    }

    @IsTest static void testReactivateSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Reactivated.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createReactivateSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

        Test.stopTest();
    }

    @IsTest static void testReactivateErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Reactivated.name();
	        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
	        String newSubGroupId1 = null;

	        // wrong activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // invalid subscription id
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.SubscriptionId__c = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity2, newSubGroupId1);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

        Test.stopTest();
    }

    @IsTest static void testDeleteSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Deleted.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createDeleteSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

        Test.stopTest();
    }

    @IsTest static void testDeleteErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Deleted.name();
	        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
	        String newSubGroupId1 = null;

	        // wrong activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // invalid subscription id
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.SubscriptionId__c = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity2, newSubGroupId1);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

        Test.stopTest();
    }

    @IsTest static void testUpdateEffectivePeriodSuccess()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_EffectivePeriodUpdated.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.assertEquals(SageApiStatus.Success, res1.status);

        Test.stopTest();
    }

    @IsTest static void testUpdateEffectivePeriodErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_EffectivePeriodUpdated.name();
	        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
	        String newSubGroupId1 = null;

	        // wrong activity type
	        SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
	        activity1.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res1.status);

	        // invalid payload
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
	        activity2.Payload__c = '{';
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity2, newSubGroupId1);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

        Test.stopTest();
    }

    @IsTest static void testAbandonSuccess1()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Rollback.name();
	        SageApiActivity__c activity2 = res1.activity;
	        String newSubGroupId2 = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.Success, res2.status);
	        System.assertEquals(SageApiStatus.Abandoned, res2.activity.ActivityStatus__c);

        Test.stopTest();
    }

    @IsTest static void testAbandonSuccess2()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Rollback.name();
	        SageApiActivity__c activity2 = res1.activity;
	        String newSubGroupId2 = null;
	        activity2.id = null;
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.Success, res2.status);
	        System.assertEquals(SageApiStatus.Abandoned, res2.activity.ActivityStatus__c);

        Test.stopTest();
    }

    @IsTest static void testAbandonErrors()
    {
        Test.startTest();

	        String event1 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name();
	        SageApiActivity__c activity1 = SageApiTestUtils.createRegradeSubscriptionActivity();
	        String newSubGroupId1 = null;
            SageApiSubscriptionActivityController.ResponseData res1 = SageApiSubscriptionActivityController.createSubscrptionActivity(event1, activity1, newSubGroupId1);
	        System.debug('res1.message: '+res1.message);
	        System.assertEquals(SageApiStatus.Success, res1.status);

	        // invalid activity id
	        String event2 = SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Rollback.name();
	        SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(res1.activity);
	        String newSubGroupId2 = null;
	        activity2.id = null;
	        activity2.ActivityID__c = 'Invalid';
            SageApiSubscriptionActivityController.ResponseData res2 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity2, newSubGroupId2);
	        System.debug('res2.message: '+res2.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res2.status);

	        // invalid activity type
	        SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity3.ActivityType__c = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
            SageApiSubscriptionActivityController.ResponseData res3 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity3, newSubGroupId2);
	        System.debug('res3.message: '+res3.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res3.status);

	        // cannot override success one
	        SageApiActivity__c activity4 = SageApiTestUtils.cloneActivity(res1.activity);
	        activity4.ActivityStatus__c = SageApiStatus.Success;
            SageApiSubscriptionActivityController.ResponseData res4 = SageApiSubscriptionActivityController.createSubscrptionActivity(event2, activity4, newSubGroupId2);
	        System.debug('res4.message: '+res4.message);
	        System.assertEquals(SageApiStatus.ValidationErrors, res4.status);

        Test.stopTest();
    }

}