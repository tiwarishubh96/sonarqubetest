public inherited sharing class TaskServiceTriggerHandler extends TriggerService {
	private TaskTriggerHelper serviceHelper;

    public TaskServiceTriggerHandler() {
        this.serviceHelper = new TaskTriggerHelper();
    }
    
    public override void onBeforeInsert() {
        this.serviceHelper.BeforeInsert((List<Task>) listNewSObject);
    }
    
	public override void onAfterInsert() {
        this.serviceHelper.onAfterInsert((List<Task>) listNewSObject);
    }
    
	public override void onAfterUpdate() {
        this.serviceHelper.onAfterUpdate((Map<Id, Task>) mapOldSObject, (List<Task>) listNewSObject);
    }
}