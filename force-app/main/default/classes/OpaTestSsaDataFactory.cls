@isTest
public class OpaTestSsaDataFactory
{
    public static void createDocuSignConfiguration() 
    {
        dsfs__DocuSignAccountConfiguration__c accConfig = new dsfs__DocuSignAccountConfiguration__c();

        accConfig.dsfs__AccountId__c = '3e8613e2-a223-4a7a-8758-cb9ba70177e7';
        accConfig.dsfs__DocuSignBaseURL__c = 'https://demo.docusign.net/';
        accConfig.dsfs__DocuSignEnvironment__c = 'demo';
        accConfig.dsfs__DSProSFPassword__c = 'TestPass';
        accConfig.dsfs__DSProSFUsername__c = 'Test Lucky';

        insert accConfig;
    }

    
    public static void createDocuSignStatusRecords(String envelopeId, String envelopeStatus, String recipientStatus1, String recipientStatus2, boolean requireSecondSignature) 
    {    
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();

        status.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        status.dsfs__Envelope_Status__c = envelopeStatus ;    //Sent, Delivered, Completed, Voided, AutoResponded
        status.dsfs__Sender_Email__c = 'alfred.kay@sage.com';
        status.dsfs__Sender__c = 'Alfred Kay';

        insert status;

        dsfs__DocuSign_Recipient_Status__c recipientStatus = new dsfs__DocuSign_Recipient_Status__c();

        recipientStatus.dsfs__Envelope_Id__c = envelopeId;
        recipientStatus.dsfs__Recipient_Status__c = recipientStatus1;
        recipientStatus.dsfs__DocuSign_Recipient_Email__c = 'alfred.kay@sage.com';
        recipientStatus.dsfs__DocuSign_Recipient_Id__c = 'EEABA059-D95D-4DAE-8639-A0CEF961B491';
        recipientStatus.dsfs__DocuSign_Recipient_Title__c = 'C.F.O';
        recipientStatus.dsfs__DocuSign_Routing_Order__c = 1;
        recipientStatus.dsfs__Parent_Status_Record__c = status.Id;

        insert recipientStatus;         
        
        if (requireSecondSignature == true)
        {
            recipientStatus = new dsfs__DocuSign_Recipient_Status__c();
    
            recipientStatus.dsfs__Envelope_Id__c = envelopeId;
            recipientStatus.dsfs__Recipient_Status__c = recipientStatus2;
            recipientStatus.dsfs__DocuSign_Recipient_Email__c = 'alfredkay@gmail.com';
            recipientStatus.dsfs__DocuSign_Recipient_Id__c = 'EEABA059-D95D-4DAE-8639-A0CEF961B492';
            recipientStatus.dsfs__DocuSign_Recipient_Title__c = 'C.E.O';
            recipientStatus.dsfs__DocuSign_Routing_Order__c = 2;
            recipientStatus.dsfs__Parent_Status_Record__c = status.Id;
            
            insert recipientStatus;        
        }        
    }
    
    
    public static OpaCustomerSite__c createCustomerSite(String type, String ssaStatus )   
    {
            OpaCustomerSite__c customersite = new OpaCustomerSite__c();
          
            customersite.OpaRegistrationNumber__c = 'RN-12345';
            customersite.OpaCompanyName__c = 'ssatestsite';
            customersite.OpaCountry__c = 'United States';
            customersite.OpaContractOrderDate__c = System.Today();
            customersite.OpaProduct__c = 'X3';
            customersite.OpaSiteName__c = 'ssatestsite';
            customersite.OpaSiteDescription__c = 'ssatestsite';   
            customersite.OpaProvisioningSiteType__c = 'Production';
            customersite.OpaFirstName__c = 'alfred';
            customersite.OpaLastName__c = 'kay';
            customersite.OpaEmail__c = 'alfred.kay@sage.com';
            customersite.OpaPhone__c = '(949) 790-2088';
            customersite.OpaAddressLine1__c = '7595 Irvine Center Drive';
            customersite.OpaAddressLine2__c = 'Suite 200';
            customersite.OpaAddressLine3__c = 'Irvine, CA 92618';
            customersite.OpaAdminFirstName__c = 'alfred';
            customersite.OpaAdminLastName__c = 'kay';
            customersite.OpaAdminEmail__c    = 'alfred.kay@sage.com';
            customersite.OpaSecondContactFirstName__c = 'alfred';
            customersite.OpaSecondContactLastName__c = 'kay';
            customersite.OpaSecondContactEmail__c = 'alfredkay@gmail.com';
            customersite.OpaSignerName__c = '';
            customersite.OpaSignerTitle__c = '';
            customersite.OpaAddressLine1OnSSA__c = '';
            customersite.OpaAddressLine2OnSSA__c = '';
            customersite.OpaAddressLine3OnSSA__c = '';                                                              
            customersite.OpaCompanySigningSSA__c = '';
            customersite.OpaProvisioningStatus__c = 'Not started';
            customersite.OpaSSAStatus__c = ssaStatus;
            customersite.OpaSSAMessages__c = '';   
          
            if (type == '1') //one signer without envelopeId
            {
                customersite.OpaRequireSecondSignatureOnSSA__c = false;
                customersite.OpaEnvelopeId__c = '';
            }
            else if (type == '2' ) //2 signers without envelopeId
            {
                customersite.OpaRequireSecondSignatureOnSSA__c = true;
                customersite.OpaEnvelopeId__c = '';
            }
            else if (type == '3' ) //one signer with envelopeId
            {
                customersite.OpaRequireSecondSignatureOnSSA__c = false;
                customersite.OpaEnvelopeId__c = '14BD4EEC-4F5D-4196-A89A-A7CB3232C7C4';
            }          
            else if (type == '4' ) //2 signers with envelopeId
            {
                customersite.OpaRequireSecondSignatureOnSSA__c = true;
                customersite.OpaEnvelopeId__c = '14BD4EEC-4F5D-4196-A89A-A7CB3232C7C4';
            }
            else //one signer without envelopeId
            {
                customersite.OpaRequireSecondSignatureOnSSA__c = false;
                customersite.OpaEnvelopeId__c = '';  
            }

            insert customersite; 
            return customersite;
    }
    

