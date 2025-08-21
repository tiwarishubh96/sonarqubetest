public class OpaProvisionCustomerSite 
{
    @Future(callout=true) public static void provisionCustomerSite(String customerSiteId) 
    {
        OpaCustomerSite__c site = [select 
                                        OpaCustomerSite__c.Name,
                                        OpaCustomerSite__c.OpaProvisioningStatus__c,
                                        OpaCustomerSite__c.OpaCompanyName__c,
                                        OpaCustomerSite__c.OpaFirstName__c,
                                        OpaCustomerSite__c.OpaLastName__c,
                                        OpaCustomerSite__c.OpaEmail__c,
                                        OpaCustomerSite__c.OpaCountry__c,
                                        OpaCustomerSite__c.OpaSiteDescription__c,
                                        OpaCustomerSite__c.OpaSiteName__c,
                                        OpaCustomerSite__c.OpaProduct__c,
                                        OpaCustomerSite__c.OpaProvisioningSiteType__c,
                                        OpaCustomerSite__c.OpaProvisioningPowerFactor__c, 
                                        OpaCustomerSite__c.OpaProvisioningEnvironmentType__c                                       
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.Name = :customerSiteId];
        
        System.debug(LoggingLevel.DEBUG, 'Site info before callout: ' + site);
        
        String customerSiteCountry = site.OpaCountry__c;
        String customerSiteEnvironmentType = site.OpaProvisioningEnvironmentType__c;                                     
        
        System.debug(LoggingLevel.DEBUG, 'OpaCountry(' + site.OpaCountry__c + ') and OpaProvisioningEnvironmentType(' + site.OpaProvisioningEnvironmentType__c + ')');
        
        List<OpaEndpointInfo__c> endpoints = [select 
                                        OpaEndpointInfo__c.OpaCertificateName__c,
                                        OpaEndpointInfo__c.OpaClientId__c,
                                        OpaEndpointInfo__c.OpaConsumerKey__c,
                                        OpaEndpointInfo__c.OpaCountry__c,
                                        OpaEndpointInfo__c.OpaEndpointHost__c,
                                        OpaEndpointInfo__c.OpaEndpointWebServiceName__c,
                                        OpaEndpointInfo__c.OpaEndpointWebServicePath__c,
                                        OpaEndpointInfo__c.OpaEnvironmentType__c,
                                        OpaEndpointInfo__c.OpaHttpMethod__c,
                                        OpaEndpointInfo__c.OpaSearchIndexLocales__c,
                                        OpaEndpointInfo__c.OpaTenantLocale__c,
                                        OpaEndpointInfo__c.OpaTestMode__c,
                                        OpaEndpointInfo__c.OpaTokenExpiration__c,
                                        OpaEndpointInfo__c.OpaTokenPath__c,
                                        OpaEndpointInfo__c.OpaTokenSubject__c                                   
                                  from 
                                      OpaEndpointInfo__c 
                                  where 
                                      ((OpaEndpointInfo__c.OpaCountry__c = :customerSiteCountry) AND (OpaEndpointInfo__c.OpaEnvironmentType__c = :customerSiteEnvironmentType))];


        System.debug(LoggingLevel.DEBUG, 'Mindo Provisioning Request for Country(' + site.OpaCountry__c + ') and Environment(' + site.OpaProvisioningEnvironmentType__c + ')');
            
        if(endpoints.isEmpty())
        {
            OpaMindoResponse response = new OpaMindoResponse();
            response.success = false;
            response.message = 'There is no endpoint defined for the selected Country(' + site.OpaCountry__c + ') and Environment(' + site.OpaProvisioningEnvironmentType__c + ') in the Provisioner List';
            updateCustomerSite(customerSiteId, response);
        }
        else    
        {
            OpaMindoResponse response = submitProvisioningRequest(site, endpoints[0]); //there should be only one matching endpoint
            updateCustomerSite(customerSiteId, response);
        }
    }
    
    public static void updateCustomerSite(string customerSiteId, OpaMindoResponse response) 
    {
        OpaCustomerSite__c site = [select 
                                    OpaCustomerSite__c.Name,
                                    OpaCustomerSite__c.OpaProvisioningStatus__c,
                                    OpaCustomerSite__c.OpaProvisioningTenantId__c,
                                    OpaCustomerSite__c.OpaProvisioningConfigurationId__c,
                                    OpaCustomerSite__c.OpaCustomerSiteUrl__c,
                                    OpaCustomerSite__c.OpaProvisioningMessages__c
                                  from 
                                    OpaCustomerSite__c 
                                  where 
                                    OpaCustomerSite__c.Name = :customerSiteId];
                                            
        
        //System.debug(LoggingLevel.DEBUG, 'Site info after callout: ' + site);
        
        if(response.success)
        {
            site.OpaProvisioningStatus__c = 'In progress';
            site.OpaProvisioningTenantId__c = response.tenantId;
            site.OpaProvisioningConfigurationId__c = response.configurationId;
            site.OpaCustomerSiteUrl__c = response.configurationUrl;  
        }
        else
        {
            site.OpaProvisioningStatus__c = 'Callout failed';
            site.OpaProvisioningTenantId__c = '';
            site.OpaProvisioningConfigurationId__c = '';
            site.OpaCustomerSiteUrl__c = ''; 
        }
        site.OpaProvisioningMessages__c = response.message;
        update site;
    }
  
    public static OpaMindoResponse submitProvisioningRequest(OpaCustomerSite__c site, OpaEndpointInfo__c endpoint)  
    {
        // Boolean validationFailed = false;
        // String validationMessage = '';
        
        // //validate endpoint fields used to create the request body
        // if(endpoint.OpaTenantLocale__c.length() != 5) 
        // {
        //     validationFailed = true;
        //     validationMessage = ' Invalid  ';
        // }
        
        // if(validationFailed)
        // {
        //     OpaMindoResponse response = new OpaMindoResponse();
        //     response.success = false;
        //     String result = 'Invalid Request Field Value(s)';
        //     System.debug(LoggingLevel.DEBUG, result);
        //     messages.add(result);
        //     return response;
        // }
        
        String body = generateMindoRequestBody(site.OpaCompanyName__c, site.OpaLastName__c, site.OpaFirstName__c, site.OpaEmail__c, endpoint.OpaTenantLocale__c,
                                                endpoint.OpaSearchIndexLocales__c, site.OpaSiteDescription__c, site.OpaSiteName__c, site.OpaProvisioningSiteType__c,
                                                site.OpaProduct__c, site.OpaProvisioningPowerFactor__c, endpoint.OpaTestMode__c, site.Name); 

        return OpaAuthenticatedCallout.makeProvisioningCall(endpoint, body);
    }

    public static String generateMindoRequestBody(String tenantName,   String contactLastName, String contactFirstName,   
                                                  String contactEmail, String contactLocale,   String searchIndexLocales, 
                                                  String configurationName, String configurationShortName, String configurationType,  
                                                  String productName, Decimal powerSize, boolean dryRun, String siteId) 
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('tenant');
                gen.writeStartObject(); //tenant
                  gen.writeStringField('name', tenantName);
                  gen.writeFieldName('contact');
                        gen.writeStartObject(); //contact
                            gen.writeStringField('lastName', contactLastName);
                            gen.writeStringField('firstName', contactFirstName);
                            gen.writeStringField('email', contactEmail);
                            gen.writeStringField('locale', contactLocale);
                        gen.writeEndObject(); //contact
                      
                  gen.writeFieldName('searchIndexlocales');
                        gen.writeStartArray(); //searchIndexLocales
                            for(String locale : searchIndexLocales.split(','))
                            {
                                gen.writeString(locale.trim());
                            }
                        gen.writeEndArray(); //searchIndexLocales
                gen.writeEndObject(); //tenant
                
                gen.writeStringField('configName', configurationName);
                gen.writeStringField('configShortName', configurationShortName);
                gen.writeStringField('configType', configurationType.toLowerCase().replace('production','prod'));
                gen.writeStringField('productName', productName);
                gen.writeNumberField('powerSize', powerSize);
                gen.writeStringField('configDeployedCallbackUrl', generateCallbackUrl(siteId));
                
                gen.writeFieldName('licesne');
                    gen.writeStartObject(); //licesne
                    //EMPTY FOR NOW UNTIL NEXT PHASE OF OPA
                    gen.writeEndObject(); //licesne
                
                gen.writeFieldName('options');
                    gen.writeStartObject(); //options
                        gen.writeBooleanField('dryRun', dryRun);
                        gen.writeFieldName('sei');
                            gen.writeStartObject(); //sei
                                gen.writeBooleanField('enabled', false);
                            gen.writeEndObject(); //sei
                    gen.writeEndObject(); //options
                
        gen.writeEndObject();
         
        String customerStr = gen.getAsString();
        System.debug(LoggingLevel.DEBUG, 'Mindo Request body: ' + customerStr);
        return customerStr;
  }
  
  public static String generateCallbackUrl(String siteId)
  {
      return OpaStaticVariables.salesforceBaseURL + OpaStaticVariables.opaRestEndpointPath + '?siteId=' + siteId + '&provisioningSuccessful=$result';
  }
  
}