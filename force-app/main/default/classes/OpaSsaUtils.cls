public with sharing class OpaSsaUtils 
{     
	  public class UncaughtException extends Exception {}
	  
    public static String getEndpoint(String baseUrl, String AccountId, String resourceDetails)
    {
      return (baseUrl + OpaSSAStaticVariables.docuSignApiPath + AccountId + resourceDetails);
    }
    
    
    public static String generateResourceDetailsUrl(String type, List<String> parameterValues)
    {
          String generateResourceDetailsUrl = '';
          
          if (type == 'getTemplateId')
          {
             generateResourceDetailsUrl = '/templates?search_text=' + parameterValues[0];
          }            
          if (type == 'createAndSendEnvelope')
          {
             generateResourceDetailsUrl = '/envelopes/';
          }    
          else if (type == 'resendSsa')
          {
             generateResourceDetailsUrl = '/envelopes/' + parameterValues[0] + '/recipients?advanced_update=true&resend_envelope=true';
          }      
          else if (type == 'voidEnvelope')
          {  
             generateResourceDetailsUrl = '/envelopes/' + parameterValues[0];
          }       
          else if (type == 'getSignerCustomTags')
          {
             generateResourceDetailsUrl = '/envelopes/' + parameterValues[0] + '/recipients/' + parameterValues[1] + '/tabs';
          }
          
          //System.Debug(LoggingLevel.DEBUG, 'generateResourceDetailsUrl ' + generateResourceDetailsUrl);
          return generateResourceDetailsUrl;
    }
    
    
    public static String generateEmailSubject(String product)
    {
          return ( 
                   OpaSsaStaticVariables.sageBusinessCloud + ' ' +
                   OpaSsaUtils.getProductList().get(product) + ' ' + 
                   OpaSsaStaticVariables.emailSubject
                );
    }
    
    
    public static Map<String, String> getProductList()
    {
         Schema.DescribeFieldResult fieldResult = OpaCustomerSite__c.OpaProduct__c.getDescribe();
         List<Schema.PicklistEntry> products = fieldResult.getPicklistValues();
         Map<String, String> productMap = new Map<String, String>();
           
         for(Schema.PicklistEntry product : products)
         {
             productMap.put(product.getValue(), product.getLabel());
         }   
        
         return productMap;
     }

    public static String generateSendSsaRequestBody( String emailSubject,
                                                     String templateId,
                                                     String contactEmail,
                                                     String contactFirstName,
                                                     String contactLastName, 
                                                     boolean requireSecondSignature,
                                                     String secondContactEmail,
                                                     String secondContactFirstName,
                                                     String secondContactLastName,
                                                     String registrationNumber,
                                                     String companyName,
                                                     String addressLine1,
                                                     String addressLine2,
                                                     String addressLine3 )
    {
    
      // Target: SendSsa request body 
      // '{'+
      //    '"emailSubject": "' + OpaSsaStaticVariables.emailSubject + '",'+
      //    '"status": "sent",'+
      //    '"templateId": "' + templateId + '",'+
      //    '"templateRoles": ['+
      //    '  {'+
      //        '"email": "' + customersite.OpaEmail__c + '",' + 
      //        '"name": "'  + customersite.OpaFirstName__c + ' ' + customersite.OpaLastName__c + '",' + 
      //        '"roleName": "Signer 1"'+ 
      
      //        '"routingOrder": "1",
      //        "tabs": {
      //            "textTabs": [
      //                   {
      //                       "tabLabel": "RegistrationNumber",
      //                       "value": customersite.OpaRegistrationNumber__c
      //                   },
      //                   {
      //                       "tabLabel": "CompanySigningSSA",
      //                       "value": customersite.OpaCompanyName__c
      //                   },
      //                   {
      //                       "tabLabel": "AddressLine1",
      //                       "value": customersite.OpaAddressLine1__c
      //                   },
      //                   {
      //                       "tabLabel": "AddressLine2",
      //                       "value": customersite.OpaAddressLine2__c
      //                   },
      //                   {
      //                       "tabLabel": "AddressLine3",
      //                       "value": customersite.OpaAddressLine3__c
      //                   }         
      //              ]
      //        },
      
        //{
        //  "email": "alfredkay@gmail.com",
        //  "name": "Alfred Kay",
        //  "roleName": "Signer 2"
        //},
        
        //{
        //  "email": "alfredkay@yahoo.com",
        //  "name": "Alfred Kay",
        //  "roleName": "CC 1"
        //  "routingOrder": "2",
        //}           
                                 
      //     ' }'+
      //     ']'+
      // '}'; 

      //Generator for SendSsa request body
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
          gen.writeStringField('emailSubject', emailSubject);
          gen.writeStringField('status', 'sent');
          gen.writeStringField('templateId', templateId);
          gen.writeFieldName('templateRoles');
              gen.writeStartArray();
              
                  //Signer 1
                  gen.writeStartObject();
                      gen.writeStringField('email', contactEmail);
                      gen.writeStringField('name', contactFirstName + ' ' + contactLastName);
                      gen.writeStringField('roleName', 'Signer 1');
                      gen.writeFieldName('tabs');
                          gen.writeStartObject();
                              gen.writeFieldName('textTabs');
                                  gen.writeStartArray();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'RegistrationNumber');
                                          gen.writeStringField('value', registrationNumber);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'CompanySigningSSA');
                                          gen.writeStringField('value', companyName);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine1');
                                          gen.writeStringField('value', addressLine1);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine2');
                                          gen.writeStringField('value', addressLine2);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine3');
                                          gen.writeStringField('value', addressLine3);
                                      gen.writeEndObject();
                                  gen.writeEndArray();
                          gen.writeEndObject(); 
                  gen.writeEndObject();
                  
                  //Signer 2
                  if (requireSecondSignature == true && String.IsNotEmpty(secondContactLastName))
                  {
                      gen.writeStartObject();
                      gen.writeStringField('email', secondContactEmail);
                      gen.writeStringField('name', secondContactFirstName + ' ' + secondContactLastName);
                      gen.writeStringField('roleName', 'Signer 2');
                      gen.writeEndObject();
                  }
                  
                  //Carbon copy 1 to Salesforce login user 
                  gen.writeStartObject();
                      gen.writeStringField('email', UserInfo.getUserEmail());
                      gen.writeStringField('name', UserInfo.getUserName());
                      gen.writeStringField('roleName', 'CC 1');
                  gen.writeEndObject();                  
                  
              gen.writeEndArray();
      gen.writeEndObject();

      String sendSsaStr = gen.getAsString();
      //System.debug(LoggingLevel.DEBUG, 'SendSsa Request body: ' + sendSsaStr);
      return sendSsaStr;
      
    }
  
                                                         
    public static String generateResendSsaSigner1RequestBody( String contactEmail,
                                                              String contactFirstName,
                                                              String contactLastName, 
                                                              String registrationNumber,
                                                              String companyName,
                                                              String addressLine1,
                                                              String addressLine2,
                                                              String addressLine3 )                                                       
    {
      // Target: ResendSsa request body 
      // '{'+
      //        '"signers": ['+
      //        '  {'+
      //            '"email": "' + customersite.OpaEmail__c + '",' + 
      //            '"name": "'  + customersite.OpaFirstName__c + ' ' + customersite.OpaLastName__c + '",' + 
      //            '"recipientId": "1"'+
      
      //        '"routingOrder": "1",
      //        "tabs": {
      //            "textTabs": [
      //                   {
      //                       "tabLabel": "RegistrationNumber",
      //                       "value": customersite.OpaRegistrationNumber__c
      //                   },
      //                   {
      //                       "tabLabel": "CompanySigningSSA",
      //                       "value": customersite.OpaCompanyName__c
      //                   },
      //                   {
      //                       "tabLabel": "AddressLine1",
      //                       "value": customersite.OpaAddressLine1__c
      //                   },
      //                   {
      //                       "tabLabel": "AddressLine2",
      //                       "value": customersite.OpaAddressLine2__c
      //                   },
      //                   {
      //                       "tabLabel": "AddressLine3",
      //                       "value": customersite.OpaAddressLine3__c
      //                   }         
      //              ]
      //        }, 
      //    ' },'+      
      //  ']'+
      //'}';  
      
      //Generator for ResendSsa request body
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
          gen.writeFieldName('signers');
              gen.writeStartArray();
                  gen.writeStartObject();
                      gen.writeStringField('email', contactEmail);
                      gen.writeStringField('name', contactFirstName + ' ' + contactLastName);
                      gen.writeStringField('recipientId', '1');                      
                      gen.writeStringField('routingOrder', '1');
                      gen.writeFieldName('tabs');
                          gen.writeStartObject();
                              gen.writeFieldName('textTabs');
                                  gen.writeStartArray();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'RegistrationNumber');
                                          gen.writeStringField('value', registrationNumber);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'CompanySigningSSA');
                                          gen.writeStringField('value', companyName);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine1');
                                          gen.writeStringField('value', addressLine1);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine2');
                                          gen.writeStringField('value', addressLine2);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine3');
                                          gen.writeStringField('value', addressLine3);
                                      gen.writeEndObject();
                                  gen.writeEndArray();
                          gen.writeEndObject();                       
                  gen.writeEndObject();                 
              gen.writeEndArray();
      gen.writeEndObject();

      String resendSsaStr = gen.getAsString();
      //System.debug(LoggingLevel.DEBUG, 'SendSsa Request body: ' + resendSsaStr);
      return resendSsaStr;
    }        
    
    
    public static String generateResendSsaSigner2RequestBody( String secondContactEmail,
                                                              String secondContactFirstName,
                                                              String secondContactLastName )                                                       
    {
      // Target: ResendSsa request body 
      // '{'+
      //        '"signers": ['+
      //        '  {'+
      //            '"email": "' + customersite.OpaSecondContactEmail__c + '",' + 
      //            '"name": "'  + customersite.OpaSecondContactFirstName__c + ' ' + customersite.OpaSecondContactLastName__c + '",' + 
      //            '"recipientId": "2"'+
      //            '"routingOrder": "2",+
      //         ' },'+      
      //        ']'+
      // '}';  
      
      //Generator for ResendSsa request body for Signer 2
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
          gen.writeFieldName('signers');
              gen.writeStartArray();
                  gen.writeStartObject();
                      gen.writeStringField('email', secondContactEmail);
                      gen.writeStringField('name', secondContactFirstName + ' ' + secondContactLastName);
                      gen.writeStringField('recipientId', '2');                      
                      gen.writeStringField('routingOrder', '2');
                  gen.writeEndObject();                  
              gen.writeEndArray();
      gen.writeEndObject();

      String resendSsaStr = gen.getAsString();
      //System.debug(LoggingLevel.DEBUG, 'SendSsa Request body: ' + resendSsaStr);
      return resendSsaStr;
    }                
        
        
    
    public static String generateResendSsaRequestBody( String contactEmail,
                                                       String contactFirstName,
                                                       String contactLastName, 
                                                       String registrationNumber,
                                                       String companyName,
                                                       String addressLine1,
                                                       String addressLine2,
                                                       String addressLine3,
                                                       Boolean requireSecondSignature,
                                                       String secondContactEmail,
                                                       String secondContactFirstName,
                                                       String secondContactLastName
                                                     )                                                       
    {
      //Generator for ResendSsa request body
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
          gen.writeFieldName('signers');
              gen.writeStartArray();
                  gen.writeStartObject();
                      gen.writeStringField('email', contactEmail);
                      gen.writeStringField('name', contactFirstName + ' ' + contactLastName);
                      gen.writeStringField('recipientId', '1');                      
                      gen.writeStringField('routingOrder', '1');
                      gen.writeFieldName('tabs');
                          gen.writeStartObject();
                              gen.writeFieldName('textTabs');
                                  gen.writeStartArray();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'RegistrationNumber');
                                          gen.writeStringField('value', registrationNumber);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'CompanySigningSSA');
                                          gen.writeStringField('value', companyName);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine1');
                                          gen.writeStringField('value', addressLine1);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine2');
                                          gen.writeStringField('value', addressLine2);
                                      gen.writeEndObject();
                                      gen.writeStartObject();
                                          gen.writeStringField('tabLabel', 'AddressLine3');
                                          gen.writeStringField('value', addressLine3);
                                      gen.writeEndObject();
                                  gen.writeEndArray();
                          gen.writeEndObject();
                  gen.writeEndObject(); 
            
                  if (requireSecondSignature == true && String.IsNotEmpty(secondContactEmail))
                  {
                      gen.writeStartObject();
                          gen.writeStringField('email', secondContactEmail);
                          gen.writeStringField('name', secondContactFirstName + ' ' + secondContactLastName);
                          gen.writeStringField('recipientId', '2');                      
                          gen.writeStringField('routingOrder', '2');
                      gen.writeEndObject();                               
                  } 
              
              gen.writeEndArray();
      gen.writeEndObject();

      String resendSsaStr = gen.getAsString();
      //System.debug(LoggingLevel.DEBUG, 'SendSsa Request body: ' + resendSsaStr);
      return resendSsaStr;
    }    
    
    public static String generateVoidEnvelopeRequestBody( String voidedStatus,
                                                          String voidedReason )                                                         
    {
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
            gen.writeStringField('status', voidedStatus);
            gen.writeStringField('voidedReason', voidedReason);
        gen.writeEndObject();
  
        return gen.getAsString();
    }                
            

    Public static String getRecipientStatus(String envelopeId, Integer numberOfSigners)
    {       
        List<String> recipientStatuses = new List<String>();
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientStatuses = [ SELECT Id, 
                                                                                name, 
                                                                                dsfs__Recipient_Status__c 
                                                                           FROM dsfs__DocuSign_Recipient_Status__c
                                                                          WHERE dsfs__Envelope_Id__c = :envelopeId 
                                                                            AND dsfs__DocuSign_Routing_Order__c <= :numberOfSigners 
                                                                       ORDER BY dsfs__DocuSign_Routing_Order__c ];  
                                                                       
        for ( dsfs__DocuSign_Recipient_Status__c dsRecipientStatus : dsRecipientStatuses ) 
        {                         
           recipientStatuses.add(dsRecipientStatus.dsfs__Recipient_Status__c);
        }  
        return String.join(recipientStatuses, ',');
    } 

}