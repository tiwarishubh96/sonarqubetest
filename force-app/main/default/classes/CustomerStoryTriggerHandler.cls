/*
* Class Name :- CustomerStoryTriggerHandler
* Author :- Shubham Kimothi
* Created Date :- 22-05-2019
* Description : This class is called from CustomerStoryTrigger
* 
// ********************Change Logs *****************************************************************************************************************************
*/
public without sharing class CustomerStoryTriggerHandler implements TriggerHandlerInterface{

     public void BeforeInsert(List<SObject> newItems){
         CustomerStoryHelper.insertRegionsAccordingtoCountries((List<Customer_Story__c>)newItems);
     }
     
     public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
     
     public void BeforeDelete(Map<Id, SObject> oldItems){}
     
     public void AfterInsert(Map<Id, SObject> newItems){}
     
     public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
     
     public void AfterDelete(Map<Id, SObject> oldItems){}
     
     public void AfterUndelete(Map<Id, SObject> oldItems){} 
}