@isTest
global class PaymentPageSignatureMockREST implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success": true, "signature" : "sig1234567890", "token" : "98j32P4k2raWdiuh9p0ld0JsUsz4IARv","key": "key12345", "tenantId" : "ten12345"}');
        res.setStatusCode(200);
        return res;
    }
}