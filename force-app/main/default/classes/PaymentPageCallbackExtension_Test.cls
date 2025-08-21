@isTest(SeeAllData=true) //SeeAllData is needed to prevent 'Please upload Zuora WSDL at first.' error, caused by internal settings of zuora.
global class PaymentPageCallbackExtension_Test{

    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class

    static testMethod void runTestQuote(){
    
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
    
        PaymentPageCallbackExtension controller = new PaymentPageCallbackExtension(new zqu.PaymentPageCallbackController());
        PaymentPageCallbackExtension.getApiStub();
        
        controller.objectId = zquote.Id;
        controller.paymentId = zuoraId;
        controller.setParams();
    }
    
    static testMethod void runTestBillingAccount(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
       // Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
         Zuora__CustomerAccount__c bAccount = createBillingAccount(acc.Id);
        
        PaymentPageCallbackExtension controller = new PaymentPageCallbackExtension(new zqu.PaymentPageCallbackController());
        PaymentPageCallbackExtension.getApiStub();
        
        controller.objectId = bAccount.Id;
        controller.paymentId = zuoraId;
        controller.setParams();
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