@isTest(SeeAllData=false) 
private class TetrisPriceTierModel_Test {

    static testMethod void testSettersGetters() {
    		TetrisPriceTierModel tetrisPriceTModel = new TetrisPriceTierModel();
    		tetrisPriceTModel.tierAttribute = 'Employee';
    		tetrisPriceTModel.minQuantity = 1;
    		tetrisPriceTModel.maxQuantity = 1;
    		tetrisPriceTModel.listPrice = 15.99;
    		tetrisPriceTModel.bundleDiscountedPrice = 10.99;
    		tetrisPriceTModel.tierDescription = 'Sample Product';
    }
}