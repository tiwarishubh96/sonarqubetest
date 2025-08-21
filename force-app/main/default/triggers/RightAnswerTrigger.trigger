/*trigger RightAnswerTrigger on RightAnswersAttached__c (before insert, before update, before delete,
		after insert, after update, after delete, after undelete) {
   
        TriggerDispatcher.Run(new RightAnswersTriggerHandler());
  
    
}*/

trigger RightAnswerTrigger on RightAnswersAttached__c (after insert,after update,after delete) { 
    if (trigger.isAfter ){
		if( trigger.isInsert) 
		{
			new RightAnswersTriggerHandler().AfterInsert(trigger.newMap);
        }else if(trigger.isUpdate){
            new RightAnswersTriggerHandler().AfterUpdate(trigger.newMap,trigger.oldMap);
        }else{
            new RightAnswersTriggerHandler().AfterDelete(trigger.oldMap);
        }
	}	
}