/**********************************************************************
 Name:  Success_PlanTrigger

======================================================
======================================================
Purpose:    Trigger on Success_Plan__c. Create sharing 
			rule after business plan is created
History:    
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
1.0         Lu                  11/2/2017          Initial Development
***********************************************************************/

trigger Success_PlanTrigger on Success_Plan__c (after insert) {
    /*if(Trigger.isAfter){
        INC0379162 - Please turn off the following Trigger/Trigger Handler
        if(Trigger.isInsert){
            Success_PlanTriggerHandler.onAfterInsert(Trigger.New);
        }
    }*/
    
    if (Trigger.isInsert && Trigger.isAfter){
        SPPSuccessPlanTriggerHandler.createBusinessPlanSharing(Trigger.New);
    }

}