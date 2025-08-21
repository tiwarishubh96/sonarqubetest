/*
* Class Name :- DealSupportRequestControllerTest
* Author :- Shubham Kimothi
* Created Date :- 16-04-2019
* Description : This test class is covering the code of DealSupportRequestController.
* 
// ********************Change Logs *****************************************************************************************************************************
*/

@isTest 
private class DealSupportRequestControllerTest {
    static testMethod void CreateDealSupportRequest() {
        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingState='Avon',BillingCity='Alphareeta',BillingStreet='street');
        insert acc;                
        
        //Insert Opportunity
        //1084 Added Why We Lost for validation
        Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opp for deal request', 
                                          StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                          Why_We_Lost__c = 'No Reason Specified',
                                          CloseDate = Date.today());
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        DealSupportRequestController dsrc = new DealSupportRequestController(sc);
        dsrc.CreateDealSupportRequest();
        List<DealSupportRequest__c> dsrList = [SELECT Id FROM DealSupportRequest__c WHERE Opportunity__c =:Opp.Id];
        System.assertEquals(1,dsrList.size());
    }
}