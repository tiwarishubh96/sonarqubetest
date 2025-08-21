/*
* Class Name :- TaskTriggerHelper
* Author :- Shubham Kimothi
* Created Date :- 01-03-2019
* Description : This class is called by Task_TriggerHandler
* 
// ********************Change Logs *****************************************************************************************************************************
*/

public inherited sharing class TaskTriggerHelper{
    private final String CLASS_NAME = 'TaskTriggerHelper';

    public void BeforeInsert(final List<Task> newObjects){
        if (FeatureManagement.checkPermission('isServiceUser')) {
            Map<Id, Task> mapTaskByCaseId = new Map<Id, Task>();
            for (Task eachTask :newObjects) {
                if (eachTask.WhatId != null 
                && 'Case'.equalsIgnoreCase(eachTask.WhatId.getSObjectType().getDescribe().getName())) {
                    mapTaskByCaseId.put(eachTask.WhatId, eachTask);
                }
            }

            for (Case eachCase :[  SELECT Id
                                        , Status 
                                    FROM Case 
                                    WHERE Id IN :mapTaskByCaseId.keySet() ]) {
                if ('Closed'.equals(eachCase.Status)) {
                    mapTaskByCaseId.get(eachCase.Id).addError(System.Label.TaskClosedMsg);
                }
            }
        }
    }
    
    public void onAfterInsert(final List<Task> newObjects){
        
        Set<Id> SP_Ids = new Set<Id>();     
        try{
            LogControl.push('onAfterInsert', CLASS_NAME);
            for(Task task : newObjects){
                if(task.Call_Duration_Minutes__c !=null && task.WhatId != null){
                    SP_Ids.add(task.WhatId);
                }
            }
            if(SP_Ids != null && !SP_Ids.isEmpty()){
                this.updateTotalTimeSuccessPlan(SP_Ids);
            }    
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        }
    }
        
    
    public void onAfterUpdate(final Map<Id, Task> oldObjectsMap, final List<Task> newObjects){
        
        Set<Id> SP_Ids = new Set<Id>();
        try{
            LogControl.push('onAfterUpdate', CLASS_NAME);
            for(Task task : newObjects){
                if(task.Call_Duration_Minutes__c !=null){
                    SP_Ids.add(task.WhatId);
                } 
            }
            if(SP_Ids != null && !SP_Ids.isEmpty()){
                updateTotalTimeSuccessPlan(SP_Ids);
            }
            
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        } 
    }    
    
    public void updateTotalTimeSuccessPlan(Set<Id> SP_Ids){ 
        Map<Id , Integer> CallSumMap = new Map<id , Integer>();
        List<Success_Plan__c> SP_List = new List<Success_Plan__c>();
        try{
            LogControl.push('updateTotalTimeSuccessPlan', CLASS_NAME);
            if(SP_Ids.size()>0){//added as fix for INC0432751, INC0432776
                for(AggregateResult result : [Select Sum(Call_Duration_Minutes__c) CallSum, WhatId from Task where WhatID in: SP_Ids and WhatID in (Select id from Success_Plan__c) AND WhatID!=null  Group By WhatId]){
                    id ids = (Id)result.get('WhatId');
                    Integer amnt = integer.valueOf((Decimal)result.get('CallSum'));
                    CallSumMap.put(ids,amnt);
                }
            }
            for(Success_Plan__c sp: [SELECT Id, Total_Time__c from Success_Plan__c where Id in:SP_Ids]){
                Integer calchour = CallSumMap.get(sp.id)/60;
                Integer calcmin = math.mod(integer.valueOf(CallSumMap.get(sp.id)), 60);
                sp.Total_Time__c = (decimal.valueOf(calchour)+(decimal.valueOf(calcmin)/60.00).setScale(2)); //multiply min with 0.01 to move it to the right 
                SP_List.add(sp);
            }
            
            if(SP_List != null && !SP_List.isEmpty()){
                update SP_List; 
            }
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        }
    }
}