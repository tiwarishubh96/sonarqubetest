trigger CommunityMembershipTrigger on Community_Membership__c (before insert, before update, after insert, after update, after delete) {
    
    if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c) {
            if (Trigger.isInsert) {
                if (Trigger.isBefore) {
                    CommunityMembershipTriggerHandler.beforeInsert(Trigger.New, Trigger.newMap);
                } else if (Trigger.isAfter) {
                    CommunityMembershipTriggerHandler.afterInsert(Trigger.New, Trigger.newMap);
                }    
            } else if (Trigger.isUpdate) {
                if (Trigger.isBefore) {
                    CommunityMembershipTriggerHandler.beforeUpdate(Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap);
                } else if (Trigger.isAfter) {
                    CommunityMembershipTriggerHandler.afterUpdate(Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap);
                }
            } else if (Trigger.isDelete) {
                CommunityMembershipTriggerHandler.afterDelete(Trigger.Old, Trigger.oldMap);
            }
        }
}