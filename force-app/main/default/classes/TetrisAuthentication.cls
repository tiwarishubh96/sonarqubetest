/* Tetris Authentication is only used in cases where calls from Zuora are made to Saleforce
 * Zuora doesn't use Oauth for their notification callouts
 */
public class TetrisAuthentication {
    
	public static void Authenticate() {
        
    	try {
         RestRequest request = RestContext.request;  
         
         String apiKey = request.params.get('apikey');
         if(apiKey != GetKey())
        	throw new TetrisAuthenticationException('Authentication Failed');
            
        } catch(Exception expObject){
            throw new TetrisAuthenticationException('Authentication Failed');
        } finally {
                
        }    

    }
    
    private static string GetKey() {
        
    //SELECT Id, Client_Id__c, Client_Secret__c, DeveloperName, Grant_Type__c, Label, 
    // Language, Login_URL__c, MasterLabel, NamespacePrefix, Password__c,
    // QualifiedApiName, Tetris_API__c, Username__c 
    // FROM Tetris_Login_Details__mdt 
    // 
        List<Tetris_Login_Details__mdt> keys = [SELECT MasterLabel, Client_Secret__c FROM Tetris_Login_Details__mdt Where MasterLabel = 'External Api Key'];
        
        if(keys.isEmpty())
            return '';
        
        return keys.get(0).Client_Secret__c;
    }
    
    
}