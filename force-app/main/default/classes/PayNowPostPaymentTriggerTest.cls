@IsTest
public class PayNowPostPaymentTriggerTest {
    final static string token = '752d154a-9c8b-4af1-a209-c4cda0fb2af5';
    final static string paymentMethodId = '76bbdf1a-6f39-4063-9c6a-8fc71d9b4640';
    final static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class
    final static string statusOfPaymentProvided = 'Payment Provided';
    final static string statusOfSent = 'Sent';
    
    @IsTest(SeeAllData=true) static void testTriggerViaDML()
    {
        Account acc = TestDataUtility.createAccount();
     	Contact con = TestDataUtility.createContact(acc.Id);
     	zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        
        PayNowToken__c testToken = new PayNowToken__c( Name = token, Status__c = statusOfSent, PayNowRedirectUrl__c = 'http:\\pay.sage.com\token', Quote__c = zquote.Id );
        insert testToken;
        testToken = [select Id, Name, Status__c, PayNowRedirectUrl__c, Quote__c from PayNowToken__c where Id = :testToken.Id];
        testToken.Status__c = statusOfPaymentProvided;
        testToken.PaymentMethodId__c = paymentMethodId;
        update testToken;

        System.assertEquals(testToken.Status__c, statusOfPaymentProvided);  
    }
}