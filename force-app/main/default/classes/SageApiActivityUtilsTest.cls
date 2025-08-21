@IsTest(SeeAllData=false)
private class SageApiActivityUtilsTest
{
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
    }

    @IsTest static void testUpdateActivityStepsNew()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.updateActivitySteps( activity, step, true );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
    }

    @IsTest static void testUpdateActivityStepsExisting()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);
        SageApiActivityStep newStep = new SageApiActivityStep( 2, 'DoAnotherStuff' );

        Test.startTest();
        
            SageApiActivityUtils.updateActivitySteps( activity, newStep, true );
    
        Test.stopTest();
        
        List<SageApiActivityStep> newSteps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( newSteps.size() == 2 );
    }

    @IsTest static void testTryNowSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testTryNowSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testBuyNowSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.BuyNowActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testBuyNowSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.BuyNowActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testTryNowConvertSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowConvertActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testTryNowConvertSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowConvertActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testTetrisStartTrialSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TetrisStartTrialActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testTetrisStartTrialSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TetrisStartTrialActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testTetrisStartPaidSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TetrisStartPaidActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testTetrisStartPaidSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TetrisStartPaidActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testTetrisConvertTrialErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TetrisConvertTrialActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testTetrisConvertTrialSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TetrisConvertTrialActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testTryNowLeadSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.LeadActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testTryNowLeadSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.LeadActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testAddCommunityUserSetErrorSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.AddCommunityUserType, null);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setError( activity, step, 'SomeStatus', null );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );
        System.assert( activity.ActivityStatus__c == 'SomeStatus' );
    }

    @IsTest static void testAddCommunityUserSetSuccessSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.AddCommunityUserType, null);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiActivityUtils.setSuccess( activity, step );
    
        Test.stopTest();
        
        System.assert( string.isNotBlank(activity.ActivitySteps__c) );

        List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(activity.ActivitySteps__c, List<SageApiActivityStep>.class);
        System.assert( steps.size() == 1 );

        System.assert( steps[0].StepStatus == SageApiStatus.Success );
    }

    @IsTest static void testAddErrorsSuccess()
    {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        Test.startTest();
        
            SageApiActivityUtils.addErrors( errors, 'theCode', 'theTarget', 'theMessage' );
    
        Test.stopTest();
        
        System.assert( errors.size() == 1 );
    }

    @IsTest static void testGetLastCompletedStepNoStep()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);

        Test.startTest();
        
            SageApiActivityStep step = SageApiActivityUtils.getLastCompletedStep( activity );
    
        Test.stopTest();
        
        System.assert( step == null );
    }

    @IsTest static void testGetLastCompletedStepInvalidStep()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activity.ActivitySteps__c = '{';

        Test.startTest();
        
            SageApiActivityStep step = SageApiActivityUtils.getLastCompletedStep( activity );
    
        Test.stopTest();
        
        System.assert( step == null );
    }

    @IsTest static void testGetLastCompletedStepSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        step.StepStatus = SageApiStatus.Success;
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();
        
            SageApiActivityStep theStep = SageApiActivityUtils.getLastCompletedStep( activity );
    
        Test.stopTest();
        
        System.assert( theStep != null );
    }

    @IsTest static void testGetProcessedStepSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        step.StepStatus = SageApiStatus.Success;
        Step.ActionID = 1;
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();
        
            SageApiActivityStep theStep = SageApiActivityUtils.getProcessedStep( activity, step );
    
        Test.stopTest();
        
        System.assert( theStep != null );
    }
    
    @IsTest static void testRequiredStepsProcessedIncompleteSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        SageApiActivityStep step1 = new SageApiActivityStep( 1, 'DoStuff' );
        step1.StepStatus = SageApiStatus.InProgress;
        Step1.ActionID = 1;
        steps.add(step1);
        activity.ActivitySteps__c = JSON.serialize(steps);
        SageApiActivityStep step2 = new SageApiActivityStep( 1, 'DoStuff' );
        step2.ActionID = 2;
        step2.StartAfterCompletedSteps = new List<SageApiActivityStep>{ Step1 };

        Test.startTest();
        
            Boolean processed = SageApiActivityUtils.requiredStepsProcessed( activity, step2 );
    
        Test.stopTest();
        
        System.assertEquals(false, processed);
    }

    @IsTest static void testRequiredStepsProcessedCompleteSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        SageApiActivityStep step1 = new SageApiActivityStep( 1, 'DoStuff' );
        step1.StepStatus = SageApiStatus.Success;
        Step1.ActionID = 1;
        steps.add(step1);
        activity.ActivitySteps__c = JSON.serialize(steps);
        SageApiActivityStep step2 = new SageApiActivityStep( 1, 'DoStuff' );
        step2.ActionID = 2;
        step2.StartAfterCompletedSteps = new List<SageApiActivityStep>{ Step1 };

        Test.startTest();
        
            Boolean processed = SageApiActivityUtils.requiredStepsProcessed( activity, step2 );
    
        Test.stopTest();
        
        System.assertEquals(true, processed);
    }

    @IsTest static void testGetPendingActivitiesForNextActionSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        SageApiActivityStep step1 = new SageApiActivityStep( 1, 'DoStuff' );
        step1.StepStatus = SageApiStatus.Success;
        Step1.ActionID = 1;
        Step1.NextActionID = 2;
        steps.add(step1);
        SageApiActivityStep step2 = new SageApiActivityStep( 1, 'DoStuff' );
        step2.StepStatus = SageApiStatus.Success;
        step2.ActionID = 2;
        steps.add(step2);
        activity.ActivitySteps__c = JSON.serialize(steps);
        activities.add(activity);

        Test.startTest();
        
            List<SageApiActivity__c> pending = SageApiActivityUtils.getPendingActivitiesForNextAction( step1, activities );
    
        Test.stopTest();
        
        System.assert( pending != null );
    }

    @IsTest static void testGetCompletedStepNoSteps()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);

        Test.startTest();
        
            SageApiActivityStep step = SageApiActivityUtils.getCompletedStep( activity, 1 );
    
        Test.stopTest();
        
        System.assert( step == null );
    }

    @IsTest static void testGetCompletedStepInvalidStepId()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);

        Test.startTest();
        
            SageApiActivityStep step = SageApiActivityUtils.getCompletedStep( activity, 0 );
    
        Test.stopTest();
        
        System.assert( step == null );
    }
    
    @IsTest static void testGetCompletedStepInvalidStep()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activity.ActivitySteps__c = '{';

        Test.startTest();
        
            SageApiActivityStep step = SageApiActivityUtils.getCompletedStep( activity, 1 );
    
        Test.stopTest();
        
        System.assert( step == null );
    }

    @IsTest static void testGetCompletedStepSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        steps.add(new SageApiActivityStep( 2, 'DoAnotherStuff' ));
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();
        
            SageApiActivityStep step = SageApiActivityUtils.getCompletedStep( activity, 2 );
    
        Test.stopTest();
        
        System.assert( step != null );
    }

    @IsTest static void testCompletedWithSuccessTrue()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        SageApiActivityStep step = new SageApiActivityStep( 2, 'DoAnotherStuff' );
        step.StepStatus = SageApiStatus.Success;
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();
        
           Boolean status = SageApiActivityUtils.completedWithSuccess( activity, 2 );
    
        Test.stopTest();

        System.assertEquals( true, status);
    }

    @IsTest static void testCompletedWithSuccessFalse()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        SageApiActivityStep step = new SageApiActivityStep( 2, 'DoAnotherStuff' );
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();

            Boolean status = SageApiActivityUtils.completedWithSuccess( activity, 2 );
    
        Test.stopTest();

        System.assertEquals( false, status);
    }

    @IsTest static void testReachedMaxAttemptsCompletedTrue()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        SageApiActivityStep step = new SageApiActivityStep( 2, 'DoAnotherStuff' );
        step.StepStatus = SageApiStatus.Success;
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();

            Boolean status = SageApiActivityUtils.reachedMaxAttempts( activity, step );
    
        Test.stopTest();

        System.assertEquals(false, status);
    }

    @IsTest static void testReachedMaxAttemptsTrue()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        SageApiActivityStep step = new SageApiActivityStep( 2, 'DoAnotherStuff' );
        step.Attempts = 100;
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();

            Boolean status = SageApiActivityUtils.reachedMaxAttempts( activity, step );
    
        Test.stopTest();

        System.assertEquals( true, status );
    }

    @IsTest static void testReachedMaxAttemptsFalse()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        SageApiActivityStep step = new SageApiActivityStep( 2, 'DoAnotherStuff' );
        step.Attempts = 1;
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();

            Boolean status = SageApiActivityUtils.reachedMaxAttempts( activity, step );

        Test.stopTest();

        System.assertEquals( false, status);
    }

    @IsTest static void testRefreshActivitiesSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        upsert activities;
        
        Test.startTest();

            List<SageApiActivity__c> refreshActivities = SageApiActivityUtils.refreshActivities( activities );
    
        Test.stopTest();
        
        System.assert(refreshActivities != null && refreshActivities.size() == 1);
    }

    @IsTest static void testRefreshActivitiesNullActivities()
    {
        List<SageApiActivity__c> activities = null;

        Test.startTest();
        
            List<SageApiActivity__c> refreshActivities = SageApiActivityUtils.refreshActivities( activities );
    
        Test.stopTest();
        
        System.assert(refreshActivities == null);
    }


    @IsTest static void testUpdateActivitiesSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        insert activities;
        activity.Artifacts__c = 'test';
        Test.startTest();
        
            SageApiActivityUtils.updateActivities( activities );
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assertEquals( 'test', updatedActivity.Artifacts__c );
    }

    @IsTest static void testUpdateActivitiesEmptyStepSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        insert activities;
        activity.Artifacts__c = 'test';
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        Test.startTest();
        
            SageApiActivityUtils.updateActivities( step, activities );
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assertEquals( 'test', updatedActivity.Artifacts__c );
    }

    @IsTest static void testUpdateActivitiesValidStepSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        step.StepStatus = SageApiStatus.Success;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        insert activities;
        step.StepStatus = SageApiStatus.Success;
        Step.StepMessage = 'Done';
        Test.startTest();
        
            SageApiActivityUtils.updateActivities( step, activities );
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assertNotEquals( null, updatedActivity.Artifacts__c );
    }

    @IsTest static void testUpdateActivitiesValidStepError()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        step.StepStatus = SageApiStatus.ManualInterventionRequired;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        insert activities;
        step.StepStatus = SageApiStatus.ManualInterventionRequired;
        Step.StepMessage = 'Done';
        Test.startTest();
        
            SageApiActivityUtils.updateActivities( step, activities );
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assertNotEquals( null, updatedActivity.Artifacts__c );
    }

    @IsTest static void testUpdateActivitiesValidStepBadPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        activity.ActivitySteps__c = '{';
        insert activities;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        step.StepStatus = SageApiStatus.InProgress;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;

        Test.startTest();
        
            SageApiActivityUtils.updateActivities( step, activities );
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, ActivityStatus__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assertEquals( SageApiStatus.ManualInterventionRequired, updatedActivity.ActivityStatus__c );
    }

    @IsTest static void testQueueOverLimits()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, JSON.serialize(SageApiTestUtils.createTryNowPayload()));
        activities.add(activity);
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'SageApiTryNowActivityStepMultisteps' );
        step.ActionID = 1;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;
        step.UseInProcessQueue = true;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        insert activities;
        Map<SageApiActivityStep, List<SageApiActivity__c>> aMap = new Map<SageApiActivityStep, List<SageApiActivity__c>>();
        aMap.put(step, activities);
        Test.startTest();
        
            for (Integer i = 0; i < 100; i++)
                SageApiActivityUtils.queueNextSteps(SageApiActivityTriggerHandler.TryNowActivityType,  aMap, null, 'SageApiActivityHandler');
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assert( updatedActivity.Artifacts__c.contains(SageApiStatus.ManualInterventionRequired) );
    }

    @IsTest static void testQueueNextStepsError()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'SageApiTryNowActivityStepMultisteps' );
        step.ActionID = 1;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        insert activities;
        Map<SageApiActivityStep, List<SageApiActivity__c>> aMap = new Map<SageApiActivityStep, List<SageApiActivity__c>>();
        aMap.put(step, activities);
        Test.startTest();
        
            SageApiActivityUtils.queueNextSteps(SageApiActivityTriggerHandler.TryNowActivityType,  aMap, null, 'SageApiActivityHandler');
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assert( updatedActivity.Artifacts__c.contains(SageApiStatus.ManualInterventionRequired) );
    }

    @IsTest static void testQueueNextStepsDisabledQueue()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, JSON.serialize(SageApiTestUtils.createTryNowPayload()));
        activities.add(activity);
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'SageApiTryNowActivityStepMultisteps' );
        step.ActionID = 1;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        insert activities;
        Map<SageApiActivityStep, List<SageApiActivity__c>> aMap = new Map<SageApiActivityStep, List<SageApiActivity__c>>();
        aMap.put(step, activities);
        SageApiActivitySetting__c setting = [select name, value__c from SageApiActivitySetting__c where name = 'DisableActivityQueue'];
        setting.Value__c  = 'true';
        update setting;
        Test.startTest();
        
            SageApiActivityUtils.queueNextSteps(SageApiActivityTriggerHandler.TryNowActivityType,  aMap, null, 'SageApiActivityHandler');
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assert( updatedActivity.Artifacts__c.contains(SageApiStatus.ManualInterventionRequired) );
        setting.Value__c  = 'false';
        update setting;
    }

    @IsTest static void testQueueNextStepsUseInProcessQueueError()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activities.add(activity);
        activity.ActivityStatus__c = SageApiStatus.Unknown;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'SageApiTryNowActivityStepMultisteps' );
        step.ActionID = 1;
        step.NextActionID = 0;
        step.OnSuccessGotoSteps = null;
        step.UseInProcessQueue = true;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        insert activities;
        Map<SageApiActivityStep, List<SageApiActivity__c>> aMap = new Map<SageApiActivityStep, List<SageApiActivity__c>>();
        aMap.put(step, activities);
        Test.startTest();
        
            SageApiActivityUtils.queueNextSteps(SageApiActivityTriggerHandler.TryNowActivityType,  aMap, null, 'SageApiActivityHandler');
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, Artifacts__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assert( updatedActivity.Artifacts__c.contains(SageApiStatus.ManualInterventionRequired) );
    }

    @IsTest static void testActivityTerminatedSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activity.ActivityStatus__c = SageApiStatus.Success;
        Test.startTest();
        
            System.assertEquals(true, SageApiActivityUtils.activityTerminated( activity ));
    
        Test.stopTest();
    }

    @IsTest static void testComposeErrorMessageForLastStepSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        steps.add(new SageApiActivityStep( 1, 'DoStuff' ));
        SageApiActivityStep step = new SageApiActivityStep( 2, 'DoAnotherStuff' );
        steps.add(step);
        activity.ActivitySteps__c = JSON.serialize(steps);

        Test.startTest();
        
            string message = SageApiActivityUtils.composeErrorMessageForLastStep( activity, 'My Error' );
    
        Test.stopTest();
        System.assertEquals(true, message.contains('My Error'));
    }
    
    @IsTest static void testUpdateActivityWithExceptionSuccess()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoAnotherStuff' );
        Test.startTest();
        
            List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException( activity, step, false, 'MyErrorTarget', 'MyErrorMessage' );
    
        Test.stopTest();
        System.assert(errors.size() == 1);
    }

    @IsTest static void testCheckAndPrepareForRetry1() {
        String activityType = 'TryNow';
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createTryNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Restarting;

        SageApiActivityStep step1 = new SageApiActivityStep(1, 'Step1', 1, 'Action1', 2, null, null);
        step1.StepStatus = SageApiStatus.Success;
        SageApiActivityStep step2 = new SageApiActivityStep(1, 'Step1', 2, 'Action2', null, null, null);
        step2.StepStatus = SageApiStatus.ManualInterventionRequired;
        step2.StepMessage = 'Error';
        List<SageApiActivityStep> steps = new List<SageApiActivityStep> {step1, step2};
        activity.ActivitySteps__c = JSON.serialize(steps);
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);

        insert activities;

        Test.startTest();
        
            SageApiActivityUtils.checkAndPrepareForRetry(activities, steps);

        Test.stopTest();

        System.assertEquals( 1, activity.RetryStartStep__c );        
        System.assertEquals( 2, activity.RetryStartAction__c );        
    }

    @IsTest static void testCheckAndPrepareForRetry2() {
        String activityType = 'TryNow';
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createTryNowPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload ) );
        activity.ActivityStatus__c = SageApiStatus.Restarting;

        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1', 1, 'Action1', 2, null, null);
        step.StepStatus = SageApiStatus.Success;
        activity.ActivitySteps__c = JSON.serialize(new List<SageApiActivityStep> {step});
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);

        SageApiActivityStep step1 = new SageApiActivityStep(1, 'Step1', 1, 'Action1', 2, null, null);
        SageApiActivityStep step2 = new SageApiActivityStep(1, 'Step1', 2, 'Action2', null, null, null);

        List<SageApiActivityStep> steps = new List<SageApiActivityStep> {step1, step2};

        insert activities;

        Test.startTest();
        
            SageApiActivityUtils.checkAndPrepareForRetry(activities, steps);

        Test.stopTest();

        System.assertEquals( 1, activity.RetryStartStep__c );     
        System.assertEquals( 2, activity.RetryStartAction__c );        
    }

