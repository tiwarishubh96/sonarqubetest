@isTest
public with sharing class LLMCaseUpdatepost_test {
@isTest
    static void Contactpostunitest1() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '56789712',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch');
        insert testCon; 
        
        Case testCase = new Case(RecordtypeId = '0121o000000sgRx',Type = 'Question', ContactId = testCon.Id, Status = 'New', Priority = 'Medium', Origin = 'Crowdsourcing', Subject = 'Test Case', Product__c = 'UKI - 50cloud Accounts', case_Category__c = 'UKI - 50cloud Accounts',Case__c  = 'Brexit' );
        insert testCase;

        LLMCaseUpdatepost.TestPayload = '{"tenantMsgId":"'+testCase.Id +'","body":"Had Conversation with Customer","msgState":"Resolved"}';
        LLMCaseUpdatepost.CaseUpdateLimitlesswrapper();

    }
    
    @isTest
    static void Contactpostunitest2() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '56789712',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch');
        insert testCon; 
        
        Case testCase = new Case(RecordtypeId = '0121o000000sgRx',Type = 'Question', ContactId = testCon.Id, Status = 'New', Priority = 'Medium', Origin = 'Crowdsourcing', Subject = 'Test Case', Product__c = 'UKI - 50cloud Accounts', case_Category__c = 'UKI - 50cloud Accounts',Case__c  = 'Brexit');
        insert testCase;
               
        Casecomment newcomment = new Casecomment(ParentId = testCase.Id, Ispublished = False, CommentBody = 'Tst Case Comment' );
         insert newcomment;

        LLMCaseUpdatepost.TestPayload = '{"tenantMsgId":"'+testCase.Id +'","body":"Had Conversation with Customer","msgState":"Escalated"}';
        LLMCaseUpdatepost.CaseUpdateLimitlesswrapper();

    }
    @isTest
    static void Contactpostunitest3() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '56789712',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch');
        insert testCon; 
        
        Case testCase = new Case(RecordtypeId = '0121o000000sgRx',Type = 'Question', ContactId = testCon.Id, Status = 'New', Priority = 'Medium', Origin = 'Crowdsourcing', Subject = 'Test Case', Product__c = 'UKI - 50cloud Accounts', case_Category__c = 'UKI - 50cloud Accounts',Case__c  = 'Brexit');
        insert testCase;
               
        Casecomment newcomment = new Casecomment(ParentId = testCase.Id, Ispublished = False, CommentBody = 'Tst Case Comment' );
         insert newcomment;

        LLMCaseUpdatepost.TestPayload = '{"tenantMsgId":"'+testCase.Id +'","body":"Had Conversation with Customer","msgState":"timeout"}';
        LLMCaseUpdatepost.CaseUpdateLimitlesswrapper();

    }
     @isTest
    static void Contactpostunitest4() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '56789712',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch');
        insert testCon; 
        
        Case testCase = new Case(RecordtypeId = '0121o000000sgRx',Type = 'Question', ContactId = testCon.Id, Status = 'New', Priority = 'Medium', Origin = 'Crowdsourcing', Subject = 'Test Case', Product__c = 'UKI - 50cloud Accounts', case_Category__c = 'UKI - 50cloud Accounts',Case__c  = 'Brexit');
        insert testCase;
               
        Casecomment newcomment = new Casecomment(ParentId = testCase.Id, Ispublished = False, CommentBody = 'Tst Case Comment' );
         insert newcomment;

        LLMCaseUpdatepost.TestPayload = '{"tenantMsgId":"","body":"Had Conversation with Customer","msgState":"Resolved"}';
        LLMCaseUpdatepost.CaseUpdateLimitlesswrapper();

    }
    
 
}