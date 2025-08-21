public with sharing class OpaSsaAuthCallout
{  
    public static List<String> messages = new List<String>(); 
  
    public static HttpRequest buildRequest(String endPointParameters, String httpMethod)
    {              
        //Get configuration base on DocuSign Account Settings.
        dsfs__DocuSignAccountConfiguration__c accConfig = [
                                                            select 
                                                                id,
                                                                name,  
                                                                dsfs__AccountId__c,
                                                                dsfs__DocuSignBaseURL__c,
                                                                dsfs__DocuSignEnvironment__c, 
                                                                dsfs__DSProSFPassword__c,
                                                                dsfs__DSProSFUsername__c 
                                                            from 
                                                                dsfs__DocuSignAccountConfiguration__c];
             
        HttpRequest req = new HttpRequest();

        req.setEndpoint(OpaSsaUtils.getEndpoint(accConfig.dsfs__DocuSignBaseURL__c, 
                                                accConfig.dsfs__AccountId__c, 
                                                endPointParameters));
        
        req.setMethod(httpMethod);
        
        req.setHeader('Content-Type', OpaSsaStaticVariables.contentType);
        req.setHeader('Accept', OpaSsaStaticVariables.contentType); 

        //Authorization header generating using DocuSign credentials.
        req.setHeader('X-DocuSign-Authentication', 
                      '<DocuSignCredentials>' + 
                          '<Username>' + accConfig.dsfs__DSProSFUsername__c + '</Username>' + 
                          '<Password>' + accConfig.dsfs__DSProSFPassword__c + '</Password>' + 
                          '<IntegratorKey>' +  Label.OpaDocuSignIntegratorKey + '</IntegratorKey>' + 
                      '</DocuSignCredentials>');
                                                               
        return req;        
    }   
    
    public static String checkDocuSignResponse (HttpResponse res, List<String> serviceMessages)
    {    
        String responseString = null;     
        String responseBody = res.getBody();
        Integer responseStatusCode = res.getStatusCode();    
            
        System.Debug(LoggingLevel.DEBUG, 'Response Body: ' + responseBody); 
        System.Debug(LoggingLevel.DEBUG, 'Response Status Code: ' + responseStatusCode ); 
                 
        if (responseStatusCode  >= 200 && responseStatusCode < 300) 
        {
            responseString = responseBody.replaceAll('\r','').replaceAll('\n','');
            String result = 'Callout was made successfully.';
            System.debug(LoggingLevel.Debug, result);
            messages.add(result);            
        } 
        else if(responseStatusCode >= 300 && responseStatusCode < 400)
        {
            String result = 'Redirected';
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        else if(responseStatusCode >= 400 && responseStatusCode < 500)
        {
            if(responseStatusCode == 401)         
            {
                String result = 'Unauthorized';
                System.debug(LoggingLevel.DEBUG, result);
                messages.add(result);
            }            
            else if(responseStatusCode == 404)    
            {
                String result = 'Not Found';
                System.debug(LoggingLevel.DEBUG, result);
                messages.add(result);
            }            
            else
            {
                String result = 'Unknown FATAL Error';
                System.Debug(LoggingLevel.DEBUG, result);
                messages.add(result);
            }
        }
        else if(responseStatusCode >= 500 && responseStatusCode < 600)
        {
            String result = 'The web service call to DocuSign failed due to an internal server error (' + responseStatusCode + ').';
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        else 
        {
            String result = 'The web service call to DocuSign failed with an unexpected response status  (' + responseStatusCode + ').';
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        
        // Capture DocuSign response (if error, response contains errorCode: xxxxx, message: xxxxxx)
        if (responseBody.contains('errorCode'))
        {
            OpaSsaDocuSignResponse instance = OpaSsaDocuSignResponse.parse(responseBody);
            messages.add(instance.errorCode);
            messages.add(instance.message);
        }
        
        return responseString;
    }
       

    public static String getTemplateId (String endPointParameters, List<String> serviceMessages)
    {    
        // REST API   : template.list - Get templateId base on country
        // Parameters : country is required
        // Notes      : Template folder name must match with country name in the picklist
            
        String responseString = null;        
        HttpResponse res;
        
        try
        {              
            res = new Http().send(buildRequest (endPointParameters, OpaSsaStaticVariables.httpMethods.get('Read')));
            responseString = checkDocuSignResponse(res, serviceMessages);
        } 
        catch (System.CalloutException e)
        {
            String result = 'DocuSign REST API Callout ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        catch (System.Exception e)
        {
            String result = 'Unexpected ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);           
        }
        
        //return aggregated messages;
        for (String msg : messages)
        {
            serviceMessages.Add(msg);
        }

        return responseString;
    }
    
    
    public static String createAndSendEnvelope (String endPointParameters, String requestBody, List<String> serviceMessages)
    {
        // REST API   : envelopes.create - Send envelope to customer
        // Parameters : templateId, accountId (account guid) are required
        // Notes      : contentType is required to prevent error 415 - unsupported media type
                
        String responseString = null;   
        HttpResponse res;
        HttpRequest req = buildRequest(endPointParameters, OpaSsaStaticVariables.httpMethods.get('Create'));
        req.setBody(requestBody);
            
        try
        {            
            res = new Http().send(req);
            responseString = checkDocuSignResponse(res, serviceMessages);
        } 
        catch (System.CalloutException e)
        {
            String result = 'DocuSign REST API Callout ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        catch (System.Exception e)
        {
            String result = 'Unexpected ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);           
        }
        
        //return aggregated messages 
        for (String msg: messages)
        {
            serviceMessages.add(msg);
        }
        return responseString;
    }

    
    public static String updateEnvelope (String endPointParameters, String requestBody, List<String> serviceMessages)
    {    
        // REST API   : envelopes.update - resend envelope 
        // Parameters : templateId, accountId (account guid), resend_envelope = true are required
        // Notes      : contentType is required to prevent error 415 - unsupported media type
                
        String responseString = null;   
        HttpResponse res;
        HttpRequest req = buildRequest(endPointParameters, OpaSsaStaticVariables.httpMethods.get('Update'));
        req.setBody(requestBody);        
            
        try
        {            
            res = new Http().send(req);
            responseString = checkDocuSignResponse(res, serviceMessages);
        } 
        catch (System.CalloutException e)
        {
            String result = 'DocuSign REST API Callout ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        catch (System.Exception e)
        {
            String result = 'Unexpected ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);           
        }
        
        //return aggregated messages 
        for (String msg: messages)
        {
            serviceMessages.add(msg);
        }
           
        return responseString;
    }    
    
    
    public static String getSignerCustomTags(String endPointParameters, List<String> serviceMessages)
    {
        // REST API   : EnvelopeTabs.list - Get Signer 1's custom field entries
        // Parameters : accountId, envelopeId, recipientId (required and usually is 1)
        // Notes      : Response Data.Object contains signHereTabs, approveTabs, titleTabs, fullNameTabs, companyTabs
        //            : For custom fields: textTabs: Array .... can be used
        
        String responseString = null; 
        HttpResponse res;

        try
        {   
            res = new Http().send(buildRequest(endPointParameters, OpaSsaStaticVariables.httpMethods.get('Read')));
            responseString = checkDocuSignResponse(res, serviceMessages);
        } 
        catch (System.CalloutException e)
        {
            String result = 'DocuSign REST API Callout ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);
        }
        catch (System.Exception e)
        {
            String result = 'Unexpected ERROR: ' + e;
            System.debug(LoggingLevel.DEBUG, result);
            messages.add(result);           
        }
        
        //return messages 
        for (String msg: messages)
        {
            serviceMessages.add(msg);
        }
                
        return responseString;
    }

}