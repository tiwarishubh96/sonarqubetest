/**********************************************************************
 Name:  SPPSuccessPlanTriggerHandler

======================================================
======================================================
Purpose:    Handler class to contain the logic of 
            Success_PlanTrigger
History:    
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
1.0         Lu                  11/2/2017          Initial Development
***********************************************************************/


public class SPPSuccessPlanTriggerHandler {
    public static void createBusinessPlanSharing(List<Success_Plan__c> spList){
        List<Success_Plan__Share> sharesToCreate = new List<Success_Plan__Share>();
        Set<Id> setAccount = new Set<Id>();
        Map<string,Id> mapComAccount = new Map<string,Id>();
        Map<Id,Id> mapAccountRole = new Map<Id,Id>();
        Map<Id,Id> mapUserRoleandGroup = new Map<Id,Id>();
        Map<Id, Id> mapComParentAccount = new Map<Id, Id>();
        //get the record type id for partner business plan from success plan object
        Id recordId = Schema.SObjectType.Success_Plan__c.getRecordTypeInfosByName().get('Partner Business Plan').getRecordTypeId();
        system.debug('record id is'+ recordId);
        
        for(Success_Plan__c obj : spList)
        { 
            //only if the record type is partner business plan
            if(obj.Account__c!= null && obj.RecordTypeId == recordId)
            { 
                setAccount.add(obj.Account__c);
                
                if(obj.Parent_Account__c != null)//Add parent account 
                {
                  setAccount.add(obj.Parent_Account__c);
                  mapComParentAccount.put(obj.id,obj.Parent_Account__c);
                }
                
                mapComAccount.put(obj.id,obj.Account__c);
            }
        }
        
        Map<Id,UserRole> mapPartnerRole = new Map<Id,UserRole>([SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId,
                                                                PortalType, PortalRole,PortalAccountOwnerId FROM UserRole where PortalAccountId IN : setAccount]);
        
        for(UserRole usrRole : mapPartnerRole.values())
        {
            mapAccountRole.put(usrRole.PortalAccountId,usrRole.Id);//Map of Account ID and User Role Id
        }
        
        //Fetch group Id based on User Role
        List<Group> lstGroup = [Select RelatedId, Id, Type FROM Group where RelatedId IN : mapPartnerRole.keyset()];
        
        for(Group grp : lstGroup)
        {   
            if(grp.Type == 'RoleAndSubordinates')
            {
                system.debug('grp.RelatedId'+grp.RelatedId);
                mapUserRoleandGroup.put(grp.RelatedId,grp.Id);
            }
        }
        
        for(Id comId : mapComAccount.keyset())//Creating Sharing Rule for Partner Account
        {
            //Get Group Id based on UserRole Id
            String strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapComAccount.get(comId)));
            system.debug('strgroupId '+strgroupId);
            //Creating success plan sharing record
            Success_Plan__Share sp = new Success_Plan__Share();
            sp.AccessLevel = 'Read';
            sp.UserOrGroupId =  strgroupId;
            sp.parentId= comId;
            sp.RowCause = Schema.Success_Plan__Share.RowCause.Access_to_all_Contact_under_Same_Partner__c;
            sharesToCreate.add(sp);
        }
        
         for(Id comId : mapComParentAccount.keyset())//Creating Sharing Rule for Partner Account
        {
            //Get Group Id based on UserRole Id
            String strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapComParentAccount.get(comId)));
            system.debug('strgroupId '+strgroupId);
            //Creating success plan sharing record
            Success_Plan__Share sp = new Success_Plan__Share();
            sp.AccessLevel = 'Read';
            sp.UserOrGroupId =  strgroupId;
            sp.parentId= comId;
            sp.RowCause = Schema.Success_Plan__Share.RowCause.Access_to_all_Contact_under_Same_Partner__c;
            sharesToCreate.add(sp);
        }
        
        if (!sharesToCreate.isEmpty())
        {
            Database.insert(sharesToCreate,false);//Inserting Sharing List 
        }
    }
}