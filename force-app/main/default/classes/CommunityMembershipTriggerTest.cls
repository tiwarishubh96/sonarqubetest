@isTest
public class CommunityMembershipTriggerTest {
	
    // Helper Methods
    // __________________________________________
    
    /**
     * Creates a account and contact
     * @author Salesforce Services 
     * @param accountName of the account to create
     * @param firstName of the contact to create
     * @param lastName of the contact to create
     * @return contact record created
    **/
    public static Contact createAccountAndContact(String accountName, String firstName, String lastName) {
        Account a = new Account(name='Test');
        insert a;
        
        Contact c = new Contact(FirstName=firstName, LastName=lastName, AccountId=a.Id);
		insert c;
        
        return c;
    }
    
    /**
     * Creates a portal user and associates it to a contact
     * @author Salesforce Services 
     * @param contactId of the contact to associate
     * @param firstName of the user 
     * @param lastName of the user
     * @param email of the user
     * @param username of the user
     * @return user record created
    **/
    public static User createPortalUser(Id contactId, String firstName, String lastName, String email, String username) {
        
        User u = new User();
        u.FirstName = firstName;
        u.lastName = lastName;
        u.username = username;
        u.alias = firstName;
        u.email = email;
        u.ProfileId = ([select id from profile where name=:Constants.CUSTOMER_COMMUNITY_PROFILE LIMIT 1]).Id;
        u.CurrencyIsoCode = 'USD';
        u.LanguageLocaleKey = 'en_US';
        u.ContactId = contactId;
        u.TimeZoneSidKey = 'GMT';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
        
        insert u;
        return u;
    }
    
    /**
     * Creates a community extension record for testing
     * @author Salesforce Services 
     * @param name of the community extension
     * @return community extension record created
    **/
    public static CommunityX__c createCommunityExtension(String name) {
        CommunityX__c community = new CommunityX__c();
        community.Name = name;
        community.Community_Base_Url__c = 'Test';
        community.CommunityId__c = 'Test';
        community.Default_User_Profile__c = 'Test';
        community.Invite_Page_Path__c = 'Test';
        community.Sage_SSO_Post_Register_Failure_Page__c = 'Test';
        community.Sage_SSO_Post_Register_Success_Page__c = 'Test';
        
        insert community;
        return community;
    }
    
    /**
     * Creates a community role record and associates it to the community extension
     * @author Salesforce Services 
     * @param roleName of the role to create
     * @param communityId of the community extension
     * @return community role record created
    **/
    public static Community_Role__c createCommunityRole(String roleName, Id communityId) {
        Community_Role__c role = new Community_Role__c(Name=roleName, Community__c=communityId);
        insert role;
        
        return role;
    }
    
    /**
     * Creates a community role permission set record and associates it with the community role
     * @author Salesforce Services 
     * @param role to associate this record with
     * @param permissionName name of the permission set
     * @return community role permission set record created
    **/
    public static Community_Role_Permission_Set__c createCommunityRolePermission(Community_Role__c role, String permissionName) {
        Community_Role_Permission_Set__c permission = new Community_Role_Permission_Set__c(Community_Role__c=role.Id, Permission_Set__c=permissionName);
        insert permission;
        
        return permission;
    }
    
    /**
     * Creates a community membership record and associates it to the community
     * @author Salesforce Services 
     * @param communityId of the community extension
     * @param contactId of the contact for which membership will be created
     * @param roleId to associate the member with
     * @return community membership record created
    **/
    public static Community_Membership__c createCommunityMembership(Id communityId, Id contactId, Id roleId) {
        Community_Membership__c membership = new Community_Membership__c(Community__c=communityId, Community_Role__c=roleId, Contact__c=contactId);
        insert membership;
        
        return membership;
    }
    
    // End Helper Methods
    // __________________________________________
    
    public static testmethod void inserting_A_Community_Member_Should_Add_PermissionSet() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        Community_Role__c role = createCommunityRole('Sage One Admin', community.Id);
        
