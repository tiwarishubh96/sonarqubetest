/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPAPCommissionPDFQueueable
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPAPCommissionPDFQueueableTest {
    static TestMethod void TestOrderQueue()
    {
        List<Account> testAcc= SPPTestData.forParentcreatAccount(1);
        SPPTestData.createOpportunity(1);
        SPPTestData.CreateZuoraInvoice(1);
        SPPTestData.createInvoice(1);
        List<SPP_Commission_Invoice__c> testc=SPPTestData.createCommissionInvoice(1,testAcc);
        System.debug('Commission Invoice'+testc);
        List<SPP_RR_Order__c> testorder=SPPTestData.createOrderL(1);
        for(integer i=0;i<testorder.size();i++)
        {
            testorder[i].SPP_AP_Commission__c=testc[0].id;
        }
        update testorder;
        Test.startTest();
        SPPAPCommissionPDFQueueableController queueable=new SPPAPCommissionPDFQueueableController(testc);
        System.enqueueJob(queueable);
        Test.stopTest();
    }
    
    static TestMethod void TestOrderQueueException()
    {
        SPPAPCommissionPDFQueueableController queueable=new SPPAPCommissionPDFQueueableController(null);
        System.enqueueJob(queueable);
    }
    
}