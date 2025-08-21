trigger PayNowPostPaymentTrigger on PayNowToken__c (after update) {
    if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c) {
            if(trigger.isUpdate && trigger.isAfter) {
				PayNowTaskHandler.onAfterUpdate(trigger.old, trigger.oldMap, trigger.new, trigger.newMap);
        	}
    }
}