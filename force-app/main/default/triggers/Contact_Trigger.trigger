/**
 * @description Trigger for Contact Standard Objects
 * @author Craig Bradshaw
 * @Date 15/02/2019
 */

trigger Contact_Trigger on Contact (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {

    ContactControlSwitch__c triggerSwitch = ContactControlSwitch__c.getInstance();
    if(Test.isRunningTest() || triggerSwitch.RunTrigger__c){
        TriggerDispatcher.Run(new Contact_TriggerHandler());
    }
}