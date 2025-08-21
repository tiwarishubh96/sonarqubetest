@isTest
global class SendToZBillingUtilsTest {
    
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   
    private static String zuoraId2 = '2c92c0f84dfff49f014e021c79b82bb7'; 
    
    
    static testMethod void testInvoiceQueue(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id,zuoraId);
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        // UpdateInvoiceStatusQueued queue = new UpdateInvoiceStatusQueued(zquote.Id, 'auto invoice id', zuoraId, zuoraId, zuoraId, zuoraId);
        //UpdateInvoiceStatusQueued.updateZuoraFuture(zquote.Id, 'auto invoice id', zuoraId, zuoraId, zuoraId, zuoraId);
        try{
            SendToZBillingUtils sTZB = new SendToZBillingUtils();
        }Catch(Exception e){}
    } 
    
    
    /**
* [This method tests and covers the 'SendToZBillingUtils' class]
*/
    static testMethod void SendtoZBillingTest(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        
        Zuora__CustomerAccount__c zCustAcct = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        Zuora__Subscription__c zsc = new Zuora__Subscription__c(Name='C-S00000001', Zuora__Zuora_Id__c = zuoraId, Zuora__TermEndDate__c = Date.today().addDays(-2) , Zuora__External_Id__c = '123');
        insert zsc;
        
        //SendToZBillingAJAXController calls SendToZBillingUtils. 
        //Calling Utils from AjaxController to avoid two separate test classes.
        System.assertEquals(Label.lbl_successful_send, SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC'));
        
        //Test ElectronicPaymentMethod set and Amend Subscription
        zquote.zqu__ElectronicPaymentMethodId__c = '2c92c0f855c9f4540155dc42153960e7';
        update zquote;
        System.assertEquals(Label.lbl_successful_send, SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC'));
        
        //Error Test: Sent to Z-Billing
        //        
        zquote.zqu__Status__c = 'Sent to Z-Billing';
        update zquote; 
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_Already_Sent_to_Z_Billing));
        
        
        //Error Test: SOQL exception
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal('123', 'CBC').contains('DML Exception'));
        
        //Error Test: lbl_No_Electronic_Payment_Method
        //       
        zquote.zqu__Status__c = '';
        zquote.zqu__ElectronicPaymentMethodId__c = null;
        update zquote; 
        zCustAcct.Zuora__Default_Payment_Method__c = null;
        update zCustAcct;
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_No_Electronic_Payment_Method));
        
        //Test Amendment
        //
        zquote.zqu__ZuoraAccountID__c = zCustAcct.Id;
        zquote.zqu__SubscriptionType__c = 'Amend Subscription';
        zquote.zqu__Previewed_Total__c = -1.0;
        zquote.zqu__ExistSubscriptionID__c = '123';
        update zquote;
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains('Send to Z-Billing was unsuccessful:'));
        
        zquote.zqu__ZuoraAccountID__c = zCustAcct.Id;
        zquote.zqu__SubscriptionType__c = 'Cancel Subscription';
        zquote.zqu__Previewed_Total__c = -1.0;
        update zquote;
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains('Send to Z-Billing was unsuccessful:'));
        
    }    
    
    
    
    static testMethod void MoreThanOneInvoiceTemplateErrorTest(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId, 'US Active 1');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        TestDataUtility.createInvoiceTemplate(zuoraId2, 'US Active 2');
        
        //SendToZBillingAJAXController calls SendToZBillingUtils. 
        //Calling Utils from AjaxController to avoid two separate test classes.
        //System.assert(SendToZBillingUtils.callZQuoteGlobal(zquote.Id).contains(Label.lbl_More_Than_One_Invoice_Template_Found));
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_More_Than_One_Invoice_Template_Found));
    }
    
    static testMethod void MoreThanOneCommProfileErrorTest(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createComunicationProfile(zuoraId, 'US Active 1');
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        TestDataUtility.createComunicationProfile(zuoraId2, 'US Active 2');
        
        //SendToZBillingAJAXController calls SendToZBillingUtils. 
        //Calling Utils from AjaxController to avoid two separate test classes.
        //System.assert(SendToZBillingUtils.callZQuoteGlobal(zquote.Id).contains(Label.lbl_More_Than_One_Comm_Profile_Found));
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_More_Than_One_Comm_Profile_Found));
    }
    
    static testMethod void NoCommProfileErrorTest(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        //SendToZBillingAJAXController calls SendToZBillingUtils. 
        //Calling Utils from AjaxController to avoid two separate test classes.
        //System.assert(SendToZBillingUtils.callZQuoteGlobal(zquote.Id).contains(Label.lbl_No_Communication_Profile_Found));
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_No_Communication_Profile_Found));
    }
    
    static testMethod void NoInvoiceTemplateErrorTest(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        
        //SendToZBillingAJAXController calls SendToZBillingUtils. 
        //Calling Utils from AjaxController to avoid two separate test classes.
        // System.assert(SendToZBillingUtils.callZQuoteGlobal(zquote.Id).contains(Label.lbl_No_Invoice_Template_Found));
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_No_Invoice_Template_Found));
    }
    
    static testMethod void NoHostedPageErrorTest(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        //SendToZBillingAJAXController calls SendToZBillingUtils.  
        //Calling Utils from AjaxController to avoid two separate test classes.
        //System.assert(SendToZBillingUtils.callZQuoteGlobal(zquote.Id).contains(Label.lbl_error_no_payment_page_found));
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_error_no_payment_page_found));
    }
    
    /**
* [This method tests and covers the 'SendToZBillingUtils' class]
*/
    static testMethod void SendtoZBillingTestTetris(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        update zquote;
        
        Zuora__CustomerAccount__c zCustAcct = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId, 'US Active');
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'CBC');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        Zuora__Subscription__c zsc = new Zuora__Subscription__c(Name='C-S00000001', Zuora__Zuora_Id__c = zuoraId, Zuora__TermEndDate__c = Date.today().addDays(-2) , Zuora__External_Id__c = '123');
        insert zsc;
        
        //SendToZBillingAJAXController calls SendToZBillingUtils. 
        //Calling Utils from AjaxController to avoid two separate test classes.
        System.assertEquals(Label.lbl_successful_send, SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC'));
        
        //Test ElectronicPaymentMethod set and Amend Subscription
        zquote.zqu__ElectronicPaymentMethodId__c = '2c92c0f855c9f4540155dc42153960e7';
        update zquote;
        System.assertEquals(Label.lbl_successful_send, SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC'));
        
        //Error Test: Sent to Z-Billing
        //        
        zquote.zqu__Status__c = 'Sent to Z-Billing';
        update zquote; 
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_Already_Sent_to_Z_Billing));
        
        
        //Error Test: SOQL exception
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal('123', 'CBC').contains('DML Exception'));
        
        //Error Test: lbl_No_Electronic_Payment_Method
        //       
        zquote.zqu__Status__c = '';
        zquote.zqu__ElectronicPaymentMethodId__c = null;
        update zquote; 
        zCustAcct.Zuora__Default_Payment_Method__c = null;
        update zCustAcct;
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_No_Electronic_Payment_Method));
        
        //Test Amendment
        //
        zquote.zqu__ZuoraAccountID__c = zCustAcct.Id;
        zquote.zqu__SubscriptionType__c = 'Amend Subscription';
        zquote.zqu__Previewed_Total__c = -1.0;
        zquote.zqu__ExistSubscriptionID__c = '123';
        update zquote;
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains('Send to Z-Billing was unsuccessful:'));
        
        zquote.zqu__ZuoraAccountID__c = zCustAcct.Id;
        zquote.zqu__SubscriptionType__c = 'Cancel Subscription';
        zquote.zqu__Previewed_Total__c = -1.0;
        update zquote;
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains('Send to Z-Billing was unsuccessful:'));
        
    }
    
    static testMethod void SendtoZBillingTestNewSubscriptionTetris(){
        
        
        System.debug('------------------SendtoZBillingTestNewSubscriptionTetris-------------------------');
        
        
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        Opportunity Opp1 = TestDataUtility.CreateOpportunity(acc.Id,'Opportunity 1');
        
        //Accounting GB
        Product2 p1 = TestDataUtility.CreateProduct2('Accounting GB','TEST00000P1');
        
        zqu__ZProduct__c zp1 = TestDataUtility.CreateZproduct('zProduct 1',p1.Id);
        
        zqu__ProductRatePlan__c zprp1 = TestDataUtility.Createproductrateplan('zProductRatePlan 1',p1.Id,zp1.Id,'sage:gb:sageone:accounts:t:rrp:monthly:pct');
        
        zqu__ProductRatePlanCharge__c   zprpc1 = TestDataUtility.createProductRatePlanCharge('zProductRatePlanCharge 1',zprp1.id);
        
        //Payroll GB
        
        Product2 p2 = TestDataUtility.CreateProduct2('Payroll GB','TEST00000P1');
        
        zqu__ZProduct__c zp2 = TestDataUtility.CreateZproduct('zProduct 1',p2.Id);
        
        zqu__ProductRatePlan__c zprp2 = TestDataUtility.Createproductrateplan('zProductRatePlan 1',p2.Id,zp2.Id,'sage:gb:sageone:payroll:t:rrp:monthly:pct');
        
        zqu__ProductRatePlanCharge__c   zprpc2 = TestDataUtility.createProductRatePlanCharge('zProductRatePlanCharge 1',zprp2.id);
        
        zqu__Quote__c zq1 = TestDataUtility.createZQuoteNewSubscription('zQuote 1',con.id,Opp1.id);
        
        zqu.Quote znewQuote = zqu.Quote.getInstance(zq1.id);
        
        System.debug('znewQuote'+znewQuote);
        
        zqu.Product[] productsToAdd = zqu.Product.loadProductsWithChildren(new String[] {zp1.id,zp2.id});
        
        znewQuote.addQuoteProducts(productsToAdd);
        znewQuote.save();
        
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(zq1.id, new id[] {zprp1.id,zprp2.id});
        
        for (zqu.zChargeGroup cgroup : chargeGroups ) {
            for ( zqu.zCharge charge : cgroup.zCharges ) {
                charge.quantity = '2';
                charge.discount = '10';
            }
            
            zqu.zQuoteUtil.calculateChargesOnQuantityChange(cgroup.zCharges);
            zqu.zQuoteUtil.calculateChargesOnDiscountChange(cgroup.zCharges);
            
        }
        
        System.debug('chargeGroups::::: '+chargeGroups);
        
        chargeGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        
        zqu__QuoteRatePlanCharge__c[] quoteRatePlanCharges = [select id from zqu__QuoteRatePlanCharge__c];
        
        System.debug('quoteRatePlanCharges'+quoteRatePlanCharges);
        
        
        zqu__Quote__c[] quoteobj = [select id,name,zqu__ZuoraAccountID__c,zqu__InvoiceID__c from zqu__Quote__c];
        
        System.debug('quoteobj::::'+quoteobj);
        Zuora__CustomerAccount__c zCustAcct = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplateForTetris(zuoraId,'US Active');
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        Zuora__Subscription__c zsc = new Zuora__Subscription__c(Name='C-S00000001', Zuora__Zuora_Id__c = zuoraId, Zuora__TermEndDate__c = Date.today().addDays(-2) , Zuora__External_Id__c = '123');
        insert zsc;
        System.assertEquals(Label.lbl_successful_send, SendToZBillingAJAXController.callZQuoteGlobal(zq1.Id, 'CBC'));
    }
    
    
    static testMethod void emptySalesOffice(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        acc.Sales_Office__c = null;
        update acc;
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId, 'US Active 1');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        TestDataUtility.createInvoiceTemplate(zuoraId2, 'US Active 2');
        
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_error_no_sales_office));
    }
    
    static testMethod void salesOfficeSGSLTD(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        acc.Sales_Office__c = 'Dublin CBC';
        update acc;
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId, 'US Active 1');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_No_Invoice_Template_Found));
    }
    
    static testMethod void salesOfficeSSIInc(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        acc.Sales_Office__c = 'US SSI INC';
        update acc;
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId); 
        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId, 'US Active 1');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        
        System.assert(SendToZBillingAJAXController.callZQuoteGlobal(zquote.Id, 'CBC').contains(Label.lbl_No_Invoice_Template_Found));
    }
    
}