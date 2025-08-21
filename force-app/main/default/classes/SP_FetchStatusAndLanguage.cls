/*
* Class Name :- SP_FetchStatusAndLanguage
* Author :- Shubham Kimothi
* Created Date :- 31-07-2019
* Description : This class is use to get the status is associated language with customer story.
* 
// ********************Change Logs *****************************************************************************************************************************
*/

global with sharing class SP_FetchStatusAndLanguage {
    
    global String CurrentSPStatus {get; set;}
    global String CurrentSPLanguage {get; set;}
    
    global string getstatusInNativeLanguage() {
        String currentStatus;
        if(CurrentSPLanguage == 'FR'){
            List<SpotLightStatusMapping__mdt> translation = [SELECT FR__c FROM SpotLightStatusMapping__mdt WHERE LABEL=:CurrentSPStatus];
            currentStatus = translation[0].FR__c;
        }
        else if(CurrentSPLanguage == 'ES'){
            List<SpotLightStatusMapping__mdt> translation = [SELECT ES__c FROM SpotLightStatusMapping__mdt WHERE LABEL=:CurrentSPStatus];
            currentStatus = translation[0].ES__c;
        }
        else if(CurrentSPLanguage == 'DE'){
            List<SpotLightStatusMapping__mdt> translation = [SELECT DE__c FROM SpotLightStatusMapping__mdt WHERE LABEL=:CurrentSPStatus];
            currentStatus = translation[0].DE__c;
        }
        else{
            currentStatus = CurrentSPStatus; 
        }
        
        return currentStatus;
    }
}