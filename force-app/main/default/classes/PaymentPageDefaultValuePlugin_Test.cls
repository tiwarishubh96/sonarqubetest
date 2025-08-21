@isTest
global class PaymentPageDefaultValuePlugin_Test {

    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   
    
    public static testMethod void quoteCreditCardTest(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id,zuoraId); 
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', zquote.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Credit Card');
    }

    public static testMethod void quoteACHTest(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id,zuoraId); 
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'ACH','CBC');
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', zquote.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('ACH');
    }

    public static testMethod void quoteBankTransferTest(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id,zuoraId); 
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'Bank Transfer','CBC');
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', zquote.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Bank Transfer');
    }
    
    public static testMethod void quoteSEPATest(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id,zuoraId); 
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'Bank Transfer','CBC');
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', zquote.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('SEPA');
    }    

    public static testMethod void billingAccountTest(){
        Account acc = TestDataUtility.createAccount();
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId); 
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'Credit Card','CBC');
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', bAccount.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Credit Card');
    }   

    public static testMethod void noPaymentPageTest(){
        Account acc = TestDataUtility.createAccount();
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId); 
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', bAccount.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Credit Card');
    }
      
    public static testMethod void billingAccountTestUK(){
        
        Account acc = new Account();
        acc.Name = 'acme';
        acc.BillingCity = 'London';
        acc.BillingCountry = 'United Kingdom';   
        acc.BillingStreet ='Some Street';
        acc.BillingPostalCode = 'AA1 1AA';
        acc.Sales_Office__c = 'Dublin CBC';
        insert acc;   
        
        Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId); 
        
        zqu__HostedPageLiteSetting__c pSetting = new zqu__HostedPageLiteSetting__c();
        pSetting.Payment_Gateway_Name__c = 'sagecbcuseu';
        pSetting.Name = 'CBC UK ' + 'Credit Card' + ' Test Data';
        pSetting.zqu__ComponentName__c = 'PaymentPage';
        pSetting.zqu__PageId__c = zuoraId;
        pSetting.zqu__PaymentMethodType__c = 'Credit Card';
        pSetting.CurrencyIsoCode = 'GBP';
        insert pSetting;
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', bAccount.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Credit Card');
    }       
    
    public static testMethod void invalidPaymentMethodTypeTest(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id,zuoraId); 
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', zquote.Id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Invalid Type');
    }
    
    public static testMethod void missingIdTest(){
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', null);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Credit Card');
    }
    
    public static testMethod void wrongObjectTest(){
        Account acc = TestDataUtility.createAccount();
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentPageDefaultValuePlugin'));
        System.currentPageReference().getParameters().put('id', acc.id);

        PaymentPageDefaultValuePlugin controller = new PaymentPageDefaultValuePlugin();
        controller.getAdditionalParameters('Credit Card');
    }
}