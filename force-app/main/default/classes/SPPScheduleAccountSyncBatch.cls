/******************************************************************************
	Author 		: Rani Thumma
	Company 	: Docmation
	Date        : 6/12/2017
	Description : Calss to Schedule SPP Partner Account sync 
*******************************************************************************/
global class SPPScheduleAccountSyncBatch implements Schedulable 
{
    global static Integer RUNNING_BATCH_LIMIT = 4;    
    global static Integer WAIT_MINUTES = 1;
    public static String CRON_EXP = '0 30 0 * * ?';  // Run every 30 mins
    
	global void execute(SchedulableContext sc) 
    {		
       Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
       if (runningJobs >= RUNNING_BATCH_LIMIT) {
            // Re-schedule ourself to run again in WAIT_MINUTES time
            scheduleAgain();
        }else{    
            Database.executeBatch(new SPPAccountSyncBatch(), 100);
        }
	}
    public void scheduleAgain() {
        DateTime now = DateTime.now();
        DateTime nextRunTime = now.addMinutes(WAIT_MINUTES);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' '+ nextRunTime.hour() + ' ' 
                + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        String schedJobNameUnique = SPPScheduleAccountSyncBatch.class.getName()
                + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new SPPScheduleAccountSyncBatch());
    }
}