/**
* @author Vikram Middha
* @date 26 May 2015
* @description SignupRequest Trigger Handler
*/

public with sharing class TriggerSignupHandler{ 

    /**
    * @author Vikram Middha
    * @date26 May 2015
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    /*public void onBeforeInsert(final List<SignupRequest> newObjects) {            
    
    }*/

    /**
    * @author Vikram Middha
    * @date 26 May 2015
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<SignupRequest> newObjects, final Map<Id, SignupRequest> newObjectsMap)
    {
        
        Set<Id> successSignupRequests           = new Set<Id>();
        Set<String> successSROrgIds             = new Set<String>();
        List<id> successPlanIds = new List<id>();
        List<Success_Plan__c> successPlans = new List<Success_Plan__c>();
        Map<id,DateTime > combi = new  Map<id,DateTime >();

        for(SignupRequest sr : newObjects){
            if(sr.Status == 'Success'){
                successSignupRequests.add(sr.Id);
                if(!String.isBlank(sr.CreatedOrgId)){
                    successSROrgIds.add(sr.CreatedOrgId);
                }
            }
        }

        if(successSROrgIds.size() > 0){
            updateOpportunityWithLicenseInfo(successSROrgIds, newObjectsMap);
        }
        List<DateTime> srCreatedDate = new List<DateTime>();
        for(SignupRequest sr : newObjects){
            if(sr.Success_Plan__c != null){
                if(sr.CreatedDate != null){
                    combi.put(sr.Success_Plan__c,sr.CreatedDate);
                }
            }
        }
        successPlans = [SELECT id, Org_Installation_Date__c FROM Success_Plan__c WHERE Id In: combi.keySet()];
        for(Success_Plan__c Sccess_Plan: successPlans){
            Sccess_Plan.Org_Installation_Date__c = combi.get(Sccess_Plan.Id);
        }
        if(successPlans.size() > 0){
            update successPlans;
        }
    }

    /**
    * @author Vikram Middha
    * @date 26 May 2015
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    /*public void onBeforeUpdate(final List<SignupRequest> oldObjects, final Map<Id, SignupRequest> oldObjectsMap,
                               final List<SignupRequest> newObjects, final Map<Id, SignupRequest> newObjectsMap) {                                
    
        
    }*/

    /**
    * @author Vikram Middha
    * @date 26 May 2015
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<SignupRequest> oldObjects, final Map<Id, SignupRequest> oldObjectsMap,
                              final List<SignupRequest> newObjects, final Map<Id, SignupRequest> newObjectsMap)
    {

        
        Set<Id> successSignupRequests           = new Set<Id>();
        Set<String> successSROrgIds             = new Set<String>();

        for(SignupRequest sr : newObjects){
            if(sr.Status == 'Success' && sr.Status != oldObjectsMap.get(sr.Id).Status){
                successSignupRequests.add(sr.Id);
                if(!String.isBlank(sr.CreatedOrgId)){
                    successSROrgIds.add(sr.CreatedOrgId);
                }
            }
        }

        if(successSROrgIds.size() > 0){
            updateOpportunityWithLicenseInfo(successSROrgIds, newObjectsMap);
        }
        
    }
  
  
    /**
    * @author Vikram Middha
    * @date 26 May 2015
    * @description fired on before delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    /*public void onBeforeDelete(final List<SignupRequest> oldObjects, final Map<Id, SignupRequest> oldObjectsMap) {
      
    }*/

    /**
    * @author Vikram Middha
    * @date 26 May 2015
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    /*public void onAfterDelete(final List<SignupRequest> oldObjects, final Map<Id, SignupRequest> oldObjectsMap) {
        
        
    }*/

    /**
    * @author Vikram Middha
    * @date 26 May 2015
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    /*public void onAfterUndelete(final List<SignupRequest> newObjects, final Map<Id, SignupRequest> newObjectsMap) {
    }*/
    
    private void updateOpportunityWithLicenseInfo(Set<String> successSROrgIds, Map<Id, SignupRequest> newObjectsMap) {

        List<String> packageNames                       = License_Management_Settings__c.getOrgDefaults().Package_Name__c.split(','); 
        Map<String,sfLma__License__c> licenseMap        = new Map<String,sfLma__License__c>();
        List<Opportunity> opportunitiesToUpdate         = new List<Opportunity>();

        List<sfLma__License__c> licenseList = [SELECT Id,
                                                        sfLma__Subscriber_Org_ID__c
                                                FROM sfLma__License__c
                                                WHERE sfLma__Subscriber_Org_ID__c IN :successSROrgIds
                                                AND sfLma__Package_Version__r.sfLma__Package__r.Name IN :packageNames  
                                                ORDER BY createdDate];


        for(sfLma__License__c license :licenseList ){
            licenseMap.put(license.sfLma__Subscriber_Org_ID__c, license);
        }

        for(String signupRequestId : newObjectsMap.keySet()){

            if(!successSROrgIds.contains(newObjectsMap.get(signupRequestId).CreatedOrgId)){
                continue;
            }

            if(licenseMap.get(newObjectsMap.get(signupRequestId).CreatedOrgId) != null && 
                                        !String.isBlank(newObjectsMap.get(signupRequestId).OpportunityId__c)){

                Opportunity opp = new Opportunity(Id = newObjectsMap.get(signupRequestId).OpportunityId__c,
                                                    License__c = licenseMap.get(newObjectsMap.get(signupRequestId).CreatedOrgId).Id);

                if(!String.isBlank(newObjectsMap.get(signupRequestId).Success_Plan_Type__c)){
                    opp.License_Populated_By__c = newObjectsMap.get(signupRequestId).Success_Plan_Type__c + ' Success Plan';
                }
                opportunitiesToUpdate.add(opp);
            }
        }
        if(opportunitiesToUpdate.size() > 0){
            update opportunitiesToUpdate;
        }

    }
   

}