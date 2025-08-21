public class OpaUtils 
{

	public class UncaughtException extends Exception {}
    // Query Organization based on Id and return IsSandbox boolean
    // public static Boolean runningInASandbox(String orgId) 
    // {
    //   return [SELECT Id, IsSandbox FROM Organization where Organization.Id = :orgId].IsSandbox;
    // }
    
    // // Determine OAuth2 authenticaton URL based on Organization type Sandbox or Developer/Production Edition
    // public static String getAuthUrl() 
    // {
    //     return 'https://' + (runningInASandbox(UserInfo.getOrganizationId()) ? 'test' : 'login') + '.salesforce.com';
    // }
    
    // Base64 encode input for URL
    public static String base64URLencode(Blob input)
    {
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
    
    // Extract field value from JSON body
    // public static String extractJsonField(String body, String field)
    // {         
    //     JSONParser parser = JSON.createParser(body);
    //     while (parser.nextToken() != null) {
    //         if (parser.getCurrentToken() == JSONToken.FIELD_NAME
    //                 && parser.getText() == field) {
    //             parser.nextToken();
    //             return parser.getText();
    //         }
    //     }
    //     throw new System.JSONException(field + ' not found in response ' + body);
    // }
      
}