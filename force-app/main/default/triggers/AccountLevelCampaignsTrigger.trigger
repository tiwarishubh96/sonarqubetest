trigger AccountLevelCampaignsTrigger on Account_Level_Campaign__c (before insert,before update) {
   
    if(Trigger.isBefore && Trigger.isInsert)
        {
            AccountLevelCampaignTriggerHelper.getErrorAccCmp(Trigger.New);
        }
   
    else if(Trigger.isBefore && Trigger.isUpdate)
        {  
            AccountLevelCampaignTriggerHelper.getErrorAccCmp(Trigger.New);
        } 
    
}