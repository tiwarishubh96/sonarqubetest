@isTest
public class AccountMergerHelperTest {
    public static Integer expBillingAccsCreated = 1; // It must equal to billing accounts created in testsetup
    
    @testSetup static void setup() {
        String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6'; //universal zuora id, used for each zuora object in this test class
        zqu__Quote__c zQuote;
        Product2 zProduct;
        zqu__ProductRatePlan__c zRatePlan;
        Product_Tier__c productTier;
        Product_Tier_Rate_Plan__c productTierRatePlan;
        List < Subscription_Master__c > subsMasters;
        Zuora__CustomerAccount__c billingAcc;
        Zuora__ZInvoice__c invoice;
        Locale__c loc;
        
        
        
        // setup product tier and product tier rate plan lists
        loc = TestDataUtility.createLocale('US - United States', 'yes', 'en_us', 'english');
        zProduct = TestDataUtility.createZProduct('Sage One Start', zuoraId);
        zRatePlan = TestDataUtility.createRatePlan(zProduct.Id, 'Monthly', zuoraId);
        productTier = TestDataUtility.createProductTier(zProduct.Id, 'SageOne Start US', 'SageOne-Start-US');
        productTierRatePlan = TestDataUtility.createProductTierRatePlan(productTier.Id, zRatePlan.Id, loc.Id, 'Monthly');
        
        
        //Create masterAccount 
        
        Account masterAcc = TestDataUtility.createAccount(loc.id);
        
        //Create Account with Billing Account and subscription master
        Account mergeAccWithBiiling = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(mergeAccWithBiiling.Id);
        Zuora__CustomerAccount__c billingAccount = TestDataUtility.createBillingAccountAndPaymentMethod(mergeAccWithBiiling, zuoraId);
        zQuote = TestDataUtility.createZQuote(mergeAccWithBiiling.Id, con.Id, zuoraId);
        
        Subscription_Master__c sm = new Subscription_Master__c(Account__c = mergeAccWithBiiling.Id,
                                                               Product__c = zProduct.Id,
                                                               Start_Date__c = System.today(),
                                                               End_Date__c = System.today().addDays(100),
                                                               Product_Tier__c = productTier.Id,
                                                               Product_Tier_Rate_Plan__c = productTierRatePlan.Id);
        insert sm;
        
    }
    
    /*** Billing Account Should not be deleted **/
    @isTest static void deleteAccountsWithBillingAccount() {
        Test.startTest();
        List < Account > billingAcc = [select id, name, isDeleted from Account where id in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
        try {
            delete billingAcc;
        } catch (DMLException e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } finally {
            List < Account > testBillingAcc = [select id, name, isDeleted from Account where id in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
            Boolean isBillingAccDeleted = testBillingAcc[0].isDeleted;
            System.AssertEquals(false, isBillingAccDeleted);
        }
        Test.stopTest();
    }
    
    /*** Subscription Account Should not be deleted **/
    @isTest static void deleteAccountWithSubscriptionMaster() {
        Test.startTest();
        List < Account > subscriptionAcc = [select id, name, isDeleted from Account where id in (select Account__c from Subscription_Master__c) Limit 1];
        try {
            delete subscriptionAcc;
        } catch (DMLException e) {
            System.debug('DMLexception ' + e.getMessage());
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } catch (Exception e) {
            System.debug('Exception ' + e.getMessage());
            
        } finally {
            List < Account > testBillingAcc = [select id, name, isDeleted from Account where id in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
            Boolean isBillingAccDeleted = testBillingAcc[0].isDeleted;
            System.AssertEquals(false, isBillingAccDeleted);
            
        }
        Test.stopTest();
        
    }
    
    /*** Billing Account Should not be merged **/
    @isTest static void mergeAccountsWithBillingAccount() {
        Test.startTest();
        Account masterAcc = [select id, name, isDeleted from Account where id not in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
        Account mergebillingAcc = [select id, name, isDeleted from Account where id in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
        
        
        try {
            merge masterAcc mergebillingAcc;
        } catch (DMLException e) {
            System.debug('DMLException ' + e.getMessage());
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
        } catch (Exception e) {
            System.debug('Exception ' + e.getMessage());
            
        } finally {
            Account testMasterAcc = [select id, name, isDeleted from Account where id not in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
            Account testMergebillingAcc = [select id, name, isDeleted from Account where id in (select Zuora__Account__c from Zuora__CustomerAccount__c) Limit 1];
            Boolean isMasterAccDeleted = testMasterAcc.isDeleted;
            System.AssertEquals(false, isMasterAccDeleted);
            Boolean isMergeBillingAccDeleted = testMergebillingAcc.isDeleted;
            System.AssertEquals(false, isMergeBillingAccDeleted);
        }
        Test.stopTest();
        
        
    }
    
    /*** Subscription Account Should not be merged **/
    @isTest static void mergeAccountsWithSubscriptionMaster() {
        Test.startTest();
        Account masterAcc = [select id, name, isDeleted from Account where id not in (select Account__c from Subscription_Master__c) Limit 1];
        Account mergeSubscriptionMasterAcc = [select id, name, isDeleted from Account where id in (select Account__c from Subscription_Master__c) Limit 1];
        
        try {
            merge masterAcc mergeSubscriptionMasterAcc;
        } catch (DMLException e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } finally {
            Account testMasterAcc = [select id, name, isDeleted from Account where id not in (select Account__c from Subscription_Master__c) Limit 1];
            Account testMergeSubscriptionMasterAcc = [select id, name, isDeleted from Account where id in (select Account__c from Subscription_Master__c) Limit 1];
            Boolean isMasterAccDeleted = testMasterAcc.isDeleted;
            System.AssertEquals(false, isMasterAccDeleted);
            Boolean isMergeSubAccDeleted = testMergeSubscriptionMasterAcc.isDeleted;
            System.AssertEquals(false, isMergeSubAccDeleted);
            
        }
        Test.stopTest();
        
    }
    
    /***  Account Should be deleted as it doesn't have any billing/subscription related records **/
    @isTest static void accountsWithoutBilling() {
        Test.startTest();
        Account masterAcc = [select id, name, isDeleted from Account where id not in (select Account__c from Subscription_Master__c) Limit 1];
       try {
            delete masterAcc;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        } finally {
            
            List < Account > testMasterAcc = [select id, name, isDeleted from Account where id not in (select Account__c from Subscription_Master__c) Limit 1];
            System.AssertEquals(0, testMasterAcc.size());
        }
        Test.stopTest();
        
    }
    
}