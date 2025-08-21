public without sharing class CarouselController {

    @AuraEnabled
    public static String getCountriesList(String communityName) {
        
        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(communityName);
        String[] countryList = communityConfig.Country_Code__c.split(';');
        //retrieve countries associated with the community
        String countriesJson = CommunityHelper.getCountriesByCommunity(countryList);        
       	return countriesJson;                            
    }

    @AuraEnabled
    public static String getLanguageList(String communityName) {
        
        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(communityName);
        String[] languageList = communityConfig.Language_code__c.split(';');
        System.debug('CarouselController: getLanguageList Language List: ' + languageList);
        
        //retrieve countries associated with the community
        String languagesJson = CommunityHelper.getLanguagesByCommunity(languageList);
        
       	return languagesJson;                            
    }
    
     @AuraEnabled
    public static void saveSettings(String componentConfigId, String componentName, String permissionName, String componentType, String settings) {
        System.debug('CarouselController: saveSettings: componentConfigId' + componentConfigId);
	    
        String communityId = CommunityHelper.getCurrentCommunitId(); 

        System.debug('CarouselController: saveSettings: communityId' + communityId);
		ComponentConfigHelper.saveSettings(componentConfigId, communityId, componentName, permissionName, componentType, settings);
    }
    

    @AuraEnabled
    public static ImageTileResult getComponentConfig(String componentName, String componentType, 
                                                             String permissionName) {
        String communityId = CommunityHelper.getCurrentCommunitId();
        System.debug('CarouselController: getComponentConfi: Community ID from API is .... ' + communityId);
                
        ImageTileResult itList = new ImageTileResult();
        itList.communityId = communityId;
    	itList.componentConfig = ComponentConfigHelper.getComponentConfigJson(communityId, componentName, componentType);
       String  communityName= getUserContexttiler();
        system.debug(' ###### communityName in carousel'+communityName);
        itList.languagesByCountry = CommunityHelper.getLocaleByCountry(communityName);
        boolean isComponentAdmin = false;
        if ((permissionName != null) & (!permissionName.equals(''))) {
	        isComponentAdmin = CommunityUtilities.hasPermissionSet(permissionName);                                                                
        }       
        itList.isComponentAdmin = isComponentAdmin;
        return itList;        
    }
    public static String getUserContexttiler() {
	 	String userInfo = getUserInfo();

        String currentCommunityId = CommunityHelper.getCurrentCommunitId();

        String currentCommunityName = CommunityHelper.getCommunityName(currentCommunityId);
        
        return currentCommunityName;
    }
 
    public static String getUserInfo() {
	 	UserLocaleInfo ul = CommunityHelper.getUser();
        return JSON.serialize(ul);
    }


    
}