@isTest
global class OpaMockSsaUpdateEnvelopeResponse implements HttpCalloutMock 
{
    public class updateEnvelopeException extends Exception{}

    global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/json');
        String content = '';     
        
        if (req.getBody().contains('3xx')) 
        {
            System.assertEquals(true, req.getBody().contains('3xx'));
            res.setStatusCode(300);
        } 
        else if (req.getBody().contains('4xx')) 
        {
            System.assertEquals(true, req.getBody().contains('4xx'));
            res.setStatusCode(400);
        } 
        else if (req.getBody().contains('401')) 
        {
            System.assertEquals(true, req.getBody().contains('401'));
            res.setStatusCode(401);
        } 
        else if (req.getBody().contains('404')) 
        {
            System.assertEquals(true, req.getBody().contains('404'));
            res.setStatusCode(404);
        }
        else if (req.getBody().contains('5xx')) 
        {
            System.assertEquals(true, req.getBody().contains('5xx'));
            res.setStatusCode(500);
        } 
        else if (req.getBody().contains('600Else')) 
        {
            System.assertEquals(true, req.getBody().contains('600Else'));
            res.setStatusCode(600);
        }  
        else if (req.getEndpoint().contains('/recipients?advanced_update=true&resend_envelope=true')) 
        {
            System.assertEquals(true, req.getEndpoint().contains('/recipients?advanced_update=true&resend_envelope=true'));
            res.setStatusCode(200);
            content =  '{'
                            +'"recipientUpdateResults" :'
                            +'['
                            +'{'
                                +'"recipientId" : "1",'
                                +'"errorDetails":'
                                +'{'
                                    +'"errorCode" : "SUCCESS",'
                                    +'"message": ""'
                                +'}'
                            +'}'
                            +']'
                        +'}';
        } 
        else if (req.getEndPoint().contains('CalloutException')) 
        {
            System.assertEquals(true, req.getEndPoint().contains('CalloutException'));
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            throw e;
        }   
        else if (req.getEndPoint().contains('Exception')) 
        {
            System.assertEquals(true, req.getEndPoint().contains('Exception'));
            throw new updateEnvelopeException('updateEnvelopeException');
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