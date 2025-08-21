public class Success_PlanTriggerHandler{
    public static void onAfterInsert(List<Success_Plan__c> triggerNew){
        List<Case> caseList = new List<Case>();
        List<Id> listId = new List<Id>();
        List<Id> listIdOpportunity = new List<Id>();
        for(Success_Plan__c forSuccess_PlanTriggerNew: triggerNew){
            listId.add(forSuccess_PlanTriggerNew.Account__c);
            listIdOpportunity.add(forSuccess_PlanTriggerNew.Opportunity__c);
        }
        Map<Id, Account> mapIdAccount = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: listId]);
        Set<String> setString = new Set<String>{'Qualify', '02 Discovery', '03 Evaluating', '04 Proposal', 'Selection', '06 Signed Order'};
        Map<Id, Opportunity> mapIdOpportunity = new Map<Id, Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id IN: listIdOpportunity]);
        for(Success_Plan__c Sccess_Plan: triggerNew){
            if(Sccess_Plan.Opportunity__c == null){
            }
            else if(setString.contains(mapIdOpportunity.get(Sccess_Plan.Opportunity__c).StageName)){
                Case cse = new Case();
                cse.Success_Plan__c = Sccess_Plan.Id;
                cse.AccountId = Sccess_Plan.Account__c;
                cse.Customer_Lifecycle_Stage__c = 'Pre-production';
                cse.Contact = Sccess_Plan.Trial_Contact__r;
                cse.Case_Category__c = 'Processing';//question What is the default value?
                cse.Case__c = 'Login';//question What is the default value?
                cse.Status = 'New'; //question What is the default value?
                cse.Priority = 'Low'; //question What is the default value?
                cse.Origin = 'Internal';
                cse.Subject = 'Pre-production Case for ' + mapIdAccount.get(Sccess_Plan.Account__c).Name;
                cse.Type = 'Internal';
                caseList.add(cse);
            }
            else if(mapIdOpportunity.get(Sccess_Plan.Opportunity__c).StageName == '07 Closed - Won'){
                Case cse = new Case();
                cse.AccountId = Sccess_Plan.Account__c;
                cse.Contact = Sccess_Plan.Trial_Contact__r;
                cse.Case_Category__c = 'Processing';//question What is the default value?
                cse.Case__c = 'Login';//question What is the default value?
                cse.Status = 'New'; //question What is the default value?
                cse.Priority = 'Low'; //question What is the default value?
                cse.Customer_Lifecycle_Stage__c = 'Onboarding - No Pre-production';
                cse.Origin = 'Internal';
                cse.Success_Plan__c = Sccess_Plan.Id;
                cse.Subject = 'Onboarding - No Pre-production Case for ' + mapIdAccount.get(Sccess_Plan.Account__c).Name;
                cse.Type = 'Internal';
                caseList.add(cse);
            }
        }
        insert caseList;
    }
}