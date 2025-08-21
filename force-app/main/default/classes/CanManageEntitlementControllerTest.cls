@IsTest
private class CanManageEntitlementControllerTest {

    @IsTest(SeeAllData=false)
    static void testCanManageEntitlement() {
        Test.startTest();

        List<Boolean> responses = CanManageEntitlementController.CanManageEntitlement();
        System.assertEquals(1, responses.size());

        Test.stopTest();
    }
}