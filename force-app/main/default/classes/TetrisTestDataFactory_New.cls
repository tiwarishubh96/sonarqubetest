// TODO CCR clearly there is a lot of duplication between this and TetrisTestDataFactory.
// We're introducing technical debt with this commit which will be resolved at the end of CloudCraze replacement
@isTest
public class TetrisTestDataFactory_New {
    // Methods for TetrisZuoraEffectiveDateService
    public static final String USER_LOCALE = 'en_GB';
    public static final String USER_CURENCY = 'GBP';

    public static void createZuoraRecords(String zuoraSubscriptionName,
            String zuoraCustAccountName,
            String zuoraSubProdChargeName,
            String accountId) {
        Zuora__CustomerAccount__c zuoraAcctObj = new Zuora__CustomerAccount__c();
        zuoraAcctObj.Zuora__Zuora_Id__c = '2c92c0fa61789dfe01618bc0869314e0';
        zuoraAcctObj.Name = zuoraCustAccountName;
        zuoraAcctObj.Zuora__Account__c = accountId;
        zuoraAcctObj.Zuora__AccountNumber__c = 'C00000001';
        insert zuoraAcctObj;

        System.debug('#######Zuora_Account Inserted');

        Zuora__Subscription__c zuoraSubObj = new Zuora__Subscription__c();
        zuoraSubObj.Zuora__Account__c = accountId;
        zuoraSubObj.Zuora__CustomerAccount__c = zuoraAcctObj.Id;
        zuoraSubObj.Zuora__NextChargeDate__c = system.today();
        zuoraSubObj.Zuora__NextRenewalDate__c = system.today();
        zuoraSubObj.Zuora__InvoiceOwner__c = zuoraAcctObj.Id;
        zuoraSubObj.Zuora__ServiceActivationDate__c = system.today();
        zuoraSubObj.Zuora__SubscriptionStartDate__c = system.today();
        zuoraSubObj.Zuora__SubscriptionEndDate__c = system.today();
        zuoraSubObj.Name = zuoraSubscriptionName;
        zuoraSubObj.Zuora__Zuora_Id__c = '2c92c0fa61789dfe01618bc0869314e1';
        zuoraSubObj.Zuora__Status__c  = 'Active';
        insert zuoraSubObj;

        Zuora__SubscriptionProductCharge__c zuoraSubChargeObj = new Zuora__SubscriptionProductCharge__c();
        zuoraSubChargeObj.Zuora__Subscription__c = zuoraSubObj.Id;
        zuoraSubChargeObj.Name = zuoraSubProdChargeName;
        zuoraSubChargeObj.Zuora__Zuora_Id__c ='2c92c0fa61789dfe01618bc0869314d1';
        zuoraSubChargeObj.Zuora__Account__c= accountId;
        zuoraSubChargeObj.BundleDescription__c = 'Bundle';
        zuoraSubChargeObj.BundleInstanceId__c = '2c92c0fa61789dfe01618bc0869314e0';
        zuoraSubChargeObj.BundleName__c = 'Bundle';
        insert zuoraSubChargeObj;
    }

}