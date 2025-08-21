/**
  	 * @description Trigger to populate Region field on MRM_Activity__c object based on Country Field
  	   Jira Ticket Number: EAD-1863
  	 **/ 
trigger MRMActivity_Trigger on MRM_Activity__c (before insert, before update, before delete,
    after insert, after update, after delete, after undelete) {   
            TriggerDispatcher.Run(new MRMActivityTriggerHandler()); 
}