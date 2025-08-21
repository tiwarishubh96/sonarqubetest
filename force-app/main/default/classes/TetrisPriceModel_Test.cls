@isTest(SeeAllData=false) 
private class TetrisPriceModel_Test {

    static testMethod void testSettersGetters() {
       	TetrisPriceModel tetrisPriceModelObj = new TetrisPriceModel();
   		tetrisPriceModelObj.productId = 'a3r0E000000DJwi';
   		tetrisPriceModelObj.productName = 'Sage One Accounting GB';
   		tetrisPriceModelObj.feeType = 'Recurring Fee';
   		tetrisPriceModelObj.priceType = 'Flat';
   		tetrisPriceModelObj.currencyCode = 'GBP';
   		tetrisPriceModelObj.startDate = system.today();
   		tetrisPriceModelObj.endDate = system.today();
   		tetrisPriceModelObj.enabled = true;
   		tetrisPriceModelObj.listID = 'a3e0E000000Cmum';
   		tetrisPriceModelObj.listItemID = 'a3d0E0000000JyF';
   		tetrisPriceModelObj.listName ='GB Price List';
   		tetrisPriceModelObj.listPrice = 10.99;
   		tetrisPriceModelObj.minQuantity = 1;
   		tetrisPriceModelObj.maxQuantity = 1;
   		tetrisPriceModelObj.recurringPrice = true;
   		tetrisPriceModelObj.unitOfMeasure = 'Each';
   		tetrisPriceModelObj.subscriptionTermId = 'a4M0E000000Cdgb';
   		tetrisPriceModelObj.subscriptionDuration = 12;
   		tetrisPriceModelObj.subscriptionFrequency = 'Monthly';
   		tetrisPriceModelObj.subscriptionAutoRenewal = true;
   		tetrisPriceModelObj.availableForSubscription = true;
   		tetrisPriceModelObj.subscriptionInstallmentCount = 10;
   		tetrisPriceModelObj.subscriptionInstallmentFrequency = 1;
   		tetrisPriceModelObj.subscriptionInstallmentUOM = 'Monthly';
   		tetrisPriceModelObj.bundledComponentPrice = 25.99;
    }
}