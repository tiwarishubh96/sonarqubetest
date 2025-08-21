@isTest
public with sharing class Success_PlanTriggerHandlerTest{
    public static testMethod void runTest1(){
        Account accnt = new Account();
        accnt.Existing_Salesforce_User__c = 'Yes';
        accnt.Name = 'Test Account';
        insert accnt;
        Contact cntact = new Contact();
        cntact.LastName = 'Test';
        cntact.Account = accnt;
        insert cntact;
        Opportunity opportunty = new Opportunity();
        opportunty.AccountId = accnt.Id;
        opportunty.CloseDate = system.today();
        opportunty.Name = 'opportunty.Name';
        opportunty.StageName = 'Qualify';
        system.assertEquals(accnt.Existing_Salesforce_User__c, 'Yes');
        //system.assertEquals(opportunty.Existing_Salesforce_User__c, true);
        insert opportunty;
        Success_Plan__c successPlan = new Success_Plan__c();
        successPlan.Name = 'TEST';
        successPlan.Account__c = accnt.Id;
        successPlan.Opportunity__c = opportunty.Id;
        successPlan.Status__c = 'New';
        successPlan.Type__c = 'Trial';
        Integer integrCase = [SELECT count() FROM Case];
        Integer integrSuccessPlan = [SELECT count() FROM Success_Plan__c];
        system.debug('joejoe28 :' + opportunty.AccountId + ':');
        system.debug('joejoe29 :' + successPlan.Account__c + ':');
        system.debug('joejoe30 :' + successPlan.Opportunity__c + ':');
        insert successPlan;
        /*INC0379162 - Please turn off the following Trigger/Trigger Handler
        System.assertNotEquals([SELECT Id FROM Case].size(), 0);
        Case cse = [SELECT ContactId, Customer_Lifecycle_Stage__c, Origin, Type FROM Case];
        
        //Success Plan created from Opportunity in stage 1-6
        System.assertEquals(integrSuccessPlan + 1, [SELECT count() FROM Success_Plan__c]);
        //Case created
        System.assertEquals(integrCase + 1, [SELECT count() FROM Case]);
        System.assertEquals('Pre-Production', cse.Customer_Lifecycle_Stage__c);
        System.assertEquals('Internal', cse.Origin);
        System.assertEquals('Internal', cse.Type);
        System.assertEquals(successPlan.Trial_Contact__c, cse.ContactId);
        
        //The Case is Attached to success plan
        System.assertEquals([SELECT Success_Plan__c FROM Case LIMIT 1].Success_Plan__c, successPlan.Id);
        */
    }
    
    public static testMethod void runTest2(){
        Account accnt = new Account();
        accnt.Existing_Salesforce_User__c = 'Yes';
        accnt.Name = 'Test Account';
        insert accnt;
        Contact cntact = new Contact();
        cntact.LastName = 'Test';
        cntact.Account = accnt;
        insert cntact;
        Opportunity opportunty = new Opportunity();
        opportunty.AccountId = accnt.Id;
        opportunty.CloseDate = system.today();
        opportunty.Name = 'opportunty.Name';
        opportunty.StageName = '07 Closed - Won';
        system.assertEquals(accnt.Existing_Salesforce_User__c, 'Yes');
        //system.assertEquals(opportunty.Existing_Salesforce_User__c, true);
        insert opportunty;
        Success_Plan__c successPlan = new Success_Plan__c();
        successPlan.Name = 'TEST';
        successPlan.Account__c = accnt.Id;
        successPlan.Opportunity__c = opportunty.Id;
        successPlan.Status__c = 'New';
        successPlan.Type__c = 'Trial';
        Integer integrCase = [SELECT count() FROM Case];
        Integer integrSuccessPlan = [SELECT count() FROM Success_Plan__c];
        system.debug('joejoe28 :' + opportunty.AccountId + ':');
        system.debug('joejoe29 :' + successPlan.Account__c + ':');
        system.debug('joejoe30 :' + successPlan.Opportunity__c + ':');
        insert successPlan;
        /*INC0379162 - Please turn off the following Trigger/Trigger Handler
        Case cse = [SELECT ContactId, Customer_Lifecycle_Stage__c, Origin, Type FROM Case];
        
        //Success Plan created from Opportunity in stage 1-6
        System.assertEquals(integrSuccessPlan + 1, [SELECT count() FROM Success_Plan__c]);
        //Case created
        System.assertEquals(integrCase + 1, [SELECT count() FROM Case]);
        System.assertEquals('Onboarding - No Pre-production', cse.Customer_Lifecycle_Stage__c);
        System.assertEquals('Internal', cse.Origin);
        System.assertEquals('Internal', cse.Type);
        System.assertEquals(successPlan.Trial_Contact__c, cse.ContactId);
        
        //The Case is Attached to success plan
        System.assertEquals([SELECT Success_Plan__c FROM Case LIMIT 1].Success_Plan__c, successPlan.Id);
        */
    }
}