    public static dsfs__DocuSignAccountConfiguration__c getAccountConfiguration()
    {
        dsfs__DocuSignAccountConfiguration__c accConfig = [ SELECT dsfs__AccountId__c, 
                                                                   dsfs__DocuSignBaseURL__c,
                                                                   dsfs__DocuSignEnvironment__c
                                                              FROM dsfs__DocuSignAccountConfiguration__c
                                                             LIMIT 1 ];    
    
        return accConfig;
    }


    public static OpaCustomerSite__c getUpdatedSite(String envelopeId)  
    {
        OpaCustomerSite__c updatedsite = [ SELECT Id,
                                                  OpaEnvelopeId__c,
                                                  OpaDocuSignStatusLookup__c,
                                                  OpaSSAStatus__c, 
                                                  OpaSSAMessages__c
                                             FROM OpaCustomerSite__c 
                                            WHERE OpaEnvelopeId__c = :envelopeId ];  
                                            
        return updatedsite;                                            
    }

    
    public static dsfs__DocuSign_Status__c getStatus(String envelopeId)  
    {
        dsfs__DocuSign_Status__c status = [ SELECT Id, 
                                                   dsfs__Envelope_Status__c,
                                                   dsfs__DocuSign_Envelope_ID__c
                                              FROM dsfs__DocuSign_Status__c 
                                             WHERE dsfs__DocuSign_Envelope_ID__c = :envelopeId ];
                                             
        return status;                                             
    }

    
    public static dsfs__DocuSign_Recipient_Status__c getRecipientStatus(String envelopeId) 
    {
        dsfs__DocuSign_Recipient_Status__c recipientStatus = [ SELECT Id, 
                                                                      dsfs__Envelope_Id__c,
                                                                      dsfs__Recipient_Status__c
                                                                 FROM dsfs__DocuSign_Recipient_Status__c 
                                                                WHERE dsfs__Envelope_Id__c = :envelopeId LIMIT 1]; 
                                                                
        return recipientStatus;                                                                
    }
    
}