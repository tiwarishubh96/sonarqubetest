@isTest
public class TestSageSSOUtil {
    private static String testEmailAddress = 'test1@test.com';
    
    @testSetup static void setupData() {      
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
    
    @isTest static void testGetSageIdentitiesForNoMatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_LISTIDENTITIES_NO_MATCH));
        List<SageUserIdentity> identityList = SageSSOUtil.getSageIdentities(testEmailAddress);
        System.assertEquals(null, identityList);      
        Test.stopTest();
    }
    
    @isTest static void testGetSageIdentitiesForMatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_LISTIDENTITIES_MATCH));
        List<SageUserIdentity> identityList = SageSSOUtil.getSageIdentities(testEmailAddress);
        System.assertNotEquals(null, identityList);         
        System.assertEquals(1, identityList.size());         
        Test.stopTest();
    }    
    
    @isTest static void testGetStartUrlForExistingUserReg() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_STARTURL_EXISTING_SAGEID));
        String redirectUrl = SageSSOUtil.getStartUrlForExistingUserReg('', '', '');
        System.assertNotEquals(null, redirectUrl);         
        Test.stopTest();
    }
    
    @isTest static void testGetExistingUserRegFailureReason() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_FAILREASON_EXISTING_SAGEID));
        String reason = SageSSOUtil.getExistingUserRegFailureReason('');
        System.assertNotEquals(null, reason);         
        Test.stopTest();
    }
    
    @isTest static void testGetStartUrlForNewUserReg(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_STARTURL_NEW_SAGEID));
        String redirectUrl = SageSSOUtil.getStartUrlForNewUserReg('','', '', '');
        System.assertNotEquals(null, redirectUrl);
        Test.stopTest();
    }
    
    @isTest static void testGetNewUserRegFailureReason(){        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestSageIDMockHttpResponseGenerator(TestSageIDMockHttpResponseGenerator.SCENARIO_GET_FAILREASON_NEW_SAGEID));
        String reason = SageSSOUtil.getNewUserRegFailureReason('');
        System.assertNotEquals(null, reason);
        Test.stopTest();
    }
    
    @isTest static void testCreateUserFromInvitation(){
        List<Community_Membership__c> membershipList = [SELECT Id, Invite_Code__c From Community_Membership__c LIMIT 1];
        System.assertNotEquals(null, membershipList);
        System.assertNotEquals(0, membershipList.size());
        System.assert(membershipList[0].Invite_Code__c != null && membershipList[0].Invite_Code__c != '', 'Invite Code missing');

        List<Account> accountList = [SELECT Id From Account LIMIT 1];
        System.assertNotEquals(null, accountList);
        System.assertNotEquals(0, accountList.size());
		
        
        User user = SageSSOUtil.createUserFromInvitation(membershipList[0].Invite_Code__c);
        System.assertNotEquals(null, user);
        
        String testSub =accountList[0].id + ':' + 'SageID' + ':' + '123456';
        SageSSOUtil.insertSageUserIdentityMap(user.id, testSub);
        
        List<SageUserIdentityProvider__c> sageIdentityList = [Select Id, Account__r.Id, IdentityID__c, SFBridgeID__c, User__c
                                                              FROM SageUserIdentityProvider__c LIMIT 1];
        
        System.assertNotEquals(null, sageIdentityList);
        System.assertNotEquals(0, sageIdentityList.size());
        System.assert(sageIdentityList[0].Account__r.Id == accountList[0].Id, 'Account in SageUserIdentityProvider__c didnt match the account originally inserted!');
        System.assert(sageIdentityList[0].SFBridgeID__c == testSub, 'Subject dont match');
    }
}