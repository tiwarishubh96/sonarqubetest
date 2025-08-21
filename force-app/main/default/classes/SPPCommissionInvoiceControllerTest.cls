/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPCommissionInvoiceController
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
public class SPPCommissionInvoiceControllerTest {
    
    static testmethod void validateInvoicePdfController(){
        
        //List<SPP_Commission_Invoice__c> testdata  = (List<SPP_Commission_Invoice__c>) JSON.deserialize( '[{"DeveloperName":"dummyValue","MasterLabel":"TestLabel","Address__c":"test Address","Payment__c":"Test Pay","Support_Phone__c":"test support","Support_Email__c":"Support@gmail.com"}]', List<SPP_Commission_Invoice__c>.class );
        //System.debug('Test Data'+ testdata);
        /*
        SPPTestData.CreateAccountAndContactForPartnerType();
        
        Account a = [Select id, Locale__r.name From Account Limit 1];
        
        system.debug('a::'+a);
        a.Locale__r.name = 'en_US';
        
        update a;
		*/
        
        SPP_Commission_Invoice__c comInvoiceTest = new SPP_Commission_Invoice__c();
        comInvoiceTest.Amount_Paid__c = 0;
        comInvoiceTest.AP_Comission__c = 200;
        comInvoiceTest.VAT__c = 19;
        //comInvoiceTest.Partner_Account__c = a.id;
        comInvoiceTest.CurrencyIsoCode = 'USD';
        insert comInvoiceTest;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(comInvoiceTest);
        SPPCommissionInvoiceController test=new SPPCommissionInvoiceController(sc);
        PageReference pageRef = Page.PartnerCommissionInvoice;
        pageRef.getParameters().put('id', String.valueOf(comInvoiceTest.Id));
        List<SPP_RR_Order__c> testd= test.getRROrderByInvoice();
        
    }
    static testmethod void findCommisionInvoicePeriodTest()
    {
        
        Date myDate = date.newinstance(Date.Today().Year(), 2, 17);
        SPPCommissionInvoiceController obj = new SPPCommissionInvoiceController();
        obj.findCommisionInvoicePeriod(myDate);
   
    }
    static testmethod void findCommisionInvoicePeriodTest1()
    {
        Date myDate = date.newinstance(Date.Today().Year(), 4, 17);
        SPPCommissionInvoiceController obj = new SPPCommissionInvoiceController();
        obj.findCommisionInvoicePeriod(myDate);

    }
    static testmethod void findCommisionInvoicePeriodTest2()
    {
        Date myDate = date.newinstance(Date.Today().Year(), 7, 17);
        SPPCommissionInvoiceController obj = new SPPCommissionInvoiceController();
        obj.findCommisionInvoicePeriod(myDate);

    }
    static testmethod void findCommisionInvoicePeriodTest3()
    {
        Date myDate = date.newinstance(Date.Today().Year(), 10, 17);
        SPPCommissionInvoiceController obj = new SPPCommissionInvoiceController();
        obj.findCommisionInvoicePeriod(myDate);

    }
   
    
}