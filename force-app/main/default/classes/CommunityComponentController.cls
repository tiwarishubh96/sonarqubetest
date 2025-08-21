public with sharing class CommunityComponentController {

	/*
     * Method to return the current logged in user information
     * @author
     * @return	JSON String containing User info
	 */
    @AuraEnabled
    public static String getUserInfo() {
	 	UserLocaleInfo ul = CommunityHelper.getUser();
        return JSON.serialize(ul);
    }

    /*
     * Method to retrieve the entire User Context
     * Community Name, ID, Mapping of Language & Country to Locales,
     * UserInfo etc.
     */ 
    @AuraEnabled
    public static String getUserContext() {
	 	String userInfo = getUserInfo();

        String currentCommunityId = CommunityHelper.getCurrentCommunitId();

        String currentCommunityName = CommunityHelper.getCommunityName(currentCommunityId);
		
        List<Community_Country_Language__c> allLanguageLocales = CommunityHelper.getAllLanguageLocales(currentCommunityName);
        System.debug('###CommunityHeader: getUserContext: allLanguageLocales ' + allLanguageLocales);
        String allLanguageLocaleJson = Json.serialize(allLanguageLocales);
        
        String userContext = '{"user":' + userInfo + ', ';
        userContext += '"allLanguageLocales":' + allLanguageLocaleJson;
        userContext += ', "communityId": "' + currentCommunityId + '", ';
        userContext += '"communityName": "' + currentCommunityName + '"}';
        
        return userContext;
    }

    /*
     * Method to retrieve the Current Community Id
     */ 
    @AuraEnabled
    public static String getCurrentCommunityId() {
	 	String communityId = CommunityHelper.getCurrentCommunitId();
        return communityId;
    }
}