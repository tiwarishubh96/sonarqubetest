global with sharing class SageCommunityUserUtil {   
    /*
    * Method checking if current user is Sage Community user profile
	* - include Customer Community profile check. Richard Wintle 20160621 (US46963)
    */
    global static Boolean isSageCommunityUser(){
        Community_SSO_Settings__c communitySetting = Community_SSO_Settings__c.getOrgDefaults();
        Set<String> sageCommunityProfiles=new Set<String>();
        sageCommunityProfiles.add(communitySetting.SageCommunityProflieName__c == null ? communitySetting.SageCommunityProflieName__c : communitySetting.SageCommunityProflieName__c.trim());
        sageCommunityProfiles.add(communitySetting.CustomerCommunityProfileName__c == null ? communitySetting.CustomerCommunityProfileName__c : communitySetting.CustomerCommunityProfileName__c.trim());
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() AND Name IN:sageCommunityProfiles];
        if(profiles!=null && profiles.size()>0){
            return true;
        }
        return false;
    }
}