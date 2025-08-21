/*-------------------------------------------------------------
    Author:         Tiago Almeida
    Date :          01/14/2020
    Company:       Sage
    Description:   Test Class for TetrisUtility
    Inputs:        This class was created to avoid using real data from salesforce tenant during tests which happens on 
				   TetrisUtility_Test class (it uses SeeAllData=true)
				  
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class TetrisUtilityZquote_Test {
	
     static testmethod void callZquotesOrderToQueueTest()
     {
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from Account];
        Contact cnt ;
        cnt = TestDataUtility.createContact(accList[0].id);
        SPPTestData.CreateZuoraSubscription(1,accList);        
        List<Zuora__Subscription__c> q1 = [Select id,Name from Zuora__Subscription__c];
        System.debug('q1:'+ q1);
        List<Product2> prod = SPPTestData.CreateZuoraProduct(1);
        
         zqu__ProductRatePlan__c productRatePlan = TestDataUtility.createRatePlan(prod[0].ID, 'Accounting GB', '2c92c0f95ec6f7b6015ec927667c7b7j');
        System.debug('productRatePlan: ' + productRatePlan);
         
         List<Zuora__Subscription__c> subscription = SPPTestData.CreateZuoraSubscription(1,accList);
         
         System.debug('subscription'+ subscription);
             
        SPPTestData.CreateSubscriptionProductCharge(1,accList,prod,q1,1);
        
         //if(lstQuoteNew[i].zqu__ZuoraSubscriptionID__c != null && lstQuoteNew[i].zqu__Status__c == 'Sent to Z-Billing' && lstQuoteOld[i].zqu__Status__c == 'New' && lstQuoteNew[i].External_Application__c != null && lstQuoteNew[i].External_Application__c == Global_Constants.TETRIS  )
        
        zqu__Quote__c qu = new zqu__Quote__c(zqu__Hidden_Subscription_Name__c ='TestAccSub0',zqu__Status__c = 'New',External_Application__c = Global_Constants.TETRIS, zqu__ZuoraSubscriptionID__c = subscription[0].Id);
        insert qu;
         
         zqu__Quote__c qu1 = [Select  zqu__Status__c from zqu__Quote__c];
         //qu1.zqu__Status__c = 'Sent to Z-Billing';
         //update qu1;    
         
         //Test.startTest();
         qu1.zqu__Status__c = 'Sent to Z-Billing';
         update qu1; 
        //Test.stopTest();
     }
}