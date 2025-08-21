/**********************************************************************
 Name:  SPPQuoteTrigger

======================================================
======================================================
Purpose: Trigger to populate the OPP Id on Subscription Product & Charge Object
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Raja Patnaik     06/02/2017          Initial Development
0.2			Tiago Almeida	 10/01/2019			 changes on trigger related to SBC assisted sales project in UK
***********************************************************************/
trigger SPPQuoteTrigger on zqu__Quote__c (after insert, before update, after update) 
{
    if(Trigger.isupdate){
        
        system.debug('SPPQuoteTrigger Is Update');
        
        //populate the OPP Id on Subscription Product & Charge Object
        SPPQuoteTriggerHandler.populateOppID(Trigger.new);
        
        system.debug('Trigger.new[0].id::'+Trigger.new[0].id);
		
        
		if (Trigger.isAfter)
		{
            system.debug('SPPQuoteTrigger Is After Update');
			SPPQuoteTriggerHandler.AfterUpdate(Trigger.new,Trigger.Old);
		}
        
        
        if (Trigger.isBefore){
            SPPQuoteTriggerHandler.BeforeUpdate(Trigger.new);
        }

    }else if(Trigger.isinsert){
        
		system.debug('Trigger.new[0].id::'+Trigger.new[0].id);
        
    }
    
}