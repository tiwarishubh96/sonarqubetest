/**
 * @description Invoice Line Item archive schedule job
 * Usage example: System.schedule('InvoiceItemArchiveSchedulable', '0 40 12 * * ?', new InvoiceItemArchiveSchedulable());
 * - Ensure custom setting CleanUpSetting has an entry for this class.
 * @author Richard Wintle
 */
global class InvoiceItemArchiveSchedulable implements Schedulable {
    //
    global static Integer RUNNING_BATCH_LIMIT=4;    // https://help.salesforce.com/apex/HTViewSolution?id=000182449
    global static Integer WAIT_MINUTES=1;
    //
    // clean-up setup values
    global static String CLEAN_UP_OBJECT='Invoice_Line_Item__c';
    global static String CLEAN_UP_REFERENCE='InvoiceLineItemArchive';
    
    public static String CRON_EXP = '0 0 3 * * ?';	// Run every day at 3am

    /**
     * execute job batch. Schedule again logic if batch queue full.
     * @param context
     */
	global void execute(SchedulableContext sc) {
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        // if there are a few batch jobs already running then delay scheduling the batch for a minute
        if (runningJobs >= RUNNING_BATCH_LIMIT) {
            // Re-schedule ourself to run again in WAIT_MINUTES time
            scheduleAgain();
        }else{    
            CleanUpSetting__c cleanUpSetting=CleanUpSetting__c.getInstance('InvoiceItemArchiveSchedulable');
            Decimal beforeDays=(cleanUpSetting.Archive_Before_Days__c>0 ? cleanUpSetting.Archive_Before_Days__c * -1 : cleanUpSetting.Archive_Before_Days__c);
            Datetime beforeDate=Date.today().addDays(Integer.valueOf(beforeDays)); 
            String query='select Id from '+CLEAN_UP_OBJECT+' where CreatedDate < '+beforeDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
            system.debug('query:'+query);
            CleanUpBatch batch_obj = new CleanUpBatch(query, CLEAN_UP_OBJECT, CLEAN_UP_REFERENCE);
            Database.executeBatch(batch_obj, 25);
        }
	}
    /**
     * Schedule again in a minute (WAIT_MINUTES) when batch queue full
     */
    public void scheduleAgain() {
        DateTime now = DateTime.now();
            DateTime nextRunTime = now.addMinutes(WAIT_MINUTES);
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' '+ nextRunTime.hour() + ' ' 
                + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
            String schedJobNameUnique = InvoiceItemArchiveSchedulable.class.getName()
                + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new InvoiceItemArchiveSchedulable());
    }
}