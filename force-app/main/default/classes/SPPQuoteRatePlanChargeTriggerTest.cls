/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPQuoteRatePlanChargeTrigger
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPQuoteRatePlanChargeTriggerTest {
    
    Public static  TestMethod void  TestCRM()
    {
        Account accou =new Account(Name='TestAccQuoteRate',BillingStreet='Test City',BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                                Phone='1234567890',Type='Analyst');
        insert accou;
        
        //1084 Included Why We Lost field for Validation
        Opportunity Oppt=new Opportunity(Name='TestOpportunityQuoteRate',Account=accou,Type='New Business',CloseDate=Date.today(),StageName='Closed Won',ForecastCategoryName='Closed',
                                        Why_We_Lost__c = 'No reason specified');
        insert Oppt;
        List<zqu__Quote__c> TestQuote=SPPTestData.CreateZuoraQuote(1,accou,Oppt);
        List<zqu__QuoteAmendment__c> TestQuoteAmend=SPPTestData.CreateZuoraQuoteAmendment(1,TestQuote);
        List<zqu__QuoteRatePlan__c> TestQuoteRatePlan=SPPTestData.CreateZuoraQuoteRatePlan(1,TestQuoteAmend,TestQuote);
         System.debug('Test Rate Plan '+[Select Id, zqu__AmendmentType__c,zqu__Quote__c,zqu__Quote__r.zqu__Opportunity__c, zqu__Quote__r.zqu__ExistSubscriptionID__c                                                                                    from zqu__QuoteRatePlan__c]);
        List<zqu__QuoteRatePlanCharge__c> TestQuoteRatePlanCharge=SPPTestData.CreateZuoraQuoteRatePlanCharge(2,TestQuoteRatePlan);
        system.debug('TEst : '+TestQuoteRatePlanCharge);
        Test.startTest();
        //insert TestQuoteRatePlanCharge;
        Test.stopTest();
    }

    
}