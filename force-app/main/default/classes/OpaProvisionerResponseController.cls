@RestResource(urlMapping='/CustomerSite/*')
global with sharing class OpaProvisionerResponseController 
{
  @HttpGet 
  global static void notifyProvisionStatus() 
  {
    RestResponse res = RestContext.response;
    String siteId = RestContext.request.params.get('siteId');
    String provisioningSuccessful = RestContext.request.params.get('provisioningSuccessful');
    String responseMessage = '';
    boolean invalidRequest = false;
    String successMessage = 'Successfully Updated CustomerSite\'s Provisioning Status based on Response form Provisioner.';
    String failureMessage = 'Invalid Request Parameter(s). Please check submitted values and try again.';

    //validate input fields
    if(siteId == null || String.isBlank(siteId))
    {
        invalidRequest = true;
        responseMessage = failureMessage;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(generateResponseObjectJson(!invalidRequest, responseMessage));
        return;
    }
    
    if(provisioningSuccessful == null || String.isBlank(provisioningSuccessful))
    {
        invalidRequest = true;
        responseMessage = failureMessage;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(generateResponseObjectJson(!invalidRequest, responseMessage));
        return;
    }

    // System.debug('Customer Site: ' + siteId);
    // System.debug('Provisioning Result: ' + provisioningSuccessful);
     
     List<OpaCustomerSite__c> site = [select 
                                    OpaCustomerSite__c.OpaProvisioningStatus__c 
                                from 
                                    OpaCustomerSite__c 
                                where 
                                    OpaCustomerSite__c.Name = :siteId];
       
    //validate that the correct site was indeed located
    if(site == null || site.isEmpty())
    {
        invalidRequest = true;
        res.statusCode = 400;
        responseMessage = failureMessage;
    }
    else
    {
        if(provisioningSuccessful.equals('true'))
        {
            site[0].OpaProvisioningStatus__c = 'Completed';
            res.statusCode = 200;
            responseMessage = successMessage;
        }
        else if(provisioningSuccessful.equals('false'))
        {
            site[0].OpaProvisioningStatus__c = 'Failed';
            res.statusCode = 200;
            responseMessage = successMessage;
        }                                        
        else
        {
            //do nothing to the site record
            invalidRequest = true;
            res.statusCode = 400;
            responseMessage = failureMessage;
        }
        
        update site; 
    }

    res.responseBody = Blob.valueOf(generateResponseObjectJson(!invalidRequest, responseMessage));
  }
  
  public static String generateResponseObjectJson(Boolean successfulRequest, String message)
  {
      return '{ "success" : ' + successfulRequest + ', "message" : "' + message + '" }';
  }
}