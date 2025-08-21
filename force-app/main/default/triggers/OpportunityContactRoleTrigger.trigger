/**
 @author 	    Pete Wilson
 @date 	        10 July 2020
 @description 	Trigger to maintain Primary_Contact__c field on Opportunity 
                which is needed for RnR setup
 */
trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert, after update, after delete) {
    
    TriggerDispatcher.Run(new OpportunityContactRoleTriggerHandler());
}