public class PublishContactMuleMessage extends PublishMuleMessagesAbstract{
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
        try{
            for(Publish_Mulesoft_Field__mdt mdtField : mdtFields){
                if(mdtField.Lookup__c == null){
                    msgBodyFields.put(mdtField.Message_Field_Name__c, record.get(mdtField.SF_Field_Name__c));
                } else if(record.getSObject(mdtField.Lookup__c) != null ){
                    msgBodyFields.put(mdtField.Message_Field_Name__c, retrieveLookupFieldVal(record, mdtField.SF_Field_Name__c));
                }
            }
            System.debug('msgBodyFields in contact = ** '+msgBodyFields);
        }catch(Exception e){
            ExceptionHandler.CatchException('PublishContactMuleMessage', 'muleMessageFields', e);
        }
        return msgBodyFields;
     }
}