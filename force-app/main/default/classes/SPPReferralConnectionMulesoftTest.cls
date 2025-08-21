/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPReferralConnectionMulesoft
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPReferralConnectionMulesoftTest 
{
    @isTest static void ReferralOrderDetailListTest() 
    {
        SPPTestData.creatAccount(1);
        SPPTestData.createOpportunity(1);
        List<Account> accList = [Select id from Account];
        SPPTestData.CreateZuoraInv(1,accList);
        SPPTestData.createInvoice(1);
        SPPTestData.createOrder(1);
        
        List<SPP_RR_Order_Detail__c> prDetail=SPPTestData.createOrderDetail(1);
        
        // Set mock callout class 
        String jsondata;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        jsonData = '{ "RequestId": "aae5fa44-f3e8-4a9a-bb45-f1286e3e7ffb","Async": false,"CallbackUrl": "","Orders": ["OrderType":"123456789qwer12","PartnerType":"Reseller","PartnerTier":"gold", "NCA":"", "ContractYear":"1", "Subscription":"yes", "ProductLine":"yes", "FirstLineSupport":"0", "ProductName":"sage","MultiYear":"yes", "ReferralDate":"", "InvoicedProduct":"","MDF":"","SFDC_ID":"a4i7E0000009UpJ" }';
        String jsonData1 = '{ "RequestId: "aae5fa44-f3e8-4a9a-bb45-f1286e3e7ffb","Async": false,"CallbackUrl": "","Orders": ["OrderType":"123456789qwer12","PartnerType":"Reseller","PartnerTier":"gold", "NCA":"", "ContractYear":"1", "Subscription":"yes", "ProductLine":"yes", "FirstLineSupport":"0", "ProductName":"sage","MultiYear":"yes", "ReferralDate":"", "InvoicedProduct":"","MDF":"","SFDC_ID":"a4i7E0000009UpJ" }';
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        //test.startTest();
        //SPPReferralConnectionMulesoftController.ReferralOrderDetailList(jsondata);
        //test.stopTest();
        
        List<SPPReferralConnectionMulesoftController.MuleResponse> lorderlist = new List<SPPReferralConnectionMulesoftController.MuleResponse>();
       
		List<SPPReferralConnectionMulesoftController.Orders> lstOrder = new List<SPPReferralConnectionMulesoftController.Orders>();
                
        SPPReferralConnectionMulesoftController.Orders ord = new SPPReferralConnectionMulesoftController.Orders();
        
        ord.RefId = prDetail[0].id;
        
        ord.Commission = '20%';
        
        lstOrder.add(ord);
        
        List<SPPReferralConnectionMulesoftController.Error> lstError = new List<SPPReferralConnectionMulesoftController.Error>();
        
        SPPReferralConnectionMulesoftController.Error err = new SPPReferralConnectionMulesoftController.Error();
        
        err.ReferenceId = prDetail[0].id;
        
        lstError.add(err);
        
        SPPReferralConnectionMulesoftController.MuleResponse muleRes = new SPPReferralConnectionMulesoftController.MuleResponse();
        
        muleRes.Id = 'a4i7E0000009UpJ';
        
        muleRes.Orders = lstOrder;
        
        muleRes.Error = lstError;
        
        lorderlist.add(muleRes);
        
        SPPReferralConnectionMulesoftController.ReferralOrderDetailList(jsonData);
        SPPReferralConnectionMulesoftController.updateReferralOrderDetail(lorderlist,jsonData);
    }
    @isTest static void ReferralOrderDetailListWithExceptionTest() 
    {
        //SPPReferralConnectionMulesoftController.ReferralOrderDetailList('jsondata');
    }
    
    
    

}