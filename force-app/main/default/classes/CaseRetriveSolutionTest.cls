@isTest
private class CaseRetriveSolutionTest{

   static testMethod void myTestClass() { /*
        
      // select a user to run the test - select a system admin
      User u1 = [Select Id, Name from User where IsActive=true and Profile.Name='System Administrator' limit 1];
      
      // so the variable is outside of the runAs scope
      RightAnswersAttached__c ra = null;
      
         // create a case        
         Case c=new Case();
         c.Subject='Test Case1';
         insert c;
      
      System.runAs(u1) {
         // create a solution
         ra=new RightAnswersAttached__c ();
         ra.CaseNumber__c = c.Id;
         ra.CaseSubject__c = 'FSA plan';
         ra.Solution_ID__c = '120521081227160';
         ra.Solution_Text__c = 'Is anyone excluded from participating in the FSA plan? For full SA solution see - http://design3.rightanswers.com:8080/paychex_portal/app/portlets/results/viewsolution.jsp?interface=sa&solutionid=120521081227160 For full SS solution see - http://design3.rightanswers.com:8080/paychex_portal/app/portlets/results/viewsolution.jsp?solutionid=120521081227160&isguest=true';
         ra.Solution_Title__c ='Is anyone excluded from participating in the FSA plan?';
         ra.Solution_URL__c ='https://integration.rightanswers.com/portal_dev8/app/portlets/results/viewsolution.jsp?solutionid=120521081227160&isguest=true';
         ra.Date_Time__c = DateTime.now();
         insert ra;

         // verify the solution is attached to the case
         System.assertEquals(1,[Select count() from RightAnswersAttached__c where CaseNumber__c = :c.Id]);
         
         // create another solution
         ra = new RightAnswersAttached__c ();
         ra.CaseSubject__c = 'Test Solution';
         ra.Solution_ID__c = '12345';
         ra.Solution_Text__c = 'Test text';
         ra.Solution_Title__c ='Test title';
         ra.Date_Time__c = DateTime.now();
         insert ra;
         
         // create multiple cases. The solution should not attach to either of the cases - we should not process bulk transactions
         Case c1 = new Case(Subject='Test Case2');
         Case c2 = new Case(Subject='Test Case3');
         Case[] cases = new Case[]{c1,c2};
         insert cases;
         
         // verify the solution is unattached
         System.assertEquals(1,[Select count() from RightAnswersAttached__c where Id=:ra.Id and CaseNumber__c = null]);
         
         // create another solution
         ra = new RightAnswersAttached__c ();
         ra.CaseSubject__c = 'Test Solution4';
         ra.Solution_ID__c = '12345';
         ra.Solution_Text__c = 'Test text';
         ra.Solution_Title__c ='Test title';
         ra.Date_Time__c = DateTime.now();
         insert ra;
         
         // create multiple cases. The solution should not attach to either of the cases - we should not process bulk transactions
         Case c3 = new Case(Subject='Test Solution4');
         insert c3;
         
         // verify the solution is unattached
         for (List<RightAnswersAttached__c> sols : [Select CaseSubject__c from RightAnswersAttached__c where CreatedById=:u1.Id and CaseNumber__c = null]){
         
           if (!sols.isEmpty()) {
            // attach all of the solutions to the case
            for (RightAnswersAttached__c raa : sols) {
            //System.Debug(raa.CaseSubject__c+'=='+c.Subject);

                if (raa.CaseSubject__c == c3.Subject)
                {
                     System.assertEquals(1,1);
                }

              }
            
            }
            else
            {
                System.assertEquals(1,0);
            }
          }

      } // System.runAs
      
      // get another user. Verify that if a case is created by someone else that someone else's solution isn't attached.
      User u2 = [Select Id, Name from User where IsActive=true and Profile.Name='System Administrator' and Id != :u1.Id limit 1];
      System.runAs(u2) {
         Case c4 = new Case(Subject='Test Case4');
         insert c4;
         
         // verify the solution created by the other user did not attach to this case
         System.assertEquals(0,[Select count() from RightAnswersAttached__c where Id=:ra.Id and CaseNumber__c = null]);
         System.assertEquals(0,[Select count() from RightAnswersAttached__c where CaseNumber__c = :c4.Id]);
      } // System.runAs
   */} // myTestClass
   
} // class CaseRetriveSolutionTest