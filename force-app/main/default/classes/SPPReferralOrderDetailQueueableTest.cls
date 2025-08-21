/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPReferralOrderDetailQueueable
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPReferralOrderDetailQueueableTest {
    //Inserting Test Data Using SPPTestData Class
    @testSetup static void SPPTestData() 
    {
        SPPTestData.creatAccount(1);
        SPPTestData.createOpportunity(1);
        SPPTestData.CreateZuoraInvoice(1);
        SPPTestData.createInvoice(1);
        SPPTestData.createOrder(1);
        SPPTestData.createOrderDetail(1);
    }
    static TestMethod void TestOrderQueueData()
    {
        
        List<SPP_RR_Order_Detail__c> prDetail=[Select id from SPP_RR_Order_Detail__c];
        System.debug('Commission Invoice'+prDetail);
        Test.startTest();
        SPPReferralOrderDetailQueueable queueable=new SPPReferralOrderDetailQueueable(prDetail);
        System.enqueueJob(queueable);
        Test.stopTest();   
    }
    static TestMethod void TestOrderQueueDataWithoutException()
    {
       
        Opportunity opp = [Select Id,Product__c from Opportunity limit 1];
        opp.Product__c = 'Sage Live';
        Update opp;
       
        List<SPP_RR_Order_Detail__c> prDetail=[Select id from SPP_RR_Order_Detail__c];
        
        SPP_RR_Order_Detail__c sppRRObj = prDetail[0];
        sppRRObj.Opportunity__c = opp.Id;
        update sppRRObj;
        System.debug('Commission Invoice'+prDetail);
        Test.startTest();
        SPPReferralOrderDetailQueueable queueable=new SPPReferralOrderDetailQueueable(prDetail);
        System.enqueueJob(queueable);
        Test.stopTest();   
    }

    
}