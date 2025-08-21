/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:        Docmation LLC
    Description:    Test Class for SPPUtils
    Inputs:         
    History:        Lu, 10/19/2017, created test methods to cover newly-added methods
                    in SPPUtils
                    Lu, 10/24/2017, created test methods to cover the exception blocks
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPUtilsTest {
    
    //Testing for Invoices
    static TestMethod void testreturnInvoices()        
    {
        Set<String> fetch = TestSampleData.getValues();
        String result = SPPUtils.returnInvoices(fetch);
        System.debug('Result for returnInvoices: '+result);
    }
    
    //Testing for Rate Plan IDS
    static TestMethod void testreturnRatePlanIds()
    {
        Set<String> fetch = TestSampleData.getValues();
        String result = SPPUtils.returnRatePlaneIds(fetch);
        System.debug('Result for returnRatePlanIds: '+result);
    }
    
    //Testing for Invoice line Ids
    static TestMethod void testreturnInvoiceLineIds()
    {
        Set<String> fetch = TestSampleData.getValues();
        String result = SPPUtils.returnInvoiceLineIds(fetch);
        System.debug('Result for returnInvoiceLineIds: '+result);
    }
    
    //Testing for Invoice Credit Balance Ids
    static TestMethod void testreturnInvoiceCrediBalIds()
    {
        Set<String> fetch = TestSampleData.getValues();
        String result = SPPUtils.returnInvoiceCrediBalIds(fetch);
        System.debug('Result for returnInvoiceCrediBalIds: '+result);
    }
    //Testing for Sandbox
    static TestMethod void testfindSandbox()
    {
    
        Boolean result = SPPUtils.isSandbox();
        System.debug('Result for isSandbox: '+result);
    }
    
    //Testing for Object Fields
    static TestMethod void testObjectField()
    {
        String fetchStringVal = TestSampleData.getObject();
        String fetchResult = SPPUtils.ObjectFields(fetchStringVal);
        System.debug('Result for Object Field: '+fetchResult);
    }
    
    
    //Testing for createEmailListToSend
    static TestMethod void createEmailListToSendTest()
    {
        String fetchStringVal = TestSampleData.getObject();
        Messaging.SingleEmailMessage fetchResult = SPPUtils.createEmailListToSend(new List<String>(), 'strEmailSubject','strEmailBody');
        System.debug('Result for Object Field: '+fetchResult);
    }
    
    //Testing for createEmailListToSend
    
    static TestMethod void getOauthAccessTokenTest()
    {
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        String fetchStringVal = TestSampleData.getObject();
        List<Callout_Configuration__mdt> lstcallout =[Select DeveloperName,MasterLabel,Client_Id__c,Client_Secret__c,Endpoint_URL__c,HTTP_Method__c,Content_Type__c,
        OAuth_Endpoint_URL__c, Username__c, Password__c,OAuth_HTTP_Method__c
        from Callout_Configuration__mdt where DeveloperName = 'MuleSoft_Commission_Endpoint'];
        //List<Callout_Configuration__mdt> lstcallout = new List<Callout_Configuration__mdt>();
        String fetchResult = MuleSoftUtils.getOauthAccessToken('JsonString','MuleSoft_Commission_Endpoint',lstcallout[0]);
    }
	
    
    //Testing for CalltoMuleSoft Basic Lu 10/19/2017 
    static TestMethod void CalltoMuleSoftBasicTest()
    {
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        String fetchStringVal = TestSampleData.getObject();
        Test.startTest();
        String fetchResult = MuleSoftUtils.CalltoMuleSoft(fetchStringVal,'MuleSoft_Commission_Endpoint','Basic');
        Test.stopTest();
        System.debug('Result for Object Field: '+fetchResult);
    }
    
    //Testing for CalltoMuleSoft OAuth Lu 10/19/2017
    static TestMethod void CalltoMuleSoftOAuthTest()
    {
        
        String fetchStringVal = TestSampleData.getObject();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String jsonData ='JsonString';
        jsonData = '{ "RequestId": "aae5fa44-f3e8-4a9a-bb45-f1286e3e7ffb","Async": false,"CallbackUrl": "","Orders": ["OrderType":"123456789qwer12","PartnerType":"Reseller","PartnerTier":"gold", "NCA":"", "ContractYear":"1", "Subscription":"yes", "ProductLine":"yes", "FirstLineSupport":"0", "ProductName":"sage","MultiYear":"yes", "ReferralDate":"", "InvoicedProduct":"","MDF":"","SFDC_ID":"a4i7E0000009UpJ" }';
        String strMuleSoftCall = 'MuleSoft_Margin_Endpoint';
        String fetchResult1 = MuleSoftUtils.CalltoMuleSoft(jsonData,'MuleSoft_Commission_Endpoint','OAuth');
        //String fetchException = MuleSoftUtils.CalltoMuleSoft(jsonData, strMuleSoftCall, 'apple');
        Test.stopTest();
        System.debug('Result for Object Field: '+fetchResult1);
    }
    
    //Lu, 10/24/2017, this method is for testing the exception block
    //in CalltoMuleSoft method
    /*
    static TestMethod void CalltoMuleSoftTestWithException(){
        String fetchException = MuleSoftUtils.CalltoMuleSoft('JsonString', 'MuleSoft_Commission_Endpoint', 'apple');
    } 
    */
    //Lu
    static TestMethod void sendDebugEmailTest(){
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        String endpointType = 'Commission';
        String endpointType1 = 'Margin';
        String jsonData = 'JsonData';
        String JSONString = 'JsonString';
        SPPUtils.sendDebugEmail(allMails, endpointType, jsonData, JSONString);
        SPPUtils.sendDebugEmail(allMails, endpointType1, jsonData, JSONString);
    }
    
    static TestMethod void createUserEmailListToSendTest(){
        List<String> listEmailTo = new List<String>{'sh@gmail.com','rp@gmail.com'};
        String subject = 'subject';
        String body = 'emailBody';
        SPPUtils.createUserEmailListToSend(listEmailTo, subject, body);
    }
    
    static TestMethod void metaDataTest(){
        //MetaDataTestContext.testCase = 'TestCase1';
        Map<ID,Sage_Cloud_Product__mdt> allCloudProduct = SPPUtils.allCloudProduct;
        List<Partner_Field__mdt> partnerfieldMapping = SPPUtils.partnerfieldMapping; 
        SPPTestData.creatAccount(1);
        Account acct = [SELECT Id FROM Account LIMIT 1];
        acct.Partner_Accountant__c = True;
        acct.Partner_Accountant_TnC__c = True;
        acct.Accountant_Partner_Tier__c = 'Authorized'; 
    }
    
    static TestMethod void updateQuoteRatePlanChargeMarginTest(){
        Account accou =new Account(Name='TestAccZuora',BillingStreet='Test City',BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                            Phone='1234567890',Type='Analyst');
        //accou.RecordType.name = 'Partner Account';
        accou.RecordTypeId =[Select Id,SobjectType,Name From RecordType WHERE Name ='Partner Account' and SobjectType ='Account' limit 1].Id;
        accou.Partner_Reseller__c = True;
        accou.Partner_Reseller_TnC__c = True;
        accou.Reseller_Partner_Tier__c = 'Authorized';
        insert accou;
        
        Opportunity Oppt=new Opportunity(Name='TestOpportunityZuora',Account=accou,Type='Resell Business',
                                         CloseDate=Date.today(),StageName=Label.Opportunity_Sales_Stages_Stage1,ForecastCategoryName='Omitted');
        insert Oppt;
        
        List<zqu__Quote__c> TestQuote=SPPTestData.CreateZuoraQuote(1,accou,Oppt);
        system.debug('this is debug for testQuote'+TestQuote);
        
        List<zqu__QuoteAmendment__c> Amendment=SPPTestData.CreateZuoraQuoteAmendment(1,TestQuote);
        List<zqu__QuoteRatePlan__c> TestRatePlan=SPPTestData.CreateZuoraQuoteRatePlan(1,Amendment,TestQuote);

        List<zqu__QuoteRatePlanCharge__c> TestQuoteRatePlanCharge=SPPTestData.CreateZuoraQuoteRatePlanCharge(1,TestRatePlan);
        system.debug('this is debug for testQuoteRatePlanCharge'+TestQuoteRatePlanCharge);
    }
    
    //1084 Included Why We Lost for Validation
    static TestMethod void updateQuoteRatePlanMarginTest(){
        
        Account accou =new Account(Name='TestAccQuoteRate',BillingStreet='Test City',BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                            Phone='1234567890',Type='Analyst');
        insert accou;
        Opportunity Oppt=new Opportunity(Name='TestOpportunityQuoteRate',Account=accou,Type='New Business',
                                         CloseDate=Date.today(),StageName=Label.Opportunity_Sales_Stages_Closed_Won,
                                         ForecastCategoryName='Closed',Why_We_Lost__c = 'No Reason Specified');
        insert Oppt;
        List<zqu__Quote__c> TestQuote=SPPTestData.CreateZuoraQuote(1,accou,Oppt);
        List<zqu__QuoteAmendment__c> TestQuoteAmend=SPPTestData.CreateZuoraQuoteAmendment(1,TestQuote);
        List<zqu__QuoteRatePlan__c> TestQuoteRatePlan=SPPTestData.CreateZuoraQuoteRatePlan(1,TestQuoteAmend,TestQuote);
        System.debug('Test Rate Plan '+[Select Id, zqu__AmendmentType__c,zqu__Quote__c,zqu__Quote__r.zqu__Opportunity__c, zqu__Quote__r.zqu__ExistSubscriptionID__c                                                                                    from zqu__QuoteRatePlan__c]);
        List<zqu__QuoteRatePlanCharge__c> TestQuoteRatePlanCharge=SPPTestData.CreateZuoraQuoteRatePlanCharge(2,TestQuoteRatePlan);
    }
    
    static TestMethod void getMapAccountRoleTest(){
        Account a = SPPTestData.createAccountAndContactAndOppListForPartnerType(1)[0];
        Set<Id> setAcct = new Set<Id>();
        setAcct.add(a.id);
        SPPUtils.getMapAccountRole(setAcct);
    }
    
    static TestMethod void getAllObjectFieldsTest(){
        
        SPPUtils.getAllObjectFields('Account');
    }

    static TestMethod void mapCountryCodeAndRateTest(){
        
        SPPUtils.mapCountryCodeAndRate();
    }
    
    static TestMethod void getPartnerTierTest(){
        
        Date subStartDate;
        
        Date subTermEndDate;
        
        Date subTermStartDate;
        
        Account a = SPPTestData.createAccountAndContactAndOppListForPartnerType(1)[0];
        
        a.isPartner = true;
        
        update a;
        
        String subType;
        
        List<Partner_Field__mdt> partnerfieldMapping = SPPUtils.partnerfieldMapping;
        
        SPPUtils.getPartnerTier(subStartDate, subTermEndDate, a, subType, subTermStartDate, partnerfieldMapping);
    }
    
}