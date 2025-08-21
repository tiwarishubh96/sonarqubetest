@isTest(SeeAllData=false)
private class TetrisAccountModel_Test {

    static testMethod void testSetterGetter() {
    		TetrisAccountModel tm = new TetrisAccountModel();
    		tm.accountName = 'Test Account';
    		tm.zuoraAccountId = '123123';
    		tm.zuoraAccountNumber = 'c-03242';
    		tm.zuoraId = '231312';
    		system.assertEquals(tm.accountName, 'Test Account') ;
    		system.assertEquals(tm.zuoraAccountId , '123123') ;
    		system.assertEquals(tm.zuoraAccountNumber, 'c-03242') ;
    		system.assertEquals(tm.zuoraId , '231312') ;
    }
}