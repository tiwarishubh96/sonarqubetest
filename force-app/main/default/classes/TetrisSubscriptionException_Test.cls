@isTest(SeeAllData=false) 
private class TetrisSubscriptionException_Test {

    static testMethod void testTetrisSubscriptionException() {
		Test.startTest();
        system.assertEquals(TetrisSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_SUBSCRIPTION_ID , 'EXCEPTION_SUBSCRIPTION_INVALID_SUBSCRIPTION_ID') ;
        system.assertEquals(TetrisSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_ACCOUNT_ID , 'EXCEPTION_SUBSCRIPTION_INVALID_ACCOUNT_ID') ;
        system.assertEquals(TetrisSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_USER_IDENTITY_ID ,'EXCEPTION_SUBSCRIPTION_INVALID_USER_IDENTITY_ID') ;
        system.assertEquals(TetrisSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_ORDER_ID , 'EXCEPTION_SUBSCRIPTION_INVALID_ORDER_ID') ;
        Test.stopTest();    
    }
}