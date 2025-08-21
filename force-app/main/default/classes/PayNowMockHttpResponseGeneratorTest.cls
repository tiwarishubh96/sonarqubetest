@isTest
global class PayNowMockHttpResponseGeneratorTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://sage-commerce-qa-a.azurewebsites.net/api/PurchaseRequest2', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"purchase-token-id": "be5c6018-af15-47b7-9cb5-fba964ae423b"}');
        res.setStatusCode(200);
        return res;
    }
}