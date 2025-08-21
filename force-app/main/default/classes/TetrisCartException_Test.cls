@isTest(SeeAllData=false) 
private class TetrisCartException_Test {
	
     static testMethod void testTetrisCartException() {
        
        Test.startTest();
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_BUNDLE_SKU , 'EXCEPTION_CART_INVALID_BUNDLE_SKU') ;
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_PRODUCT_SKU , 'EXCEPTION_CART_INVALID_PRODUCT_SKU') ;
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_CART_ID ,'EXCEPTION_CART_INVALID_CART_ID') ;
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_CONTACT_ID , 'EXCEPTION_CART_INVALID_CONTACT_ID') ;
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_ACCOUNT_ID , 'EXCEPTION_CART_INVALID_ACCOUNT_ID') ;
        system.assertEquals(TetrisCartException.EXCEPTION_EMPTY_CART_REMOVE_FAILED , 'EXCEPTION_CART_EMPTY_CART_REMOVE_FAILED') ;
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_COUPON , 'EXCEPTION_CART_INVALID_COUPON_CODE') ;
        
        system.assertEquals(TetrisCartException.EXCEPTION_EXPIRED_COUPON , 'EXCEPTION_CART_EXPIRED_COUPON_CODE') ;
        system.assertEquals(TetrisCartException.EXCEPTION_INVALID_AMOUNT_FOR_COUPON , 'EXCEPTION_CART_INVALID_AMOUNT_FOR_COUPON') ;
        system.assertEquals(TetrisCartException.EXCEPTION_PRODUCT_COUPON_LIMIT , 'EXCEPTION_CART_PRODUCT_COUPON_LIMIT') ;
        system.assertEquals(TetrisCartException.EXCEPTION_CART_COUPON_LIMIT , 'EXCEPTION_CART_CART_COUPON_LIMIT') ;
        system.assertEquals(TetrisCartException.EXCEPTION_COUPON_NOT_APPLIED , 'EXCEPTION_CART_COUPON_NOT_APPLIED') ;
        system.assertEquals(TetrisCartException.EXCEPTION_CREATE_CART , 'EXCEPTION_CART_CREATE_CART') ;
        system.assertEquals(TetrisCartException.EXCEPTION_APPLY_COUPON , 'EXCEPTION_CART_APPLY_COUPON') ;
        system.assertEquals(TetrisCartException.EXCEPTION_UPDATE_CART , 'EXCEPTION_CART_UPDATE_CART') ;
        system.assertEquals(TetrisCartException.EXCEPTION_ADD_TO_CART , 'EXCEPTION_CART_ADD_TO_CART') ;
        system.assertEquals(TetrisCartException.EXCEPTION_REMOVE_FROM_CART , 'EXCEPTION_CART_REMOVE_FROM_CART') ;
        system.assertEquals(TetrisCartException.EXCEPTION_CREATE_SUBSCRIPTION_FROM_CART , 'EXCEPTION_CART_CREATE_SUBSCRIPTION_FROM_CART') ;
        Test.stopTest();
    }
}