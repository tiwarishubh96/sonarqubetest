public class OpaSsaGetSignerRecipientStatusResponse
{
    public List<Signers> signers {get;set;} 
      
    public class Signers 
    {
        public String signInEachLocation {get;set;} 
        public String creationReason {get;set;} 
        public String isBulkRecipient {get;set;} 
        public String name {get;set;} 
        public String email {get;set;} 
        public String recipientId {get;set;} 
        public String recipientIdGuid {get;set;} 
        public String requireIdLookup {get;set;} 
        public String userId {get;set;} 
        public String routingOrder {get;set;} 
        public String note {get;set;} 
        public String roleName {get;set;} 
        public String status {get;set;} 
        public String deliveryMethod {get;set;} 
        public String templateLocked {get;set;} 
        public String templateRequired {get;set;} 
    }
    
    public static OpaSsaGetSignerRecipientStatusResponse parse(String json) 
    {
        return (OpaSsaGetSignerRecipientStatusResponse) System.JSON.deserialize(json, OpaSsaGetSignerRecipientStatusResponse.class);
    }  
      
    public static String parseSignerRecipientStatus(String json) 
    {
        String status = '';
        List<Signers> signersList = parse(json).signers;
        for (Signers signer : signersList)
        {
            status = signer.status;
        }
        return status;
    }       
 
}