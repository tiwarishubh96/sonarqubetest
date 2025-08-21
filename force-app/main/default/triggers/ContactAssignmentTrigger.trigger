/*
 *ContactAssignmentTrigger
 * 
 * Fires when Contact Assignment record is created
 * and is used to update Contact fields: 
 */
trigger ContactAssignmentTrigger on Contact_Assignment__c (before insert, before update, before delete,
                                                                   after insert, after update, after delete, after undelete) {
   ContactAssignmentControlSwitch__c triggerSwitch = ContactAssignmentControlSwitch__c.getInstance();
    if (Test.isRunningTest() || triggerSwitch.Run_Trigger__c) {
        TriggerDispatcher.Run(new ContactAssignmentHandler());                                                                      
    }
}