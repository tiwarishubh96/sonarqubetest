/*-------------------------------------------------------------
    Author:         Veni
    Date :          05/15/2017
    Company:       
    Description:    This class is used to schedule SPPCommissionBatch class
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
global class SPPCommissionBatchSchedule implements Schedulable 
{
    // Usage example: System.schedule('ScheduleSPPCommissionBatch', '0 40 12 * * ?', new ScheduleSPPCommissionBatch());
    
    global static Integer RUNNING_BATCH_LIMIT=4;
    global static Integer WAIT_MINUTES=1;
    
    public static String CRON_EXP = '0 0 3 * * ?';  // Run every day at 3am

    public SPPCommissionBatchSchedule() 
    {
    }
    
    global void execute(SchedulableContext sc) 
    {
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        // if there are a few batch jobs already running then delay scheduling the batch for a minute
        if (runningJobs >= RUNNING_BATCH_LIMIT) 
        {
            // Re-schedule ourself to run again in WAIT_MINUTES time
            scheduleAgain();
        }
        else
        {    
             //query to fetch Completely Paid Invoices/orders
            SPPCommissionBatch batch_obj = new SPPCommissionBatch('Select Commission_Payable__c,CurrencyISOCode,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Id from SPP_RR_Order__c where Invoiced__c = false and SPP_AP_Commission__c=null and Commission_Payable__c > 0');
            Database.executeBatch(batch_obj, 25);
     
        }
    }
    
    public void scheduleAgain() 
    {
            DateTime now = DateTime.now();
            DateTime nextRunTime = now.addMinutes(WAIT_MINUTES);
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' '+ nextRunTime.hour() + ' ' 
            + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
            String schedJobNameUnique = SPPCommissionBatchSchedule.class.getName()
            + '-' + nextRunTime.year()+nextRunTime.month()+nextRunTime.day()+nextRunTime.hour()+nextRunTime.minute()+nextRunTime.second();
            system.schedule(schedJobNameUnique, cronString, new SPPCommissionBatchSchedule());
    }
}