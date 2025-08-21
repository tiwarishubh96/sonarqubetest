/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPscheduleBulkVoid
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPscheduleBulkVoidTest
{

    @testSetup static void SPPTestData() {
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c(
            dsfs__AccountId__c='Test Account ',dsfs__DocuSignBaseURL__c='Test Url',dsfs__DocuSignEnvironment__c='Test Env'
            , dsfs__DSProSFPassword__c='TestPass',dsfs__DSProSFUsername__c='Test Lucky'
        );
        insert accConFig;
        
        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
        Terms_Conditions_Version__c tn = [Select id from Terms_Conditions_Version__c limit 1];
        Terms_Conditions_Community__c tc = [Select Id from Terms_Conditions_Community__c limit 1];
        Account acc = [Select id from Account limit 1];
        Contact con = [Select id from Contact limit 1];
        
        tc.Partner_Types__c = 'Accountant';
        update tc;
        
        Partner_Terms_and_Condition__c part = new Partner_Terms_and_Condition__c (Contact__c=con.id ,Account__c =acc.id,Terms_Conditions_Version__c=tn.Id,Voided__c =true,DocuSign_EnvelopeId__c='test',DocuSign_Status__c='Sent' );
        insert part;
    }
    @isTest
    static void executeTest()
    {
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        test.startTest();
        
        String sch = '0 0 23 * * ?';
        System.schedule('TermsAndConditionsVoid', sch, new SPPscheduleBulkVoid());
        
        test.stopTest();
    }
}