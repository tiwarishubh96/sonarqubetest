@IsTest(SeeAllData=false)
private class SageApiActivityHandlerTest
{
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
    }

    @IsTest static void testExecuteTryNowLeadSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.LeadActivityType;
        SageApiTryNowLeadActivityRequest payload = SageApiTestUtils.createTryNowLeadPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteTryNowSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.TryNowActivityType;
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createTryNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteTryNowConvertSuccess()
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
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteBuyNowSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.BuyNowActivityType;
        SageApiBuyNowActivityRequest payload = SageApiTestUtils.createBuyNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteAddCommunityUserSuccess()
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
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteTetrisStartTrialSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.TetrisStartTrialActivityType;
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteTetrisConvertTrialSuccess()
    {
        SageApiTryNowActivityRequest trialPayload = SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c trialActivity = SageApiTestUtils.createActivity( trialPayload );
        insert trialActivity;

        Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Entitlement_Message__c msg = new Entitlement_Message__c();
        msg.Status__c = 'Processed';
        insert msg;

        Subscription_Master__c subsMaster = new Subscription_Master__c();
        subsMaster.Start_Date__c = System.now();
        subsMaster.End_Date__c = System.now().addDays( 30 );
        subsMaster.Status__c = 'Trial';
        subsmaster.CbcSubscriptionId__c = 'CBC Subscription ID';
        subsMaster.Sage_API_Activity__c = trialActivity.Id;
        subsmaster.Entitlement_Id__c = msg.Id;
        insert subsmaster;
        
        trialActivity.SubscriptionMaster__c = subsMaster.Id;
        trialActivity.Entitlement_Message__c = msg.Id;
        update trialActivity;

        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Zuora__Zuora_Id__c = 'Zuora__Zuora_Id__c';
        insert sub;

        SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTetrisConvertTrialPayload(subsMaster.CbcSubscriptionId__c, 'ZuoraSubscriptionId');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        String activityType = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType;
        activity.ActivityType__c = activityType;
        activity.ActivityID__c = 'Random ID';
        activity.ActivityID__c = activityType + ':' + activity.ActivityID__c;
        activity.Account__c = cont.AccountId;
        activity.Contact__c = cont.Id;
        activity.Entitlement_Message__c = msg.Id;
        activity.SubscriptionMaster__c = subsMaster.Id;
        activity.ZuoraSubscriptionId__c = sub.Zuora__Zuora_Id__c;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteTetrisStartPaidSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.TetrisStartPaidActivityType;
        SageApiBuyNowActivityRequest payload = SageApiTestUtils.createTetrisStartPaidPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteCreateSubscriptionSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.CreateSubscriptionActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateSubscriptionPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteUpdateSubscriptionSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.UpdateSubscriptionActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createUpdateSubscriptionPayload(GenericUtilities.getRandomUUIDv4());
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }

    @IsTest static void testExecuteCreateAccountSuccess()
    {
        String activityType = SageApiActivityTriggerHandler.CreateAccountActivityType;
        SageApiSubscriptionActivityRequest payload = SageApiTestUtils.createCreateAccountPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        insert activity;

        SageApiActivityHandler handler = new SageApiActivityHandler(activityType, null, null, null);
        SageApiActivityStep step = handler.activitySteps[0];
    
        Test.startTest();
        
            SageApiActivityHandler hdlr = new SageApiActivityHandler( activityType, step, new List<SageApiActivity__c>{ activity }, UserInfo.getSessionId() );
            System.enqueueJob( hdlr );

        Test.stopTest();

        System.assertNotEquals( null, hdlr.activitySteps );
    }
}