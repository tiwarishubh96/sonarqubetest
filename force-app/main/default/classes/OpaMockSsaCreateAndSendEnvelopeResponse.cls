@isTest
global class OpaMockSsaCreateAndSendEnvelopeResponse implements HttpCalloutMock 
{
    public class createAndSendEnvelopeException extends Exception{}
    
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
        else if (req.getEndPoint().contains('CalloutException')) 
        {
            System.assertEquals(true, req.getEndPoint().contains('CalloutException'));
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            throw e;
        }           
        else if (req.getBody().contains('Exception')) 
        {
            System.assertEquals(true, req.getBody().contains('Exception'));
            throw new createAndSendEnvelopeException('createAndSendEnvelopeException');
        }       
        else if (req.getBody().contains('invalid_templateId')) 
        {
            System.assertEquals(true, req.getBody().contains('invalid_templateId'));
            content = '{'
                            +'"errorCode": "INVALID_REQUEST_PARAMETER",'
                            +'"message": "The request contained at least one invalid parameter. Invalid value specified for \'templateId\'"'
                      +'}';
            res.setStatusCode(200);                      
        } 
        else if (req.getEndpoint().contains('/envelopes')) 
        {
            System.assertEquals(true, req.getEndpoint().contains('/envelopes'));
            res.setStatusCode(201);
            content =  '{'
                            +'"envelopeId": "3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f",'
                            +'"uri": "/envelopes/3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f",'
                            +'"statusDateTime": "2018-04-04T22:09:08.2389426Z",'
                            +'"status": "sent"'
                       +'}';
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