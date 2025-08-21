public class ZClient {
    public class ZClientException extends Exception {}
    
    public class HPMAuthBody {
        public String uri { get; set;}
        public String method { get; set;}
        public String pageId { get; set;}
    }
    
    public String tenantId {get;set;}
    public String pageId {get;set;}
    
    public static RESTCalloutResult restCallout(String endpoint, String method, Object requestObject, String userName, String password) {
        if (userName == null || password == null) {
            throw new ZClientException('userName and password must be set.');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        String body = '';
        
        if (requestObject != null) {
            body = JSON.serializePretty(requestObject);
            req.setBody(body);
        }
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('charset', 'utf-8');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Length', String.valueOf(body.length()));
        req.setHeader('apiAccessKeyId', userName);
        req.setHeader('apiSecretAccessKey', password);
        
        Http http = new Http();
        HTTPResponse response;
        try {
            response = http.send(req);
            System.debug(response.getBody());
        } catch(Exception e) {
            System.debug(e);
            throw new ZClientException('Connection issue', e);
        }
        
        RESTCalloutResult restCalloutResult = new RESTCalloutResult();
        restCalloutResult.statusCode = response.getStatusCode();
        if (String.valueOf(restCalloutResult.statusCode).startsWith('2')) {
            restCalloutResult.success = true;
            restCalloutResult.responseBody = response.getBody();
            restCalloutResult.responseMap = deserializeRESTResponse(response.getBody());
        } else {
            restCalloutResult.success = false;
        }
        return restCalloutResult;
        
    }
    
    public static Map<String, Object> deserializeRESTResponse(string responseBody){
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(responsebody);                        
        } catch(Exception e) {                  
            String errorMessage = 'ZClient.deserializeRESTResponse: An error occured when trying to deserialize the REST call response. Error Message: ' + e.getMessage();
            System.debug(errorMessage);
            throw new ZClientException(errorMessage, e);
        }
    }   

    
    public class RESTCalloutResult {
        public Integer statusCode;
        public String status;
        public Boolean success;
        public Map<String, Object> responseMap;
        public String responseBody;
    }   
}