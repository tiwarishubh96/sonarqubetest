trigger CampaignInfluence_Trigger on CampaignInfluence (before insert, before update, before delete,
		after insert, after update, after delete, after undelete) {
    CampaignInfluenceControlSwitch__c  triggerSwitch = CampaignInfluenceControlSwitch__c.getInstance();
	if (Test.isRunningTest() || triggerSwitch.RunTrigger__c){
		TriggerDispatcher.Run(new CampaignInfluence_TriggerHandler());
	}

}