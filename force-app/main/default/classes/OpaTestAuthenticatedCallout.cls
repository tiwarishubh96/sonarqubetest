@isTest
private class OpaTestAuthenticatedCallout
{ 
    static testMethod void ValidRequestTest() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
    	
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'valid_request');
    		System.assertEquals(true, response != null);
    		System.assertEquals(true, response.success);
    		System.assertEquals('tenanduuid', response.tenantId);
    		System.assertEquals('configuid', response.configurationId);
    		System.assertEquals('http://url.com', response.configurationUrl);
		Test.stopTest();
    }
    
    static testMethod void RequestRedirectTest() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_307');
    		System.assertEquals(true, response != null);
    		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestErrorGeneral() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_general');
    		System.assertEquals(true, response != null);
    		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError30() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_30');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError31() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_31');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError09() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_09');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError11() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid'); 
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_11');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    
    
    static testMethod void InvalidRequestTestError50() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_50');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError43() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_43');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError41() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_41');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError42() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_42');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    
    
    static testMethod void InvalidRequestTestError45() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid'); 
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_45');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    
    
    static testMethod void InvalidRequestTestError20() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');  
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_20');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError28() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_28');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError21() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid'); 
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_21');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestError27() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_27');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestErrorUnexpected() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid'); 
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_authentication_error_xx');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
     		System.assertEquals(true, response.message.contains('Unexpected authentication related issue'));
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestErrorInvalidEndpointUrl() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('invalid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'invalid_endpoint_url');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
     		System.assertEquals(true, response.message.contains('Endpoint Not Found'));
		Test.stopTest();
    }
    
    
    static testMethod void InvalidRequestTestAuthenitcationErrorUnexpected() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'unexpected_response_status');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
     		System.assertEquals(true, response.message.contains('FATAL Error'));
		Test.stopTest();
    }
			
    
    static testMethod void InvalidRequestTestErrorInternalServerError() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('invalid'); 
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'internal_server_error');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
     		System.assertEquals(true, response.message.contains('ECONNRESET'));
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestErrorUnexpectedServerError() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'unexpected_server_error');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    
    static testMethod void InvalidRequestTestClientCalloutException() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'client_callout_exception');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestClientCalloutExceptionUnexpected() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid'); 
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'client_callout_unexpected_exception');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void InvalidRequestTestExceptionUnexpected() 
    {
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');  
        
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
    		OpaMindoResponse response = OpaAuthenticatedCallout.makeProvisioningCall(endpoint, 'some_unexpected_exception');
    		System.assertEquals(true, response != null);
     		System.assertEquals(false, response.success);
		Test.stopTest();
    }
    
    static testMethod void ExtractMessageTest() 
    {
    	Test.startTest();
    	    String message = OpaAuthenticatedCallout.extractMessage('{"message":"ECONNRESET"}'); 
    		System.assertEquals(true, message != null);
    		System.assertEquals('ECONNRESET', message);
		Test.stopTest();
    }
    
}