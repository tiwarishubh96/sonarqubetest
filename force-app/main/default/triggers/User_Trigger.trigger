/**
 * @description Trigger for User Standard Objects
 * @author Shanmuk Hanumanthu
 * @Date 12/12/2019
 */

trigger User_Trigger on User (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {

    UserControlSwitch__c triggerSwitch = UserControlSwitch__c.getInstance();
    if(Test.isRunningTest() || triggerSwitch.RunTrigger__c){
        TriggerDispatcher.Run(new User_TriggerHandler());
    }
}