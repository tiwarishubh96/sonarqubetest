@isTest(SeeAllData=false)
private class TetrisAddressModel_Test {

    static testMethod void testSettersGetters() {
        TetrisAddressModel tetrisModel = new TetrisAddressModel();
    		tetrisModel.addressLine1 = 'Wharfedale Road';
    		tetrisModel.addressLine2 = 'Street 1';
    		tetrisModel.city = 'Winnersh';
    		tetrisModel.state = 'Berkwickshire';
    		tetrisModel.country = 'United Kingdom';
    		tetrisModel.postalCode = '12311';
    		system.assertEquals(tetrisModel.addressLine1 , 'Wharfedale Road') ;
    		system.assertEquals(tetrisModel.addressLine2 , 'Street 1') ;
    		system.assertEquals(tetrisModel.city , 'Winnersh') ;
    		system.assertEquals(tetrisModel.state , 'Berkwickshire') ;
    		system.assertEquals(tetrisModel.country , 'United Kingdom') ;
    		system.assertEquals(tetrisModel.postalCode , '12311') ;
    }
}