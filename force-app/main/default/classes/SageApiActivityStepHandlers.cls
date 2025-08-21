public class SageApiActivityStepHandlers {
    public class CreateSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateCreateSubscriptionPayload(step, activities);
        }
    }

    public class CreateSubscriptionV2Validation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            //SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(step, activities, false, true);
        }
    }

    public class DeleteSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateDeleteSubscriptionPayload(step, activities);
        }
    }

    public class SuspendSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateSuspendSubscriptionPayload(step, activities);
        }
    }

    public class ReactivateSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateReactivateSubscriptionPayload(step, activities);
        }
    }

    public class ConvertSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(step, activities);
        }
    }

    public class RegradeSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            //SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(step, activities, true);
        }
    }

    public class UpdateSubscriptionEffectivePeriodValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(step, activities);
        }
    }

    public class CreateAccountValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateCreateAccountPayload(step, activities);
        }
    }

    public class UpdateSubscriptionValidation extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.validateUpdateSubscriptionPayload(step, activities);
        }
    }

    public class CreateOrUpdateAccount extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.createOrUpdateAccount(step, activities);
        }
    }

    public class CreateOrUpdateContact extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.createOrUpdateContact(step, activities);
        }
    }

    public class CreateOrUpdateLead extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.createOrUpdateLeadFromContact(step, activities);
        }
    }

    public class ConvertLead extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.convertLead(step, activities);
        }
    }

    public class CreateUser extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.provisionUser(step, activities);
        }
    }

    public class CreateUserV2 extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.provisionUserV2(step, activities);
        }
    }

    public class CreateOrUpdateSubscriptionMaster extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.createOrUpdateSubscriptionMaster(step, activities);
        }
    }

    public class UpdateSubscriptionMaster extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.updateSubscriptionMaster(step, activities);
        }
    }

    public class CreateEntitlementDetail extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.createEntitlementDetail(step, activities);
        }
    }

    public class DeleteEntitlementDetail extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.deleteEntitlementDetail(step, activities);
        }
    }

    public class SuspendEntitlementDetail extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.suspendEntitlementDetail(step, activities);
        }
    }

    public class ReactivateEntitlementDetail extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.reactivateEntitlementDetail(step, activities);
        }
    }

    public class ConvertEntitlementDetail extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.convertEntitlementDetail(step, activities);
        }
    }

    public class RegradeEntitlementDetail extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.regradeEntitlementDetail(step, activities);
        }
    }

    public class UpdateSubscriptionEffectivePeriod extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.updateSubscriptionEffectivePeriod(step, activities);
        }
    }


/*
    public class StartProductProvision extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.startProductProvision(step, activities);
        }
    }

    public class CompleteCbcProvision extends SageApiActivityStepBase {
        public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
            SageApiSubscriptionActivityUtils.completeCbcProvision(step, activities);
        }
    }
*/
    public virtual class SageApiActivityStepBase extends SageApiActivityStepActionBase {
        public SageApiActivityStep step;
        public List<SageApiActivity__c> activities;
        public string sessionId;

        public virtual override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {}

        public void process() {
            this.activities = SageApiActivityUtils.refreshActivities(this.activities);

            List<SageApiActivity__c> activitiesToProcess = new List<SageApiActivity__c>();
            List<SageApiActivity__c> activitiesCompleted = new List<SageApiActivity__c>();
            for(SageApiActivity__c activity : this.activities) {
                step.StartTime = Datetime.now();
                SageApiActivityUtils.updateActivitySteps(activity, step, true);
                if (SageApiActivityUtils.reachedMaxAttempts(activity, this.step)) {
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Activity Step ' + this.step.StepID, ' max allowed retry attemps reached');
                    SageApiActivityUtils.setError(activity, this.step, SageApiStatus.ManualInterventionRequired, errors);
                    activitiesCompleted.add(activity);
                    continue;
                }

                SageApiActivityUtils.debug('SageApiActivityStepAction: Check for required steps');
                if (!SageApiActivityUtils.requiredStepsProcessed(activity, step)) {
                    SageApiActivityUtils.debug('required steps are not complete, return to queue');
                    continue;
                }
                
                if (SageApiActivityUtils.completedWithSuccess(activity, this.step.StepID)){
                    activitiesCompleted.add(activity);
                    continue;
                }
                
                activitiesToProcess.add(activity);            
            }
            
            if (activitiesCompleted.size() > 0)
                SageApiActivityUtils.updateActivities(activitiesCompleted);
            
            if (activitiesToProcess.size() == 0) {
                SageApiActivityUtils.debug('SageApiActivityStepAction exit without actions');
                return;
            }

            SageApiActivityUtils.debug('SageApiActivityStepAction step: '+this.step);
            SageApiActivityUtils.debug('SageApiActivityStepAction activitiesToProcess: '+activitiesToProcess);
            process(this.step, activitiesToProcess, this.sessionId);
            SageApiActivityUtils.debug('SageApiActivityStepAction exiting');
        }
    }

    public abstract class SageApiActivityActionBase {
        public abstract void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId);
    }
}