global class TetrisPriceModel {
    
	global string productId {get;set;}
	global string productName {get;set;}
    global String feeType {get;set;}
    global String priceType {get;set;}
    
    global String currencyCode {get;set;} 
	
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    
    global boolean enabled {get;set;}
    
    global String listID {get;set;} 
	global String listItemID {get;set;} 
	global String listName {get;set;} 
	global Double listPrice {get;set;} 
	global Decimal minQuantity {get;set;}  
	global Decimal maxQuantity {get;set;} 
	global Boolean recurringPrice {get;set;} 
	//global String source {get;set;} 
	//global Double subAmount {get;set;}  
	global String unitOfMeasure {get;set;}   

		global String subscriptionTermId {get;set;} 
    	global Long subscriptionDuration {get;set;} 
		global String subscriptionFrequency {get;set;} 
 		global Boolean subscriptionAutoRenewal {get;set;} 
		global Boolean availableForSubscription {get;set;} 
		global Decimal subscriptionInstallmentCount {get;set;} 
		global Decimal subscriptionInstallmentFrequency {get;set;} 
		global String subscriptionInstallmentUOM {get;set;} 

    global list<TetrisPriceTierModel> tierPriceList {get;set;} 
    global Double bundledComponentPrice {get;set;} 


}