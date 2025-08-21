/**
 * @description Event entry point for Subscription_Master__c object.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
trigger SubscriptionMasterTrigger on Subscription_Master__c ( 	before insert, 
																after insert
																,before update
																, after update
																// ,before delete, after delete
																// ,after undelete
)
{
	if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c )
	{
	// before insert
	
	 if (Trigger.isInsert && Trigger.isBefore)
	 {
	 	SubscriptionMasterTriggerHandler.beforeInsert();
	 }
	
	// after insert
	
	 else

	 if (Trigger.isInsert && Trigger.isAfter)
	 {
	 	SubscriptionMasterTriggerHandler.afterInsert();
         
        SubscriptionMasterTriggerHandler.updateChannelPartner(Trigger.New);

	 }
	
	// before update
	
	 else

	 if (Trigger.isUpdate && Trigger.isBefore)
	 {
	 	SubscriptionMasterTriggerHandler.beforeUpdate();
	 }
	
	// after update
	
	 else

	 if (Trigger.isUpdate && Trigger.isAfter)
	 {
	 	SubscriptionMasterTriggerHandler.afterUpdate();
        SubscriptionMasterTriggerHandler.updateChannelPartner(Trigger.New);
	 }
	
	// before delete
	
	// else

	// if (Trigger.isDelete && Trigger.isBefore)
	// {
	// }
	
	// after delete
	
	// else

	// if (Trigger.isDelete && Trigger.isAfter)
	// {
	// }
	
	// undelete
	
	// else

	// if (Trigger.isUnDelete)
	// {
	// }
	}
}