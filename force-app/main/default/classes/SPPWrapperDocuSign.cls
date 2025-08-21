public class SPPWrapperDocuSign 
{
    public String envelopeId;
    public BulkEnvelopeStatus bulkEnvelopeStatus;
    public String uri; 
    public String statusDateTime; 
    public String status; 
    public String errorCode;
    public String message;

    public class BulkEnvelopeStatus {
        public String batchSize;
        public String batchId;
        public String bulkEnvelopesBatchUri;
        public String failed;
        public String queued;
        public String sent;
        public String submittedDate;
    }

    
    public static SPPWrapperDocuSign parseJson(String json) {
        return (SPPWrapperDocuSign) System.JSON.deserialize(json, SPPWrapperDocuSign.class);
    }
}