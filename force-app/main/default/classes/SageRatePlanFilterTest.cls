@isTest
public class SageRatePlanFilterTest {
    
    private static Datetime todaysDate;
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class 

    /**
    * Testing the SageRatePlan a Z Product
    * @param name of the ZProduct to create
    * @return ZProduct record created
    **/
    
    static testmethod void validateSageRatePlanFilter() {
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        
        // setup product tier and product tier rate plan lists
        Product2 prod = TestDataUtility.createZProduct('Sage One Start', zuoraId);
        zqu__ProductRatePlan__c ratePlan = TestDataUtility.createRatePlan(prod.Id, 'Monthly', zuoraId);
       
        
        Product_Tier__c pTier = TestDataUtility.createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US');
        Product_Tier_Rate_Plan__c pTierRate = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Monthly');
        Product_Tier_Rate_Plan__c pTierRate1 = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Annual');

        
		boolean isFoundation=false;
        String conditionStr='';
        Integer i=0;
        //Construct the SOQL String
       List<Product_Tier_Rate_Plan__c> ptrpList= [SELECT Product_Rate_Plan__c,is_Foundation__c FROM Product_Tier_Rate_Plan__c WHERE locale__C =:loc.id  AND Product_Rate_Plan__c != null And Is_Foundation__c =: isFoundation];
    
       String soqlStr = ('Id IN (\''+ptrpList[0].Product_Rate_Plan__c +'\', \''+ ptrpList[1].Product_Rate_Plan__c + '\')').trim();
       System.debug('soqlSTR test:'+ soqlStr);

        //call the zuora plugin
        //
        apexpages.currentpage().getparameters().put('id' , zquote.Id);
        SageRatePlanFilter srf = new SageRatePlanFilter();
        String soqlFragment = srf.getRateplanSoqlFragment().trim();
		System.debug('soqlFragment test '+soqlFragment);
        System.assertEquals(soqlFragment,soqlStr) ;  
        
        String productSoqlFragment =srf.getProductSoqlFragment();
        System.assertEquals('', productSoqlFragment);

        
    }
    
    

      /**
    * Testing the SageRatePlan for Foundation  a Z Product
    * @param name of the ZProduct to create
    * set the foundation customer status to Aprroved and a valid Eligibility Criteria Date
    * @return ZProduct record created
    **/
    
    static testmethod void validateSageRatePlanFilterWithFoundationPlan() {
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        acc.Foundation_Customer__c='Approved';
        acc.Eligibility_Expiration_Date__c=Date.today().addDays(30);
        update acc;
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        
        // setup product tier and product tier rate plan lists
        Product2 prod = TestDataUtility.createZProduct('SageFoundation', zuoraId);
        zqu__ProductRatePlan__c ratePlan = TestDataUtility.createRatePlan(prod.Id, 'Monthly', zuoraId);
       
       Product_Tier__c pTier = TestDataUtility.createProductTier(prod.Id, 'SageFoundation Start US', 'SageFoundation-Start-US');
       Product_Tier_Rate_Plan__c pTierRate = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Monthly',true);
        boolean isFoundation=true;
        //Construct the SOQL String
        //
        System.debug('Product_Tier_Rate_Plan__c '+pTierRate);
        //
        Product_Tier_Rate_Plan__c ptrpList= [SELECT Product_Rate_Plan__c,is_Foundation__c FROM Product_Tier_Rate_Plan__c WHERE locale__C =:loc.id  AND Product_Rate_Plan__c != null And Is_Foundation__c =: isFoundation LIMIT 1];
        System.debug('ptrpList' +ptrpList);
        String soqlStr = ('Id IN (\''+ptrpList.Product_Rate_Plan__c +'\')').trim();
        system.debug('soqlSTR:'+ soqlStr);

        //call the zuora plugin
        //
        apexpages.currentpage().getparameters().put('id' , zquote.Id);
        SageRatePlanFilter srf = new SageRatePlanFilter();
        String soqlFragment = srf.getRateplanSoqlFragment().trim();

       system.assertEquals(soqlFragment,soqlStr) ;  
		}


         /**
    * Testing the SageRatePlan for Foundation  a Z Product with No RatePlan
    * @param name of the ZProduct to create
    * set the foundation customer status to Aprroved and a valid Eligibility Criteria Date
    * @return ZProduct record created
    **/
    
    static testmethod void validateSageRatePlanFilterWithNoFoundationRatePlan() {
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        acc.Foundation_Customer__c='Approved';
        acc.Eligibility_Expiration_Date__c=Date.today().addDays(30);
        update acc;
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        
        // setup product tier and product tier rate plan lists
        Product2 prod = TestDataUtility.createZProduct('SageFoundation', zuoraId);
        zqu__ProductRatePlan__c ratePlan = TestDataUtility.createRatePlan(prod.Id, 'Monthly', zuoraId);
       
       Product_Tier__c pTier = TestDataUtility.createProductTier(prod.Id, 'SageFoundation Start US', 'SageFoundation-Start-US');
       Product_Tier_Rate_Plan__c pTierRate = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Monthly',false);
        boolean isFoundation=true;
        Product_Tier_Rate_Plan__c ptrpList =null;
        String  soqlStr = 'Id = null';
        //Construct the SOQL String
        //
        System.debug('Product_Tier_Rate_Plan__c '+pTierRate);
        //
        try{
        ptrpList= [SELECT Product_Rate_Plan__c,is_Foundation__c FROM Product_Tier_Rate_Plan__c WHERE locale__C =:loc.id  AND Product_Rate_Plan__c != null And Is_Foundation__c =: isFoundation LIMIT 1];
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
        }
        apexpages.currentpage().getparameters().put('id' , zquote.Id);
        SageRatePlanFilter srf = new SageRatePlanFilter();
        String soqlFragment = srf.getRateplanSoqlFragment().trim();

       system.assertEquals(soqlFragment,soqlStr) ;  
        }
}