public class PublishMuleMessageWrapper {
    
    public class PublishMuleRequest{ 
        public SObject record {get; set;} 
        public List<Publish_Mulesoft_Field__mdt> mdtFields {get; set;}
        public String eventId {get; set;}
        public String eventDate {get; set;}
        public String sfObjectName {get; set;}
        public String region {get; set;}
        public String recordtype {get; set;}
        public String messageType {get; set;}
        public String eventSource {get; set;}
    }
    
    Public class publishMuleResponse{
        public String eventId {get; set;}
        public String recordId {get; set;}
        public String messageId {get; set;}
        public String errorMessage {get; set;}
    }
}