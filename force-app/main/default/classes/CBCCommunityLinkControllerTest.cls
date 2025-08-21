@IsTest
private class CBCCommunityLinkControllerTest {
    
    @IsTest(SeeAllData=true)
    static void  testRedirectToCommunity(){
        Test.startTest();
        CBCCommunityLinkController ctrl = new CBCCommunityLinkController();
        system.assertEquals(true, ctrl.redirectToCommunity() != null, 'There should be returned community page reference/check');
        Test.stopTest();
    }

}