public class SageApiActivityHandler extends SageApiActivityHandlerBase {
    public SageApiActivityHandler() {}

    public SageApiActivityHandler(String activityType, SageApiActivityStep currentStep, List<SageApiActivity__c> activities, string sessionId) {
        init(activityType, currentStep, activities, sessionId);
    }

    public SageApiActivityHandler(Integer version, String activityType, SageApiActivityStep currentStep, List<SageApiActivity__c> activities, string sessionId) {
        this.Version = version;
        init(activityType, currentStep, activities, sessionId);
    }

    public override void init(String activityType, SageApiActivityStep currentStep, List<SageApiActivity__c> activities, string sessionId) {
        this.CurrentStep = currentStep;
        this.Activities = activities;
        this.SessionId = sessionId;
        this.BatchActivityType = activityType;

        if (activityType == SageApiActivityTriggerHandler.TryNowActivityType)
            initializeTryNowActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.TryNowConvertActivityType)
            initializeTryNowConvertActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.BuyNowActivityType)
            initializeBuyNowActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.LeadActivityType)
            initializeTryNowLeadActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.AddCommunityUserType)
            initializeAddCommunityUserActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.TetrisStartTrialActivityType)
            initializeTetrisStartTrialActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.TetrisConvertTrialActivityType)
            initializeTetrisConvertTrialActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.TetrisStartPaidActivityType)
            initializeTetrisStartPaidActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.CreateSubscriptionActivityType)
            if (this.Version == 2)
                initializeCreateSubscriptionActivityStepsV2();
            else
                initializeCreateSubscriptionActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.DeleteSubscriptionActivityType)
            initializeDeleteSubscriptionActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.SuspendSubscriptionActivityType)
            initializeSuspendSubscriptionActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType)
            initializeReactivateSubscriptionActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.ConvertSubscriptionActivityType)
            initializeConvertSubscriptionActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.RegradeSubscriptionActivityType)
            initializeRegradeSubscriptionActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType)
            initializeUpdateSubscriptionEffectivePeriodActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.CreateAccountActivityType)
            initializeCreateAccountActivitySteps();
        else if (activityType == SageApiActivityTriggerHandler.UpdateSubscriptionActivityType)
            initializeUpdateSubscriptionActivitySteps();

        for (SageApiActivityStep step : this.ActivitySteps)
            if (currentStep != null && currentStep.StepID == step.StepID) {
                step.StepMessage = currentStep.StepMessage;
                step.StepStatus = currentStep.StepStatus;
                step.StepInput = currentStep.StepInput;
                this.CurrentStep = step;
                break;
            }

        System.debug('CurrentStep: ' + JSON.serialize(this.CurrentStep));
        System.debug('Steps: ' + JSON.serialize(this.ActivitySteps));
    }

    public override void init(Integer version, String activityType, SageApiActivityStep currentStep, List<SageApiActivity__c> activities, string sessionId) {
        this.Version = version;
        init(activityType, currentStep, activities, sessionId);
    }
    
    public override void execute(System.QueueableContext objContext) {
        if (! this.HandlerEnabled) return;

        //SageApiActivityUtils.debug('SageApiActivityHandler: '+JSON.serialize(this.Activities));
        SageApiActivityUtils.debug('UserInfo.getSessionId(): '+sessionId);

        if (this.Activities == null || this.Activities.isEmpty()) {
            SageApiActivityUtils.debug('no activities to process: ' + this.Activities);
            return;
        }
        if (this.CurrentStep == null) {
            SageApiActivityUtils.debug('no step found: ' + this.CurrentStep);
            return;
        }
        if (String.isBlank(this.CurrentStep.StepName)) {
            SageApiActivityUtils.debug('no step name defined: ' + this.CurrentStep);
            return;
        }

        // if any step contains future method to update activities, when a new step starts, activities should be refreshed
        if (this.CurrentStep.StepID > 1)
            refreshActivities();
        else
            for (SageApiActivity__c activity : this.Activities)
                activity.ActivityStartTime__c = Datetime.now();

        System.debug('CurrentStep: ' + JSON.serialize(this.CurrentStep));

        // process external step callback
        if (this.CurrentStep.StepStatus == SageApiStatus.Success || this.CurrentStep.StepStatus == SageApiStatus.ManualInterventionRequired || this.CurrentStep.StepStatus == SageApiStatus.Abandoned) {
            for (SageApiActivity__c activity : this.Activities)
                if (this.CurrentStep.StepStatus == SageApiStatus.Success)
                    SageApiActivityUtils.setSuccess(activity, this.CurrentStep);
                else if (this.CurrentStep.StepStatus == SageApiStatus.ManualInterventionRequired || this.CurrentStep.StepStatus == SageApiStatus.Abandoned) {
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, this.CurrentStep.StepName, this.CurrentStep.StepMessage);
                    SageApiActivityUtils.setError(activity, this.CurrentStep, this.CurrentStep.StepStatus, errors);

                    String rollbackAction = this.CurrentStep.RollbackActionName;
                    if (String.isNotBlank(rollbackAction)) {
                        List<SageApiActivity__c> rollbackActivities = new List<SageApiActivity__c>();
                        rollbackActivities.add(activity);
                        Type t = Type.forName(rollbackAction);
                        if (t == null) throw new CustomException('Step Rollback Action is not found: ' + rollbackAction);
                        SageApiActivityStepHandlers.SageApiActivityActionBase action = (SageApiActivityStepHandlers.SageApiActivityActionBase)t.newInstance();
                        action.process(this.CurrentStep, rollbackActivities, this.sessionID);
                    }
                }

            SageApiActivityUtils.updateActivities(this.Activities);
        } else {
            SageApiActivityUtils.checkAndPrepareForRetry(this.Activities, this.ActivitySteps);

            this.CurrentStep.JobID = objContext.getJobId();
            SageApiActivityUtils.debug('SageApiActivityHandler starts running step: '+JSON.serialize(this.CurrentStep));

            SageApiActivityStep runningStep = this.CurrentStep;
            List<SageApiActivity__c> runningActivities = this.Activities;
            while (this.CurrentStep == runningStep && runningActivities != null && runningActivities.size()>0) {
                SageApiActivityUtils.debug('start with runningStep: ' + runningStep);
                Type t = Type.forName(runningStep.StepName);
                if (t == null) throw new CustomException('Step action is not found: ' + runningStep.StepName);
                SageApiActivityStepActionBase stepAction = (SageApiActivityStepActionBase)t.newInstance();
                stepAction.process(runningStep, runningActivities, this.sessionID);
                runningActivities = SageApiActivityUtils.getPendingActivitiesForNextAction(runningStep, runningActivities);
                runningStep = SageApiActivityUtils.getNextQueuedActionStep(this.activitySteps, runningStep);
                SageApiActivityUtils.debug('next runningStep: '+JSON.serialize(runningStep));        
                if (runningStep != null) this.CurrentStep = runningStep;
                //if (runningStep == null) throw new CustomException('my error');
                SageApiActivityUtils.debug('end with runningStep: ' + runningStep);
            }

            SageApiActivityUtils.debug('SageApiActivityHandler ends running step');        
        }

        Map<SageApiActivityStep, List<SageApiActivity__c>> stepActivitiesMap = new Map<SageApiActivityStep, List<SageApiActivity__c>>();
        List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : this.Activities){
            SageApiActivityStep lastCompletedStep = SageApiActivityUtils.getLastCompletedStep(activity);
            SageApiActivityUtils.debug('last completed step: '+JSON.serialize(lastCompletedStep));
            if (lastCompletedStep == null) continue;
            
            List<SageApiActivityStep> nextSteps = new List<SageApiActivityStep>();
            if (lastCompletedStep.StepStatus == SageApiStatus.Success)
                nextSteps = getSuccessSteps(lastCompletedStep);
            
            Boolean hasError = lastCompletedStep.StepStatus == SageApiStatus.Abandoned 
                     || lastCompletedStep.StepStatus == SageApiStatus.ManualInterventionRequired;
            if (hasError)
                nextSteps = getErrorSteps(lastCompletedStep);
            Boolean reachedMaxAttempts = (lastCompletedStep.StepStatus != SageApiStatus.Success) && (lastCompletedStep.Attempts > SageApiActivityUtils.setting_MaxAttemptsPerStep);
            
            if (nextSteps == null || nextSteps.size() == 0 || hasError || reachedMaxAttempts || lastCompletedStep.StepStatus == SageApiStatus.InProgressExternal)
            {
                //if (reachedMaxAttempts) {
                //    lastCompletedStep.StepStatus = SageApiStatus.ManualInterventionRequired;
                //    lastCompletedStep.StepMessage = 'Exceeding retry attempts';
                //}
                activity.ActivityStatus__c = lastCompletedStep.StepStatus;
                //SageApiTryNowActivityUtils.updateArtifact(activity, lastCompletedStep.StepMessage);
                activitiesCompleted.add(activity);
                continue;
            }

            //if (lastCompletedStep.StepStatus != SageApiStatus.Success)
            //    SageApiActivityUtils.updateActivitySteps(activity, lastCompletedStep, true);

            for (SageApiActivityStep step : nextSteps) {
                List<SageApiActivity__c> activityQueue = stepActivitiesMap.get(step);
                if (activityQueue == null) activityQueue = new List<SageApiActivity__c>();
                activityQueue.add(activity);
                stepActivitiesMap.put(step, activityQueue);
                //SageApiActivityUtils.updateActivitySteps(activity, step, true);
                //activitiesToProcess.add(activity);
                SageApiActivityUtils.debug('stepActivitiesMap: '+JSON.serialize(stepActivitiesMap));
            }
        }

        //if (activitiesToProcess.size() > 0)
        //    update activitiesToProcess;

        if (activitiesCompleted.size() > 0) {
            SageApiActivityUtils.updateActivities(activitiesCompleted);
            SageApiActivityUtils.debug('SageApiActivityHandler activitiesCompleted: '+JSON.serialize(activitiesCompleted));        

            List<Integer> indexesToRemove = new List<Integer>();
            for (Integer i = this.Activities.size() - 1; i >= 0; i--)
                for (SageApiActivity__c ac : activitiesCompleted)
                    if (ac.ActivityId__c == this.Activities[i].ActivityId__c) {
                        indexesToRemove.add(i);
                        break;
                    }
            for (Integer index = 0; index < indexesToRemove.size(); index++)
                this.Activities.remove(indexesToRemove[index]);
        }


        if (stepActivitiesMap.size() > 0)
            SageApiActivityUtils.queueNextSteps(this.Version, this.BatchActivityType, stepActivitiesMap, this.sessionId, 'SageApiActivityHandler');

        SageApiActivityUtils.debug('SageApiActivityHandler next steps queued: '+JSON.serialize(stepActivitiesMap));        
    }

    private void initializeTryNowActivitySteps() {
        //DUE TO GOVERNANCE LIMIT, even though the step interface supports handling multiple steps, during implementation, 
        //we are still bound to 1 chained job limit per transaction, in this case one and only one following step is supported
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                1,
                'validatePayloads',
                2,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                2,
                'createOrUpdateLead',
                3,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                3,
                'convertLead',
                4,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                4,
                'createUser',
                5,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                5,
                'createQuote',
                null,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiTryNowActivityStepGetPaymentUrl',
                new List<Integer>{3},
                new List<SageApiActivityStep> { new SageApiActivityStep(1, 5) }
            ),
            new SageApiActivityStep(
                3,
                'SageApiTryNowActivityStepUpsertSM',
                null,
                new List<SageApiActivityStep> { new SageApiActivityStep(1, 5) }
            )
        };

        this.ActivitySteps[6].UseInProcessQueue = true;
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeTryNowConvertActivitySteps() {
        this.activitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiTryNowConvertActivityStepValid',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiTryNowConvertStepUpdateQuote',
                new List<Integer>{3},
                null
            ),
            new SageApiActivityStep(
                3,
                'SageApiBuyNowActivityStepCreateSubscr',
                new List<Integer>{4},
                null
            ),
            new SageApiActivityStep(
                4,
                'SageApiTryNowConvertStepConvertSM',
                null,
                null
            )
        };
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.activitySteps[0];
    }    

    private void initializeBuyNowActivitySteps() {
        this.activitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiBuyNowActivityStepMultisteps',
                1,
                'validatePayloads',
                2,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                2,
                'createOrUpdateLead',
                3,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                3,
                'convertLead',
                4,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                4,
                'createUser',
                5,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                5,
                'createQuote',
                null,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiBuyNowActivityStepCreateSubscr',
                new List<Integer>{3},
                new List<SageApiActivityStep> { new SageApiActivityStep(1, 5) }
            ),
            new SageApiActivityStep(
                3,
                'SageApiBuyNowActivityStepUpsertSM',
                null,
                null
            )
        };
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.activitySteps[0];
    }

    private void initializeAddCommunityUserActivitySteps() {
        this.activitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiAddCommUserActivityStepValidate',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiAddCommUserActivityStepCreate',
                null,
                null
            )
        };
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.activitySteps[0];
    }

    private void initializeTryNowLeadActivitySteps() {
        this.activitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiTryNowLeadActivityStepMultisteps',
                null,
                null
            )
        };
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.activitySteps[0];
    }

    private void initializeTetrisStartTrialActivitySteps() {
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                1,
                'validatePayloads',
                2,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                2,
                'createOrUpdateLead',
                3,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                3,
                'convertLead',
                4,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiTryNowActivityStepMultisteps',
                4,
                'createUser',
                null,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiTryNowActivityStepUpsertSM',
                null,
                null
            )
        };

        this.ActivitySteps[1].UseInProcessQueue = true;
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }
    
    private void initializeTetrisConvertTrialActivitySteps() {
        this.activitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiTryNowConvertActivityStepValid',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiTryNowConvertStepConvertSM',
                null,
                null
            )
        };
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.activitySteps[0];
    }

    private void initializeTetrisStartPaidActivitySteps() {
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiBuyNowActivityStepMultisteps',
                1,
                'validatePayloads',
                2,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiBuyNowActivityStepMultisteps',
                2,
                'createOrUpdateLead',
                3,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiBuyNowActivityStepMultisteps',
                3,
                'convertLead',
                4,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                1,
                'SageApiBuyNowActivityStepMultisteps',
                4,
                'createUser',
                null,
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiBuyNowActivityStepUpsertSM',
                null,
                null
            )
        };

        this.ActivitySteps[1].UseInProcessQueue = true;
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeCreateSubscriptionActivitySteps() {
        System.debug('initializeCreateSubscriptionActivitySteps');
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.CreateSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.CreateOrUpdateAccount',
                new List<Integer>{3},
                null
            ),
            new SageApiActivityStep(
                3,
                'SageApiActivityStepHandlers.CreateOrUpdateContact',
                new List<Integer>{4},
                null
            ),
            //new SageApiActivityStep(
            //    4,
            //    'SageApiActivityStepHandlers.CreateOrUpdateOpp',
            //    new List<Integer>{5},
            //    null
            //),
            new SageApiActivityStep(
                4,
                'SageApiActivityStepHandlers.CreateOrUpdateLead',
                new List<Integer>{5},
                null
            ),
            new SageApiActivityStep(
                5,
                'SageApiActivityStepHandlers.ConvertLead',
                new List<Integer>{6},
                null
            ),
            new SageApiActivityStep(
                6,
                'SageApiActivityStepHandlers.CreateUser',
                new List<Integer>{7},
                null
            ),
            new SageApiActivityStep(
                7,
                'SageApiActivityStepHandlers.CreateOrUpdateSubscriptionMaster',
                null,
                null
            )
        };

        this.ActivitySteps[6].UseInProcessQueue = true;

        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }
