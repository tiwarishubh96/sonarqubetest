public class FeaturedArticlesResult extends BaseResult {
    
    @AuraEnabled    
    public String id;
    
    @AuraEnabled
    public String communityId;
    
    @AuraEnabled
    public String componentName;
        
    @AuraEnabled
    public String componentType;

    @AuraEnabled
    public String componentTitle;

    @AuraEnabled
    public String emptyDataSetMessage;

    @AuraEnabled
    public Boolean isComponentAdmin;

    @AuraEnabled
    public String componentConfig;
    
    @AuraEnabled
    public List<DataCategoryGroupModel> dataCategoryGroups;

    @AuraEnabled
    public String languages;

}