public class PublishMuleMesssagesHelper {
    
    public List<PublishMuleMessageWrapper.publishMuleResponse> generateMessageJSON(List<PublishMuleMessageWrapper.PublishMuleRequest> publishReqList){
        
        List<PublishMuleMessageWrapper.publishMuleResponse> publishResponseList = new List<PublishMuleMessageWrapper.publishMuleResponse>();
        String responseJSON = '';
        String partialMsg = '';
        Map<String, String> eventIdtoRecordIdMap = new Map<String, String>();
        Integer count = 0;        
        //type of specific class
        Mulesoft_Helper_Class__mdt classType = [SELECT Class_Type__c FROM Mulesoft_Helper_Class__mdt 
                                                 WHERE Request_Type__C = 'Publish' AND SObjectType__c = :publishReqList[0].sfObjectName LIMIT 1];
        Type t = Type.forName(classType.Class_Type__c);
        PublishMuleMessagesAbstract SobjectFields = (PublishMuleMessagesAbstract)t.newInstance();
        SPP_Message_Size__mdt msgSize = [SELECT UpperLimit__c,LowerLimit__c,DeveloperName FROM 
                                         SPP_Message_Size__mdt WHERE DeveloperName = 'Publish' LIMIT 1];                        
        PublishMuleMessageWrapper.PublishMuleRequest req;  
        
        for(PublishMuleMessageWrapper.PublishMuleRequest publishReq :publishReqList){
            String etId = GUIDHelper.generateGUID();
            eventIdtoRecordIdMap.put(etID, (String)publishReq.record.get('Id'));
            publishReq.eventId = etId;
            
            if(partialMsg.length() < msgSize.UpperLimit__c){
                //if the record is last one in the loop or size is close to upper limit
                System.debug('count before adding this rec >>> helper '+count);
                partialMsg += SobjectFields.buildPartialMsg(publishReq);
                //System.debug('partialMsg before size check  >> '+partialMsg);
                if(partialMsg.length() > msgSize.LowerLimit__c || (publishReqList.size()>0 && publishReqList.size()-1 == count)){
                    if(partialMsg != null && partialMsg != '' && partialMsg.endsWith(',')){
                       partialMsg = partialMsg.substring(0,partialMsg.length()-1);
                        String finalMsg = '{"publishRequest": {"messages": {"message": ['+partialMsg+']}}}';
                        System.debug('finalMsg in if **** '+finalMsg);
                        //Callout to Mulesoft Publish API
                        responseJSON=MuleSoftUtils.CalltoMuleSoft(finalMsg,'Mulesoft_Publish_Endpoint', 'OAuth');
                        //Parse the mulesoft response and build a list of publishResponses
                        publishResponseList.addAll(SobjectFields.parseResponse(eventIdtoRecordIdMap, responseJSON));
                        //After publishing clear the partialMsg
                        partialMsg = ''; 
                    }
                } else{
                    //partialMsg += SobjectFields.buildPartialMsg(publishReq);
                    System.debug('partialMsg >lowerlimit in else >> '+partialMsg);
                } 
            } else {
                if(partialMsg.endsWith(','))
                    partialMsg = partialMsg.substring(0,partialMsg.length()-1);
                
                String finalMsg = '{"publishRequest": {"messages": {"message": ['+partialMsg+']}}}';
                System.debug('finalMsg in else **** '+finalMsg);
                //Callout to Mulesoft Publish API
                responseJSON=MuleSoftUtils.CalltoMuleSoft(finalMsg,'Mulesoft_Publish_Endpoint', 'OAuth');
                //Parse the mulesoft response and build a list of publishResponses
                publishResponseList.addAll(SobjectFields.parseResponse(eventIdtoRecordIdMap, responseJSON));
                //After publishing clear the partialMsg
                partialMsg = '';
                partialMsg += SobjectFields.buildPartialMsg(publishReq);
            }
            count++;
        }
        System.debug('publishResponseList before return>>>>> '+publishResponseList);                                                
        return publishResponseList;
    } 
}