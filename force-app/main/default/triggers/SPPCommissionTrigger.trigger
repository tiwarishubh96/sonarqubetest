/**********************************************************************
 Name:  SPPCommissionTrigger

======================================================
======================================================
Purpose: Trigger to create a sharing rule for each SPP 
        Commission Record.
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
1.0         Lu                  10/20/2017          Initial Development
***********************************************************************/
trigger SPPCommissionTrigger on SPP_Commission_Invoice__c (after insert, after update) {

        SPPCommissionInvoiceTriggerHandler.createCommissionSharing(Trigger.new);
    

}