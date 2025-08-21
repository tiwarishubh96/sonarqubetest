@isTest
public class OpaTestDataFactory
{ 
    public static OpaEndpointInfo__c createEndpoint(String type) 
    {
        OpaEndpointInfo__c endpoint = new OpaEndpointInfo__c();
        
        if(type.equals('valid'))
        {
            endpoint.OpaClientId__c = '15176e5e3dbc41a398c3ec6893058367';
            endpoint.OpaConsumerKey__c = 'nGIjoJx7SWle5jM03PWdd8iTOkUuW80p';
            endpoint.OpaCountry__c = 'United States';
            endpoint.OpaEndpointHost__c = 'https://cloudmanager.dev-sagex3.com';
            endpoint.OpaEndpointWebServicePath__c = '/api1/syracuse/collaboration/syracuse/proxies/$service/';
            endpoint.OpaEndpointWebServiceName__c = 'provisionConfigurationV1';
            endpoint.OpaEnvironmentType__c = 'Dev';
            endpoint.OpaHttpMethod__c = 'POST';
            endpoint.OpaSearchIndexLocales__c = 'en-US';
            endpoint.OpaTenantLocale__c = 'en-US';
            endpoint.OpaTestMode__c = true;
            endpoint.OpaTokenExpiration__c = 120;
            endpoint.OpaTokenSubject__c = 'opa';
        }
        else 
        {
            endpoint.OpaClientId__c = '15176e5e3dbc41a398c3ec6893058367';
            endpoint.OpaConsumerKey__c = 'nGIjoJx7SWle5jM03PWdd8iTOkUuW80p';
            endpoint.OpaCountry__c = 'United States';
            endpoint.OpaEndpointHost__c = 'https://cloudmanager.dev-sagex3.com';
            endpoint.OpaEndpointWebServicePath__c = '/api1/syracuse/collaboration/syracuse/proxies/$service/';
            endpoint.OpaEndpointWebServiceName__c = 'provisionConfigurationV2';
            endpoint.OpaEnvironmentType__c = 'dev';
            endpoint.OpaHttpMethod__c = 'POST';
            endpoint.OpaSearchIndexLocales__c = 'en-US';
            endpoint.OpaTenantLocale__c = 'en-US';
            endpoint.OpaTestMode__c = true;
            endpoint.OpaTokenExpiration__c = 120;
            endpoint.OpaTokenSubject__c = 'opa';
        }

        insert endpoint;
        return endpoint;
    }
    
    public static void createSite(String companyName) 
    {
        OpaCustomerSite__c site = new OpaCustomerSite__c();

        site.OpaCompanyName__c = companyName;
        site.OpaRegistrationNumber__c = '16531685';
        site.OpaCountry__c = 'United States';
        site.OpaContractOrderDate__c = System.Today();
        site.OpaProduct__c = 'X3';
        site.OpaSiteName__c = 'main';
        site.OpaSiteDescription__c = 'main site housing all products';
        site.OpaFirstName__c = 'John';
        site.OpaLastName__c = 'Wu';
        site.OpaEmail__c = 'john.wu@jwu.com';
        site.OpaPhone__c = '331-223-5567';
        site.OpaAddressLine1__c = '112 Main St';
        site.OpaAdminFirstName__c = 'jane';
        site.OpaAdminLastName__c = 'doe';
        site.OpaAdminEmail__c = 'jane.doe@jwu.com';
        site.OpaProvisioningEnvironmentType__c = 'Dev';
        site.OpaProvisioningStatus__c = 'Not started';
        site.OpaLSMEmail__c = 'liveservicemanagement-x3@sage.com';

        insert site;
    }
}