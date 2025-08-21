@isTest(SeeAllData=false) 
private class TetrisCartItemTierModel_Test {

    static testMethod void testSettersGetters() {
    		TetrisCartItemTierModel tetrisCM = new TetrisCartItemTierModel();
       	tetrisCM.tierAttribute = 'Employee';
	    	tetrisCM.tierQuantity = 1.0;
	    tetrisCM.tierDescription = 'Payroll Product';

	    system.assertEquals(tetrisCM.tierAttribute , 'Employee') ;
	    system.assertEquals(tetrisCM.tierQuantity , 1.0) ;
	    system.assertEquals(tetrisCM.tierDescription , 'Payroll Product');
    }
}