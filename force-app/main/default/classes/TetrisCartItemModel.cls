global class TetrisCartItemModel {	
	global String productId;
	global String productName;
    global String productShortDescription;
    global String productLongDescription;
    
    global String sku;
    global Decimal quantity;
    global String bundleSKU;
    global String bundleDescription;
    global List<TetrisCartItemTierModel> tier;
    
    global Integer trialLength;
    global Decimal absoluteDiscount;
    global Decimal percentageDiscount;
    global Decimal adjustmentAmount;
    global Decimal subAmount;
    global Decimal taxAmount;
    global Decimal taxPercentage;
    
    global String category;
    
    global Decimal price;
    global String pricingType;
    
    global String subProdTermId;
    global Decimal subscriptionFrequency;
    global Decimal subscriptionDuration;
    global String subscriptionTermId;

	global String cartItemId;
    global String cartItemNumber;
    
    global String cartItemType;
    global String comments;
    
    global DateTime contractEffectiveDate;
    global DateTime contractStartDate;

    global String couponCode;
    global String couponType;
    global String couponMessage;
	global String couponShortDescription;
	global String couponLongDescription;
    
    global String productType;
    global Boolean isTierPriced;
    global String isProductBundle;
    
    global List<TetrisPriceTierModel> tierPrice;
    
    global String sageInternalProduct;
    
    global String parentProductBundleSKU;
    global String parentProductBundleDescription;
    global String tierDescription;
    
    //Guided Selling
    global String identityProvider;
    
}