@isTest
public class FailedInvoiceItemBatchTest {
    public static Zuora__ZInvoice__c inv;
    public static Zuora__Payment__c payment;
    public static Product2 zProduct;
    
    static {
        TestDataUtility.Status = 'Status';
        Account acc = createAccount();
        TestDataUtility.AccountId = acc.Id;
        Zuora__CustomerAccount__c ca = createBillingAccount(acc.Id);
        //
        // Principal object records
        // - invoice
        inv=new Zuora__ZInvoice__c(Zuora__BillingAccount__c=ca.Id, Zuora__Zuora_Id__c='2c92c0f8547a3c9c0154910bbd9c59e9');
        insert inv;
        // - product
        zProduct = new Product2(Name='testZProduct', zqu__ZuoraId__c='zprodExtId123', zqu__SKU__c='sku123');
        insert zProduct;
        //
        // - payment record with Error
        payment=new Zuora__Payment__c(Zuora__BillingAccount__c=ca.Id, Zuora__Invoice__c=inv.Id, Zuora__Status__c='Error');
        insert payment;
    }
    @isTest(SeeAllData=true) //SeeAllData is needed to prevent 'Please upload Zuora WSDL at first.' error, caused by internal setting of zuora.
    static void batchExecution() {
        List<Zuora__Payment__c> zpList=[select Id, Zuora__Invoice__c, Zuora__Invoice__r.Zuora__Zuora_Id__c, Zuora__GatewayResponse__c  
                                        from Zuora__Payment__c where Id=:payment.Id];
        //
        Test.StartTest();
        // test invoice item
        Zuora.zObject zo=new Zuora.zObject('InvoiceItem');
                zo.setValue('Id','123456');
                zo.setValue('InvoiceId','2c92c0f8547a3c9c0154910bbd9c59e9');
                zo.setValue('ProductId',zProduct.zqu__ZuoraId__c);  // external ID lookup to ZProduct
        //
        // configure batch with query to get the test payment error
        FailedInvoiceItemBatch batch_obj = new FailedInvoiceItemBatch('select Id, Name, Zuora__Invoice__c, Zuora__GatewayResponse__c, Zuora__Invoice__r.Zuora__ZuoraId__c from Zuora__Payment__c where Id=\''+
                                       payment.Id+'\'');
        batch_obj.testZInvoiceItem=zo;
        //
        //run methods
        Database.BatchableContext dbc;
        Iterable<sObject> iter=batch_obj.start(dbc);
        system.debug('***TEST iter:'+iter);
        batch_obj.execute(dbc, zpList);
        batch_obj.finish(dbc);
        
        Test.stopTest();
        //
        // confirm new invoice line item created
        List<Invoice_Line_Item__c> iliList=[select id, name, Invoice__c, Zuora_Id__c from Invoice_Line_Item__c where Invoice__c=:inv.Id];
        system.debug('iliList: '+iliList);
        system.assertEquals('123456', iliList[0].Zuora_Id__c);
        //
        // confirm payment processed
        List<Zuora__Payment__c> paymentList=[select id, Error_Processed__c from Zuora__Payment__c where ID=:payment.Id];
        system.assert(paymentList[0].Error_Processed__c);
    }
    @isTest(SeeAllData=true) //SeeAllData is needed to prevent 'Please upload Zuora WSDL at first.' error, caused by internal setting of zuora.
    static void batchExecutionError() {
        List<Zuora__Payment__c> zpList=[select Id, Zuora__Invoice__c, Zuora__Invoice__r.Zuora__Zuora_Id__c,
                                         Zuora__GatewayResponse__c from Zuora__Payment__c where Id=:payment.Id];
        //
        Test.StartTest();
        // test invoice item - without Product will cause the error we want
        Zuora.zObject zo=new Zuora.zObject('InvoiceItem');
                zo.setValue('Id','123456');
                zo.setValue('InvoiceId','2c92c0f8547a3c9c0154910bbd9c59e9');
                //zo.setValue('ProductId',zProduct.zqu__ZuoraId__c);    // external ID lookup to ZProduct
        //
        // configure batch with query to get the test payment error
        FailedInvoiceItemBatch batch_obj = new FailedInvoiceItemBatch('select Id, Name, Zuora__Invoice__c, Zuora__Invoice__r.Zuora__ZuoraId__c, Zuora__GatewayResponse__c from Zuora__Payment__c where Id=\''+
                                       payment.Id+'\'');
        batch_obj.testZInvoiceItem=zo;
        //
        //run methods
        Database.BatchableContext dbc;
        Iterable<sObject> iter=batch_obj.start(dbc);
        system.debug('***TEST iter:'+iter);
        batch_obj.execute(dbc, zpList);
        batch_obj.finish(dbc);
        
        Test.stopTest();
        //
        // confirm new invoice line item created
        List<Invoice_Line_Item__c> iliList=[select id, name, Invoice__c, Zuora_Id__c from Invoice_Line_Item__c where Invoice__c=:inv.Id];
        system.debug('iliList: '+iliList);
        system.assertEquals(0, iliList.size());
        //
        // confirm payment not processed
        List<Zuora__Payment__c> paymentList=[select id, Error_Processed__c from Zuora__Payment__c where ID=:payment.Id];
        system.assert(!paymentList[0].Error_Processed__c);
    }
    //
    // Tests for FailedInvoiceItemSchedulable class
    static testmethod void testScheduleBatch() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('FailedInvoiceItemTest.ScheduleFailedInvoiceItem', ScheduleFailedInvoiceItem.CRON_EXP, new ScheduleFailedInvoiceItem());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(ScheduleFailedInvoiceItem.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('03:00:00'));
        //
        //check here - batch has not run yet
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(0,runningJobs);
        
