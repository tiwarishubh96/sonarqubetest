@isTest
global class ZuoraMockHttpResponseGenerator implements HttpCalloutMock {
	 // Implement this interface method
         global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://apisandbox-api.zuora.com/rest/v1/connections', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Id":"2c92c0f84dfff49f014e021c79b82bb6","VAT_Number__c":"FR-123456", "TaxExemptCertificateID":"FR-123456", "TaxExemptStatus":"YES"}');
        res.setStatusCode(200);
        return res;
    }
}