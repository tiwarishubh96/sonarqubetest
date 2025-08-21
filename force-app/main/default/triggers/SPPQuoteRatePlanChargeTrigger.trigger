/**********************************************************************
 Name:  SPPQuoteRatePlanChargeTrigger
 
======================================================
======================================================
Purpose: Trigger to populate the Rep Id on Quote Rate Plan Charge
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Raja Patnaik     06/02/2017          Initial Development
*********************************************************************/
trigger SPPQuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete)
{

    //In this particular scenario there is no need to check the application control custom setting since this
    //is suposed to be executed to all users

    TriggerDispatcher.Run(new SPPQuoteRatePlanChargeTriggerHandler());

}