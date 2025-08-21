@isTest

public class PayNowTokenRetrieverTest {
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   
    /*
     * These can be used manually to test for the existence of the actual values.
     * In an initial deploy, they will fail since the values won't exist.
    @IsTest(SeeAllData=true) static void getSalesContactPhoneUs(){
        string phoneNumber = PayNowTokenRetriever.getSalesContactPhone('US');
        
        System.assertEquals('1 844 789 5433', phoneNumber);
    }
    @IsTest(SeeAllData=true) static void getSalesContactPhoneGb(){
        string phoneNumber = PayNowTokenRetriever.getSalesContactPhone('GB');
        
        System.assertEquals('0800 376 0000', phoneNumber);
    }
    @IsTest(SeeAllData=true) static void getSalesContactPhoneIe(){
        string phoneNumber = PayNowTokenRetriever.getSalesContactPhone('IE');
        
        System.assertEquals('1800 930 333', phoneNumber);
    }    
    @IsTest(SeeAllData=true) static void getSalesContactPhoneOther(){
        string phoneNumber = PayNowTokenRetriever.getSalesContactPhone('FOO');
        
        System.assertEquals('1 844 789 5433', phoneNumber);
    }  

    */
    
    static void getSalesContactNullCountry(){
        try{
        string errorText = PayNowTokenRetriever.getSalesContactPhone('null');
        } catch(Exception ex){
            string message = ex.getMessage();
            System.assertEquals(message, 'Missing billing country code.');
        }
      }  
    
    static testMethod void getSalesContactPhoneExists(){
        PayNowSetting__c setting = new PayNowSetting__c();
        setting.Name = 'ContactPhone_US';
        setting.Value__c = '1 844 789 5433';
        insert setting;
        
        string phoneNumber = PayNowTokenRetriever.getSalesContactPhone('US');
        
        System.assertEquals('1 844 789 5433', phoneNumber);
        
        PayNowSetting__c pnSetting = PayNowSetting__c.getInstance('usssss');
       
        
    }
    
    static testMethod void getSalesContactPhoneNoMatchDefaultToUs(){
        PayNowSetting__c setting = new PayNowSetting__c();
        setting.Name = 'ContactPhone_US';
        setting.Value__c = '1 844 789 5433';
        insert setting;
        string phoneNumber = PayNowTokenRetriever.getSalesContactPhone('FOO');
        System.assertEquals('1 844 789 5433', phoneNumber);
        
       }
    
    static testMethod void getPayNowPurchaseRequestNoData(){
        string quoteId = '';
        string pdfId = '';
        
        string requestJson = PayNowTokenRetriever.getPayNowPurchaseRequest(quoteId, pdfId,null);
        System.debug('requested JSON '+ requestJson);
       
        
        System.assert(requestJson.startsWithIgnoreCase('Error generating JSON:'));
    }
    
    static testMethod void getPayNowPurchaseRequestSuccess(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        
        zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
        testQuoteAmendment.Name = 'my test quote amendment';
        testQuoteAmendment.zqu__Quote__c = zquote.Id;
        insert testQuoteAmendment;
        

        PayNowSetting__c setting = new PayNowSetting__c();
        setting.Name = 'ContactPhone_US';
        setting.Value__c = '1 844 789 5433';
        insert setting;
        
        string pdfId = 'testpdf01';
        Attachment newAttachment = new Attachment();
        //newAttachment.Id = pdfId;
        newAttachment.Name = pdfId + '.pdf';
        newAttachment.ContentType = 'testMock';
        newAttachment.ParentId=acc.Id;
        newAttachment.Body=Blob.valueOf('');
        insert newAttachment;
        acc.BillingCountryCode = 'US';
         Map<string, string> params = new Map<string, string>();
        params.put('paymentCompleteNotificationUrl', 'test');
        params.put('paymentCompleteRedirectUrl', 'test');
        params.put('paymentCompleteCancelUrl', 'test');
        
        Product2 zp = new Product2();
        zp.zqu__ZuoraId__c=zuoraId;
        zp.zqu__SKU__c='zdvd';
        zp.Name='Test Product';
        insert zp;
        
        zqu__ProductRatePlan__c prp=new zqu__ProductRatePlan__c();
        prp.zqu__Product__c=zp.Id;
        prp.zqu__ZuoraId__c=zuoraId;
        insert prp;
        
        zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c();
        prpc.zqu__ZuoraId__c=zuoraId;
        prpc.zqu__ProductRatePlan__c=prp.Id;
        insert prpc;
        
        
        zqu__QuoteRatePlan__c testQuoteRatePlan = new zqu__QuoteRatePlan__c();
        testQuoteRatePlan.Name = 'my test quote rate plan';
        testQuoteRatePlan.zqu__QuoteAmendment__c = testQuoteAmendment.Id;
        insert testQuoteRatePlan;
        
        
        zqu__QuoteRatePlanCharge__c qc = new zqu__QuoteRatePlanCharge__c();
        qc.zqu__QuoteRatePlan__c=testQuoteRatePlan.Id;
        qc.zqu__ProductRatePlanCharge__c=prpc.Id;
        qc.zqu__Total__c=20;
        insert qc;

        string requestJson = PayNowTokenRetriever.getPayNowPurchaseRequest(zquote.Id, newAttachment.Id,params);
        
       // System.assert(requestJson.startsWithIgnoreCase('Error generating JSON:'));
        System.assert(requestJson.contains('version'));
    }
    
