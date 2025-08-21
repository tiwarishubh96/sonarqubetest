/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPActivatenewTandC
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPActivatenewTandCTest
{

    @testSetup static void SPPTestData() {
        
       // SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
        
    }

    @isTest
    static void activateTnCWithoutError()
    {

        Terms_Conditions_Community__c tncc = [Select id,name,TnC_Versions_Count__c  from Terms_Conditions_Community__c limit 1];
        Terms_Conditions_Version__c tnvc = [Select id,name from Terms_Conditions_Version__c  where Active__c = false limit 1];
        
        SPPActivatenewTandC.activateTnC(tncc.Id,'Accountant',false,'Authorized','en_US',tnvc.id );

    }

    @isTest
    static void activateTnCWithActiveFalse()
    {

        Terms_Conditions_Community__c tncc = [Select id,name,TnC_Versions_Count__c  from Terms_Conditions_Community__c limit 1];
        Terms_Conditions_Version__c tnvc = [Select id,name from Terms_Conditions_Version__c where Active__c = true limit 1];
        
        SPPActivatenewTandC.activateTnC(tncc.Id,'Accountant',false,'Authorized','en_US',tnvc.id );

    }

    @isTest
    static void activateTnCWithActiveFalse2()
    {

        Terms_Conditions_Community__c tncc = [Select id,name,TnC_Versions_Count__c  from Terms_Conditions_Community__c limit 1];
        Terms_Conditions_Version__c tnvc = [Select id,name from Terms_Conditions_Version__c where End_Date_Active__c != null limit 1];
        SPPActivatenewTandC.activateTnC(tncc.Id,'Accountant',false,'Authorized','en_US',tnvc.id );

    }

    @isTest
    static void activateTnCWithActiveFalse3()
    {

        Terms_Conditions_Community__c tncc = [Select id,name,TnC_Versions_Count__c  from Terms_Conditions_Community__c limit 1];
        Terms_Conditions_Version__c tnvc = [Select id,name from Terms_Conditions_Version__c where Active__c = false and End_Date_Active__c != null limit 1];
        SPPActivatenewTandC.activateTnC(tncc.Id,'Accountant',false,'Authorized','en_US',tnvc.id );

    }
    
}