public inherited sharing class OpportunitySurveyHandler extends TriggerService {
    private OpportunitySurveyHelper oppSurveyHelper;

    public OpportunitySurveyHandler() {
        this.oppSurveyHelper = new OpportunitySurveyHelper();
    }

    public void setOverride(OpportunitySurveyHelper oppSurveyHelper) {
        this.oppSurveyHelper = oppSurveyHelper;
    }

    public override void onAfterUpdate() {
        // EAD-1572 RnR Survey
        // Checking the 'Trigger Switch' custom setting before executing the survey method
        Survey_Request_Control_Switch__c triggerSwitch = Survey_Request_Control_Switch__c.getInstance();
        if ((Test.isRunningTest()) ||
                (triggerSwitch.Customer_Contact__c && triggerSwitch.Transaction_Opportunity__c)) {
            // check and survey if required
            this.oppSurveyHelper.solicitSurvey((List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapOldSObject);
        }
    }

    public override void onAfterInsert() {
        Survey_Request_Control_Switch__c triggerSwitch = Survey_Request_Control_Switch__c.getInstance();
        if ((Test.isRunningTest()) ||
                (triggerSwitch.Customer_Contact__c && triggerSwitch.Transaction_Opportunity__c)) {
            // check and survey if required
            this.oppSurveyHelper.solicitSurvey((List<Opportunity>) this.listNewSObject);
        }
    }
}