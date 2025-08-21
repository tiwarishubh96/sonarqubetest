/*
* Trigger Name :- CustomerStoryTrigger
* Author :- Shubham Kimothi
* Created Date :- 22-05-2019
* 
// ********************Change Logs *****************************************************************************************************************************
*/

trigger CustomerStoryTrigger on Customer_Story__c (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerDispatcher.Run(new CustomerStoryTriggerHandler());
}