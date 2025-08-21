/******************************************************************************
	Author 		: Rani Thumma
	Company 	: Docmation
	Date        : 6/12/2017
	Description : Calss to Schedule SPP MQ Events clean up batch 
*******************************************************************************/
global class SPPMQEventsCleanupScheduler implements Schedulable 
{
    global static Integer RUNNING_BATCH_LIMIT = 4;    
    global static Integer WAIT_MINUTES = 1;
    public static String CRON_EXP = '0 0 23 * * ?';  // Run every day at 12pm
    
    global void execute(SchedulableContext sc) 
    {	 
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
       	if (runningJobs >= RUNNING_BATCH_LIMIT) {
            // Re-schedule ourself to run again in WAIT_MINUTES time
            scheduleAgain();
        }else{    
            Database.executeBatch(new SPPMQEventsCleanUpBatch());
        }
	}
    public void scheduleAgain() {
        DateTime now = DateTime.now();
        DateTime nextRunTime = now.addMinutes(WAIT_MINUTES);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' '+ nextRunTime.hour() + ' ' 
                + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        String schedJobNameUnique = SPPMQEventsCleanupScheduler.class.getName()
                + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new SPPMQEventsCleanupScheduler());
    }
}