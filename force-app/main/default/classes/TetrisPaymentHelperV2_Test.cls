/**
 * Created by cafe on 2/4/2021.
 */
@isTest(SeeAllData=true)
private class TetrisPaymentHelperV2_Test {

    private static final String SAGE_PRODUCT = 'sage_product';
    private static final String SAGE_PRODUCT_SUBPROD = 'sage_product_subProdTermId' ;
    private static final String SAGE_PRODUCT_COUPON = 'sage_product_coupon';
    private static final String SAGE_PRODUCT_TIERED = 'sage_product_tiered';
    private static final String SAGE_PRODUCT_TIERED_SUBPROD = 'sage_product_tiered_subProdTermId' ;
    private static final String STORE_FRONT = 'DefaultStore';
    private static final String PORTAL_USER_NAME = 'Storefront Community Site Guest User';
    private static final String USER_LOCALE = 'en_GB';
    private static final String USER_CURENCY = 'GBP';
    private static final String ACCOUNT_SALES_OFFICE = 'Dublin CBC';
    private static final String ZUORA_ACCOUNT_ID = '2c92c0fa61789dfe01618bc0869314e0';
    private static final String PAYMENTMETHOD_ID = '2c92c0fa61789dfe01618bc0869114e0';
    private static final String ZUORA_SUBSCRIPTION_ID = '2c92c0fa61789dfe01618bc0869314e1';
    private static final String ZUORA_SUBSCRIPTION_NUMBER = 'C-S00000001';
    private static Map<String, String> mapTestData = null;

    static {

    }

    static testMethod void testGetPaymentPageSettings() {
        TetrisPaymentHelperV2 TetrisPaymentHelperV2Obj = new TetrisPaymentHelperV2();
        String countryCode = 'GB';
        String paymentMethod = 'Credit Card';
        TetrisPaymentModel tetrisPaymentModelObject = TetrisPaymentHelperV2Obj.getPaymentPageSettings(countryCode, paymentMethod);
    }

    static testMethod void testGetZuoraAPIConnectionConfig() {
        TetrisPaymentHelperV2 TetrisPaymentHelperV2Obj = new TetrisPaymentHelperV2();
        ZuoraPaymentPageSetting__c zuoraPaymentPageSetting = TetrisPaymentHelperV2Obj.getZuoraAPIConnectionConfig();
    }

    static testMethod void testGetZuoraTenantInfo() {
        TetrisPaymentHelperV2 TetrisPaymentHelperV2Obj = new TetrisPaymentHelperV2();
        ZuoraPaymentPageSetting__c zuoraPaymentPageSetting = TetrisPaymentHelperV2Obj.getZuoraAPIConnectionConfig();
        String pageId = '';
        TetrisPaymentModel.PaymentMethod tetrisPaymentModelObj = TetrisPaymentHelperV2Obj.getZuoraTenantInfo(zuoraPaymentPageSetting, pageId);
    }

    static testMethod void testGetPaymentPages() {
        TetrisPaymentHelperV2 TetrisPaymentHelperV2Obj = new TetrisPaymentHelperV2();
        ZuoraPaymentPageSetting__c zuoraPaymentPageSetting = TetrisPaymentHelperV2Obj.getZuoraAPIConnectionConfig();
        String countryCode = 'GB';
        String paymentMethod = 'Credit Card';
        TetrisPaymentModel tetrisPaymentModelObj = TetrisPaymentHelperV2Obj.getPaymentPages(zuoraPaymentPageSetting,
                countryCode, paymentMethod);
        system.debug('-----tetrisPaymentModelObj----------' + tetrisPaymentModelObj);
    }

    static testMethod void testGetPaymentPages_Exceptions() {
        TetrisPaymentHelperV2 TetrisPaymentHelperV2Obj = new TetrisPaymentHelperV2();
        ZuoraPaymentPageSetting__c zuoraPaymentPageSetting = TetrisPaymentHelperV2Obj.getZuoraAPIConnectionConfig();
        String countryCode = 'GB1';
        String paymentMethod = 'Credit Card';
        try {
            TetrisPaymentModel tetrisPaymentModelObj = TetrisPaymentHelperV2Obj.getPaymentPages(zuoraPaymentPageSetting,
                    countryCode, paymentMethod);
            system.debug('-----tetrisPaymentModelObj----------' + tetrisPaymentModelObj);
        } catch (Exception expObj) {
            System.assertEquals(expObj.getMessage(), expObj.getMessage());
        }
    }

    static testMethod void testaddItemToZAccountList() {
        Test.startTest();
        TetrisPaymentHelperV2 TetrisPaymentHelperV2Obj = new TetrisPaymentHelperV2();
        TetrisPaymentHelperV2Obj.addItemToZAccountList(null, null);
        Test.StopTest();
    }
}