/*
* Class Name :- BomboraSchedulerCustomCategories_Account
* Author :- Bob Lin
* Created Date :- 07-04-2020
* Description : This class is for populating the custom HR and Finance category Bombora fields on Account.
*               This scheduled class should run every monday after Bombora's own scheduled data integration is finished. 
* 
// ********************Change Logs *****************************************************************************************************************************
*/

global class BomboraSchedulerCustomCategories_Account implements Schedulable {
    global static Integer RUNNING_BATCH_LIMIT=4;    // https://help.salesforce.com/apex/HTViewSolution?id=000182449
    global static String UPDATE_OBJECT='Account';    
    global static Integer WAIT_MINUTES=1;
    //public static String CRON_EXP = '0 0 * * 0 ?';  // Run every week on sunday
    
    global void execute(SchedulableContext sc) {    
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        // if there are a few batch jobs already running then delay scheduling the batch for a minute
        if (runningJobs >= RUNNING_BATCH_LIMIT) {
            // Re-schedule ourself to run again in WAIT_MINUTES time
            scheduleAgain();
        }else{  
            String DAYS_BUFFER = Label.Bombora_Custom_Categories_Batch_Days_Buffer;
            
			Integer bufferDay = integer.valueof(DAYS_BUFFER) * -1;
			Datetime dateLimit = System.now().Adddays(bufferDay);
            
            String query = 'Select Id FROM '+UPDATE_OBJECT+' WHERE Id IN (SELECT bombora_app__Account__c FROM bombora_app__BomboraCustomObject__c where LastModifiedDate > :dateLimit)';
            
            BomboraCustomCategoriesBatch_Account batchJob = new BomboraCustomCategoriesBatch_Account(query, dateLimit);
            Database.executeBatch(batchJob, 200);
        }    
    }
    
    public void scheduleAgain() {
        DateTime now = DateTime.now();
        DateTime nextRunTime = now.addMinutes(WAIT_MINUTES);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' '+ nextRunTime.hour() + ' ' 
            + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        String schedJobNameUnique = BomboraSchedulerCustomCategories_Account.class.getName()
            + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new BomboraSchedulerCustomCategories_Account());
    }
}