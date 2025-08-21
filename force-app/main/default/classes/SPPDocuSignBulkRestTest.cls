/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPDocuSignBulkRest
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPDocuSignBulkRestTest
{
    
    @isTest
    static void itShould()
    {
        // Given
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c(
            dsfs__AccountId__c='Test Account ',dsfs__DocuSignBaseURL__c='Test Url',dsfs__DocuSignEnvironment__c='Test Env'
            , dsfs__DSProSFPassword__c='TestPass',dsfs__DSProSFUsername__c='Test Lucky'
        );
        insert accConFig;
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        
        Test.startTest();
        SPPWrapperDocuSign wrap = SPPDocuSignBulkRest.CreateEnvelopDraftWithTemplate('templateID');
        
        SPPWrapperDocuSign wrap1 = SPPDocuSignBulkRest.createBulkRecipientsFromCSV('envId' , 'csvFile');
        
        SPPWrapperDocuSign wrap2 = SPPDocuSignBulkRest.updateEnvelope('envId');
        
        SPPBulkEnvelops wrap3 = SPPDocuSignBulkRest.getBulkList('envId');
        Test.stopTest();
        
        
    }
    
    
     @isTest
    static void getBulkListException()
    {
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        SPPBulkEnvelops wrap3 = SPPDocuSignBulkRest.getBulkList('envId');
        
    }
}