@isTest
public class FeaturedArticlesControllerTest {
    @isTest
    static void getDataCategoryGroupsTest() {
        List<DataCategoryGroupModel> dModel= new List<DataCategoryGroupModel>();
        dModel=FeaturedArticlesController.getDataCategoryGroups();
    }
    
    @isTest(SeeAllData=true)
    static void getCommunityLanguagesTest() {
        String config = 'Sage Customer Community';
        String languages='';
        languages=FeaturedArticlesController.getCommunityLanguages(config);
    }
    
    @isTest(SeeAllData=true)
    static void getComponentConfigTest() {
        FeaturedArticlesController.getComponentConfig('Customer Community Comp', 'Featured Articles Component', 'Sage Customer Community', 'Sage: Partner CC Admin');
    }
    
    @isTest(SeeAllData=true)
    static void saveSettingsTest() {
        Id commId = [select Id from Network limit 1].Id;
        String communityId = commId;
        Community_Component_Config__c commCompConfig = new Community_Component_Config__c();
        commCompConfig.Component_Name__c = 'Customer Community Comp';
        commCompConfig.Name = 'Comp';
        commCompConfig.Community_Id__c = commId;
        insert commCompConfig;
        String componentConfigId=''+commCompConfig.Id;
        FeaturedArticlesController.saveSettings(componentConfigId, communityId, 'Customer Community Comp', 'Featured Articles Component', '','');
    }
    
    @isTest
    static void getArticlesByDataCategoriesTest() {
        String categoryJson = 'Category__c'+':'+'Support__c'+','+'Products__c'+':'+'Sage_Live__c';
        FeaturedArticlesController.getArticlesByDataCategories(categoryJson,2,'en','','Customer Community Config');
    }
}