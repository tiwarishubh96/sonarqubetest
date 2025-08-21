@isTest
public class FlowUtilitiesCheckPermissionTest {
	
    public static testmethod void hasPermission_When_user_doesnt_have_permission_returns_false() {
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        
        System.runAs(u) {
            Test.startTest();
            List<Boolean> result = FlowUtilitiesCheckPermission.hasPermission(new List<String> {Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL});
            Test.stopTest();
			
            System.assertEquals(1, result.size());
            System.assertEquals(false, result[0]);
        }
    }
    
    public static testmethod void hasPermission_When_user_does_have_permission_set_returns_true() {
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            List<Boolean> result = FlowUtilitiesCheckPermission.hasPermission(new List<String> {Constants.MANAGE_SUBSCRIPTION_PERMISSION});
            Test.stopTest();

            System.assertEquals(1, result.size());
            System.assertEquals(true, result[0]);
        }
    }
    
    public static testmethod void hasPermission_When_user_does_have_one_permission_set_but_not_the_other_returns_true_and_false() {
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            List<Boolean> result = FlowUtilitiesCheckPermission.hasPermission(new List<String> {Constants.MANAGE_SUBSCRIPTION_PERMISSION, 'Non-existant-permission'});
            Test.stopTest();

            System.assertEquals(2, result.size());
            System.assertEquals(true, result[0]);
            System.assertEquals(false, result[1]);
        }
    }
}