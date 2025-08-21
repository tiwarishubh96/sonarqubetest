global class ScheduleFailedInvoiceItem implements Schedulable {
    // Usage example: System.schedule('ScheduleFailedInvoiceItem', '0 40 12 * * ?', new ScheduleFailedInvoiceItem());
    //
    global static Integer RUNNING_BATCH_LIMIT=4;    // https://help.salesforce.com/apex/HTViewSolution?id=000182449
    global static Integer WAIT_MINUTES=1;
    
    public static String CRON_EXP = '0 0 3 * * ?';  // Run every day at 3am

    public ScheduleFailedInvoiceItem() {
    }
    
    global void execute(SchedulableContext sc) {
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        // if there are a few batch jobs already running then delay scheduling the batch for a minute
        if (runningJobs >= RUNNING_BATCH_LIMIT) {
            // Re-schedule ourself to run again in WAIT_MINUTES time
            scheduleAgain();
        }else{    
            FailedInvoiceItemBatch batch_obj = new FailedInvoiceItemBatch('select Id, Name, Zuora__Invoice__c, Zuora__Invoice__r.Zuora__Zuora_Id__c, Zuora__GatewayResponse__c from Zuora__Payment__c where Zuora__Status__c=\'Error\' and Error_Processed__c=false');
            Database.executeBatch(batch_obj, 25);

            //Schedule for batch sepa failed transaction
            SepaFailedInvoiceItemBatch batch_obj1 = new SepaFailedInvoiceItemBatch('SELECT Id, Zuora__Account__c,Name,Zuora__Amount__c,Zuora__GatewayResponseCode__c,Zuora__GatewayResponse__c,Zuora__Payment__c, Zuora__PaymentMethod__c,Zuora__Status__c FROM Zuora__Refund__c Where Zuora__ReasonCodeName__c = \'Payment Rejection\' and Error_Processed__c = false');
            Database.executeBatch(batch_obj1, 25);

          
        }
    }
    
    public void scheduleAgain() {
        DateTime now = DateTime.now();
            DateTime nextRunTime = now.addMinutes(WAIT_MINUTES);
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' '+ nextRunTime.hour() + ' ' 
                + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
            String schedJobNameUnique = ScheduleFailedInvoiceItem.class.getName()
                + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
        System.schedule(schedJobNameUnique, cronString, new ScheduleFailedInvoiceItem());
    }
}