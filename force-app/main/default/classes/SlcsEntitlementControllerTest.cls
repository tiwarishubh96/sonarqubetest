@IsTest(SeeAllData=false)
private class SlcsEntitlementControllerTest {
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupChannelPlatform();

        SageApiSlcsEventControllerTest.TestUtils testUtils = new SageApiSlcsEventControllerTest.TestUtils();
        testUtils.setupTest();
    }
    
    @IsTest static void testGetEntitlementSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createCreateSubscriptionV2Artifacts();
        System.debug('activity.SubscriptionId__c='+activity.SubscriptionId__c);
        List<String> subIds = new List<String>();
        subIds.add(activity.SubscriptionId__c);
        System.debug('subIds='+subIds);

        String body = '{"id":"dc985fe5-8bff-4cca-bb78-77a6708b3b9e","principalID":"CBCAccount:0010E00000MlnerQAB","effectivePeriod":{"notBefore":"2018-06-27","notAfter":"2099-12-31"},"isTerminated":false,"products":[{"name":"sageonestartde"}],"entitlement":{"products":[{"product":"sageonestartde","launchUrl":"https://someUrl.com"}]}}';
        EntitlementMockREST mock = new EntitlementMockREST(200, 'SUCCESS', body, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        List<SlcsEntitlementController.Response> responses = SlcsEntitlementController.getSlcsEntitlement(subIds);
        System.assertEquals(1, responses.size());

        Test.stopTest();
    }
}