public without sharing class FeaturedArticlesController {

    @AuraEnabled
    public static List<KnowledgeArticleVersion> getArticlesByDataCategories(String dataCategoriesFilterJson, 
                                                                        	Integer maxRecords,
                                                                        	String languageCode, 
                                                                            String countryCode, 
                                                                           	String communityName) {        
		String dataCategorySoql = '';                                                                                                                                        	
        String[] dataCategoriesFilter = dataCategoriesFilterJson.split(',');
        for (String dataCategoryFilter : dataCategoriesFilter) {
        	String[] dataCategoryMap = dataCategoryFilter.split(':');
            String dataCategoryType = dataCategoryMap[0];
  			String dataCategoryValue = dataCategoryMap[1];    
            String dataCategoryValues = '';
            
            /*
             * Code to handle Multiple Data Categories
             * 
            if (!dataCategoryValues.equals(''))
            	dataCategoryValues += ', ' + dataCategoryValue;
             else
                    dataCategoryValues += dataCategoryValue;
           if (!dataCategoryValues.equals('')) {
                dataCategoryValues = '(' + dataCategoryValues + ')';
			*/
          	dataCategoryValues = '(' + dataCategoryValue + ')';
            if (dataCategorySoql.equals('')) {
            	dataCategorySoql = ' WITH DATA CATEGORY ' + dataCategoryType + ' BELOW ' +  dataCategoryValues;
           	}
            else {
            	dataCategorySoql += ' AND ' + dataCategoryType + ' BELOW ' +  dataCategoryValues;
          	}
      	}
		String languageLocaleCode = CommunityHelper.getLocaleForCommunityCountryAndLanguage(countryCode, languageCode, communityName); //CommunityLocaleUtil.lang2key.get(languageCode);
		System.debug('FeaturedArticlesController: getArticlesByDataCategories: language locale code ' + languageLocaleCode + ', for language code ' + languageCode + ' and country code ' + countryCode);

        List<KnowledgeArticleVersion> kavList = KnowledgeHelper.getArticlesByDataCategories(languageLocaleCode, dataCategorySoql);    
        return kavList;
	}                                                                            

   	@AuraEnabled
    public static FeaturedArticlesResult getComponentConfig(String componentName, String componentType, 
                                                            String communityName, String permissionName) {
        String communityId = CommunityHelper.getCurrentCommunitId();
        FeaturedArticlesResult faList = new FeaturedArticlesResult();
        faList.componentTitle = Label.CUST_COMMUNITY_FEATURED_ARTICLES_LABEL;
        faList.emptyDataSetMessage = Label.CUST_COMMUNITY_FEATURED_ARTICLES_EMPTY_DATASET_MESSAGE;
        faList.communityId = communityId;
    	faList.componentConfig = ComponentConfigHelper.getComponentConfigJson(communityId, componentName, componentType);
                                                                
        boolean isComponentAdmin = false;
        if ((permissionName != null) & (!permissionName.equals(''))) {
	        isComponentAdmin = CommunityUtilities.hasPermissionSet(permissionName);                                                                
        }       
        if (isComponentAdmin) {
            faList.isComponentAdmin = true;
	        faList.dataCategoryGroups = getDataCategoryGroups();
	        faList.languages = getCommunityLanguages(communityName);
        }
        else {
            faList.isComponentAdmin = false;
            faList.dataCategoryGroups = new List<DataCategoryGroupModel>();
            faList.languages = '[]';
        }
        return faList;        
    }

   	@AuraEnabled
    public static String getCommunityLanguages(String communityName) {
        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(communityName);
        String[] languageList = communityConfig.Language_Code__c.split(';');        
        
        //retrieve languages associated with the community
        String languagesJson = CommunityHelper.getLanguagesByCommunity(languageList);
   		return languagesJson;
    }
    
   	@AuraEnabled
    public static List<DataCategoryGroupModel> getDataCategoryGroups() {
    	List<DataCategoryGroupModel> dcGroups = new List<DataCategoryGroupModel>();
    	List<DataCategoryGroupSobjectTypePair> kdcGroups = KnowledgeHelper.getAllKnowledgeDataCategoryGroups();
        for (DataCategoryGroupSobjectTypePair kdcPair : kdcGroups) {
        	String kdcGroupName = kdcPair.getDataCategoryGroupName();
			String kdcSObject = kdcPair.getSobject();
            DataCategoryGroupModel dcgModel = KnowledgeHelper.getDataCategoryValues(kdcSObject, kdcGroupName);
            dcGroups.add(dcgModel);
        }
        return dcGroups;
    }
    
    @AuraEnabled
    public static void saveSettings(String componentConfigId, String communityId, String componentName, String componentType, String settings,String permissionName) {
        if ((communityId == null) || (communityId.length() == 0)) {
	        communityId = CommunityHelper.getCurrentCommunitId();        
        }
        
		ComponentConfigHelper.saveSettings(componentConfigId, communityId, componentName, permissionName, componentType, settings);
    }

    class CustomCommunityException extends Exception {}

}