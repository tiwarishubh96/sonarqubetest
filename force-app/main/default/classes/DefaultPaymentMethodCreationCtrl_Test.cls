@isTest
public with sharing class DefaultPaymentMethodCreationCtrl_Test {

private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   

    public static testMethod void runTestSuccess(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
    
        ApexPages.StandardController ctrl = new ApexPages.StandardController(bAccount);
        DefaultPaymentMethodCreationController controller = new DefaultPaymentMethodCreationController(ctrl);
        controller.next();
        controller.cancel(); 
        String pageId = controller.pageId; // adding code coverage for getter method
    }

    public static testMethod void runErrorTestNoPaymentPages(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
           
        ApexPages.StandardController ctrl = new ApexPages.StandardController(bAccount);
        DefaultPaymentMethodCreationController controller = new DefaultPaymentMethodCreationController(ctrl);
        controller.next();
        controller.cancel(); 
        String pageId = controller.pageId; // adding code coverage for getter method
    }
    
    public static testMethod void runErrorTestMultiplePaymentPages(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createHostedPageLiteSetting('2c92c0f84dfff49f014e021c79b82bb7'); // Different Zuora Id to avoid DML constraint error
           
        ApexPages.StandardController ctrl = new ApexPages.StandardController(bAccount);
        DefaultPaymentMethodCreationController controller = new DefaultPaymentMethodCreationController(ctrl);
        controller.next();
        controller.cancel(); 
        String pageId = controller.pageId; // adding code coverage for getter method
    }
    
    public static testMethod void runErrorTestMissingGatewayName(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
          
        // Insert a Payment Page with no Gateway Name
        zqu__HostedPageLiteSetting__c pSetting = new zqu__HostedPageLiteSetting__c();
        pSetting.Name = 'CBC US Credit Card Test Data';
        pSetting.zqu__ComponentName__c = 'PaymentPage';
        pSetting.zqu__PageId__c = zuoraId;
        pSetting.zqu__PaymentMethodType__c = 'Credit Card';
        pSetting.CurrencyIsoCode = 'USD';
        
        insert pSetting;
                   
        ApexPages.StandardController ctrl = new ApexPages.StandardController(bAccount);
        DefaultPaymentMethodCreationController controller = new DefaultPaymentMethodCreationController(ctrl);
        controller.next();
        controller.cancel(); 
        String pageId = controller.pageId; // adding code coverage for getter method
    } 
}