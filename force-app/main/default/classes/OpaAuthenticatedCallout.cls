public with sharing class OpaAuthenticatedCallout 
{
    private class ConnectionException extends Exception {}
    public static List<String> messages = new List<String>(); 
            
    public static OpaMindoResponse makeProvisioningCall(OpaEndpointInfo__c endpoint, String body)
    {
        return  checkResponse(parseCloudManagerResponse(bearerTokenAuthCallout(endpoint, body))); 
    }
    
    private static OpaMindoResponse parseCloudManagerResponse(String jsonStr) 
    {
        System.debug(LoggingLevel.DEBUG, 'Mindo Response String: ' + jsonStr);
        OpaMindoResponse resp = new OpaMindoResponse();
        
        if(jsonStr == null)
        {
            return null;
        }
        
        JSONParser parser = JSON.createParser(jsonStr);
        while (parser.nextToken() != null) 
        {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
            {
                resp = (OpaMindoResponse)parser.readValueAs(OpaMindoResponse.class);
                return resp;
            }
        }
        
        System.debug(LoggingLevel.DEBUG, 'Mindo Response Object: ' + resp);
        return resp;
    } 

    public static OpaMindoResponse checkResponse(OpaMindoResponse response)
    {
        if(response != null)
        {
            //check to see the expected fields are received
            response.success = true;
        }
        else 
        {
            response = new OpaMindoResponse();
            response.success = false;
            String result = 'Unsuccessful or Invalid Response ';
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result); 
        } 
        
        response.message = String.join(messages,',');
        
        //have to limit the response messages length to 250 characters
        if(response.message.length() > 250) 
        {
           response.message = response.message.substring(0,246) + '...'; 
        }
        
        return response;
    }
    
    public static String bearerTokenAuthCallout(OpaEndpointInfo__c endpoint,  String body) 
    {
        HttpRequest req = new HttpRequest();
        String responseString = null;
        
        try
        { 
            String mindoUrl = endpoint.OpaEndpointHost__c + endpoint.OpaEndpointWebServicePath__c + endpoint.OpaEndpointWebServiceName__c;
            System.debug(LoggingLevel.DEBUG, 'Mindo Provisioning Endpoint(' + mindoUrl + ')');
            req.setEndpoint(mindoUrl);
            
            req.setMethod(endpoint.OpaHttpMethod__c);
            
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json;charset=UTF-8');
            
            req.setTimeout(OpaStaticVariables.requestTimeout); 
            
            //Token based Auth
            req.setHeader('Authorization', 'Bearer ' + OpaTokenGenerator.getBearerToken(endpoint));
        
            System.debug(LoggingLevel.DEBUG,'Request body: ' + body);
            req.setBody(body);
            
            HTTPResponse res = new Http().send(req);
            String responseBody =  res.getBody();
            
            System.debug(LoggingLevel.DEBUG,'Response Body:' + responseBody);
            System.debug(LoggingLevel.DEBUG,'Response Status Code:' + res.getStatusCode());
            
            messages.add('Response Code: ' + res.getStatusCode() + ' ');
            
            responseString = responseBody;
            
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) 
            {
                String result = 'Callout was made successfully';
                System.debug(LoggingLevel.DEBUG,result);
                messages.add(result);
            } 
            else if(res.getStatusCode() >= 300 && res.getStatusCode() < 400)
            {
                System.debug(responseString);
                
                // redirection may be due to failed authentication
                if(res.getStatusCode() == 307) 
                {
                    //handle the case where the user on the Cloud Manager side does not exist or the token is invalid
                    if(responseString.contains('auth/login/page'))
                    {
                        responseString = null; //this puts the record in 'Callout Failed' state
                        String result = 'OAuth Invalid User: User Authentication failed (e.g., unknown client).';
                        System.debug(LoggingLevel.DEBUG,result);
                        messages.add(result);
                    }
                }
            }
            else if(res.getStatusCode() >= 400 && res.getStatusCode() < 500)
            {   
                responseString = null; //this puts the record in 'Callout Failed' state
                if(res.getStatusCode() == 400)         
                {
                    String result = 'Client Error: ' + extractMessage(responseBody);
                    System.debug(LoggingLevel.DEBUG,result);
                    messages.add(result);
                }
                
                else if(res.getStatusCode() == 401)         
                {
                    String result = 'Request Authorization Failed: ';
                    
                    //handle the non-json results returend by Syracuse
                    if(responseBody.contains('Error 30:'))
                    {
                        result += 'token is invalid';
                    }
                    else if(responseBody.contains('Error 31:'))
                    {
                        result += 'token is invalid: the connected app corresponding to the client id was not found';
                    }
                    else if(responseBody.contains('Error 9:'))
                    {
                        result += 'token is invalid: the payload could not be decoded therefore the consumer key may be invalid';
                    }
                    else if(responseBody.contains('Error 11:'))
                    {
                        result += 'token is invalid: malformed token structure';
                    }
                    else if(responseBody.contains('Error 50:'))
                    {
                        result += 'token is invalid: token payload could not be verified: ';
                        result += responseBody.subString(10); //provide the supplied reason to the user
                    }
                    else if(responseBody.contains('Error 43:'))
                    {
                        result += 'token is invalid: token subject appears to refer to an invalid username';
                    }
                    else if(responseBody.contains('Error 41:'))
                    {
                        result += 'token is invalid: client id does not appear to be valid';
                    }
                    else if(responseBody.contains('Error 42:'))
                    {
                        result += 'token is invalid: token subject (username) is invalid or not allowed by the conncted app';
                    }
                    else if(responseBody.contains('Error 45:'))
                    {
                        result += 'token is invalid: token audience is not provided or is invalid';
                    }
                    else if(responseBody.contains('Error 20:'))
                    {
                        result += 'token is invalid: token issued at (timestamp) is invalid';
                    }
                    else if(responseBody.contains('Error 28:'))
                    {
                        result += 'token is invalid: token expiration (timestamp) is invalid, cannot be more than 120';
                    }
                    else if(responseBody.contains('Error 21:'))
                    {
                        result += 'token is invalid: token issued at (timestamp) cannot be set to a future date';
                    }
                    else if(responseBody.contains('Error 27:'))
                    {
                        result += 'token is invalid: token issued at and expiration timestamps are invalid';
                    }
                    else
                    {
                        result += 'Unexpected authentication related issue: ';
                        result += responseBody; //provide the supplied message to the user
                    }
                    
                    System.debug(LoggingLevel.DEBUG,result);
                    messages.add(result);
                }
                
                else if(res.getStatusCode() == 404)    
                {
                    String result = 'Endpoint Not Found. Check the endpoint Url and make sure it is correct.';
                    System.debug(LoggingLevel.DEBUG,result);
                    messages.add(result);
                }
                
                else
                {
                    String result = 'Unknown FATAL Error: ' + extractMessage(responseBody);
                    System.debug(LoggingLevel.DEBUG,result);
                    messages.add(result);
                }
            }
            else if(res.getStatusCode() >= 500 && res.getStatusCode() < 600)
            {
                responseString = null; //this puts the record in 'Callout Failed' state
                String result = 'Callout to Cloud Manager failed due to an internal server error (' + res.getStatusCode() + ') ' + responseBody;
                System.debug(LoggingLevel.DEBUG,result);
                System.debug(LoggingLevel.DEBUG,responseBody);
                messages.add(result);
            }
            else 
            {
                responseString = null; //this puts the record in 'Callout Failed' state
                String result = 'The web service call to Cloud Manager failed with an unexpected response status (' + res.getStatusCode() + '). ' + responseBody;
                System.debug(LoggingLevel.DEBUG,result);
                System.debug(LoggingLevel.DEBUG,responseBody);
                messages.add(result);
            }
        } 
        catch (System.CalloutException e)
        {                
            responseString = null; //this puts the record in 'Callout Failed' state
            String result = 'WebService Callout ERROR:' + e;
            System.debug(LoggingLevel.DEBUG,result);
            
            if(e.getMessage().contains('Unauthorized endpoint'))
            {
                messages.add('Callout Error: Check Setup->Security->Remote site settings.');
            }
            else 
            {
                messages.add(result);    
            }
            
        }
        catch (System.Exception e)
        {
            responseString = null; //this puts the record in 'Callout Failed' state
            String result = 'Unexpected ERROR:' + e;
            System.debug(LoggingLevel.DEBUG,result);
            messages.add(result);
        }
        return responseString;
    }
    
    
    public static String extractMessage(String response) 
    {
        String result = '';
        try
        {
            JSONParser parser = JSON.createParser(response);
            while (parser.nextToken() != null) 
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message')) 
                {
                    parser.nextToken();
                    result = parser.getText();
                }
            }
        }
        catch(System.JSONException e)
        {
            result = 'JSON error, message could not be parsed from the reponse. Raw response: ' + response;
        }
        return result;
    }

    
}