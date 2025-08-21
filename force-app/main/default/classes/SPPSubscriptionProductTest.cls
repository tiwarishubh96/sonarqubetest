/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPSubscriptionProduct
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

@isTest
public class SPPSubscriptionProductTest {
   
    Static TestMethod void TestSubscriptionProduct()
    {
        List<Account> TestAcc=SPPTestData.forParentcreatAccount(1);
        List<Product2> TestProduct=SPPTestData.CreateZuoraProduct(1);
        List<Zuora__Subscription__c> TestSubscription=SPPTestData.CreateZuoraSubscription(1,TestAcc);
        List<Subscription_Product_Detail__c> TestSubDetail=SPPTestData.CreateSubscriptionDetail(1,TestAcc);
        Test.startTest();
        List<Zuora__SubscriptionProductCharge__c> TestSubscriptionProd=SPPTestData.CreateSubscriptionProductCharge(1,TestAcc,TestProduct,TestSubscription,0);
         List<Zuora__SubscriptionProductCharge__c> TestSubscriptionProd1=SPPTestData.CreateSubscriptionProductCharge(1,TestAcc,TestProduct,TestSubscription,1);
        System.debug('Sub Detail Prod'+TestSubscriptionProd);
        System.debug('Sub Detail'+TestSubDetail);
        Test.stopTest();
    }
    
}