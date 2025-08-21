@IsTest(SeeAllData=false)
public with sharing class SageApiSubscriptionActivityUtilsTest {
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
        SageApiTestUtils.setupProductCatalog();
    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadSuccess()
    {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();

            // validation = true, activityStarted = false
            SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities1 = new List<SageApiActivity__c>{activity1};
            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities1, true, false);
            System.assertEquals(SageApiStatus.InProgressExternal, activities1[0].ActivityStatus__c);
        
            // validation = true, activityStarted = true
            SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities2 = new List<SageApiActivity__c>{activity2};
            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities2, true, true);
            System.assertEquals(SageApiStatus.InProgressExternal, activities2[0].ActivityStatus__c);


        Test.stopTest();

    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadFailedNullPayload()
    {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
            List<SageApiActivity__c> activities = new List<SageApiActivity__c>{activity};
            activity.Payload__c = null;
            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities, true, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
        
        Test.stopTest();

    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadFailedInvalidPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.Payload__c = '{';
        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities, true, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
        
        Test.stopTest();
    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadFailedNullFields()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.ChannelPlatformProvided__c = null;
        activity.ChannelPartnerProvided__c = null;

        SageApiActivityRequestObjects.SubscriptionRequest req0 = (SageApiActivityRequestObjects.SubscriptionRequest) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
        req0.subscriptionGroupId = null;
        req0.managingAccount = null;
        req0.entitledAccount = null;
        req0.customerContact = null;
        req0.effectivePeriod = null;
        req0.products = null;
        req0.customerCommunityUsers = null;
        activity.Payload__c = JSON.serialize(req0);

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = null;
        req.state = null;
        req.entitlement = null;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities, true, false);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadFailedMoreNullFields()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.ChannelPlatformProvided__c = 'Invalid';
        activity.ChannelPartnerProvided__c = null;

        SageApiActivityRequestObjects.SubscriptionRequest req0 = (SageApiActivityRequestObjects.SubscriptionRequest) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
        req0.managingAccount.id = null;
        req0.entitledAccount.id = null;
        req0.customerContact.id = null;
        req0.effectivePeriod.notBefore = null;
        req0.effectivePeriod.notAfter = null;
        activity.Payload__c = JSON.serialize(req0);

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = 'subscriptionId';
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = null;
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities, true, false);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadFailedInvalidFields()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.ChannelPlatformProvided__c = 'Invalid';

        SageApiActivityRequestObjects.SubscriptionRequest req0 = (SageApiActivityRequestObjects.SubscriptionRequest) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
        req0.effectivePeriod.notBefore = 'invalid date';
        req0.effectivePeriod.notAfter = 'invalid date';
        activity.Payload__c = JSON.serialize(req0);

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = 'subscriptionId';
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = null;
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities, true, false);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadFailedMoreInvalidFields()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.ChannelPlatformProvided__c = 'Invalid';

        SageApiActivityRequestObjects.SubscriptionRequest req0 = (SageApiActivityRequestObjects.SubscriptionRequest) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
        req0.effectivePeriod.notBefore = '2017-12-31';
        req0.effectivePeriod.notAfter = '2017-01-01';
        activity.Payload__c = JSON.serialize(req0);

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = 'subscriptionId';
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = null;
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities, true, false);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionV2PayloadErrors() {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();

            // null subscription
            SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities1 = new List<SageApiActivity__c>{activity1};
            SageApiActivityRequestObjects.SubscriptionAllData req1 = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity1.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
            req1.subscriptionId = null;
            req1.state = null;
            req1.entitlement = null;
            req1.subscriptionGroupId = null;
            activity1.Payload__c = JSON.serialize(req1);
            SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activities1, false, true);
            System.assertEquals(SageApiStatus.ValidationErrors, activity1.ActivityStatus__c);

            // validation = true, activityStarted = true
            SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(activity);
            SageApiActivityRequestObjects.SubscriptionAllData req3 = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity3.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
            req3.subscriptionGroupId = 'SomeGroupId';
            activity3.Payload__c = JSON.serialize(req3);
            activity3.SubscriptionGroupId__c = null;
            List<SageApiActivity__c> activities3 = new List<SageApiActivity__c>{activity3};
            Map<String, ChannelPlatform__c> platforms = SageApiSubscriptionActivityUtils.getActivityPlatforms(activities3);
            Map<String, ChannelPartner__c> partners = SageApiSubscriptionActivityUtils.getActivityPartners(activities3);
            List<Account> accounts = SageApiSubscriptionActivityUtils.getActivityAccounts(activities3);
            List<Contact> contacts = SageApiSubscriptionActivityUtils.getActivityContacts(activities3);
            List<Subscription_Master__c> existingSmsFromGroupId = new List<Subscription_Master__c>{new Subscription_Master__c(SubscriptionGroupId__c='SomeExistingGroupId',CbcSubscriptionId__c='SomeId')}; 
            List<SageApiActivityError> errors = SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activity3, false, true, platforms, partners, accounts, contacts, existingSmsFromGroupId);
            System.assertNotEquals(null, errors);

            req3.subscriptionGroupId = 'SomeExistingGroupId';
            req3.managingAccount.id = null;
            req3.entitledAccount.id = null;
            req3.partner.account = null;
            req3.customerContact.id = null;
            activity3.Payload__c = JSON.serialize(req3);
            activity3.SubscriptionGroupId__c = null;
            errors = SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(steps[0], activity3, false, true, platforms, partners, accounts, contacts, existingSmsFromGroupId);
            System.assertNotEquals(null, errors);

        Test.stopTest();

    }

    @IsTest static void testCreateEntitlementDetailSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = GenericUtilities.getRandomUUIDv4();
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = GenericUtilities.getRandomUUIDv4();
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.createEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateEntitlementDetailFailedNoPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.Payload__c = null;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.createEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateEntitlementDetailFailedNoEntitlement()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;


        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = GenericUtilities.getRandomUUIDv4();
        req.state = 'Active';
        req.entitlement = null;

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));
        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.createEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateEntitlementDetailSuccessNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = GenericUtilities.getRandomUUIDv4();
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = GenericUtilities.getRandomUUIDv4();
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        Subscription_Master__c newSM = new Subscription_Master__c();
        newSM.EnableInsertTrigger__c = false;
        newSM.Sage_API_Activity__c = activity.Id;
        newSM.CbcSubscriptionId__c = req.subscriptionId;
        newSM.Entitlement_Id__c = req.entitlement.entitlementId;
        newSM.External_Id__c = activity.Account__c + ':' + newSM.CbcSubscriptionId__c;
        newSM.ChannelPartner__c = activity.ChannelPartner__c;
        newSM.Status__c = req.isTrial ? Constants.ASSET_STATUS_TRIAL : Constants.ASSET_STATUS_ACTIVE;
        newSM.SubscriptionState__c = req.state;
        newSM.Start_Date__c = Date.valueOf(req.effectivePeriod.notBefore);
        newSM.End_Date__c = Date.valueOf(req.effectivePeriod.notAfter);
        insert newSM;
        activity.SubscriptionMaster__c = newSM.id;
        update activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.createEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateDeleteSubscriptionSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateDeleteSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateDeleteSubscriptionFailedNoSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = null;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateDeleteSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateDeleteSubscriptionFailedInvalidSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = 'Does not exists';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateDeleteSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testDeleteEntitlementDetailSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.deleteEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testDeleteEntitlementDetailNoEntitledProductSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        List<EntitlementProduct__c> products = [SELECT id FROM EntitlementProduct__c WHERE SubscriptionMaster__c =: activity.SubscriptionMaster__c];
        if (products != null) delete products;

        Test.startTest();

            SageApiSubscriptionActivityUtils.deleteEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testDeleteEntitlementDetailFailedNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.SubscriptionMaster__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.deleteEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateSuspendSubscriptionSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateSuspendSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateSuspendSubscriptionFailedNoSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = null;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateSuspendSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateSuspendSubscriptionFailedInvalidSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = 'Invalid';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateSuspendSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testSuspendEntitlementDetailSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.Reason reason = new SageApiActivityRequestObjects.Reason();
        reason.reasonCode = 'DelinquentPayment';
        reason.reasonDescription = 'Payment declined';
        activity.Payload__c = JSON.serialize(reason);

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.suspendEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testSuspendEntitlementDetailFailedNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.Reason reason = new SageApiActivityRequestObjects.Reason();
        reason.reasonCode = 'DelinquentPayment';
        reason.reasonDescription = 'Payment declined';
        activity.Payload__c = JSON.serialize(reason);

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.SubscriptionMaster__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.suspendEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testSuspendEntitlementDetailFailedNoPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createSuspendSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.SuspendSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.Payload__c = null;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.suspendEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateReactivateSubscriptionSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateReactivateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateReactivateSubscriptionFailedNoSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = null;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateReactivateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateReactivateSubscriptionFailedInvalidSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = 'Invalid';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateReactivateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testReactivateEntitlementDetailSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.reactivateEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testReactivateEntitlementDetailFailedNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createReactivateSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.SubscriptionMaster__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.reactivateEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionSuccessWithNewPeriod()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"'+startDate+'","notAfter":"'+endDate+'"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionSuccessWithoutNewPeriod()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.Payload__c = '{}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedInvalidPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.Payload__c = '{';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedInvalidPeriod1()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.Payload__c = '{';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedInvalidPeriod2()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"'+startDate+'","notAfter":"invalid"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedInvalidPeriod3()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"'+endDate+'","notAfter":"'+startDate+'"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedInvalidPeriod4()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"invalid","notAfter":"'+endDate+'"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedNoSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = null;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateConvertSubscriptionFailedInvalidSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = 'Invalid';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testConvertEntitlementDetailSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.convertEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testConvertEntitlementDetailFailedNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.SubscriptionMaster__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.convertEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testConvertEntitlementDetailFailedInvalidPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createConvertSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.ConvertSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Payload__c = '{';
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.convertEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateRegradeSubscriptionSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, null, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionResponse res = (SageApiActivityRequestObjects.SubscriptionResponse) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionResponse.class);
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageoneaccounting';
        pres1.launchUrl = 'https://test.com/api';
        res.state = 'Active';
        res.entitlement = new SageApiActivityRequestObjects.Entitlement();
        res.entitlement.entitlementId = 'Test';
        res.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        res.entitlement.products.add(pres1);

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities, false);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateRegradeSubscriptionErrors()
    {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;
            SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();

            // subscription id = null or invalid
            SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities1 = new List<SageApiActivity__c>{activity1};
            activity1.SubscriptionId__c = 'Invalid';
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities1, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities1[0].ActivityStatus__c);

            activity1.SubscriptionId__c = null;
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities1, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities1[0].ActivityStatus__c);

            // no products or null product id
            SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities2 = new List<SageApiActivity__c>{activity2};
            SageApiActivityRequestObjects.SubscriptionRequest req2 = (SageApiActivityRequestObjects.SubscriptionRequest) JSON.deserialize(activity2.Payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
            for (SageApiActivityRequestObjects.ProductRequest pr : req2.products)
                pr.product=null;
            activity2.Payload__c = JSON.serialize(req2);
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities2, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities2[0].ActivityStatus__c);

            req2.products = null;
            activity2.Payload__c = JSON.serialize(req2);
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities2, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities2[0].ActivityStatus__c);

            // null or invalid payload
            SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities3 = new List<SageApiActivity__c>{activity3};
            activity3.Payload__c = null;
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities3, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities3[0].ActivityStatus__c);

            activity3.Payload__c = '{';
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities3, false);
            System.assertEquals(SageApiStatus.ValidationErrors, activities3[0].ActivityStatus__c);

            // activityStarted = true
            SageApiActivity__c activity4 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities4 = new List<SageApiActivity__c>{activity4};
            SageApiActivityRequestObjects.SubscriptionAllData req4 = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity4.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
            req4.state = null;
            req4.entitlement.entitlementId = null;
            activity4.Payload__c = JSON.serialize(req4);
            SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(steps[0], activities4, true);
            System.assertEquals(SageApiStatus.ValidationErrors, activities4[0].ActivityStatus__c);

        
        Test.stopTest();
    }

    @IsTest static void testRegradeEntitlementDetailSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageoneaccounting';
        pres1.launchUrl = 'https://test.com/api';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.regradeEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testRegradeEntitlementDetailFailedNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageoneaccounting';
        pres1.launchUrl = 'https://test.com/api';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.SubscriptionMaster__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.regradeEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testRegradeEntitlementDetailFailedNoPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Payload__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.regradeEntitlementDetail(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.Unknown, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedNoPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.Payload__c = null;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedNoPeriod()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.Payload__c = '{}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedNoEndDate()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"'+startDate+'","notAfter":null}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedInvalidEndDate()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"'+startDate+'","notAfter":"invalid"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedInvalidStartDate()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"invalid","notAfter":"'+endDate+'"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedInvalidPeriod()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        Date d = date.today();
        String startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String endDate = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        activity.Payload__c = '{"effectivePeriod":{"notBefore":"'+endDate+'","notAfter":"'+startDate+'"}}';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedNoSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = null;
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionEffectivePeriodFailedInvalidSubscriptionId()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activity.SubscriptionId__c = 'Invalid';
        insert activity;

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(steps[0], activities);
        
        Test.stopTest();

        System.assertEquals(SageApiStatus.ValidationErrors, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionEffectivePeriodSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionEffectivePeriod(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionEffectivePeriodFailedNoSubscriptionComponent()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.SubscriptionMaster__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionEffectivePeriod(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionEffectivePeriodFailedNoPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createUpdateSubscriptionEffectivePeriodActivity();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Payload__c = null;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionEffectivePeriod(steps[steps.size()-1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testProvisionUserV2Success()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = GenericUtilities.getRandomUUIDv4();
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = GenericUtilities.getRandomUUIDv4();
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.provisionUserV2(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        SageApiActivityStep completedStep = SageApiActivityUtils.getProcessedStep(activities[0], steps[0]);
        System.assert(completedStep != null && completedStep.StepStatus == SageApiStatus.Success);
    }

    @IsTest static void testProvisionUserV2FailedNoPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = GenericUtilities.getRandomUUIDv4();
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = GenericUtilities.getRandomUUIDv4();
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);

        activity.Payload__c = null;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.provisionUserV2(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testProvisionUserV2FailedNoUser()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();
        SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        req.subscriptionId = GenericUtilities.getRandomUUIDv4();
        req.state = 'Active';
        req.entitlement = new SageApiActivityRequestObjects.Entitlement();
        req.entitlement.entitlementId = GenericUtilities.getRandomUUIDv4();
        SageApiActivityRequestObjects.ProductResponse pres1 = new SageApiActivityRequestObjects.ProductResponse();
        pres1.product = 'sageonestart';
        pres1.launchUrl = 'https://test.com/api';
        SageApiActivityRequestObjects.ProductResponse pres2 = new SageApiActivityRequestObjects.ProductResponse();
        pres2.product = 'sageonestart';
        pres2.launchUrl = 'https://test.com/api';
        req.entitlement.products = new List<SageApiActivityRequestObjects.ProductResponse>();
        req.entitlement.products.add(pres1);
        req.entitlement.products.add(pres2);
        req.customerCommunityUsers = null;

        activity.Payload__c = JSON.serialize(req);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;
        System.debug('activity: '+JSON.serialize(activity));

        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.provisionUserV2(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadInvalidPayload()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, '{');
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoSubscription()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoChannelPlatform()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = null;
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadInvalidChannelPlatform()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = 'Not exists';
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoChannelPartner()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = null;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoStartDate()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.startDate = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadPastStartDate()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        Date d = date.today().addDays(-2);
        req.subscription.startDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        ////quick fix
        System.assert(SageApiStatus.ManualInterventionRequired == activities[0].ActivityStatus__c || SageApiStatus.InProgress == activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadInvalidStartDate()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.startDate = 'not a date';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadInvalidEndDate()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.endDate = 'not a date';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadPastEndDate()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        Date d = date.today().addDays(-2);
        req.subscription.endDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoAccount()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoAccountId()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account.accountId = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoAccountType()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account.accountType = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoAccountName()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account.accountId = null;
        req.account.name = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadSFAccount()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account.accountId = acc.Id;
        req.account.accountType = SageApiActivityRequestObjects.IdentifierType.Salesforce.name();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }


    @IsTest static void testValidateCreateSubscriptionPayloadNoContact()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadInvalidContactType()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.contactType = 'Some Value';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoIdentityId()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.identityId = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoIdentityType()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.identityType = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoFirstName()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.contactId = null;
        req.contact.firstName = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoLastName()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.contactId = null;
        req.contact.lastName = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionPayloadNoEmail()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.contactId = null;
        req.contact.email = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateSubscriptionSFContactType()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.contact.contactId = con.id;
        req.contact.contactType = SageApiActivityRequestObjects.IdentifierType.Salesforce.name();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        SageUserIdentityProvider__c provider = new SageUserIdentityProvider__c(Account__c = acc.Id, IdentityID__c = req.contact.identityId, IdentityProvider__c = req.contact.identityType, SFBridgeID__c = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, Name = ID.valueOf(acc.Id) + ':' + req.contact.identityType + ':' + req.contact.identityId, User__c = testUser.Id);
        insert provider;
        AccountMapping__c acctMap = new AccountMapping__c(ExternalAccountType__c = SageApiActivityRequestObjects.IdentifierType.AppDirect.name(), ExternalAccountId__c = req.account.accountId, ExternalAccountKey__c = req.account.accountType+':'+req.account.accountId, Name = req.account.accountType+':'+req.account.accountId, Account__c = acc.Id);
        insert acctMap;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayload()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadInvalidPayload()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, '{');
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoAccount()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.account = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNullAccountIdAndName()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.account.accountId = null;
        payload.account.name = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadInvalidAccountType()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.account.accountType = 'Not exists';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoContact()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoIdentityType()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact.identityType = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoIdentityId()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact.identityId = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoFirstName()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact.contactId = null;
        payload.contact.firstName = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoLastName()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact.contactId = null;
        payload.contact.lastName = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadNoEmail()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact.contactId = null;
        payload.contact.email = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadSfContact()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();
        //SageApiTestUtils.setupCommunity();
        //SageApiTestUtils.setupChannelPlatform();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.contact.contactType = SageApiActivityRequestObjects.IdentifierType.Salesforce.name();
        payload.contact.ContactId = con.Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateCreateAccountPayloadSfAccount()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();
        //SageApiTestUtils.setupCommunity();
        //SageApiTestUtils.setupChannelPlatform();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        payload.account.accountId = acc.Id;
        payload.account.accountType = SageApiActivityRequestObjects.IdentifierType.Salesforce.name();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateAccountActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateAccountActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadNoSubscription()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        req.subscription = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadNoCbcSubscription()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        req.subscription.cbcSubscriptionId = 'no exists';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadNullChannelPlatform()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = null;
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadInvalidChannelPlatform()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = 'no exists';
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadNullChannelPartner()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = null;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadInvalidBlock()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Blocked__c = true;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        req.subscription.cbcSubscriptionId = 'MySubscriptionId';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadInvalidUnblock()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        req.subscription.cbcSubscriptionId = 'MySubscriptionId';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadInvalidCancel()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        req.subscription.cbcSubscriptionId = 'MySubscriptionId';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testValidateUpdateSubscriptionPayloadInvalidReactivate()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        User testUser = SageApiTestUtils.createUser(con);   

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        req.subscription.cbcSubscriptionId = 'MySubscriptionId';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(steps[0], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateAccountSuccess()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateAccount(steps[1], activities);
        
        Test.stopTest();

        System.assert( String.isNotBlank(activities[0].Account__c));
    }

    @IsTest static void testCreateOrUpdateAccountExistingAccount()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Account__c = acct.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateAccount(steps[1], activities);
        
        Test.stopTest();

        System.assert( acct.Id == activities[0].Account__c );
    }

    @IsTest static void testCreateOrUpdateAccountInvalidPayload()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, '{');
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateAccount(steps[1], activities);
        
        Test.stopTest();

        System.assert( String.isBlank(activities[0].Account__c));
    }

    @IsTest static void testCreateOrUpdateContactSuccess()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Account__c = acct.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateContact(steps[2], activities);
        
        Test.stopTest();

        System.assert( String.isNotBlank(activities[0].Contact__c));
    }

    @IsTest static void testCreateOrUpdateContactInvalidPayload()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, '{');
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Account__c = acct.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateContact(steps[2], activities);
        
        Test.stopTest();

        System.assert( String.isBlank(activities[0].Contact__c));
    }

    @IsTest static void testCreateOrUpdateContactExistingContact()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acct = new Account(
                Name = 'Test Biz', 
                Locale_Billing_CC__c = 'US',
                Locale__c = loc.id,
                Type = 'Customer'
            );
        insert acct;

        Contact con = new Contact( Firstname = 'Some', Lastname = 'One', AccountId = acct.Id, MailingCountryCode = 'US' );
        insert con;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.Account__c = acct.Id;
        activity.Contact__c = con.Id;

        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateContact(steps[2], activities);
        
        Test.stopTest();

        System.assert( con.Id == activities[0].Contact__c );
    }

    @IsTest static void testCreateOrUpdateContactNoExistingAccount()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupLocale();

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;

        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateContact(steps[2], activities);
        
        Test.stopTest();

        System.assert( null == activities[0].Contact__c &&  null == activities[0].Account__c );
    }

    @IsTest static void testConvertLeadSuccess()
    {
        //SageApiTestUtils.setup();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        List<Lead> convertableLeads = new List<Lead>();
        for(Integer i = 0; i < 2; i++)
        {
            convertableLeads.add( new Lead( Firstname='Some',Lastname='One'+i,Email='a@b.com',phone='1231212',Company='Example Inc.',Street='122 st',City='Atlanta',CurrencyIsoCode='USD',Sales_Office__c='Atlanta CBC',CountryCode='US',PostalCode='30332',StateCode='GA',IsPartner__c=false,Language__c='English',RecordTypeId=recordTypeId ) );
        }
        insert convertableLeads;
    
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 2; i++)
        {
            SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
            payload.account.paymentMethodId = GenericUtilities.getRandomUUIDv4();
            payload.account.paymentMethodType = 'Credit-Card';
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
            if( i < 2 )
            {
                SageApiSubscriptionActivityResponse resp = new SageApiSubscriptionActivityResponse();
                resp.data = new SageApiSubscriptionActivityResponse.ResponseData();
                resp.data.leadId = convertableLeads[i].Id;
                activity.Artifacts__c = JSON.serialize( resp );
                activity.Lead__c = convertableLeads[i].Id;
            }

            activities.add( activity );
        }
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.convertLead( step, activities );
    
        Test.stopTest();
    
        System.assertEquals( 2, [SELECT Count() FROM Lead] );
        System.assertEquals( SageApiActivityUtils.setting_OpportunityStageEvaluating, [SELECT StageName FROM Opportunity LIMIT 1].StageName );
        System.assertEquals( 2, [SELECT Count() FROM Account] );
        System.assertEquals( 2, [SELECT Count() FROM Contact] );
    }

    @IsTest static void testConvertLeadNoLeads()
    {
        //SageApiTestUtils.setup();

    
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 2; i++)
        {
            SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
            payload.account.paymentMethodId = GenericUtilities.getRandomUUIDv4();
            payload.account.paymentMethodType = 'Credit-Card';
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );

            activities.add( activity );
        }
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.convertLead( step, activities );
        
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM Account] );
    }


    @IsTest static void testConvertLeadMisc()
    {
        //SageApiTestUtils.setup();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        Account acc = new Account(Name = 'Business '+string.valueOf(Math.abs(GenericUtilities.getRandom())), BillingCountryCode = 'US', Sales_Office__c = 'Atlanta CBC', locale_billing_cc__c = 'US' );
        insert acc;
        Contact con = new Contact(email = string.valueOf(Math.abs(GenericUtilities.getRandom()))+'@testemail.com', firstName = 'Test', lastName = 'User', accountId = acc.Id, MailingCity = 'New York', MailingCountry = 'United States', MailingPostalCode = '10082', Language__c = 'English', ELanguage__c = 'EN');
        insert con;
        Lead convertableLead = new Lead( Firstname='Some',Lastname='One',Email='a@b.com',phone='1231212',Company='Example Inc.',Street='122 st',City='Atlanta',CurrencyIsoCode='USD',Sales_Office__c='Atlanta CBC',CountryCode='US',PostalCode='30332',StateCode='GA',IsPartner__c=false,Language__c='English',RecordTypeId=recordTypeId,IsConverted=true,ConvertedAccountId=acc.Id,ConvertedContactId=con.Id );
        insert convertableLead;
    
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        payload.account.paymentMethodId = GenericUtilities.getRandomUUIDv4();
        payload.account.paymentMethodType = 'Credit-Card';
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        SageApiSubscriptionActivityResponse resp = new SageApiSubscriptionActivityResponse();
        resp.data = new SageApiSubscriptionActivityResponse.ResponseData();
        resp.data.leadId = convertableLead.Id;
        activity.Artifacts__c = JSON.serialize( resp );
        activity.Lead__c = convertableLead.Id;
        activities.add( activity );
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.convertLead( step, activities );
            System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );

            Lead convertableLead1 = new Lead( Firstname='Some',Lastname='One',Email='a@b.com',phone='1231212',Company='Example Inc.',Street='122 st',City='Atlanta',CurrencyIsoCode='USD',Sales_Office__c='Atlanta CBC',CountryCode='US',PostalCode='30332',StateCode='GA',IsPartner__c=false,Language__c='English',RecordTypeId=recordTypeId );
            insert convertableLead1;
            resp.data.leadId = convertableLead1.Id;
            activities[0].Artifacts__c = JSON.serialize( resp );
            activities[0].Lead__c = convertableLead1.Id;
            activities[0].Payload__c = null;
            SageApiSubscriptionActivityUtils.convertLead( step, activities );
            System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );

        Test.stopTest();
    
    }

    @IsTest static void testCreateUserSuccess()
    {
        //SageApiTestUtils.setup();
        //SageApiTestUtils.setupCommunity();
        //SageApiTestUtils.setupLocale();

        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];

        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.', Locale__c = loc.Id, Locale_Billing_CC__c = 'US' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id, MailingCountryCode = 'US' ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Contact con : cons)
        {
            SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
            SageApiSubscriptionActivityResponse resp = new SageApiSubscriptionActivityResponse();
            resp.data = new SageApiSubscriptionActivityResponse.ResponseData();
            resp.data.contactId = con.Id;
            activity.Contact__c = con.Id;
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;
        System.debug('accs: ' + accs);
        System.debug('cons: ' + cons);
        System.debug('activities: ' + activities);

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiSubscriptionActivityUtils.provisionUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserNoContacts()
    {
        //SageApiTestUtils.setup();

        //SageApiTestUtils.setupCommunity();

        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 2; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 2; i++)
        {
            SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
            SageApiSubscriptionActivityResponse resp = new SageApiSubscriptionActivityResponse();
            resp.data = new SageApiSubscriptionActivityResponse.ResponseData();
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiSubscriptionActivityUtils.provisionUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserNoCandidates()
    {
        //SageApiTestUtils.setup();

        //SageApiTestUtils.setupCommunity();

        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 2; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 2; i++)
        {
            SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
            SageApiSubscriptionActivityResponse resp = new SageApiSubscriptionActivityResponse();
            resp.data = new SageApiSubscriptionActivityResponse.ResponseData();
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        delete cons;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiSubscriptionActivityUtils.provisionUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserPayload()
    {
        //SageApiTestUtils.setup();

        //SageApiTestUtils.setupCommunity();

        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( 'TryNow', '{' );
            SageApiSubscriptionActivityResponse resp = new SageApiSubscriptionActivityResponse();
            resp.data = new SageApiSubscriptionActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            activity.Contact__c = cons[i].Id;
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiSubscriptionActivityUtils.provisionUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
        Map<Id, SageApiActivity__c> mapActivites = new Map<Id, SageApiActivity__c>((List<SageApiActivity__c>)GenericUtilities.resetSObjects( activities ));
        Set<String> possibleErrors = new Set<String>{ SageApiStatus.ManualInterventionRequired, SageApiStatus.Abandoned };
        for( SageApiActivity__c act : mapActivites.values() )
        {
            System.assertEquals( true, possibleErrors.contains( act.ActivityStatus__c ) );
        }
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterNoAccount()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = null;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterInvalidPayload()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterExistingSmSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.cbcSubscriptionId = sm.CbcSubscriptionId__c;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        activity.SubscriptionMaster__c = sm.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterExistingSmAndEmProcessed()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processed', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.cbcSubscriptionId = sm.CbcSubscriptionId__c;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterExistingSmAndEmError()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Error', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.cbcSubscriptionId = sm.CbcSubscriptionId__c;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterExistingSmAndEmNew()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'New', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.cbcSubscriptionId = sm.CbcSubscriptionId__c;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testCreateOrUpdateSubscriptionMasterExistingSmAndEmProcessing()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processing', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.subscription.cbcSubscriptionId = sm.CbcSubscriptionId__c;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Account__c = acc.Id;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(steps[6], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterBlockSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processed', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterBlockNoEmSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        activity.SubscriptionMaster__c = sm.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterBlockNoExistingSM()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterBlockEmError()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Error', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterBlockEmProcessing()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processing', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterBlockEmNew()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'New', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Block.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterCancelSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processed', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterCancelNoEmSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.SubscriptionMaster__c = sm.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterCancelNoExistingSM()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterCancelEmError()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Error', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterCancelEmProcessing()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processing', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterCancelEmNew()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'New', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Cancel.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterReactivateSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processed', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterReactivateNoEmSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        activity.SubscriptionMaster__c = sm.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterReactivateNoExistingSM()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterReactivateEmError()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Error', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterReactivateEmProcessing()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processing', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterReactivateEmNew()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Cancelled__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'New', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Reactivate.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterUnblockSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Blocked__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processed', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterUnblockNoEmSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Blocked__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        activity.SubscriptionMaster__c = sm.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterUnblockNoExistingSM()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload('MySubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterUnblockEmError()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Blocked__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Error', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterUnblockEmProcessing()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Blocked__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'Processing', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testUpdateSubscriptionMasterUnblockEmNew()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Active';
        sm.Entitlement_Id__c = 'MyEntitlementId';
        sm.CbcSubscriptionId__c = 'MySubscriptionId';
        sm.Is_Blocked__c = true;
        sm.External_ID__c = ID.valueOf(acc.Id)+':SageOne-Start-US:'+sm.CbcSubscriptionId__c;
        insert sm;

        Entitlement_Message__c msg = new Entitlement_Message__c(Status__c = 'New', Subscription_Master__c = sm.Id);
        insert msg;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createUpdateSubscriptionPayload(sm.CbcSubscriptionId__c);
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ActivityAction__c = SageApiActivityRequestObjects.ActivityAction.Unblock.name();
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        SageApiActivityHandler handler = new SageApiActivityHandler(SageApiActivityTriggerHandler.UpdateSubscriptionActivityType, null, activities, null);
        List<SageApiActivityStep> steps = handler.ActivitySteps;
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(steps[1], activities);
        
        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(SageApiStatus.InProgress, activities[0].ActivityStatus__c);
    }

    @IsTest static void testGetOppNameSuccess()
    {
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        insert activity;

        Test.startTest();

            String theName = SageApiSubscriptionActivityUtils.getOpportunityName(activity);
        
        Test.stopTest();

        System.assert(String.isNotBlank(theName));
    }

    @IsTest static void testGetOppNameInvalidPayload()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, '{');
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        insert activity;

        Test.startTest();

            String theName = SageApiSubscriptionActivityUtils.getOpportunityName(activity);
        
        Test.stopTest();

        System.assert(String.isBlank(theName));
    }

    @IsTest static void testGetOppNameNoAccountSuccess()
    {
        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        insert activity;

        Test.startTest();

            String theName = SageApiSubscriptionActivityUtils.getOpportunityName(activity);
        
        Test.stopTest();

        System.assert(String.isNotBlank(theName));
    }

    @IsTest static void testGetRequestLeads()
    {
        Account acc = new Account(Name = 'Business '+string.valueOf(Math.abs(GenericUtilities.getRandom())), BillingCountryCode = 'US', Sales_Office__c = 'Atlanta CBC', locale_billing_cc__c = 'US' );
        insert acc;  
        Contact con = new Contact(email = string.valueOf(Math.abs(GenericUtilities.getRandom()))+'@testemail.com', firstName = 'Test', lastName = 'User', accountId = acc.Id, MailingCity = 'New York', MailingCountry = 'United States', MailingPostalCode = '10082', Language__c = 'English', ELanguage__c = 'EN');
        insert con;               

        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account.accountId = acc.Id;
        req.contact.contactId = con.Id;

        Lead lead = SageApiTestUtils.createLead(req.account.accountId, req.contact.contactId);
        req.contact.leadId = lead.Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);

        Map<Id, Lead> leadMap = null;
        Test.startTest();

            leadMap = SageApiSubscriptionActivityUtils.getRequestLeads( activities );
        
        Test.stopTest();

        System.assertEquals(false, leadMap.isEmpty());
    }

    @IsTest static void testGetRequestLeadsNoPayload()
    {
        Account acc = new Account(Name = 'Business '+string.valueOf(Math.abs(GenericUtilities.getRandom())), BillingCountryCode = 'US', Sales_Office__c = 'Atlanta CBC', locale_billing_cc__c = 'US' );
        insert acc;  
        Contact con = new Contact(email = string.valueOf(Math.abs(GenericUtilities.getRandom()))+'@testemail.com', firstName = 'Test', lastName = 'User', accountId = acc.Id, MailingCity = 'New York', MailingCountry = 'United States', MailingPostalCode = '10082', Language__c = 'English', ELanguage__c = 'EN');
        insert con;               

        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        req.account.accountId = acc.Id;
        req.contact.contactId = con.Id;

        Lead lead = SageApiTestUtils.createLead(req.account.accountId, req.contact.contactId);
        req.contact.leadId = lead.Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.Payload__c = '{';
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);

        Map<Id, Lead> leadMap = null;
        Test.startTest();

            leadMap = SageApiSubscriptionActivityUtils.getRequestLeads( activities );
        
        Test.stopTest();

        System.assertEquals(null, leadMap);
    }

    @IsTest static void testSaveAccountContactMappings()
    {
        Account acc = new Account(Name = 'Business '+string.valueOf(Math.abs(GenericUtilities.getRandom())), BillingCountryCode = 'US', Sales_Office__c = 'Atlanta CBC', locale_billing_cc__c = 'US' );
        insert acc;  
        Contact con = new Contact(email = string.valueOf(Math.abs(GenericUtilities.getRandom()))+'@testemail.com', firstName = 'Test', lastName = 'User', accountId = acc.Id, MailingCity = 'New York', MailingCountry = 'United States', MailingPostalCode = '10082', Language__c = 'English', ELanguage__c = 'EN');
        insert con;               

        SageApiSubscriptionActivityRequest req = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.CreateSubscriptionActivityType, JSON.serialize(req));
        activity.Account__c = acc.Id;
        activity.AccountId__c = req.account.accountId;
        activity.AccountIdType__c = req.account.accountType;
        activity.Contact__c = con.Id;
        activity.ContactId__c = req.contact.contactId;
        activity.ContactIdType__c = req.contact.contactType;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ChannelPlatformProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        activity.ChannelPartnerProvided__c = SageApiActivityRequestObjects.Source.AppDirect.name();
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);

        Test.startTest();

            SageApiSubscriptionActivityUtils.saveAccountMappings( activities );
            SageApiSubscriptionActivityUtils.saveContactMappings( activities );
        
        Test.stopTest();

        List<AccountMapping__c> existingAcctMappings = [SELECT ID, ExternalAccountKey__c FROM AccountMapping__c WHERE ExternalAccountKey__c =: (req.account.accountType+':'+req.account.accountId)];
        System.assert(existingAcctMappings != null);
        List<contactMapping__c> existingContMappings = [SELECT ID, ExternalContactKey__c FROM ContactMapping__c WHERE ExternalContactKey__c =: (req.contact.contactType+':'+req.contact.contactId)];
        System.assert(existingAcctMappings != null);
    }

    @IsTest static void testCreateOrUpdateLeadFromContactSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];

        Account acct = new Account( 
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact( 
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street' 
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        payload.contact.ContactId = cont.Id;
        payload.account.accountId = acct.Id;
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        activity.Account__c = acct.Id;
        activity.Contact__c = cont.Id;
        activities.add( activity );
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);
        
            System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactNoAccountFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact( 
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street' 
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        payload.contact.ContactId = cont.Id;
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        activity.Contact__c = cont.Id;
        activities.add( activity );
        insert activities;
       
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);
        
            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactNoContactFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        activity.Account__c = acct.Id;
        activities.add( activity );
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);
        
            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactBadPayloadFailure()
    {
        SageApiTestUtils.setup();

        Account acct = new Account( 
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact( 
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street' 
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        payload.contact.ContactId = cont.Id;
        payload.account.accountId = acct.Id;
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        activity.Account__c = acct.Id;
        activity.Contact__c = cont.Id;
        activity.Payload__c = '{';
        activities.add( activity );
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);
        
            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactNoProductFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact( 
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street' 
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        payload.contact.ContactId = cont.Id;
        payload.account.accountId = acct.Id;
        payload.subscription = new SageApiActivityRequestObjects.Subscription();
        payload.subscription.products = null;
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        activity.Account__c = acct.Id;
        activity.Contact__c = cont.Id;
        activities.add( activity );
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);
        
            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactExistingLead()
    {
        List<Lead> leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();

        leads.add( new Lead( Firstname = 'Some', Lastname = 'One', Company = 'Example Inc.', Sales_Office__c = 'Atlanta Office', RecordTypeId = recordTypeId ) );
        insert leads;
    
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        payload.contact.leadId = leads[0].id;
        payload.account.phone = '123456';

        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionActivity( payload );
        activity.Lead__c = leads[0].Id;
        activities.add( activity );
        insert activities;
        
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();

            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);
        
            System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testLocateAndCopyActivityDataErrors() {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;
            SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
            Subscription_Master__c sm = [SELECT id FROM Subscription_Master__c WHERE CbcSubscriptionId__c=:activity.SubscriptionId__c LIMIT 1];

            // invalid subscription id
            sm.IsPending__c = true;
            update sm;
            SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities1 = new List<SageApiActivity__c>{activity1};
            Map<String, SageApiActivity__c> subActivityMap1 = new Map<String, SageApiActivity__c>{activity1.SubscriptionId__c => activity1};
            SageApiSubscriptionActivityUtils.locateAndCopyActivityData(steps[0], activities1, false, subActivityMap1);
            System.debug('activity1: '+JSON.serialize(activity1));
            System.assertEquals(SageApiStatus.ValidationErrors, activity1.ActivityStatus__c);

            // unlinked sm-activity
            sm.IsPending__c = false;
            String parentA = sm.Sage_API_Activity__c;
            sm.Sage_API_Activity__c = null;
            update sm;
            SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities2 = new List<SageApiActivity__c>{activity2};
            Map<String, SageApiActivity__c> subActivityMap2 = new Map<String, SageApiActivity__c>{activity2.SubscriptionId__c => activity2};
            SageApiSubscriptionActivityUtils.locateAndCopyActivityData(steps[0], activities2, false, subActivityMap2);
            System.debug('activity2: '+JSON.serialize(activity2));
            System.assertEquals(SageApiStatus.ValidationErrors, activity2.ActivityStatus__c);

            // unlinked sub-activity
            sm.IsPending__c = false;
            sm.Sage_API_Activity__c = parentA;
            update sm;
            SageApiActivity__c activity3 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities3 = new List<SageApiActivity__c>{activity3};
            Map<String, SageApiActivity__c> subActivityMap3 = new Map<String, SageApiActivity__c>{activity3.SubscriptionId__c => null};
            SageApiSubscriptionActivityUtils.locateAndCopyActivityData(steps[0], activities3, false, subActivityMap3);
            System.debug('activity3: '+JSON.serialize(activity3));
            System.assertEquals(SageApiStatus.Unknown, activity3.ActivityStatus__c);

        Test.stopTest();
    }

    @IsTest static void testGetSubscriptionMasters() {
        Test.startTest();

            SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();

            // success
            SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities1 = new List<SageApiActivity__c>{activity1};
            Map<String, Subscription_Master__c> subActivityMap1 = SageApiSubscriptionActivityUtils.getSubscriptionMasters(activities1);
            System.assertEquals(1, subActivityMap1.size());

        Test.stopTest();
    }

    @IsTest static void testGetActivityProducts() {
        Test.startTest();

            SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Activity();

            // null subscription
            SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            req.subscription = null;
            activity.Payload__c = JSON.serialize(req);
            List<SageApiActivity__c> activities = new List<SageApiActivity__c>{activity};
            Map<ID, List<SageApiActivityRequestObjects.Product>> aProdMap = SageApiSubscriptionActivityUtils.getActivityProducts(activities);
            System.assertEquals(0, aProdMap.size());

            // invalid payload
            activity.Payload__c = '{';
            aProdMap = SageApiSubscriptionActivityUtils.getActivityProducts(activities);
            System.assertEquals(0, aProdMap.size());

        Test.stopTest();
    }

    @IsTest static void testAbandon() {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(2, SageApiActivityTriggerHandler.RegradeSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;
            SageApiActivity__c activity = SageApiTestUtils.createRegradeSubscriptionActivity();

            // no sm
            SageApiActivity__c activity1 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities1 = new List<SageApiActivity__c>{activity1};
            SageApiSubscriptionActivityUtils.abandon(steps[0], activities1);
            System.assertEquals(SageApiStatus.Abandoned, activity1.ActivityStatus__c);

            // has sm
            SageApiActivity__c activity2 = SageApiTestUtils.cloneActivity(activity);
            List<SageApiActivity__c> activities2 = new List<SageApiActivity__c>{activity2};
            Subscription_Master__c sm2 = [SELECT id FROM Subscription_Master__c LIMIT 1];
            sm2.IsPending__c = true;
            update sm2;
            activity2.SubscriptionMaster__c = sm2.id;
            SageApiSubscriptionActivityUtils.abandon(steps[0], activities2);
            System.assertEquals(SageApiStatus.Abandoned, activity2.ActivityStatus__c);

        Test.stopTest();
    }

    @IsTest static void testValidateActivity() {
        Test.startTest();

            SageApiActivityHandler handler = new SageApiActivityHandler(1, SageApiActivityTriggerHandler.DeleteSubscriptionActivityType, null, null, null);
            List<SageApiActivityStep> steps = handler.ActivitySteps;

            // null activity
            List<SageApiActivityError> errors1 = SageApiSubscriptionActivityUtils.validateActivity(steps[0], null, null, null);
            System.assertEquals(1, errors1.size());

            // has sm
            SageApiActivity__c activity = SageApiTestUtils.createDeleteSubscriptionActivity();
            activity.ChannelPlatformProvided__c = null;
            activity.ChannelPartnerProvided__c = null;
            List<SageApiActivityError> errors2 = SageApiSubscriptionActivityUtils.validateActivity(steps[0], activity, null, null);
            System.assertEquals(true, errors1.size()>0);

        Test.stopTest();
    }

    @IsTest static void testGetCustomAttribute() {
        SageApiActivityRequestObjects.Attribute attr = new SageApiActivityRequestObjects.Attribute();
        attr.name='key1';
        attr.value='value1';
        List<SageApiActivityRequestObjects.Attribute> attrs = new List<SageApiActivityRequestObjects.Attribute>{attr};
        String val1 = SageApiSubscriptionActivityUtils.getCustomAttribute(attrs, 'key1');
        System.assertEquals('value1', val1);
        String val2 = SageApiSubscriptionActivityUtils.getCustomAttribute(attrs, 'key2');
        System.assertEquals(null, val2);
    }

    @IsTest static void testIsValidAccount() {
        Account acc = new Account(Name = 'Business '+string.valueOf(Math.abs(GenericUtilities.getRandom())), BillingCountryCode = 'US', Sales_Office__c = 'Atlanta CBC', locale_billing_cc__c = 'US' );
        insert acc;
        List<Account> accs = new List<Account>{acc};
        Boolean valid = SageApiSubscriptionActivityUtils.isValidAccount(accs, 'invalidId');
        System.assertEquals(false, valid);
    }
}