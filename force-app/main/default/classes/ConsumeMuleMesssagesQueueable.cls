global class ConsumeMuleMesssagesQueueable implements Queueable, Database.AllowsCallouts
{
    public String query;
    public String category;
    public sObject obj;
    global ConsumeMuleMesssagesQueueable(String category){
        this.category = Category;
       // this.query = query;
    }
    
   
    public void execute(QueueableContext context){
        String resultResponse = '';
        try{
            
            Consume_API_Request__mdt consumeRequest = [SELECT Consumer__c, Dequeue_Flag__c, Message_Count__c, Message_Type__c, Record_Type_Filter__c,Region__c  
                                                       FROM Consume_API_Request__mdt WHERE Category__c =: category LIMIT 1];
            
            List<String> recordTypeFilter = new List<String>();
            recordTypeFilter.add(consumeRequest.Record_Type_Filter__c);
            ConsumeMuleRequestWrapper msgWrapper = new ConsumeMuleRequestWrapper(consumeRequest.Consumer__c,consumeRequest.Region__c,
                                                                                 System.now().format('yyyy-MM-dd\'T\'HH:mm:ss:sss\'Z\''),
                                                                                 consumeRequest.Message_Type__c,recordTypeFilter,consumeRequest.Message_Count__c,Boolean.valueOf(consumeRequest.Dequeue_Flag__c));
            
            
            resultResponse=MuleSoftUtils.CalltoMuleSoft(JSON.serialize(msgWrapper),'Mulesoft_Consume_Endpoint', 'OAuth');
            Mulesoft_Helper_Class__mdt classType = [SELECT Class_Type__c FROM Mulesoft_Helper_Class__mdt 
                                                    WHERE SObjectType__c = :category AND Request_Type__c='Consume' LIMIT 1];
            Type t = Type.forName(classType.Class_Type__c); 
            ConsumeParserInteface consumeFields = (ConsumeParserInteface)t.newInstance();
            consumeFields.consumeResponseParse(resultResponse); 
            
            
        }catch(Exception e){
            ExceptionHandler.CatchException('ConsumeMuleMesssagesQueueable','execute', e);
        }
        
        
    }  
    
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    
    
    
}