@isTest
private class SSOInternalUserHandler_Test
{
    static testMethod void testInsertSSOHandler()
    {
        Id samlSSOProviderId = null;
        Id communityId = null;
        Id portalId = null;
        String federationIdentifier = 'test';
        String assertion = null;
        Map<String, String> attributes = new Map<String, String>{'First Name' => 'Test'
                                                                , 'Last Name' => 'Test'
                                                                , 'Email' => 'Test'
                                                                , 'Username' => 'Test'
                                                                , 'Nickname' => 'Test'
                                                                , 'Country' => 'Test'
                                                                , 'Street' => 'Harakon'
                                                                , 'Title' => 'Mr'};

        SSOInternalUserHandler JITHandler = new SSOInternalUserHandler();

        JITHandler.createUser(samlSSOProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }

    static testMethod void testUpdateSSOHandler(){
        Id samlSSOProviderId = null;
        Id communityId = null;
        Id portalId = null;
        String federationIdentifier = 'test';
        String assertion = null;
        Map<String, String> attributes = new Map<String, String>{'First Name' => 'Test'
                                                                , 'Last Name' => 'Test'
                                                                , 'Email' => 'Test@email.com'
                                                                , 'Username' => 'Test@test.test.org'
                                                                , 'Nickname' => 'Test'
                                                                , 'Country' => 'Israel'
                                                                , 'Street' => 'Harakon'
                                                                , 'Title' => 'Mr'};


        Profile p = [SELECT Id FROM Profile WHERE Name='Sage: Chatter Only']; 
        User testUser = new User(FirstName = 'test'
                                , LastName = 'test'
                                , Email = 'test@test.test'
                                , Username = 'testost@test.test.SSO'
                                , CommunityNickname = 'test'+System.now()
                                , Alias = 'testo'+System.now().second()
                                , EmailEncodingKey='UTF-8'
                                , LocaleSidKey='en_US'
                                , TimeZoneSidKey='America/Los_Angeles'
                                , LanguageLocaleKey='en_US'
                                , ProfileId=p.id);

        insert testUser;

        SSOInternalUserHandler JITHandler = new SSOInternalUserHandler();

        JITHandler.updateUser(testUser.Id, samlSSOProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
}