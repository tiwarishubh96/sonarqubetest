@isTest
public class OpaTestSsaUtils
{
    static testMethod void getEndPointTest() 
    {
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        dsfs__DocuSignAccountConfiguration__c accConfig = OpaTestSsaDataFactory.getAccountConfiguration();

        String endPointParameters = '/envelopes'; 
         
        Test.startTest();
        String endPoint = OpaSsaUtils.getEndPoint( accConfig.dsfs__DocuSignBaseURL__c, 
                                                   accConfig.dsfs__AccountId__c, 
                                                   endPointParameters );
        Test.stopTest();
        
        System.AssertEquals(accConfig.dsfs__DocuSignBaseURL__c + 'restapi/v2/accounts/' + accConfig.dsfs__AccountId__c + '/envelopes', endPoint);
    }
    
    static testMethod void generateSendSsaRequestBodyTest() 
    {
          String emailSubject = OpaSsaStaticVariables.emailSubject;
          String templateId = 'b3dcb808-2f23-4299-904b-c8534e85022b';
          String contactEmail = 'alfred.kay@sage.com';
          String contactFirstName = 'Alfred';
          String contactLastName = 'Kay';
          boolean requireSecondSignature = true;
          String secondContactEmail = 'tim.ho@sage.com';
          String secondContactFirstName = 'Tim';
          String secondContactLastName = 'Ho';
          String registrationNumber = '12345';
          String companyName = 'Sage';
          String addressLine1 = '7595 Irvine Center Drive';
          String addressLine2 = 'Suite 200';
          String addressLine3 = 'Irvine, CA 92618';
          
          // Target: SendSsa request body
          String expectedStr = 
           '{ ' + 
              '"emailSubject" : "' + emailSubject + '", ' + 
              '"status" : "sent", ' + 
              '"templateId" : "' + templateId + '", ' + 
              '"templateRoles" : [ ' +
              '{ '+ 
                  '"email" : "' + contactEmail + '", ' + 
                  '"name" : "'  + contactFirstName + ' ' + contactLastName + '", ' + 
                  '"roleName" : "Signer 1", ' + 
                  '"tabs" : { ' +
                      '"textTabs" : [ ' +
                             '{ ' +
                                 '"tabLabel" : "RegistrationNumber", ' +
                                 '"value" : "' + registrationNumber + '" ' +
                             '}, ' +
                             '{ ' + 
                                 '"tabLabel" : "CompanySigningSSA", ' +
                                 '"value" : "' +  companyName + '" ' +
                             '}, ' + 
                             '{ ' +
                                 '"tabLabel" : "AddressLine1", ' + 
                                 '"value" : "' + addressLine1 + '" ' +
                             '}, ' +
                             '{ ' +
                                 '"tabLabel" : "AddressLine2", ' +
                                 '"value" : "' + addressLine2 + '" ' +
                             '}, ' + 
                             '{ ' +
                                 '"tabLabel" : "AddressLine3", ' +
                                 '"value" : "' + addressLine3 + '" ' + 
                             ' } ' +         
                        ' ] ' +
                    ' } ' +                           
                '}, ' +
                    
                '{ ' +
                      '"email" : "' + secondContactEmail + '", ' +
                      '"name" : "' + secondContactFirstName + ' ' + secondContactLastName + '", ' + 
                      '"roleName" : "Signer 2" ' + 
                '}, ' + 
            
                '{ ' +
                      '"email" : "' +  UserInfo.getUserEmail() + '", ' + 
                      '"name" : "' + UserInfo.getUserName() + '", '  +
                      '"roleName" : "CC 1" ' +
                '} ' +            
                   
              '] ' +
           '}'; 

        Test.startTest();
        String generatedStr = OpaSsaUtils.generateSendSsaRequestBody( emailSubject,
                                                                      templateId,
                                                                      contactEmail,
                                                                      contactFirstName,
                                                                      contactLastName, 
                                                                      requireSecondSignature,
                                                                      secondContactEmail,
                                                                      secondContactFirstName,
                                                                      secondContactLastName,
                                                                      registrationNumber,
                                                                      companyName,
                                                                      addressLine1,
                                                                      addressLine2,
                                                                      addressLine3 );
        Test.stopTest();
        
        System.AssertEquals(expectedStr.replaceAll(' ',''), 
                            generatedStr.replaceAll('\n', '').replaceAll('\r','').replaceAll(' ', ''));
    }
    
