public with sharing class ConsumeMuleRequestWrapper {
 
    public ConsumeRequest consumeRequest {get;set;}

    public ConsumeMuleRequestWrapper(String consumer, String region, String pollDate, String messageType, List<String> recordTypeFilter, String messageCount, Boolean dequeueFlag)
    {
        this.consumeRequest = new ConsumeRequest(consumer,region, pollDate,messageType,recordTypeFilter,messageCount,dequeueFlag);
    }
    public class ConsumeRequest
    {
        public String consumer {get; set;}
        public String region {get; set;}
        public String pollDate {get; set;}
        public String messageType {get; set;}
        public RecordTypeFilters recordTypeFilters {get; set;}
        public String messageCount {get; set;}

         public Boolean dequeueFlag {get; set;}
        
       
        public ConsumeRequest(String consumer, String region, String pollDate, String messageType, List<String> recordTypeFilter, String messageCount, Boolean dequeueFlag)
        {
            this.consumer = consumer;
            this.region = region;
            this.pollDate = pollDate;
            this.messageType = messageType;
            this.recordTypeFilters = new RecordTypeFilters(recordTypeFilter);
            this.messageCount = messageCount;
            this.dequeueFlag = dequeueFlag;
        }
    } 
    public class RecordTypeFilters {
		public  List<String> recordTypeFilter;
        public RecordTypeFilters(List<String> recordTypeFilter){
            this.recordTypeFilter = recordTypeFilter;
        }
	}
  
    
    
    
}