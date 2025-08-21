/**
 * @description Event entry point for Invoice_Line_Item__c object.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (	
												// before insert
												 //,
												after insert
												// ,before update, after update
												// ,before delete, after delete
												// ,after undelete
												)
{
	if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c)
	{
		// before insert
		
		// if (Trigger.isInsert && Trigger.isBefore)
		// {
		// }
		
		// after insert
		
		// else

		 if (Trigger.isInsert && Trigger.isAfter)
		 {
		 	InvoiceLineItemTriggerHandler.afterInsert();
		 }
		
		// before update
		
		// else

		// if (Trigger.isUpdate && Trigger.isBefore)
		// {
		// }
		
		// after update
		
		// else

		// if (Trigger.isUpdate && Trigger.isAfter)
		// {
		// }
		
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