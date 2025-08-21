public without sharing class OpportunityContactRoleTriggerHandler implements TriggerHandlerInterface {
    public void BeforeInsert(List<SObject> newItems){ }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}

    public void BeforeDelete(Map<Id, SObject> oldItems){}

    public void AfterInsert(Map<Id, SObject> newItems) {
        OpportunityContactRoleHelper.updateOpportunityPrimaryContact((List<OpportunityContactRole>) newItems.values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        OpportunityContactRoleHelper.updateOpportunityPrimaryContact((List<OpportunityContactRole>) newItems.values());
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {
        OpportunityContactRoleHelper.updateOpportunityPrimaryContact((List<OpportunityContactRole>) oldItems.values());
    }

    public void AfterUndelete(Map<Id, SObject> oldItems){}
}