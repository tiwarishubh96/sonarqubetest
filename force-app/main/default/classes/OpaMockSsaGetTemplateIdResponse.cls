@isTest
global class OpaMockSsaGetTemplateIdResponse implements HttpCalloutMock 
{
    public class getTemplateIdException extends Exception{}
    
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
        else if (req.getEndPoint().contains('search_text=%X3-United+States%')) 
        {   
            System.assertEquals(true, req.getEndPoint().contains('search_text=%X3-United+States%'));
            res.setStatusCode(200);
            content =  '{'
                           +'"envelopeTemplates": ['
                               +'{'
                                    +'"templateId": "b3dcb808-2f23-4299-904b-c8534e85022d",' //X3-United States
                                    +'"name": "SSA template for X3+United States",'
                                    +'"shared": "true",'
                                    +'"password": "",'
                                    +'"description": "This is the subscription services agreement template for United States.",'
                                    +'"lastModified": "2018-03-30T19:12:03.5330000Z",'
                                    +'"created": "0001-01-01T00:00:00.0000000Z",'
                                    +'"pageCount": 1,'
                                    +'"uri": "/templates/b3dcb808-2f23-4299-904b-c8534e85022b",'
                                    +'"folderName": "United States",'
                                    +'"folderId": "638aec0d-a47f-4cf8-83c0-7aec5a01f6e1",'
                                    +'"folderUri": "/folders/638aec0d-a47f-4cf8-83c0-7aec5a01f6e1",'
                                    +'"owner": {'
                                        +'"userName": "Alfred Kay",'
                                        +'"userId": "214820a5-27bc-4d11-baeb-d68add71edfd",'
                                        +'"email": "alfredkay+opadev1@gmail.com"'
                                    +'},'
                                    +'"emailSubject": "Please DocuSign: SSA_UnitedStates.pdf",'
                                    +'"emailBlurb": "Hi, Please sign the SSA. \n\nthank you\nSage team",'
                                    +'"signingLocation": "Online",'
                                    +'"authoritativeCopy": "false",'
                                    +'"enforceSignerVisibility": "false",'
                                    +'"enableWetSign": "true",'
                                    +'"allowMarkup": "false",'
                                    +'"allowReassign": "true"'
                                +'}'
                            +'],'
                            +'"resultSetSize": "1",'
                            +'"startPosition": "0",'
                            +'"endPosition": "0",'
                            +'"totalSetSize": "1"'
                        +'}';
        } 
        else if (req.getEndPoint().contains('search_text=%X3-USA%')) //X3-USA is invalid 
        {   
            System.assertEquals(true, req.getEndPoint().contains('search_text=%X3-USA%'));
            res.setStatusCode(200);
            content =  '{'
                            +'"errorCode": "INVALID_REQUEST_PARAMETER",'
                            +'"message": "The request contained at least one invalid parameter. Invalid value specified for folder."'
                        +'}';
        }         
        else if (req.getEndPoint().contains('invalid_templateId')) 
        {   
            System.assertEquals(true, req.getEndPoint().contains('invalid_templateId'));
            res.setStatusCode(200);
            content =  '{'
                           +'"envelopeTemplates": ['
                               +'{'
                                    +'"templateId": "",'  //force resturn empty templateId
                                    +'"name": "SSA template for X3+United States",'
                                    +'"shared": "true",'
                                    +'"password": "",'
                                    +'"description": "This is the subscription services agreement template for United States.",'
                                    +'"lastModified": "2018-03-30T19:12:03.5330000Z",'
                                    +'"created": "0001-01-01T00:00:00.0000000Z",'
                                    +'"pageCount": 1,'
                                    +'"uri": "/templates/b3dcb808-2f23-4299-904b-c8534e85022b",'
                                    +'"folderName": "United States",'
                                    +'"folderId": "638aec0d-a47f-4cf8-83c0-7aec5a01f6e1",'
                                    +'"folderUri": "/folders/638aec0d-a47f-4cf8-83c0-7aec5a01f6e1",'
                                    +'"owner": {'
                                        +'"userName": "Alfred Kay",'
                                        +'"userId": "214820a5-27bc-4d11-baeb-d68add71edfd",'
                                        +'"email": "alfredkay+opadev1@gmail.com"'
                                    +'},'
                                    +'"emailSubject": "Please DocuSign: SSA_UnitedStates.pdf",'
                                    +'"emailBlurb": "Hi, Please sign the SSA. \n\nthank you\nSage team",'
                                    +'"signingLocation": "Online",'
                                    +'"authoritativeCopy": "false",'
                                    +'"enforceSignerVisibility": "false",'
                                    +'"enableWetSign": "true",'
                                    +'"allowMarkup": "false",'
                                    +'"allowReassign": "true"'
                                +'}'
                            +'],'
                            +'"resultSetSize": "1",'
                            +'"startPosition": "0",'
                            +'"endPosition": "0",'
                            +'"totalSetSize": "1"'
                        +'}';
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
        else if (req.getEndPoint().contains('CalloutException')) 
        {
            System.assertEquals(true, req.getEndPoint().contains('CalloutException'));
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            throw e;
        }   
        else if (req.getEndPoint().contains('Exception')) 
        {
            System.assertEquals(true, req.getEndPoint().contains('Exception'));
            throw new getTemplateIdException('getTemplateException');
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