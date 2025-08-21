trigger CaseRetriveSolution on Case(after insert) {
   
   // we only want to fire this trigger if this is a single case transaction. If this is a bulk transaction, we can skip this trigger
   // also - this is dependent on the assumption that the Analyst will retrieve solutions into and save the case 1 new case at a time.   
   if( Trigger.new.size() == 1){
      // get the case
      Case c = Trigger.new[0];
      // find any solutions that were created by this user and are not currently attached to a case
      for (List<RightAnswersAttached__c> sols : [select Id, CaseSubject__c, CaseNumber__c from RightAnswersAttached__c where OwnerId = :UserInfo.getUserId() and CaseNumber__c = null]) {
         if (!sols.isEmpty()) {
            // attach all of the solutions to the case
            for (RightAnswersAttached__c raa : sols) {
                if (raa.CaseSubject__c == c.Subject)
                {    
                   raa.CaseNumber__c = c.Id;
                   raa.Date_Time__c = DateTime.now();
                }
            }

            update sols;
         } // if (!sols.isEmpty
      } // for
      
   } // if Trigger.new.size() == 1
   
} // trigger CaseRetriveSolution