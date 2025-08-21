Public class OpaSsaCreateAndSendEnvelopeResponse
{     
    public String envelopeId {get;set;} 
    public String uri {get;set;} 
    public String statusDateTime {get;set;} 
    public String status {get;set;} 
  
    Public static OpaSsaCreateAndSendEnvelopeResponse parse(string json)
    {
       return (OpaSsaCreateAndSendEnvelopeResponse) System.JSON.deserialize(json, OpaSsaCreateAndSendEnvelopeResponse.class);
    }     
}