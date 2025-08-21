/***************************************************************************************
Author      : Rani Thumma
Company     : Docmation
Date        : 5/8/2017
Description : This is class is developed to clean up all the MQEvents created when syncing 
Accounts and contacts
****************************************************************************************/
global class SPPMQEventsCleanUpBatch implements Database.Batchable<sobject>, Database.Stateful {
    //global String query{get;set;}
    global List<MQ_Event__c> events;
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        SPP_Config_Helper__mdt msgSize = [SELECT NoOfDays__c,DeveloperName FROM SPP_Config_Helper__mdt WHERE DeveloperName = 'MQ_Event_Cleanup' LIMIT 1];
        String query = 'SELECT Id, Name, Createddate FROM MQ_Event__c WHERE CreatedDate < LAST_N_DAYS:'+Integer.valueOf(msgSize.NoOfDays__c);
        System.debug('Query=== '+query);
        return Database.getQueryLocator(query);
    }
    global void execute (Database.BatchableContext BC, List<MQ_Event__c> scope) {
        System.debug('Size of Scope @@@@@ '+Scope.size());
        if(scope.size() > 0){
            events = new List<MQ_Event__c>();
            for(SObject mq :scope){
                MQ_Event__c event = (MQ_Event__c)mq;
                events.add(event);
            }
            if(events.size() > 0){
                Database.delete(events, false);
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}