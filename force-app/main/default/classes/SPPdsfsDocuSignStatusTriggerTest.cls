/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPdsfsDocuSignStatusTrigger
    Inputs:        None
    History
    <Date>            <Authors Name>               <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPdsfsDocuSignStatusTriggerTest
{
    @testSetup static void SPPTestData() {
        
        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
        
    }
    
    @isTest
    static void testMethod1()
    {
        Account acc = [Select id from Account limit 1];
        Terms_Conditions_Version__c tnv = [Select id from Terms_Conditions_Version__c limit 1];
        Contact con = [Select id from Contact limit 1];
        
        Partner_Terms_and_Condition__c par = new Partner_Terms_and_Condition__c();
        par.Docusign_Status__c = 'pending';
        par.Account__c = acc.Id;
        par.Terms_Conditions_Version__c = tnv.Id;
        par.DocuSign_EnvelopeId__c = 'enveId';
        par.Contact__c = con.id;
        insert par;

        
        dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c();
        docStatus.dsfs__DocuSign_Envelope_ID__c = 'enveId';
        docStatus.dsfs__Envelope_Status__c = 'Completed';
        insert docStatus;

    }
}