public class OpaSsaCustomerSiteUpdate implements Queueable, Database.AllowsCallouts
{
    private OpaCustomerSite__c customersite; 
    private String messages = '';
    public static String processedEnvelopeId = '';
    
    public OpaSsaCustomerSiteUpdate(OpaCustomerSite__c customersite)
    {     
        this.customersite = customersite;
    }      
   
    public void execute(QueueableContext context) 
    {   
        if(String.IsNotEmpty(customersite.OpaEnvelopeId__c))
        {
            // Description: Callout to DocuSign to get signer's custom tags. Invoke from dsfs_DocuSign_Status__c trigger after update event.
            // REST API   : DocuSign's EnvelopeTabs: list ( class-method : OpaSsaAuthCallout.getSignerCustomTags)
            // URL        : GET /v2/accounts/{accountId}/envelopes/{envelopeId}/recipients/{recipientId}/tabs
            // Parameters : accountId, envelopeId, recipientId
            // Notes      : Use textTabs to retrieve Registration Number, SignerTitle, SignerName, Company, Address Lines

            List<String> serviceMessages = new List<String>();
            
            //signer 1 callout
            doCalloutAndHandleSigner(new List<String>{ customersite.OpaEnvelopeId__c, '1' }, OpaSsaStaticVariables.signerInfo.FIRST_SIGNER, serviceMessages);
            
            //signer 2 callout
            if (String.IsNotEmpty(customersite.OpaSecondContactEmail__c) && customersite.OpaRequireSecondSignatureOnSSA__c == true)
            {   
                doCalloutAndHandleSigner(new List<String>{ customersite.OpaEnvelopeId__c, '2' }, OpaSsaStaticVariables.signerInfo.SECOND_SIGNER, serviceMessages);
            }         

            if (serviceMessages.size() > 0)
            {
                String finalMessage = String.join(serviceMessages, '\n');
                if (finalMessage.length() > 250)
                {
                    finalMessage = finalMessage.substring(0,246) + '...';
                }
                customersite.OpaSSAMessages__c = finalMessage;
            }

            update customersite;            
        }            
    }     
    
    public void doCalloutAndHandleSigner(List<String> parameterValues, OpaSsaStaticVariables.signerInfo signer, List<String> serviceMessages)
    {
        Map<String, String> signerTagsMap = new Map<String, String>();
        
        String responseString = OpaSsaAuthCallout.getSignerCustomTags(OpaSsaUtils.generateResourceDetailsUrl('getSignerCustomTags', parameterValues), serviceMessages);
        if (String.isNotEmpty(responseString))
        {   
            if (signer == OpaSsaStaticVariables.signerInfo.FIRST_SIGNER)
            {
                signerTagsMap = OpaSsaGetSignerCustomTagsResponse.parseSigner1CustomTags(responseString);
                customersite.OpaSignerName__c              = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[0]);
                customersite.OpaSignerTitle__c             = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[1]);               
                customersite.OpaCompanySigningSSA__c       = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[2]);  
                customersite.OpaRegistrationNumberOnSSA__c = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[3]);
                customersite.OpaAddressLine1OnSSA__c       = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[4]);
                customersite.OpaAddressLine2OnSSA__c       = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[5]);  
                customersite.OpaAddressLine3OnSSA__c       = signerTagsMap.get(OpaSsaStaticVariables.firstSignerTags[6]);
                customersite.OpaDateAndTimeSigned__c       = System.Now();     
                customersite.OpaSSAStatus__c               = 'SSA Signed';
                customersite.OpaSSAMessages__c             =  OpaSsaStaticVariables.messageSignedByCustomer;    
                customersite.OpaProvisioningStatus__c      = 'Ready';                
            }
            else if(signer == OpaSsaStaticVariables.signerInfo.SECOND_SIGNER)
            {
                signerTagsMap = OpaSsaGetSignerCustomTagsResponse.parseSigner2CustomTags(responseString);
                customersite.OpaSecondSigner__c = signerTagsMap.get(OpaSsaStaticVariables.secondSignerTags[0]);
                customersite.OpaSecondSignerTitle__c = signerTagsMap.get(OpaSsaStaticVariables.secondSignerTags[1]);    
            }            
        }  
    }
    

    Public static void processDocuSignStatusUpdate(dsfs__DocuSign_Status__c status)
    {   
        List<OpaCustomerSite__c> sites = [ SELECT Id, 
                                                  OpaEnvelopeId__c, 
                                                  OpaDocuSignStatusLookup__c,
                                                  OpaSecondContactEmail__c,
                                                  OpaRequireSecondSignatureOnSSA__c 
                                             FROM OpaCustomerSite__c
                                            WHERE OpaEnvelopeId__c = :status.dsfs__DocuSign_Envelope_ID__c ];   
                                                                                  
        for(OpaCustomerSite__c site : sites) 
        {             
            if (status.dsfs__Envelope_Status__c == 'Sent') 
            {          
                site.OpaDocuSignStatusLookup__c = status.Id;
                site.OpaSSAStatus__c = 'SSA Sent';
                site.OpaSSAMessages__c = OpaSsaStaticVariables.messageWaitingForCustomerSignature;
                update site;
            }
            else if (status.dsfs__Envelope_Status__c == 'Voided') 
            {          
                site.OpaSSAStatus__c = 'SSA Voided';
                site.OpaSSAMessages__c = OpaSsaStaticVariables.messageVoided;
                update site;
            }
            else if (status.dsfs__Envelope_Status__c == 'Completed')
            {
                System.enqueueJob(new OpaSsaCustomerSiteUpdate(site));
            }              
         }  
    }     
    
    Public static void processDocuSignRecipientStatusUpdate(dsfs__DocuSign_Recipient_Status__c status)
    {   
        Integer numberOfSigners = 1;        
        List<OpaCustomerSite__c> sites = [ SELECT Id, 
                                                  OpaSSAStatus__c, 
                                                  OpaSSAMessages__c,
                                                  OpaRequireSecondSignatureOnSSA__c,
                                                  OpaSecondContactEmail__c
                                             FROM OpaCustomerSite__c
                                            WHERE OpaEnvelopeId__c = :status.dsfs__Envelope_Id__c ];  
        
        processedEnvelopeId = status.dsfs__Envelope_Id__c;                                         
                                    
        for(OpaCustomerSite__c site : sites) 
        {            
            if (site.OpaRequireSecondSignatureOnSSA__c == true && String.IsNotEmpty(site.OpaSecondContactEmail__c))
            {   
                numberOfSigners = 2;
            }
            
            String dsRecipientStatus = OpaSsaUtils.getRecipientStatus(status.dsfs__Envelope_Id__c, numberOfSigners);
            
            site.OpaSSAStatus__c = OpaSsaStaticVariables.dsStatusToSsaStatus.get(dsRecipientStatus);      
            site.OpaSSAMessages__c = OpaSsaStaticVariables.dsStatusToMessages.get(dsRecipientStatus);

            update site;             
         }  
         
    }     
  
}