/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPQuoteChargeTrigger
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPQuoteChargeTriggerTest {
Public static  TestMethod void  TestCRMQuoteCharge()
{
    Account accou =new Account(Name='TestAccZuora',BillingStreet='Test City',BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                            Phone='1234567890',Type='Analyst');
    insert accou;
    
    //1084 Added Why We Lost for Validation
    Opportunity Oppt=new Opportunity(Name='TestOpportunityZuora',Account=accou,Type='New Business',CloseDate=Date.today(),StageName='Closed Won',ForecastCategoryName='Closed',
                                    Why_We_Lost__c = 'No reason specified');
    insert Oppt;
    List<zqu__Quote__c> TestQuote=SPPTestData.CreateZuoraQuote(1,accou,Oppt);
    Test.startTest();
    List<zqu__QuoteCharge__c> TestQuoteCharge=SPPTestData.CreateZuoraQuoteCharge(1,TestQuote);
    Test.stopTest();
}

}