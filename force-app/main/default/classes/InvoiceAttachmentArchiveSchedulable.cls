/**
* @description Invoice Zuora PDF attachments archive schedule job
* Usage example: System.schedule('InvoiceAttachmentArchiveSchedulable', '0 40 12 * * ?', new InvoiceAttachmentArchiveSchedulable());
* - Ensure custom setting CleanUpSetting has an entry for this class.
* @author Richard Wintle
*/
global class InvoiceAttachmentArchiveSchedulable implements Schedulable {
    // 
    global static Integer RUNNING_BATCH_LIMIT=4;    // https://help.salesforce.com/apex/HTViewSolution?id=000182449
    global static Integer WAIT_MINUTES=1;
    //
    // clean-up setup values
    global static String CLEAN_UP_OBJECT='Attachment';
    global static String CLEAN_UP_REFERENCE='InvoiceAttachmentArchive';
    
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
            // batch run
            // set parameters
            CleanUpSetting__c cleanUpSetting=CleanUpSetting__c.getInstance('InvoiceAttachmentArchiveSchedulable');
            Decimal beforeDays=(cleanUpSetting.Archive_Before_Days__c>0 ? cleanUpSetting.Archive_Before_Days__c * -1 : cleanUpSetting.Archive_Before_Days__c);
            Datetime beforeDate=Date.today().addDays(Integer.valueOf(beforeDays)); 
            String query='select id from '+CLEAN_UP_OBJECT+' where parentId IN (select id from Zuora__ZInvoice__c where createdDate<'+beforeDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'')+
                ') and createdDate<'+beforeDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'')+' and name like \'invoice-%.pdf\'';
            system.debug('query:'+query);
            // run batch
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
        String schedJobNameUnique = InvoiceAttachmentArchiveSchedulable.class.getName()
            + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new InvoiceAttachmentArchiveSchedulable());
    }
}