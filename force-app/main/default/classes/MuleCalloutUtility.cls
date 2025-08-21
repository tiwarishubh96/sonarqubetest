public class MuleCalloutUtility implements ICalloutUtility{ 

    public interface ICalloutUtility {
        //HttpResponse sendCallout(String username, String password, String body, 
        //                                String endpoint, String certificate, 
        //                                            String organizationId, String type);

        HttpResponse sendCallout(String body, String type);

        HttpResponse sendCallout(String body, String queryStr, String type);

    }

    public static final String AUTHORIZATION = 'Authorization';
    public static final String ACCEPT = 'accept';
    public static final String BEARER = 'Bearer ';

    @TestVisible private static ICustomMetadataTypeDAO customMetadataTypeDAOInstance = DAOFactory.getCustomMetadataTypeDAO();

    private String baseMuleUrl {get;set;}

    public MuleCalloutUtility() {

        //load up the base Mule endpoint entry
        System.debug('Entering MuleCalloutUtility...');
        Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleBaseEndpoint();
        System.debug('Base Mule Callout config => ' + config);
        String endpointUrl = config.Endpoint_URL__c;

        if(endpointUrl != null && String.isNotEmpty(endpointUrl))
        {
            baseMuleUrl = endpointUrl;
        }
        System.debug('baseMuleUrl has been set to => ' + baseMuleUrl);

        System.debug('Exiting MuleCalloutUtility');
    } 

    public HttpResponse sendCallout(String body, String type){
        return sendCallout(body, null, type);
    }

    public HttpResponse sendCallout(String body, String queryStr, String type){

        if(Limits.getCallouts() < Limits.getLimitCallouts()){
            if(type.equalsIgnoreCase('AVALARA')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToAvalaraTaxCalc();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Avalara endpointUrl => ' + endpointUrl);

                return sendCalloutToAvalara(endpointUrl, body, config);

            } else if(type.equalsIgnoreCase('ZUORA_ACCOUNT')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToZouraAccountCreate();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Zuora Account endpointUrl => ' + endpointUrl);

                return sendCalloutToCreateZuoraAccount(endpointUrl, body, config);

            } else if(type.equalsIgnoreCase('ZUORA_CONTACT')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToZouraContactCreate();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Zuora Contact endpointUrl => ' + endpointUrl);

                return sendCalloutToCreateUpdateContact(endpointUrl, body, config);

            } else if(type.equalsIgnoreCase('ZUORA_UPDATE')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToZouraAccountUpdate();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Zuora Update endpointUrl => ' + endpointUrl);

                return sendCalloutToUpdateZuoraAccount(endpointUrl, body, config);

            } else if(type.equalsIgnoreCase('ZUORA_SUBSC')){

                //NOTE: Old subscription model; deprecated as of 2017-03-31
                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToZouraSubscribe();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Zuora Subscription endpointUrl => ' + endpointUrl);

                return sendCalloutToSubscribe(endpointUrl, body, config);

            } else if(type.equalsIgnoreCase('PRODUCT_PROVISION')){         

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToProductProvisioning();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Product Provisioning endpointUrl => ' + endpointUrl);

                return sendCalloutToProvisionProduct(endpointUrl, body, config);

            } else if(type.equalsIgnoreCase('ADDRESS_AUTO_COMPLETION')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToInformaticaAddressValidation();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Address Auto Completion endpointUrl => ' + endpointUrl);

                return sendCalloutToAddressAutoCompletion(endpointUrl, config);

            } else if(type.equalsIgnoreCase('SAGE_EMAIL_VALIDATION')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToSageOneEmailValidation();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Sage Email Validation endpointUrl => ' + endpointUrl);

                return sendCalloutToValidateEmailInSage(endpointUrl, config);

            } else if(type.equalsIgnoreCase('ZUORA_DYNAMIC_SUBSC')){

                //Get endpoint from config
                System.debug('[DEBUG:SAGE:Config DAO Instance => ' + customMetadataTypeDAOInstance);
                Callout_Configuration__mdt config = customMetadataTypeDAOInstance.getMuleToZouraDynamicSubscribe();
                System.debug('[DEBUG:SAGE:config => ' + config);
                String endpointUrl = config.Endpoint_URL__c;
                if(queryStr != null){
                    endpointUrl += queryStr;
                }
                System.debug('[DEBUG:SAGE:Zuora Dynamic Subscription endpointUrl => ' + endpointUrl);

                return sendCalloutZuoraDynamicSubscription(endpointUrl, body, config);
            } 
        }
        return null;
    }

    //Internal method which executes a request without sending body arguments
    private HttpResponse sendRequestWithoutBody(String method, String authHeader, String contentType, String endpointUrl, Integer timeout) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod(method);
        request.setHeader('Authorization', authHeader);
        // Don't set content type when there is no body
        //request.setHeader('Content-Type', contentType);
        request.setEndpoint(endpointUrl);
        request.setTimeout(timeout);

        return http.send(request);  
    }


    //Internal method which executes a request without sending body arguments
    private HttpResponse sendRequestWithBody(String method, String authHeader, String contentType, String endpointUrl, String json, Integer timeout) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod(method);

        //conditionally add auth header and content type header if present
        if(authHeader != null && String.isNotEmpty(authHeader)) {
            request.setHeader('Authorization', authHeader);
        }
        if(contentType != null && String.isNotEmpty(contentType)) {
            request.setHeader('Content-Type', contentType);
        }

        request.setEndpoint(endpointUrl);
        request.setTimeout(timeout);

        request.setBody(json);

        return http.send(request);  
    }    

    //Determins based on the endpoint information passed in whether it is relative and should be added to the 
    // base Mule URL or if it is absolute then it will be used as-is
    private String ResolveMuleEndpoint(String relativeOrAbsoluteEndpointUrl) {

        if(relativeOrAbsoluteEndpointUrl.startsWithIgnoreCase('http')) {
            return relativeOrAbsoluteEndpointUrl;
        } else {
            //assume the provided URL is relative and append it to the Mule base URL
            if(relativeOrAbsoluteEndpointUrl.startsWithIgnoreCase('/')) {
                return baseMuleUrl + relativeOrAbsoluteEndpointUrl;
            } else {
                return baseMuleUrl + '/' + relativeOrAbsoluteEndpointUrl;
            }
        }   
    }


    public HttpResponse sendCalloutZuoraDynamicSubscription(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c); 

    }

    public HttpResponse sendCalloutToValidateEmailInSage(String endpoint, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithoutBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        (Integer)config.Timeout__c);
 
    }

    public HttpResponse sendCalloutToAddressAutoCompletion(String endpoint, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithoutBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutToUpdateZuoraAccount(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutToCreateZuoraAccount(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutToCreateUpdateContact(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutToSubscribe(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutToProvisionProduct(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }
    
    public HttpResponse sendCalloutToAvalara(String endpoint, String json, Callout_Configuration__mdt config) { 
        System.debug('in sendCalloutToAvalara ');

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutSageIdEmailCheck(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }

    public HttpResponse sendCalloutSageIdNewUserStart(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }   

    public HttpResponse sendCalloutSageIdNewUserEnd(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }  

    public HttpResponse sendCalloutSageIdExistingUserStart(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }          

    public HttpResponse sendCalloutSageIdExistingUserEnd(String endpoint, String json, Callout_Configuration__mdt config) { 

        String targetEndpoint = ResolveMuleEndpoint(endpoint);
        return sendRequestWithBody(config.HTTP_Method__c, 
                                        config.Authorization__c,
                                        config.Content_Type__c,
                                        targetEndpoint,
                                        json,
                                        (Integer)config.Timeout__c);

    }          

}