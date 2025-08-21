/*
* Class Name : EventTriggerHandler
* Author : Pete Wilson
* Created Date : 05 November 2020
* Description : Requests survey when required after Event update
*/ 
public without sharing class EventTriggerHandler implements TriggerHandlerInterface {
    
    public void BeforeInsert(List<SObject> newItems) {
        List<Event> eventList = (List<Event>)newItems;
        for(Event e:eventList){
            if(e.Type != null){
                e.Type__c = e.Type;
            }
            if(e.Support_Subject__c != null){
                e.subject = e.Support_Subject__c + Label.Support_Subject_Label;
            }
            
        }
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
        List<Event> eventList = (List<Event>)newItems.values();
        for(Event e:eventList){
            if(e.Type != null){
                e.Type__c = e.Type;
            }
             if(e.Support_Subject__c != null){
                e.subject = e.Support_Subject__c + Label.Support_Subject_Label;
            }
        }
    
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        Survey_Request_Control_Switch__c triggerSwitch = Survey_Request_Control_Switch__c.getInstance();

        if ((Test.isRunningTest()) || 
            (triggerSwitch.Customer_Contact__c && triggerSwitch.Transaction_Event__c)) {
            // check and survey if required       
            EventSurveyHandler surveyHandler = new EventSurveyHandler();
            surveyHandler.solicitSurvey((List<Event>) newItems.values(), new Map<Id,Event>());
        }
              
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Survey_Request_Control_Switch__c triggerSwitch = Survey_Request_Control_Switch__c.getInstance();

        if ((Test.isRunningTest()) || 
            (triggerSwitch.Customer_Contact__c && triggerSwitch.Transaction_Event__c)) {
            // check and survey if required       
            EventSurveyHandler surveyHandler = new EventSurveyHandler();
            surveyHandler.solicitSurvey((List<Event>) newItems.values(), (Map<Id, Event>) oldItems);
        }         
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}