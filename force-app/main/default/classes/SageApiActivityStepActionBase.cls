public abstract class SageApiActivityStepActionBase {
    public SageApiActivityHandlerBase activityHandler {get; set;}
    
    public abstract void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId);
}