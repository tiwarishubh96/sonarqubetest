/**
* @description Tests associated class.
*
* @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
*/
@IsTest
public with sharing class CustCommSubscriptionUpgradeBtnCtrlTest
{
    /**
* @description Tests that the case is created.
* @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
* @date        2016-05-23
*/
    @IsTest(SeeAllData=false) static void testCreateCase()
    {
        Integer qCases = [SELECT Count() FROM Case];
        System.assertEquals(0, qCases);
        
        Test.startTest();
        
        CustCommSubscriptionUpgradeBtnCtrl.createCase();
        qCases = [SELECT Count() FROM Case];
        System.assertEquals(1, qCases);
        
        Test.stopTest();
    }
    
    /**
* @description Tests exception handling logic.
* @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
* @date        2016-05-25
*/
    @IsTest(SeeAllData=false) static void testCreateCaseError()
    {
        TestExc.fire(CustCommSubscriptionUpgradeBtnCtrl.class, 'error');
        
        Test.startTest();
        
        try {
            CustCommSubscriptionUpgradeBtnCtrl.createCase();
        } catch(Exception ex) {
            TestExc.isExcThrown = true;
        }
        
        System.assertEquals(true, TestExc.isExcThrown);
        
        Test.stopTest();
    }
    
    /**
* @description Test if the controller successfully identifies that a User can upgrade its subscription.
* @author      Santiago Colman <scolman@altimetrik.com>
* @date        2016-06-02
*/
    @IsTest(SeeAllData=false) static void testCanUserUpgradeSubscription(){
        // Create a contact and account
        Contact c = CommunityUtilitiesTest.createAccountAndContact('TestCommunityUserAccount', 'Some', 'One', 'someone@example.com');
        // Create a portal user
        User commUser = CommunityUtilitiesTest.createPortalUser(c);
        // Create two ZProducts, one will be upgraded from the other
        zqu__ZProduct__c upgradeProduct = new zqu__ZProduct__c(Name = 'upgradeProduct', zqu__ZuoraId__c = 'zprodExtId123', zqu__SKU__c = 'sku123');
        insert upgradeProduct;
        zqu__ZProduct__c basicProduct = new zqu__ZProduct__c(Name = 'basicProduct', Upgrade_To__c = upgradeProduct.Id, zqu__ZuoraId__c = 'zprodExtId456', zqu__SKU__c = 'sku456');
        insert basicProduct;
        
        SageApiTestUtils.setupLocale();
        Locale__c loc = [SELECT ID FROM Locale__c LIMIT 1];
        Product_Tier__c tier2 = new Product_Tier__c();
        tier2.Name = 'Sage One Accounting US';
        tier2.Product_Tier_Code__c = 'SageOne-Accounting-US';
        tier2.Product_Use_Region__c = 'US - United States';
        tier2.ZProduct__c = upgradeProduct.Id;
        tier2.PayNow_PageType__c = 'SageOne';
        insert tier2;
        
        Product_Tier_Rate_Plan__c plan2 = new Product_Tier_Rate_Plan__c();
        plan2.Name = 'Monthly';
        plan2.End_Date__c = System.today().addDays( 100 );
        plan2.Start_Date__c = System.today().addYears( -1 );
        plan2.Trial_Period__c = 30;
        plan2.Product_Tier__c = tier2.Id;
        plan2.Payment_Grace_Period__c = 0;
        plan2.CurrencyIsoCode = 'USD';
        plan2.Locale__c = loc.Id;
        insert plan2;
        
        Product_Tier__c tier1 = new Product_Tier__c();
        tier1.Name = 'Sage One Start US';
        tier1.Product_Tier_Code__c = 'SageOne-Start-US';
        tier1.Product_Use_Region__c = 'US - United States';
        tier1.ZProduct__c = basicProduct.Id;
        tier1.PayNow_PageType__c = 'SageOne';
        insert tier1;
        
        Product_Tier_Rate_Plan__c plan1 = new Product_Tier_Rate_Plan__c();
        plan1.Name = 'Monthly';
        plan1.End_Date__c = System.today().addDays( 100 );
        plan1.Start_Date__c = System.today().addYears( -1 );
        plan1.Trial_Period__c = 30;
        plan1.Product_Tier__c = tier1.Id;
        plan1.Payment_Grace_Period__c = 0;
        plan1.CurrencyIsoCode = 'USD';
        plan1.UpgradeToProductTierRatePlan__c = plan2.Id;
        plan1.Locale__c = loc.Id;
        insert plan1;
        
        // Create an Asset related to the Billing account of the portal user and to the basic Product
        Subscription_Master__c subscription = new Subscription_Master__c(Account__c = c.AccountId, ZProduct__c = basicProduct.Id, Product_Tier__c = tier1.Id, Product_Tier_Rate_Plan__c = plan1.Id);
        insert subscription;
        Boolean canPortalUserUpgrade = false;
        Boolean canCurrentUserUpgrade = false;
        Test.startTest();
        canCurrentUserUpgrade = CustCommSubscriptionUpgradeBtnCtrl.canUpgradeSubscription();
        System.runAs(commUser){
            canPortalUserUpgrade = CustCommSubscriptionUpgradeBtnCtrl.canUpgradeSubscription();
            CustCommSubscriptionUpgradeBtnCtrl.upgradeTrial();
        }


        Test.stopTest();
        // The current user should NOT be able to upgrade any Subscription
        System.assertEquals(false, canCurrentUserUpgrade);
        // The portal user should be able to upgrade its subscription
        System.assertEquals(true, canPortalUserUpgrade);
    }
    
    /**
* @description Expects no open cases to exist for the current user.
* @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
* @date        2016-08-17
*/
    @IsTest(SeeAllData=false) static void testNoOpenCases()
    {
        
        Test.startTest();
        
        System.assertEquals( false, CustCommSubscriptionUpgradeBtnCtrl.hasOpenCases() );
        
        Test.stopTest();
    }


}