/**//**/
    @IsTest static void testGetProductTiers()
    {
        Product2 zproduct = new Product2();
        zproduct.Name = 'Sage One';
        zproduct.zqu__Category__c = 'Base Products';
        zproduct.zqu__EffectiveEndDate__c = System.today().addYears( 100 );
        zproduct.zqu__EffectiveStartDate__c = System.today().addYears( -10 );
        zproduct.zqu__SKU__c = '1';
        zproduct.zqu__ZuoraId__c = 'p1';
        insert zproduct;

        Product_Tier__c tier = new Product_Tier__c();
        tier.Name = 'Sage One';
        tier.Product_Tier_Code__c = 'SageOne-Start-US';
        tier.Product_Use_Region__c = 'US - United States';
        tier.Product__c = zproduct.Id;
        tier.PayNow_PageType__c = 'SageOne';
        tier.Trial_Period__c = 30;
        insert tier;

        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
    
        Test.startTest();
        
            List<Product_Tier__c> tiers = SageApiActivityUtils.getProductTiers( payload.products );
    
            Integer size = tiers.size();

        Test.stopTest();

        System.assertEquals( 1, size );
    }
/**//**/
    @IsTest static void testGetProductTierRatePlans()
    {
        Locale__c loc = new Locale__c(BillingBatch__c='Batch1',Country__c='US - United States',CurrencyIsoCode='USD',Default_Locale__c='Yes',Language__c='English',Name='en_US',PayNow_EmailTemplateName__c='PayNow Complete',SalesOffice__c='Atlanta CBC',TimeZone__c='America/New_York',LanguageLocaleKey__c='en_US');
        insert loc;

        Product2 zproduct = new Product2();
        zproduct.Name = 'Sage One';
        zproduct.zqu__Category__c = 'Base Products';
        zproduct.zqu__EffectiveEndDate__c = System.today().addYears( 100 );
        zproduct.zqu__EffectiveStartDate__c = System.today().addYears( -10 );
        zproduct.zqu__SKU__c = '1';
        zproduct.zqu__ZuoraId__c = 'p1';
        insert zproduct;

        zqu__ProductRatePlan__c rate = new zqu__ProductRatePlan__c();
        rate.Name = 'Kryptonite';
        rate.zqu__Product__c = zproduct.Id;
        rate.zqu__EffectiveEndDate__c = System.today().addYears( 100 );
        rate.zqu__EffectiveStartDate__c = System.today().addYears( -10 );
        rate.zqu__ZuoraId__c = 'r1';
        insert rate;

        Product_Tier__c tier = new Product_Tier__c();
        tier.Name = 'Sage One';
        tier.Product_Tier_Code__c = 'SageOne-Start-US';
        tier.Product_Use_Region__c = 'US - United States';
        tier.Product__c = zproduct.Id;
        tier.PayNow_PageType__c = 'SageOne';
        tier.Trial_Period__c = 30;
        insert tier;
    
        Product_Tier_Rate_Plan__c plan = new Product_Tier_Rate_Plan__c();
        plan.Name = 'Monthly';
        plan.End_Date__c = System.today().addDays( 100 );
        plan.Start_Date__c = System.today().addYears( -1 );
        plan.Trial_Period__c = 30;
        plan.Product_Tier__c = tier.Id;
        plan.Product_Rate_Plan__c = rate.Id;
        plan.Payment_Grace_Period__c = 0;
        plan.CurrencyIsoCode = 'GBP';
        plan.Locale__c = loc.Id;
        insert plan;

        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
    
        Test.startTest();
        
            Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans( payload.products );
            Integer size = listTierMap.size();

        Test.stopTest();

        System.assertEquals( 1, size );
    }

