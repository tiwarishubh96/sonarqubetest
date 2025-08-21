@isTest
global class CreatePaymentMethodController_Test {

    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   

    public static testMethod void runTestSuccess(){
     Account acc = TestDataUtility.createAccount();
     Contact con = TestDataUtility.createContact(acc.Id);
     zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
     TestDataUtility.createHostedPageLiteSetting(zuoraId);
      
     ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
     CreatePaymentMethodController controller = new CreatePaymentMethodController(sc);
     System.assertEquals(controller.displayPage, true);
    }
    
    public static testMethod void runErrorTestNoPaymentPages(){
     Account acc = TestDataUtility.createAccount();
     Contact con = TestDataUtility.createContact(acc.Id);
     zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
           
     ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
     CreatePaymentMethodController controller = new CreatePaymentMethodController(sc);
     String pageId = controller.pageId; // adding code coverage for getter method
     System.assertEquals(controller.displayPage, false);
    }
    
    public static testMethod void runErrorTestMultiplePaymentPages(){
     Account acc = TestDataUtility.createAccount();
     Contact con = TestDataUtility.createContact(acc.Id);
     zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
     TestDataUtility.createHostedPageLiteSetting(zuoraId);
     TestDataUtility.createHostedPageLiteSetting('2c92c0f84dfff49f014e021c79b82bb7'); // Different Zuora Id to avoid DML constraint error
           
     ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
     CreatePaymentMethodController controller = new CreatePaymentMethodController(sc);
     String pageId = controller.pageId; // adding code coverage for getter method
     System.assertEquals(controller.displayPage, false);
    }
    
     public static testMethod void runErrorTestMissingGatewayName(){
     Account acc = TestDataUtility.createAccount();
     Contact con = TestDataUtility.createContact(acc.Id);
     zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
          
     // Insert a Payment Page with no Gateway Name
     zqu__HostedPageLiteSetting__c pSetting = new zqu__HostedPageLiteSetting__c();
     pSetting.Name = 'CBC US Credit Card Test Data';
     pSetting.zqu__ComponentName__c = 'PaymentPage';
     pSetting.zqu__PageId__c = zuoraId;
     pSetting.zqu__PaymentMethodType__c = 'Credit Card';
     pSetting.CurrencyIsoCode = 'USD';
        
     insert pSetting;
                   
     ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
     CreatePaymentMethodController controller = new CreatePaymentMethodController(sc);
     String pageId = controller.pageId; // adding code coverage for getter method
     System.assertEquals(controller.displayPage, false);
    }         
}