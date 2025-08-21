/*
 * ContactAssignmentHandler
 * ----------------------------
 */
public class ContactAssignmentHandler implements TriggerHandlerInterface {
    
    public void BeforeInsert(List<SObject> newItems) {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        ContactAssignmentHelper.assignContacts((List<Contact_Assignment__c>)newItems.values());
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // ContactAssignmentHelper.assignContacts((List<Contact_Assignment__c>)newItems.values());
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
}