    static testMethod void getPayNowPurchaseRequestNoContact(){
       Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        //Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, null, zuoraId);
        
        PayNowSetting__c setting = new PayNowSetting__c();
        setting.Name = 'ContactPhone_US';
        setting.Value__c = '1 844 789 5433';
        insert setting;
        
        string pdfId = 'testpdf01';
        Attachment newAttachment = new Attachment();
        //newAttachment.Id = pdfId;
        newAttachment.Name = pdfId + '.pdf';
        newAttachment.ContentType = 'testMock';
        acc.BillingCountryCode = 'US';

        string requestJson = PayNowTokenRetriever.getPayNowPurchaseRequest(zquote.Id, newAttachment.Id,null);
        System.debug('requested JSON '+ requestJson);
        System.assert(requestJson.startsWithIgnoreCase('Error generating JSON:'));
        //System.assert(requestJson.contains('version'));
    }    
    
    static testMethod void getPayNowPurchaseRequestGbp(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        
        zquote.zqu__Currency__c = 'GBP';
        update zquote;
        
        PayNowSetting__c setting = new PayNowSetting__c();
        setting.Name = 'ContactPhone_US';
        setting.Value__c = '1 844 789 5433';
        insert setting;
        
        string pdfId = 'testpdf01';
        Attachment newAttachment = new Attachment();
        //newAttachment.Id = pdfId;
        newAttachment.Name = pdfId + '.pdf';
        newAttachment.ContentType = 'testMock';
        acc.BillingCountryCode = 'US';
         Map<string, string> params = new Map<string, string>();
        params.put('paymentCompleteNotificationUrl', 'test');
        params.put('paymentCompleteRedirectUrl', 'test');
        params.put('paymentCompleteCancelUrl', 'test');
        
        string requestJson = PayNowTokenRetriever.getPayNowPurchaseRequest(zquote.Id, newAttachment.Id,params);
        
       // System.assert(requestJson.startsWithIgnoreCase('Error generating JSON:'));
        System.assert(requestJson.contains('version'));
    }
    
    static testMethod void getPayNowPurchaseRequestEur(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        
        zquote.zqu__Currency__c = 'EUR';
        update zquote;
        
        PayNowSetting__c setting = new PayNowSetting__c();
        setting.Name = 'ContactPhone_US';
        setting.Value__c = '1 844 789 5433';
        insert setting;
        
        string pdfId = 'testpdf01';
        Attachment newAttachment = new Attachment();
        //newAttachment.Id = pdfId;
        newAttachment.Name = pdfId + '.pdf';
        newAttachment.ContentType = 'testMock';
        acc.BillingCountryCode = 'US';
         Map<string, string> params = new Map<string, string>();
        params.put('paymentCompleteNotificationUrl', 'test');
        params.put('paymentCompleteRedirectUrl', 'test');
        params.put('paymentCompleteCancelUrl', 'test');
        
        string requestJson = PayNowTokenRetriever.getPayNowPurchaseRequest(zquote.Id, newAttachment.Id,params);
        
       // System.assert(requestJson.startsWithIgnoreCase('Error generating JSON:'));
        System.assert(requestJson.contains('version'));
    }    
    
