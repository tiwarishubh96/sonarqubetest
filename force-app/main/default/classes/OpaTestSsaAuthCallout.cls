@isTest 
private class OpaTestSsaAuthCallout
{   
    static testMethod void buildRequestTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('1', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();     
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/templates?search_text=' 
                                    + '%'
                                    + EncodingUtil.urlEncode(customersite.OpaProduct__c, 'UTF-8')
                                    + '-'
                                    + EncodingUtil.urlEncode(customersite.OpaCountry__c, 'UTF-8')
                                    + '%';
          
        HttpRequest req = new HttpRequest();          
        Test.startTest();
        req = OpaSsaAuthCallout.buildRequest(endPointParameters, 'GET');
        Test.stopTest();
        
        System.assertEquals(req.getHeader('Content-Type'), OpaSsaStaticVariables.contentType);
        System.assertEquals(req.getHeader('Accept'), OpaSsaStaticVariables.contentType);
    }


    static testMethod void getTemplateIdResponseTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('1', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();    
    
        List<String> serviceMessages = new List<String>();
        List<String> parameterValues = new List<String>();
        parameterValues.add('%' 
                             + EncodingUtil.urlEncode(customersite.OpaProduct__c, 'UTF-8') 
                             + '-'
                             + EncodingUtil.urlEncode(customersite.OpaCountry__c, 'UTF-8') 
                             + '%'
                            );                                      

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());          
        String responseString = OpaSsaAuthCallout.getTemplateId( OpaSsaUtils.generateResourceDetailsUrl('getTemplateId', parameterValues), serviceMessages );    
        Test.stopTest();