/*
    private void initializeCreateSubscriptionActivityStepsV2() {
        System.debug('initializeCreateSubscriptionActivityStepsV2');
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.Start',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.CreateSubscriptionV2Validation',
                new List<Integer>{3},
                null
            ),
            new SageApiActivityStep(
                3,
                'SageApiActivityStepHandlers.CreateUserV2',
                new List<Integer>{4},
                null
            ),
            //new SageApiActivityStep(
            //    4,
            //    'SageApiActivityStepHandlers.RequestEntitlementDetail',
            //    new List<Integer>{5},
            //    null
            //),
            new SageApiActivityStep(
                4,
                'SageApiActivityStepHandlers.CreateEntitlementDetail',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
        for (SageApiActivityStep step : this.ActivitySteps)
            if (step.StepID == 1 || step.StepID == 4)
                step.UsePlatformEvent = true;

        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }
*/

    private void initializeCreateSubscriptionActivityStepsV2() {
        System.debug('initializeCreateSubscriptionActivityStepsV2');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.CreateSubscriptionV2Validation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.CreateEntitlementDetail',
                new List<Integer>{3},
                null
            ),
            new SageApiActivityStep(
                3,
                'SageApiActivityStepHandlers.CreateUserV2',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
/*        for (SageApiActivityStep step : this.ActivitySteps)
            if (step.StepID == 2) {
                step.UsePlatformEvent = true;
                step.RollbackActionName = 'SageApiActivityStepHandlers.AbandonEntitlementUpdate';
            }*/
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeDeleteSubscriptionActivitySteps() {
        System.debug('initializeDeleteSubscriptionActivitySteps');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.DeleteSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.DeleteEntitlementDetail',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeSuspendSubscriptionActivitySteps() {
        System.debug('initializeSuspendSubscriptionActivitySteps');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.SuspendSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.SuspendEntitlementDetail',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeReactivateSubscriptionActivitySteps() {
        System.debug('initializeReactivateSubscriptionActivitySteps');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.ReactivateSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.ReactivateEntitlementDetail',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeConvertSubscriptionActivitySteps() {
        System.debug('initializeConvertSubscriptionActivitySteps');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.ConvertSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.ConvertEntitlementDetail',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;

        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeRegradeSubscriptionActivitySteps() {
        System.debug('initializeRegradeSubscriptionActivitySteps');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.RegradeSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.RegradeEntitlementDetail',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeUpdateSubscriptionEffectivePeriodActivitySteps() {
        System.debug('initializeUpdateSubscriptionEffectivePeriodActivitySteps');
        this.HandlerEnabled = false;
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.UpdateSubscriptionEffectivePeriodValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.UpdateSubscriptionEffectivePeriod',
                null,
                null
            )
        };

        //this.ActivitySteps[6].UseInProcessQueue = true;
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeCreateAccountActivitySteps() {
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.CreateAccountValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.CreateOrUpdateAccount',
                new List<Integer>{3},
                null
            ),
            new SageApiActivityStep(
                3,
                'SageApiActivityStepHandlers.CreateOrUpdateContact',
                null,
                null
            )
        };
      
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }

    private void initializeUpdateSubscriptionActivitySteps() {
        this.ActivitySteps = new List<SageApiActivityStep> {
            new SageApiActivityStep(
                1,
                'SageApiActivityStepHandlers.UpdateSubscriptionValidation',
                new List<Integer>{2},
                null
            ),
            new SageApiActivityStep(
                2,
                'SageApiActivityStepHandlers.UpdateSubscriptionMaster',
                null,
                null
            )
        };

        this.ActivitySteps[1].UseInProcessQueue = true;
            
        if (this.CurrentStep == null)
            this.CurrentStep = this.ActivitySteps[0];
    }
}