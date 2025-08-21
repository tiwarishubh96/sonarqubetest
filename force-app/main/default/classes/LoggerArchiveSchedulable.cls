/**
 * @description Logger archive schedule job
 * Usage example: System.schedule('LoggerArchiveSchedulable', '0 40 12 * * ?', new LoggerArchiveSchedulable());
 * - Ensure custom setting CleanUpSetting has an entry for this class name
 * - the field "Archive Before Days" indicates how many days of the most recent records should be preserved
 * - setting this to zero will empty the Logger__c table (though the cleanup job will create its own log)
 * @author Pete Wilson
 */
global class LoggerArchiveSchedulable implements Schedulable {
    global static Integer RUNNING_BATCH_LIMIT = 4;
    global static Integer WAIT_MINUTES = 1;
    // clean-up setup values
    global static String CLEAN_UP_OBJECT = 'Logger__c';
    global static String CLEAN_UP_REFERENCE = 'LoggerArchive';

    /**
     * execute job batch. Schedule again logic if batch queue full.
     * @param context
     */
	global void execute(SchedulableContext sc) {
        Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        // if there are a few batch jobs already running then delay scheduling the batch for a minute
        if (runningJobs >= RUNNING_BATCH_LIMIT) {
            // Re-schedule to run again in WAIT_MINUTES time
            scheduleAgain();
        } else {
            CleanUpSetting__c cleanUpSetting = CleanUpSetting__c.getInstance('LoggerArchiveSchedulable');
            // quit without purge if custom setting entry not found
            if (cleanUpSetting == null) {
                System.debug('Custom setting not found - exiting without deleting records');
                return;
            }
            Decimal beforeDays = (cleanUpSetting.Archive_Before_Days__c > 0 ? cleanUpSetting.Archive_Before_Days__c * -1 : cleanUpSetting.Archive_Before_Days__c);
            String query = 'SELECT Id FROM ' + CLEAN_UP_OBJECT;
            if (beforeDays != 0) {
                query += ' WHERE CreatedDate != LAST_N_DAYS:' + (Integer)cleanUpSetting.Archive_Before_Days__c;
            }
            System.debug('Query records for deletion: ' + query);
            CleanUpBatch batch_obj = new CleanUpBatch(query, CLEAN_UP_OBJECT, CLEAN_UP_REFERENCE);
            Database.executeBatch(batch_obj, 25);
        }
	}

    /**
     * Schedule again in a minute (WAIT_MINUTES) when batch queue full
     * All Cron parameters are specified without wildcards to ensure only a single additional run is scheduled
     */
    public void scheduleAgain() {
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(WAIT_MINUTES);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' '
                + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        String schedJobNameUnique = LoggerArchiveSchedulable.class.getName()
                + '-' + nextRunTime.year() + nextRunTime.month() + nextRunTime.day() + nextRunTime.hour() + nextRunTime.minute() + nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new LoggerArchiveSchedulable());
    }
}