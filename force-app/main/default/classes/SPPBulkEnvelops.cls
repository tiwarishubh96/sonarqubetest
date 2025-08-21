public class SPPBulkEnvelops {
    
    public String batchSize;
    public String batchId;
    public String bulkEnvelopesBatchUri;
    public String failed;
    public String queued;
    public String sent;
    public String submittedDate;
    public String resultSetSize;
    public String startPosition;
    public String endPosition;
    public String totalSetSize;
    public String nextUri;
    public String previousUri;
    public List<BulkEnvelopes> bulkEnvelopes;
    
    public class BulkEnvelopes {
        public String transactionId;
        public String submittedDateTime;
        public String envelopeId;
        public String envelopeUri;
        public String bulkRecipientRow;
        public String name;
        public String email;
        public String bulkStatus;
        public ErrorDetails errorDetails;
    }
    
    
    public class ErrorDetails {
        public String errorCode;
        public String message;
    }
    
    
    public static SPPBulkEnvelops parse(String json) {
        return (SPPBulkEnvelops) System.JSON.deserialize(json, SPPBulkEnvelops.class);
    }
}