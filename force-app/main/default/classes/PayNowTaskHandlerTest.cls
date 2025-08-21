@IsTest
public class PayNowTaskHandlerTest {
    final static string token = '752d154a-9c8b-4af1-a209-c4cda0fb2af5';
    final static string paymentMethodId = '76bbdf1a-6f39-4063-9c6a-8fc71d9b4640';
    final static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class
    final static string statusOfPaymentProvided = 'Payment Provided';
    final static string statusOfSent = 'Sent';
    
    @IsTest(SeeAllData=true) static void testOnAfterUpdateDirectly_EqualToken()
    {
        Account acc = TestDataUtility.createAccount();
     	Contact con = TestDataUtility.createContact(acc.Id);
     	zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        
        PayNowToken__c testToken = new PayNowToken__c( Name = token, Status__c = statusOfSent, PayNowRedirectUrl__c = 'http:\\pay.sage.com\token', Quote__c = zquote.Id );
        insert testToken;
        testToken = [select Id, Name, Status__c, PayNowRedirectUrl__c, Quote__c, PaymentMethodId__c from PayNowToken__c where Id = :testToken.Id];
		PayNowToken__c oldObject = [select Id, Name, Status__c, PayNowRedirectUrl__c, Quote__c from PayNowToken__c where Id = :testToken.Id];

        testToken.Status__c = statusOfPaymentProvided;
        testToken.PaymentMethodId__c = paymentMethodId;
        update testToken;
		PayNowToken__c newObject = [select Id, Name, Status__c, PayNowRedirectUrl__c, Quote__c, PaymentMethodId__c from PayNowToken__c where Id = :testToken.Id];

        List<PayNowToken__c> oldObjects = new List<PayNowToken__c> {oldObject};
		Map<Id, PayNowToken__c> oldObjectsMap = new Map<Id, PayNowToken__c>();
        oldObjectsMap.put(oldObject.Id, oldObject);

        List<PayNowToken__c> newObjects = new List<PayNowToken__c> {newObject};
		Map<Id, PayNowToken__c> newObjectsMap = new Map<Id, PayNowToken__c>();
        newObjectsMap.put(newObject.Id, newObject);

        PayNowTaskHandler.onAfterUpdate(oldObjects, oldObjectsMap, newObjects, newObjectsMap);
        
        System.assertEquals(testToken.Status__c, statusOfPaymentProvided);  
    }
    
/*    
	@IsTest(SeeAllData=true) static void TestNullToken(){
        List<PayNowToken__c> tokens = null;
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        System.assert(status == 'No action - no qualified tokens updated');
    }

	@IsTest(SeeAllData=true) static void TestEmptyToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        System.assert(status == 'No action - no qualified tokens updated');
    }

	@IsTest(SeeAllData=true) static void TestNotPaidStatus1Token(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Some other status';
        token.PaymentMethodId__c = null;
        tokens.add(token);
        insert tokens;
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        System.assert(status == 'No action - no qualified related quotes in Token');
    }
    
    @IsTest(SeeAllData=true) static void TestNotPaidStatus2Token(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Some other status';
        token.PaymentMethodId__c = 'cb30451a-0bbf-4f50-8d43-a9ee10739e48';
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        System.assert(status == 'No action - no qualified related quotes in Token');
    }

	@IsTest(SeeAllData=true) static void TestNoPaymentToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Payment Provided';
        token.PaymentMethodId__c = null;
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        System.assert(status == 'No action - no qualified related quotes in Token');
    }

 
    @IsTest(SeeAllData=true) static void TestNoMatchingQuoteToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Payment Provided';
        token.PaymentMethodId__c = 'cb30451a-0bbf-4f50-8d43-a9ee10739e48';
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        //System.assert(status == 'No action - no qualified quotes found in Quote');
    }
 
    @IsTest(SeeAllData=true) static void TestNoLastModifiedUserToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Payment Provided';
        token.PaymentMethodId__c = 'cb30451a-0bbf-4f50-8d43-a9ee10739e48';
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        //System.assert(status == 'No action - no qualified related users in Quote');
    }

    @IsTest(SeeAllData=true) static void TestLastModifiedUserNotExistsToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Payment Provided';
        token.PaymentMethodId__c = 'cb30451a-0bbf-4f50-8d43-a9ee10739e48';
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        //System.assert(status == 'No action - no qualified users found in Users');
    }

    @IsTest(SeeAllData=true) static void TestSuccessToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Payment Provided';
        token.PaymentMethodId__c = 'cb30451a-0bbf-4f50-8d43-a9ee10739e48';
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        //System.assert(status == 'Created tasks');
    }

    @IsTest(SeeAllData=true) static void TestExceptionToken(){
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        PayNowToken__c token = new PayNowToken__c();
        token.Status__c = 'Payment Provided';
        token.PaymentMethodId__c = 'cb30451a-0bbf-4f50-8d43-a9ee10739e48';
        tokens.add(token);
        
        string status = PayNowTaskHandler.processPostPayment(tokens);
        
        //System.assert(status == 'Error creating task');
    }
*/   
}