@isTest
public class FeaturedTopicControllerTest {
    
	static testmethod void getCountryListTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        String CommunityConfigName = 'Sage Customer Community';
        Community_Config__c communityConfig = new Community_Config__c();
        communityConfig.Name = CommunityConfigName;
        communityConfig.Country_Code__c = 'ca; de; es; fr; gb; us';
        communityConfig.Language_Code__c = 'de; en; es; fr';
        communityConfig.Community_Name__c='Sage Customer Community';
        insert communityConfig;
        system.runAs(u){
            test.startTest();
            FeaturedTopicController.getCountriesList(CommunityConfigName);
            test.stopTest();
        }
    }
    
    // We are using all data = true because we were not able to retreive community Id from network object.
    @istest(SeeAllData=true)
    static void saveSettingsTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c(); 
        Id commId = [SELECT id, name FROM Network limit 1].id;
        //Id commId = UserInfo.getUserId(); 
        communityComponentConfig.Name = 'sample Test';
        communityComponentConfig.Permission_Name__c = 'Sage: Customer CC Admin';
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communitycomponentConfig.Community_Id__c = commId;
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;
        system.runAs(u){
            test.startTest();
            FeaturedTopicController.saveSettings(null, communityComponentConfig.Component_Name__c,
                                                 communityComponentConfig.Component_Type__c, communityComponentConfig.Permission_Name__c, communityComponentConfig.Settings__c);
            FeaturedTopicController.saveSettings(communityComponentConfig.Id, communityComponentConfig.Component_Name__c,
                                                 communityComponentConfig.Component_Type__c, communityComponentConfig.Permission_Name__c, communityComponentConfig.Settings__c);
            test.stopTest();
        }
    }
    
    // We are using all data = true because we were not able to retreive community Id from network object.
    @istest(SeeAllData=true)
    static void getComponentConfigTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        Id commId = [SELECT id, name FROM Network where Name='Sage Customer Community' limit 1].id;
        communityComponentConfig.Name = 'sample Test';
        communitycomponentConfig.Community_Id__c = commId;
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            FeaturedTopicController.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                       communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
}