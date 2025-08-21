public class DequeueMuleMessagesWrapper {
    public DequeueRequest dequeueRequest;
    public DequeueMuleMessagesWrapper(String eventId, String consumer,String region,String messageType,List<String> recordTypeFilters, 
                                      List<String> dequeueEventIds){
        this.dequeueRequest = new DequeueRequest(eventId,consumer,region,messageType,recordTypeFilters,dequeueEventIds);
    }
    public class DequeueRequest{
        public String eventId;
		public String consumer;
		public String region;
		public String messageType;
		public RecordTypeFilters recordTypeFilters;
		public DequeueEventIds dequeueEventIds;
        public DequeueRequest(String eventId, String consumer,String region,String messageType,List<String> recordTypeFilters, 
                                      List<String> dequeueEventIds){
            this.eventId = eventId;
            this.consumer = consumer;
            this.region = region;
            this.messageType = messageType;
            this.recordTypeFilters = new RecordTypeFilters(recordTypeFilters);
            this.dequeueEventIds = new DequeueEventIds(dequeueEventIds);
        }
    }
    public class RecordTypeFilters{
        public List<String> recordTypeFilter;
        public RecordTypeFilters(List<String> recordTypeFilter){
            this.recordTypeFilter =recordTypeFilter;
        }
    }
    public class DequeueEventIds{
        public List<String> dequeueEventId;
        public DequeueEventIds(List<String> dequeueEventId){
            this.dequeueEventId = dequeueEventId;
        }
    }

}