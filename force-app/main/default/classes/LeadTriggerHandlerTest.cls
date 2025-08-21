/*-------------------------------------------------------------
Author:         Lakshman
Date :          08/18/2017
Company:       Docmation LLC
Description:   Test Class for LeadTriggerHandler
Inputs:        None
History
<Date>            <Authors Name>                <Brief Description of Change>

------------------------------------------------------------*/

@isTest
public with sharing class LeadTriggerHandlerTest {


 
    public static testMethod void testUpdateLanguage(){
            String language='German';
            Lead LangLead = new Lead();
            LangLead.LastName = 'DE LastName';
            LangLead.Company = 'DE Company';
            LangLead.Country='Germany';
            LangLead.Product__c='Sage One Accounting';
            LangLead.ELanguage__c='DE';
            
           insert LangLead;
           List<Lead> testLangLead =[select id,Language__c from Lead where id =: LangLead.id];
           for(Lead l:testLangLead) {
           System.debug(l.Language__c);
           system.assertEquals(language, l.Language__c);
         }
     }


    public static testMethod void testNASalesOffice(){
       List<String> NA_countries = new List<String> {'United States', 'Canada','Australia'};
       String SalesOffice='Atlanta CBC';
       List<Lead> NAlistLead = new List<Lead>();
       for (String country : NA_countries){
            Lead l = new Lead();
            l.LastName = country+'LastName';
            l.Company = country+'Company';
            l.Country=country;
            l.Product__c='Sage One Accounting';
            NAlistLead.add(l);
        }
         insert NAlistLead;
       List<Lead> salesOfficeLead =[select id,Sales_Office__c from Lead where id in :NAlistLead];
       for(Lead l:salesOfficeLead) {
         System.debug(l.Sales_Office__c);
         //system.assertEquals(SalesOffice, l.Sales_Office__c);
         }
  
     } 
    
    public static testMethod void testEUSalesOffice(){
       List<String> EU_countries = new List<String> {'United Kingdom', 'Ireland','Germany','France','Spain'};
       String SalesOffice='Dublin CBC';
       List<Lead> EUlistLead = new List<Lead>();
       for (String country : EU_countries){
            Lead l = new Lead();
            l.LastName = country+'LastName';
            l.Company = country+'Company';
            l.Country=country;
            l.Product__c='Sage One Accounting';
            EUlistLead.add(l);
        }
         insert EUlistLead;
       List<Lead> salesOfficeLead =[select id,Sales_Office__c from Lead where id in :EUlistLead];
       for(Lead l:salesOfficeLead) {
         System.debug(l.Sales_Office__c);
         //system.assertEquals(SalesOffice, l.Sales_Office__c);
         }
  
     }    
    
    public static testMethod void createpartnerRoleSharingLeadTest(){
        integer max = 10;
        SPPTestData.CreateAccountAndContactForPartnerType();
        Account acc = [select id from account limit 1];
        acc.isPartner = true;
        update acc;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs ( thisUser ) 
        {
            UserRole r = new UserRole(PortalAccountId = acc.Id,PortalType = 'Partner');
            Database.insert(r);
        }
        Map<Id,Lead> leadsMap = new Map<Id, Lead>();
        List<Lead> listLead = new List<Lead>();
        for(integer i = 0; i < max; i++){
            Lead leadLead = new Lead();
            leadLead.LastName = 'leadLead.LastName';
            leadLead.Company = 'leadLead.Company';
            leadLead.Referring_Partner_Account__c = acc.Id;
            listLead.add(leadLead);
        }
        insert listLead;
        leadsMap = new map<Id,Lead>([Select Id,Referring_Partner_Account__c,
                                     createdBy.accountid FROM Lead where Id in :listLead]);
        LeadTriggerHandler.createpartnerRoleSharingLead(listLead,leadsMap);
    }
    
    
    public static testMethod void createpartnerRoleSharingOppTest(){
        SPPTestData.CreateAccountAndContactForPartnerType();
        Account acc = [Select id from Account limit 1];
        Opportunity o = new Opportunity( Name='TestOpportunity',StageName='Qualify',CloseDate=Date.today(),ForecastCategoryName='Closed',Referring_Partner_Account__c=acc.id,Account=acc,Type='New Business');
        insert o;
        acc.isPartner = true;
        update acc;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs ( thisUser ) 
        {
            
            UserRole r = new UserRole(PortalAccountId = acc.Id,PortalType = 'Partner');
            Database.insert(r);
        }
        
        set<Id> oppl = new set<Id>();
        
        oppl.add(o.id);
        
        ///LeadTriggerHandler.createpartnerRoleSharingOpp(oppl);
        
    }
    
    public static testMethod void LeadInsertUpdate(){
        test.startTest();
        integer max = 3;
        SPPTestData.CreateAccountAndContactForPartnerType();
        Account acc = [select id from account limit 1];
        acc.isPartner = true;
        update acc;

        String recType=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        Account acc1 = new Account(Name='TestAcc1',BillingStreet='Test City',
                                  BillingCity='Atlanta',BillingCountry='United States',
                                  BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                                  Phone='1234567890',Type='Analyst',BillingPostalCode='30092',
                                  Partner_Accountant__c = true, Accountant_Partner_Tier__c ='Authorized',Partner_Account_ID__c = '1212',
                                   recordtypeid=recType,Locale_Billing_CC__c = 'US'
                                 );
        Account acc2 = new Account(Name='TestAcc2',BillingStreet='Test City',
                                  BillingCity='Atlanta',BillingCountry='United States',
                                  BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                                  Phone='1234567890',Type='Analyst',BillingPostalCode='30092',
                                  Partner_Implementation__c = true,SI_Partner_Tier__c='Gold',Partner_Account_ID__c = '1212',
                                   recordtypeid=recType,Locale_Billing_CC__c = 'US'
                                 );
        Account acc3 = new Account(Name='TestAcc3',BillingStreet='Test City',
                                  BillingCity='Atlanta',BillingCountry='United States',
                                  BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                                  Phone='1234567890',Type='Analyst',BillingPostalCode='30092',
                                  Partner_Reseller__c = true,Reseller_Partner_Tier__c='Authorized',Partner_Account_ID__c = '1212',
                                   recordtypeid=recType,Locale_Billing_CC__c = 'US'
                                 );
        List<Account> accList = new List<Account>();
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        insert accList;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs ( thisUser ) 
        {
            
            UserRole r = new UserRole(PortalAccountId = acc.Id,PortalType = 'Partner');
            Database.insert(r);
            
        }
        
        List<Lead> listLead = new List<Lead>();
        for(integer i = 0; i < max; i++){
            Lead leadLead = new Lead();
            leadLead.LastName = 'leadLead.LastName';
            leadLead.Company = 'leadLead.Company';
            leadLead.Referring_Partner_Account__c = accList[0].Id;
            
            listLead.add(leadLead);
        }
        insert listLead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(listLead[0].id);
        
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        
        Lead leadTest = listLead[1];
        leadTest.Email = 'test@email.com';
        
        update leadTest;
        Lead leadTest1 = listLead[2];
        leadTest1.Status = 'Open';
        update leadTest1;
        
        
        leadTest1.Product__c = 'Non Product Line Specific';
        
        //update leadTest1;
        delete leadTest1;
        test.stopTest();
    }
    //Adam Annony
    //Lead Playbook Play Status update test
    public static testMethod void LeadPlaybookPlayStatusUpdateTest(){
        test.startTest();
        Lead leadLead = new Lead();
        leadLead.Funnel_Stage__c = 'MQL';
        leadLead.LastName = 'test';
        leadLead.Status = 'New';
        leadLead.Company = 'testcompany';
        leadLead.Email = 'adamtestemail2@test.com';
        leadLead.LeadSource = 'Blog';
        leadLead.Product__c = 'Non Product Line Specific';
        insert leadLead;
        leadLead.Playbooks_Play_Status__c = 'In-Flight';
        update leadLead;

        Lead leadLead1 = new Lead();
        leadLead1.Funnel_Stage__c = 'MQL';
        leadLead1.LastName = 'test';
        leadLead1.Status = 'New';
        leadLead1.Company = 'testcompany';
        leadLead1.Email = 'adamtestemail3@test.com';
        leadLead1.LeadSource = 'Blog';
        leadLead1.Product__c = 'Non Product Line Specific';
        leadLead1.Playbooks_Play_Status__c = 'In-Flight';
        insert leadLead1;
        leadLead1.Playbooks_Play_Status__c = 'Failure';
        update leadLead1;
        test.stopTest();
    }
    
       // PGertz 2/20/2018    
    public static testMethod void UpdateLatestMQLDateTimeTest(){
        test.startTest();
        Lead leadLead = new Lead();
        leadLead.Funnel_Stage__c = 'MQL';
        leadLead.LastName = 'test';
        leadLead.Status = 'New';
        leadLead.Company = 'testcompany';
        leadLead.Email = 'paultestemail1@test.com';
        leadLead.LeadSource = 'Blog';
        leadLead.Product__c = 'Non Product Line Specific';
        insert leadLead;
        test.stopTest();
    }

    //EAD-461
    //test method to validate the country code assignment fix for appexchange leads.
    static testMethod void test_setCountryCodeToUk(){

        List<Lead> leads = new List<Lead>();
        for (integer i = 0; i < 200; i++) {
            Lead record = new Lead();
            record.FirstName = 'Test Lead First Name ' + i;
            record.LastName = 'Test Lead Last Name ' + i;
            record.Email = 'test' + i + '@testlead.com';
            record.Company = 'Avengers';

            //this is the ISO code of UK and US that will be sent from appexchange via REST, without the fix the lead insert will fail
            if (i >= 100) {
                record.Country = 'GB';
            } else {
                record.Country = 'US';
            }

            leads.add(record);
        }

        test.startTest();
        if (!leads.isEmpty()) {
            insert leads;
        }

        List<Lead> insertedLeads = [SELECT Id, Country, CountryCode FROM Lead WHERE Id IN:leads];
        System.assert(!insertedLeads.isEmpty(), 'Failed to create leads');
        for (Lead record : insertedLeads) {
            System.assert(record.Country.equals('United Kingdom') || record.Country.equals('United States'));
        }
        test.stopTest();
    }  

}