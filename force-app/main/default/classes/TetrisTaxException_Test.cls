@isTest(SeeAllData=false) 
private class TetrisTaxException_Test {

    static testMethod void testTetrisTaxException() {
		Test.startTest();
        system.assertEquals(TetrisTaxException.EXCEPTION_TAX_CALLOUT , 'EXCEPTION_TAX_CALLOUT') ;
        system.assertEquals(TetrisTaxException.EXCEPTION_TAX_SERVICE_ERROR , 'EXCEPTION_TAX_SERVICE_ERROR') ;
        Test.stopTest();     
    }
}