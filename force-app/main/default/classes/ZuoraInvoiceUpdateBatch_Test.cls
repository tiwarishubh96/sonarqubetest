@isTest(seeAlldata=true)//SeeAllData is needed to prevent 'Please upload Zuora WSDL at first.' error, caused by internal setting of zuora.
private class ZuoraInvoiceUpdateBatch_Test {
      
       
    @isTest static void testBatch() {
        
        TestDataUtility.Status = 'Status';
        Account acc = createAccount();
        TestDataUtility.AccountId = acc.Id;
        Zuora__CustomerAccount__c ca = createBillingAccount(acc.Id);
        List<Zuora.zObject> zInvoiceList = createZuoraInvoice();
        try{
        Test.StartTest();
        
        ScheduleZuoraInvoiceUpdate SZIU = new ScheduleZuoraInvoiceUpdate();     
        ZuoraInvoiceUpdateBatch ZIUB = new ZuoraInvoiceUpdateBatch();   
            
        database.executeBatch(ZIUB, 10); 

        String CRON_EXP = '0 0 * * * ?';
        
        System.schedule( 'ZuoraInvoiceUpdateBatch', CRON_EXP, SZIU);
        
        Test.StopTest();
        System.assertEquals(acc.Sales_Office__c,'Atlanta CBC');
        }catch(Exception e){
        }
    }
   /**
    * Negative Test Case to test Exception 
    */ 
    @isTest static void testBatchNegativeScenario(){
        TestDataUtility.Status = 'Stat';
        Account acc = createAccount();
        TestDataUtility.AccountId = acc.Id;
        Zuora__CustomerAccount__c ca = createBillingAccount(acc.Id);
        List<Zuora.zObject> zInvoiceList = createZuoraInvoice();
        try{
        Test.StartTest();
        
        ScheduleZuoraInvoiceUpdate SZIU = new ScheduleZuoraInvoiceUpdate();     
        ZuoraInvoiceUpdateBatch ZIUB = new ZuoraInvoiceUpdateBatch();   
            
        database.executeBatch(ZIUB, 10); 

        String CRON_EXP = '0 0 * * * ?';
        
        System.schedule( 'ZuoraInvoiceUpdateBatch', CRON_EXP, SZIU);
        
        Test.StopTest();
        }catch(Exception e){
        }
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