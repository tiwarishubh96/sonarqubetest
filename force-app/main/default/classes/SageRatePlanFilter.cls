//Zuora custom plugin to filter rate plans based on the locale at the Account
//Docmation 2016-07-19
//
global class SageRatePlanFilter implements zqu.SelectProductComponentOptions.IFilterPlugin {
    String quoteId;
    
    public SageRatePlanFilter() {
        //get the quote ID
        quoteId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public String getProductSoqlFragment() {
        return '';
    }
    
    /*** Returns the Rateplan Filter SOQL Fragment that filters by billing frequency */
    public String getRateplanSoqlFragment() {
        
        String soqlFragment = ' ';
        String conditionStr = '';
        Integer i = 0;
        //isFoundation Field is used to retrieve the ratePlans related to SageFoundation
        Boolean isFoundation=false;
        Boolean isValidEligibleDate=false;
        
        //Get the locale tied to the quote account
        zqu__Quote__c q = [SELECT zqu__Account__r.Locale__c, zqu__Account__r.Foundation_Customer__c,zqu__Account__r.Eligibility_Expiration_Date__c FROM zqu__Quote__c  where id = :quoteId];
        Id locale = q.zqu__Account__r.locale__c;
        //Get the status of Sage Foundation Customer from Quote account
        String foundationCustomerStatus = q.zqu__Account__r.Foundation_Customer__c;
        Date eligibilityExpirationDate = q.zqu__Account__r.Eligibility_Expiration_Date__c;
        // get the eligibility date and it should be greater than Today
        isValidEligibleDate=eligibilityExpirationDate > Date.today()?true:false;
        
        //if Sage Foundation Customer status is set to Approved then update the isFoundation to true else false
        isFoundation = foundationCustomerStatus == 'Approved'?true:false;
        
        // Set isFoundation to true only both isFoundation and isValidEligibleDate were true
        isFoundation = (isFoundation && isValidEligibleDate );
       // System.debug('isFoundation' +isFoundation );
      
       
        
        if (locale != null) {
            try{
                //Get the Product Rate Plan Ids that need to be displayed
                //Product_Tier_Rate_Plan__c maps the zProduct_Rate_Plan to the Locale
                
                List<Product_Tier_Rate_Plan__c> listOfprpIDs =Database.query('SELECT Product_Rate_Plan__c,is_Foundation__c FROM Product_Tier_Rate_Plan__c WHERE locale__C =: locale AND Product_Rate_Plan__c != null And Is_Foundation__c =: isFoundation');
                Set< Product_Tier_Rate_Plan__c> prpIDs = new Set<Product_Tier_Rate_Plan__c>(listOfprpIDs);
                
                 System.debug('conditionStr  ' + conditionStr);
                 System.debug('soqlFragment '+soqlFragment );
                //Building the soqlFragment that will be used to 
                //further limit the rate plan
                //
                //
                if (prpIDs != null && prpIDs.size() == 0) {
                        conditionStr=null;
                        soqlFragment = ' Id = ' + conditionStr;  
                }
                
                if (prpIDs != null && prpIDs.size() > 0) {
                    for (Product_Tier_Rate_Plan__c rp: prpIDs) {
                        if (i > 0){
                            conditionStr = conditionStr + ', \''+ rp.Product_Rate_Plan__c + '\'' ;
                        } else {
                            conditionStr = '(\''+ rp.Product_Rate_Plan__c + '\'';
                            i++;
                        }
                    }
                    
                    conditionStr = conditionStr + ')';
                    System.debug('conditionStr  ' + conditionStr);
                    soqlFragment = ' Id IN ' + conditionStr;
                    System.debug('soqlFragment '+soqlFragment );
                    
                }
                
                 
            } catch (exception e) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            }  
        }
      
    
        return soqlFragment;
    }
    
}