        System.assertEquals(true, responseString.contains('templateId'));        
    }
    
    
    static testMethod void getTemplateIdResponseTestWithInvalidParameter() 
    {
        OpaTestSsaDataFactory.createDocuSignConfiguration();      
        List<String> serviceMessages = new List<String>();
        List<String> parameterValues = new List<String>();
        parameterValues.add('%X3-USA%');                                     
                       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());         
        String responseString = OpaSsaAuthCallout.getTemplateId( OpaSsaUtils.generateResourceDetailsUrl('getTemplateId', parameterValues), serviceMessages );
        Test.stopTest();
        
        System.assertEquals(false, responseString.contains('templateId'));        
    }    
    
    
    static testMethod void createAndSendEnvelopeResponseTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('2', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '3a2d43cc-fe5b-4455-93c4-342f236709ff', //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();
        
        System.assertEquals(true, responseString.contains('envelopeId')); // check status code = 201 - Created
        if (String.IsNotEmpty(responseString))
        {
            OpaSsaCreateAndSendEnvelopeResponse instance = OpaSsaCreateAndSendEnvelopeResponse.parse(responseString);
            System.assertEquals('3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f',instance.envelopeId);
            System.assertEquals('Sent', instance.status.capitalize());
        }       
    }  


    static testMethod void createAndSendEnvelopeResponseInvalidTemplateIdTest() 
    {   
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('2', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration(); 
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      'invalid_templateId', //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();

        System.assertEquals(true, responseString.contains('errorCode')); 
        if (String.IsNotEmpty(responseString))
        {
            OpaSsaDocuSignResponse instance = OpaSsaDocuSignResponse.parse(responseString);
            System.assertEquals('INVALID_REQUEST_PARAMETER', instance.errorCode);
            System.assertEquals('The request contained at least one invalid parameter. Invalid value specified for \'templateId\'', instance.message);
        }       
    }         
    
    
    static testMethod void getSigner1CustomTagsResponseTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('2', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();     
    
        List<String> serviceMessages = new List<String>();
        Map<String, String> signerTagsMap = new Map<String, String>();
        String endPointParameters = '/envelopes/' + customersite.OpaEnvelopeId__c + '/recipients/1/tabs';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetSignerCustomTagsResponse());  
        String responseString = OpaSsaAuthCallout.getSignerCustomTags( endPointParameters, serviceMessages );    
        Test.stopTest();
        
        if (String.isNotEmpty(responseString))
        {
            signerTagsMap = OpaSsaGetSignerCustomTagsResponse.parseSigner1CustomTags ( responseString );   
            System.assertEquals ( 'John Doe', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[0] ) );
            System.assertEquals ( 'C.E.O', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[1] ) );               
            System.assertEquals ( 'amazon', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[2] ) );  
            System.assertEquals ( '12345', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[3] ) );
            System.assertEquals ( '7595 Irvine Center Drive', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[4]) );
            System.assertEquals ( 'Suite 200', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[5] ) );  
            System.assertEquals ( 'Irvine, CA 92618-2313', signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[6] ) );   
        } 
    }
    
    static testMethod void getSigner2CustomTagsResponseTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('2', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration(); 
        
        List<String> serviceMessages = new List<String>();
        Map<String, String> signerTagsMap = new Map<String, String>();
        String endPointParameters = '/envelopes/' + customersite.OpaEnvelopeId__c + '/recipients/2/tabs';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetSignerCustomTagsResponse());
        String responseString = OpaSsaAuthCallout.getSignerCustomTags( endPointParameters, serviceMessages );    
        Test.stopTest();
        
        if (String.isNotEmpty(responseString))
        {
            signerTagsMap = OpaSsaGetSignerCustomTagsResponse.parseSigner2CustomTags ( responseString );   
            System.assertEquals ( 'Jane Doe', signerTagsMap.get(OpaSsaStaticVariables.secondSignerTags[0]) );
            System.assertEquals ( 'C.F.O', signerTagsMap.get(OpaSsaStaticVariables.secondSignerTags[1]) );               
        } 
    }    
    

    static testMethod void updateEnvelopeResponseTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();     
    
        List<String> serviceMessages = new List<String>(); 
        String endPointParameters = '/envelopes/' 
                                    + customersite.OpaEnvelopeId__c
                                    + '/recipients?advanced_update=true&resend_envelope=true'; 
                                    
        String requestBody = OpaSsaUtils.generateResendSsaSigner1RequestBody ( 
                                                                               customersite.OpaEmail__c, 
                                                                               customersite.OpaFirstName__c,
                                                                               customersite.OpaLastName__c,
                                                                               customersite.OpaRegistrationNumber__c,
                                                                               customersite.OpaCompanyName__c,
                                                                               customersite.OpaAddressLine1__c,
                                                                               customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                               customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c                                                                                
                                                                             ); 
                              
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse()); 
        String responseString = OpaSsaAuthCallout.updateEnvelope( endPointParameters, requestBody, serviceMessages );    
        Test.stopTest();
        
        if (String.isNotEmpty(responseString))
        {
            OpaSsaUpdateEnvelopeResponse instance = OpaSsaUpdateEnvelopeResponse.parse( responseString );
            System.assertEquals(true, responseString.contains('SUCCESS'));                         
        } 
    }        
    
    static testmethod void checkDocuSignResponseTest3xx()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();    
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '3xx', 
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();

        System.assertEquals(true, String.join(serviceMessages,'\n').contains('Redirected'));
    }
    
    static testmethod void checkDocuSignResponseTest4xx()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();      
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '4xx', //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    ); 
                                                                    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();
        
        System.assertEquals(true, String.join(serviceMessages,'\n').contains('Unknown FATAL Error'));
    }
    
    static testmethod void checkDocuSignResponseTest401()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();      
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '401',  //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());        
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();
        
        System.assertEquals(true, String.join(serviceMessages,';').contains('Unauthorized'));
    }    
    
    static testmethod void checkDocuSignResponseTest404()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();    
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '404',  //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());        
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();

        System.assertEquals(true, String.join(serviceMessages,';').contains('Not Found'));
    } 

    static testmethod void checkDocuSignResponseTest5xx()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '5xx',   //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());        
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();
       
        System.assertEquals(true, String.join(serviceMessages,';').contains('The web service call to DocuSign failed due to an internal server error'));
    }
    
    
    static testmethod void checkDocuSignResponseTest600Else()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = '/envelopes'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '600Else', //templateId,
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());
        String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        Test.stopTest();
       
        System.assertEquals(true, String.join(serviceMessages,';').contains('The web service call to DocuSign failed with an unexpected response status'));
    }
    
        
    static testMethod void getTemplateIdResponseCalloutExceptionTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = 'CalloutException'; 

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());
        try
        {
            String responseString = OpaSsaAuthCallout.getTemplateId( endPointParameters, serviceMessages );    
        }
        catch (CalloutException e)
        {
           System.assertEquals(true, String.join(serviceMessages,';').contains('DocuSign REST API Callout ERROR'));
        }
        Test.stopTest();
    }
    
    
    static testmethod void CreateAndSendEnvelopeCalloutExceptionTest()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = 'CalloutException'; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      '3a2d43cc-fe5b-4455-93c4-342f236709ff',
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());        
        try 
        {
            String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        }
        catch (CalloutException e)
        {
           System.assertEquals(true, String.join(serviceMessages,';').contains('DocuSign REST API Callout ERROR'));
        }
        Test.stopTest();
    }   

    static testMethod void getSignerCustomTagsCalloutExceptionTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = 'CalloutException';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetSignerCustomTagsResponse());        
        try
        {
            String responseString = OpaSsaAuthCallout.getSignerCustomTags( endPointParameters, serviceMessages );    
        }
        catch (CalloutException e)
        {
            System.assertEquals(true, String.join(serviceMessages,';').contains('DocuSign REST API Callout ERROR'));
        }
        Test.stopTest();
    }
    
    
    static testMethod void updateEnvelopeCalloutExceptionTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
        
        List<String>serviceMessages = new List<String>(); 
        String endPointParameters = 'CalloutException';
        
        String requestBody = OpaSsaUtils.generateResendSsaSigner2RequestBody( 
                                                                              customersite.OpaSecondContactEmail__c,
                                                                              customersite.OpaSecondContactFirstName__c,
                                                                              customersite.OpaSecondContactLastName__c
                                                                            );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse());         
        try
        {
             String responseString = OpaSsaAuthCallout.updateEnvelope(endPointParameters, requestBody, serviceMessages);        
        }
        catch (Exception e)
        {
            System.assertEquals(true, String.join(serviceMessages,';').contains('Unexpected ERROR'));
        }
        Test.stopTest();
    }     
    

    static testMethod void getTemplateIdResponseExceptionTest() 
    {   
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();  
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = 'Exception';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());          
        try
        {
            String responseString = OpaSsaAuthCallout.getTemplateId( endPointParameters, serviceMessages );    
        }
        catch (Exception e)
        {
            System.assertEquals(true, String.join(serviceMessages,';').contains('Unexpected ERROR'));
        }
        Test.stopTest();
    }      
    
    
    static testmethod void CreateAndSendEnvelopeExceptionTest()
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();      
    
        List<String> serviceMessages = new List<String>();
        String endPointParameters = null; 
        
        String requestBody = OpaSsaUtils.generateSendSsaRequestBody(  
                                                                      OpaSsaStaticVariables.emailSubject, 
                                                                      'Exception',
                                                                      customersite.OpaEmail__c, 
                                                                      customersite.OpaFirstName__c,
                                                                      customersite.OpaLastName__c,
                                                                      customersite.OpaRequireSecondSignatureOnSSA__c,
                                                                      customersite.OpaSecondContactEmail__c,
                                                                      customersite.OpaSecondContactFirstName__c,
                                                                      customersite.OpaSecondContactLastName__c,
                                                                      customersite.OpaRegistrationNumber__c,
                                                                      customersite.OpaCompanyName__c,
                                                                      customersite.OpaAddressLine1__c,
                                                                      customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                      customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c 
                                                                    );            

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaCreateAndSendEnvelopeResponse());        
        try 
        {
            String responseString = OpaSsaAuthCallout.createAndSendEnvelope ( endPointParameters, requestBody, serviceMessages );
        }
        catch (Exception e)
        {
            System.assertEquals(true, String.join(serviceMessages,';').contains('Unexpected ERROR'));
        }
        Test.stopTest();
    }   
    

    static testMethod void getSignerCustomTagsExceptionTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration(); 
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = 'Exception';
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetSignerCustomTagsResponse());        
        try
        {
            String responseString = OpaSsaAuthCallout.getSignerCustomTags( endPointParameters, serviceMessages );    
        }
        catch (Exception e)
        {
            System.assertEquals(true, String.join(serviceMessages,';').contains('Unexpected ERROR'));
        }
        Test.stopTest();
    }    
    
    
    static testMethod void updateEnvelopeExceptionTest() 
    {
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();     
    
        List<String>serviceMessages = new List<String>(); 
        String envelopeId = customersite.OpaEnvelopeId__c;
        String endPointParameters = 'Exception';
        String requestBody = OpaSsaUtils.generateResendSsaSigner2RequestBody( 
                                                                              customersite.OpaSecondContactEmail__c,
                                                                              customersite.OpaSecondContactFirstName__c,
                                                                              customersite.OpaSecondContactLastName__c        
                                                                            );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse()); 
        try
        {
             String responseString = OpaSsaAuthCallout.updateEnvelope(endPointParameters, requestBody, serviceMessages);        
        }
        catch (Exception e)
        {
            System.assertEquals(true, String.join(serviceMessages,';').contains('Unexpected ERROR'));
        }
        Test.stopTest();
    }      
    
    
}