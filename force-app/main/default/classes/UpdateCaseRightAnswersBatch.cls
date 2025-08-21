global class UpdateCaseRightAnswersBatch implements  Database.Batchable<sObject> {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select ID,CaseNumber__c from RightAnswersAttached__c where CaseNumber__c !=NULL ');
    }
    global void execute(Database.BatchableContext bc, List<RightAnswersAttached__c> scope){
        //Map<ID,Case> mapdata = new Map<ID,Case>();
        //SELECT ID,hasRightAnswer__c From Case
        /*for(Case c:[select ID,hasRightAnswer__c from Case where ID IN ]){
            c.hasRightAnswer__c=0;
        }
        if(scope.size() > 0){
            Update scope;
        }//end of notfication size check*/
        Map<ID,RightAnswersAttached__c> newItems = new Map<ID,RightAnswersAttached__c>();
        for(RightAnswersAttached__c r:scope){
            newItems.put(r.id,r);
        }
        RightAnswersHelper.updatehasRightAnswer(newItems);
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        system.debug('@@job@@'+job);
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }    
}