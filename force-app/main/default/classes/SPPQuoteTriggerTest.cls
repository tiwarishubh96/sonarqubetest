/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPQuoteTriggerTest
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPQuoteTriggerTest {

    
    static testmethod void QuoteTriggerTest()
    {
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from Account];
        SPPTestData.CreateZuoraSubscription(1,accList);        
        List<Zuora__Subscription__c> q1 = [Select id,Name from Zuora__Subscription__c];
        System.debug('q1:'+ q1);
        List<Product2> prod = SPPTestData.CreateZuoraProduct(1);
        
        SPPTestData.CreateSubscriptionProductCharge(1,accList,prod,q1,1);
        
        zqu__Quote__c qu = new zqu__Quote__c(zqu__Hidden_Subscription_Name__c ='TestAccSub0');
        insert qu;
        update qu;
    }
    /*
    static testmethod void IsExternallApp()
    {
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from Account];
        SPPTestData.CreateZuoraSubscription(1,accList);        
        List<Zuora__Subscription__c> q1 = [Select id, Name from Zuora__Subscription__c];
        System.debug('q1: '+ q1);
        List<Product2> prod = SPPTestData.CreateZuoraProduct(1);
        
        zqu__ProductRatePlan__c productRatePlan = TestDataUtility.createRatePlan(prod[0].ID, 'Accounting GB', '2c92c0f95ec6f7b6015ec927667c7b7j');
        System.debug('productRatePlan: ' + productRatePlan);
            
        SPPTestData.CreateSubscriptionProductCharge(1, accList, prod, q1, 1);
        
        zqu__Quote__c qu = new zqu__Quote__c(zqu__Hidden_Subscription_Name__c ='TestAccSub0');
        insert qu;
        update qu;
    }*/
    
}