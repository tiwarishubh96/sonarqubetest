@isTest
private with sharing class SageLiveCommunityRegistrationHandlerTest {
    
    public static void setUpErrorCustomSettings(){
        
        Community_SSO_Settings__c setting = new Community_SSO_Settings__c();
        setting.Web_To_Case_Service_Url__c = URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.WebToCase?encoding=UTF-8';
        setting.CaseCustomerInstanceUrlFieldId__c = '00N2400000DjkTY';
        setting.CaseCustomerInstancefieldId__c='00N2400000DjkTa';
        setting.Case_Category_Field_Id__c='00N2400000DjkTV';
        setting.Case_Category__c = 'Customer Service';
        setting.CaseSubCategoryFieldId__c = '00N2400000DjkTX';
        setting.Case_SubCategory__c = 'Websites and Self Service';
        setting.Case_Prority__c='High';
        setting.Case_Status__c = 'New';
        setting.Case_Type__c = 'Problem';
        setting.CaseConsumerUserNameId__c ='00N2400000DjkTb';
        setting.Case_Origin__c = 'Web SSO Error';
        setting.SageCommunityProflieName__c = 'Sage: CBC Customer Community User';
        insert setting;
        
    }
    
    //test for scenario when no licence found
    static testMethod void testCreateUserWithoutLicence() {
        setUpErrorCustomSettings();
        test.startTest();
        SageLiveCommunityRegistrationHandler handler = new SageLiveCommunityRegistrationHandler();
        Boolean errorThrow = false;
        
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US'});
        
        try{
            Test.setMock(HttpCalloutMock.class, new SageLiveWebToCaseMockHttp());
            User u = handler.createUser(null, sampleData);
            system.assertEquals(true, false, 'Exception should be thrown as no licence exists');
        }catch(Exception ex){
            errorThrow=true;
            system.assertEquals(Label.SageLiveRegistrationLicenseNotExistError, ex.getMessage(), 'There should no license be found in db');
        }
        system.assertEquals(true, errorThrow, 'Rigister handler should throw an expcetion');
        Test.stopTest();
    }
    
    static testMethod void testCreateUserWithLicenceWithoutAccount() {
        setUpErrorCustomSettings();
        Test.startTest();
        SageLiveCommunityRegistrationHandler handler = new SageLiveCommunityRegistrationHandler();
        Boolean errorThrow = false;
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        insert licensesf;
        
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US','organization_id' =>'00Dd0000000cnGD'});
        
        try{
            Test.setMock(HttpCalloutMock.class, new SageLiveWebToCaseMockHttp());
            User u = handler.createUser(null, sampleData);
            system.assertEquals(true, false, 'Exception should be thrown as no licence exists');
        }catch(Exception ex){
            errorThrow=true;
            //system.assertEquals(Label.SageLiveRegistrationAccountNotAssignedError.replace('{0}',licensesf.id ), ex.getMessage(), 'Exisitng license should not have an alinged account reference');
        }
        system.assertEquals(true, errorThrow, 'Rigister handler should throw an expcetion');
        Test.stopTest();
    }
    
    static testMethod void testCreateUserWithLicenceWithtAccountAndUpdateUserData() {
        setUpErrorCustomSettings();
        Test.startTest();
        SageLiveCommunityRegistrationHandler handler = new SageLiveCommunityRegistrationHandler();
        
        Account a = new Account();
        a.BillingCity = 'London';
        a.BillingCountry = 'United Kingdom';
        a.BillingPostalCode = 'TS1 1AA';
        a.BillingStreet = 'Test street';     
        a.Name = 'Test Account for register handler';
        insert a;
        
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        licensesf.sfLma__Account__c = a.id;
        insert licensesf;
        
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'locale' => 'en_US', 'language' => 'en_US','organization_id' =>'00Dd0000000cnGD','username' => 'testuserSage@example.org'});
        
       sampleData.locale = 'en_US';
       sampleData.attributeMap.put('timezone','America/Los_Angeles');
       Test.setMock(HttpCalloutMock.class, new SageLiveWebToCaseMockHttp()); 
       User u = handler.createUser(null, sampleData);
       system.debug('Debug from unit test:'+u);
       //check if user created
       system.assertEquals(true, u.Username.containsIgnoreCase('testuserSage@example.org'), 'There should be created testuser@example.org');
       //check if contact was created for user
       system.assertEquals(true, u.ContactId != null, 'There should be contact aligned to user');
       
       insert u;
       //run as Automated user to avoid mixd dml operations 
       User runningUser =  [Select id from User where name='Automated User' limit 1].get(0);
       system.runAs(runningUser){
            //test update user and contact method
           sampleData.email = 'testuserUpdated@example.org';
           sampleData.firstName = 'testFirstUpdated';
           sampleData.lastName =  'testLastUpdated';
            
           handler.updateUser(u.id,null, sampleData);    
       }
       Test.stopTest();
        
    }
    
    
    static testMethod void testCreateUserWithLicenceWithtAccountUpdateUserInActive() {
        setUpErrorCustomSettings();
        Test.startTest();
        SageLiveCommunityRegistrationHandler handler = new SageLiveCommunityRegistrationHandler();
        
        Account a = new Account();
        a.BillingCity = 'London';
        a.BillingCountry = 'United Kingdom';
        a.BillingPostalCode = 'TS1 1AA';
        a.BillingStreet = 'Test street';     
        a.Name = 'Test Account for register handler';
        insert a;
        
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        licensesf.sfLma__Account__c = a.id;
        insert licensesf;
        
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'locale' => 'en_US', 'language' => 'en_US','organization_id' =>'00Dd0000000cnGD','username' => 'testuserSage@example.org'});
        
       sampleData.locale = 'en_US';
       sampleData.attributeMap.put('timezone','America/Los_Angeles');
       Test.setMock(HttpCalloutMock.class, new SageLiveWebToCaseMockHttp()); 
       User u = handler.createUser(null, sampleData);
       system.debug('Debug from unit test:'+u);
       //check if user created
       system.assertEquals(true, u.Username.containsIgnoreCase('testuserSage@example.org'), 'There should be created testuser@example.org');
       //check if contact was created for user
       system.assertEquals(true, u.ContactId != null, 'There should be contact aligned to user');
       u.IsActive = false;
       insert u;
      
       //run as Automated user to avoid mixd dml operations 
       User runningUser =  [Select id from User where name='Automated User' limit 1].get(0);
       system.runAs(runningUser){
            //test update user and contact method
           sampleData.email = 'testuserUpdated@example.org';
           sampleData.firstName = 'testFirstUpdated';
           sampleData.lastName =  'testLastUpdated';
           Boolean errorWasThrown = false;
           try{
               handler.updateUser(u.id,null, sampleData);
              system.assertEquals(true, false, 'Exception should be thrown'); 
           }catch(Exception ex){
               errorWasThrown = true;
               system.assertEquals(Label.SageLiveRegistrationAccountDisabled, ex.getMessage(), 'Error about inactive user should be thrown');
           }
           
           system.assertEquals(true, errorWasThrown, 'Exception should be thrown');
       }
       Test.stopTest();
        
    }
    
    //testing the scenario when user with the same alias/nickname/username
    //already exist in db and user has never log in using SSO before-such case
    //can happen when user was revoked from third party list by administrator
    static testMethod void testCreateUserForThirdPartyRevoke() {
        setUpErrorCustomSettings();
        Test.startTest();
        SageLiveCommunityRegistrationHandler handler = new SageLiveCommunityRegistrationHandler();
        
        Account a = new Account();
        a.BillingCity = 'London';
        a.BillingCountry = 'United Kingdom';
        a.BillingPostalCode = 'TS1 1AA';
        a.BillingStreet = 'Test street';      
        a.Name = 'Test Account for register handler';
        insert a;
        
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        licensesf.sfLma__Account__c = a.id;
        insert licensesf;
        
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'locale' => 'en_US', 'language' => 'en_US','organization_id' =>'00Dd0000000cnGD','username' => 'testuserSage@example.org'});
        
       sampleData.locale = 'en_US';
       sampleData.attributeMap.put('timezone','America/Los_Angeles');  
       //User u = handler.createUser(null, sampleData);
       //system.debug('Debug from unit test:'+u);
       //check if user created
       //system.assertEquals(true, u.Username.containsIgnoreCase('testuserSage@example.org'), 'There should be created testuser@example.org');
       //check if contact was created for user
       //system.assertEquals(true, u.ContactId != null, 'There should be contact aligned to user');
       
       //insert u;
       //run as Automated user to avoid mixd dml operations 
       //User runningUser =  [Select id from User where name='Automated User' limit 1].get(0);
       //system.runAs(runningUser){
       //     Test.setMock(HttpCalloutMock.class, new SageLiveWebToCaseMockHttp());
            //User u1 = handler.createUser(null, sampleData);   
       //}
       Test.stopTest();
        
    }
}