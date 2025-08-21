@isTest
private class Test_TaskTriggerHandler {

    @TestSetup private static void setupData() {
        List<SObject> lDataInsert = new List<SObject>();

        lDataInsert.add(new Application_Control__c(SetupOwnerId = UserInfo.getOrganizationId()
                ,   Run_Triggers__c = true
        ));

        lDataInsert.add(new CBC_Application_Control__c(SetupOwnerId = UserInfo.getOrganizationId()
                ,   Run_Triggers__c = true
        ));
        lDataInsert.add(new Lead(
                    Country = 'United States'
                ,   FirstName = 'FirstName'
                ,   LastName = 'LastName'
                ,   Company = 'Test Company'
                ,   Status = 'New'
                ,   Lead_Source__c = 'Marketing'
                ,   Industry = 'Banking'
        ));

        Database.insert(lDataInsert);
    }

    private static testMethod void SuccessPlanTest() {
        Application_Control__c set1 = Application_Control__c.getOrgDefaults();
        set1.Run_Validation_Rules__c = false;
        try { upsert set1; } catch(Exception ex) { System.debug(LoggingLevel.Error, ex); }
        
        Account a = new Account();
        a.Name='testAccount';
        a.Sales_Office__c='Dublin CBC';
        a.Phone = '111';
        a.Type='Press';
        insert a;
        
        Success_plan__c sp = new Success_Plan__c();
        sp.name='Success';
        sp.Account__c=a.id;
        sp.Type__c='Renewal';
        insert sp;
        Task t = new Task();
        
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Type = 'Attempted Contact';
        t.Status = 'Completed';
        t.Call_Duration_Minutes__c=3;
        t.WhatId = sp.id;
        t.Description='test';
        
        insert t;
    }
    
    private static testMethod void OpportunityTest() {
        Application_Control__c set1 = Application_Control__c.getOrgDefaults();
        set1.Run_Validation_Rules__c = false;
        try { upsert set1; } catch(Exception ex) { System.debug(LoggingLevel.Error, ex); }
        
        Account a = new Account();
        a.name='testAccount';
        a.Sales_Office__c='Dublin CBC';
        a.Phone = '111';
        a.Type='Press';
        insert a;

        Opportunity op = new Opportunity();
        op.name='oppor';
        op.Account=a;
        op.Type='New Business';
        op.Lead_Source__c = 'Marketing';
        op.CloseDate=Date.today();
        op.StageName=Label.Opportunity_Sales_Stages_Stage1;
        op.ForecastCategoryName='Pipeline';
        insert op;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Type = 'Connected Call';
        t.Status = 'Completed';
        t.Call_Duration_Minutes__c=3;
        t.WhatId = op.id;
        t.Description='test';
        
        insert t;
    }
    
    public static testMethod void taskDueDateTimeTest(){
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Type = 'Connected Call';
        t.Status = 'Completed';
        t.Call_Duration_Minutes__c = 3;
        t.Description = 'test';
        t.DueDateTime__c = Date.today();
        t.Reminder__c = true;
       
        t.Description = 'description test description test description test description test ' +
            'description test description test description test description test description test description test';
        insert t;
        
        t = [   SELECT  Id
                    ,   ActivityDate
                FROM Task
                WHERE Id = :t.Id ];
               
        System.assertEquals(Date.today(), t.ActivityDate);
    }

    public static testMethod void callTaskDueDateTest(){
        // GIVEN
        Task newTask = new Task(
                OwnerId = UserInfo.getUserId()
            ,   Subject = 'Call Task'
            ,   Type = 'Connected Call'
            ,   Status = 'Completed'
            ,   Description = 'Description'
            ,   Reminder__c = true
            ,   CallObject = 'callIdentifierXXXXVVVVVVTTTTTTT'
        );

        // WHEN
        Test.startTest();
        Database.insert(newTask);
        Test.stopTest();

        // THEN
        System.assertEquals(Date.today()
                , [ SELECT Id, ActivityDate FROM Task WHERE CallObject = 'callIdentifierXXXXVVVVVVTTTTTTT' LIMIT 1 ].get(0).ActivityDate);
    }
    
    public static testMethod void taskCreatedByRole(){
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Test';
        t.Type = 'Test Created by role';
        t.Status = 'Completed';
        t.Description = 'test';
        t.DueDateTime__c = Date.today();
        t.Reminder__c = true;
        
        insert t;
        
        t = [SELECT Id, ActivityDate, Created_By_Role__c FROM Task WHERE Id = :t.Id ];
        List<User> u = [SELECT ID, UserRole.Name FROM USER WHERE Id = :UserInfo.getUserId()];     
        System.assertEquals(u[0].UserRole.Name, t.Created_By_Role__c);
    }
}