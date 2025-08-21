@isTest
global class EntitlementMockREST implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Map<String, String> responseHeaders;
    
    public EntitlementMockREST() {
        this.code = 200;
        this.status = 'SUCCESS';
        this.bodyAsString = '{"id" : "111-111-111"}';
        this.responseHeaders = new Map<String,String>();
        this.responseHeaders.put('Content-Type', 'application/json');
    }
    public EntitlementMockREST(Integer code, String status, String body, Map<String, String> responseHeaders) {
                                   this.code = code;
                                   this.status = status;
                                   this.bodyAsString = body;
                                   this.responseHeaders = responseHeaders;
                               }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(code);
        res.setStatus(status);
        res.setBody(bodyAsString);
        //res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"id" : "111-111-111"}');
        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                res.setHeader(key, responseHeaders.get(key));
            }
        }
        return res;
    }
}