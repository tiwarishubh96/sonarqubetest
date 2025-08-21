@isTest
public class CommunityHeaderControllerTest {
    	static void dataSetup() {
        //Inserting test record in to Community_Config__c
        Community_Config__c testConfig = new Community_Config__c(Name='Customer Community Config',
                                                                 Country_Code__c='us;fr', 
                                                                 Language_Code__c='en;fr'
                                                                );
        testConfig.Community_Name__c = 'Sage Customer Community';
            insert testConfig;
        //Insert using Utility class TestDataUtility
        //Inserting test Record in Community_Country_Mapping__c
        Map<String,object> countryMappingAttributesForRecords = new Map<String,object>();
        countryMappingAttributesForRecords.put('Name','United States');
        countryMappingAttributesForRecords.put( 'Country_Code__c','us');
        countryMappingAttributesForRecords.put('Country_Label__c','United States');
        TestDataUtility.createSobject(3, true, countryMappingAttributesForRecords, 'Community_Country_Mapping__c');
        //Inserting test Record in Community_Language_Mapping__c
        Map<String,object> languageMappingAttributesForRecords = new Map<String,object>();
        languageMappingAttributesForRecords.put('Name','French');
        languageMappingAttributesForRecords.put( 'Language_Code__c','fr');
        languageMappingAttributesForRecords.put('Language_Label__c','Français');
        languageMappingAttributesForRecords.put('Language_Selector__c','French');
        TestDataUtility.createSobject(3, true, languageMappingAttributesForRecords, 'Community_Language_Mapping__c');
        //Creating Sage customer Community User 
        //Create Account 
        //Account acc = TestDataUtility.createAccount();
        //Create contact
        //Contact contact1 = new Contact(LastName='TestUser',
                                       //AccountId = acc.Id, Partner_Contact__c=true ,Invite_user_to_Partner_Community__c= true);
        Contact con = CommunityUtilitiesTest.createAccountAndContact('Unknown Plc', 'J', 'Smith', 'jsmth@gmail.com');
        upsert con;
        //Profile Id
        Id prof = [SELECT Id FROM Profile WHERE Name = 'Sage: Customer Community User' Limit 1].Id;
        //Test Sage customer community user 
        Map<String,object> userAttributesForRecords = new Map<String,object>();
        userAttributesForRecords.put('ProfileId',prof);
        userAttributesForRecords.put( 'LastName','testUser');
        userAttributesForRecords.put('CommunityNickname','testnick');
        userAttributesForRecords.put('Email','testUser@test.com');
        userAttributesForRecords.put('Username','testUser@test.com' + System.currentTimeMillis());
        userAttributesForRecords.put( 'Alias','alias');
        userAttributesForRecords.put('Contactid',con.id);
        userAttributesForRecords.put('TimeZoneSidKey','America/Los_Angeles');
        userAttributesForRecords.put('EmailEncodingKey','UTF-8');
        userAttributesForRecords.put( 'LanguageLocaleKey','en_US');
        userAttributesForRecords.put('LocaleSidKey','en_US');
        TestDataUtility.createSobject(1, true, userAttributesForRecords, 'User');
    }
    
    @isTest(SeeAllData=true)
    static void test1()
    {
        
        dataSetup();
        User u = [Select Id , name FROM User WHERE Email='testUser@test.com'];
        List<Network> community = [SELECT id, Name,OptionsReputationEnabled FROM Network ];
        System.debug('Test: '+community);
        test.startTest();
        //Running as Test user 
        System.RunAs(u){
            //UserShare usersh = new UserShare(UserAccessLevel = 'Read', UserId = u.Id);
            // Calling getNavigationHeaderPicklists Method 
            //String out = CommunityHeaderController.getNavigationHeaderPicklists('Customer Community Config');
            //System.debug(out);
            //.assertNotEquals(out, null);
            String userInf = CommunityHeaderController.getUser();
            System.assertNotEquals(userInf, null);
            String result = CommunityHeaderController.updateUserLanguageAndLocale('fr','fr','Sage Customer Community');
            System.assertNotEquals(result, null);
            //CommunityNavigationController.setLanguage('test', 'test'); 
        }
        test.stopTest();
    }
    
    /*
    * Some of the ConnectApi classes are not providing test methods in that community class is one.
    * Based on following link https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_TestingApex.htm
    * Using @IsTest(SeeAllData=true).
    * Date: 11/14/2016
	**/
    @isTest(SeeAllData=true)
    static void test2()
    {
        CommunityHeaderController.getCommunities();
    }
    @isTest(SeeAllData=true)
    static void getNavigationHeaderPicklistsTest() {
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Group plc', 'Edward', 'Conor', 'econnor@gmail.com');
        User u = CommunityUtilitiesTest.createPortalUser(c);
        System.runAs(u){
            CommunityHeaderController.getNavigationHeaderPicklists();
        }
    }
}