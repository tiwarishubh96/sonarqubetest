/**
* Tests for InvoiceAttachmentArchiveSchedulable class
*/
@isTest
public class InvoiceAttachmentArchiveSchedulableTest {
/**
 * Test: running invoiceItemArchiveSchedulable gets scheduled
 */
    static {
        CleanUpSetting__c cus=new CleanUpSetting__c(Name='InvoiceAttachmentArchiveSchedulable',Archive_Before_Days__c=10);
        insert cus;
    }
    static testmethod void testInvoiceSchedulable() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('CleanUpTest.testCleanUpSchedulable', InvoiceAttachmentArchiveSchedulable.CRON_EXP, new InvoiceAttachmentArchiveSchedulable());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(InvoiceAttachmentArchiveSchedulable.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('03:00:00'));
        //
        //check here - batch has not run yet
        system.debug([SELECT id FROM AsyncApexJob WHERE JobType='BatchApex']);
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
        InvoiceAttachmentArchiveSchedulable sched=new InvoiceAttachmentArchiveSchedulable();
        sched.scheduleAgain();
        Test.stopTest();	// forces schedule to run
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1,runningJobs);
    }

}