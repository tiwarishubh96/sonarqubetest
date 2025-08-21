@IsTest
public class ZuoraUpdateVatNumberTriggerHandlerTest {
private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class
    
    public static testMethod void testVatUpdates()
    {
        Locale__C loc = TestDataUtility.createLocale('US - United States', 'yes', 'en_us', 'english');
		Account acc = TestDataUtility.createAccount(loc.id);
		Zuora__CustomerAccount__c ca= TestDataUtility.createBillingAccountAndPaymentMethod(acc,zuoraId);
        acc.VAT_Number__c='US-123456';
        update acc;
        
		// Call Test.startTest before performing callout
        // but after setting test data.
        Test.startTest();        
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ZuoraMockHttpResponseGenerator());
        
        //Build the Http Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apisandbox-api.zuora.com/rest/v1/connections');
        req.setMethod('GET');
        Http h = new Http();
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
       HttpResponse res = h.send(req);
            // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        /*** {"Id":"2c92c0f84dfff49f014e021c79b82bb6",
        //	  "VAT_Number__c":"FR-123456", 
        //	  "TaxExemptCertificateID":"FR-123456", 
        //	   "TaxExemptStatus":"YES"} ***/
       	   
        System.debug('Actual Value' +actualValue);
        String expectedValue = '{"VAT_Number__c":"FR-123456"}';
        //System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest(); 
        
        
		

    }

}