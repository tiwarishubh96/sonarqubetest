@isTest
public class CarouselControllerTest {
    @isTest
    static void getLanguageListTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        String CommunityConfigName = 'Sage Customer Community';
        Community_Config__c communityConfig = new Community_Config__c();
        communityConfig.Name = CommunityConfigName;
        communityConfig.Country_Code__c = 'ca; de; es; fr; gb; us';
        communityConfig.Language_Code__c = 'de; en; es; fr';
        communityConfig.Community_Name__c = 'Sage Customer Community';
        insert communityConfig;
        system.runAs(u){
            test.startTest();
            CarouselController.getLanguageList(CommunityConfigName);
            test.stopTest();
        }
    }
    
     //SeeAllData True is using to get Community Id
    @isTest(SeeAllData=true)
    static void saveSettingsTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        communityComponentConfig.Name = 'sample Test';
        communityComponentConfig.Permission_Name__c = 'Customer CC Admin';
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Community_Id__c = [SELECT id, name FROM Network limit 1].id;
        communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;
        system.runAs(u){
            test.startTest();
            CarouselController.saveSettings(null, communityComponentConfig.Component_Name__c,communityComponentConfig.Permission_Name__c,
                                            communityComponentConfig.Component_Type__c, communityComponentConfig.Settings__c);
            CarouselController.saveSettings(communityComponentConfig.Id, communityComponentConfig.Component_Name__c,communityComponentConfig.Permission_Name__c,
                                            communityComponentConfig.Component_Type__c, communityComponentConfig.Settings__c);
            test.stopTest();
        }
    }
    //SeeAllData True is using to get Community Id
    @isTest(SeeAllData=true)
    static void getComponentConfigTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        communityComponentConfig.Name = 'sample Test';
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        communityComponentConfig.Community_Id__c = [SELECT id, name FROM Network limit 1].id;
        communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            CarouselController.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                  communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
    
    static testmethod void getCountriesListTest() {
        Community_Config__c communityConfig = new Community_Config__c();
        communityConfig.Name = 'Customer Community Config';
        communityConfig.Country_Code__c = 'ca; de; es; fr; gb; us';
        communityConfig.Language_Code__c = 'de; en; es; fr';
        communityConfig.Community_Name__c = 'Sage Customer Community';
        insert communityConfig;
        String countries = CarouselController.getCountriesList('Sage Customer Community');
    }
}