/*
 * Class Name :- BomboraAccountforCustomCategories_Test
 * Author :- Bob Lin
 * Created Date :- 07-04-2020
 * Description : This class test class of BomboraSchedulerCustomCategories_Account and BomboraCustomCategoriesBatch_Account.
 * 
 // ********************Change Logs *****************************************************************************************************************************
 */

 @isTest
 public class BomboraAccountforCustomCategories_Test {
     static Recordtype rts = [SELECT Id, Name FROM RecordType WHERE NAme = 'Standard Account' LIMIT 1];
     static testMethod void BomboraAccountScheduler_Test() {
         Test.startTest();
         BomboraSchedulerCustomCategories_Account sched = new BomboraSchedulerCustomCategories_Account();
         System.schedule('Schedule BomboraSchedulerCustomCategories_Account', '0 48 * * * ?',sched);
         Test.stopTest();
         Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
         system.assertEquals(1,runningJobs);
     }
    
     static testMethod void BomboraAccountScheduler_Test2() {
         Test.startTest();
         BomboraSchedulerCustomCategories_Account sched = new BomboraSchedulerCustomCategories_Account();
         sched.scheduleAgain();
         Test.stopTest();
         Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
         system.assertEquals(1,runningJobs);
     }
     
     static testMethod void BomboraLeadBatch_Test(){
        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingState='Avon',BillingCity='Alphareeta',BillingStreet='street');
        insert acc;
         
        List<bombora_app__BomboraCustomObject__c> testBomboraSurges = new List<bombora_app__BomboraCustomObject__c>();
        bombora_app__BomboraCustomObject__c testSurge = new bombora_app__BomboraCustomObject__c();
        testSurge.bombora_app__Category__c = 'Accounting';
        testSurge.bombora_app__DateStamp__c= System.now().format('yyyyMMdd');
        testSurge.bombora_app__CompositeScore__c = 60;
        testSurge.bombora_app__Account__c = acc.id;
        insert testSurge;

        bombora_app__BomboraCustomObject__c testSurgeTwo = new bombora_app__BomboraCustomObject__c();
        testSurgeTwo.bombora_app__DateStamp__c= System.now().format('yyyyMMdd');
        testSurgeTwo.bombora_app__CompositeScore__c = 70;
        testSurgeTwo.bombora_app__Category__c = 'HR';
        testSurgeTwo.bombora_app__Account__c = acc.id;
        insert testSurgeTwo;

		Datetime dateLimit = System.now().Adddays(-6);
            
        String query = 'Select Id FROM Account WHERE Id IN (SELECT bombora_app__Account__c FROM bombora_app__BomboraCustomObject__c where LastModifiedDate > :dateLimit)';

        Test.startTest();    
        BomboraCustomCategoriesBatch_Account batchJob = new BomboraCustomCategoriesBatch_Account(query, dateLimit);
        Database.executeBatch(batchJob, 200);
        Test.stopTest();
     }
 }