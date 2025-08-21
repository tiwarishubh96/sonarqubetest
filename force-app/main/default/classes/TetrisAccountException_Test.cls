@isTest(SeeAllData=false) 
private class TetrisAccountException_Test {
    
    static testMethod void testTetrisAccountException() {
        
        Test.startTest();
		system.assertEquals(TetrisAccountException.EXCEPTION_GET_ACCOUNT, 'EXCEPTION_ACCOUNT_GET_ACCOUNT');
        system.assertEquals(TetrisAccountException.EXCEPTION_CREATE_ACCOUNT , 'EXCEPTION_ACCOUNT_CREATE_ACCOUNT') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_CREATE_CONTACT , 'EXCEPTION_ACCOUNT_CREATE_CONTACT') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_CREATE_LEAD ,'EXCEPTION_ACCOUNT_CREATE_LEAD') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_CREATE_OPPORTUNITY , 'EXCEPTION_ACCOUNT_CREATE_OPPORTUNITY') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_CREATE_OPPORTUNITYLINEITEM, 'EXCEPTION_ACCOUNT_CREATE_OPPORTUNITYLINEITEM') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_UPDATE_ACCOUNT , 'EXCEPTION_ACCOUNT_UPDATE_ACCOUNT') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_UPDATE_CONTACT , 'EXCEPTION_ACCOUNT_UPDATE_CONTACT') ;
        system.assertEquals(TetrisAccountException.EXCEPTION_INVALID_CONTACT_ID , 'EXCEPTION_ACCOUNT_INVALID_CONTACT_ID') ;
        Test.stopTest();
    }
    
}