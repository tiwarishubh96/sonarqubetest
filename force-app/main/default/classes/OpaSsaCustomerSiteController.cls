public with sharing class OpaSsaCustomerSiteController
{   
    public OpaCustomerSite__c customersite;
    Apexpages.StandardController controller;

    Public string templateId  {get; set;} 
    Public string envelopeId  {get; set;}    

    Public string ssaStatus          {get; set;}  
    Public boolean resendSSAStatus   {get; set;}

    Public string requestBody        {get; set;}
    Public string responseString     {get; set;} 
    
    public String messages = ''; 

    public OpaSsaCustomerSiteController(ApexPages.StandardController stdController) 
    {  
        controller = stdController;

        //Create a list of required custom fields
        List<String> fieldNames = new List<String>();
        fieldNames.add('OpaCountry__c');
        fieldNames.add('OpaEmail__c');
        fieldNames.add('OpaFirstName__c');
        fieldNames.add('OpaLastName__c');
        fieldNames.add('OpaRequireSecondSignatureOnSSA__c');
        fieldNames.add('OpaSecondContactEmail__c');
        fieldNames.add('OpaSecondContactFirstName__c');
        fieldNames.add('OpaSecondContactLastName__c');        
        fieldNames.add('OpaSiteName__c');
        fieldNames.add('OpaEnvelopeId__c');
        fieldNames.add('OpaRegistrationNumber__c');
        fieldNames.add('OpaCompanyName__c');
        fieldNames.add('OpaAddressLine1__c');     
        fieldNames.add('OpaAddressLine2__c'); 
        fieldNames.add('OpaAddressLine3__c');    
        fieldNames.add('OpaSSAStatus__c');
        fieldNames.add('OpaSSAMessages__c');
        fieldNames.add('OpaDocuSignStatusLookup__c');
        fieldNames.add('OpaProduct__c');
        fieldNames.add('OpaProvisioningStatus__c');


        if (!Test.isRunningTest())
        {
           stdController.addFields(fieldNames);
        }
        this.customersite = (OpaCustomerSite__c)stdController.getRecord();
    } 
    
    
    public PageReference sendSSA() 
    {      
        try 
        {  
            //1. Send or Resend
            //a. Get template id, create and send a new envelope if no envelope Id yet
            if (String.IsEmpty(customersite.OpaEnvelopeId__c))   
            {   
                //1. Get template Id, if error or no template Id is return return to the page
                templateId = getTemplateId(customersite); 

                if (String.IsEmpty(templateId))
                {   
                    customersite.OpaSSAStatus__c = 'SSA Error';
                    customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageSsaTemplateSetupError;
                    update customersite;   
                                  
                    PageReference pf = new PageReference('/' + customersite.Id);   
                    pf.setRedirect(true);
                    return pf; 
                }
            
                //Parse DocuSign JSON response body, get envelopeId and status to update OpaCustomerSite__c object
                ssaStatus = createAndSendEnvelope(templateId, customersite); 

                //if (String.IsNotEmpty(envelopeId) && ssaStatus == 'sent') //status code = 201 - Created
                if (ssaStatus == 'sent') //status code = 201 - Created
                {
                   customersite.OpaEnvelopeId__c = envelopeId;
                   customersite.OpaSSAStatus__c = 'SSA Request in progress'; 
                   customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageSendSsaInProgress;    
                }  
            }
            
            //b. Envelope Id exists, company was changed, send a new envelope 
            //   Comment out per Laili/Sourena - OpaSsaUtils.checkIfNeedToVoid(customersite) &&
            else if ( customersite.OpaProvisioningStatus__c == 'Not started' &&
                    ( customersite.OpaSSAStatus__c == 'SSA Opened' || 
                      customersite.OpaSSAStatus__c == 'SSA Request in progress' ||
                      customersite.OpaSSAStatus__c == 'SSA Sent' ))
            {   
                boolean voidStatus = voidEnvelope(customersite.OpaEnvelopeId__c);
                
                if (voidStatus == true)
                {   
                    //Set default as - no template cause SSA Error
                    customersite.OpaSSAStatus__c = 'SSA Error';
                    customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageSsaTemplateSetupError; 
                    
                    templateId = getTemplateId(customersite);
                    if (String.IsNotEmpty(templateId))
                    {   
                        ssaStatus = createAndSendEnvelope(templateId, customersite);             
                        if (String.IsNotEmpty(envelopeId) && ssaStatus == 'sent') //status code = 201 - Created
                        {
                           customersite.OpaSSAStatus__c = 'SSA Request in progress';                           
                           customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageSendSsaInProgress; 
                        }
                    }
                    customersite.OpaEnvelopeId__c = envelopeId;
                    customersite.OpaDocuSignStatusLookup__c = null;                      
                }
            }          
            
            //c. Envelope Id exists and company was not changed. Give warning if one of the signer already signed.
            else if (customersite.OpaSSAStatus__c == 'SSA Signed' || 
                     customersite.OpaSSAStatus__c  == 'SSA Partial')
            {
                customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageAlreadyBeenSigned;
            } 
            
            //d. Envelope Id exists and SSA's fields were not changed. company, registration number, address line 1-3
            //Allow resend to incorrect recipient's email issue   
            else if (customersite.OpaSSAStatus__c.containsIgnoreCase('Email Auto Response') == true) //'Delivery Failure'           
            {   
                resendSsaStatus = resendSsa();  

                if (resendSsaStatus)
                {
                    customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageResent;
                }
            }  
        }
        catch (System.Exception e)
        {   
            customersite.OpaEnvelopeId__c = envelopeId == null ? '' : envelopeId;
            customersite.OpaSSAStatus__c = 'SSA Error';
            customersite.OpaSSAMessages__c = OpaSsaStaticVariables.messageSendSsaError;      
        }                
            
        update customersite;  
                      
        PageReference pf = new PageReference('/' + customersite.Id);   
        pf.setRedirect(true);
        return pf;        
    }    
    

    Public String getTemplateId(OpaCustomerSite__c customersite)
    {    
        //****************************************************************************************************************      
        // Step 1     : Callout to DocuSign to get template id base on country selected
        // REST API   : DocuSign Templates : list (callout class-method : OpaSsaAuthCallout.getTemplateId
        // URL        : GET /v2/accounts/{accountId}/templates?search_text=xxxxxx
        // Parameters : 
        // Notes      : Template folder name must match with country name in the picklist when setup DocuSign templates
        //              and should be encoded
        //****************************************************************************************************************
        String templateId = '';
        List<String> serviceMessages = new List<String>();
        
        List<String> parameterValues = new List<String>();
        parameterValues.add('%' 
                             + EncodingUtil.urlEncode(customersite.OpaProduct__c, 'UTF-8') 
                             + '-'
                             + EncodingUtil.urlEncode(customersite.OpaCountry__c, 'UTF-8') 
                             + '%'
                            );     
        
        responseString = OpaSsaAuthCallout.getTemplateId( OpaSsaUtils.generateResourceDetailsUrl('getTemplateId', parameterValues), serviceMessages );
        if (String.isNotEmpty(responseString) && responseString.contains('templateId'))
        {
            templateId = OpaSsaGetTemplateIdResponse.parseTemplateId(responseString); 
            System.Debug(LoggingLevel.DEBUG, '*** templateId: ' + templateId + ' ***');                       
        } 
        
        if (serviceMessages.size() > 0 )
        {
            messages = String.join(serviceMessages, '\n');
        }

        return templateId;
    }    
    
    
    Public String createAndSendEnvelope(String templateId, OpaCustomerSite__c customersite)
    {
        //*****************************************************************************************************************
        // Step 2a    : Callout to DocuSign to send SSA to customer
        // REST API   : DocuSign Envelopes: create (callout class-method : OpaSsaAuthCallout.createAndSendEnvelope)
        // URL        : POST /v2/accounts/{accountId}/envelopes
        // Parameters : accountId, templateId
        // Notes      : contentType = 'application/json' is needed to prevent 'error 415 - unsupported media type'
        //*****************************************************************************************************************

        List<String> serviceMessages = new List<String>();
        List<String> parameterValues = new List<String>();
        
        String emailSubject = OpaSsaUtils.generateEmailSubject(customersite.OpaProduct__c); 

        requestBody = OpaSsaUtils.generateSendSsaRequestBody( emailSubject,  
                                                              templateId,
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
                                                              customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c );            

        responseString = OpaSsaAuthCallout.createAndSendEnvelope (OpaSsaUtils.generateResourceDetailsUrl('createAndSendEnvelope', parameterValues),
                                                                  requestBody, 
                                                                  serviceMessages);
        if (String.IsNotEmpty(responseString)) //status code = 201 - Created
        {
            OpaSsaCreateAndSendEnvelopeResponse instance = OpaSsaCreateAndSendEnvelopeResponse.parse(responseString);
            envelopeId = instance.envelopeId.toUpperCase();
            ssaStatus = instance.status.capitalize();
            System.Debug(LoggingLevel.DEBUG, '*** envelopeId & status: ' + envelopeId + ' : ' + ssaStatus + ' ***');            
        }
        
        if (serviceMessages.size() > 0 )
        {
            messages = String.join(serviceMessages, '\n');
        }
        
        return ssaStatus;
        
    }   
    
   
    Public boolean resendSsa()
    {
        //*****************************************************************************************************************
        // Step 2b    : Callout to DocuSign to resend Envelope
        // REST API   : Envelopes: update (callout class-method: OpaSsaAuthCallout.updateEnvelope)
        // URL        : PUT /v2/accounts/{accountId}/envelopes/{envelopeId}?advanced_update=true&resend_envelope=true
        // Parameters : accountId, envelopeId
        // Notes      : contentType = 'application/json' is needed to prevent 'error 415 - unsupported media type'
        //*****************************************************************************************************************
        List<String> recipientStatuses;
        List<String> serviceMessages = new List<String>();
        Boolean resendStatus = false;
        
        if (customersite.OpaRequireSecondSignatureOnSSA__c == true && String.IsNotEmpty(customersite.OpaSecondContactEmail__c))
        {        
            recipientStatuses = OpaSsaUtils.getRecipientStatus(customersite.OpaEnvelopeId__c, 2).split(',', 2);
        }
        else
        {
            recipientStatuses = OpaSsaUtils.getRecipientStatus(customersite.OpaEnvelopeId__c, 1).split(',', 2);
        }

        if (recipientStatuses[0] == 'AutoResponded')
        {   
            resendStatus = resendSsaAutoResponded (OpaSsaStaticVariables.signerInfo.FIRST_SIGNER,  customersite);      
        } 
  
        //Check signer2's recipient state before send correction
        else if ( customersite.OpaRequireSecondSignatureOnSSA__c == true && 
                  String.IsNotEmpty(customersite.OpaSecondContactEmail__c) &&
                  recipientStatuses[1] == 'AutoResponded' )
        {   
            resendStatus = resendSsaAutoResponded ( OpaSsaStaticVariables.signerInfo.SECOND_SIGNER,  customersite ); 

        }  

        return resendStatus;
     }
     
  
     public boolean voidEnvelope(String envelopeId)
     {
            Boolean voidEnvelopeStatus = false;
            List<String> serviceMessages = new List<String>(); 
            
            List<String> parameterValues = new List<String>();
            parameterValues.add(envelopeId);    
            
            String requestBody = OpaSsaUtils.generateVoidEnvelopeRequestBody ( OpaSsaStaticVariables.voided, 
                                                                               OpaSsaStaticVariables.voidReason ); 
            
            String responseString = OpaSsaAuthCallout.updateEnvelope( OpaSsaUtils.generateResourceDetailsUrl('voidEnvelope', parameterValues), 
                                                                      requestBody, 
                                                                      serviceMessages);

            if (String.IsNotEmpty(responseString) && responseString.contains('envelopeId'))
            {
                voidEnvelopeStatus = true;
            }  
            if (serviceMessages.size() > 0 )
            {
                messages = String.join(serviceMessages, '\n');
            }            
            
            return voidEnvelopeStatus; 
     }     
     
     

     public boolean resendSsaAutoResponded(OpaSsaStaticVariables.signerInfo signer, OpaCustomerSite__c customersite) 
     {
            Boolean resendStatus = false;
            List<String> serviceMessages = new List<String>(); 
            
            List<String> parameterValues = new List<String>();
            parameterValues.add(customersite.OpaEnvelopeId__c); 
       
            if (signer == OpaSsaStaticVariables.signerInfo.FIRST_SIGNER)
            {
                requestBody = OpaSsaUtils.generateResendSsaSigner1RequestBody (  
                                                                                 customersite.OpaEmail__c, 
                                                                                 customersite.OpaFirstName__c, 
                                                                                 customersite.OpaLastName__c, 
                                                                                 customersite.OpaRegistrationNumber__c,
                                                                                 customersite.OpaCompanyName__c,
                                                                                 customersite.OpaAddressLine1__c,
                                                                                 customersite.OpaAddressLine2__c == null ? '' : customersite.OpaAddressLine2__c,                  
                                                                                 customersite.OpaAddressLine3__c == null ? '' : customersite.OpaAddressLine3__c
                                                                              ); 
            }
            else if (signer == OpaSsaStaticVariables.signerInfo.SECOND_SIGNER)
            {
                requestBody = OpaSsaUtils.generateResendSsaSigner2RequestBody ( 
                                                                              customersite.OpaSecondContactEmail__c, 
                                                                              customersite.OpaSecondContactFirstName__c, 
                                                                              customersite.OpaSecondContactLastName__c 
                                                                             );    
            }                                                                         
            responseString = OpaSsaAuthCallout.updateEnvelope( OpaSsaUtils.generateResourceDetailsUrl('resendSsa', parameterValues), 
                                                               requestBody, 
                                                               serviceMessages);
                                                               
            if (String.IsNotEmpty(responseString))
            {
                resendStatus = true;
            }
            if (serviceMessages.size() > 0 )
            {
                messages = String.join(serviceMessages, '\n');
            }

            return resendStatus;
     }
     
}