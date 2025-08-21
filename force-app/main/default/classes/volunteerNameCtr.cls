public with sharing class volunteerNameCtr {
    
    public string urlLoad {get;set;}
    
    
    public volunteerNameCtr(ApexPages.StandardController controller) {
        Schema.DescribeSObjectResult r = Volunteering__c.sObjectType.getDescribe();
         String keyPrefix = r.getKeyPrefix();   
         field_Id__c fId = field_Id__c.getOrgDefaults();
         id currentUser;
         currentUser = UserInfo.getUserId();         
         
         User uRecord = new User ();
         uRecord = [SELECT Name, ID from User  where Id =:currentuser limit 1];
         urlLoad = '/'+keyPrefix+'/e?CF'+fID.VOLUNTEER_Volunteer_Name__c+'='+uRecord.Name+'&CF'+fID.VOLUNTEER_Volunteer_Name__c+'_lkid='+UserInfo.getUserId();
    }
    
// action="{!redirect}"
    public PageReference redirect(){
         
         Schema.DescribeSObjectResult r = Volunteering__c.sObjectType.getDescribe();
         String keyPrefix = r.getKeyPrefix();   
         field_Id__c fId = field_Id__c.getOrgDefaults();
         id currentUser;
         currentUser = UserInfo.getUserId();         
         
         User uRecord = new User ();
         uRecord = [SELECT Name, ID from User  where Id =:currentuser limit 1];
         
         //https://sagegroup--bau1uat--c.cs86.visual.force.com/apex/prepopulateNameVolunteer?CF00N7E000000gxle=Rodney+Ballener&CF00N7E000000gxle_lkid=00524000001jXDGAA2&save_new=1&sfdc.override=1&vfRetURLInSFX=%2Fa1w%2Fo
         
         PageReference pageRef = new PageReference('/'+keyPrefix+'/e?CF'+fID.VOLUNTEER_Volunteer_Name__c+'='+uRecord.Name+'&CF'+fID.VOLUNTEER_Volunteer_Name__c+'_lkid='+UserInfo.getUserId()+'&nooverride=0');
         ///e?CF'+fID.VOLUNTEER_Volunteer_Name__c+'='+uRecord.Name+'&CF'+fID.VOLUNTEER_Volunteer_Name__c+'_lkid='+UserInfo.getUserId());
         
         
         
         return pageRef;
    }

}