@isTest
public with sharing class zuora_actionZBillingCtrlTest {

    @TestSetup
    static void makeData(){
        RecordType defaultType = [SELECT Id FROM RecordType WHERE SobjectType = 'zqu__Quote__c' and DeveloperName = 'Default' LIMIT 1];
        
        Account account = new Account(Name='TestAcc');
        insert account;
        zqu__Quote__c zqu_Quote = new zqu__Quote__c(zqu__Account__c=account.Id);
        zqu_Quote.RecordTypeId = defaultType.Id;
        zqu_Quote.Name = 'TestQuote';
        insert zqu_Quote;
        zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
        testQuoteAmendment.Name = 'my test quote amendment';
        testQuoteAmendment.zqu__Quote__c = zqu_Quote.Id;
        insert testQuoteAmendment;        
        zqu__QuoteRatePlan__c qrPlan = new zqu__QuoteRatePlan__c(Name='my test quote rate plan');
        qrPlan.zqu__Quote__c = zqu_Quote.id;
        qrPlan.zqu__QuoteAmendment__c = testQuoteAmendment.Id;
        insert qrPlan;
        
        zqu__QuoteChargeSummary__c qcSum = new zqu__QuoteChargeSummary__c(TranslatedProductName__c='Some value');
        qcSum.zqu__QuoteRatePlan__c = qrPlan.Id;
        insert qcSum;    
    } 


    @isTest
    public static void testFetchQuoteChargeSummary(){
        zqu__Quote__c quote = [Select Id from zqu__Quote__c where Name = 'TestQuote'];
        System.assert(quote != null);
        List<zqu__QuoteChargeSummary__c> qChSum = zuora_actionZBillingCtrl.fetchQuoteChargeSummary(quote.Id);
        System.assert(qChSum.size() == 1);
    }    

    @isTest
    public static void testgetQuote(){
        zqu__Quote__c quote = [Select Id from zqu__Quote__c where Name = 'TestQuote'];
        System.assert(quote != null);
        zqu__Quote__c zQuote = zuora_actionZBillingCtrl.getQuote(quote.Id);
        System.assert(zQuote != null);
    }

    @isTest
    public static void testProcessResponse(){
        String EX = 'There was am Exception';
        String UN = 'It was Unsuccessful';
        String ALL = 'Other things happened';
        zuora_actionZBillingCtrl.Billing_m result = zuora_actionZBillingCtrl.processResponse(EX);
        System.assertEquals(result.status, 'FAILURE');
        result = zuora_actionZBillingCtrl.processResponse(UN);
        System.assertEquals(result.status, 'FAILURE');   
        result = zuora_actionZBillingCtrl.processResponse(ALL);
        System.assertEquals(result.status, 'SUCCESS');           
    }
    
    @isTest
    public static void testCallZQuoteGlobal(){
        zqu__Quote__c quote = [Select Id from zqu__Quote__c where Name = 'TestQuote'];
        System.assert(quote != null);
        
        zuora_actionZBillingCtrl.Billing_m result  = zuora_actionZBillingCtrl.callZQuoteGlobal(quote.id);
        
    }

}