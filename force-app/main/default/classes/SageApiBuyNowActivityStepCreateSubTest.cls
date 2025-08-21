@IsTest(SeeAllData=false)
private class SageApiBuyNowActivityStepCreateSubTest
{
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
    }

    @IsTest static void testBuyNowActivityStepCreateSubscr()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        SageApiActivityStep step=new SageApiActivityStep(1, 'stepNameTest');
        SageApiBuyNowActivityStepCreateSubscr handler = new SageApiBuyNowActivityStepCreateSubscr();
        Test.startTest();
        
	    	handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowActivityStepCreateSubscrCheckCompletion()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        SageApiActivityStep step = new SageApiActivityStep(1, 'stepNameTest');
        step.StepStatus = SageApiStatus.Success;
        SageApiBuyNowActivityStepCreateSubscr handler = new SageApiBuyNowActivityStepCreateSubscr();
        Test.startTest();
        
	    	handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowActivityStepCreateSubscrCheckMaxAttempts()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        SageApiActivityStep step = new SageApiActivityStep(1, 'stepNameTest');
        step.StepStatus = SageApiStatus.InProgress;
        step.Attempts = 100;
        SageApiBuyNowActivityStepCreateSubscr handler = new SageApiBuyNowActivityStepCreateSubscr();
        Test.startTest();
        
	    	handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowActivityStepCreateSubscrCheckRequiredStep()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        SageApiActivityStep step1 = new SageApiActivityStep(1, 'step1');
        step1.StepStatus = SageApiStatus.Success;
        step1.OnSuccessGotoSteps =  new List<Integer> { 2 };
        activities[0].ActivityStatus__c = SageApiStatus.InProgress;
        activities[0].ActivitySteps__c = JSON.serialize(step1);
        update activities;

        SageApiActivityStep step2 = new SageApiActivityStep(2, 'step2');
        step2.StartAfterCompletedSteps = new List<SageApiActivityStep> { step1 };

        SageApiBuyNowActivityStepCreateSubscr handler = new SageApiBuyNowActivityStepCreateSubscr();
        Test.startTest();
        
	    	handler.process(step2, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.InProgress, activities[0].ActivityStatus__c );
    }
}