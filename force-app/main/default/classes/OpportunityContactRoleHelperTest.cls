/**
 * @author          Pete Wilson
 * @date            24 July 2020
 * @description     Check Primary Contact lookup on Opportunity is maintained for insertions, updates, deletions
 */
@isTest
public class OpportunityContactRoleHelperTest {
    static string CLASSNAME = 'OpportunityContactRoleHelperTest';
    
    @TestSetup
    static void dataSetup() {
        Account acc = new Account(Name='testAccount', Type='Customer', BillingCountry='United Kingdom', 
                                  BillingCity='Blyth', BillingStreet='Salisbury Street');
        insert acc;
        Contact con1 = new Contact(FirstName='Roger', LastName='Hunt', Email='roger.hunt@test.com.donotcall', AccountId=acc.Id);
        Contact con2 = new Contact(FirstName='Bobby', LastName='Charlton', Email='bobby.charlton@test.com.donotcall', AccountId=acc.Id);
        Contact con3 = new Contact(FirstName='Martin', LastName='Peters', Email='martin.peters@test.com.donotcall', AccountId=acc.Id);
        List<Contact> cons = new List<Contact>{con1,con2,con3};
        insert cons;
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Medium - Standard Opportunity'];
        Opportunity opp = new Opportunity(Name='o1', AccountId=acc.Id, StageName='Qualify',
                                          CloseDate=System.today() + 20, RecordTypeId=rt.Id, Lead_Source__c='Marketing');
        insert opp;
        OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId=con1.Id,OpportunityId=opp.Id,IsPrimary=false,Role='Other');
        OpportunityContactRole ocr2 = new OpportunityContactRole(ContactId=con2.Id,OpportunityId=opp.Id,IsPrimary=false,Role='Other');
        List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>{ocr1,ocr2};
        insert ocrs;
    }
    
    @IsTest
    static void testPrimaryContact() {
        System.debug(CLASSNAME + ': testPrimaryContact START');
        Opportunity opp = [SELECT Id, Primary_Contact__c,Email__c FROM Opportunity LIMIT 1];
        Contact con2 = [SELECT Id, Email FROM Contact WHERE FirstName = 'Bobby' LIMIT 1];
        Contact con3 = [SELECT Id, Email FROM Contact WHERE FirstName = 'Martin' LIMIT 1];
        OpportunityContactRole ocr3 = new OpportunityContactRole(ContactId=con3.Id,OpportunityId=opp.Id,IsPrimary=true,Role='Other'); 
        Test.startTest();
        System.assertEquals(null,opp.Primary_Contact__c);
         System.assertEquals(null,opp.Email__c);
        insert ocr3;
        opp = [SELECT Id, Primary_Contact__c,Email__c FROM Opportunity LIMIT 1];
        System.assertEquals(con3.Id,opp.Primary_Contact__c);
        System.assertEquals(con3.Email,opp.Email__c);
        OpportunityContactRole ocr2 = [SELECT Id, IsPrimary FROM OpportunityContactRole WHERE ContactId = :con2.Id LIMIT 1];
        ocr2.isPrimary = true;
        update ocr2;
        opp = [SELECT Id, Primary_Contact__c,Email__c FROM Opportunity LIMIT 1];
        System.assertEquals(con2.Id,opp.Primary_Contact__c);
        System.assertEquals(con2.Email,opp.Email__c);
        
        delete ocr2;
        opp = [SELECT Id, Primary_Contact__c,Email__c FROM Opportunity LIMIT 1];
        System.assertEquals(null,opp.Primary_Contact__c);
        System.assertEquals(null,opp.Email__c);
        
        System.debug(CLASSNAME + ': testPrimaryContact FINISH');
    }
}