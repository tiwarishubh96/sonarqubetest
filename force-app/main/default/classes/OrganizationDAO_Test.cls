/**
 * Created by mike.jutzin on 4/4/2017.
 */

@IsTest
private class OrganizationDAO_Test {

    static testMethod void testIsRunningInSandbox() {
        // i mean really though
        System.assertEquals(
            [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandBox,
            new OrganizationDAO().isRunningInSandbox()
        );
    }

    static testMethod void testGetCurrentOrganizationId() {
        System.assertEquals(
                UserInfo.getOrganizationId(),
                new OrganizationDAO().getCurrentOrganizationId()
        );
    }
}