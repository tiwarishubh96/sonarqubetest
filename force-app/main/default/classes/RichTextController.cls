public without sharing class RichTextController {
    
    @AuraEnabled
    public static ImageTileResult getComponentConfig(String componentName,
                                                     String componentType, 
                                                     String permissionName) 
    {
        String communityId = CommunityHelper.getCurrentCommunitId();
        ImageTileResult itList = new ImageTileResult();
        itList.communityId = communityId;
        itList.componentConfig = ComponentConfigHelper.getComponentConfigJson(communityId, componentName, componentType);
        boolean isComponentAdmin = false;
        if ((permissionName != null) & (!permissionName.equals(''))) {
            isComponentAdmin = CommunityUtilities.hasPermissionSet(permissionName);                                                                
        }       
        itList.isComponentAdmin = isComponentAdmin;
        return itList;        
    }
    
    @AuraEnabled
    public static String getCountriesList(String communityName) 
    { 
        List<Community_Country_Language__c> communityCountryLanguages = [Select Name, Country__c, Country_Code__c, Default_Language__c, Language_Code__c, Language_Locale_Key__c,Locale__c,Language__r.Name ,Country__r.Country_Label__c  from Community_Country_Language__c WHERE Community_Name__c INCLUDES (:communityName)];
       
         String countryLabel='';
         String languageLabel='';
         String countryList = '[';
        for(Community_Country_Language__c localeItem : communityCountryLanguages) {
            
            String countryCode = localeItem.Country_Code__c;
            String languageCode = localeItem.Language_Code__c;
            String localeKey = localeItem.Locale__c;
            String countryLanguageCode = languageCode+'_'+countryCode.toUpperCase();
            countryLabel=localeItem.Country__r.Country_Label__c;
            languageLabel =localeItem.Language__r.Name;
            if(countryLanguageCode ==localeKey ){
                    if (countryList.equals('[')) {
                        countryList += '{"countryCode": "' + countryCode + '", "languageCode": "' + languageCode + '", "localeKey": "' + localeKey + '", "countryLabel": "' + countryLabel + '", "languageLabel": "' + languageLabel + '"}';
                    }
                    else {
                        countryList += ',{"countryCode": "' + countryCode + '", "languageCode": "' + languageCode + '", "localeKey": "' + localeKey + '", "countryLabel": "' + countryLabel + '", "languageLabel": "' + languageLabel + '"}';
                    }
            }
            
                
            
        }

        countryList += ']';
         return countryList;
        /*
         system.debug('communityName : '+communityName);
        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(communityName);
        system.debug('communityConfig : '+communityConfig);
        String[] countryList = communityConfig.Country_Code__c.split(';');
        System.debug('CommunityNavigationController: getNavigationHeaderPicklists countryList: ' + countryList);
        system.debug('countryList : '+countryList);
        //retrieve countries associated with the community
        String countriesJson = RichTextController.getCountriesByCommunity(countryList);  
        
        system.debug('Country Json : '+countriesJson);
        return countriesJson;   */   
       
    }
                              
    
    
    /*
    public static String getCountriesByCommunity(String[] countries) 
    {
        //Customer Community Config
        List<Community_Country_Mapping__c> communityCountries = [SELECT Country_Code__c, toLabel(Country_Label__c),Locale_SID_Key__c FROM Community_Country_Mapping__c];
        String countryList = '[';
        for(Community_Country_Mapping__c countryItem : communityCountries) {
            String countryCode = countryItem.Country_Code__c;
            String countryLabel = countryItem.Country_Label__c;
            String countryLocale = countryItem.Locale_SID_Key__c;
            for (String country : countries) {
                if (countryCode.equals(country)) {
                    if (countryList.equals('[')) {
                        countryList += '{"countryLocale": "' + countryLocale + '", "countryCode": "' + countryCode + '", "countryLabel": "' + countryLabel + '"}';
                    }
                    else {
                        countryList += ',{"countryLocale": "' + countryLocale + '", "countryCode": "' + countryCode + '", "countryLabel": "' + countryLabel + '"}';
                    }
                }
            }
        }
        
        countryList += ']';
        system.debug('List : '+countryList);
        return countryList;
    }
*/
    
    @AuraEnabled
    public static void saveRichTextSettings(String componentConfigId, 
                                            String componentName, 
                                            String componentType, 
                                            String permissionName, 
                                            String settings) 
    {
        String communityId = CommunityHelper.getCurrentCommunitId(); 
        ComponentConfigHelper.saveSettings(componentConfigId, communityId, componentName, permissionName, componentType, settings);
    }
}