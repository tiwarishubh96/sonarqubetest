@isTest
global class OpaMockAuthenticatedCalloutResponse implements HttpCalloutMock 
{
	global HttpResponse respond(HttpRequest req) 
	{
		HttpResponse res = new HttpResponse();
		
        res.setHeader('Content-Type', 'application/json');
        String content = '';        
        
        if (req.getBody().contains('valid_request')) 
        {
        	System.assertEquals(true, req.getBody().contains('valid_request'));
            content = '{"tenantId":"tenanduuid","configurationId":"configuid","configurationUrl":"http://url.com","dryRun":true}';
            res.setStatusCode(200);
		}
		else if (req.getBody().contains('TestSite01')) 
        {
        	System.assertEquals(true, req.getBody().contains('TestSite01'));
            content = '{"tenantId":"tenanduuid","configurationId":"configuid","configurationUrl":"http://url.com","dryRun":true}';
            res.setStatusCode(200);
		}
		else if (req.getBody().contains('TestSite02')) 
        {
        	System.assertEquals(true, req.getBody().contains('TestSite02'));
            content = '{"message":"some invalid case"}';
            res.setStatusCode(400);
		}
		else if (req.getBody().contains('invalid_307')) 
        {
        	System.assertEquals(true, req.getBody().contains('invalid_307'));
            content = 'abc auth/login/page def';
            res.setStatusCode(307);
		} 
		else if (req.getBody().contains('invalid_authentication_general')) 
		{
			System.assertEquals(true, req.getBody().contains('invalid_authentication_general'));
            content = 'Some invalid response here';
            res.setStatusCode(400);
		} 
		else if (req.getBody().contains('invalid_authentication_error_09')) 
		{
			System.assertEquals(true, req.getBody().contains('invalid_authentication_error'));
			String errorNumber = '9';
			System.debug(LoggingLevel.DEBUG, 'errorNumber: ' + errorNumber);
            content = 'Error ' + errorNumber + ': Some invalid response here';
            res.setStatusCode(401);
		} 
		else if (req.getBody().contains('invalid_authentication_error')) 
		{
			System.assertEquals(true, req.getBody().contains('invalid_authentication_error'));
			String errorNumber = req.getBody().subString(29,31);
			System.debug(LoggingLevel.DEBUG, 'errorNumber: ' + errorNumber);
            content = 'Error ' + errorNumber + ': Some invalid response here';
            res.setStatusCode(401);
		} 
		else if (req.getBody().contains('invalid_endpoint_url')) 
		{
			System.assertEquals(true, req.getBody().contains('invalid_endpoint_url'));
            content = 'Web Service not found';
            res.setStatusCode(404);
		} 
		else if (req.getBody().contains('unexpected_response_status')) 
		{
			System.assertEquals(true, req.getBody().contains('unexpected_response_status'));
            content = '{"message":"ACXDSE##@$"}';
            res.setStatusCode(405);
		} 
		else if (req.getBody().contains('internal_server_error')) 
		{
			System.assertEquals(true, req.getBody().contains('internal_server_error'));
            content = '{"message":"ECONNRESET"}';
            res.setStatusCode(500);
		} 
		else if (req.getBody().contains('unexpected_server_error')) 
		{
			System.assertEquals(true, req.getBody().contains('unexpected_server_error'));
            content = '{"message":"ACXDSE##@$"}';
            res.setStatusCode(888);
		}  
		else if (req.getBody().contains('client_callout_exception')) 
		{
			System.assertEquals(true, req.getBody().contains('client_callout_exception'));
            throw new System.CalloutException('Unauthorized endpoint reached');
		}   
		else if (req.getBody().contains('client_callout_unexpected_exception')) 
		{
			System.assertEquals(true, req.getBody().contains('client_callout_unexpected_exception'));
            throw new System.CalloutException('Some unexpected issue occured');
		} 
		else if (req.getBody().contains('some_unexpected_exception')) 
		{
			System.assertEquals(true, req.getBody().contains('some_unexpected_exception'));
            throw new OpaUtils.UncaughtException('Some unexpected issue occured and we are trying to make the message go above the limit of 256 characters to test the scenario where the message field goes above this limit to see if the implementation handles this case properly meaning it will truncate messages that are longer than 255 characters.');
		} 
        else 
        {            
        	content = 'UNHANDLED REQUEST, MUST IMPLEMENT A MOCKED RESPONSE FOR THIS REQUEST';
        	res.setStatusCode(integer.valueof(req.getBody()));
        }
        res.setBody(content);
        return res;
	}
	
}