/**
* @author          Rani Thumma (rani.thumma@sage.com)
* @date            30 July 2018
* @param           Opportunity
* @description     to display warning messages on the Opportunity detail page
**/
public with sharing class opportunityMesgExt {
    
    public static String oppId {get;set;}
    public static Opportunity opp {get;set;}

    public Set<String> integrationStatus = new Set<String>
                                    {
                                'Pending - Send to Local (Self)',
                                'Pending - Send to Local (Round-Robin)',
                                'Extracted to Local',
                                'Updated from Local',
                                'Loaded to Local',
                                'Closed – Auto Opportunity Created'};

    public opportunityMesgExt(ApexPages.StandardController stdController) {
        oppId = stdController.getRecord().id;
        opp= (Opportunity)stdController.getRecord();

        if(!retrieveContactRoles()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Opportunity_Contact_Role));
        }
        if(retrieveLocalCRMOppID()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Opportunity_Local_CRM_Sync));
        }
    }
    public Boolean retrieveContactRoles(){
        Boolean hasContactRoles = false;
        List<OpportunityContactRole> ocr = [Select Id, OpportunityId From OpportunityContactRole WHERE OpportunityId = :oppId];
        if(!ocr.isEmpty()){
            hasContactRoles = true;
        }
        return hasContactRoles;
    }

    private Boolean retrieveLocalCRMOppID(){
        Boolean hasOppSendtoLocalCRM = false;
	    List<Opportunity> crmOpp = [Select Id, Integration_Record_Status__c From Opportunity WHERE Id = :oppId and
                                  Integration_Record_Status__c IN :integrationStatus];
                                                                 
           if(!crmOpp.isEmpty()){
            hasOppSendtoLocalCRM = true;
           }
        return hasOppSendtoLocalCRM;
    }
}