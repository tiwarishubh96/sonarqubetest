trigger OpaSsaDocuSignRecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (after insert, after update)
{
   if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
   {    
        for(dsfs__DocuSign_Recipient_Status__c dsRecipientStatus : Trigger.new) 
        {
            if (OpaSsaCustomerSiteUpdate.processedEnvelopeId != dsRecipientStatus.dsfs__Envelope_Id__c)
            {
                OpaSsaCustomerSiteUpdate.processDocuSignRecipientStatusUpdate (dsRecipientStatus);
            }
        } 
   }
}