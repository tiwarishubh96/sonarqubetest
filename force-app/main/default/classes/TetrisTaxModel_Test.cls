@isTest(SeeAllData=false) 
private class TetrisTaxModel_Test {

    static testMethod void testSettersGetters() {
		TetrisTaxModel tetrisTaxModelObj = new TetrisTaxModel();
		tetrisTaxModelObj.country = 'United Kingdom';
		tetrisTaxModelObj.taxAmount = 2;
		tetrisTaxModelObj.taxRate = 20;
		tetrisTaxModelObj.taxableAmount = 2;
		tetrisTaxModelObj.totalAmount = 18;
    }
}