global class TetrisProductModel extends TetrisBaseModel {
		//core set of attributes related to product
		global String productId {get;set;} 
		global String productType {get;set;} // in json: type
		global String productName {get;set;} 
		global String productSKU {get;set;} 
		global String alternateName {get;set;} 
		global String status {get;set;} 
    	//remove market. no longer being used
		global String market {get;set;} 
		global String country {get;set;} 
    	global String productLocale {get; set;}
		
    	global String productFamily {get;set;} 
		global String businessSize {get;set;} 
    	global List<String> categories {get;set;} 
		global String industry {get;set;}         
		global List<String> segment {get;set;} 
		global Date startDate {get;set;}  
		global Date endDate {get;set;} 
		global String productLongDescription {get;set;} 
    	global String productShortDescription {get;set;} 
		global String uom {get;set;}  
		global Decimal quantityPerUnit {get;set;} 
 		
    	global String storefront {get; set;}
    
    	//trial related attributes
    	global Boolean trial {get;set;}  
		global Decimal trialLength {get;set;} 
   	    	
    	//pricing setup for product
    	global String soldBy {get;set;}
	   	global Boolean taxable {get;set;} 
		global String vatRule {get;set;}
    	global String feeType {get;set;}
    	global String priceType {get;set;}
    	global String periodOrFrequency {get;set;} 
    	global boolean vatTaxExemptId  {get;set;}
		global String currencyUnit {get;set;} 
    	//global String productSkuChargePeriod {get;set;}

    	global String termsAndConditions {get;set;}
    	global Boolean individuallySold {get;set;}  
		global Decimal cancellationPeriod {get;set;} 
 		global Decimal contractDuration {get;set;}
		
    	//zuora or subscription engine related attributes
		global String billingProductId {get;set;} 
		global String ratePlanId {get;set;} 

    	//product name used in the SF org for CBC. Used in lead tracking
    	global String sageInternalProductName {get; set;}
    	//subscription related attributes
		global String subscriptionDisclaimer {get;set;} 


    	//related products
		global List<TetrisProductModel> crossSellProducts {get;set;} 
		global List<TetrisProductModel> upSellProducts {get;set;} 
		global TetrisProductModel buyProduct {get;set;} 
		global TetrisProductModel trialProduct {get;set;} 

    	global Boolean isBundledProduct {get; set;}
		//bundle related attributes
    	global List<TetrisProductModel> bundledProducts {get;set;} 
    	global Double bundleListPrice {get;set;} 
    	global Double bundleDiscountedPrice {get;set;}     
    	global Double bundleSavingsPercentage {get;set;} 
    	//bundle component related attributes
    	global Boolean bundleComponentIsOptional {get; set;}
    	global String bundleComponentDescription {get; set;}

    	//pricing related attributes
    	global Boolean tieredPricing {get;set;}  
		global List<TetrisPriceModel> price {get;set;} 
		
		//Entitlement Product Id
		global String tierCode {get; set;}
		//SLCS subscription events 
		global String slcsSubscriptionEventsUrl{get; set;}
	    global String entitlementProductId {get; set;}
    
	    global String taxCode {get; set;}
    
    	//Identity Provider for Guided Selling
    	global String identityProvider {get; set;}
}