    static testMethod void generateResendSsaSigner1RequestBodyTest() 
    {
          String contactEmail = 'alfred.kay@sage.com';
          String contactFirstName = 'Alfred';
          String contactLastName = 'Kay';
          String registrationNumber = '12345';
          String companyName = 'Sage';
          String addressLine1 = '7595 Irvine Center Drive'; 
          String addressLine2 = 'Suite 200';
          String addressLine3 = 'Irvine, CA 92618';          
          
          // Target: ResendSsa request body
          String expectedStr = 
           '{ '+ 
                  '"signers" : [ '+
                  '{ '+ 
                      '"email" : "' + contactEmail + '", ' + 
                      '"name" : "'  + contactFirstName + ' ' + contactLastName + '", ' + 
                      '"recipientId" : "1", ' + 
                      '"routingOrder" : "1", ' + 
                      '"tabs" : { ' + 
                      '"textTabs" : [ ' + 
                            '{ ' + 
                                 '"tabLabel" : "RegistrationNumber", ' + 
                                 '"value" : "' + registrationNumber + '" ' +
                            '}, ' +
                             '{ ' + 
                                 '"tabLabel" : "CompanySigningSSA", ' + 
                                 '"value" : "' + companyName + '" ' +
                             '}, ' +
                             '{ ' + 
                                 '"tabLabel" : "AddressLine1", ' + 
                                 '"value" : "' + addressLine1 + '" ' +
                             '}, ' + 
                             '{ ' + 
                                 '"tabLabel" : "AddressLine2", ' + 
                                 '"value" : "' + addressLine2 + '" ' +
                             '}, ' + 
                             '{ ' + 
                                 '"tabLabel" : "AddressLine3", ' + 
                                 '"value" : "' + addressLine3 + '" ' +
                             '} ' +          
                        '] ' + 
                  '} ' + 
              '} ' +      
            ']' + 
          '}';  

        Test.startTest();
        String generatedStr = OpaSsaUtils.generateResendSsaSigner1RequestBody( contactEmail,
                                                                               contactFirstName,
                                                                               contactLastName, 
                                                                               registrationNumber,
                                                                               companyName,
                                                                               addressLine1,
                                                                               addressLine2,
                                                                               addressLine3 );
        Test.stopTest();
        
        System.AssertEquals(expectedStr.replaceAll(' ',''), 
                            generatedStr.replaceAll('\n', '').replaceAll('\r','').replaceAll(' ', ''));
    }
    
    static testMethod void generateResendSsaSigner2RequestBodyTest() 
    {
          String secondContactEmail = 'tim.ho@sage.com';
          String secondContactFirstName = 'Tim';
          String secondContactLastName = 'Ho';         
           
          // Target: ResendSsa request body 
          String expectedStr  = 
          '{ '+ 
             '"signers" : [ '+ 
             '{ '+ 
                  '"email" : "' + secondContactEmail + '", ' + 
                  '"name" : "'  + secondContactFirstName + ' ' + secondContactLastName + '", ' + 
                  '"recipientId" : "2", '+ 
                  '"routingOrder" : "2" '+ 
                  '} '+      
                  ']'+ 
           '}'; 

        Test.startTest();
        String generatedStr = OpaSsaUtils.generateResendSsaSigner2RequestBody( secondContactEmail,
                                                                               secondContactFirstName,
                                                                               secondContactLastName );
        Test.stopTest();
        
        System.AssertEquals(expectedStr.replaceAll(' ',''), 
                            generatedStr.replaceAll('\n', '').replaceAll('\r','').replaceAll(' ', ''));
                            
    }    
    
    
    
