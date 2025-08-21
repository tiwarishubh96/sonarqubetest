/*
* Class Name :- DSRRelatedListControllerTest
* Author :- Shubham Kimothi
* Created Date :- 16-04-2019
* Description : This test class is covering the code of DSRRelatedListController.
* 
// ********************Change Logs *****************************************************************************************************************************
*/

@isTest 
private class DSRRelatedListControllerTest {
    static testMethod void CreateDealSupportRequest() {
        
        //Insert Account
        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingState='Avon',BillingCity='Alphareeta',BillingStreet='street');
        insert acc;                
        
        //Insert Opportunity
        //1084 Added Why We Lost for validation
        Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opp for deal request', 
                                          StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                          Why_We_Lost__c = 'No Reason Specified',
                                          CloseDate = Date.today());
        insert opp;
        
        DealSupportRequest__c dsrc = new DealSupportRequest__c();
        dsrc.DealSupportRequestDetail__c = 'test desc';
        dsrc.opportunity__c = opp.Id;
        dsrc.DealSupportRequestType__c = 'Deal Desk';
        insert dsrc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(dsrc);
        DSRRelatedListController dsr = new DSRRelatedListController(sc);
    }
}