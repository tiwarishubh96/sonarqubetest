/**
 * @description  Zuora Contact Sync Test Class
 * @author Bob Lin
 * @date July 2019
 */
@IsTest
public class ZuoraSyncContactDetails_Test {
  private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class  
  @IsTest static void testVatUpdates()
  { 
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    User u = new User(Alias = 'lbandaru', Email='devtestemail@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='devtestemail=sage.com@test.com');
    insert u;
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sync_to_Zuora_Account_and_Contact'];
	insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
    System.runAs(u) {
    ZuoraSyncContactDetails.checkZuoraSync('0031X000008oJaaQAE');
    Locale__c loc = TestDataUtility.createLocale('US - United States', 'yes', 'en_us', 'english');
	Account acc = TestDataUtility.createAccount(loc.Id);
	Zuora__CustomerAccount__c ca = TestDataUtility.createBillingAccountAndPaymentMethod(acc,zuoraId);

    Contact cont = TestDataUtility.createContact(acc.id);
    cont.Sync_to_Zuora_Bill_to__c = false;
    cont.Sync_to_Zuora_Sold_to__c = false;
    update cont;
	ZuoraSyncContactDetails.checkZuoraSync(cont.id);
    cont.Sync_to_Zuora_Bill_to__c = true;
    cont.Sync_to_Zuora_Sold_to__c = true;
    update cont;
    ZuoraSyncContactDetails.checkZuoraSync(cont.id); 
    ca.Zuora__BillToId__c = zuoraId;
    ca.Zuora__SoldToId__c = zuoraId;
    update ca;
    ZuoraSyncContactDetails.checkZuoraSync(cont.id); 
	// Call Test.startTest before performing callout,but after setting test data.
    Test.startTest();        
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new ZuoraMockHttpResponseGenerator());        
    //Build the Http Request
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://apisandbox-api.zuora.com/rest/v1/connections');
    req.setMethod('GET');
    Http h = new Http();        
    // Call method to test. This causes a fake response to be sent from the class that implements HttpCalloutMock. 
    HttpResponse res = h.send(req);
    // Verify response received contains fake values
    String contentType = res.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = res.getBody();
    /*** {"Id":"2c92c0f84dfff49f014e021c79b82bb6",
    //	  "VAT_Number__c":"FR-123456", 
    //	  "TaxExemptCertificateID":"FR-123456", 
    //	   "TaxExemptStatus":"YES"} ***/       	   
    //System.debug('Actual Value' +actualValue);
    //String expectedValue = '{"VAT_Number__c":"FR-123456"}';
    //System.assertEquals(actualValue, expectedValue);
    System.assertEquals(200, res.getStatusCode());
    Test.stopTest();
    }
  }
}