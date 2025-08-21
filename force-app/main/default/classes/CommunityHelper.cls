public without sharing class CommunityHelper {

    /*
     * Utility method to return ID of the Community based on Name
     * @param       communityName
     * @return      a string with ID for the Community
     */ 
    public static String getCommunityId(String communityName) {
        String communityId = '';
        List<ConnectAPI.Community> communities = getAllCommunities();
        for (ConnectAPI.Community community : communities) {
            if (communityName.equals(community.name)) {
                communityId = community.id;
            }
        }
        return communityId;
    }

    /*
     * Utility method to return the current Community Id
     */ 
    public static String getCurrentCommunitId() {
        Id networkId ;
        if( !test.isrunningtest() ){
            networkId = Network.getNetworkId();             
        }else 
        {
            // The below is added to address the issue of not able to retrieve network id in test class.
            networkId = System.Label.PartnerCommunityId;
         }
        String communityId = networkId;
        return communityId;
    }

    /*
     * Utility method to retrieve list of all Communities
     */ 
    public static List<ConnectAPI.Community> getAllCommunities() {
        ConnectAPI.CommunityPage communityPage = ConnectAPI.Communities.getCommunities(ConnectApi.CommunityStatus.Live);
        List<ConnectAPI.Community> communities = communityPage.communities;
        return communities;
    }

    /*
     * Utility method to retrieve a list of all Navigational Topic configured
     * for a given Community
     */ 
    public static List<ConnectApi.ManagedTopic> getNavigationalTopics(String communityId) {
        ConnectApi.ManagedTopicCollection managedCollection = ConnectAPI.ManagedTopics.getManagedTopics(communityId, ConnectApi.ManagedTopicType.Navigational);
        return managedCollection.managedTopics;
    }

    /*
     * Utility method to retrieve Child Navigational topics associated with a Parent Navigational Topic
     */ 
    public static List<ConnectApi.ManagedTopic> getNavigationalTopicsByParent(String communityId, String parentTopicId) {
        List<String> parentTopics = new List<String>();
        parentTopics.add(parentTopicId);
        ConnectApi.ManagedTopicCollection managedCollection = ConnectAPI.ManagedTopics.getManagedTopics(communityId, ConnectApi.ManagedTopicType.Navigational, parentTopics, 2);
        List<ConnectApi.ManagedTopic> childTopics = new List<ConnectApi.ManagedTopic>();
        for (ConnectApi.ManagedTopic parentTopic : managedCollection.managedTopics) {
            if (parentTopic.children != null) {
                childTopics = parentTopic.children;
            }
        }
        return childTopics;
    }

    /*
     * Method to retrieve Community configuration by Name.
     * @author
     * @return Returns Community Config information
     */
    public static Community_Config__c getCommunityConfig(String communityName) {
        system.debug('communityName = '+communityName);
        //communityName = 'Sage Partner Community';
        Community_Config__c communityConfig = [SELECT Language_code__c, Country_Code__c, Community_Name__c, Display_Community_Selector__c, Display_Language_Selector__c, Display_Country_Selector__c FROM Community_Config__c WHERE Community_Name__c = :communityName  LIMIT 1];
        return communityConfig;
    }

    /*
     * Utility method to retrieve a Map of Countries and Languages associated with each of them
     */ 
    public static String getLanguagesByCountry(String communityName) {
         //SELECT ID, Country__c, Language__c, Default_Language__C FROM Community_Country_Language__c
        /* String countryLanguageMapping = '[';
        countryLanguageMapping += '{"countryCode": "us", "languageCodes":["en"], "default": "en"}';
        countryLanguageMapping += ',{"countryCode": "fr", "languageCodes":["fr","en"], "default": "fr"}';
        countryLanguageMapping += ',{"countryCode": "es", "languageCodes":["es","en"], "default": "es"}';
        countryLanguageMapping += ',{"countryCode": "de", "languageCodes":["de","en"], "default": "de"}';
        countryLanguageMapping += ',{"countryCode": "ca", "languageCodes":["fr","en"], "default": "en"}';
        countryLanguageMapping += ']';
        return countryLanguageMapping; */ 
        
        Map<String,List<Community_Country_Language__c>> CountryMap = null;
        string JSONString  = '';
        string defaultLanguage = 'en';
        
        List<Community_Country_Language__c> CountryList = getAllLanguageLocales(communityName);
        
        /*
         * Loop through list of Country Language List and 
         * build the Mapped Languages for each Country
         */ 
        CountryMap = new Map<String,List<Community_Country_Language__c>>();
        //Loop through Country List to Map it Based on country code
        for(Community_Country_Language__c country : CountryList){
            if(CountryMap.containsKey(country.Country_Code__c)){
                List<Community_Country_Language__c> conList = CountryMap.get(country.Country_Code__c);
                conList.add(country);
                CountryMap.put(country.Country_Code__c, conList);
            } else { 
                CountryMap.put(country.Country_Code__c, new List<Community_Country_Language__c> { country });
            }
        }
        
        //build the JSON String with Languages for each country and the default
        integer count = 0, count1 = 0; // Count to Check the no. of Languages for a country
        // Start of Creating Json String
        JSONString = '[';
        // Looping Through the respective Country to get all Languages of the country with their default language
        set<String> keys = CountryMap.keySet();
        integer keyCount = keys.size();
        for(String str: CountryMap.keySet()){
            if(CountryMap.containsKey(str)){
                count = 0;
                JSONString += '{"countryCode": "' + str + '", "languageCodes":["';
                for(Community_Country_Language__c con: CountryMap.get(str)){
                    if(con.Default_Language__c){
                        defaultLanguage = con.Language_Code__c;
                    }
                    if(count > 0){
                        JSONString += ',"';
                    }
                    JSONString += con.Language_Code__c + '"';
                    count++;
                }
                JSONString += '], "default": "' + defaultLanguage + '"}';
                count1++;
                if(keyCount-1 >= count1){
                    JSONString += ',';
                }
            }
        }
        JSONString += ']';
        return JSONString;
    }
    
    /*
     * Method to retrieve Language Code(s) and Label(s) associated with the Community
     * @author
     * @return  JSON string containing a list of Language Code and Label(s)
     */
    public static String getLanguagesByCommunity(String[] languages) {
        //Customer Community Config
        List<Community_Language_Mapping__c> communityLanguages = [SELECT Language_Code__c, toLabel(Language_Label__c) FROM Community_Language_Mapping__c ORDER BY Language_Label__c ASC];
        String languageList = '[';
        for(Community_Language_Mapping__c langItem : communityLanguages) {
            String languageCode = langItem.Language_Code__c;
            String languageLabel = langItem.Language_Label__c;
            for (String language: languages) {
                if (languageCode.equals(language)) {
                    if (languageList.equals('[')) {
                        languageList += '{"languageCode": "' + languageCode + '", "languageLabel": "' + languageLabel + '"}';
                    }
                    else {
                        languageList += ',{"languageCode": "' + languageCode + '", "languageLabel": "' + languageLabel + '"}';
                    }
                }
            }
        }
        languageList += ']';
        return languageList;
    }

    /*
     * Method to return a list of Countries associated with the Community
     * @author
     * @return  Return a JSON string containing a list of Country Code(s) and Label(s)
     */
    public static String getCountriesByCommunity(String[] countries) {
        //Customer Community Config
        List<Community_Country_Mapping__c> communityCountries = [SELECT Country_Code__c, toLabel(Country_Label__c) FROM Community_Country_Mapping__c];
        String countryList = '[';
        for(Community_Country_Mapping__c countryItem : communityCountries) {
            String countryCode = countryItem.Country_Code__c;
            String countryLabel = countryItem.Country_Label__c;
            for (String country : countries) {
                if (countryCode.equals(country)) {
                    if (countryList.equals('[')) {
                        countryList += '{"countryCode": "' + countryCode + '", "countryLabel": "' + countryLabel + '"}';
                    }
                    else {
                        countryList += ',{"countryCode": "' + countryCode + '", "countryLabel": "' + countryLabel + '"}';
                    }
                }
            }
        }

        countryList += ']';

        return countryList;
    }
    
    
    
    /*
     * Method to return a list of Countries associated with the Community
     * @author
     * @return  Return a JSON string containing a list of Country Code(s) and Label(s) and Language(s)
     */
    //code added by Ravi
    public static String getLocalesByCommunity(String[] countries, String communityName) {
        system.debug('communityName = '+communityName);
        system.debug('in getLocalesByCommunity = ');
        //Customer Community Config
        String query = 'SELECT Id, Locale__c, Country__r.Name, Country__r.Country_Code__c, toLabel(Country__r.Country_Label__c), Language__r.Name '
                        + ' FROM Community_Country_Language__c where Country__r.Country_Code__c IN :countries '
                        + ' and Community_Name__c INCLUDES (\'' + communityName +'\')';
        String countryList = '[';
        for(SObject so : Database.query(query)) {
            Community_Country_Language__c item = (Community_Country_Language__c)so;
            String countryCode = item.Locale__c;
            String countryLabel = item.Country__r.Country_Label__c;
            String languageCountryLabel = item.Language__r.Name + ' (' + item.Country__r.Name +')';
            if (countryList.equals('[')) {
                countryList += '{"countryCode": "' + countryCode + '", "countryLabel": "' + countryLabel + '", "languageCountryLabel": "' + languageCountryLabel + '"}';
            }
            else {
                countryList += ',{"countryCode": "' + countryCode + '", "countryLabel": "' + countryLabel + '", "languageCountryLabel": "' + languageCountryLabel + '"}';
            }

        }

        countryList += ']';

        return countryList;
    }
    
    /*
     * Helper method to retrieve Language locale based on the mapping for a country and language
     */ 
    public static String getLocaleForCommunityCountryAndLanguage(String countryCode, String languageCode, String communityName) {
        String languageLocale = 'en_US';
        List<Community_Country_Language__c> communityCountryLanguages = [Select Name, Country__c, Country_Code__c, Default_Language__c, Language_Code__c, Language_Locale_Key__c from Community_Country_Language__c WHERE  Language_Code__c = :languageCode AND Country_Code__c = :countryCode AND Community_Name__c INCLUDES (:communityName)];
        for(Community_Country_Language__c communityCountryLanguage : communityCountryLanguages) {
            String languageLocaleName = communityCountryLanguage.name;
            languageLocale = communityCountryLanguage.Language_Locale_Key__c; //CommunityLocaleUtil.langLocale2key.get(languageLocaleName);
        }   
        return languageLocale;
    }

    /*
     * Method to retrieve a list of all Language locales
     */ 
    public static List<Community_Country_Language__c> getAllLanguageLocales(String communityName) {
        List<Community_Country_Language__c> communityCountryLanguages = [Select Name, Country__c, Country_Code__c, Default_Language__c, Language_Code__c, Language_Locale_Key__c,Locale__c  from Community_Country_Language__c WHERE Community_Name__c INCLUDES (:communityName)];
        return communityCountryLanguages;
    }
    
    public static UserLocaleInfo getUser() {        
        User me = [SELECT Name, LanguageLocaleKey,ContactId,Contact.AccountId,LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        UserLocaleInfo ul = new UserLocaleInfo();
        ul.UserName = me.Name;
        ul.LanguageKey = me.LanguageLocaleKey;
        ul.LocaleKey = me.LocaleSidKey;

        return ul;
    }
    
    /*
     * Utility method to return Name of the Community based on ID
     * @param       communityId
     * @return      a string with ID for the Community
     */ 
    public static String getCommunityName(String communityId) {
        String communityName = '';
        if( !test.isrunningtest() ){
            Network community = [SELECT Name FROM NETWORK WHERE Id = :communityId];
            communityName = community.Name;
            system.debug('communityId = '+communityId +' communityName = '+communityName);
        }
        else {
            communityName = 'Sage Partner Community';
        }            
        return communityName;
    }
    
    /*
     * Method to return the Locale SID Key associated with the Country Code
     * @author
     * @return  Return a JSON string 
     */
    public static String getLocaleSIDKey(String countryCode) {
       Community_Country_Mapping__c communityCountry = [SELECT Locale_SID_Key__c FROM Community_Country_Mapping__c WHERE Country_Code__c = :countryCode LIMIT 1];

        return communityCountry.Locale_SID_Key__c;
    }
     public static String getUserCountryName(String countryCode ){
        Community_Country_Mapping__c communityCountry = [SELECT Name FROM Community_Country_Mapping__c WHERE Country_Code__c = :countryCode LIMIT 1];
       system.debug('communityCountry.Name'+communityCountry.Name);
         return communityCountry.Name;
    }
    
    public static String getLocaleByCountry(String communityName ){
        system.debug('@@ countryList:'+communityName);
         List<Community_Country_Language__c> communityCountryLanguages = [Select Name, Country__c, Country_Code__c, Default_Language__c, Language_Code__c, Language_Locale_Key__c,Locale__c,Language__r.Name ,Country__r.Country_Label__c  from Community_Country_Language__c WHERE Community_Name__c INCLUDES (:communityName) ORDER BY Country__r.Country_Label__c desc];
       system.debug('@@ countryList:'+communityCountryLanguages);
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
        system.debug('@@ countryList:'+countryList);
         return countryList;
       
    }
    /*
     * Utility method to return Partner Type/Tier Mapping of the Community based on ID
     * @param       communityId
     * @return      a string with ID for the Community
     */ 
    public static map<string,list<string>> getPartnerTypeTierMapping(String communityId) {
        map<string,list<string>> partnerTypeWithTier=new map<string,list<string>>();
        for(CommunitiesUIConfig__mdt communitiesUIConfigObj : [select id,Partner_Tier__c,Partner_Type__c from CommunitiesUIConfig__mdt where CommunityId__c=:communityId order by Partner_Tier__c ]){
            if(partnerTypeWithTier.containsKey(communitiesUIConfigObj.Partner_Type__c))
                partnerTypeWithTier.get(communitiesUIConfigObj.Partner_Type__c).add(communitiesUIConfigObj.Partner_Tier__c);
            else{
                partnerTypeWithTier.put(communitiesUIConfigObj.Partner_Type__c,new list<string>{communitiesUIConfigObj.Partner_Tier__c});
            }
        }
        return partnerTypeWithTier;
    }
    public static user getLoggedinUserInfo(){
        return [Select contactid,contact.AccountId from User where id =: Userinfo.getUserid()];
    }
    public static Account getLoggedinUserAccountInfo(id accountId){
        return [Select id,Partner_Accountant_TnC__c,Partner_Alliance_TnC__c,Partner_ISV_TnC__c,Partner_Reseller_TnC__c,Partner_Implementation_TnC__c,Accountant_Partner_Tier__c,Reseller_Partner_Tier__c,ISV_Partner_Tier__c,Alliance_Partner_Tier__c,SI_Partner_Tier__c  from Account  where id =: accountId];
    }
}