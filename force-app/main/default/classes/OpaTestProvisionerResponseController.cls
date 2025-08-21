@isTest
private class OpaTestProvisionerResponseController
{ 
    static testMethod void TestNotifyProvisionStatusSuccess()    
    {
        String companyName = 'SomeTestSite';
        OpaTestDataFactory.createSite(companyName);
        
        OpaCustomerSite__c site = [select 
                                       OpaCustomerSite__c.Name,
                                       OpaCustomerSite__c.Id,
                                       OpaCustomerSite__c.OpaCompanyName__c,
                                       OpaCustomerSite__c.OpaProvisioningStatus__c 
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerSite/'; 
            req.addParameter('siteId', site.Name);
            req.addParameter('provisioningSuccessful', 'true');
            
        	req.httpMethod = 'GET';  
            RestContext.request = req;
        	RestContext.response = res;
        	
            OpaProvisionerResponseController.notifyProvisionStatus();
        Test.stopTest();
        
        //perform asserts to make sure the reponse object contains the proper status, etc.
        System.debug(LoggingLevel.DEBUG,'TestNotifyProvisionStatusSuccess: Status(' + res.statusCode + ') Body(' + res.responseBody.toString() + ')' + ' Site Info: Id(' + site.Id + ') CompanyName(' + companyName + ')');
        System.assertEquals(res.statusCode, 200);
    }
    
    static testMethod void TestNotifyProvisionStatusSiteNotSupplied()    
    {
        Test.startTest();
            RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerSite/'; 
            req.addParameter('siteId', '');
            req.addParameter('provisioningSuccessful', 'true');
            
        	req.httpMethod = 'GET';  
            RestContext.request = req;
        	RestContext.response = res;
        	
            OpaProvisionerResponseController.notifyProvisionStatus();
        Test.stopTest();
        
        //perform asserts to make sure the reponse object contains the proper status, etc.
        System.debug(LoggingLevel.DEBUG,'TestNotifyProvisionStatusSiteNotSupplied: Status(' + res.statusCode + ') Body(' + res.responseBody.toString() + ')');
        System.assertEquals(res.statusCode, 400);
    }
    
    static testMethod void TestNotifyProvisionStatusFailed()    
    {
        String companyName = 'SomeTestSite';
        OpaTestDataFactory.createSite(companyName);
        
        OpaCustomerSite__c site = [select 
                                       OpaCustomerSite__c.Name,
                                       OpaCustomerSite__c.Id,
                                       OpaCustomerSite__c.OpaCompanyName__c,
                                       OpaCustomerSite__c.OpaProvisioningStatus__c 
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerSite/'; 
            req.addParameter('siteId', site.Name);
            req.addParameter('provisioningSuccessful', 'false');
            
        	req.httpMethod = 'GET';  
            RestContext.request = req;
        	RestContext.response = res;
        	
            OpaProvisionerResponseController.notifyProvisionStatus();
        Test.stopTest();
        
        //perform asserts to make sure the reponse object contains the proper status, etc.
        System.debug(LoggingLevel.DEBUG,'TestNotifyProvisionStatusFailed: Status(' + res.statusCode + ') Body(' + res.responseBody.toString() + ')' + ' Site Info: Id(' + site.Id + ') CompanyName(' + companyName + ')');
        System.assertEquals(res.statusCode, 200);
    }
    
    static testMethod void TestNotifyProvisionStatusProvisionerStatusNotSupplied()    
    {
        String companyName = 'SomeTestSite';
        OpaTestDataFactory.createSite(companyName);
        
        OpaCustomerSite__c site = [select 
                                       OpaCustomerSite__c.Name,
                                       OpaCustomerSite__c.Id,
                                       OpaCustomerSite__c.OpaCompanyName__c,
                                       OpaCustomerSite__c.OpaProvisioningStatus__c 
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerSite/'; 
            req.addParameter('siteId', site.Name);
            req.addParameter('provisioningSuccessful', '');
            
        	req.httpMethod = 'GET';  
            RestContext.request = req;
        	RestContext.response = res;
        	
            OpaProvisionerResponseController.notifyProvisionStatus();
        Test.stopTest();
        
        //perform asserts to make sure the reponse object contains the proper status, etc.
        System.debug(LoggingLevel.DEBUG,'TestNotifyProvisionStatusProvisionerStatusNotSupplied: Status(' + res.statusCode + ') Body(' + res.responseBody.toString() + ')' + ' Site Info: Id(' + site.Id + ') CompanyName(' + companyName + ')');
        System.assertEquals(res.statusCode, 400);
    }
    
    static testMethod void TestNotifyProvisionStatusProvisionerStatusInvalid()    
    {
        String companyName = 'SomeTestSite';
        OpaTestDataFactory.createSite(companyName);
        
        OpaCustomerSite__c site = [select 
                                       OpaCustomerSite__c.Name,
                                       OpaCustomerSite__c.Id,
                                       OpaCustomerSite__c.OpaCompanyName__c,
                                       OpaCustomerSite__c.OpaProvisioningStatus__c 
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
            RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerSite/'; 
            req.addParameter('siteId', site.Name);
            req.addParameter('provisioningSuccessful', 'abc');
            
        	req.httpMethod = 'GET';  
            RestContext.request = req;
        	RestContext.response = res;
        	
            OpaProvisionerResponseController.notifyProvisionStatus();
        Test.stopTest();
        
        //perform asserts to make sure the reponse object contains the proper status, etc.
        System.debug(LoggingLevel.DEBUG,'TestNotifyProvisionStatusProvisionerStatusInvalid: Status(' + res.statusCode + ') Body(' + res.responseBody.toString() + ')' + ' Site Info: Id(' + site.Id + ') CompanyName(' + companyName + ')');
        System.assertEquals(res.statusCode, 400);
    }
    
        
    static testMethod void TestNotifyProvisionStatusSiteDoesNotExist()    
    {
        Test.startTest();
            RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/CustomerSite/'; 
            req.addParameter('siteId', 'DCX001'); //ficticious id that does not exist to test the non-existent site case
            req.addParameter('provisioningSuccessful', 'false');
            
        	req.httpMethod = 'GET';  
            RestContext.request = req;
        	RestContext.response = res;
        	
            OpaProvisionerResponseController.notifyProvisionStatus();
        Test.stopTest();
        
        //perform asserts to make sure the reponse object contains the proper status, etc.
        System.debug(LoggingLevel.DEBUG,'TestNotifyProvisionStatusSiteDoesNotExist: Status(' + res.statusCode + ') Body(' + res.responseBody.toString() + ')');
        System.assertEquals(res.statusCode, 400);
    }
}