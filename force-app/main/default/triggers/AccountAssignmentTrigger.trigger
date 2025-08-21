/*
 *AccountAssignmentTrigger
 * 
 * Fires when Account Assignment record is created
 * and is used to update Account fields: 
 */
trigger AccountAssignmentTrigger on Account_Assignment__c (before insert, before update, before delete,
                                                                   after insert, after update, after delete, after undelete) {
   AccountAssignmentControlSwitch__c triggerSwitch = AccountAssignmentControlSwitch__c.getInstance();
    if (Test.isRunningTest() || triggerSwitch.Run_Trigger__c) {
        TriggerDispatcher.Run(new AccountAssignmentHandler());                                                                      
    }
}