public without sharing class FeaturedTopicController_v2 {
  
    @AuraEnabled
    public static String getCountriesList() {
          String currentCommunityId = CommunityHelper.getCurrentCommunitId();
        system.debug('currentCommunityId = '+currentCommunityId);
        String communityName = CommunityHelper.getCommunityName(currentCommunityId); 
        system.debug('communityName = '+communityName);
        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(communityName);
        String[] countryList = communityConfig.Country_Code__c.split(';');
        System.debug('CommunityNavigationController: getNavigationHeaderPicklists countryList: ' + countryList);
        
        //retrieve countries associated with the community
        String countriesJson = CommunityHelper.getCountriesByCommunity(countryList);  
        system.debug('countriesJson = '+countriesJson);
        return countriesJson;                            
    }
    
    //Method added by Ravi
    @AuraEnabled
    public static String getCountriesListWithLanguage() {
          String currentCommunityId = CommunityHelper.getCurrentCommunitId();

        String communityName = CommunityHelper.getCommunityName(currentCommunityId); 
        System.debug('in getCountriesListWithLanguage communityName = '+communityName);
        //retrieve the country and language code list configured for the current community
        Community_Config__c communityConfig = CommunityHelper.getCommunityConfig(communityName);
        String[] countryList = communityConfig.Country_Code__c.split(';');
        System.debug('CommunityNavigationController: getNavigationHeaderPicklists countryList: ' + countryList);
        
        //retrieve countries associated with the community
        String countriesJson = CommunityHelper.getLocalesByCommunity(countryList,communityName);  
        system.debug('countriesJson = '+countriesJson);
        return countriesJson;                            
    }
   
    
     @AuraEnabled
    public static void saveSettings(String componentConfigId, String componentName, String componentType, String permissionName, String settings) {
        System.debug('FeaturedTopicsController: saveSettings: componentConfigId' + componentConfigId);
        

        String communityId = CommunityHelper.getCurrentCommunitId(); 
        
        System.debug('FeaturedTopicsController: saveSettings: communityId' + communityId);
        ComponentConfigHelper.saveSettings(componentConfigId, communityId, componentName, permissionName, componentType, settings);
    }
     @AuraEnabled
    public static Void deleteDocumentImages(List<ID> imageIDs) {
        for(ID i:imageIDs){
           List<document> v=[select id,Name from document where id=:i];
         delete v;
        }
                            
    }
    
    @AuraEnabled
    public static ImageTileResult getComponentConfig(String componentName, String componentType, 
                                                           String permissionName) {
                                                               
                                                             
        String communityId = CommunityHelper.getCurrentCommunitId();
        System.debug('ImageTileController: getComponentConfi: Community ID from API is .... ' + communityId);
        /******************************** Get the logged in user details,Ravi **************************/
        User objUser = CommunityHelper.getLoggedinUserInfo();
        Account objAccount=new Account();
        boolean isInternalUser=true;
        /******************************** Get the logged in user Account details,Ravi **************************/
        if(objUser != null && objUser.ContactId != null && objUser.COntact.AccountId != null){
            objAccount = CommunityHelper.getLoggedinUserAccountInfo(objUser.COntact.AccountId);
            isInternalUser=false;
        }
                                                               
        /******************************** get the logic to display the images,Ravi **************************/
        map<string,string> accountPartnerTypeMap=getAccountPartnerType(objAccount);
        ImageTileResult itList = new ImageTileResult();
        itList.communityId = communityId;
        /******************************** parse the existing saved logic and compare with the logged in account,Ravi **************************/
        itList.componentConfig = ComponentConfigHelper.getComponentConfigJson(communityId, componentName, componentType);
        Map<String,Object> responsemap = (Map<String,Object>) json.deserializeUntyped(itList.componentConfig);  
        if(responsemap != null && responsemap.containsKey('Settings')){
            Map<String,Object> compSettingsMap = (Map<String,Object>)responsemap.get('Settings'); 
            system.debug('**compSettingsMap**'+compSettingsMap);
            if(compSettingsMap != null && compSettingsMap.containsKey('images')){
                 Object[] compSettingsImagesMap = (Object[])compSettingsMap.get('images');
                 system.debug('**compSettingsImagesMap**'+compSettingsImagesMap);
                 list<Object> lstObject=new list<Object>();
                 if(compSettingsImagesMap != null){
                    for(Object objString : compSettingsImagesMap){
                        system.debug('**objString**'+objString);
                        Map<String,Object> responsemapObject = (Map<String,Object>) json.deserializeUntyped(json.serialize(objString));  
                        system.debug('**responsemapObject**'+responsemapObject);
                        if(!isInternalUser){
                            if(responsemapObject != null && responsemapObject.containsKey('tiers')){
                                system.debug('**responsemapObject**'+responsemapObject.get('tiers'));
                                list<PartnerTypeTier> lstPartnerTypeTeir=(list<PartnerTypeTier>)json.deserialize(json.serialize(responsemapObject.get('tiers')),list<PartnerTypeTier>.class);
                                set<string> setSelectedPartnerType=new set<string>();
                                boolean isFound=false;
                                responsemapObject.put('isDisplay',false);
                                system.debug('**After Added responsemapObject**'+responsemapObject);
                                for(PartnerTypeTier objPartnerTypeTier : lstPartnerTypeTeir){
                                    for(PartnerTypeTier.PartnerTier partnerTierObj : objPartnerTypeTier.partnerTierList){
                                        if(partnerTierObj.isSelected){
                                            if(accountPartnerTypeMap.containsKey('All') || (accountPartnerTypeMap.containsKey(objPartnerTypeTier.partnerTypeName) && accountPartnerTypeMap.get(objPartnerTypeTier.partnerTypeName) == 'All') ||
                                            (accountPartnerTypeMap.containsKey(objPartnerTypeTier.partnerTypeName) && accountPartnerTypeMap.get(objPartnerTypeTier.partnerTypeName) == partnerTierObj.partnerTierName)){
                                                responsemapObject.put('isDisplay',true);
                                                isFound=true;
                                                break;
                                            }
                                            
                                        }
                                    }
                                    if(isFound)
                                        break;
                                }
                                
                            }
                            system.debug('**After responsemapObject**'+responsemapObject);
                        }
                        else{
                            responsemapObject.put('isDisplay',true);
                        }
                        lstObject.add(responsemapObject);
                    }
                     system.debug('**After compSettingsImagesMap**'+compSettingsImagesMap);
                 }
                 compSettingsMap.put('images',lstObject);
             }
            responsemap.put('Settings',compSettingsMap);
            system.debug('**responsemapg**'+responsemap);      
            itList.componentConfig = json.serialize(responsemap);
        }                                   
        
        system.debug('**itList.componentConfig**'+itList.componentConfig);                                                   
    
    String  communityName= getUserContexttiler();
        system.debug(' ###### communityName'+communityName);
        itList.languagesByCountry = CommunityHelper.getLocaleByCountry(communityName);
        boolean isComponentAdmin = false;
        if ((permissionName != null) & (!permissionName.equals(''))) {
            isComponentAdmin = CommunityUtilities.hasPermissionSet(permissionName);                                                                
        }       
        itList.isComponentAdmin = isComponentAdmin;
        /******************************** set the default Partner Type and Teir,Ravi **************************/                                                            
        map<string,list<string>>  partnerTypeTierMap=CommunityHelper.getPartnerTypeTierMapping(communityId);  
        list<PartnerTypeTier>  partnerTypeTierList=new   list<PartnerTypeTier>();                                                 
        for(string partnerType :  partnerTypeTierMap.keyset()){
            PartnerTypeTier partnerTypeTierobj=new PartnerTypeTier();
            partnerTypeTierobj.partnerTypeName=partnerType;
            list<PartnerTypeTier.PartnerTier> partnerTierList=new list<PartnerTypeTier.PartnerTier>();
            partnerTypeTierMap.get(partnerType).sort();//added by Ravi to fix the order of PartnerTierList 22nd Jan 2019
            for(string partnerTierName : partnerTypeTierMap.get(partnerType)){
                PartnerTypeTier.PartnerTier partnerTierObj=new PartnerTypeTier.PartnerTier();
                partnerTierObj.partnerTierName=partnerTierName;
                partnerTierObj.isSelected=false;
                partnerTierList.add(partnerTierObj);
            }
            system.debug('partnerTierList = '+partnerTierList);
            partnerTypeTierobj.partnerTierList=partnerTierList;
            partnerTypeTierList.add(partnerTypeTierobj);                                                        
        }                                                       
        itList.partnerTypeTierList= partnerTypeTierList;  
        /***************************************** End Here********************************************************/
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

    /*********************************************************
     * @objAccount - logged in user account
     * This method is used to execute the logic to get the Partner Type and Teir for logged in user,Ravi
     * ********************************************************/
    public static map<string,string> getAccountPartnerType(Account objAccount){
        map<string,string> accountPartnerTypeMap=new map<string,string>();
        if((objAccount.Partner_Accountant_TnC__c == TRUE && objAccount.Accountant_Partner_Tier__c == null) || 
           (objAccount.Partner_Alliance_TnC__c == TRUE && objAccount.Alliance_Partner_Tier__c ==null) && 
           (objAccount.Partner_ISV_TnC__c == TRUE && objAccount.ISV_Partner_Tier__c== null) && 
           (objAccount.Partner_Reseller_TnC__c == TRUE && objAccount.Reseller_Partner_Tier__c == null)  &&
           (objAccount.Partner_Implementation_TnC__c == TRUE && objAccount.SI_Partner_Tier__c == null)){
            accountPartnerTypeMap.put('All','All');
            return accountPartnerTypeMap;
        }
        If(objAccount.Partner_Accountant_TnC__c == TRUE && objAccount.Accountant_Partner_Tier__c == 'Platinum'){
            accountPartnerTypeMap.put('Accountant','Platinum');
        }
        else If(objAccount.Partner_Accountant_TnC__c == TRUE && objAccount.Accountant_Partner_Tier__c == 'Silver'){
            accountPartnerTypeMap.put('Accountant','Silver');
        }
        else If(objAccount.Partner_Accountant_TnC__c == TRUE && objAccount.Accountant_Partner_Tier__c == 'Gold'){
            accountPartnerTypeMap.put('Accountant','Gold');
        }
        else If(objAccount.Partner_Accountant_TnC__c == TRUE && objAccount.Accountant_Partner_Tier__c == 'Authorized'){
            accountPartnerTypeMap.put('Accountant','Authorized');
        }
        else if(objAccount.Partner_Accountant_TnC__c == TRUE && objAccount.Accountant_Partner_Tier__c == null){
            accountPartnerTypeMap.put('Accountant','All');
        }
        If(objAccount.Partner_Alliance_TnC__c == TRUE && objAccount.Alliance_Partner_Tier__c == 'Global Sage'){
            accountPartnerTypeMap.put('Alliance','Strategic Alliance');
        }
        else If(objAccount.Partner_Alliance_TnC__c == TRUE && objAccount.Alliance_Partner_Tier__c == 'Corporate'){
            accountPartnerTypeMap.put('Alliance','Corporate Partner');
        }
        else If(objAccount.Partner_Alliance_TnC__c == TRUE && objAccount.Alliance_Partner_Tier__c == null){
            accountPartnerTypeMap.put('Alliance','All');
        }
        If(objAccount.Partner_ISV_TnC__c == TRUE && objAccount.ISV_Partner_Tier__c == 'RockStar'){
            accountPartnerTypeMap.put('ISV','Rockstar');
        }
        else if(objAccount.Partner_ISV_TnC__c == TRUE && objAccount.ISV_Partner_Tier__c == 'Champion'){
            accountPartnerTypeMap.put('ISV','Champion');
        }
        else if(objAccount.Partner_ISV_TnC__c == TRUE && objAccount.ISV_Partner_Tier__c == 'Whitelabel'){
            accountPartnerTypeMap.put('ISV','Whitelabel');
        }
        else if(objAccount.Partner_ISV_TnC__c == TRUE && (objAccount.ISV_Partner_Tier__c == 'Developer' || objAccount.ISV_Partner_Tier__c == 'Authorized')){
            accountPartnerTypeMap.put('ISV','Developer');
        }
        else If(objAccount.Partner_ISV_TnC__c == TRUE && objAccount.ISV_Partner_Tier__c == null){
            accountPartnerTypeMap.put('ISV','All');
        }
        If(objAccount.Partner_Reseller_TnC__c == TRUE && objAccount.Reseller_Partner_Tier__c == 'Platinum'){
            accountPartnerTypeMap.put('Reseller','Platinum');
        }
        else if(objAccount.Partner_Reseller_TnC__c == TRUE && objAccount.Reseller_Partner_Tier__c == 'Gold'){
            accountPartnerTypeMap.put('Reseller','Gold');
        }
        else if(objAccount.Partner_Reseller_TnC__c == TRUE && objAccount.Reseller_Partner_Tier__c == 'Silver'){
            accountPartnerTypeMap.put('Reseller','Silver');
        }
        else If(objAccount.Partner_Reseller_TnC__c == TRUE && objAccount.Reseller_Partner_Tier__c == 'Authorized'){
            accountPartnerTypeMap.put('Reseller','Authorized');
        }
        else If(objAccount.Partner_Reseller_TnC__c == TRUE && objAccount.Reseller_Partner_Tier__c == null){
            accountPartnerTypeMap.put('Reseller','All');
        }
        If(objAccount.Partner_Implementation_TnC__c == TRUE && objAccount.SI_Partner_Tier__c == 'Platinum'){
            accountPartnerTypeMap.put('System Implementer','Platinum');
        }
        else if(objAccount.Partner_Implementation_TnC__c == TRUE && objAccount.SI_Partner_Tier__c == 'Gold'){
            accountPartnerTypeMap.put('System Implementer','Gold');
        }
        else if(objAccount.Partner_Implementation_TnC__c == TRUE && objAccount.SI_Partner_Tier__c == 'Silver'){
            accountPartnerTypeMap.put('System Implementer','Silver');
        }
        else If(objAccount.Partner_Implementation_TnC__c == TRUE && objAccount.SI_Partner_Tier__c == 'Authorized'){
            accountPartnerTypeMap.put('System Implementer','Authorized');
        }
        else If(objAccount.Partner_Implementation_TnC__c == TRUE && objAccount.SI_Partner_Tier__c == null){
            accountPartnerTypeMap.put('System Implementer','All');
        }
        return accountPartnerTypeMap;
    }
}