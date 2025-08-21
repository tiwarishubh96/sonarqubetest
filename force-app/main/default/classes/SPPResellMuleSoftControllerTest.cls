@isTest
public class SPPResellMuleSoftControllerTest {
    
    static testMethod void ResellOrderDetailListForPluginTestWithException(){
       
        
    }
    
    static testMethod void ResellOrderDetailListForPluginTest(){
        
        SPPTestData.creatAccount(1);
        SPPTestData.createOpportunity(1);
        List<Account> accList = [Select id from Account];
        List<Opportunity> oppList = [Select id from Opportunity];
        List<zqu__Quote__c> lstZuoraQuote = SPPTestData.CreateZuoraQuote(1,accList[0], oppList[0]);
        List<zqu__QuoteAmendment__c> lstQuoteAmend = SPPTestData.CreateZuoraQuoteAmendment(1, lstZuoraQuote);
        List<zqu__QuoteRatePlan__c> lstQuoteRatePlan = SPPTestData.CreateZuoraQuoteRatePlan(1,lstQuoteAmend,lstZuoraQuote);
        List<zqu__QuoteRatePlanCharge__c> lstQuoteRatePlanCharge = SPPTestData.CreateZuoraQuoteRatePlanCharge(1,lstQuoteRatePlan);
        
        SPPTestData.CreateZuoraInv(1,accList);
        SPPTestData.createInvoice(1);
        SPPTestData.createOrder(1);
        
        List<SPP_RR_Order_Detail__c> prDetail=SPPTestData.createOrderDetail(1);
        
        
        /*
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
        
        quoteRatePlanCharge.Name = 'Partner Margin';
        
        quoteRatePlanCharge.zqu__Quantity__c = 1;
        
        quoteRatePlanCharge.Total_Margin__c = 2;
        
        quoteRatePlanCharge.zqu__EffectivePrice__c = 2;
        
        quoteRatePlanCharge.Partner_Tier__c = '';
        
        quoteRatePlanCharge.zqu__QuoteRatePlan__c = 'a4i7E0000009UpJ123';
        
        insert quoteRatePlanCharge;
        */
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String jsonData = '{ "RequestId": "aae5fa44-f3e8-4a9a-bb45-f1286e3e7ffb","Async": false,"CallbackUrl": "","Orders": ["OrderType":"123456789qwer12","PartnerType":"Reseller","PartnerTier":"gold", "NCA":"", "ContractYear":"1", "Subscription":"yes", "ProductLine":"yes", "FirstLineSupport":"0", "ProductName":"sage","MultiYear":"yes", "ReferralDate":"", "InvoicedProduct":"","MDF":"","SFDC_ID":"a4i7E0000009UpJ" }';
        
        List<SPPResellConnectionMulesoftController.MuleResponse> lorderlist = new List<SPPResellConnectionMulesoftController.MuleResponse>();
        
        SPPResellConnectionMulesoftController.MuleResponse strMuleResp = new SPPResellConnectionMulesoftController.MuleResponse();
        
        List<SPPResellConnectionMulesoftController.Orders> lstOrder = new List<SPPResellConnectionMulesoftController.Orders>();
                
        SPPResellConnectionMulesoftController.Orders ord = new SPPResellConnectionMulesoftController.Orders();
        
        ord.RefId = lstQuoteRatePlanCharge[0].id;
        
        ord.Margin = '20%';
        
        lstOrder.add(ord);
        
        List<SPPResellConnectionMulesoftController.Error> lstError = new List<SPPResellConnectionMulesoftController.Error>();
        
        SPPResellConnectionMulesoftController.Error err = new SPPResellConnectionMulesoftController.Error();
        
        lstError.add(err);
        
        SPPResellConnectionMulesoftController.MuleResponse muleRes = new SPPResellConnectionMulesoftController.MuleResponse();
        
        muleRes.Id = 'a4i7E0000009UpJ';
        
        muleRes.Orders = lstOrder;
        
        muleRes.Error = lstError;
        
        lorderlist.add(muleRes);
        
        List<zqu__QuoteRatePlanCharge__c> lstOrderDetails = new List<zqu__QuoteRatePlanCharge__c>();
        
        SPPResellConnectionMulesoftController.ResellOrderDetailListForPlugin(jsonData);
        
        SPPResellConnectionMulesoftController.updateQuoteRatePlanChargeResellOrderDetail(lorderlist);

    }
    
}