/**//**/
    @IsTest static void testGetPricingCodeCharges()
    {
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
    
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};

        Test.startTest();

            List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
            Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);

        Test.stopTest();

        System.assert( pricingChargeMap != null );
    }

/**//**/
    @IsTest static void testGetPricingCodeChargesWithPricingCode()
    {
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
    
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload('_LIST');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};

        Test.startTest();

            List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
            Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);

        Test.stopTest();

        System.assert( pricingChargeMap != null );
    }

/**//**/
    @IsTest static void testSourceExistsTrue()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.sourceExists(SageApiActivityRequestObjects.Source.AppDirect.name());

        Test.stopTest();

        System.assertEquals( true, exists );
    }

/**//**/
    @IsTest static void testSourceExistsFalse()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.sourceExists('Not Exists');

        Test.stopTest();

        System.assertEquals( false, exists );
    }

/**//**/
    @IsTest static void testIdentifierTypeTrue()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.identifierTypeExists(SageApiActivityRequestObjects.IdentifierType.AppDirect.name());

        Test.stopTest();

        System.assertEquals( true, exists );
    }

/**//**/
    @IsTest static void testIdentifierTypeFalse()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.identifierTypeExists('Not Exists');

        Test.stopTest();

        System.assertEquals( false, exists );
    }

/**//**/
    @IsTest static void testActivityTypeExistsTrue()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.activityTypeExists(SageApiActivityRequestObjects.ActivityType.CreateSubscription.name());

        Test.stopTest();

        System.assertEquals( true, exists );
    }

/**//**/
    @IsTest static void testActivityTypeExistsFalse()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.activityTypeExists('Not Exists');

        Test.stopTest();

        System.assertEquals( false, exists );
    }

/**//**/
    @IsTest static void testActivityActionExistsTrue()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.activityActionExists(SageApiActivityRequestObjects.ActivityAction.Cancel.name());

        Test.stopTest();

        System.assertEquals( true, exists );
    }

/**//**/
    @IsTest static void testActivityActionExistsFalse()
    {
        Test.startTest();

            Boolean exists = SageApiActivityUtils.activityActionExists('Not Exists');

        Test.stopTest();

        System.assertEquals( false, exists );
    }

/*
    @IsTest static void testUpdateActivitiesInvalidType()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activity.ActivityType__c = 'TryNow';
        activities.add(activity);
        insert activities;
        activity.ActivityType__c = 'InvalidType';
        
        Test.startTest();
        
            SageApiActivityUtils.updateActivities( activities );
    
        Test.stopTest();
        
        SageApiActivity__c updatedActivity = [SELECT Id, ActivityType__c FROM SageApiActivity__c WHERE Id =: activity.Id];
        System.assertEquals( updatedActivity.ActivityType__c, activity.ActivityType__c );
    }
*/
}