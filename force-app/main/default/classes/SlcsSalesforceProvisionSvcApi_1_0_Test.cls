@IsTest
public class SlcsSalesforceProvisionSvcApi_1_0_Test {
    
    public static testmethod  void testExistingUsername()
    {
        createUsername('test00120301sage@email12d324csage.com');
        Test.startTest();
        Boolean isDuplicated = SlcsSalesforceProvisionSvcApi_1_0.DoPost('test00120301sage@email12d324csage.com');
        System.debug('testExistingUsername isDuplicated ' + isDuplicated);
        Test.stopTest();
        System.assertEquals(isDuplicated,true);        
    }
    
    public static testmethod  void testNonExistingUsername()
    {
        Test.startTest();
        Boolean isDuplicated = SlcsSalesforceProvisionSvcApi_1_0.DoPost('test00120301sage@email12d324csage.com');
        Test.stopTest();
        System.debug('testExistingUsername isDuplicated ' + isDuplicated);
        System.assertEquals(isDuplicated,false);        
    }
    
    private static void createUsername(String username) {
        User user = new User();
        user.FirstName = 'any';
        user.LastName = 'any';
        user.Alias = 'any';
        user.EMail = 'any@email.com';
        user.Username = username;
        user.CommunityNickname = username;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.ProfileId = [SELECT Id, Name FROM Profile WHERE Name='Standard User' limit 1].Id;
        insert user;
    }
    
}