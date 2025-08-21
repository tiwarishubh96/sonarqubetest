@isTest(SeeAllData=false) 
private class TetrisCartItemModel_Test {
	
    static testMethod void testTetrisCartItemModel() {
        TetrisCartItemModel tcModel = new TetrisCartItemModel();
        tcModel.productId = '0021312';
        tcModel.productShortDescription = 'Sample Product';
        tcModel.productLongDescription = 'Sample Product long description';
        
        tcModel.sku = '1231';
        tcModel.quantity = 1.0;
        tcModel.bundleSKU = 'bundle123';
        
        TetrisCartItemTierModel tierModel = new TetrisCartItemTierModel();
        tierModel.tierAttribute = 'Employee';
        tierModel.tierQuantity = 1.0 ;
        tierModel.tierDescription =  'Tier Product';
        List<TetrisCartItemTierModel> lstTier = new List<TetrisCartItemTierModel>();
        lstTier.add(tierModel);
        tcModel.tier = lstTier;
        
        tcModel.absoluteDiscount = 10;
        tcModel.percentageDiscount = 10;
        tcModel.adjustmentAmount = 10;
        tcModel.subAmount = 5;
        
        tcModel.category = 'Product Category';
        
        tcModel.subProdTermId = '01312111';
   		tcModel.subscriptionFrequency = 12;
    		tcModel.subscriptionDuration = 12;
    		tcModel.subscriptionTermId = '12321312';
    		
    		
    		tcModel.cartItemId = '02342342342';
    		tcModel.cartItemNumber = '12312';
    
    		tcModel.cartItemType = 'trial';
    		tcModel.comments = 'Sample Cart';
    
    		tcModel.contractEffectiveDate = system.now();
    		tcModel.contractStartDate = system.now();

    		tcModel.couponCode = 'GBS1TEN';
    		tcModel.couponType = 'Product';
    		tcModel.couponMessage = '10% Discount';
		tcModel.couponShortDescription = 'Coupon 10% Discount short Description';
		tcModel.couponLongDescription = 'Coupon 10% Discount long Description';
    
    		tcModel.productType = 'trial';
    		tcModel.isTierPriced = false;
    		tcModel.isProductBundle = 'FALSE';
    
    		List<TetrisPriceTierModel> tierPrice = new List<TetrisPriceTierModel>();
    		TetrisPriceTierModel trPriceModel = new TetrisPriceTierModel();
    		trPriceModel.tierAttribute = 'Employee';
	    trPriceModel.minQuantity = 1.0;
	    trPriceModel.maxQuantity = 1.0; 
	   	trPriceModel.listPrice = 9.99; 
	    trPriceModel.bundleDiscountedPrice = 15.99; 
		trPriceModel.tierDescription = 'Payroll Tier Product';
		tierPrice.add(trPriceModel);
		
		tcModel.tierPrice  = tierPrice;
    		
        
    }
}