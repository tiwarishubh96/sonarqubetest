@isTest
private class OpaTestSsaCustomerSiteController
{
    public static OpaCustomerSite__c customersite;
   
    static testMethod void sendSsaTest()
    {       
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('1', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());
        ctrl.sendSSA(); 
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( true, String.IsNotEmpty(updatedsite.OpaEnvelopeId__c) );
        System.assertEquals( 'SSA Request in progress', updatedsite.OpaSSAStatus__c );
        System.assertEquals( OpaSsaStaticVariables.messageSendSsaInProgress, updatedsite.OpaSsaMessages__c );        
    }  
    
    
    static testMethod void sendSsaTestVoidCreateAndSend()
    {       
        String ssaStatus = 'SSA Sent';
        String envelopeStatus = 'Voided';
        String recipientStatus1 = 'Sent';
        String recipientStatus2 = '';        

        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaVoidEnvelopeResponse());  
        ctrl.sendSSA(); 
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( true, String.IsNotEmpty(updatedsite.OpaEnvelopeId__c) );
        System.assertEquals( 'SSA Request in progress', updatedsite.OpaSSAStatus__c );
        System.assertEquals( OpaSsaStaticVariables.messageSendSsaInProgress, updatedsite.OpaSsaMessages__c );        
    }  
    
    
    static testMethod void sendSsaTestVoidCreateAndSendCatchError()
    {       
        String ssaStatus = 'SSA Sent';
        String envelopeStatus = 'Voided';
        String recipientStatus1 = 'Sent';
        String recipientStatus2 = '';        

        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaVoidEnvelopeResponse());  
        ctrl.sendSSA(); 
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( true, String.IsEmpty(updatedsite.OpaEnvelopeId__c) );
        System.assertEquals( 'SSA Error', updatedsite.OpaSSAStatus__c );
    }   
    
    
    // static testMethod void sendSsaTestVoidCreateAndSendInvalidTemplateError()
    // {       
    //     String ssaStatus = 'SSA Sent';
    //     String envelopeStatus = 'Voided';
    //     String recipientStatus1 = 'Sent';
    //     String recipientStatus2 = '';        

    //     OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);

    //     Test.startTest();
    //     ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
    //     OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
    //     String endPointParameters = 'invalid_templateId'; 
    //     Test.setMock(HttpCalloutMock.class, new OpaMockSsaVoidEnvelopeResponse());
    //     ctrl.sendSSA(); 
    //     Test.stopTest();
        
    //     OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
    //     System.assertEquals( true, String.IsEmpty(updatedsite.OpaEnvelopeId__c) );
    //     System.assertEquals( 'SSA Error', updatedsite.OpaSSAStatus__c );
    // }      
                
    
    static testMethod void sendSsaTestInvalidTemplateId()
    {       
        String ssaStatus = '';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('1', ssaStatus);

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());
        String endPointParameters = 'invalid_templateId';        
        ctrl.sendSSA();
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( 'SSA Error', updatedsite.OpaSSAStatus__c );
        System.assertEquals( OpaSsaStaticVariables.messageSsaTemplateSetupError, updatedsite.OpaSsaMessages__c );        
    }    
    

    static testMethod void sendSsaTestSSAStatusIsEmailAutoResponse()
    {       
        String ssaStatus = 'Email Auto Response (first recipient)';
        String envelopeStatus  = 'Sent';
        String recipientStatus1 = 'AutoResponded';
        String recipientStatus2 = '';

        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, false);        

        Test.startTest();      
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse());
        ctrl.sendSSA();
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( 'Email Auto Response (first recipient)', updatedsite.OpaSSAStatus__c );
        System.assertEquals( OpaSsaStaticVariables.messageResent, updatedsite.OpaSsaMessages__c ); 
    }   


    static testMethod void sendSsaTestSSAStatusIsSigned()
    {       
        String ssaStatus = 'SSA Signed';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        
        Test.startTest();      
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        ctrl.sendSSA();
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);                                    
        System.assertEquals( OpaSsaStaticVariables.messageAlreadyBeenSigned, updatedsite.OpaSsaMessages__c );
    }      
    
    
    static testMethod void sendSsaTestSSAStatusIsPartial()
    {       
        String ssaStatus = 'SSA Partial';
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);

        Test.startTest();   
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        ctrl.sendSSA();
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( OpaSsaStaticVariables.messageAlreadyBeenSigned, updatedsite.OpaSsaMessages__c );
    }      
    
    
    static testMethod void getTemplateIdTest()
    {
        String ssaStatus = '';
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('1', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();          

        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetTemplateIdResponse());
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController);
        String templateId = ctrl.getTemplateId(customersite);
        Test.stopTest();
        System.AssertEquals(true, String.IsNotEmpty(templateId));
    }


    static testMethod void resendSsaAutoRespondedTestFirstSigner() 
    {
        String ssaStatus = 'Email Auto Response (first recipient)';
        String envelopeStatus  = 'Sent';
        String recipientStatus1 = 'AutoResponded';
        String recipientStatus2 = 'Created';
        Boolean resendSsaStatus;
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse());   
        Apexpages.StandardController sc = new Apexpages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(sc);        
        resendSsaStatus = ctrl.resendSsa();
        Test.stopTest();
        
        System.Assert(true, resendSsaStatus);        
    }       
    
    
    static testMethod void resendSsaAutoRespondedTestSecondSigner() 
    {
        String ssaStatus = 'SSA Partial. Email Auto Response (second recipient)';
        String envelopeStatus  = 'Sent';
        String recipientStatus1 = 'Completed';
        String recipientStatus2 = 'AutoResponded';
        Boolean resendSsaStatus;
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse());   
        Apexpages.StandardController sc = new Apexpages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(sc);        
        resendSsaStatus = ctrl.resendSsa();
        Test.stopTest();
        
        System.Assert(true, resendSsaStatus);            
    }       
            

    static testMethod void resendSsaSigner1AutoRespondedTest() 
    {
        String ssaStatus = 'Email Auto Response';
        String envelopeStatus  = 'Sent';
        String recipientStatus1 = 'AutoResponded';
        String recipientStatus2 = '';
        Boolean resendSsaStatus;
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse());   
        Apexpages.StandardController sc = new Apexpages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(sc);        
        resendSsaStatus = ctrl.resendSsaAutoResponded (OpaSsaStaticVariables.signerInfo.FIRST_SIGNER,  customersite);
        Test.stopTest();
        
        System.Assert(true, resendSsaStatus);
    }       
    
    
    static testMethod void resendSSASigner2AutoRespondedTest() 
    {
        String ssaStatus = '';
        String envelopeStatus  = 'Sent';
        String recipientStatus1 = 'Completed';
        String recipientStatus2 = 'AutoResponded';
        Boolean resendSsaStatus;
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaUpdateEnvelopeResponse());   
        Apexpages.StandardController sc = new Apexpages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(sc);        
        resendSsaStatus = ctrl.resendSsaAutoResponded (OpaSsaStaticVariables.signerInfo.SECOND_SIGNER,  customersite);
        Test.stopTest();
        
        System.Assert(true, resendSSAStatus);        
    }       
    
    
    static testMethod void voidEnvelopeTestVoidSuccessful()
    {
        String ssaStatus = 'SSA Sent';
        Boolean voidEnvelopeStatus;
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(customersite);
        OpaSsaCustomerSiteController ctrl = new OpaSsaCustomerSiteController(stdController); 
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaVoidEnvelopeResponse());
        voidEnvelopeStatus = ctrl.voidEnvelope(customersite.OpaEnvelopeId__c);
        Test.stopTest();
        
        System.assertEquals(true, voidEnvelopeStatus); 
    }    

}