    static testMethod void generateResendSsaRequestBodyTest() 
    {
          String contactEmail = 'alfred.kay@sage.com';
          String contactFirstName = 'Alfred';
          String contactLastName = 'Kay';
          String registrationNumber = '12345';
          String companyName = 'Sage';
          String addressLine1 = '7595 Irvine Center Drive'; 
          String addressLine2 = 'Suite 200';
          String addressLine3 = 'Irvine, CA 92618';  
          Boolean requireSecondSignature = true;
          String secondContactEmail = 'alfredkay@gmail.com';
          String secondContactFirstName = 'Alfred';
          String secondContactLastName = 'Kay';
          
          // Target: ResendSsa request body
          String expectedStr = 
           '{ '+ 
                  '"signers" : [ '+
                  '{ '+ 
                      '"email" : "' + contactEmail + '", ' + 
                      '"name" : "'  + contactFirstName + ' ' + contactLastName + '", ' + 
                      '"recipientId" : "1", ' + 
                      '"routingOrder" : "1", ' + 
                      '"tabs" : { ' + 
                      '"textTabs" : [ ' + 
                            '{ ' + 
                                 '"tabLabel" : "RegistrationNumber", ' + 
                                 '"value" : "' + registrationNumber + '" ' +
                            '}, ' +
                             '{ ' + 
                                 '"tabLabel" : "CompanySigningSSA", ' + 
                                 '"value" : "' + companyName + '" ' +
                             '}, ' +
                             '{ ' + 
                                 '"tabLabel" : "AddressLine1", ' + 
                                 '"value" : "' + addressLine1 + '" ' +
                             '}, ' + 
                             '{ ' + 
                                 '"tabLabel" : "AddressLine2", ' + 
                                 '"value" : "' + addressLine2 + '" ' +
                             '}, ' + 
                             '{ ' + 
                                 '"tabLabel" : "AddressLine3", ' + 
                                 '"value" : "' + addressLine3 + '" ' +
                             '} ' +          
                        '] ' + 
                  '} ' + 
              '}, ' +      
            '{'+
                  '"email": "' + SecondContactEmail + '",' + 
                  '"name": "'  + SecondContactFirstName + ' ' + secondContactLastName + '",' + 
                  '"recipientId": "2",'+
                  '"routingOrder": "2"'+
            '}'+
           ']' +
          '}';  

        Test.startTest();
        String generatedStr = OpaSsaUtils.generateResendSsaRequestBody( contactEmail,
                                                                        contactFirstName,
                                                                        contactLastName, 
                                                                        registrationNumber,
                                                                        companyName,
                                                                        addressLine1,
                                                                        addressLine2,
                                                                        addressLine3,
                                                                        requireSecondSignature,
                                                                        secondContactEmail,
                                                                        secondContactFirstName,
                                                                        secondContactLastName
                                                                       );
        Test.stopTest();

        System.AssertEquals(expectedStr.replaceAll(' ',''), 
                            generatedStr.replaceAll('\n', '').replaceAll('\r','').replaceAll(' ', ''));
    }
    
    
    static testMethod void generateVoidEnvelopeRequestBodyTest()                                                         
    {
        // Target: VoidEnvelope request body 
        String expectedStr  = 
        '{ '+ 
           '"status" : "' + OpaSsaStaticVariables.voided + '", ' + 
           '"voidedReason" : "'  + OpaSsaStaticVariables.voidReason + '"' + 
        '}'; 

        Test.startTest();
        String generatedStr = OpaSsaUtils.generateVoidEnvelopeRequestBody ( OpaSsaStaticVariables.voided, 
                                                                            OpaSsaStaticVariables.voidReason );                                                                                
        Test.stopTest();
        
        System.AssertEquals(expectedStr.replaceAll(' ',''), 
                            generatedStr.replaceAll('\n', '').replaceAll('\r','').replaceAll(' ', ''));
    }
    
    
    
    static testMethod void getProductListTest()
    {
        Map<String, String> productMap = new Map<String, String>();
        
        Test.startTest();
        productMap = OpaSsaUtils.getProductList(); 
        Test.stopTest();
        
        System.assertEquals('Enterprise Management', productMap.get('X3'));
        System.assertEquals('Enterprise Management HR', productMap.get('X3P'));
    }     
       
    
    static testMethod void generateEmailSubjectTest()
    {
        String emailSubjectForX3 = ''; 
        String emailSubjectForX3P = '';

        Test.startTest();
        emailSubjectForX3 = OpaSsaUtils.generateEmailSubject('X3');  
        emailSubjectForX3P = OpaSsaUtils.generateEmailSubject('X3P'); 
        Test.stopTest();

        System.assertEquals('Sage Business Cloud Enterprise Management Subscription Services Agreement', emailSubjectForX3);
        System.assertEquals('Sage Business Cloud Enterprise Management HR Subscription Services Agreement', emailSubjectForX3P);  
    }         
    
    
    static testMethod void generateResourceDetailsUrlTestGetTemplateId()
    {
        String type = 'getTemplateId';
        String searchText = '%X3-Canada%';
        List<String> parameterValues = new List<String>();
        parameterValues.add(searchText);    

        Test.startTest();
        String generatedUrl = OpaSsaUtils.generateResourceDetailsUrl(type, parameterValues); 
        Test.stopTest();
        
        System.AssertEquals('/templates?search_text=' + searchText, generatedUrl);
    }
    
    
    static testMethod void generateResourceDetailsUrlTestCreateAndSendEnvelope()
    {
        String type = 'createAndSendEnvelope';
        List<String> parameterValues = new List<String>();

        Test.startTest();
        String generatedUrl = OpaSsaUtils.generateResourceDetailsUrl(type, parameterValues); 
        Test.stopTest();
        
        System.AssertEquals('/envelopes/', generatedUrl);
    }    
    
    
    static testMethod void generateResourceDetailsUrlTestForResendSsa()
    {
        String type = 'resendSsa';
        String envelopeId = '14BD4EEC-4F5D-4196-A89A-A7CB3232C7C3';
        List<String> parameterValues = new List<String>();
        parameterValues.add(envelopeId);

        Test.startTest();
        String generatedUrl = OpaSsaUtils.generateResourceDetailsUrl(type, parameterValues); 
        Test.stopTest();
        
        System.AssertEquals('/envelopes/' +  envelopeId + '/recipients?advanced_update=true&resend_envelope=true', generatedUrl);
    }       

    
    
