public class PublishSurveyMuleMessage extends PublishMuleMessagesAbstract{
    public override String buildPartialMsg(PublishMuleMessageWrapper.PublishMuleRequest publishReq){
        String partialMsg = '';
        Map<String, Object> msgBodyMap = muleMessageFields(publishReq.record, publishReq.mdtFields);
        
        String msgHeader = buildMsgHeader(publishReq.region, publishReq.recordtype, publishReq.messageType, 
                            publishReq.eventSource, publishReq.eventDate, publishReq.eventId); 
        String msgBody = buildMsgBody(msgBodyMap, publishReq.sfObjectName);
        partialMsg  = msgHeader + msgBody;                     
        return partialMsg;
    }
    
    public override Map<String, Object> muleMessageFields(SObject record,
                                                 List<Publish_Mulesoft_Field__mdt> mdtFields){
        Map<String, Object> msgBodyFields = new Map<String, Object>();                                            
        //msgBodyFields.put('workflow', LABEL.RnRSurveyWorkFlow);
           
              for(Publish_Mulesoft_Field__mdt mdtField : mdtFields){
                
                if(mdtField.Lookup__c == null){
                    system.debug(mdtField.Message_Field_Name__c);
                   
                    if( mdtField.SF_Field_Name__c!=null){
                        
                    	msgBodyFields.put(mdtField.Message_Field_Name__c, record.get(mdtField.SF_Field_Name__c));
                    }
                    else{
                        msgBodyFields.put(mdtField.Message_Field_Name__c, null);
                    }
                } else if(record.getSObject(mdtField.Lookup__c) != null){
                      if(mdtField.SF_Field_Name__c != null){
                    msgBodyFields.put(mdtField.Message_Field_Name__c, retrieveLookupFieldVal(record, mdtField.SF_Field_Name__c));
                     }
                    else{
                         msgBodyFields.put(mdtField.Message_Field_Name__c, null);
                    }
                }
            }
            String country = (String)msgBodyFields.get('customerCountry');
            if(country != null && country != ''){
                List<Rant_and_Rave_Workflow__mdt> rnrWorkflows = [SELECT Id, Country__c, Rant_and_Rave_Workflow__c 
                                                           FROM Rant_and_Rave_Workflow__mdt WHERE Country__c = :country LIMIT 1];
                if(rnrWorkflows != null && rnrWorkflows.size()>0){
                    msgBodyFields.put('workflow', rnrWorkflows[0].Rant_and_Rave_Workflow__c);
                } else {
                    //default workflow
                    msgBodyFields.put('workflow', LABEL.RnRSurveyWorkFlow);
                }
            }                                      
        return msgBodyFields;
     }
}