/**
* Sage.
*
* @category  Batch
* @author    Ravi Yalamati
* @copyright 
* @license   
* @CreatedDate  07/10/2020 

*/

global class RnRRetrySurveyBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    private static final String CASE_QUERY = 'Select Id,contactId,Account.BillingCountry FROM Case where Is_Survey_Sent__c = true and Last_survey_sent_date__c = null';
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator(CASE_QUERY);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<Case> listOfCases){
        System.enqueueJob(new QueueClass(new Map<Id, Case>(listOfCases).keySet()));
    }
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        
        System.debug(LoggingLevel.INFO  + 'The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
    }
    
    public class QueueClass implements Queueable {
        Set<Id> recordids;
        public QueueClass(Set<Id> recordIds) {
            this.recordIds = recordIds;
        }
        public void execute(QueueableContext context) {
           List<Id> caseIds = new List<Id>();
            for(Id caseId : this.recordIds){
                caseIds.add(caseId);
            }
            RnRSurveyCallOutHelper.sendSurveyRnR(caseIds, new Map<Id,Case>());
            
            
        }
    }
    
}