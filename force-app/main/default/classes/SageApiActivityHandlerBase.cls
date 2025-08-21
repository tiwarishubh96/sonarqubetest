public abstract class SageApiActivityHandlerBase implements System.Queueable {
    public List<SageApiActivityStep> ActivitySteps {set; get;}
    public SageApiStatus ActivityStatus {get; set;}
    public SageApiActivityStep CurrentStep {set; get;}
    public String BatchActivityType {get; set;}
    public List<SageApiActivity__c> Activities {set; get;}
    public List<SageApiActivity__c> QueuedActivities {set; get;}
    public string SessionID {set; get;}
    public Integer Version {get; set;}
    public Boolean HandlerEnabled = true;

    public List<SageApiActivityStep> getSuccessSteps(SageApiActivityStep step) {
        return getSteps(step.OnSuccessGotoSteps);
    }

    public List<SageApiActivityStep> getErrorSteps(SageApiActivityStep step) {
        return getSteps(step.OnErrorGotoSteps);
    }

    public List<SageApiActivityStep> getSteps(List<Integer> stepIDs) {
        if (stepIDs == null || stepIDs.size() == 0) return null;
        
        List<SageApiActivityStep> steps = new List<SageApiActivityStep>();
        for (Integer id : stepIDs)
            for (SageApiActivityStep step : activitySteps)
                if (step.StepID == id)
                    steps.add(step);
        return steps;
    }

    public SageApiActivityStep getNextStep(SageApiActivityStep currentStep) {
        if (currentStep == null) return null;
        
        for (SageApiActivityStep step : activitySteps)
            if (step.StepID == currentStep.StepID+1)
                return step;
        return null;
    }
    
    public void refreshActivities()
    {
        this.Activities = SageApiActivityUtils.refreshActivities(this.Activities);
        System.debug('refreshActivities ended');
    }
    
    public abstract void execute(System.QueueableContext objContext);
    
    public abstract void init(String activityType, SageApiActivityStep currentStep, List<SageApiActivity__c> activities, string sessionId);

    public abstract void init(Integer version, String activityType, SageApiActivityStep currentStep, List<SageApiActivity__c> activities, string sessionId);
}