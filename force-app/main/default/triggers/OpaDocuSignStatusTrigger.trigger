trigger OpaDocuSignStatusTrigger on dsfs__DocuSign_Status__c (after insert, after update)
{
   if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
   {           
        for(dsfs__DocuSign_Status__c status : Trigger.new) 
        {  
            if (status.dsfs__Envelope_Status__c == 'Sent' || status.dsfs__Envelope_Status__c == 'Voided' || status.dsfs__Envelope_Status__c == 'Completed') 
            {      
                OpaSsaCustomerSiteUpdate.processDocuSignStatusUpdate(status); 
            }
        }        
    }
}