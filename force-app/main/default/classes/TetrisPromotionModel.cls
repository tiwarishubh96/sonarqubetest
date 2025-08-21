global class TetrisPromotionModel {
    global id id {get;set;}
    global String promotionName {get;set;}
    global String promotionTargetSKU {get;set;}
    global String promotioncode {get;set;}
	global Date startDate {get;set;}	
	global Date endDate {get;set;}  
	global String promotionType {get;set;}
	global Decimal promotionValue {get;set;}
	global Integer promotionDuration {get;set;}
	global String promotionPeriod {get;set;}
	global String storefront {get;set;}
    global String shortDescription {get; set;}
    global String longDescription {get; set;}
    global Boolean enabled {get; set;}

    // Added By Neha Mishra|Docmation for EADAPPI-378
    global String foundationPromotionType {get; set;}
    // @Rishu Garg Docmation (EADAPPI-926) 11/17/2020
    global Decimal promotionLength {get;set;}
}