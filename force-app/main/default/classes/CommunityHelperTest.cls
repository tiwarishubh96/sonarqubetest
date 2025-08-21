@isTest
private class CommunityHelperTest
{
    
    @isTest(SeeAllData=true)
    static void itShould() {        

        Id commId =  System.Label.PartnerCommunityId;
        CommunityHelper.getCommunityId(''+commId);
        CommunityHelper.getAllCommunities();
    }
    
    @IsTest(SeeAllData=true)
    public static void getCommunityIdTest()
    {
        ConnectAPI.Community obj = new ConnectAPI.Community();
        obj.Name = 'test1';
        obj.Id = 'test1';
        obj.loginUrl = 'test1';
        obj.Name = 'test2';
        obj.Id = 'test2';
        obj.loginUrl = 'test2';
        obj.Name = 'Sage Customer Community';
        obj.Id = 'test3';
        obj.loginUrl = 'test3';
        String fetch = CommunityHelper.getCommunityId('Sage Customer Community');
        System.debug('Fetching Data for getCommunityIdTest: '+fetch);
        System.debug('End of getCommunityIdTest data');
    }
    
    @IsTest(SeeAllData=true)
    public static void getNavigationalTopicsTest()
    {
        System.debug('Fetching Data for getNavigationalTopicsTest');
        Id commId = [SELECT id, name FROM Network limit 1].id;
        CommunityHelper.getNavigationalTopics(''+commId);
        System.debug('End of getCommunityIdTest data');
    }
   
    static testmethod void getCountriesByCommunityTest()
    {
        
        Community_Country_Mapping__c objCCM = new Community_Country_Mapping__c();
        objCCM.Country_Code__c = 'us';
        objCCM.Locale_SID_Key__c = 'en_US';
        objCCM.Name = 'United States';
        objCCM.Country_Label__c = 'United States';
        insert objCCM;
        
        Community_Country_Mapping__c objCCM2 = new Community_Country_Mapping__c();
        objCCM2.Country_Code__c = 'gb';
        objCCM2.Locale_SID_Key__c = 'en_GB';
        objCCM2.Name = 'United Kingdom';
        objCCM2.Country_Label__c = 'United Kingdom';
        insert objCCM2;
        
        String[] countries = new String[]{'en','fr','es','gb','us'};
        String strCountryList = CommunityHelper.getCountriesByCommunity(countries);
        system.assertNotEquals(Null, strCountryList);
    }
    
    static testmethod void getCurrentCommunityIdTest() {
        
        String strCommId = CommunityHelper.getCurrentCommunitId();
        system.assertNotEquals(Null, strCommId);
    }
    
    Static testmethod void getCommunityConfigTest() {
        
        String configName = 'Sage Partner Community';
        
        Community_Config__c objCommConfig = new Community_Config__c();
        objCommConfig.Community_Name__c = configName;
        insert objCommConfig;
        
        Community_Config__c objCC = CommunityHelper.getCommunityConfig(configName);
        system.assertNotEquals(Null, objCC);
    }
    
    static testmethod void getLanguagesByCountryTest() {
        
        Community_Country_Mapping__c objCCM = new Community_Country_Mapping__c();
        objCCM.Country_Code__c = 'us';
        objCCM.Locale_SID_Key__c = 'en_US';
        objCCM.Name = 'United States';
        objCCM.Country_Label__c = 'United States';
        insert objCCM;
        
        Community_Language_Mapping__c objCLM = new Community_Language_Mapping__c();
        objCLM.Name = 'English';
        objCLM.Language_Code__c = 'en';
        objCLM.Language_Label__c = 'English';
        objCLM.Language_Selector__c = 'English';
        insert objCLM;
                
        Community_Country_Language__c objCCL = new Community_Country_Language__c();
        objCCL.Country__c = objCCM.Id;
        objCCL.Language__c = objCLM.Id;
        objCCL.Locale__c = 'en_US';
        objCCL.Language_Locale_Key__c = 'en_US';
        objCCL.Community_Name__c = 'Sage Partner Community';
        insert objCCL; 
        
        String[] countries = new String[]{'us'};

        String configName = 'Sage Partner Community';
        CommunityHelper.getLanguagesByCountry(configName);
        CommunityHelper.getLocaleByCountry(configName);
        CommunityHelper.getAllLanguageLocales(configName);
        string strCountryList  = CommunityHelper.getLocalesByCommunity( countries , configName);
        system.assertNotEquals(Null, strCountryList);
        
        string strLanguageLocale = CommunityHelper.getLocaleForCommunityCountryAndLanguage('us','en',configName);
        system.assertNotEquals(Null, strLanguageLocale);
    }
    
    static testmethod void getLanguagesByCommunityTest() {
        
        Community_Language_Mapping__c objCLM = new Community_Language_Mapping__c();
        objCLM.Name = 'English';
        objCLM.Language_Code__c = 'en';
        objCLM.Language_Label__c = 'English';
        objCLM.Language_Selector__c = 'English';
        insert objCLM;
        
        String[] languages = new String[]{'en','fr','es','de','ca'};
        string strLanguageList = CommunityHelper.getLanguagesByCommunity(languages);
        system.assertNotEquals(Null, strLanguageList);
    }
    
    static testmethod void getCommunityNameTest() {
        
        Community_Country_Mapping__c objCCM = new Community_Country_Mapping__c();
        objCCM.Country_Code__c = 'us';
        objCCM.Locale_SID_Key__c = 'en_US';
        objCCM.Name = 'United States';
        insert objCCM;
        
        Contact objContact = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        CommunityHelper.getUser();
        CommunityHelper.getLoggedinUserInfo();
        Id commId = System.Label.PartnerCommunityId;
        CommunityHelper.getCommunityName(commId);
        CommunityHelper.getPartnerTypeTierMapping(commId);
        CommunityHelper.getLocaleSIDKey('US');
        CommunityHelper.getUserCountryName('US');
                
        Account objAccount = CommunityHelper.getLoggedinUserAccountInfo(objContact.AccountId);
        System.AssertNotEquals(objAccount , Null);

    }
}