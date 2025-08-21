/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPPartnerTnCTrigger
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPPartnerTnCTriggerTest {

    
    static TestMethod void createpartnerRoleSharingDocusignStatusTest()
    {
        SPPTestData.CreateAccountAndContactForPartnerType();
        Account acc = [Select id from account limit 1];
        //Data for createpartnerRoleSharingDocusignStatus Method
        SPPTestData.CreateTandCGlobalAndVersions();
        SPPDocuSignTestData.CreateDocuSignStatus();
        dsfs__DocuSign_Status__c doc = [Select id from dsfs__DocuSign_Status__c limit 1];
        Terms_Conditions_Version__c tnv = [Select id from Terms_Conditions_Version__c where Active__c = true limit 1];
        Contact con = [Select id from Contact limit 1];
        SPPDocuSignTestData.CreatePartnerTandCond(acc,tnv,doc,con);
        Partner_Terms_and_Condition__c par = [Select id from Partner_Terms_and_Condition__c limit 1];
        update par;
        
    }
}