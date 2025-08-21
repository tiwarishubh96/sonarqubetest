@isTest
private class OpaTestProvisionCustomerSite
{ 
    static testMethod void TestValidCase()    
    {
        String companyName = 'TestSite01';
        OpaTestDataFactory.createSite(companyName);
        
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
        OpaCustomerSite__c site = [select 
                                       OpaCustomerSite__c.Name,
                                       OpaCustomerSite__c.Id,
                                       OpaCustomerSite__c.OpaCompanyName__c,
                                       OpaCustomerSite__c.OpaProvisioningStatus__c 
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
            OpaProvisionCustomerSite.provisionCustomerSite(site.Name);
        Test.stopTest();
        
        OpaCustomerSite__c siteFinal = [select 
                                            OpaCustomerSite__c.Name,
                                            OpaCustomerSite__c.Id,
                                            OpaCustomerSite__c.OpaCompanyName__c,
                                            OpaCustomerSite__c.OpaProvisioningStatus__c 
                                        from 
                                            OpaCustomerSite__c 
                                        where 
                                            OpaCustomerSite__c.OpaCompanyName__c = :companyName];
                                            
        System.assertEquals('In progress', siteFinal.OpaProvisioningStatus__c ); 
    }
    
    
    static testMethod void TestInvalidCase()    
    {
        String companyName = 'TestSite02';
        OpaTestDataFactory.createSite(companyName);
        
        OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
        OpaCustomerSite__c site = [select 
                                       OpaCustomerSite__c.Name,
                                       OpaCustomerSite__c.Id,
                                       OpaCustomerSite__c.OpaCompanyName__c,
                                       OpaCustomerSite__c.OpaProvisioningStatus__c 
                                   from 
                                       OpaCustomerSite__c 
                                   where 
                                       OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
            OpaProvisionCustomerSite.provisionCustomerSite(site.Name);
        Test.stopTest();
        
        OpaCustomerSite__c siteFinal = [select 
                                            OpaCustomerSite__c.Name,
                                            OpaCustomerSite__c.Id,
                                            OpaCustomerSite__c.OpaCompanyName__c,
                                            OpaCustomerSite__c.OpaProvisioningStatus__c,
                                            OpaCustomerSite__c.OpaProvisioningMessages__c 
                                        from 
                                            OpaCustomerSite__c 
                                        where 
                                            OpaCustomerSite__c.OpaCompanyName__c = :companyName];
                                            
        System.assertEquals('Callout failed', siteFinal.OpaProvisioningStatus__c ); 
        System.debug(LoggingLevel.DEBUG,'TestInvalidCase: provisionStatus(' + siteFinal.OpaProvisioningStatus__c + ') messages(' + siteFinal.OpaProvisioningMessages__c + ')');
        System.assertEquals(true, siteFinal.OpaProvisioningMessages__c.contains('some invalid case') ); 
        
    }
    
    
    static testMethod void TestInvalidCaseEndpointMissing()    
    {
        String companyName = 'TestSite01';
        OpaTestDataFactory.createSite(companyName);
        
        //OpaEndpointInfo__c endpoint = OpaTestDataFactory.createEndpoint('valid');
        
        OpaCustomerSite__c site = [select 
                                      OpaCustomerSite__c.Name,
                                      OpaCustomerSite__c.Id,
                                      OpaCustomerSite__c.OpaCompanyName__c,
                                      OpaCustomerSite__c.OpaProvisioningStatus__c 
                                  from 
                                      OpaCustomerSite__c 
                                  where 
                                      OpaCustomerSite__c.OpaCompanyName__c = :companyName];
        
        Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new OpaMockAuthenticatedCalloutResponse());
            OpaProvisionCustomerSite.provisionCustomerSite(site.Name);
        Test.stopTest();
        
        OpaCustomerSite__c siteFinal = [select 
                                            OpaCustomerSite__c.Name,
                                            OpaCustomerSite__c.Id,
                                            OpaCustomerSite__c.OpaCompanyName__c,
                                            OpaCustomerSite__c.OpaProvisioningStatus__c,
                                            OpaCustomerSite__c.OpaProvisioningMessages__c
                                        from 
                                            OpaCustomerSite__c 
                                        where 
                                            OpaCustomerSite__c.OpaCompanyName__c = :companyName];
                                            
        System.assertEquals('Callout failed', siteFinal.OpaProvisioningStatus__c ); 
        System.assertEquals(true, siteFinal.OpaProvisioningMessages__c.contains('no endpoint defined') ); 
    }
}