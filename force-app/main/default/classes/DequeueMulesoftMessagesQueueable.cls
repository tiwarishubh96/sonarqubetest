global class DequeueMulesoftMessagesQueueable implements Queueable, Database.AllowsCallouts
{
    public String query;
    public String category;
    global DequeueMulesoftMessagesQueueable(String category){
        this.category = Category;
       // this.query = query;
    }
    
  /*  public Database.QueryLocator start(Database.BatchableContext BC)
    {
       // query = 'Select id,Event_Id__c, Survey_Status__c from Case where Status=\'Closed\' AND Survey_Status__c != null';
        return Database.getQueryLocator(query);
    } */
    
    public void execute(QueueableContext context){
        String resultResponse = '';
        
        
        try{
            
            Consume_API_Request__mdt consumeRequest = [SELECT Consumer__c,Message_Type__c, Record_Type_Filter__c,Region__c  
                                                       FROM Consume_API_Request__mdt WHERE Category__c =: category  LIMIT 1];
            Mulesoft_Helper_Class__mdt classType = [SELECT Class_Type__c FROM Mulesoft_Helper_Class__mdt 
                                                 WHERE SObjectType__c =:category  AND Request_Type__c ='Dequeue' LIMIT 1];
        Type t = Type.forName(classType.Class_Type__c); 
         DequeueMuleMessagesInterface deQueueFields = (DequeueMuleMessagesInterface)t.newInstance();
            
            List<String> recordTypeFilter = new List<String>();
            recordTypeFilter.add(consumeRequest.Record_Type_Filter__c);
            List<String> dequeueEventIds = new List<String>();
                dequeueEventIds = deQueueFields.getEventIds();
            system.debug('dequeueEventIds in Dequeue message  '+dequeueEventIds);
          /*  for(SObject caseConfig : scope){
                Case caseConfigVal = (Case)caseConfig;
                dequeueEventIds.add(caseConfigVal.Event_Id__c);
                
            } */
          //  SPPSyncCalloutHelper mulesoftCallout = new SPPSyncCalloutHelper();
            dequeueMuleMessagesWrapper msgWrapper = new dequeueMuleMessagesWrapper(GUIDHelper.generateGUID(),consumeRequest.Consumer__c,consumeRequest.Region__c,
                                                                                   consumeRequest.Message_Type__c,recordTypeFilter,dequeueEventIds);
            system.debug('msgWrapper----- '+JSON.serialize(msgWrapper));
            
            
             resultResponse=MuleSoftUtils.CalltoMuleSoft(JSON.serialize(msgWrapper),'Mulesoft_Dequeue_Endpoint', 'OAuth');
            
            
           /* resultResponse = mulesoftCallout.syncMessages(consumeEndPoint.Client_Id__c, consumeEndPoint.Client_Secret__c, 
                                                          consumeEndPoint.HTTP_Method__c,JSON.serialize(msgWrapper), 
                                                          consumeEndPoint.Endpoint_URL__c);  */
            system.debug('resultResponse ----------- '+resultResponse);
            deQueueFields.updateCases(resultResponse,dequeueEventIds);
          
            
       }catch(Exception e){
        	ExceptionHandler.CatchException('DequeueMulesoftMessagesHelper','execute', e);
    	}
    }
   
    
   
    
}