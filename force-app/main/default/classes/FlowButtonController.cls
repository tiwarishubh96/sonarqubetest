public class FlowButtonController {

    @AuraEnabled
    public static void markRecent(String recordId) {
        Lead_Last_Touched__c llt = new Lead_Last_Touched__c();
        llt.Lead__c = recordId;
        insert llt;
	}    
    
}