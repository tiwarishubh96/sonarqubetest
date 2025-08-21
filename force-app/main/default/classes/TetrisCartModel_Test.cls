@isTest(SeeAllData=false) 
private class TetrisCartModel_Test {

    static testMethod void testSettersGetters() {
        TetrisCartModel tetrisCartModelObj = new TetrisCartModel();
        tetrisCartModelObj.cartId = 'b9237360-7b48-4d0f-a2a1-7175931185f2';
        tetrisCartModelObj.cartNumber = '00019014';
        tetrisCartModelObj.transactionType = 'trial';
        tetrisCartModelObj.cartStatus = 'Open';
        tetrisCartModelObj.cartType = 'Major';
        tetrisCartModelObj.currencyCode = 'GBP';
        tetrisCartModelObj.cartLocale = 'GB';
        tetrisCartModelObj.totalAmount = 10.99;
        tetrisCartModelObj.subTotalAmount = 10.99;
        tetrisCartModelObj.adjustmentAmount = 2.99;
        tetrisCartModelObj.adjustmentReason = 'Discount';
        tetrisCartModelObj.taxAmount = 2.00;
        tetrisCartModelObj.taxExemptFlag = false;
        tetrisCartModelObj.taxSubtotalAmount = 2.00;
        tetrisCartModelObj.totalDiscount = 2.00;
        tetrisCartModelObj.vatNumber = 'VAT231';
        tetrisCartModelObj.taxCode = 'CT-121';
        
        tetrisCartModelObj.userIdentityId = '68088fea-59f1-489c-ae50-d7ba62155467';
        
	    tetrisCartModelObj.accountId = '0010E00000EQMCa';
	    tetrisCartModelObj.contactId = '0030E00000EpNl2';
	  	tetrisCartModelObj.leadId = '00Q0E000003TAUg';
	    tetrisCartModelObj.opportunityId = '0060E000007Ihw8';
	    tetrisCartModelObj.zuoraSubscriptionId = '2c92c0f9602fb245016033f21fb35408';
	    tetrisCartModelObj.productSubscriptionId ='2c92c0f9602fb245016033f21fb35408';

	 	tetrisCartModelObj.user = 'Test User';
	  	tetrisCartModelObj.productEntitlementId = '';
	  	tetrisCartModelObj.slcsClientRef = 'b3a7e01c-2c8d-4f12-8d24-c56589c0966a';
	  	tetrisCartModelObj.slcsSubscriptionGroupId = 'd57e4ca1-8b7e-43ba-9f1d-ad7d672fccc4';
	  	tetrisCartModelObj.slcsSubscriptionId = '0081ecb6-358e-4c92-b276-4bc38874d5ea';
    
    		List<TetrisCartItemModel> cartItems = new List<TetrisCartItemModel>();
    		TetrisCartItemModel tetrisCITM = new TetrisCartItemModel();
    		cartItems.add(tetrisCITM);
    		
    		tetrisCartModelObj.cartItems = cartItems;
    }
    
}