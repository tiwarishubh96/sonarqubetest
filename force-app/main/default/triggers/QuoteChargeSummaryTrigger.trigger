trigger QuoteChargeSummaryTrigger on zqu__QuoteChargeSummary__c (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
 		system.debug('QuoteChargeSummaryTrigger Trigger.New'+Trigger.New);
        QuoteChargeSummaryTriggerHandler qcst = new QuoteChargeSummaryTriggerHandler();
        qcst.updateProductTranslatedName(Trigger.New);
    }
}