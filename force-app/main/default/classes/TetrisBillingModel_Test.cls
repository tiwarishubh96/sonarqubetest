@isTest
public class TetrisBillingModel_Test {
    public static testmethod void testforTetrisBillingModel(){
        TetrisBillingModel tetrisBilling = new TetrisBillingModel();
        tetrisBilling.billingAccountStatus ='Approved';
        tetrisBilling.contractEffectiveDate = Date.today();
        tetrisBilling.nextChargeDate = Date.today();
        tetrisBilling.salesforceAccountId = '1234';
        tetrisBilling.serviceActivationDate = Date.today();
        tetrisBilling.subscriptionEndDate = Date.today();
        tetrisBilling.subscriptionNumber = '12345';
        tetrisBilling.subscriptionStartDate = Date.today();
        tetrisBilling.tcv = Decimal.valueOf('123456');
        tetrisBilling.termEndDate = Date.today();
        tetrisBilling.termSettingType = 'test type';
        tetrisBilling.termStartDate = Date.today();
        tetrisBilling.zuoraAccountId = '12345';
        tetrisBilling.zuoraAccountName = 'acc Name';
        tetrisBilling.zuoraAccountZuoraId = 'zuora acc id';
        tetrisBilling.zuoraSubscriptionId = 'subs id';
        tetrisBilling.zuoraSubscriptionSFID ='subs sf id';
    }
}