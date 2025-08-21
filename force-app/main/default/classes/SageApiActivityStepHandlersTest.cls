@IsTest(SeeAllData=false)
private class SageApiActivityStepHandlersTest
{
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
        SageApiTestUtils.setupProductCatalog();
    }

    @IsTest static void testCreateSubscriptionValidation()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateSubscriptionValidation handler = new SageApiActivityStepHandlers.CreateSubscriptionValidation();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateAccountValidation()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateAccountValidation handler = new SageApiActivityStepHandlers.CreateAccountValidation();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testUpdateSubscriptionValidation()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.UpdateSubscriptionActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createUpdateSubscriptionPayload('some id');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.UpdateSubscriptionValidation handler = new SageApiActivityStepHandlers.UpdateSubscriptionValidation();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // will fail since wrong id provided
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateOrUpdateAccount()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateOrUpdateAccount handler = new SageApiActivityStepHandlers.CreateOrUpdateAccount();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateOrUpdateContact()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateOrUpdateContact handler = new SageApiActivityStepHandlers.CreateOrUpdateContact();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will fail
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateOrUpdateLead()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateOrUpdateLead handler = new SageApiActivityStepHandlers.CreateOrUpdateLead();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will fail
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testConvertLead()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.ConvertLead handler = new SageApiActivityStepHandlers.ConvertLead();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will fail
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateUser()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateUser handler = new SageApiActivityStepHandlers.CreateUser();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will fail
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateOrUpdateSubscriptionMaster()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.CreateOrUpdateSubscriptionMaster handler = new SageApiActivityStepHandlers.CreateOrUpdateSubscriptionMaster();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will fail
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testUpdateSubscriptionMaster()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityStepHandlers.UpdateSubscriptionMaster handler = new SageApiActivityStepHandlers.UpdateSubscriptionMaster();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();
        
            handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will fail
        System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testSageApiActivityStepBaseInProgress()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };
        SageApiActivityStepHandlers.SageApiActivityStepBase handler = new SageApiActivityStepHandlers.SageApiActivityStepBase();
        handler.step = step;
        handler.activities = activities;
        handler.sessionId = UserInfo.getSessionId();

        Test.startTest();
        
            handler.process();

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        // no preprocessed step, therefore will stay InProgress
        System.assertEquals( SageApiStatus.InProgress, activities[0].ActivityStatus__c );
    }

    @IsTest static void testSageApiActivityStepBaseReachedMaxAttempts()
    {
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };
        SageApiActivityStepHandlers.SageApiActivityStepBase handler = new SageApiActivityStepHandlers.SageApiActivityStepBase();
        handler.step = step;
        handler.activities = activities;
        handler.sessionId = UserInfo.getSessionId();

        Test.startTest();
        
            handler.process();

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(handler.activities);
        // no real processing done, therefore will stay InProgress
        System.assertEquals( SageApiStatus.InProgress, activities[0].ActivityStatus__c );
    }

    @IsTest static void testSageApiActivityStepBaseRequiredStepsNotProcessed()
    {
        SageApiActivityStep step = new SageApiActivityStep(2, 'Step2');
        step.StartAfterCompletedSteps = new List<SageApiActivityStep> {new SageApiActivityStep(1, 'Step1')};
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };
        SageApiActivityStepHandlers.SageApiActivityStepBase handler = new SageApiActivityStepHandlers.SageApiActivityStepBase();
        handler.step = step;
        handler.activities = activities;
        handler.sessionId = UserInfo.getSessionId();

        Test.startTest();
        
            handler.process();

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(handler.activities);
        System.assertEquals( SageApiStatus.InProgress, activities[0].ActivityStatus__c );
    }

    @IsTest static void testSageApiActivityStepBaseRequiredStepsProcessed()
    {
        SageApiActivityStep step = new SageApiActivityStep(2, 'Step2');
        step.StartAfterCompletedSteps = new List<SageApiActivityStep> {new SageApiActivityStep(1, 'Step1')};
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ChannelPlatformProvided__c = 'AppDirect';
        activity.ChannelPartnerProvided__c = 'AppDirect';
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityStep stepCompleted = new SageApiActivityStep(1, 'Step1');
        stepCompleted.OnSuccessGotoSteps = new List<Integer> {2};
        stepCompleted.StepStatus = SageApiStatus.Success;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {stepCompleted});
        insert activity;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };
        SageApiActivityStepHandlers.SageApiActivityStepBase handler = new SageApiActivityStepHandlers.SageApiActivityStepBase();
        handler.step = step;
        handler.activities = activities;
        handler.sessionId = UserInfo.getSessionId();

        Test.startTest();
        
            handler.process();

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(handler.activities);
        System.assertEquals( SageApiStatus.InProgress, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateSubscriptionV2Validation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.CreateSubscriptionV2Validation stepHandler = new SageApiActivityStepHandlers.CreateSubscriptionV2Validation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.InProgressExternal, activities[0].ActivityStatus__c );
    }

    @IsTest static void testDeleteSubscriptionValidation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.DeleteSubscriptionValidation stepHandler = new SageApiActivityStepHandlers.DeleteSubscriptionValidation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testSuspendSubscriptionValidation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.SuspendSubscriptionValidation stepHandler = new SageApiActivityStepHandlers.SuspendSubscriptionValidation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testReactivateSubscriptionValidation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.ReactivateSubscriptionValidation stepHandler = new SageApiActivityStepHandlers.ReactivateSubscriptionValidation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testConvertSubscriptionValidation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.ConvertSubscriptionValidation stepHandler = new SageApiActivityStepHandlers.ConvertSubscriptionValidation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testRegradeSubscriptionValidation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.RegradeSubscriptionValidation stepHandler = new SageApiActivityStepHandlers.RegradeSubscriptionValidation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testUpdateSubscriptionEffectivePeriodValidation()
    {
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.UpdateSubscriptionEffectivePeriodValidation stepHandler = new SageApiActivityStepHandlers.UpdateSubscriptionEffectivePeriodValidation();

        Test.startTest();
        
            stepHandler.process(steps[0], activities, UserInfo.getSessionId());

        Test.stopTest();

        System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateUserV2()
    {
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.CreateUserV2 stepHandler = new SageApiActivityStepHandlers.CreateUserV2();

        Test.startTest();
        
            stepHandler.process(steps[2], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testCreateEntitlementDetail()
    {
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.CreateEntitlementDetail stepHandler = new SageApiActivityStepHandlers.CreateEntitlementDetail();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.InProgress, activities[0].ActivityStatus__c );
    }

    @IsTest static void testDeleteEntitlementDetail()
    {
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.DeleteEntitlementDetail stepHandler = new SageApiActivityStepHandlers.DeleteEntitlementDetail();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testSuspendEntitlementDetail()
    {
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.SuspendEntitlementDetail stepHandler = new SageApiActivityStepHandlers.SuspendEntitlementDetail();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testReactivateEntitlementDetail()
    {
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.ReactivateEntitlementDetail stepHandler = new SageApiActivityStepHandlers.ReactivateEntitlementDetail();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testConvertEntitlementDetail()
    {
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.ConvertEntitlementDetail stepHandler = new SageApiActivityStepHandlers.ConvertEntitlementDetail();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testRegradeEntitlementDetail()
    {
        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageoneaccounting';
        pres1.launchUrl = 'https://test.com/api';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        activity.Payload__c = JSON.serialize(req);
        insert activity;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.RegradeEntitlementDetail stepHandler = new SageApiActivityStepHandlers.RegradeEntitlementDetail();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testUpdateSubscriptionEffectivePeriod()
    {
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        SageApiActivityStepHandlers.UpdateSubscriptionEffectivePeriod stepHandler = new SageApiActivityStepHandlers.UpdateSubscriptionEffectivePeriod();

        Test.startTest();
        
            stepHandler.process(steps[1], activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

}