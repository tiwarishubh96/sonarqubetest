global with sharing class SPPDocuSignBulkRestTestMockGenerator implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        req.setHeader('Content-Type', 'application/json');
       // System.assertEquals('https://demo.docusign.net/restapi/v2/accounts/', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
       
        string strVal = '{ "envelopeId": "f394b224-3a7f-42e4-8933-239e5da6aa80", "uri": "/envelopes/f394b224-3a7f-42e4-8933-239e5da6aa80","statusDateTime": "2017-06-15T14:37:11.9000000Z", "status": "created" ,"BulkEnvelopeStatus": '+
       '{' +
           ' "batchId": "sample string 1",'+
           ' "email": "sample string 2",'+
            '"name": "sample string 3",'+
            '"note": "sample string 4",'+
            '"accessCode": "sample string 5",'+
            '"identification": "sample string 6",'+
            '"phoneNumber": "sample string 7",'+
            '"tabLabels": ['+
                '{'+
               '     "name": "sample string 1",'+
              '      "value": "sample string 2"'+
             '   }'+
            '],'+
            '"recipientSignatureProviderInfo": ['+
             '   {'+
            '        "name": "sample string 1",'+
           '         "value": "sample string 2"'+
          '      }'+
         ' ] '+
        '},'+
       ' "bulkEnvelopes": ['+
       ' {'+
           ' "transactionId": "sample string 1",'+
           ' "submittedDateTime": "sample string 2",'+
            '"envelopeId": "12345",'+
            '"envelopeUri": "sample string 4",'+
            '"bulkRecipientRow": "sample string 5",'+
            '"name": "sample string 6",'+
            '"email": "xyzmail@mail.com",'+
            '"bulkStatus": "sample string 8",'+
            '"errorDetails": {'+
             '   "errorCode": "sample string 1",'+
              '  "message": "sample string 2"'+
            '}'+
        '}'+
    ']'+

    '}';
        // Create a fake response
        system.debug('Str: ' + strVal);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strVal);
        res.setStatusCode(200);
        return res;
    }
     
}