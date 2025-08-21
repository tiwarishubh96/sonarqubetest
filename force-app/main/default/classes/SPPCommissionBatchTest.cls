/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPCommissionBatch
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPCommissionBatchTest {
    
    static List <SPP_RR_Order__c> ordersUpdate{get;set;}
    @testSetup static void setup() {
        
    }
    
    static testMethod void testMethodforAccounts()
    {
        List<Account> TestAcc=SPPTestData.forParentcreatAccount(1);
    
        List<Opportunity> TestOpp=SPPTestData.createOpportunity(1);

        SPPTestData.CreateZuoraInvoice(1);
        
        List<SPP_RR_Invoice__c> Testinv =SPPTestData.createInvoice(1);
         
        List <SPP_RR_Order__c> orders=SPPTestData.createOrderL(1);
        
        List<SPP_RR_Order_Detail__c> prDetail=SPPTestData.createOrderDetail(1);
        
        System.debug('Invoice'+Testinv);
        System.debug('Order Detail'+ prDetail);
        
        ordersUpdate=new List <SPP_RR_Order__c>();
        
        SPPCommissionBatch reassign = new SPPCommissionBatch('Select Commission_Payable__c,CurrencyISOCode,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Id from SPP_RR_Order__c where Invoiced__c = false and SPP_AP_Commission__c=null and Commission_Payable__c > 0');
        
        //SppCommissionBatch reassign = new SppCommissionBatch(); 
        for(SPP_RR_Order__c ord:[Select Commission_Payable__c,Commission_Amount__c,Opportunity__r.Account.Name,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Opportunity__r.Name from SPP_RR_Order__c where id IN: orders])
        {
            System.debug('Commission Payable'+ord.Commission_Payable__c);
            
            ordersUpdate.add(ord);  
        }
        
        SPP_RR_Order__c orde=[Select Commission_Payable__c,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Id from SPP_RR_Order__c where Invoiced__c = false and SPP_AP_Commission__c=null ];
        
        System.debug('orde'+orde);    
        
        update ordersUpdate;
        
        Test.startTest();
        Database.executeBatch(reassign,10);
        Test.StopTest();
    }  
    
    static testMethod void testMethodforAccountsWithException()
    {
        List<Account> TestAcc=SPPTestData.forParentcreatAccount(1);
        List<Opportunity> TestOpp=SPPTestData.createOpportunity(1);
        SPPTestData.CreateZuoraInvoice(1);
        List<SPP_RR_Invoice__c> Testinv =SPPTestData.createInvoice(1);
        List <SPP_RR_Order__c> orders=SPPTestData.createOrderL(1);
        List<SPP_RR_Order_Detail__c> prDetail=SPPTestData.createOrderDetail(1);
        System.debug('Invoice'+Testinv);
        System.debug('Order Detail'+ prDetail);
        ordersUpdate=new List <SPP_RR_Order__c>();
        SPPCommissionBatch reassign = new SPPCommissionBatch('Select Commission_Payable__c,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Id from SPP_RR_Order__c where Invoiced__c = false and SPP_AP_Commission__c=null and Commission_Payable__c > 0');
        
        //SppCommissionBatch reassign = new SppCommissionBatch(); 
        for(SPP_RR_Order__c ord:[Select Commission_Payable__c,Commission_Amount__c,Opportunity__r.Account.Name,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Opportunity__r.Name from SPP_RR_Order__c where id IN: orders])
        {
            //ord.Credit_Note__c    =10;
            System.debug('Commission Payable'+ord.Commission_Payable__c);
            //ord.Commission_Payable__c=10;
            ordersUpdate.add(ord);  
        }
        SPP_RR_Order__c orde=[Select Commission_Payable__c,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Id from SPP_RR_Order__c where Invoiced__c = false and SPP_AP_Commission__c=null ];
        System.debug('orde'+orde);    
        update ordersUpdate;
        Test.startTest();
        Database.executeBatch(reassign,10);
        Test.StopTest();
    }
    
    static testMethod void calloutToAvalaraForVATTest(){
        
        SPPCommissionBatch sb = new SPPCommissionBatch('q'); 
        
        sb.CalloutToAvalaraForVAT('q','q');
    }
}