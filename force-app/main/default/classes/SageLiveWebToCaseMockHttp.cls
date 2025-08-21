@isTest
public class SageLiveWebToCaseMockHttp implements HttpCalloutMock{
    
	public HTTPResponse respond(HTTPRequest req) 
    {   
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<soapenv:Envelope><soapenv:Body>Response 1</soapenv:Body></soapenv:Envelope>');
        system.assertEquals(true, res != null, 'Respons should be populated');
        return res;
    }
}