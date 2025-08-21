/**
 * Filter Feed Items for blacklisted words
 * Author: Quinton Wall - qwall@salesforce.com
 */
trigger BlacklistWordFilterOnPost on FeedItem (before insert) 
{
     // added flag to control the trigger enablement per SF Governance Meeting on 20170629
     if (TestUtils.isRunningTest() || Application_Control__c.getOrgDefaults().Run_Blacklist_Word_Filter__c) {       
         new BlacklistFilterDelegate().filterFeedItems(trigger.new);
     
     }
}