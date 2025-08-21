public class OpaSsaDocuSignResponse
{
    public String errorCode {get;set;} 
    public String message {get;set;} 
    
    public static OpaSsaDocuSignResponse parse(String json) 
    {
        return (OpaSsaDocuSignResponse) System.JSON.deserialize(json, OpaSsaDocuSignResponse.class);
    }
}