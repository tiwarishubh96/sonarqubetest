public class ImageTileResult extends BaseResult {
    
    @AuraEnabled    
    public String id;
    
    @AuraEnabled
    public String communityId;
    
    @AuraEnabled
    public String componentName;
        
    @AuraEnabled
    public String componentType;

    @AuraEnabled
    public Boolean isComponentAdmin;

    @AuraEnabled
    public String componentConfig;
    
    @AuraEnabled
    public String languagesByCountry;
    
    @AuraEnabled
    public list<PartnerTypeTier> partnerTypeTierList;
    
}