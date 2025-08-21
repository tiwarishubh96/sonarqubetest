public abstract class PublishMuleMessagesAbstract {
    
    public abstract Map<String, Object> muleMessageFields(SObject record,
                                                          List<Publish_Mulesoft_Field__mdt> mdtFields);
    public abstract String buildPartialMsg(PublishMuleMessageWrapper.PublishMuleRequest publishReq);
    
    public Object retrieveLookupFieldVal(SObject rec, String sfField){
        String fieldValue = '';
        SObject lookupVal;
        List<String> lookupFields = sfField.split('\\.');
        Integer i = 0;
        try{
            for(String lookupField : lookupFields){
                if(i==0){
                    lookupVal = rec.getSObject(lookupField);
                } else if(i > 0 && i < lookupFields.size()-1){
                    lookupVal = lookupVal.getSObject(lookupField);
                } else {
                    fieldValue = (String)lookupVal.get(lookupField);
                }
                i++;
            }
    	}catch(Exception e){
        	ExceptionHandler.CatchException('PublishMuleMessagesAbstract', 'retrieveLookupFieldVal', e);
    	}
        return (Object)fieldValue;
    }
    
    public String buildMsgBody(Map<String, Object> msgBodyMap, String sfObjectName){
        System.debug('msgBodyMap *** '+msgBodyMap);
        String msgBody = '"MessageBody": {"'+sfObjectName+'": ';
        try{
        	if(msgBodyMap != null && msgBodyMap.size() > 0){
                msgBody += JSON.serialize(msgBodyMap);
                msgBody += '}},';
        	}
        } catch(Exception e){
            ExceptionHandler.CatchException('PublishMuleMessagesAbstract', 'buildMsgBody', e);
        }
        System.debug('msgBody >>> '+msgBody);
        return msgBody;
    }
    
    Public String buildMsgHeader(String region, String recordtype, String messageType, 
                                 String eventSource, String eventDate, String eventId){
        String msgHeader = '{';
        msgHeader += '"MessageHeader": {'+
            '"region": "'+region+'",'+
            '"recordType": "'+recordtype+'",'+
            '"messageType": "'+messageType+'",'+
            '"eventSource": "'+eventSource+'",'+
            '"eventId": "'+eventId+'",'+
            '"eventDate": "'+eventDate+'"},';
        return msgHeader;
    }
    
    public List<PublishMuleMessageWrapper.publishMuleResponse> parseResponse(Map<String, String> eventIdToRecId, 
                                                                             String reponseResult){
        List<PublishMuleMessageWrapper.publishMuleResponse> publishReponses = new List<PublishMuleMessageWrapper.publishMuleResponse>();
        try{
            if(eventIdToRecId != null && reponseResult != null && reponseResult != ''){
            PublishMuleMessageWrapper.publishMuleResponse pr;
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(reponseResult);
            Map<String, Object> publishResponse = m!=null?(Map<String, Object>)m.get('publishResponse'):null;
            Map<String, Object> responses = publishResponse!=null?(Map<String, Object>)publishResponse.get('responses'):null;     
            List<Object> reponse = responses!=null?(List<Object>)responses.get('response'):null;
            System.debug(reponse);
            if(reponse != null && reponse.size() > 0){
                for(Object res :reponse){
                pr = new PublishMuleMessageWrapper.publishMuleResponse();
                Map<String, Object> details = (Map<String, Object>)res;
                pr.eventId = details!= null?(String)details.get('eventId'):null;
                pr.messageId = details!= null?(String)details.get('messageId'):null;
                pr.recordId = eventIdToRecId.get(pr.eventId);
                Map<String, Object> errors = details!= null?(Map<String, Object>)details.get('error'):null;
                    if(errors != null){
                        Map<String, Object> exceptions = (Map<String, Object>)errors.get('exceptions');
                        List<Object> errordetails = (List<Object>)exceptions.get('errordetail');
                        for(Object err :errordetails){
                            Map<String, Object> errMsgs = (Map<String, Object>)err;
                            pr.errorMessage = (String)errMsgs.get('errorMessage');
                            publishReponses.add(pr);
                        }
                    } else {
                        //if there is no error
                        publishReponses.add(pr);
                    }
            	}
           }
        }                                                                          
        }catch(Exception e){
            ExceptionHandler.CatchException('PublishMuleMessagesAbstract', 'parseResponse', e);
        }
        return publishReponses;
    }
}