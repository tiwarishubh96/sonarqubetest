@isTest(SeeAllData=false) 
private class TetrisProductTierModel_Test {

    static testMethod void testSettersGetters() {
    		TetrisProductTierModel tetrisPModel = new TetrisProductTierModel();
    		tetrisPModel.sku = 'GBS1A';
    		tetrisPModel.quantity = 1;
    		
    		List<TetrisProductTierModel.TetrisProductTier> lstTierProductDetails = new List<TetrisProductTierModel.TetrisProductTier>();
    		
    		TetrisProductTierModel.TetrisProductTier tierProduct = new TetrisProductTierModel.TetrisProductTier();
    		tierProduct.tierAttribute = 'Employee';
    		tierProduct.tierQuantity = '1';
    		lstTierProductDetails.add(tierProduct);
    		
    		tetrisPModel.tier = lstTierProductDetails;
    }
}