        createCommunityRolePermission(role, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        
        Contact c = createAccountAndContact('Test', 'test', 'test');
        
        User u = createPortalUser(c.Id, 'test', 'test', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com');
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        createCommunityMembership(community.Id, c.Id, role.Id);
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u.id];
        
        Boolean foundPermission = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermission = true;
                break;
            }
        }
        
        System.assertEquals(true, foundPermission);
    }
    
    public static testmethod void updating_A_Community_Member_Should_Update_PermissionSet() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        
        Community_Role__c role1 = createCommunityRole('Sage One Admin', community.Id);
        
        Community_Role__c role2 = createCommunityRole('Sage One User', community.Id);
        createCommunityRolePermission(role2, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        
        Contact c = createAccountAndContact('Test', 'test', 'test');
        
        User u = createPortalUser(c.Id, 'test', 'test', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com');
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        Community_Membership__c membership = createCommunityMembership(community.Id, c.Id, role1.Id);
        membership.Community_Role__c = role2.Id;
        update membership;
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u.id];
        
        Boolean foundPermission = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermission = true;
                break;
            }
        }
        
        System.assertEquals(true, foundPermission);
    }
    
    public static testmethod void deleting_A_Community_Member_Should_Remove_PermissionSet() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        
        Community_Role__c role = createCommunityRole('Sage One Admin', community.Id);
        createCommunityRolePermission(role, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        
        Contact c = createAccountAndContact('Test', 'test', 'test');
        
        User u = createPortalUser(c.Id, 'test', 'test', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com');
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        Community_Membership__c membership = createCommunityMembership(community.Id, c.Id, role.Id);
        delete membership;
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u.id];
        
        Boolean foundPermission = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermission = true;
                break;
            }
        }
        
        System.assertEquals(false, foundPermission);
    }
    
    public static testmethod void updating_A_Community_Member_Role_Should_Change_PermissionSet() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        
        Community_Role__c role1 = createCommunityRole('Sage One Admin', community.Id);
        createCommunityRolePermission(role1, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        
        Community_Role__c role2 = createCommunityRole('Sage One User', community.Id);
        createCommunityRolePermission(role2, Constants.VIEW_INVOICES_PERMISSION_SET_LABEL);
        
        Contact c = createAccountAndContact('Test', 'test', 'test');
        
        User u = createPortalUser(c.Id, 'test', 'test', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com');
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        Community_Membership__c membership = createCommunityMembership(community.Id, c.Id, role1.Id);
        membership.Community_Role__c = role2.Id;
        update membership;
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u.id];
        
        Boolean foundPermissionManageSubscription = false;
        Boolean foundPermissionViewInvoices = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermissionManageSubscription = true;
            }
            
            if (permission.PermissionSet.Label == Constants.VIEW_INVOICES_PERMISSION_SET_LABEL) {
                foundPermissionViewInvoices = true;
            }
        }
        
        System.assertEquals(false, foundPermissionManageSubscription);
        System.assertEquals(true, foundPermissionViewInvoices);
    }
    
    public static testmethod void creating_A_Community_Member_Role_With_Multiple_Permissions_Should_Add_All_PermissionSets() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        
        Community_Role__c role = createCommunityRole('Sage One Admin', community.Id);
        createCommunityRolePermission(role, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        createCommunityRolePermission(role, Constants.VIEW_INVOICES_PERMISSION_SET_LABEL);
        
        Contact c = createAccountAndContact('Test', 'test', 'test');
        
        User u = createPortalUser(c.Id, 'test', 'test', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com');
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        createCommunityMembership(community.Id, c.Id, role.Id);
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u.id];
        
        Boolean foundPermissionManageSubscription = false;
        Boolean foundPermissionViewInvoices = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermissionManageSubscription = true;
            }
            
            if (permission.PermissionSet.Label == Constants.VIEW_INVOICES_PERMISSION_SET_LABEL) {
                foundPermissionViewInvoices = true;
            }
        }
        
        System.assertEquals(true, foundPermissionManageSubscription);
        System.assertEquals(true, foundPermissionViewInvoices);
    }
    
    public static testmethod void creating_Mutiple_Community_Member_Roles_For_The_Same_Contact_Should_Add_All_PermissionSets() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        
        Community_Role__c role1 = createCommunityRole('Sage One Admin', community.Id);
        createCommunityRolePermission(role1, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        Community_Role__c role2 = createCommunityRole('Sage One Trial', community.Id);
        createCommunityRolePermission(role2, Constants.VIEW_INVOICES_PERMISSION_SET_LABEL);
        
        Contact c = createAccountAndContact('Test', 'test', 'test');
        
        User u = createPortalUser(c.Id, 'test', 'test', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com', 
                            'inserting_A_Community_User_Permission_Should_Add_PermissionSet@test.com');
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        createCommunityMembership(community.Id, c.Id, role1.Id);
        createCommunityMembership(community.Id, c.Id, role2.Id);
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u.id];
        
        Boolean foundPermissionManageSubscription = false;
        Boolean foundPermissionViewInvoices = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermissionManageSubscription = true;
            }
            
            if (permission.PermissionSet.Label == Constants.VIEW_INVOICES_PERMISSION_SET_LABEL) {
                foundPermissionViewInvoices = true;
            }
        }
        
        System.assertEquals(true, foundPermissionManageSubscription);
        System.assertEquals(true, foundPermissionViewInvoices);
    }
    
    public static testmethod void creating_A_Community_Member_Role_For_Different_Contacts_Should_Add_PermissionSet_To_Both_Contacts() {
        
        CommunityX__c community = createCommunityExtension(Constants.CUSTOMER_COMMUNITY_NAME);
        
        Community_Role__c role = createCommunityRole('Sage One Admin', community.Id);
        createCommunityRolePermission(role, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
        
        Contact c1 = createAccountAndContact('Test1', 'test1', 'test1');
        Contact c2 = createAccountAndContact('Test2', 'test2', 'test2');
        
        User u1 = createPortalUser(c1.Id, 'test1', 'test1', 
                            'creating_A_Community_Member_Role_For_Different1@test.com', 
                            'creating_A_Community_Member_Role_For_Different1@test.com');
        
        User u2 = createPortalUser(c2.Id, 'test2', 'test2', 
                            'creating_A_Community_Member_Role_For_Different2@test.com', 
                            'creating_A_Community_Member_Role_For_Different2@test.com');
        
        
        TestUtilities.createTriggerCustomSetting();
        
        Test.startTest();
        createCommunityMembership(community.Id, c1.Id, role.Id);
        createCommunityMembership(community.Id, c2.Id, role.Id);
        Test.stopTest();
        
        List<PermissionSetAssignment> permissions1 = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u1.id];
        
        Boolean foundPermissionManageSubscriptionForUser1 = false;
        
        for (PermissionSetAssignment permission : permissions1) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermissionManageSubscriptionForUser1 = true;
            }
        }
        
        List<PermissionSetAssignment> permissions2 = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:u2.id];
        
        Boolean foundPermissionManageSubscriptionForUser2 = false;
        
        for (PermissionSetAssignment permission : permissions2) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermissionManageSubscriptionForUser2 = true;
            }
        }
        
        System.assertEquals(true, foundPermissionManageSubscriptionForUser1);
        System.assertEquals(true, foundPermissionManageSubscriptionForUser2);
    }
}