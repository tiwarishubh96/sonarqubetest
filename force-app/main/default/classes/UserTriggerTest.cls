@isTest
public class UserTriggerTest {
    static string CLASSNAME = 'UserTriggerTest';
    
    @isTest static void UserWithoutContactID() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='baconbitsandsoda@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, country='India',
            TimeZoneSidKey='America/Los_Angeles', UserName='baconbitsandsoda@testorg.com');

        Test.startTest();
        Database.SaveResult result = Database.insert(u, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
    
    @isTest static void User_With_ENLocale() {
        Locale__c testLoc = new Locale__c(Name='en_US', LanguageLocaleKey__c='en_US', CurrencyIsoCode='USD', Country__c = 'US - United States');
        insert testLoc;
        
        Account testAcc = DataFactoryForTesting.createAccountWithLoc(testLoc.Id);
        testAcc.IsPartner = true;
        
        Contact testCon = DataFactoryForTesting.createContact(testAcc.Id);
        User u = DataFactoryForTesting.createUser(testCon.Id);
        Test.startTest();
            Database.SaveResult result = Database.insert(u, false);
        Test.stopTest();
        System.assertNotEquals (True,result.isSuccess());
    }
    
    @isTest static void User_Without_ENLocale() {
        Locale__c testLoc = new Locale__c(Name='es_ES', LanguageLocaleKey__c='es', CurrencyIsoCode='USD', Country__c = 'ES - Spain');
        insert testLoc;
        
        Account testAcc = DataFactoryForTesting.createAccountLocNotEN(testLoc.Id);
        testAcc.IsPartner = true;
        
        Contact testCon = DataFactoryForTesting.createContact(testAcc.Id);
          system.debug(testAcc.Locale__r.Name);
           system.debug(testAcc.Locale_Billing_CC__c);
        String Locale = getLocalevaluefromMapping.getlocalefromMapping(testAcc.Locale__r.Name,testAcc.Locale_Billing_CC__c);
        User u = DataFactoryForTesting.createUser(testCon.Id);
        
        Test.startTest();
        Database.SaveResult result = Database.insert(u, false);
        Test.stopTest();
        System.assertNotEquals(True,result.isSuccess());
    }
     @isTest static void UserUpdate() {
        Locale__c testLoc = new Locale__c(Name='en_US', LanguageLocaleKey__c='en_US', CurrencyIsoCode='USD', Country__c = 'US - United States');
        insert testLoc;
        
        Account testAcc = DataFactoryForTesting.createAccountWithLoc(testLoc.Id);
        testAcc.IsPartner = true;
        update testAcc;
        Contact testCon = DataFactoryForTesting.createContact(testAcc.Id);
        User u = DataFactoryForTesting.createUser(testCon.Id);
        //create custom setting data
        Partner_Community_Locale_Mapping__c testMapping  = new Partner_Community_Locale_Mapping__c();
        testMapping.Name = 'US';
        testMapping.Account_Locale__c = 'en_US';
        testMapping.Contact_User_Locale__c = 'en_US';
        testMapping.Country_Name__c = 'United States of America (USA)';
        testMapping.ISO_Country_Code__c = 'US';
        insert testMapping;
        Partner_Community_Profiles__c testProfiles  = new Partner_Community_Profiles__c(name=Constants.PARTNER_COMMUNITY_PROFILE, Profile__c = Constants.PARTNER_COMMUNITY_PROFILE);
        insert testProfiles;
        Test.startTest();
            Database.SaveResult resultInsert = Database.insert(u, false);
            //check for update
            Database.SaveResult resultUpdate;
            System.runAs(new User(Id=Userinfo.getUserId())) {
                u.firstname='test';
                u.country='India';
                resultUpdate = Database.update(u, false);
            }
            
        Test.stopTest();
        System.debug('--resultUpdate--'+resultUpdate);
        System.assertNotEquals (False,resultInsert.isSuccess());
        System.assertNotEquals (False,resultUpdate.isSuccess());
        //System.assertNotEquals (True,result.isSuccess());
     }

    /**
  	 * @description: Check Rant and Rave Manager is in line with the standard Manager field
  	 *               and the manager email field is kept in line on related Closed Loop records
  	**/
    @IsTest
    static void testRnRManagerInSync() {
        System.debug(CLASSNAME + ': testRnRManagerInSync START');

        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Sage: Global Services User'];
        User manager1 = new User(Alias='manager1', Email='manager@bbb.com.donotsend',
                EmailEncodingKey='ISO-8859-1', FirstName='bbb', LastName='bbb',
                LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId=p1.Id, TimeZoneSidKey='Europe/London',
                CommunityNickname = 'man1', IsActive=true, Username='manager1@bbb.com.sage.test');
        insert manager1;
        User manager2 = new User(Alias='manager2', Email='manager2@bbb.com.donotsend',
                EmailEncodingKey='ISO-8859-1', FirstName='bbb', LastName='bbb',
                LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId=p1.Id, TimeZoneSidKey='Europe/London',
                CommunityNickname = 'man2', IsActive=true, Username='manager2@bbb.com.sage.test');
        insert manager2;
        User agent = new User(Alias='agent', Email='agent@bbb.com.donotsend',
                EmailEncodingKey='ISO-8859-1', FirstName='aaa', LastName='aaa',
                LanguageLocaleKey='en_US', LocaleSidKey='en_GB', ProfileId=p1.Id, TimeZoneSidKey='Europe/London',
                CommunityNickname = 'age', IsActive=true, Username='agent@aaa.com.sage.test',
                managerId = manager1.Id);
        
        Test.startTest();
        // INSERT USER
        insert agent;

        User insertedAgent = [SELECT RRFrontline__Rant_and_Rave_Manager__c
                              FROM User
                              WHERE Alias = 'agent' LIMIT 1];

        System.assertEquals(insertedAgent.RRFrontline__Rant_and_Rave_Manager__c, manager1.Id);

        Closed_Loop__c cl = new Closed_Loop__c(Agent__c=agent.Id, Status__c='Customer call required');
        insert cl;
        
        insertedAgent.ManagerId = manager2.Id;
        update insertedAgent;

        Test.stopTest();

        User updatedAgent = [SELECT RRFrontline__Rant_and_Rave_Manager__c
                             FROM User
                             WHERE Alias = 'agent' LIMIT 1];

        System.assertEquals(updatedAgent.RRFrontline__Rant_and_Rave_Manager__c, manager2.Id);
        
        Closed_Loop__c retCl = [SELECT Id, Status__c, Agent__c, Is_Closed__c, Agent_Manager_Email__c 
                                FROM Closed_Loop__c
                                WHERE Id = :cl.Id LIMIT 1];
        
        System.debug('Closed Loop ' + retCl);
        System.assertEquals('manager2@bbb.com.donotsend', retCl.Agent_Manager_Email__c);
        
        System.debug(CLASSNAME + ': testRnRManagerInSync FINISH');
    }
}