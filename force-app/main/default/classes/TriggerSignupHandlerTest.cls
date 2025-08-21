@isTest
public class TriggerSignupHandlerTest{
    public static testMethod void createSignupRequest(){
        List<Success_Plan__c> toInsertSp = new List<Success_Plan__c>();
        integer max = 10;
        Account acc = new Account(Name='Test Account');
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.BillingStreet = 'A Street';
        acc.BillingCity = 'A City';
        acc.BillingState = 'Georgia';
        acc.BillingPostalCode = '11111';
        acc.BillingCountry = 'United States';
        insert acc;
        for(integer i = 0; i < max; i++){
            Success_Plan__c sp = new Success_Plan__c();
            sp.Name = 'Test' + i;
            sp.Account__c = acc.Id;
            sp.Status__c = 'New';
            sp.Type__c = 'Trial';
            sp.Trial_Country__c = 'US';
            toInsertSp.add(sp);
        }
        insert toInsertSp;
        List<Success_Plan__c> sccssPlans = new List<Success_Plan__c>();
        sccssPlans = [SELECT id FROM Success_Plan__c];
        SignupRequest sr = new SignupRequest();
        sr.Success_Plan__c = sccssPlans[0].Id;
        sr.TemplateId = '0TTj0000002A1Dw';
        sr.LastName = 'LastName';
        sr.Username = 'test@signup.sage';
        sr.SignupEmail = 'test@test.com';
        sr.Company = 'Test Company';
        sr.Country = 'FR';
        insert sr;
        system.assertEquals(sr.Success_Plan__r.Org_Installation_Date__c, sr.CreatedDate);
    }
}