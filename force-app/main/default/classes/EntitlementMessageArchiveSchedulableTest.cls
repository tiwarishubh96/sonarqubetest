/**
* Tests for EntitlementMessageArchiveSchedulable class
*/
@isTest
public class EntitlementMessageArchiveSchedulableTest {
/**
 * Test: running invoiceItemArchiveSchedulable gets scheduled
 */
    static {
        CleanUpSetting__c cus=new CleanUpSetting__c(Name='EntitlementMessageArchiveSchedulable',Archive_Before_Days__c=10);
        insert cus;
    }
    static testmethod void testInvoiceSchedulable() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('CleanUpTest.testCleanUpSchedulable', EntitlementMessageArchiveSchedulable.CRON_EXP, new EntitlementMessageArchiveSchedulable());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(EntitlementMessageArchiveSchedulable.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('03:00:00'));
        //
        //check here - batch has not run yet
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(0,runningJobs);
        
        Test.stopTest();	// forces schedule to run
        //
        // batch has started - but will complete after this test.
        runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1,runningJobs);
    }
    /**
     * Test: scheduleAgain method execution
     */
    static testMethod void testScheduleAgain() {
        Test.startTest();
        EntitlementMessageArchiveSchedulable sched=new EntitlementMessageArchiveSchedulable();
        sched.scheduleAgain();
        Test.stopTest();	// forces schedule to run
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1,runningJobs);
    }

}