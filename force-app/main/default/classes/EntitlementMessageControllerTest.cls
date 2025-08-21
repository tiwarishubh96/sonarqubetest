@isTest
private class EntitlementMessageControllerTest {
	
    @IsTest(SeeAllData=false) static void testGetPaidEntitlementSuccess()
    {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Artifacts();
        List<String> entitlementIds = new List<String>();
        entitlementIds.add(activity.EntitlementId__c);

        String body = '{"id":"dc985fe5-8bff-4cca-bb78-77a6708b3b9e","principalID":"CBCAccount:0010E00000MlnerQAB","effectivePeriod":{"notBefore":"2018-06-27","notAfter":"2099-12-31"},"isTerminated":false,"products":[{"name":"sageonestartde"}]}';
        EntitlementMockREST mock = new EntitlementMockREST(200, 'SUCCESS', body, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

	        List<EntitlementMessageController.Response> responses = EntitlementMessageController.getEntitlement(entitlementIds);
	        System.assertEquals(1, responses.size());

        Test.stopTest();
    }

    @IsTest(SeeAllData=false) static void testGetTrialEntitlementSuccess()
    {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Artifacts();
        List<String> entitlementIds = new List<String>();
        entitlementIds.add(activity.EntitlementId__c);

        // trial
        String body = '{"id":"2a771660-7769-4537-8fa7-6300a0e76c99","principalID":"CBCAccount:0010E00000Mt0DlQAJ","effectivePeriod":{"notBefore":"2018-06-28","notAfter":"2018-07-28"},"isTerminated":false,"products":[{"name":"sageoneaccountingfr","features":[{"name":"trial"}]}]}';
        EntitlementMockREST mock = new EntitlementMockREST(200, 'SUCCESS', body, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

	        List<EntitlementMessageController.Response> responses = EntitlementMessageController.getEntitlement(entitlementIds);
	        System.assertEquals(1, responses.size());

        Test.stopTest();
    }

    @IsTest(SeeAllData=false) static void testGetBlockedEntitlementSuccess()
    {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
        insert new EntitlementSetting__c(Name='Test', Location__c='https://api.test.com', Key__c='testKey', Username__c='testUsername');
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Artifacts();
        List<String> entitlementIds = new List<String>();
        entitlementIds.add(activity.EntitlementId__c);

        // blocked
        String body = '{"id":"15a409c8-beea-4791-850f-6ec44b0c668b","principalID":"CBCAccount:00124000016jo49AAA","effectivePeriod":{"notBefore":"2017-03-28","notAfter":"2099-12-31"},"isTerminated":false,"blockInfo":{"isBlocked":true,"blockedReason":"PaymentIssue","blockedMessage":"Stolen or lost card.  Possible action* Refer the transaction to your customer support center for manual review."},"products":[{"name":"sageoneaccounting"}]}';
        EntitlementMockREST mock = new EntitlementMockREST(200, 'SUCCESS', body, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

	        List<EntitlementMessageController.Response> responses = EntitlementMessageController.getEntitlement(entitlementIds);
	        System.assertEquals(1, responses.size());

        Test.stopTest();

    }

    @IsTest(SeeAllData=false) static void testGetEntitlementError()
    {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();
        insert new EntitlementSetting__c(Name='Test', Location__c=System.Label.ENT_API_LOCATION, Key__c='testKey', Username__c='testUsername');
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Artifacts();
        List<String> entitlementIds = new List<String>();
        entitlementIds.add(activity.EntitlementId__c);

        // blocked
        String body = '{"id":"15a409c8-beea-4791-850f-6ec44b0c668b","principalID":"CBCAccount:00124000016jo49AAA","effectivePeriod":{"notBefore":"2017-03-28","notAfter":"2099-12-31"},"isTerminated":false,"blockInfo":{"isBlocked":true,"blockedReason":"PaymentIssue","blockedMessage":"Stolen or lost card.  Possible action* Refer the transaction to your customer support center for manual review."},"products":[{"name":"sageoneaccounting"}]}';
        EntitlementMockREST mock = new EntitlementMockREST(500, 'Error', body, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

	        List<EntitlementMessageController.Response> responses = EntitlementMessageController.getEntitlement(entitlementIds);
	        System.assertEquals(1, responses.size());

        Test.stopTest();

    }

}