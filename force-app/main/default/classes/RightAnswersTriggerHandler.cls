public without sharing class RightAnswersTriggerHandler {
   /* public void BeforeInsert(List<SObject> newItems){
    }
    
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems){
    }*/
    
    public void AfterInsert(Map<Id, SObject> newItems){
        
        RightAnswersHelper.publishEventToCasOnCreatingRARecord(newItems);
        RightAnswersHelper.updatehasRightAnswer(newItems);
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        RightAnswersHelper.updatehasRightAnswer(newItems);
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems){
        RightAnswersHelper.updatehasRightAnswerto0(oldItems);
    }
    
    /*public void AfterUndelete(Map<Id, SObject> oldItems){
    }*/
}