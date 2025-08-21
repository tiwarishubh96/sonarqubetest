global class scheduledBatchableCallItems implements Schedulable {
   global void execute(SchedulableContext sc) {
      callItemActiveDeactivateBatch b = new callItemActiveDeactivateBatch(); 
      database.executebatch(b,100);
   }
}