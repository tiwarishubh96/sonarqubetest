public with sharing class CommunityHeaderController {
    /*
     * Main function that builds the JSON string associated with all
     * Picklists (Language, Country, Community Switcher) in the Navigation Header.
    *  @author
    *  @return a JSON string with all picklists
     */
    @AuraEnabled
    public static String getNavigationHeaderPicklists() {
        //generate all the picklist values into a JSON string
        String navHeaderJson = '{';
  
        
        String currentCommunityId = CommunityHelper.getCurrentCommunitId();

        String currentCommunityName = CommunityHelper.getCommunityName(currentCommunityId);
		
        
        //retrieve list of communities to be displayed
        List<CommunitiesAvailable> communities = getCommunities();
        String communitiesJSON = JSON.serialize(communities);
        navHeaderJson += '"communitiesList": ' + communitiesJSON;

        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(currentCommunityName);
            
        String[] countryList = communityConfig.Country_Code__c.split(';');
        String[] languageList = communityConfig.Language_Code__c.split(';');
        
        //retrieve languages associated with the community
        String languagesJson = CommunityHelper.getLanguagesByCommunity(languageList);
        navHeaderJson += ',"languagesList": ' + languagesJson;

        //retrieve countries associated with the community
        String countriesJson = CommunityHelper.getCountriesByCommunity(countryList);
        navHeaderJson += ',"countriesList": ' + countriesJson;

        //retrieve list of Country and Languages
        String countryLanguageMappingJson = CommunityHelper.getLanguagesByCountry(currentCommunityName);
        navHeaderJson += ',"countryLanguageMapping": ' + countryLanguageMappingJson;

        //retrieve current user info
        String userJson = getUser();
        navHeaderJson += ',"userInfo": ' + userJson;
        String profile=getUserprofile();
          Boolean displayCommunitySelector;
          Boolean flag=false;
       
 
        
         List<Partner_Community_Profiles__c> listB = Partner_Community_Profiles__c.getAll().values(); 
for(Integer i=0;i<listB.size();i++){
    
        if(profile==listB[i].Profile__c){
            flag = true; 
            
        }
        
}
            
     displayCommunitySelector = communityConfig.Display_Community_Selector__c;
    	Boolean displayLanguageSelector = communityConfig.Display_Language_Selector__c;
    	Boolean displayCountrySelector = communityConfig.Display_Country_Selector__c;
        
        System.debug('displayCommunitySelector: ' + displayCommunitySelector);
        navHeaderJson += ',"displayCommunitySelector": "' + displayCommunitySelector + '"';
        navHeaderJson += ',"displayLanguageSelector": "' + displayLanguageSelector + '"';
        navHeaderJson += ',"displayCountrySelector": "' + displayCountrySelector + '"';
         navHeaderJson += ',"flag": "' + flag + '"';
        navHeaderJson += '}';
            
    
system.debug('navHeaderJson :'+navHeaderJson);
       	return navHeaderJson;
    }
    
 public static String getUserprofile() {
        id id1 = userinfo.getProfileId();
String ProfieName=[select Name from profile where id = :id1].Name;
        return ProfieName;
    }
    
   	/**
    *  Method to get the list of communities that a user has access to
    *  @author
    *  @return a list of wrapper objects that represents each of the communities a user has acccess to
    */
    @AuraEnabled
    public static List<CommunitiesAvailable> getCommunities(){
        List<CommunitiesAvailable> communities = new List<CommunitiesAvailable>();
        try {
			List<ConnectAPI.Community> communityList = CommunityHelper.getAllCommunities();
            // Iterate over the available communities
            for(ConnectApi.Community commItem : communityList){
                CommunitiesAvailable c = new CommunitiesAvailable();
                c.name = commItem.name;
                c.switchUrl = commItem.siteUrl;
                communities.add(c);
            }
        }
        catch (Exception ex) {
            System.debug('Anonymous user will get an exception. Suppressing the message');
        }
        return communities;
    }

    /*
     * Method to return the current logged in user information
     * @author
     * @return	JSON String containing User info
	 */
    @AuraEnabled
    public static String getUser() {
	 	UserLocaleInfo ul = CommunityHelper.getUser();
        return JSON.serialize(ul);
    }

    /*
     * Method to update the Locale and Language information in User Profile
     * for the current user
     * @author
     * @return	Updated Language Locale String
	 */
    @AuraEnabled
    public static String updateUserLanguageAndLocale (String newLanguage, String newCountry, String communityName) {
    	String languageCode; // language which to change
        String countryCode; //changed language
        String changedLang;
        String result; //return value

        languageCode = CommunityHelper.getLocaleForCommunityCountryAndLanguage(newCountry, newLanguage, communityName);
        countryCode = CommunityHelper.getLocaleSIDKey(newCountry);

      	if (Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.Fields.LanguageLocaleKey.isAccessible()) {
        	User me = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            if (Schema.SObjectType.User.isUpdateable() && Schema.SObjectType.User.Fields.LanguageLocaleKey.isUpdateable()) {
            	me.LanguageLocaleKey = languageCode;
				me.LocaleSidKey = countryCode;
    			update me;
                changedLang = languageCode;
            } 
            else {
                changedLang = me.LanguageLocaleKey;
            }
            result = changedLang;
         } else {
             result = '--no language--';
         }
         return result;
     }

	/**
      * @description Wrapper class to list the communities a user has acccess to
      */
    public class CommunitiesAvailable {
        @AuraEnabled public String name;
        @AuraEnabled public String switchUrl;
    }
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
    @AuraEnabled
    public static String getUserInfo() {
	 	UserLocaleInfo ul = CommunityHelper.getUser();
        return JSON.serialize(ul);
    }
   
   
}