@isTest
public class TestSageSSOController {
    @testSetup static void setupData() {   
        
        CommunityAuthSettings__c authSettings = CommunityAuthSettings__c.getOrgDefaults();
		authSettings.SageIDAuthProviderKey__c = 'SageID';
		authSettings.FacebookAuthProviderKey__c = 'Facebook';
		authSettings.GoogleAuthProviderKey__c = 'Google';
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
    @isTest static void testInitInvite() {
        // Create New Invite
        
        List<Community_Membership__c> membershipList = [SELECT Id, Invite_Code__c From Community_Membership__c LIMIT 1];
        System.assertNotEquals(null, membershipList);
        System.assertNotEquals(0, membershipList.size());
        System.assert(membershipList[0].Invite_Code__c != null && membershipList[0].Invite_Code__c != '', 'Invite Code missing');
        
        
        Test.setCurrentPageReference(new PageReference('Page.JoinCommunityWithInvite'));
        System.currentPageReference().getParameters().put('invite', membershipList[0].Invite_Code__c);
        
        SageSSOController ssoController = new SageSSOController();
        System.assertNotEquals(null, ssoController.invitationId);
        ssoController.initInvite();
        System.assertNotEquals(null, ssoController.membershipInfo);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_LISTIDENTITIES_MATCH));
        ssoController.navToRegister();
        System.assertNotEquals(null, ssoController.sageIdentity);
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_STARTURL_EXISTING_SAGEID));
        PageReference pg  = ssoController.startExistingSageUserReg();
        // URL Should not be null
        System.assertNotEquals(null, pg.getUrl());
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_STARTURL_NEW_SAGEID));
        pg  = ssoController.startNewSageUserReg();
        System.assertNotEquals(null, pg.getUrl());
		pg = ssoController.handleFacebookConnect();
        System.assertNotEquals(null, pg.getUrl());
		pg = ssoController.handleGoogleConnect();
        System.assertNotEquals(null, pg.getUrl());
        Test.stopTest();
    }

    @isTest static void testSageResponse(){
        List<Community_Membership__c> membershipList = [SELECT Id, Invite_Code__c From Community_Membership__c LIMIT 1];
        System.assertNotEquals(null, membershipList);
        System.assertNotEquals(0, membershipList.size());
        Test.setCurrentPageReference(new PageReference('Page.SageId_Registration_Success'));
        System.currentPageReference().getParameters().put('invite', membershipList[0].Invite_Code__c);
        System.currentPageReference().getParameters().put('resultId', '123456-1234');
		SageSSOController ssoController = new SageSSOController();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_FAILREASON_EXISTING_SAGEID));
		PageReference pg = ssoController.handleSageIDRegSuccess();
        System.assertNotEquals(null, pg.getUrl());
		pg = ssoController.handleSageIDRegFailure();
        System.assertNotEquals(null, pg);

        Test.stopTest();
    }
}