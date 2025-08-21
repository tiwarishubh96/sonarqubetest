/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPUpdateZuoraInvoicesDetails
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

@isTest
public class SPPUpdateZuoraInvoicesDetailsTest {
   
    
    @isTest(seeAlldata=true)
    Public static void  ZuoraInvoiceDetailsTest()
    {
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from account where Name='TestAcc0' and Phone='1234567890' limit 1];
        SPPTestData.createOpportunity(1);
        SPPTestData.CreateZuoraInv(1,accList);
        SPPTestData.createInvoice(1);
        SPPTestData.createOrder(1);
        SPPTestData.createOrderDetail(1);
        
         //To insert test records SPP_RR_Invoice__c
        List<String> ZuoraIds = new List<String>();
        
        List<Zuora__ZInvoice__c> alist =  [Select id from Zuora__ZInvoice__c where Zuora__Zuora_Id__c='Test0010' limit 1];
        for(Zuora__ZInvoice__c obj : alist)
        {
            ZuoraIds.add(obj.id);
        }
        SPPUpdateZuoraInvoicesDetails.ZuoraInvoiceDetails(ZuoraIds);
    }
    
     
    Public static  TestMethod void  ZuoraInvoiceDetailsTestForException()
    {
        
        List<String> ZuoraIds = new List<String>();
        SPPUpdateZuoraInvoicesDetails.ZuoraInvoiceDetails(ZuoraIds);
    }
    
    Public static  TestMethod void  createZuoraObjectException()
    {
        Map<String, Object> mapTest = new Map<String, Object>();
        mapTest.put('id', 'value');
        SPPUpdateZuoraInvoicesDetails.createZuoraObject('ZuoraIds', 'id', mapTest );
    }
    
    
}