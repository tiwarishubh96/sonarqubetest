trigger SignupRequest on SignupRequest(after insert, after update) {

    TriggerSignupHandler handler = new TriggerSignupHandler();

    if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c) {

        /*if (Trigger.isInsert && Trigger.isBefore) {
            handler.onBeforeInsert(Trigger.new);
        }*/

        /* After Insert */
        if (Trigger.isAfter && Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new, Trigger.newMap);
        }

        /* Before Update 
        else if (Trigger.isUpdate && Trigger.isBefore) {
            handler.onBeforeUpdate(trigger.old, trigger.oldMap, trigger.new, trigger.newMap);
        }*/

        /* After Update */
        else if (Trigger.isUpdate && Trigger.isAfter) {
            handler.onAfterUpdate(trigger.old, trigger.oldMap, trigger.new, trigger.newMap);
        }

        /* Before Delete 
        else if (Trigger.isDelete && Trigger.isBefore) {
            handler.onBeforeDelete(trigger.old, trigger.oldMap);
        }*/

        /* After Delete 
        else if (Trigger.isDelete && Trigger.isAfter) {
            handler.onAfterDelete(trigger.old, trigger.oldMap);
        }*/

        /* After Undelete 
        else if (Trigger.isUnDelete) {
            handler.onAfterUndelete(trigger.new, trigger.newMap);
        }*/
    }

}