        Test.stopTest();    // forces schedule to run
        //
        // batch has started - but will complete after this test.
        runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(2,runningJobs);
    }
    static testMethod void testScheduleAgain() {
        Test.startTest();
        ScheduleFailedInvoiceItem scheduler=new ScheduleFailedInvoiceItem();
        scheduler.scheduleAgain();
        Test.stopTest();    // forces schedule to run
        Integer runningJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'];
        system.assertEquals(2,runningJobs);
    }
    
    /**
* [createAccount creates new account in SFDC]
* @return [new SFDC account]
*/
    private static Zuora__CustomerAccount__c createBillingAccount(Id accountId){      
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
        ca.Zuora__Zuora_Id__c = '2c92c0f94e03d39e014e05cd105f17E4';
        ca.Zuora__Account__c = accountId; 
        insert ca;       
        return ca;
    }
    /**
* [createAccount creates new account in SFDC]
* @return [new SFDC account]
*/
    private static Account createAccount(){      
        Account acc = (Account) TestDataUtility.createSobject(1, true, new Map<String, Object>{
            'Name' => 'acme',
                'Sales_Office__c' => 'Atlanta CBC',
                'BillingCity' => 'New York',
                'BillingCountry' => 'United States',
                'BillingState' => 'New York',
                'BillingPostalCode' => '12345',
                'BillingStreet' => 'Some Street'
                }, 'Account')[0];
        return acc;
    }
    /**
* [createAccount creates new account in SFDC]
* @return [new SFDC account]
*/
    private static List<Zuora.zObject> createZuoraInvoice(){      
        List<Zuora.zObject> updateZList = new List<Zuora.zObject>();
        
        Zuora.zObject obj = new Zuora.zObject('Invoice');
        
        String invoiceId = '2c92c0f94e001371014e02a0b2e744e7';
        
        obj.setValue('Id', invoiceId);
        obj.setValue('Invoice_Sequence_Number__c', 'US-00000001');
        obj.setValue('AccountId', '2c92c0f94e001371014e02a0b2e749d6');
        obj.setValue('Status', 'Posted');
        
        updateZList.add(obj);
        
        return updateZList;
        
    }
}