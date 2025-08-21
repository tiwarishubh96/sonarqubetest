@isTest
public class SPPScheduleAccountSyncBatchTest {
    public static testmethod void testScheduleJod()
    {
        Test.startTest();
        String jobId = System.schedule('SPPScheduleAccountSyncBatch', SPPScheduleAccountSyncBatch.CRON_EXP, 
                        new SPPScheduleAccountSyncBatch());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(SPPScheduleAccountSyncBatch.CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        Integer schJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1, schJobs);
    }
    
    public static testMethod void testScheduleAgain() 
    {
        Test.startTest();
        
        SPPScheduleAccountSyncBatch sched = new SPPScheduleAccountSyncBatch();
        sched.scheduleAgain();
        
        Test.stopTest();  
        Integer schJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1, schJobs);
    }
}