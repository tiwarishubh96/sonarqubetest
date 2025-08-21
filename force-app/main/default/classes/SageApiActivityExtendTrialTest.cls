@IsTest(SeeAllData=false)
private class SageApiActivityExtendTrialTest {
    @IsTest
    static void testExtendTrial() {
        String smId = setupTest();
    
        List<SageApiActivityExtendTrial.ExtendTrialRequest> requests = new List<SageApiActivityExtendTrial.ExtendTrialRequest>();
        SageApiActivityExtendTrial.ExtendTrialRequest request = new SageApiActivityExtendTrial.ExtendTrialRequest();
        request.subscriptionMasterId = smId;
        request.expiryDate = Date.today().addMonths(1);
        requests.add(request);

        Test.startTest();
        
            List<SageApiActivityExtendTrial.ExtendTrialResult> results = SageApiActivityExtendTrial.extendTrials(requests);
            
        Test.stopTest();
    }

    @IsTest
    static void testExtendTrialNoRequests() {
        List<SageApiActivityExtendTrial.ExtendTrialRequest> requests = new List<SageApiActivityExtendTrial.ExtendTrialRequest>();
        SageApiActivityExtendTrial.ExtendTrialRequest request = new SageApiActivityExtendTrial.ExtendTrialRequest();

        Test.startTest();
        
            List<SageApiActivityExtendTrial.ExtendTrialResult> results = SageApiActivityExtendTrial.extendTrials(requests);
            
        Test.stopTest();
    }
    
    static string setupTest()
    {
        SageApiTestUtils.setup();
        //SageApiTestUtils.setupProductCatalog();

        Product_Tier__c tier = new Product_Tier__c();
        tier.Name = 'Sage One';
        tier.Product_Tier_Code__c = 'SageOne-Start-US';
        tier.Product_Use_Region__c = 'US - United States';
        tier.PayNow_PageType__c = 'SageOne';
        insert tier;
                
        Account acc = new Account( 
                Name = 'Test Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'
            );
        insert acc;

        Contact con = new Contact( 
                Firstname = 'Some'
                , Lastname = 'One' + acc.Name.substringBefore(' ')
                , AccountId = acc.Id
                , MailingCity = 'London'
                , MailingPostalCode = '30318'
                , MailingCountryCode = 'US'
                , MailingStreet = 'Downing Street' 
            );
        insert con;


        Entitlement_Message__c msg = new Entitlement_Message__c();
        msg.Status__c = 'Processed';
        insert msg;

        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', '2c92c0f84dfff49f014e021c79b82bb6'); 

        //Product_Tier__c tier = [SELECT Id, Product_Tier_Code__c FROM Product_Tier__c LIMIT 1];
        
        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Quote__c = zquote.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Trial';
        sm.Entitlement_Id__c = msg.Id;
        sm.Product_Tier__c = tier.Id;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.products[0].tierCode = tier.Product_Tier_Code__c;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
        resp.data = new SageApiBuyNowActivityResponse.ResponseData();
        resp.data.contactId = con.Id;
        resp.data.accountId = con.AccountId;
        
        PayNowToken__c token = new PayNowToken__c();
        token.name = 'Test';
        insert token;

        activity.Artifacts__c = JSON.serialize( resp );
        activity.Account__c = con.AccountId;
        activity.Contact__c = con.Id;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        activity.ActivityStatus__c = SageApiStatus.Success;
        activity.ActivityType__c = SageApiActivityTriggerHandler.TryNowActivityType;
        activity.PayNowToken__c = token.Id;
        activities.add( activity );
        insert activities;

        sm.Sage_API_Activity__c = activity.Id;
        update sm;
        
        return sm.Id;
    }
}