    static testMethod void createPayNowPurchaseToken(){
        string payNowBaseUrl = 'https://sage-commerce-dev-a.azurewebsites.net'; 
        string quoteId = '';
        string purchaseRequestPayLoad = '';
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        quoteID=zquote.id;
        
        zquote.zqu__Currency__c = 'GBP';
        update zquote;
        
      
        
        PayNowSetting__c url = new PayNowSetting__c();
        url.Name = 'payNowBaseUrl';
        url.Value__c = 'testServiceUrl';
        insert url; 
        
        PayNowSetting__c userName = new PayNowSetting__c();
        userName.Name = 'payNowServiceUserName';
        userName.Value__c = 'testServiceUserName';
        insert userName;
        
        PayNowSetting__c password = new PayNowSetting__c();
        password.Name = 'payNowServicePassword';
        password.Value__c = 'testServicePassword';
        insert password;
         PayNowToken__c token = new PayNowToken__c();
        token.Name = 'TestToken';
        insert token;
        String purchaseToken='test';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PayNowMockHttpResponseGeneratorTest());   
        PayNowToken__c newToken = PayNowTokenRetriever.createPayNowPurchaseToken(quoteId, purchaseRequestPayLoad);
        system.debug(newToken);
        String newTokenQuoteID=newToken.Quote__c;
        System.assertEquals('be5c6018-af15-47b7-9cb5-fba964ae423b',newToken.Name);
        System.assertEquals(quoteID,newTokenQuoteID);
        System.assertEquals('Created',newToken.Status__c);
        
       

    }
    
    static testMethod void createPayNowPurchaseTokenTetris(){
        string payNowBaseUrl = 'https://sage-commerce-dev-a.azurewebsites.net'; 
        string quoteId = '';
        string purchaseRequestPayLoad = '';
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        quoteID=zquote.id;
        
        zquote.zqu__Currency__c = 'GBP';
        
        zquote.External_Application__c = Global_Constants.TETRIS;
        update zquote;
        
      
        
        PayNowSetting__c url = new PayNowSetting__c();
        url.Name = 'payNowBaseUrl';
        url.Value__c = 'testServiceUrl';
        insert url; 
        
        PayNowSetting__c userName = new PayNowSetting__c();
        userName.Name = 'payNowServiceUserName';
        userName.Value__c = 'testServiceUserName';
        insert userName;
        
        PayNowSetting__c password = new PayNowSetting__c();
        password.Name = 'payNowServicePassword';
        password.Value__c = 'testServicePassword';
        insert password;
         PayNowToken__c token = new PayNowToken__c();
        token.Name = 'TestToken';
        insert token;
        String purchaseToken='test';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PayNowMockHttpResponseGeneratorTest());   
        PayNowToken__c newToken = PayNowTokenRetriever.createPayNowPurchaseToken(quoteId, purchaseRequestPayLoad);
        system.debug(newToken);
        String newTokenQuoteID=newToken.Quote__c;
        System.assertEquals('be5c6018-af15-47b7-9cb5-fba964ae423b',newToken.Name);
        System.assertEquals(quoteID,newTokenQuoteID);
        System.assertEquals('Created',newToken.Status__c);
        
       

    }
    

    static testMethod void createPayNowPurchaseTokenWithMap(){
        string payNowBaseUrl = 'https://sage-commerce-dev-a.azurewebsites.net'; 
        string quoteId = '';
        string purchaseRequestPayLoad = 'test';

        Map<ID,String> quotePayLoadMap=new Map<ID,String>();
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);
        quoteID=zquote.id;
        
        zquote.zqu__Currency__c = 'GBP';
        update zquote;
        quotePayLoadMap.put(quoteID,purchaseRequestPayLoad);

       
        
        PayNowSetting__c url = new PayNowSetting__c();
        url.Name = 'payNowBaseUrl';
        url.Value__c = 'testServiceUrl';
        insert url; 
        
        PayNowSetting__c userName = new PayNowSetting__c();
        userName.Name = 'payNowServiceUserName';
        userName.Value__c = 'testServiceUserName';
        insert userName;
        
        PayNowSetting__c password = new PayNowSetting__c();
        password.Name = 'payNowServicePassword';
        password.Value__c = 'testServicePassword';
        insert password;
        PayNowToken__c token = new PayNowToken__c();
        token.Name = 'TestToken';
        insert token;
        String purchaseToken='test';
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PayNowMockHttpResponseGeneratorTest());   
        Map<ID,PayNowToken__c> newToken = PayNowTokenRetriever.createPayNowPurchaseToken(quotePayLoadMap);
        system.debug(newToken);
        for (ID d: newToken.keySet())
        {
         String pNTQuoteID = newToken.get(d).Quote__c;
         system.assertEquals('be5c6018-af15-47b7-9cb5-fba964ae423b', newToken.get(d).Name);
         system.assertEquals('Created', newToken.get(d).status__c);
         system.assertEquals(quoteID, pNTQuoteID);
            
        }

        
    }
    
    
      

}