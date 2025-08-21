/**********************************************************************************************
    Author      : Rani Thumma
    Company     : Docmation
    Date        : 26/6/2017
    Description : Calss is developed to implement Idempotence in delivering mulesoft messages 
************************************************************************************************/
@RestResource(urlMapping='/messages/find')
global with sharing class SPPMQEventRest 
{
    @HttpPost
    global static void findMessage() 
    {
        String requestBody = RestContext.request.requestBody.toString();
        Map<String, SPPMQEventWrapper.SPPMQEventReqWrapper> reqMap = new Map<String, SPPMQEventWrapper.SPPMQEventReqWrapper>();
        Map<String, MQ_Event__c> mqEventMap = new Map<String, MQ_Event__c>();
        List<SPPMQEventWrapper.SPPMQEventResWrapper> reponseWraps = new List<SPPMQEventWrapper.SPPMQEventResWrapper>();
        String results;
        String soqlClause = '(\'';
        String queryString = '';
        List<MQ_Event__c> mqEvents = new List<MQ_Event__c>(); 
        Map<String, String> eventsMap = new Map<String, String>();
        try
        {
        List<SPPMQEventWrapper.SPPMQEventReqWrapper> events = 
            (List<SPPMQEventWrapper.SPPMQEventReqWrapper>)JSON.deserialize(requestBody, List<SPPMQEventWrapper.SPPMQEventReqWrapper>.class);
        
        for(SPPMQEventWrapper.SPPMQEventReqWrapper eventWrp : events)
        {
            //reqMap.put(eventWrp.eventId, eventWrp.messageType);
            //reqMap.put(eventWrp.eventId, eventWrp);
            if(eventWrp.eventId != null && eventWrp.eventId != '')
            {
                soqlClause +=  eventWrp.eventId + '\',\'';
        	}
        }
        soqlClause = soqlClause.substring(0,soqlClause.length()-2); 
        soqlClause += ')';
        queryString = 'SELECT Id, Name, EventId__c, Region__c, MessageType__c FROM MQ_Event__c WHERE EventId__c IN ' +soqlClause;
        if(soqlClause.startsWith('('))
        {
            mqEvents = Database.query('SELECT Id, Name, EventId__c, Region__c, MessageType__c FROM MQ_Event__c WHERE EventId__c IN ' +soqlClause);
        }
        if(mqEvents != null && mqEvents.size()>0)
        {
       	for(SPPMQEventWrapper.SPPMQEventReqWrapper etWrp : events)
        {
            SPPMQEventWrapper.SPPMQEventResWrapper  resWrap = new SPPMQEventWrapper.SPPMQEventResWrapper();
        	for(MQ_Event__c mqEt : mqEvents)
            {
                if(etWrp.eventId == mqEt.EventId__c && 
                   etWrp.region == mqEt.Region__c && 
                   etWrp.messageType == mqEt.MessageType__c)
                {
                	//requested event id is in the MQEvent repository
                    resWrap.exists = true;
                    resWrap.eventId = etWrp.eventId;
                    resWrap.MessageType = etWrp.messageType;
                    System.debug('resWrap in if '+etWrp.eventId+'  '+mqEt.Region__c+' '+resWrap);
                    break;
                } 
                else
                {
                    //requested event id is in the MQEvent repository but region or message type do not match
                    resWrap.exists = false;
                    resWrap.eventId = etWrp.eventId;
                    resWrap.MessageType = etWrp.messageType;
                    System.debug('resWrap in else   '+etWrp.eventId+'  '+mqEt.Region__c+' '+resWrap);
            	}
            }
            reponseWraps.add(resWrap);
        }  
        }
        System.debug('reponseWraps>>>> '+reponseWraps);
        if(reponseWraps.size() > 0)
            RestContext.response.responseBody = Blob.valueOf(json.serialize(reponseWraps));
        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('SPPMQEventRest', 'Execute', e, queryString);
        }   
    }
    
    @HttpPut
    global static void insertMessageData()
    {
        String requestBody = RestContext.request.requestBody.toString();
        Map<String, String> reqPutMap = new Map<String, String>();
        List<MQ_Event__c> mqEvents = new List<MQ_Event__c>();
        try
        {
        List<SPPMQEventWrapper.SPPMQEventReqPutWrapper> events = 
            (List<SPPMQEventWrapper.SPPMQEventReqPutWrapper>)JSON.deserialize(requestBody, List<SPPMQEventWrapper.SPPMQEventReqPutWrapper>.class);
        System.debug('events >>> '+events);
        for(SPPMQEventWrapper.SPPMQEventReqPutWrapper eventWrp : events)
        {
            MQ_Event__c mqEvent = new MQ_Event__c();
            mqEvent.EventId__c = eventWrp.eventID;
            mqEvent.EventSource__c = eventWrp.eventSource;
            mqEvent.MessageType__c = eventWrp.messageType;
            mqEvent.EventDate__c = eventWrp.eventDate;
            mqEvent.Region__c = eventWrp.region;
            mqEvent.RecordType__c = eventWrp.recordType;
            mqEvents.add(mqEvent);
        }
        
        if(mqEvents.size() > 0)
        {
            Database.insert(mqEvents);
        }
        } catch(Exception ex)
        {
            ExceptionHandler.CatchException('SPPMQEventRest', 'Execute', ex);
        }
    }
}