@isTest
private class caseTriggerHandlerTest {
    
    // NEGATIVE TEST - Test that when toaddress IS NOT UQUAL TO 'sagepeoplesupport@Sage.com' the   
    // Product__c field is NOT set to 'Sage People'
    
    @isTest static void negative_Test() {
        // Creation of a Case
        case emailCase = new Case(
            subject = 'Testing Email to Case Negative'
        );
        insert emailCase;                                       
        //Creation of Email Message related to Case
        emailMessage em = new emailMessage(
            parentId = emailCase.Id,
            Incoming = TRUE,
            toaddress = 'sagepeopl@Sage.com'
        );
        insert em;
        //Create Case Map of the test case
        Map<Id,Case> caseMap = new Map<Id,Case>([SELECT Id FROM Case]);
        //Call setCaseProductField Method
        caseTriggerHandler.setCaseProductField(caseMap);
        //System.Assert - Check Case IS NOT Updated as Expected
        emailCase = [SELECT Id, Product__c FROM Case WHERE Id = :emailCase.Id];
        system.assertNotEquals('Sage People',emailCase.Product__c);
    }
    /*
    REMOVED as part of the Case trigger refactoring work EAD-2431
    @isTest static void communitySharingRules() {
        
        
        Locale__c locale = DataFactoryForTesting.createLocale();
        DataFactoryForTesting.createPartnerCommunityLocaleMapping();
        Account a = DataFactoryForTesting.createAccountWithLoc(locale.Id);
        //User adminuser = DataFactoryForTesting.createAdminUser();
        //insert adminuser;
        Contact c1 = DataFactoryForTesting.createContact(a.Id);
        User u1 =  DataFactoryForTesting.createUser(c1.Id);
        insert u1;
        
        System.runAs(u1) {
            
            Test.startTest();
            Case newCase = DataFactoryForTesting.createCase(c1);
            Test.stopTest();
            
            UserRole role = [SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId, PortalType, PortalRole,PortalAccountOwnerId FROM UserRole where PortalAccountId = :a.Id][0];
            Group g = [Select Name, DeveloperName, RelatedId, Id, Type FROM Group where RelatedId = :role.Id and Type = 'RoleAndSubordinates'][0];
            
			CaseShare share = [Select Id, CaseAccessLevel from CaseShare where CaseId = :newCase.Id and UserOrGroupId = :g.Id][0];
	        System.assertEquals('Edit', share.CaseAccessLevel);
        }
        
    }
*/
    
    @IsTest static void caseclosetask() {
        
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com');
        insert testCon;
        
        Case testCase = new Case(Type = 'Problem', ContactId = testCon.Id, Case_Category__c = 'Accounting/Payroll - Bank', Case__c = 'Accounting - Transfer', Status = 'Service - Work In Progress', Priority = 'Medium', Origin = 'Phone', Subject = 'Test Case');
        insert testCase;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='testsage@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testsage@testorg.com');
        
        insert u;
        
        Task tsk = new Task(Status='In Progress', Priority='Normal', whatId= testCase.id, Subject = 'Test Task', Type = 'Other', Ownerid = u.Id);
        insert tsk;
        
        testCase.Status = 'Partner - Pending';
        update testCase;
        
    }
    // Test method for the Case Retrive Solution funtionality
    static testMethod void testCaseRetriveSolution() { 
        
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
            List<case> caselist = new List<case>{c1};
                system.debug(caselist);
            Case_Helper.updateCaseRetriveSolution(caselist);
            // create another solution
            ra = new RightAnswersAttached__c ();
            ra.CaseSubject__c = 'Test Solution4';
            ra.Solution_ID__c = '12345';
            ra.Solution_Text__c = 'Test text';
            ra.Solution_Title__c ='Test title';
            ra.Date_Time__c = DateTime.now();
            insert ra;
            
            ra.CaseSubject__c = 'Test Solution5';
            update ra;
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
            // System.assertEquals(0,[Select count() from RightAnswersAttached__c where Id=:ra.Id and CaseNumber__c = null]);
            System.assertEquals(0,[Select count() from RightAnswersAttached__c where CaseNumber__c = :c4.Id]);
            
        } // System.runAs
        
    } // myTestClass
    
    static testMethod void testCaseRnRSurvey() { 
        /*Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
insert testAcc;

Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com');
insert testCon;

Case testCase = new Case(Type = 'Problem', ContactId = testCon.Id, Case_Category__c = 'Accounting/Payroll - Bank', Case__c = 'Accounting - Transfer', Status = 'Service - Work In Progress', Priority = 'Medium', Origin = 'Phone', Subject = 'Test Case');
insert testCase;*/
        Profile p = [SELECT Id FROM Profile WHERE Name='Sage: Global Services User']; 
        UserRole r = [SELECT Id FROM UserRole WHERE Name='EU Customer Service Analyst']; 
        User u = new User(Alias = 'sttrnr', Email='testsagernrsurvey@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testsagernrsurvey@testorg.com',UserRoleId=r.Id);
        
        insert u;
        system.runAs(u){
            //Case testCase=[select id,status from case limit 1];
            Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
            insert testAcc;
            
            Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com');
            insert testCon;
            
            Case testCase = new Case(Type = 'Problem', ContactId = testCon.Id, Case_Category__c = 'Accounting/Payroll - Bank', Case__c = 'Accounting - Transfer', Status = 'Service - Work In Progress', Priority = 'Medium', Origin = 'Phone', Subject = 'Test Case');
            insert testCase;
            testCase.Status = 'Closed';
            /*testcase.origin=
testCase.category =
testCase.subcategory=
testCase.type =*/
            update testCase;
        }
    }
    
    
    static testMethod void testHasRightAnswers() { 
        // create a case        
        Case c=new Case();
        c.Subject='Test Case1';
        insert c;
        // create a solution
        RightAnswersAttached__c ra =new RightAnswersAttached__c ();
        ra.CaseNumber__c = c.Id;
        ra.CaseSubject__c = 'FSA plan';
        ra.Solution_ID__c = '120521081227160';
        ra.Solution_Text__c = 'Is anyone excluded from participating in the FSA plan? For full SA solution see - http://design3.rightanswers.com:8080/paychex_portal/app/portlets/results/viewsolution.jsp?interface=sa&solutionid=120521081227160 For full SS solution see - http://design3.rightanswers.com:8080/paychex_portal/app/portlets/results/viewsolution.jsp?solutionid=120521081227160&isguest=true';
        ra.Solution_Title__c ='Is anyone excluded from participating in the FSA plan?';
        ra.Solution_URL__c ='https://integration.rightanswers.com/portal_dev8/app/portlets/results/viewsolution.jsp?solutionid=120521081227160&isguest=true';
        ra.Date_Time__c = DateTime.now();
        insert ra;
        /*List<RightAnswersAttached__c> raList = new List<RightAnswersAttached__c>();
        raList.add(ra);
        insert raList;*/
        Map<ID,RightAnswersAttached__c> newItems = new Map<ID,RightAnswersAttached__c>();
        newItems.put(ra.id,ra);
        RightAnswersHelper.updatehasRightAnswer(newItems);
        RightAnswersHelper.updatehasRightAnswerto0(newItems);
        
        UpdateCaseRightAnswersBatch uca = new UpdateCaseRightAnswersBatch();
        Id batchId = Database.executeBatch(uca,500);
        system.debug('batchID'+batchID);
        /*ra.CaseSubject__c = 'Test Solution5';
        update ra;
        delete ra;*/
    } // myTestClass
    
}