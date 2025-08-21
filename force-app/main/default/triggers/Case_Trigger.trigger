/**
 @author 	Manjusha Guthikonda
 @date 	12/30/2018
 @description 	trigger for CAse object. There should only be one trigger per object.
 # ------------------------------------------------------------------------
 # Migrated to new Trigger Framework
 */

trigger Case_Trigger on Case (before insert, before update, before delete,
		after insert, after update, after delete, after undelete) {

	TriggerFactory.executeTrigger(CaseControlSwitch__c.getInstance());
}