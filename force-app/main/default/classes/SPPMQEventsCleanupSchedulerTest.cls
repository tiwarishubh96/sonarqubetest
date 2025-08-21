@istest
public class SPPMQEventsCleanupSchedulerTest 
{
    public static testmethod void testScheduleJod()
    {
        Test.startTest();
        String jobId = System.schedule('SPPMQEventsCleanupScheduler', SPPMQEventsCleanupScheduler.CRON_EXP, 
                        new SPPMQEventsCleanupScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(SPPMQEventsCleanupScheduler.CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        Integer schJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1, schJobs);
    }
    
    public static testMethod void testScheduleAgain() 
    {
        Test.startTest();
        
        SPPMQEventsCleanupScheduler sched = new SPPMQEventsCleanupScheduler();
        sched.scheduleAgain();
        
        Test.stopTest();  
        Integer schJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(1, schJobs);
    }
}