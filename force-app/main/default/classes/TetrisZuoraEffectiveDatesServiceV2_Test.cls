@isTest
public class TetrisZuoraEffectiveDatesServiceV2_Test {

    private static final String accountName = 'TestAcc';
    private static final String encryptedCartId = null;
    private static final String transactionType = 'try';
    private static final String salesOffice = 'Dublin CBC';
    private static final String zuoraSubscriptionName = 'Test_Zuora_Sub_Name';
    private static final String zuoraCustAccountName = 'Test_Zuora_CustAccName';
    private static final String zuoraSubProdChargeName = 'Test_Zuora_SubProdChargeName';

    private static Boolean isdataCreated = false;

    static void setup(){
        TetrisContactModel contactModelObj = new TetrisContactModel();

        contactModelObj.firstName = StringUtils.createRandomString(5);
        contactModelObj.lastName = StringUtils.createRandomString(5);
        contactModelObj.email = 'test@test.com';
        contactModelObj.phone = '252 142 1111';

        TetrisAddressModel billTo = new TetrisAddressModel();
        billTo.addressLine1='123 St';
        billTo.city='London';
        billTo.country='United Kingdom';
        TetrisAccountResultModel tetrisAccObject = TetrisAccountServiceV2.createAccount(accountName, encryptedCartId , false , transactionType, salesOffice, TetrisTestDataFactory_New.USER_LOCALE,
                TetrisTestDataFactory_New.USER_CURENCY , contactModelObj , billTo , true, false);
        createZuoraRecords(zuoraSubscriptionName,
                zuoraCustAccountName,
                zuoraSubProdChargeName,
                tetrisAccObject.accountId
        );
        isdataCreated = true;
    }

    // seeAllData should not be set to true. Here we are using Zuora objects in the method calls
    // which's throwing WSDL error if seeAllData != true.
    // ref: https://community.zuora.com/t5/API/quot-Zuora-zAPIException-Please-upload-Zuora-WSDL-at-first-quot/td-p/2214
    // seeAllData should be removed and @testSetup should be used once we figure out this zuora issue
    @isTest(seeAllData=true) static void getZuoraNextInvoiceDateTest(){
        if(isdataCreated != true){
            setup();
        }
        List<Zuora__Subscription__c> lstsageAcctSubscription = [SELECT Id,Zuora__Zuora_Id__c FROM Zuora__Subscription__c where Name = :zuoraSubscriptionName];

        Zuora__SubscriptionProductCharge__c ratePlanCharge = new Zuora__SubscriptionProductCharge__c();
        ratePlanCharge.Zuora__RatePlanId__c = '2c92c0f85ec6e9f4015ec92f41a64220';
        ratePlanCharge.Zuora__Model__c ='Volume Pricing';
        ratePlanCharge.Zuora__ProductSKU__c = 'S1GBBUN04B';
        ratePlanCharge.Zuora__Subscription__c = lstsageAcctSubscription[0].Id;
        insert ratePlanCharge;

        TetrisZuoraModel resultObj = TetrisZuoraEffectiveDatesServiceV2.getZuoraNextInvoiceDate(lstsageAcctSubscription[0].Zuora__Zuora_Id__c);
        System.debug('Get Date Result: '+resultObj);
        System.assertEquals(((DateTime)System.today()).date(), resultObj.nextInvoiceDate);
    }

    @isTest static void getZuoraNextInvoiceDateTestException(){
        if(isdataCreated != true){
            setup();
        }
        TetrisZuoraModel resultObj = TetrisZuoraEffectiveDatesServiceV2.getZuoraNextInvoiceDate('');
        System.debug('Get Date Result: '+resultObj);
        System.assertEquals('EXCEPTION_SUBSCRIPTION_INVALID_ZUORA_SUBSCRIPTION_NUMBER', resultObj.message);
    }


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
        zuoraSubChargeObj.Zuora__ProductSKU__c = 'S1GBBUN04B';
        zuoraSubChargeObj.BundleDescription__c = 'Bundle';
        zuoraSubChargeObj.BundleInstanceId__c = '2c92c0fa61789dfe01618bc0869314e0';
        zuoraSubChargeObj.BundleName__c = 'Bundle';
        insert zuoraSubChargeObj;
    }

}