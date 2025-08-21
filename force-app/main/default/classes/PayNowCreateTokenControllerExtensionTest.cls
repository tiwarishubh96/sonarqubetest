@isTest

public class PayNowCreateTokenControllerExtensionTest {
    
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class  
    
    @IsTest(SeeAllData=true) static  void runTestSuccess(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PayNowMockHttpResponseGeneratorTest());   
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        //TestDataUtility.createHostedPageLiteSetting(zuoraId);
      
        ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
        PayNowCreateTokenControllerExtension controller = new PayNowCreateTokenControllerExtension(sc);
        //String pageId = controller.pageId; // adding code coverage for getter method
     
        System.debug('PayNowCreateTokenControllerExtensionTest: about to run Test.setMock ');   
     
        System.debug('PayNowCreateTokenControllerExtensionTest: after to run Test.setMock ');   
        
             
        controller.isInConsole = false;        
        controller.createPayNowToken();
     
        controller.hasPdfAttachments = true;
        controller.isInConsole = true;
        controller.createPayNowToken();
        
        controller.checkHasValidPaymentMethod('United States', 'US', 'Credit Card');
        controller.checkHasValidPaymentMethod('Ireland', 'IE', 'ACH');
        controller.checkHasValidPaymentMethod('United Kingdom', 'GB', 'ACH');
        controller.checkHasValidPaymentMethod('United States', 'US', 'Bank Transfer');
        
        controller.hasValidPaymentMethod = true;
    }
    
     @IsTest(SeeAllData=true) static  void  runTestpayNowCreateTokenControllerExtension()
     {
          Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PayNowMockHttpResponseGeneratorTest());  
         Account acc = TestDataUtility.createAccount();
       Contact con = TestDataUtility.createContact(acc.Id);
       zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
       zqu__Quote__c quote;
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp', CloseDate=System.today(), StageName='Qualify', Lead_Source__c='Marketing');
        insert opp;
      
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'Credit Card','CBC');
        //Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId); 
        //insert bAccount;
          Zuora__CustomerAccount__c bAccount = createBillingAccount(acc.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
       PayNowCreateTokenControllerExtension controller = new PayNowCreateTokenControllerExtension(sc);
        String quoteId ; 
         String opportunityId ;
         List<zqu__Quote__c> listQuote;
         List<Attachment> listOfAttachments;
         boolean hasValidPaymentMethod;
         boolean quoteHasReceivedPaymentMethod;
         
         quote = (zqu__Quote__c)sc.getRecord();
         quoteId=quote.id;
         system.assertEquals(quoteid, zquote.id);
        
        listQuote = [SELECT ID, Name, zqu__PaymentMethod__c, Zuora_Country_Code__c, zqu__Number__c, zqu__Status__c, zqu__InitialTerm__c, zqu__RenewalTerm__c, zqu__ValidUntil__c, zqu__BillToContact__c, zqu__Previewed_Total__c, zqu__Opportunity__c FROM zqu__Quote__c WHERE ID = :quoteId];
        System.debug('listQuote' + listQuote);
        opportunityId = opp.id;
        
        listOfAttachments = [select Id, Name, Body, ContentType, CreatedDate from attachment where name like '%pdf' and ParentId =: opportunityId order by CreatedDate desc];
        
        Contact billingContact = [select id, MailingCountry, MailingCountryCode from Contact where Id IN
               (select zqu__BillToContact__c from zqu__Quote__c where id =: quoteId)];
         String MailingCountry=billingContact.MailingCountry;
         String MailingCountryCode=billingContact.MailingCountryCode;
         String paymentMethod=listQuote[0].zqu__PaymentMethod__c;
         System.assertEquals('United States', MailingCountry);
          System.assertEquals('US', MailingCountryCode);
          system.assertEquals('Credit Card', paymentMethod);
        
       hasValidPaymentMethod = controller.checkHasValidPaymentMethod(MailingCountry, MailingCountryCode, paymentMethod);
        system.assertEquals(true,hasValidPaymentMethod);
         PayNowToken__c a = new PayNowToken__c(name= 'purchaseToken', PayNowRedirectUrl__c = 'http:\\pay.sage.com\token', Quote__c = quoteId, Status__c ='Payment Provided');
        insert a;
        List<PayNowToken__c> currentTokens = [Select Id, name, PayNowRedirectUrl__c, Status__c, Quote_Payment_Method_ID__c From PayNowToken__c Where Quote__c =: quoteId Order By SystemModStamp Desc];

        system.debug('currentTokens' + currentTokens);
        system.assertEquals(currentTokens[0].name, a.name);
        System.debug('currentTokens.isEmpty()='+currentTokens.isEmpty());
         
 
        
        if(currentTokens.isEmpty()){
            quoteHasReceivedPaymentMethod = false;
            System.debug('quoteHasReceivedPaymentMethod='+quoteHasReceivedPaymentMethod);
            return;
        }
        
        string paymentMethodId = currentTokens.get(0).Quote_Payment_Method_ID__c;
        System.debug('paymentMethodId='+paymentMethodId);
        system.assertEquals(a.Quote_Payment_Method_ID__c, currentTokens.get(0).Quote_Payment_Method_ID__c);
        
        quoteHasReceivedPaymentMethod = String.isNotBlank(paymentMethodId);
        System.debug('quoteHasReceivedPaymentMethod='+quoteHasReceivedPaymentMethod);
         
     }
    
    /**
     * [createAccount creates new account in SFDC]
     * @return [new SFDC account]
     */
	private static Zuora__CustomerAccount__c createBillingAccount(Id accountId){      
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
        ca.Zuora__Zuora_Id__c = '2c92c0f94e001371014e02a0b2e749d6';
        ca.Zuora__Account__c = accountId; 
        insert ca;       
        System.debug('billingAccount Id created:'+ca.Id);
        return ca;
	}
    
    
}