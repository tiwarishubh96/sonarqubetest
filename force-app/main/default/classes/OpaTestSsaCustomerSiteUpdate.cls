@isTest
public class OpaTestSsaCustomerSiteUpdate
{
    static testMethod void processRecipientStatusUpdateTest1Signer()
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
        OpaSsaCustomerSiteUpdate.processDocuSignRecipientStatusUpdate(recipientStatus);
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( 'SSA Sent', updatedsite.OpaSsaStatus__c);
        System.assertEquals( OpaSsaStaticVariables.messageWaitingForCustomerSignature, updatedsite.OpaSsaMessages__c );         
    }   
    
    
    static testMethod void processRecipientStatusUpdateTest2Singers()
    {
        String ssaStatus = 'SSA Sent';
        String envelopeStatus = 'Sent';
        String recipientStatus1 = 'Completed';
        String recipientStatus2 = 'Sent';
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);
        dsfs__DocuSign_Recipient_Status__c recipientStatus = OpaTestSsaDataFactory.getRecipientStatus(customersite.OpaEnvelopeId__c);

        Test.startTest(); 
            OpaSsaCustomerSiteUpdate.processDocuSignRecipientStatusUpdate(recipientStatus);
        Test.stopTest();    

        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( 'SSA Partial', updatedsite.OpaSsaStatus__c);
        System.assertEquals( OpaSsaStaticVariables.messageCompletedAndSent, updatedsite.OpaSsaMessages__c ); 
    }   
    
    
    static testMethod void processSentStatusUpdateTest()
    {
        String ssaStatus = 'SSA Sent';
        String envelopeStatus = 'Sent';
        String recipientStatus1 = 'Sent';
        String recipientStatus2 = '';
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);
        dsfs__DocuSign_Status__c status = OpaTestSsaDataFactory.getStatus(customersite.OpaEnvelopeId__c);
        
        Test.startTest();
            OpaSsaCustomerSiteUpdate.processDocuSignStatusUpdate(status);
        Test.stopTest();    
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( 'SSA Sent', updatedsite.OpaSSAStatus__c );
        System.assertEquals( OpaSsaStaticVariables.messageWaitingForCustomerSignature, updatedsite.OpaSsaMessages__c );
        System.assertEquals(true, String.IsNotEmpty(updatedsite.OpaDocuSignStatusLookup__c));         
    }  

    
    static testMethod void processVoidStatusUpdateTest()
    {
        String ssaStatus = 'SSA Voided';    
        String envelopeStatus = 'Voided';
        String recipientStatus1 = 'Sent';
        String recipientStatus2 = '';
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('3', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);
        dsfs__DocuSign_Status__c status = OpaTestSsaDataFactory.getStatus(customersite.OpaEnvelopeId__c);
        
        Test.startTest();
        OpaSsaCustomerSiteUpdate.processDocuSignStatusUpdate(status);
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);
        System.assertEquals( 'SSA Voided', updatedsite.OpaSSAStatus__c );
        System.assertEquals( OpaSsaStaticVariables.messageVoided, updatedsite.OpaSsaMessages__c );        
    }  
        
    
    static testMethod void processCompletedStatusUpdateTest()
    {
        String ssaStatus = 'SSA Signed';
        String envelopeStatus = 'Completed';
        String recipientStatus1 = 'Completed';
        String recipientStatus2 = 'Completed';

        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);
        dsfs__DocuSign_Status__c status = OpaTestSsaDataFactory.getStatus(customersite.OpaEnvelopeId__c);
        
        Test.startTest();
        System.enqueueJob(new OpaSsaCustomerSiteUpdate(customersite));
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetSignerCustomTagsResponse());
        Test.stopTest();
        
        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);       
        System.assertEquals('SSA Signed', updatedsite.OpaSSAStatus__c);
    } 
    
    
    static testMethod void processCompletedStatusUpdateTestMoreThan250()
    {
        String ssaStatus = 'SSA Signed';
        String envelopeStatus = 'Completed';
        String recipientStatus1 = 'Completed';
        String recipientStatus2 = 'Completed';
        
        OpaCustomerSite__c customersite = OpaTestSsaDataFactory.createCustomerSite('4', ssaStatus);
        OpaTestSsaDataFactory.createDocuSignConfiguration();
        OpaTestSsaDataFactory.createDocuSignStatusRecords(customersite.OpaEnvelopeId__c, envelopeStatus, recipientStatus1, recipientStatus2, customersite.OpaRequireSecondSignatureOnSSA__c);
        dsfs__DocuSign_Status__c status = OpaTestSsaDataFactory.getStatus(customersite.OpaEnvelopeId__c);
        
        List<String> serviceMessages = new List<String>();
        String endPointParameters = 'message_gt_250';
        String responseString = OpaSsaAuthCallout.getSignerCustomTags( endPointParameters, serviceMessages );        
        
        Test.startTest();
        System.enqueueJob(new OpaSsaCustomerSiteUpdate(customersite));
        Test.setMock(HttpCalloutMock.class, new OpaMockSsaGetSignerCustomTagsResponse());
        Test.stopTest();

        OpaCustomerSite__c updatedsite = OpaTestSsaDataFactory.getUpdatedSite(customersite.OpaEnvelopeId__c);       
        System.assertEquals(true, updatedsite.OpaSSAMessages__c.contains('...'));         
    }           
 
}