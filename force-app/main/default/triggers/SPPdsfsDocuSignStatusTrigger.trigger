/*********************************************************************
Name    : SPPdsfsDocuSignStatusTrigger
Author  : Lakshman Jaasti
Date    : 04/14/2017
Description :  This Trigger is used to update Partner Junction Object Records.
After record get inserted in Docusign Status Object from DocuSign.
**********************************************************************/
trigger SPPdsfsDocuSignStatusTrigger on dsfs__DocuSign_Status__c (after insert,after update) {
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            
            List<Partner_Terms_and_Condition__c> partnerTnCListCompleted = new List<Partner_Terms_and_Condition__c>();
            List<String> docuSignStatusIdsList = new List<String>();
            map<String , dsfs__DocuSign_Status__c> docuSignMap = new map<String , dsfs__DocuSign_Status__c>();
            List<Partner_Terms_and_Condition__c> ptcListUpdate = new List<Partner_Terms_and_Condition__c>();
            for(dsfs__DocuSign_Status__c obj : Trigger.New)
            {
                docuSignStatusIdsList.add(obj.dsfs__DocuSign_Envelope_ID__c);
                docuSignMap.put(obj.dsfs__DocuSign_Envelope_ID__c.toLowerCase() , obj);
            }
            List<Partner_Terms_and_Condition__c> ptcList = [Select id ,DocuSign_EnvelopeId__c,Partner_Type__c,Account__c from Partner_Terms_and_Condition__c where DocuSign_EnvelopeId__c IN :docuSignStatusIdsList];
            for(Partner_Terms_and_Condition__c obj : ptcList)
            {
                dsfs__DocuSign_Status__c docuObj = docuSignMap.get(obj.DocuSign_EnvelopeId__c.toLowerCase());
                if(docuObj != null)
                {
                    obj.DocuSign_Status_Object__c = docuObj.Id;
                    obj.Docusign_Status__c = docuObj.dsfs__Envelope_Status__c;
                    ptcListUpdate.add(obj);
                    if(obj.Docusign_Status__c.equals('Completed') )
                    {
                        partnerTnCListCompleted.add(obj);
                    }
                    
                }
            }         
            system.debug('Trigger.New :'+Trigger.New);
            Update ptcListUpdate;
            SPPDocuSignBulkRestService tncutils = new SPPDocuSignBulkRestService();
            tncutils.updateAccountTiers(partnerTnCListCompleted);
        }
        
    }
    
}