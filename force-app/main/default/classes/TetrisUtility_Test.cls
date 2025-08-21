@isTest(SeeAllData=true)
private class TetrisUtility_Test {

    private static final String SAGE_PRODUCT = 'sage_product';
    private static final String SAGE_PRODUCT_SUBPROD = 'sage_product_subProdTermId' ;
    private static final String SAGE_PRODUCT_COUPON = 'sage_product_coupon';
    private static final String SAGE_PRODUCT_TIERED = 'sage_product_tiered';
    private static final String SAGE_PRODUCT_TIERED_SUBPROD = 'sage_product_tiered_subProdTermId' ;
    private static final String SAGE_PRODUCT_ABS_COUPON = 'sage_product_abs_coupon';
    private static final String SAGE_PRODUCT_PER_COUPON = 'sage_product_per_coupon';
    private static final String SAGE_PRODUCT_TIER_ABS_COUPON = 'sage_product_tier_abs_coupon';
    private static final String SAGE_PRODUCT_TIER_PER_COUPON = 'sage_product_tier_per_coupon';
    private static final String STORE_FRONT = 'DefaultStore';
    private static final String PORTAL_USER_NAME = 'Storefront Community Site Guest User';
    private static final String USER_LOCALE = 'en_GB';
    private static final String USER_CURENCY = 'GBP';
    private static final String ACCOUNT_SALES_OFFICE = 'Dublin CBC';
    private static final String USER_IDENTITY_ID = '123-123-1212';
    private static final String USER_EMAIL = 'test@sage.com';
    private static final String EFFECTIVE_DATE = String.valueOf(date.today());
    // private static final String USER_IDENTITY_ID = '53dcf5b3-ad86-4ddd-844b-79b828c538de';
    private static final String SLCS_SUBSCRIPTION_ID='6f0e3059-e045-48fe-967b-3284e627a0fe';
    private static final String SLCS_SUBSCRIPTION_GROUP_ID ='e3059-967b-e045-48fe-3284e62';
    private static final String SLCS_CLIENT_REF='1231';
    private static final String ENTITLEMENT_ID='bd4ec839-c9bd-484f-b3c0-7f1b5491fb04';
    private static final String ACTIVITY_ID='c9bd-484f-b3c0-7f1';
    private static final String ZUORA_ACCOUNT_NUMBER='C00000001';
    private static final String ZUORA_SUBSCRIPTION_ID='2c92c0fa61789dfe01618bc0869314e1';
    private static final String ZUORA_SUBSCRIPTION_NUMBER='C-S00000001';
    private static String tetrissubscriptionId;
    private static String strCartId;
    private static String localeId;
    private static String cartSalesforceID;
    private static String accountId = null;

    static testMethod void testoauthLogin() {
        test.startTest();
        TetrisUtility.MuleLoginVO muleLoginObj = TetrisUtility.oauthLogin();
        test.stopTest();
    }

}