    static testMethod void generateResourceDetailsUrlTestForVoidEnvelope()
    {
        String type = 'voidEnvelope';
        String envelopeId = '14BD4EEC-4F5D-4196-A89A-A7CB3232C7C3';
        List<String> parameterValues = new List<String>();
        parameterValues.add(envelopeId);

        Test.startTest();
        String generatedUrl = OpaSsaUtils.generateResourceDetailsUrl(type, parameterValues); 
        Test.stopTest();
        
        System.AssertEquals('/envelopes/' + envelopeId, generatedUrl);
    }       

    
    
    static testMethod void generateResourceDetailsUrlTestForGetSignerCustomTags()
    {
        String type = 'getSignerCustomTags';
        String envelopeId = '14BD4EEC-4F5D-4196-A89A-A7CB3232C7C3';
        String recipientId = '1';
        
        List<String> parameterValues = new List<String>();
        parameterValues.add(envelopeId);
        parameterValues.add(recipientId);

        Test.startTest();
        String generatedUrl = OpaSsaUtils.generateResourceDetailsUrl(type, parameterValues); 
        Test.stopTest();
        
        System.AssertEquals('/envelopes/' + envelopeId + '/recipients/' + recipientId + '/tabs', generatedUrl);
    }           
    
    
    static testMethod void getRecipientStatusTest1Signer()
    {
        String ssaStatus = 'SSA Sent';    
        String envelopeStatus = 'Sent';
        String recipientStatus1 = 'Sent';
        String recipientStatus2 = '';
    
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c); 
        dsfs__DocuSign_Recipient_Status__c recipientStatus = OpaTestSsaDataFactory.getRecipientStatus(customersite.OpaEnvelopeId__c);

        Test.startTest();
        String dsRecipientStatus = OpaSsaUtils.getRecipientStatus(recipientStatus.dsfs__Envelope_Id__c, 1); 
        List<String> recipientStatuses = dsRecipientStatus.split(',', 2);
        
        for(integer i = 0; i < recipientStatuses.size()-1; i++)
        {
            System.assertEquals(true, OpaSsaStaticVariables.recipientStatuses.Contains(recipientStatuses[i]));
        }   
        Test.stopTest();
    }  
    
    
    static testMethod void getRecipientStatusTest2Signer()
    {
        String ssaStatus = 'SSA Partial'; 
        String envelopeStatus = 'Sent';
        String recipientStatus1 = 'Completed';
        String recipientStatus2 = 'Sent';
    
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, true); 
        dsfs__DocuSign_Recipient_Status__c recipientStatus = OpaTestSsaDataFactory.getRecipientStatus(customersite.OpaEnvelopeId__c);

        Test.startTest();
        String dsRecipientStatus = OpaSsaUtils.getRecipientStatus(recipientStatus.dsfs__Envelope_Id__c, 2); 
        List<String> recipientStatuses = dsRecipientStatus.split(',', 2);

        for(integer i = 0; i < recipientStatuses.size()-1; i++)
        {
            System.assertEquals(true, OpaSsaStaticVariables.recipientStatuses.Contains(recipientStatuses[i]));
        }   
        Test.stopTest();
    }    
    
}