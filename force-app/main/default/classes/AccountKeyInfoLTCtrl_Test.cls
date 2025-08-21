@isTest
public with sharing class AccountKeyInfoLTCtrl_Test {

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'nogroup', Email='standardusernogroup@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='nogroup@anywhere.com', FederationIdentifier='nogroup');
        insert u; 
        Account account = new Account(Name='TestAcc');
        insert account;
        Call_Item__c callItem = new Call_Item__c(Name='MyCallItem',FederationUserID__c=u.FederationIdentifier,Account__c=account.id);
        insert callItem;
    }
    
    /**
    * Tests that passing the recordId in SOQL uses the supplied recordId as the Account record Id
    */
    @isTest public static void  testFetchKeyInfo_AccountRecord() {
        Account account = [select Id from Account where Name = 'TestAcc' LIMIT 1];
        String configName = 'Account';
        String recordId = account.Id;
        String soql = 'recordId';
        String accountFieldName ='Account__c';
        Test.startTest();
            AccountKeyInfoLTCtrl.fetchKeyInfo(configName,recordId,soql,accountFieldName);
        Test.stopTest();
        System.assertEquals(AccountKeyInfoLTCtrl.accountId, account.Id,'Should have selected the recordId as accountId');

    }

   /**
    * Tests that the SOQL wil find the account record to drive the key information queries
    */
    @isTest public static void  testFetchKeyInfo_Call_Item_Record() {
        List<Call_Item__c> callItems = [select Id,Account__c from Call_Item__c];
        Call_Item__c callItem = callItems[0];
        String configName = 'CallItem';
        String recordId = callItem.Id;
        String soql = 'SELECT Account__c FROM Call_Item__c where id =';
        String accountFieldName ='Account__c';
        Test.startTest();
            AccountKeyInfoLTCtrl.fetchKeyInfo(configName,recordId,soql,accountFieldName);
        Test.stopTest();
        System.assertEquals(AccountKeyInfoLTCtrl.accountId, callItem.Account__c,'Should have looked up the Account from the CallItem');

    }   
}