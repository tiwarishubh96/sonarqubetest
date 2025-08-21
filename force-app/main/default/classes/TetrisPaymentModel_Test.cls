@isTest(SeeAllData=false) 
private class TetrisPaymentModel_Test {

    static testMethod void testSettersGetters() {
    		Test.startTest();
        TetrisPaymentModel tetrisPModel = new TetrisPaymentModel();
        
        TetrisPaymentModel.PaymentMethod paymentMethodObj = new TetrisPaymentModel.PaymentMethod();
        paymentMethodObj.zTenantID = 'z34322';
        paymentMethodObj.zSignature = 'asfas24234';
        paymentMethodObj.zToken = '2344sadfasf';
        paymentMethodObj.zKey = 'as23423dfadsfa';
        paymentMethodObj.zURL = 'https://z.com';
        paymentMethodObj.paymentType = 'Credit Card';
        
        paymentMethodObj.paymentPageId = '2c92c0f85fde706f015fe8e0e7132e8d';
        paymentMethodObj.isDefault = true;
        paymentMethodObj.paymentGateway = 'Payment Page';
        paymentMethodObj.countryLanguage = 'English';
        paymentMethodObj.countryCurrency = 'GBP';
        paymentMethodObj.countryCode = 'GB';
        
        List<TetrisPaymentModel.PaymentMethod> lstPaymentMethods = new List<TetrisPaymentModel.PaymentMethod>();
        lstPaymentMethods.add(paymentMethodObj);
        
        tetrisPModel.paymentMethods =  lstPaymentMethods;
        
        Test.stopTest();
    }
}