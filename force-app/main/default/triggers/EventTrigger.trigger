trigger EventTrigger on Event (before insert, before update, before delete,
    after insert, after update, after delete, after undelete) {
    
    EventControlSwitch__c triggerSwitch = EventControlSwitch__c.getInstance();
    if (Test.isRunningTest() || triggerSwitch.Run_Trigger__c){
		TriggerDispatcher.Run(new EventTriggerHandler());
    }
}