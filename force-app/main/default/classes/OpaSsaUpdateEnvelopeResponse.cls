public class OpaSsaUpdateEnvelopeResponse
{
    public List<RecipientUpdateResults> recipientUpdateResults;

    public class ErrorDetails 
    {
        public String errorCode;
        public String message;
    }

    public class RecipientUpdateResults 
    {
        public String recipientId;
        public ErrorDetails errorDetails;
    }

    
    public static OpaSsaUpdateEnvelopeResponse parse(String json) {
        return (OpaSsaUpdateEnvelopeResponse) System.JSON.deserialize(json, OpaSsaUpdateEnvelopeResponse.class);
    }
}