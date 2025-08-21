public class TetrisEndpointLookupUtility {

	// Usage:
	//
	//	 Declaration at top of class
	//     @TestVisible private static TetrisEndpointLookupUtility tetrisEndpoints = new TetrisEndpointLookupUtility();
	//
	//   Then get the config:	 
    //     TetrisEndpointLookupUtility.TetrisEndpointConfig config = tetrisEndpoints.getConfigByName('config-name-here');
    //	
    //	 Add access properties
    //     myUrl = config.EndpointUrl;
    //

	//Simple object to return config values to caller
    public class TetrisEndpointConfig {
    	public String EndpointUrl {get;set;}
    	public String Method {get;set;}
    	public String AuthHeader {get;set;}
    	public String ContentType {get;set;}
    	public Integer Timeout {get;set;}
    	public String SSLCertificate {get;set;}
    	public String ClientId {get;set;}
    	public String ClientSecret {get;set;}
    }

    @TestVisible private static ICustomMetadataTypeDAO customMetadataTypeDAOInstance = DAOFactory.getCustomMetadataTypeDAO();

	public TetrisEndpointLookupUtility() {
		
	}

	//retrieves a configuration given it's name
    public TetrisEndpointConfig getConfigByName(String configName){

    	TetrisEndpointConfig result = new TetrisEndpointConfig();
    	Callout_Configuration__mdt config;

    	if(configName != null && !String.isEmpty(configName)){
			if(configName.toLowerCase() == 'sage-one') {
		        config = customMetadataTypeDAOInstance.getSageOneSignOnUrl();
			}
			else if(configName.toLowerCase() == 'recaptcha') {
		        config = customMetadataTypeDAOInstance.getGoogleReCAPTCHASettings();
			}
			else if(configName.toLowerCase() == 'tokenized-convert') {
		        config = customMetadataTypeDAOInstance.getTokenizedPaymentUrl();
			} 
            else if(configName.toLowerCase() == 'zuora-iframe-account') {
                config = customMetadataTypeDAOInstance.getMuleToZouraAccountCreate();
            }
            else if(configName.toLowerCase() == 'sage-one-convert-success') {
                config = customMetadataTypeDAOInstance.getSageOneConvertSuccessUrl();
            }
            else if(configName.toLowerCase() == 'sage-one-convert-failure') {
                config = customMetadataTypeDAOInstance.getSageOneConvertFailureUrl();
            }
			else {
				config = null;
			}    		
    	}

        //if we fetched a valid object, pull properties off
        if(config != null) {

			result.EndpointUrl = config.Endpoint_URL__c;
			result.Method = config.HTTP_Method__c; 
            result.AuthHeader = config.Authorization__c;
            result.ContentType = config.Content_Type__c;
            result.Timeout = (Integer)config.Timeout__c;
            result.SSLCertificate = config.SSL_Certificate__c;
            result.ClientId = config.Client_Id__c;
            result.ClientSecret = config.Client_Secret__c;
        }

    	return result;
	}

}