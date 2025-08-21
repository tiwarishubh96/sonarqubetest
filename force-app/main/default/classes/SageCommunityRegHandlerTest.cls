/**
 * @description Tests associted class.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest
public with sharing class SageCommunityRegHandlerTest
{
    //////////////////////////////
    // Customer Community Tests //
    //////////////////////////////

    static private User comUser;
    static private SageUserIdentityProvider__c provider;
    static private Account acc;
    static private Contact con;

    static private void setup()
    {   
        System.runAs(new User(Id = UserInfo.getuserId() ) )
        {
            acc = new Account( Name = 'Some Business');
            insert acc;

            con = new Contact( AccountId = acc.Id, Firstname = 'John', Lastname = 'Smith', Email = 'john.smith@example.com' );
            insert con;
            con = (Contact)GenericUtilities.resetSObject( con );
			
            CommunityX__c communityX = new CommunityX__c(CommunityId__c = '123233', Name='Test Community', 
                                                     Community_Base_Url__c ='/base', Default_User_Profile__c ='Sage: Partner Community User',
                                                     Invite_Page_Path__c = '/invite',
                                                     Sage_SSO_Post_Register_Failure_Page__c ='/sso_failure',
                                                     Sage_SSO_Post_Register_Success_Page__c = '/sso_success');
        
            insert communityX;
			
			// Create Community Role
            Community_Role__c role = new Community_Role__c(Name='Admin', Community__c=communityX.Id);
        	insert role;
            
            // Create Community Role Permission Set
            Community_Role_Permission_Set__c permission = new Community_Role_Permission_Set__c(
                Community_Role__c=role.Id, Permission_Set__c=Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            insert permission;
            
            // Create Community Membership
            Community_Membership__c membership = new Community_Membership__c(Community__c = communityX.Id, 
                                                                             Contact__c = con.Id,
                                                                             Community_Role__c = role.Id);
            insert membership;
            
            comUser = new User();
            comUser.Username = 'someone.sagetest@example.com';
            comUser.Email = 'someone.sagetest@example.com';
            comUser.LastName = con.Lastname;
            comUser.FirstName = con.Firstname;
            comUser.CompanyName = acc.Name;
            comUser.Alias = 'test';
            // TODO: something to improve later
            comUser.EmailEncodingKey = 'UTF-8';
            comUser.LanguageLocaleKey = 'en_US';
            comUser.LocaleSidKey = 'en_US';
            comUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1].Id;
            comUser.EmailEncodingKey = 'ISO-8859-1';
            comUser.TimeZoneSidKey = 'GMT';
            comUser.ContactId = con.Id;
            comUser.CommunityNickname = 'JohnSmith549273450';
            comUser.IsActive = false;
            insert comUser;

            provider = new SageUserIdentityProvider__c();
            provider.User__c = comUser.Id;
            provider.Account__c = acc.Id;
            provider.IdentityId__c = 'testid';
            provider.IdentityProvider__c = 'TestProvider';
            provider.SFBridgeId__c = String.join((new String[]{ String.valueOf(acc.Id), provider.IdentityProvider__c, provider.IdentityId__c }), ':');
            insert provider;
        }

        
    }

    @IsTest(SeeAllData=false) static void testCreateUserSuccess()
    {
        // Moving test setup up to sync future
        Test.startTest();
        
            setup();
    		
        	Id userId = comUser.Id;
        
            Auth.UserData data = new Auth.UserData(
                provider.SFBridgeId__c // identifier
                , null // firstname
                , null // lastname
                , 'Someone Else' // fullname
                , 'someone.sagetest-changed@example.com' // email
                , null // link
                , 'someone@example.com' // username
                , 'en_US' // locale
                , 'TestProvider' // provider
                , null // siteLongUrl
                , new Map<String, String>() // attributeMap
            );
        
            SageCommunityRegHandler hdlr = new SageCommunityRegHandler();
            hdlr.createUser( null, data );
    
        Test.stopTest();

        User resultUser = (User)GenericUtilities.resetSObject( comUser );
        // name didn't change
        System.assertEquals( con.Name, resultUser.Name );
        // email changed
        System.assertEquals( data.email, resultUser.Email );
        // user is active
        System.assertEquals( true, resultUser.IsActive );
        
        List<PermissionSetAssignment> permissions = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId=:userId];
        
        Boolean foundPermission = false;
        
        for (PermissionSetAssignment permission : permissions) {
            if (permission.PermissionSet.Label == Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL) {
                foundPermission = true;
                break;
            }
        }
        
        System.assertEquals(true, foundPermission);
    }
    
    @IsTest(SeeAllData=false) static void tsetCreateUserFailure()
    {
        setup();

        Auth.UserData data = new Auth.UserData(
            'nonsense' // identifier
            , null // firstname
            , null // lastname
            , 'Someone Else' // fullname
            , 'someone.sagetest-changed@example.com' // email
            , null // link
            , 'someone@example.com' // username
            , 'en_US' // locale
            , 'TestProvider' // provider
            , null // siteLongUrl
            , new Map<String, String>() // attributeMap
        );
    
        Test.startTest();
        
            try {
                SageCommunityRegHandler hdlr = new SageCommunityRegHandler();
                hdlr.createUser( null, data );
            }
            catch(Exception ex)
            {
                TestExc.isExcThrown = true;
            }
    
        Test.stopTest();

        System.assertEquals( true, TestExc.isExcThrown );
    }

    @IsTest(SeeAllData=false) static void testUpdateUserSuccess()
    {
        setup();

        Auth.UserData data = new Auth.UserData(
            provider.SFBridgeId__c // identifier
            , null // firstname
            , null // lastname
            , 'Someone Else' // fullname
            , 'someone.sagetest-changed@example.com' // email
            , null // link
            , 'someone@example.com' // username
            , 'en_US' // locale
            , 'TestProvider' // provider
            , null // siteLongUrl
            , new Map<String, String>() // attributeMap
        );
    
        Test.startTest();
        
            try {
                SageCommunityRegHandler hdlr = new SageCommunityRegHandler();
                hdlr.updateUser( comUser.Id, null, data ); 
            }
            catch(Exception ex)
            {
                TestExc.isExcThrown = true;
            }
    
        Test.stopTest();

        User resultUser = (User)GenericUtilities.resetSObject( comUser );
        // name didn't change
        System.assertEquals( con.Name, resultUser.Name );
        // email changed
        System.assertEquals( data.email, resultUser.Email );

        System.assertEquals( false, TestExc.isExcThrown );
    }

    @IsTest(SeeAllData=false) static void testUpdateUserFailure()
    {
        setup();

        Auth.UserData data = new Auth.UserData(
            provider.SFBridgeId__c // identifier
            , null // firstname
            , null // lastname
            , 'Someone Else' // fullname
            , 'someone.sagetest-changed@example.com' // email
            , null // link
            , 'someone@example.com' // username
            , 'en_US' // locale
            , 'TestProvider' // provider
            , null // siteLongUrl
            , new Map<String, String>() // attributeMap
        );

        TestExc.fire( SageCommunityRegHandler.class, 'coverage' );
    
        Test.startTest();
        
            try {
                SageCommunityRegHandler hdlr = new SageCommunityRegHandler();
                hdlr.updateUser( comUser.Id, null, data ); 
            }
            catch(Exception ex)
            {
                TestExc.isExcThrown = true;
            }
    
        Test.stopTest();

        System.assertEquals( true, TestExc.isExcThrown );
    }

    /////////////////////////////
    // Partner Community Tests //
    /////////////////////////////

    static private void setupPartnerData() {   
        
        CommunityAuthSettings__c authSettings = CommunityAuthSettings__c.getOrgDefaults();
        authSettings.SageIDAuthProviderName__c = 'SageID';
        authSettings.FacebookAuthProviderName__c = 'Facebook';
        authSettings.GoogleAuthProviderName__c = 'Google';
        upsert authSettings CommunityAuthSettings__c.Id;
        
        Account testAcc = new Account(Name = 'Test Account', Sales_Office__c = 'Dublin CBC', Type = 'Customer', Industry = 'Finance', Phone = '12345678');
        insert testAcc;
        
        // Create Contact for Account
        Contact testCon = new Contact(
            AccountId = testAcc.Id, FirstName = 'Test', LastName = 'Contact', Phone = '12345678', Email = 'test@test123.com');     
        insert testCon; 
        
        // Create CommunityX Record
        CommunityX__c communityX = new CommunityX__c(CommunityId__c = '123233', Name='Test Community', 
                                                     Community_Base_Url__c ='/base', Default_User_Profile__c ='Sage: Partner Community User',
                                                     Invite_Page_Path__c = '/invite',
                                                     Sage_SSO_Post_Register_Failure_Page__c ='/sso_failure',
                                                     Sage_SSO_Post_Register_Success_Page__c = '/sso_success');
        
        insert communityX;
        
        // Create Community Membership
        Community_Membership__c membership = new Community_Membership__c(Community__c = communityX.Id, 
                                                                         Contact__c = testCon.Id,
                                                                         Invite_Code__c = 'INV-12345',
                                                                         Status__c  = 'Invited');
        insert membership;
        System.debug(membership);
    }

    @isTest static void testCreateUserFlow()
    {
        setupPartnerData();

        List<Community_Membership__c> membershipList = [SELECT Id, Invite_Code__c From Community_Membership__c LIMIT 1];
        System.assertNotEquals(null, membershipList);
        System.assertNotEquals(0, membershipList.size());
        System.assert(membershipList[0].Invite_Code__c != null && membershipList[0].Invite_Code__c != '', 'Invite Code missing');

        List<Account> accountList = [SELECT Id From Account LIMIT 1];
        System.assertNotEquals(null, accountList);
        System.assertNotEquals(0, accountList.size());
                      
        String testSub =accountList[0].id + ':' + 'SageID' + ':' + '123456';
        
        SageCommunityRegHandler handler = new SageCommunityRegHandler();
        Auth.UserData authUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                   'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'SageID',
                                                   null, new Map<String, String>{'contact_id' => membershipList[0].Invite_Code__c,'sub' => testSub});
        User u = handler.createUser(null, authUserData);
        System.assertNotEquals(null, u);

        //handler.updateUser(u.Id, null, authUserData);
        // Nothing to test yet on update flow.

        // Test for Existing SageIdentity Entry - Since it would have already been inserted in previous call
        authUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                   'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'SageID',
                                                   null, new Map<String, String>{'contact_id' => membershipList[0].Invite_Code__c, 'sub' => testSub});
        u = handler.createUser(null, authUserData);
        System.assertNotEquals(null, u);
        
    }
}