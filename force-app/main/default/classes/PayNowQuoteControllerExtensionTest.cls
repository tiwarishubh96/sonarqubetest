@isTest

public class PayNowQuoteControllerExtensionTest {
	
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class
    
    @IsTest(SeeAllData=true) static  void runTestExistingToken(){
        Account acc = TestDataUtility.createAccount();
     	Contact con = TestDataUtility.createContact(acc.Id);
     	zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);

        PayNowToken__c a = new PayNowToken__c(name= 'purchaseToken', PayNowRedirectUrl__c = 'http:\\pay.sage.com\token', Quote__c = zquote.Id, Status__c ='Created');
        insert a;
        
     	ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
                
        //Call controller with token created.
     	PayNowQuoteControllerExtension controller = new PayNowQuoteControllerExtension(sc);
        
        string payNowLink = controller.getPayNowLink();
        
        string status = controller.getStatus();
        
        string message = controller.getMessage();
    }
    
    @IsTest(SeeAllData=true) static  void runTestExistingTokenPaymentProvidedStatus(){
        Account acc = TestDataUtility.createAccount();
     	Contact con = TestDataUtility.createContact(acc.Id);
     	zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);

        PayNowToken__c a = new PayNowToken__c(name= 'purchaseToken', PayNowRedirectUrl__c = 'http:\\pay.sage.com\token', Quote__c = zquote.Id, Status__c ='Payment Provided');
        insert a;
        
     	ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
                
        //Call controller with token created.
     	PayNowQuoteControllerExtension controller = new PayNowQuoteControllerExtension(sc);
        
        string payNowLink = controller.getPayNowLink();
        
        string status = controller.getStatus();
        
        string message = controller.getMessage();
    }
    
    @IsTest(SeeAllData=true) static  void runTestNoExistingToken(){
        Account acc = TestDataUtility.createAccount();
     	Contact con = TestDataUtility.createContact(acc.Id);
     	zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
                
     	ApexPages.StandardController sc = new ApexPages.StandardController(zquote);
                
        //Call controller with token created.
     	PayNowQuoteControllerExtension controller = new PayNowQuoteControllerExtension(sc);
        
        string payNowLink = controller.getPayNowLink();
        
        string status = controller.getStatus();
        
        string message = controller.getMessage();
    }
}