/*
* Class Name :- TaskTriggerHandler
* Author :- Shubham Kimothi
* Created Date :- 01-03-2019
* Description : This class is called by TaskTrigger
* 
// ********************Change Logs *****************************************************************************************************************************
*/

public without sharing class TaskTriggerHandler implements TriggerHandlerInterface{
    
    public void BeforeInsert(List<SObject> newItems){
        /*TaskTriggerHelper.BeforeInsert((List<Task>) newItems);
        TaskTriggerHelper.UpdateTaskDueDate((List<Task>)newItems,new Map<Id,Task>());
        TaskTriggerHelper.UpdateTaskComments((List<Task>)newItems,new Map<Id,Task>());
        TaskTriggerHelper.populateCreatedByRole((List<Task>) newItems);
        TaskTriggerHelper.UpdateTaskType((List<Task>) newItems);*/
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        /*TaskTriggerHelper.UpdateTaskDueDate((List<Task>)newItems.values(),(Map<Id, Task>)oldItems);
        TaskTriggerHelper.UpdateTaskComments((List<Task>)newItems.values(),(Map<Id, Task>)oldItems);
        TaskTriggerHelper.UpdateTaskType((List<Task>) newItems.values());*/
        
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){
        /*TaskTriggerHelper.onAfterInsert((List<Task>)newItems.values());
        TaskTriggerHelper.updateCallitemAttemptedCalls((List<Task>)newItems.values());
         Survey_Request_Control_Switch__c triggerSwitch = Survey_Request_Control_Switch__c.getInstance();
        if ((Test.isRunningTest()) || 
            (triggerSwitch.Customer_Contact__c && triggerSwitch.Transaction_Task__c)) {
                // check and survey if required
                
                TaskSurveyHandler surveyHandler = new TaskSurveyHandler();
                surveyHandler.solicitSurvey((List<Task>) newItems.values(), new Map<Id, Task>());
               
            }    */
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        /*TaskTriggerHelper.onAfterUpdate((Map<Id, Task>)oldItems,(List<Task>)newItems.values());
        Survey_Request_Control_Switch__c triggerSwitch = Survey_Request_Control_Switch__c.getInstance();
        if ((Test.isRunningTest()) || 
            (triggerSwitch.Customer_Contact__c && triggerSwitch.Transaction_Task__c)) {
                // check and survey if required
                System.debug('Enter Task Trigger after update');
                TaskSurveyHandler surveyHandler = new TaskSurveyHandler();
                surveyHandler.solicitSurvey((List<Task>) newItems.values(), (Map<Id, Task>) oldItems);
            }  */       
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
}