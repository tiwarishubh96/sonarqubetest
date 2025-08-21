@isTest
public class TestSageOpenIDConnectRegHandler {
    @testSetup static void setupData() {   
        
        CommunityAuthSettings__c authSettings = CommunityAuthSettings__c.getOrgDefaults();
        authSettings.SageIDAuthProviderName__c = 'SageID';
        authSettings.FacebookAuthProviderName__c = 'Facebook';
        authSettings.GoogleAuthProviderName__c = 'Google';
        upsert authSettings CommunityAuthSettings__c.Id;
        
        Account acc = new Account(Name = 'Test Account', Sales_Office__c = 'Dublin CBC', Type = 'Customer', Industry = 'Finance', Phone = '12345678');
        insert acc;
        
        // Create Contact for Account
        Contact con = new Contact(
            AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact', Phone = '12345678', Email = 'test@test123.com');     
        insert con; 
        
        // Create CommunityX Record
        CommunityX__c communityX = new CommunityX__c(CommunityId__c = '123233', Name='Test Community', 
                                                     Community_Base_Url__c ='/base', Default_User_Profile__c ='Sage: Partner Community User',
                                                     Invite_Page_Path__c = '/invite',
                                                     Sage_SSO_Post_Register_Failure_Page__c ='/sso_failure',
                                                     Sage_SSO_Post_Register_Success_Page__c = '/sso_success');
        
        insert communityX;
        
        // Create Community Membership
        Community_Membership__c membership = new Community_Membership__c(Community__c = communityX.Id, 
                                                                         Contact__c = con.Id,
                                                                         Invite_Code__c = 'INV-12345',
                                                                         Status__c  = 'Invited');
        insert membership;
        System.debug(membership);
        
        
    }
    @isTest static void testCreateUserFlow(){
        List<Community_Membership__c> membershipList = [SELECT Id, Invite_Code__c From Community_Membership__c LIMIT 1];
        System.assertNotEquals(null, membershipList);
        System.assertNotEquals(0, membershipList.size());
        System.assert(membershipList[0].Invite_Code__c != null && membershipList[0].Invite_Code__c != '', 'Invite Code missing');

        List<Account> accountList = [SELECT Id From Account LIMIT 1];
        System.assertNotEquals(null, accountList);
        System.assertNotEquals(0, accountList.size());
                      
        String testSub =accountList[0].id + ':' + 'SageID' + ':' + '123456';
        
        SageOpenIDConnectRegHandler handler = new SageOpenIDConnectRegHandler();
        Auth.UserData authUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                   'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'SageID',
                                                   null, new Map<String, String>{'contact_id' => membershipList[0].Invite_Code__c,'sub' => testSub});
        User u = handler.createUser(null, authUserData);
        System.assertNotEquals(null, u);

        handler.updateUser(u.Id, null, authUserData);
		// Nothing to test yet on update flow.

        // Test for Existing SageIdentity Entry - Since it would have already been inserted in previous call
        authUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                   'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'SageID',
                                                   null, new Map<String, String>{'contact_id' => membershipList[0].Invite_Code__c, 'sub' => testSub});
        u = handler.createUser(null, authUserData);
        System.assertNotEquals(null, u);
        
    }
    
}