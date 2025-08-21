trigger EntitlementMessageTrigger on Entitlement_Message__c (before insert, before update, after insert, after update, after delete) {
    
    if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c) {
            if (Trigger.isInsert) {
                if (Trigger.isBefore) {
                    EntitlementMessageTriggerHandler.beforeInsert(Trigger.New, Trigger.newMap);
                } else if (Trigger.isAfter) {
                    EntitlementMessageTriggerHandler.afterInsert(Trigger.New, Trigger.newMap);
                }    
            } else if (Trigger.isUpdate) {
                if (Trigger.isBefore) {
                    EntitlementMessageTriggerHandler.beforeUpdate(Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap);
                } else if (Trigger.isAfter) {
                    EntitlementMessageTriggerHandler.afterUpdate(Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap);
                }
            } else if (Trigger.isDelete) {
                EntitlementMessageTriggerHandler.afterDelete(Trigger.Old, Trigger.oldMap);
            }
        }
}