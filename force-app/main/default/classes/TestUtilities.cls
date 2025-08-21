@isTest
public class TestUtilities {
    public static void createTriggerCustomSetting() {
        Application_Control__c settings1 = Application_Control__c.getOrgDefaults();
		settings1.Run_Triggers__c = true;
		upsert settings1 Application_Control__c.Id;
        
        CBC_Application_Control__c settings2 = CBC_Application_Control__c.getOrgDefaults();
		settings2.Run_Triggers__c = true;
		upsert settings2 CBC_Application_Control__c.Id;
    }
}