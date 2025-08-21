global class TetrisZuoraModel extends TetrisBaseModel{
    
  global List<ProductRatePlanJSON> productList;
  global List<RatePlanChargeJSON> ratePlanList;
  global Date nextInvoiceDate {get; set;} 
  global Date discountEndDate {get; set;}
  global Date effectiveStartDate {get; set;}    
 
  global class RatePlanChargeJSON {
    global String ratePlanId {get; set;}
    global string contractEffectiveDate {get; set;}     
    }
    
   global class ProductRatePlanJSON {
       global String productRatePlanId {get; set;}
       global string contractEffectiveDate {get; set;}
       global List<Map<String,String>> chargeOverrides {get; set;}              
                 }
}