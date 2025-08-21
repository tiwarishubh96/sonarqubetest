/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPZuoraInvoiceHelperClass
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPZuoraInvoiceHelperClassTest {
    
    @isTest(seeAlldata=true)
    static void handleAfterInsertTest()
    {
        
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from account where name = 'TestAcc0' and phone = '1234567890' Limit 1];
        accList[0].IsPartner = true;
        accList[0].Partner_Agreement__c = 'V3';
        accList[0].Locale_Billing_CC__c = 'US';
        update accList[0];
        
        //SPPTestData.createOpportunity(1);
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        
        opp.type = 'Resell Business';
		opp.name = 'SPPZuoraInvoiceHelperClassTestOpp';
        opp.Accountid = accList[0].id;
        opp.Amount_ACV__c = 600;
        opp.CloseDate=Date.today();
        opp.StageName=Label.Opportunity_Sales_Stages_Closed_Won;
        //EAD-1044 Added Why_We_Lost for Validation
        opp.Why_We_Lost__c = 'No Reason Specified';
    
        opp.ForecastCategoryName='Closed';
        opp.Lead_Source__c = 'Marketing';
        oppList.add(opp);
        insert oppList;
        
        system.debug('oppList>>>'+oppList[0]);
        SPPTestData.createInvoice(1);
        
        List<Product2> lstzProduct=new List<Product2>();
        lstzProduct.add(new Product2(Name='Test Product'));
        insert lstzProduct;
        
        List<zqu__Quote__c> lstQuote = SPPTestData.CreateZuoraQuote(1, accList[0], oppList[0]);
        
        List<zqu__QuoteAmendment__c> lstQuoteAmend = SPPTestData.CreateZuoraQuoteAmendment(1, lstQuote);
        
        List<zqu__QuoteRatePlan__c> lstQuoteRatePlan = SPPTestData.CreateZuoraQuoteRatePlan(1,lstQuoteAmend,lstQuote);
        
        lstQuoteRatePlan[0].zqu__QuoteRatePlanFullName__c = 'SPPZuoraInvoiceHelperClassQuoteRatePlan';
        
        update lstQuoteRatePlan[0];
        
        system.debug('lstQuoteRatePlan Test>>>'+lstQuoteRatePlan[0]);
        
        List<Zuora__ZInvoice__c> lstzInvoice=SPPTestData.CreateZuoraInv(1, accList);
        
        lstzInvoice[0].Zuora__Zuora_Id__c = '2c92c0f94e2401bb014e2a3b4bd64537';
        
        lstzInvoice[0].Name = 'SPPZuoraInvoiceHelperClassInvoice';
        
        update lstzInvoice[0];
            
        system.debug('lstzInvoice Test>>>'+lstzInvoice[0]);
        
        List<Zuora__Subscription__c> lstzSub = SPPTestData.CreateZuoraSubscription(1, accList);
        
        List<Zuora__SubscriptionProductCharge__c> lstzSubscriptionCharge=new List<Zuora__SubscriptionProductCharge__c>();
        
        lstzSubscriptionCharge.add(new Zuora__SubscriptionProductCharge__c(Name = 'TestAccSubcharge',
                                                                           Zuora__Account__c = accList[0].id,   
                                                                           Zuora__Subscription__c = lstzSub[0].id,
                                                                           Zuora__ProductName__c = 'Test Product',
                                                                           Zuora__ChargeNumber__c = 'test',
                                                                           OPP_ID__c = oppList[0].id,
                                                                           Zuora__Quantity__c = 2,
                                                                           Zuora__Zuora_Id__c = lstzInvoice[0].Zuora__Zuora_Id__c));

    }
    
    static testMethod void getPartnerTypeAndTierTest()
    {
        
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from account];
        SPPTestData.createOpportunity(1);
        SPPTestData.CreateZuoraInv(2,accList);
        SPPTestData.createInvoice(1);
        SPPTestData.createOrder(1);
        SPP_RR_Order__c ord = [Select Id,Name,Invoice__c,Opportunity__c,Invoice__r.Account__r.Customer_Type__c, Sale_Type__c,Opportunity__r.AccountId,
                               Opportunity__r.Referring_Partner_Account__r.Partner_Reseller__c,Opportunity__r.Referring_Partner_Account__r.Reseller_Partner_Tier__c,
                               Opportunity__r.Referring_Partner_Account__r.Partner_Accountant__c,Opportunity__r.Referring_Partner_Account__r.Accountant_Partner_Tier__c,
                               Opportunity__r.Referring_Partner_Account__r.Partner_Implementation__c,Opportunity__r.Referring_Partner_Account__r.SI_Partner_Tier__c
                               from SPP_RR_Order__c limit 1];
        
        Test.startTest();
        SPPZuoraInvoiceHelperClass.getPartnerTypeAndTier(ord);
        Test.stopTest();
        
        
    }
    
    static testMethod void getContractYearTest()
    {
        
        SPPTestData.creatAccount(1);
        List<Account> accList = [Select id from Account];
        SPPTestData.CreateZuoraSubscription(1,accList);        
        List<Zuora__Subscription__c> q1 = [Select id from Zuora__Subscription__c];
        List<Product2> prod = SPPTestData.CreateZuoraProduct(1);
        
        SPPTestData.CreateSubscriptionProductCharge(1,accList,prod,q1,1);
        Zuora__SubscriptionProductCharge__c q = [Select id,Zuora__Subscription__r.Zuora__SubscriptionStartDate__c,Zuora__Subscription__r.Zuora__TermEndDate__c from Zuora__SubscriptionProductCharge__c limit 1];
        System.debug('q'+q);
        Test.startTest();
        SPPZuoraInvoiceHelperClass.getContractYear(q);
        Test.stopTest();

        
    }
    
    static testMethod void createZuoraObjectTestException()
    {
        
        SPPZuoraInvoiceHelperClass.createZuoraObject('objName', 'id', new Map<String, Object>());
        
    }
    
}