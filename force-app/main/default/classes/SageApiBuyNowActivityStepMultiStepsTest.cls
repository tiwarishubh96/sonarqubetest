@IsTest(SeeAllData=false)
private class SageApiBuyNowActivityStepMultiStepsTest
{
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
    }
    
    @IsTest static void testBuyNowActivityStepValidatePayload()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 

        PayNowToken__c token = new PayNowToken__c(Name='mytoken', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert token;
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        activities[0].PayNowToken__c = token.Id;
        update activities;

        SageApiActivityStep step=new SageApiActivityStep(1, 'stepNameTest');
        step.ActionID = 1;
        SageApiBuyNowActivityStepMultiSteps handler = new SageApiBuyNowActivityStepMultiSteps();
        Test.startTest();
        
	    	handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowActivityStepStep5()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 

		List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
		SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
		product.tierCode = 'sageone-start-us';
		products.add(product);

        PayNowToken__c token = new PayNowToken__c(Name='mytoken', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert token;
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        activities[0].PayNowToken__c = token.Id;
        update activities;

        SageApiActivityStep step=new SageApiActivityStep(1, 'stepNameTest');
        step.ActionID = 5;
        SageApiBuyNowActivityStepMultiSteps handler = new SageApiBuyNowActivityStepMultiSteps();
        Test.startTest();
        
	    	handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.Success, activities[0].ActivityStatus__c );
    }

    @IsTest static void testBuyNowActivityStepOutOfActions()
    {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId); 

		List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
		SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
		product.tierCode = 'sageone-start-us';
		products.add(product);

        PayNowToken__c token = new PayNowToken__c(Name='mytoken', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert token;
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();  
        
        List<SageApiActivity__c> activities = SageApiBuyNowActivityUtilsTest.setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        activities[0].PayNowToken__c = token.Id;
        update activities;

        SageApiActivityStep step=new SageApiActivityStep(1, 'stepNameTest');
        step.ActionID = 10;
        SageApiBuyNowActivityStepMultiSteps handler = new SageApiBuyNowActivityStepMultiSteps();
        Test.startTest();
        
	    	handler.process(step, activities, UserInfo.getSessionId());

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
    	System.assertEquals( SageApiStatus.Unknown, activities[0].ActivityStatus__c );
    }
}