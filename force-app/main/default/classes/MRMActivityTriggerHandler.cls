/*
* Class Name :- MRMActivityTriggerHandler
* Author :- Dharani Sai
* Created Date :- 14-10-2020
* Description : This class is called by MRMActivity_Trigger
* 
// ********************Change Logs *****************************************************************************************************************************
*/
public without sharing class MRMActivityTriggerHandler implements TriggerHandlerInterface{
    public void BeforeInsert(List<SObject> newItems){
        MRMActivity_Trigger_Helper.populateRegionBasedOnCountry((List<MRM_Activity__c>) newItems);
    }   
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        MRMActivity_Trigger_Helper.populateRegionBasedOnCountry((List<MRM_Activity__c>) newItems.values(),(Map<Id, MRM_Activity__c>)oldItems);     
    } 
    public void BeforeDelete(Map<Id, SObject> oldItems){} 
    public void AfterInsert(Map<Id, SObject> newItems){     }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}  
}