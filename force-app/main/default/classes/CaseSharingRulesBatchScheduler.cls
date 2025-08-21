global class CaseSharingRulesBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      CaseSharingRulesBatch sharingBatch = new CaseSharingRulesBatch(); 
      database.executebatch(sharingBatch,50);
   }
}