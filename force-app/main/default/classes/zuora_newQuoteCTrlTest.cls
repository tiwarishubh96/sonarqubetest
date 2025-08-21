/**
 * Test Class for the Zuora New Quote Lex Component Action
 */ 
@isTest
public with sharing class zuora_newQuoteCTrlTest {
    
    @TestSetup
    static void makeData(){
        locale__c loc = new locale__c(Name='Locl1',LanguageLocaleKey__c='en_GB',Language__c='English');
        insert loc;
        Account account = new Account(Name='TestAcc',Locale__c=loc.id);
        insert account;
        Date nowD = Date.today();
        Opportunity opp1 = new Opportunity(Name='MyOpp1',AccountId=account.id,Type='New Business',Referral_Date__c=nowD.addDays(-2),StageName='Closed Won',CloseDate=nowD);
        insert opp1;
    }

    @isTest
    public static void testGetOpportunity(){
        Opportunity opp = [Select Id from Opportunity where Name = 'MyOpp1'];
        System.assert(opp != null);
        
        Opportunity opp2 = zuora_newQuoteCTrl.getOpportunity(opp.Id);
        System.assert(opp2 != null);
    }
    @isTest
    public static void testGetOpportunity_Error(){
        try{
            Opportunity opp2 = zuora_newQuoteCTrl.getOpportunity(null);
            //force a fail if it gets here
            System.assert(false);
        }catch(AuraHandledException aex){
            System.assert(aex != null);
        }
        
       
    }    
}