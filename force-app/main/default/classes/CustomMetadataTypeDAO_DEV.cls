public class CustomMetadataTypeDAO_DEV implements ICustomMetadataTypeDAO{
        


  //// Mule Base URL that the other configs can reference and use via relative url
    public Callout_Configuration__mdt getMuleBaseEndpoint() {
      String developerName = 'DEV_Mule_Base_Endpoint';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }


    //// Mule Tax calculations
    //    /tax
    public Callout_Configuration__mdt getMuleToAvalaraTaxCalc() {
        String developerName = 'DEV_Mule_Tetris_Avalara_Tax_Calc';
        return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
                    FROM Callout_Configuration__mdt 
                        WHERE DeveloperName =: developerName LIMIT 1];
    }

    //// Mule Zuora operations
    //    /zuora/account
    public Callout_Configuration__mdt getMuleToZouraAccountCreate() {
        String developerName = 'DEV_Mule_Tetris_Zuora_Account_Create';
        return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
                    FROM Callout_Configuration__mdt 
                        WHERE DeveloperName =: developerName LIMIT 1];
    }

    //    /zuora/account
    public Callout_Configuration__mdt getMuleToZouraAccountUpdate() {
        String developerName = 'DEV_Mule_Tetris_Zuora_Account_Update';
        return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
                    FROM Callout_Configuration__mdt 
                        WHERE DeveloperName =: developerName LIMIT 1];
    }

    //    /zuora/contact
    public Callout_Configuration__mdt getMuleToZouraContactCreate() {
      String developerName = 'DEV_Mule_Tetris_Zuora_Contact_Create';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }

    //    /zuora/subscribe (old approach)
    public Callout_Configuration__mdt getMuleToZouraSubscribe() {
      String developerName = 'DEV_Mule_Tetris_Zuora_Subscribe_Create';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }

    //    /zuora/subscribe-integrate (new dynamic subscription call)
    public Callout_Configuration__mdt getMuleToZouraDynamicSubscribe() {
      String developerName = 'DEV_Mule_Tetris_Zuora_Dyn_Sub_Create';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }


    //// Mule Address Validation operations
    //    /address-autocompletion
    public Callout_Configuration__mdt getMuleToInformaticaAddressValidation() {
      String developerName = 'DEV_Mule_Tetris_Info360_Addr_Val';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }

    //// Mule Sage One email address check
    //    /validate-email
    public Callout_Configuration__mdt getMuleToSageOneEmailValidation() {
      String developerName = 'DEV_Mule_Tetris_Sage_One_Email_Val';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }


    //// Mule Product Provisioning
    //    /api/subscription
    public Callout_Configuration__mdt getMuleToProductProvisioning() {
      String developerName = 'DEV_Mule_Tetris_Product_Provision';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }




    //// Zuora Hosted Payment Page URLs
    // Callout_Configuration__mdt getZuoraSignatureEndpoint();
    public Callout_Configuration__mdt getZuoraSignatureEndpoint() {
      String developerName = 'DEV_Tetris_Zuora_Sig_Endpoint';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }
    //Callout_Configuration__mdt getZuoraHostedPaymentPage();
    public Callout_Configuration__mdt getZuoraHostedPaymentPage() {
      String developerName = 'DEV_Tetris_Zuora_Hosted_PP';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }


    //// Sage One Sign On URL
    //Callout_Configuration__mdt getSageOneSignOnUrl();
    public Callout_Configuration__mdt getSageOneSignOnUrl() {
      String developerName = 'DEV_Tetris_Sage_One_Sign_On';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }

    //// Tokenized Conversion URL (for conversion operation)
    //Callout_Configuration__mdt getTokenizedPaymentUrl();
    public Callout_Configuration__mdt getTokenizedPaymentUrl() {
      String developerName = 'DEV_Tetris_Tokenized_Convert';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, Timeout__c, Authorization__c, 
                Content_Type__c, Client_Id__c, Client_Secret__c, Disabled__c
            FROM Callout_Configuration__mdt 
            WHERE DeveloperName =: developerName LIMIT 1];
    }


    //// Google reCAPTCHA Settings
    //Callout_Configuration__mdt getGoogleReCAPTCHASettings();
    public Callout_Configuration__mdt getGoogleReCAPTCHASettings() {
      String developerName = 'DEV_Tetris_reCAPTCHA_Settings';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, 
                      Timeout__c, Authorization__c, Content_Type__c, Client_Id__c, 
                        Client_Secret__c, Disabled__c
              FROM Callout_Configuration__mdt 
              WHERE DeveloperName =: developerName LIMIT 1];
    }


    //// Sage One convert re-entry endpoints
    //2017-04-11
    //Callout_Configuration__mdt getSageOneConvertSuccessUrl();
    public Callout_Configuration__mdt getSageOneConvertSuccessUrl() {
      String developerName = 'DEV_Tetris_Sage_One_Success_Url';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, 
                      Timeout__c, Authorization__c, Content_Type__c, Client_Id__c, 
                        Client_Secret__c, Disabled__c
              FROM Callout_Configuration__mdt 
              WHERE DeveloperName =: developerName LIMIT 1];
    }
    
    //Callout_Configuration__mdt getSageOneConvertFailureUrl();
    public Callout_Configuration__mdt getSageOneConvertFailureUrl() {
      String developerName = 'DEV_Tetris_Sage_One_Failure_Url';
      return [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, 
                      Timeout__c, Authorization__c, Content_Type__c, Client_Id__c, 
                        Client_Secret__c, Disabled__c
              FROM Callout_Configuration__mdt 
              WHERE DeveloperName =: developerName LIMIT 1];
    }
    
    public List<Zuora_Payment_Page_Setting__mdt> getZuoraPaymentPageSettings() {
      String orgId = UserInfo.getOrganizationId();
      return [SELECT apiAccessID__c, apiAccessKey__c, ppApiSecurityKey__c,  ppDomain__c,
                ppPageID__c, ppPageRef__c, ppSignaturePath__c, ppTenantID__c, SFPageKey__c, SFDC_Org_Id__c 
                  FROM Zuora_Payment_Page_Setting__mdt 
                   WHERE SFDC_Org_Id__c =: orgId];
    }

    public Analytics_Configuration__mdt getTealiumSettings() {
      String developerName = 'DEV_Tetris_Tealium';
      return [SELECT Id__c, URL__c, Disabled__c
                FROM Analytics_Configuration__mdt 
                  WHERE DeveloperName =: developerName LIMIT 1];
    }
}