@isTest(SeeAllData=false) 
private class TetrisBillingProductChargeModel_Test {
    
    static testMethod void testTetrisProductModel() {
        
        TetrisBillingProductChargeModel tetrisBillingPCM = new TetrisBillingProductChargeModel();
        tetrisBillingPCM.originalChargeId = '2342314143';
    	tetrisBillingPCM.productRatePlanChargeId = '431242142';
        tetrisBillingPCM.chargeNumber = '2341241';
        tetrisBillingPCM.name = 'testingsample';
        tetrisBillingPCM.chargeType = 'test';
        tetrisBillingPCM.model = 'test32';
        tetrisBillingPCM.price = 12.99;
        tetrisBillingPCM.pricingSummary = 'monthly subscription';
        tetrisBillingPCM.billingCurrency = 'monthly';
        tetrisBillingPCM.applyDiscountTo = 'product';
        tetrisBillingPCM.billingDay = '1';
        tetrisBillingPCM.billingPeriod = 'month';
        tetrisBillingPCM.effectiveStartDate = system.today();
        tetrisBillingPCM.effectiveEndDate = system.today().addYears(1);
        tetrisBillingPCM.endDateCondition = 'cancel';
        tetrisBillingPCM.uptoPeriodsType = 'mdasa';
        tetrisBillingPCM.upToPeriods = 12;
        tetrisBillingPCM.description = 'sample';
        tetrisBillingPCM.productBundleName = 'Product Bundle';
        tetrisBillingPCM.productBundleInstanceId = '213124532341';
        tetrisBillingPCM.productBundleDescription = '1234124sadf';
        tetrisBillingPCM.productDescription = 'adfas234fd';
        tetrisBillingPCM.productName = 'sku_test';
        tetrisBillingPCM.productSKU = 'sku_test';
        tetrisBillingPCM.quantity = 1;
        tetrisBillingPCM.ratePlanName = 'monthly';
        tetrisBillingPCM.ratePlanDescription = 'adfasfa';
        tetrisBillingPCM.totalContractValue = 1299;
    }

}