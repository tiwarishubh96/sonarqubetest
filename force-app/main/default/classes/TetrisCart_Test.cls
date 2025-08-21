@isTest(SeeAllData=false) 
private class TetrisCart_Test {
    static testMethod void testSettersGetters() {
    	Test.startTest();
        system.assertEquals('Abandoned', TetrisCart.CART_STATUS_ABANDONED);
        system.assertEquals('Account Created', TetrisCart.CART_STATUS_ACCOUNT_CREATED);
        system.assertEquals('Closed', TetrisCart.CART_STATUS_CLOSED);
        system.assertEquals('Open', TetrisCart.CART_STATUS_OPEN);
        system.assertEquals('Product Provisioned', TetrisCart.CART_STATUS_PRODUCT_PROVISIONED);
        system.assertEquals('Provision Pending', TetrisCart.CART_STATUS_PROVISION_PENDING);
        system.assertEquals('buy', TetrisCart.CART_TRANSACTION_TYPE_BUY);
        system.assertEquals('convert', TetrisCart.CART_TRANSACTION_TYPE_CONVERT);
        system.assertEquals('cross sell', TetrisCart.CART_TRANSACTION_TYPE_CROSSSELL);
        system.assertEquals('downgrade', TetrisCart.CART_TRANSACTION_TYPE_DOWNGRADE);
        system.assertEquals('trial', TetrisCart.CART_TRANSACTION_TYPE_TRIAL);
        system.assertEquals('upgrade', TetrisCart.CART_TRANSACTION_TYPE_UPGRADE);
        system.assertEquals('upsell', TetrisCart.CART_TRANSACTION_TYPE_UPSELL);
        system.assertEquals('CartAuthUserValidated', TetrisCart.CART_VALIDATION_STATUS_VALIDATED);
        system.assertEquals('CartTotal', TetrisCart.COUPON_RULE_TYPE_CART_TOTAL);
        system.assertEquals('General', TetrisCart.COUPON_RULE_TYPE_GENERAL);
        system.assertEquals('Absolute', TetrisCart.COUPON_TYPE_ABSOLUTE);
        system.assertEquals('Percentage', TetrisCart.COUPON_TYPE_PERCENTAGE);
        system.assertEquals('Price', TetrisCart.COUPON_TYPE_PRICE);
        system.assertEquals('DefaultStore', TetrisCart.DEFAULT_STORE);
        Test.stopTest();
   	}

}