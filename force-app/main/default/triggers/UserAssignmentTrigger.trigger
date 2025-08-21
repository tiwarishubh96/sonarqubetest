/*
 *UserAssignmentTrigger
 * 
 * Fires when anUser Assignment record is created
 * and is used to update User fields: First Name, Last Name, Role, Manager, Employee Number
 */
trigger UserAssignmentTrigger on User_Assignment__c (before insert, before update, before delete,
                                                                   after insert, after update, after delete, after undelete) {
   UserAssignmentControlSwitch__c triggerSwitch = UserAssignmentControlSwitch__c.getInstance();
    if (Test.isRunningTest() || triggerSwitch.RunTrigger__c) {
        TriggerDispatcher.Run(new UserAssignmentHandler());                                                                      
    }
}