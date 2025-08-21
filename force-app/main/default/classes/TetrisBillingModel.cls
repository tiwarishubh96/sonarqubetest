global class TetrisBillingModel {

    global String zuoraSubscriptionSFID {get; set;}
    global String zuoraSubscriptionId {get; set;}
    global String subscriptionNumber {get; set;}

    global String zuoraAccountName {get; set;}
    global String zuoraAccountNumber {get; set;}
    global String salesforceAccountId {get; set;}
    global Date contractEffectiveDate {get; set;}
    global String billingAccountStatus {get; set;}
    global String zuoraAccountId {get; set;}
    global String zuoraAccountZuoraId {get; set;}
    global Date serviceActivationDate {get; set;}
    global Date subscriptionStartDate {get; set;}
    global Date subscriptionEndDate {get; set;}
    
    global Date nextChargeDate {get; set;}
    global Date termStartDate {get; set;}
    global Date termEndDate {get; set;}
    global String termSettingType {get; set;}
    global Decimal tcv {get; set;}
    
    global List<TetrisBillingProductChargeModel> ratePlans {get; set;}
    
    

}