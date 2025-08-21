global class ZuoraInvoiceUpdateBatch implements Database.Batchable < Zuora.zObject >, Database.AllowsCallouts, Database.Stateful {
/*-------------------------------------------------------------
    Author:         Zohar Sinay
    Company:       
    Description:   Batch Class to pull all the Draft Invoices from Zuora, populate each one with a sequential Regional Invoice Number        
                   Contains Sample Method which can be used / removed as required 
                   All Methods need not be implemented as Interface is already implemented by DefaultTriggerHandler
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  7th Sep 2015     Rohit (Salesforce.Com)       Batch Class Re-Designed as part of Sage R1.5 release
  ------------------------------------------------------------*/
  
  // Collection and Variable Declaration
    public static String ZUORA_INVOICE = 'Invoice';
    Set<string> zuoraProcessedRecordId = new set<string>(); // Set to contain zuoraProcessedRecordId
    List<Zuora.zObject> zList { get; set; }
    List<zuoraErrorHandler> errorMessagesList = new List<zuoraErrorHandler> ();  // List of Error Handler Wrapper Class
    List<Zuora.zApi.SaveResult> results; // Object to store zUpdate results
    List<Sobject> invoiceSObjectList = new List<Sobject>();
    Map<id,string> zuoraErrorRecordId = new Map<id,string> (); // Set to contain zuoraErrorRecordId
    Map<string, string>  invoiceIdByRegionalIdMap = new Map<string,string> (); // This would contain map of invoice Id and regionalId
    Map<string, string>  accountRegionMap = new Map<string, string> ();
    Map<string, string>  accountSoldToCountryMap = new Map<string, string> ();
    Map<string, string>  autoNumberByInvoiceIdMap = new Map<string, string> ();
    Map<string, string>  zInvoiceIdAccountIdMap = new Map<string, string> ();
    Map<String, String>  zAccountNameByIdMap = new Map<String, String> ();
    Map<String, String>  zInvoiceIdByInvoiceNumberMap = new Map<String, String> ();
    Map<string,string> invoiceAutoNumberByErrorMessage = new Map<string,string>();
    Boolean hasMoreRecords { get; set; } // Boolean Variable 
    Zuora.zApi zApiInstance;
    string zuoraAccountId; 
    // Constructor Declaration 
    global ZuoraInvoiceUpdateBatch() {
    }
    
    /**
     *  @desc Start Method 
     *        Fetch all the invoices from Zuora in Draft Status and pass it to Iterable Interface . 
     *        Generating Autonumber records for each Invoice here which will be used in execute method. This is done in Start method to avoid salesforce uncommitted transaction error 
     */ 
    global Iterable < Zuora.zObject > start(Database.batchableContext info) {

        System.debug('start');

        zApiInstance = ZuoraUpdateUtility.loginToZuora('ZuoraInvoiceUpdateBatch');  // Call the loginToZuora method from ZuoraUpdateUtility to login to the Zuora API               
        //EAD-1889
        //String zoql_old = 'SELECT Id,AccountId,InvoiceNumber FROM Invoice WHERE Status=\'Draft\''; // ZOQL Query to be executed in Zuora Application        
        String zoql = 'SELECT Id,AccountId,InvoiceNumber,IsTaxCalculated__c FROM Invoice WHERE ' + System.Label.Invoice_Zoql;

        System.debug('after zoql');
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest(); // Create instance of Zuora.aApi.QueryRequest to pass as parameter in zApiInstance.zquery
        qr.zoql = zoql;   // intialize Zuora.zApi.QueryRequest object to with zoql query as string 
        if (! Test.isRunningtest()) {
            Zuora.zApi.QueryResult queryResult = zApiInstance.zquery(qr); // Execute zoql query
            /**
             * Zuora.zApi.QueryResult would return four parameters
             * @paramReturned done ( Boolean ) : Indicates whether the query is complete (true) or not (false). 
             * @paramReturned queryLocator (String) : String If done is false, this value can be passed to the zqueryMore() method to retrieve the next series of records
             * @paramReturned records (List) : An array of zObjects of the appropriate type (Product, Account, Invoice, etc.), containing the requested data.
             * @paramReturned size (Integer) : The number of rows retrieved. If size is equal to zero, then no rows were retrieved.
             */
            zList = queryResult.records;
            hasMoreRecords = !queryResult.done;  //  Returned as True if Invoice Object has more then 2000 records , 2000 records are returned in one go.
        }
        else {
            //adding test data - as the data comes from Zuora, we cannot retrieve it in order to test the method from Salesforce, without it there will be many lines not covered within our code.
            Zuora.zObject invoice_1 = createZuoraObject('Invoice', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountId' => '2c92c0f94e03d39e014e05cd105f17E4', 'Status' => 'Draft' });
            Zuora.zObject invoice_2 = createZuoraObject('Invoice', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountId' => '2c92c0f94e03d39e014e05cd105f17f6', 'Status' => 'Draft' });
            zList = new List<Zuora.zObject> { invoice_1, invoice_2 };
            hasMoreRecords = false;
        }
        // Call the generateAutoNumbers method to create a Regional Invoice Number for each Invoice retrieved from Zuora

        generateAutoNumbers(zList);
        return new ZuoraInvoiceCustomIterable(zList);
    }

    /**
     * @desc Execute Method
     *       This method receives 50 records at max because of Zuora Limit. 
     *       It updates the Regional Invoice number and and makes an update call to Zuora to update Invoice number, then send a regenerate PDF update request and sends an update request to update invoice status to posted.
     */ 
    global void execute(Database.batchableContext info, List<Zuora.zObject> scope) {
        //errorMessagesList.clear();
        
        List<Zuora.zObject> updateZList = new List<Zuora.zObject> ();
        List<Zuora.zObject> updateZInvoiceNumberList = new List<Zuora.zObject> ();
        List<Zuora.zObject> updateZInvoicePDFList = new List<Zuora.zObject> ();
        List<Zuora.zObject> updateZInvoiceStatusList = new List<Zuora.zObject> ();
        for (Zuora.zObject z : scope) {
            String invoiceId = (String) z.getValue('Id');
            zuoraAccountId = (String) z.getValue('AccountId');
            // Create Map of Invoice Id and Account Id , this would be used while to fetch object type while inserting error logs on the failed callout process
            zInvoiceIdAccountIdMap.put((String) z.getValue('Id'), (string) z.getValue('AccountId'));
            zInvoiceIdByInvoiceNumberMap.put((String) z.getValue('Id'),(string) z.getValue('InvoiceNumber'));
            if (String.isNotBlank(autoNumberByInvoiceIdMap.get(invoiceId))){
                if(!Test.isRunningTest()){
                    // Prepare ZInvoiceList to Update Invoice Id (autonumber generated in Salesforce) to Zuora
                    addItemToZInvoiceList(updateZInvoiceNumberList, new Map<String, Object> { 'Id' => invoiceId, 'Invoice_Sequence_Number__c' => autoNumberByInvoiceIdMap.get(invoiceId) });
                 }
               }
             // Adding this test method to create Test Data for UpdateZInvoiceNumberList , we can't do Zuora Callout in test class hence creating dummy test data  
             if (Test.isRunningTest()){
                   // Create ZObject Dummy Test Data 
                    addItemToZInvoiceList(updateZInvoiceNumberList, new Map<String, Object> { 'Id' => '2c92c0f94e001371014e02a0b2e744e7', 'Invoice_Sequence_Number__c' => 'US-00000001' });
               }
            }
        /**
         *  Callout to first update  Regional Invoice Number 
         *  Re-generate pdf  
         *  Post the Invoice to make sure that an updated Invoice PDF is sent to the customer by Zuora
         */ 
        try {
            /**
             * @desc zUPdate would return three parameters
             * @param Errors (List of zObjects )If the update failed, this contains an array of error objects.
             * @param Id (String )  ID of the updated object.
             * @param Success (Boolean) If the update was successful, true. Otherwise, false.
             */ 
              if(updateZInvoiceNumberList.size() > 0){
                if(!Test.isRunningTest()){ // Callout when test class is not working
                     results = zApiInstance.zUpdate(updateZInvoiceNumberList);
                }else{ // Create a dummy result object as callout did not happen
                    results = TestDataUtility.createDummyResult();
                }
                // If the callout was successful then prepare/process another list
                processZuoraUpdateResult(results,'zApiInstanceCalloutForInvoiceAutoNumberUpdate');
                //Recreate the pdf list
                for(Zuora.zObject z : scope){
                    String invoiceId = (String) z.getValue('Id');
                    if(String.isNotBlank(autoNumberByInvoiceIdMap.get(invoiceId)) && !Test.isRunningtest() && zuoraProcessedRecordId.contains(invoiceId)){
                        addItemToZInvoiceList(updateZInvoicePDFList, new Map<String, Object> { 'Id' => invoiceId, 'RegenerateInvoicePDF' => true });
                    }
                    // Adding this test method to create Test Data for UpdateZInvoiceNumberList , we can't do Zuora Callout in test class hence creating dummy test data  
                    if (Test.isRunningTest()){
                        // Create ZObject Dummy Test Data 
                        addItemToZInvoiceList(updateZInvoiceNumberList, new Map<String, Object> { 'Id' => '2c92c0f94e001371014e02a0b2e744e7', 'RegenerateInvoicePDF' => true });
                    }
                }
                try{
                    if(!Test.isRunningTest()){// Callout when test class is not working
                         results = zApiInstance.zUpdate(updateZInvoicePDFList);
                    }else{// Create a dummy result object as callout did not happen
                        results = TestDataUtility.createDummyResult();
                    }
                   
                    // If the callout was successful then prepare/process another list
                    processZuoraUpdateResult(results,'zApiInstanceCalloutforPDFUpdate');
                   //Process record for status update   
                   for(Zuora.zObject z : scope){
                    String invoiceId = (String) z.getValue('Id');
                    if(String.isNotBlank(autoNumberByInvoiceIdMap.get(invoiceId)) && !Test.isRunningtest() && zuoraProcessedRecordId.contains(invoiceId)){
                        addItemToZInvoiceList(updateZInvoiceStatusList, new Map<String, Object> { 'Id' => invoiceId, 'Status' => 'Posted' });
                      }
                    if (Test.isRunningTest()){
                        // Create ZObject Dummy Test Data 
                        addItemToZInvoiceList(updateZInvoiceNumberList, new Map<String, Object> { 'Id' => '2c92c0f94e001371014e02a0b2e744e7',  TestDataUtility.Status => 'Posted' });
                      }
                    }
                    try{
                        if(!Test.isRunningTest()){// Callout when test class is not working
                             results = zApiInstance.zUpdate(updateZInvoiceStatusList);
                        }else{ // Create a dummy result object as callout did not happen
                             results = TestDataUtility.createDummyResult();
                        }
                        // If the callout was successful then prepare/process another list
                        processZuoraUpdateResult(results,'zApiInstanceCalloutforStatusUpdate');
                    }catch(Exception e){
                        ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','zApiInstanceCalloutforStatusUpdate',e);
                    }
                }catch(Exception e){
                    ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','zApiInstanceCalloutforPDFUpdate',e);
                }   
              }
          }
        catch(exception e) {
            ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','zApiInstanceCalloutForInvoiceAutoNumberUpdate',e);
        }
          // Creating ZuoraRecordError Id Map, it difficult to generate error codes in batch as there won't be any callout , generating error codes manually here
        if(test.isRunningTest()){
             Id invId;
             // Creating a dummy map and data .
             invId = TestDataUtility.createInvoice().Id; // Call to utility class to create invoice and generate unique Id
             accountRegionMap.put(invId,'Atlanta CBC');
              zuoraErrorRecordId.put(invId,'ErrorMessagezApiInstanceCalloutForInvoiceAutoNumberUpdate');
              zInvoiceIdAccountIdMap.put((string)invId,TestDataUtility.AccountId);
              
              invId = TestDataUtility.createInvoice().Id;
              zuoraErrorRecordId.put(invId,'ErrorMessagezApiInstanceCalloutforPDFUpdate');
              zInvoiceIdAccountIdMap.put((string)invId,TestDataUtility.AccountId);
              
              invId = TestDataUtility.createInvoice().Id;
              zuoraErrorRecordId.put(invId,'ErrorMessagezApiInstanceCalloutforStatusUpdate');
              zInvoiceIdAccountIdMap.put((string)invId,TestDataUtility.AccountId);
              
              accountRegionMap.put((string)TestDataUtility.AccountId,'Atlanta CBC'); // Fetch Account Id from Utility Class
         }
         /**
         *  Loop through all the error Message and Update Logger as well as Invoice Object
         */ 
        for(Id invoiceId : zuoraErrorRecordId.keySet()){
            // Find the Object Type and Create Instance of It
               // Fetch invoice object API name from custom sertting Zuora Invoce Mapping    
                 String invoiceObjApi = Zuora_Invoice_Mapping__c.getAll().get(accountRegionMap.get(zInvoiceIdAccountIdMap.get(invoiceId))).Invoice_Object__c;
                 sObject sObj = Schema.getGlobalDescribe().get(invoiceObjApi).newSObject();
                  // Process Error Codes to user friendly message
                 String errorMessage = processErrorMessage(zuoraErrorRecordId.get(invoiceId));
                  // Fetch Invoice SF  Record Id based on Zuora Invoice Id
                 if( invoiceIdByRegionalIdMap.size() >0 && invoiceIdByRegionalIdMap.get(invoiceId) != null){
                        sObj.put('Id', invoiceIdByRegionalIdMap.get(invoiceId));
                        sObj.put('Z_Invoice_Error_Message__c',errorMessage);
                        invoiceSObjectList.add(sObj);
                 }
              
                 
            // Create Map of Invoice AutoNumber and ErrorMessage, this would be required to log AutoNumberId as well Invoice Id in Logger Object
                 string keyId = invoiceId+'-'+(string) autoNumberByInvoiceIdMap.get(invoiceId);
                 invoiceAutoNumberByErrorMessage.put((string) keyId,(string) zuoraErrorRecordId.get(invoiceId)); 
            // Create Wrapper List for Error Message to be sent as Email
                 if(zInvoiceIdAccountIdMap.get(invoiceId) != null && zAccountNameByIdMap.get(zInvoiceIdAccountIdMap.get(invoiceId)) != null && zInvoiceIdByInvoiceNumberMap.get(invoiceId)!= null){
                     // This error is already logged so passing boolean variable as false
                     errorMessagesList.add(new zuoraErrorHandler(zInvoiceIdAccountIdMap.get(invoiceId), zAccountNameByIdMap.get(zInvoiceIdAccountIdMap.get(invoiceId)),errorMessage,zInvoiceIdByInvoiceNumberMap.get(invoiceId),false));
                 }
                    
        }
        // Update Invoice Records with Errors if it exists
        if(invoiceSObjectList.size() > 0){
                try{
                 // Sort invoiceSObjectList to avoid chunking issue
                 invoiceSObjectList.sort();
                 Database.Update(invoiceSObjectList);
                 // Insert Zuora Record Processing Error Message
                 ExceptionHandler.logZuoraRecordProcessingErrors('ZuoraUpdateInvoiceBatch','ErrorLogUpdateForCalloutInBatchs',invoiceAutoNumberByErrorMessage);
                 // Insert Errror Handler Log into Logger Object
                 //invoiceAutoNumberByErrorMessage.clear(); // Clear the Map to log errors where Zuora Account Id could not be found in Salesforce Billing Account Records
                 
                   }catch(Exception ex){
                        ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','ErrorLogUpdateForCalloutInBatch',ex);
                   }
            }
    }
   /**
    *  @desc Finish Method
    *        If there are more then 2000 records returned then same batch class is scheduled again.
    *        Need to update exception handling for list of error records during callout
    */ 
    global void finish(Database.batchableContext info) {

        
        String subject = '';
        String htmlEmailBody = '';
        String errorMessage = '';
        String keyVal = '';
        // Update Error 
        // log Error Message that would be sent as part of email
        // Condition to log error where Zuora Account ID could not be found in Salesforce Billing Account Records
        for (zuoraErrorHandler zeh : errorMessagesList) {
              if(zeh.logErrorMessage){
                 // Error Message when there is no Invoice Number
                 errorMessage = Label.lbl_Zuora_Account_Id + ' \"' +zeh.accountid + '\"; ' + Label.lbl_Zuora_Account + ' \"' + zeh.accountName + '\"; ' + Label.lbl_Zuora_Error_Message + ' \"'+ zeh.errorMessage + '\"';
                 }
              keyVal = 'ZuoraAccountID : '+zeh.AccountId;
              invoiceAutoNumberByErrorMessage.put(keyVal,errorMessage);
             }
        // This error would occur while generating autonumbers hence passing predefined value. This block is placed in Finish Method as batch implements Database.Stateful.
        // This approach would help avoid same erros from being created multiple times when the batch process executes for multiple times
        if(invoiceAutoNumberByErrorMessage.size() > 0){
                ExceptionHandler.logZuoraRecordProcessingErrors('ZuoraInvoiceUpdateBatch','generateAutoNumbers',invoiceAutoNumberByErrorMessage);
            }
        
        // Schedule the batch again there are more then 2000 Invoices
        if (hasMoreRecords) {
            System.scheduleBatch(new ZuoraInvoiceUpdateBatch(), 'ZuoraInvoiceUpdateBatch', 1, 50);
        }
        if (errorMessagesList.size() > 0) {
            subject = Label.lbl_unsuccessful_batch;
            htmlEmailBody = Label.lbl_unsuccessful_bodyMessage + ' ' + Datetime.now() + ' ' + Label.lbl_Zuora_Batch_Process_Completed_with_errors +  + '<br> <br>';
        } else {
            subject = Label.lbl_successful_batch;
            htmlEmailBody = Label.lbl_unsuccessful_bodyMessage + ' ' + Datetime.now() + ' ' + Label.lbl_Zuora_Batch_Process_Completed_Successfully +  + '<br> <br>';
        }
        for (zuoraErrorHandler zeh : errorMessagesList) {
            if(zeh.invoiceNumber == null){ // Error Message when there is no Invoice Number
                htmlEmailBody += Label.lbl_Zuora_Account_Id + ' \"' +zeh.accountid + '\"; ' + Label.lbl_Zuora_Account + ' \"' + zeh.accountName + '\"; ' + Label.lbl_Zuora_Error_Message + ' \"'+ zeh.errorMessage + '\";' + '<br>';
            }else{
                htmlEmailBody += Label.lbl_Zuora_Account_Id + ' \"' +zeh.accountid + '\"; ' + Label.lbl_Zuora_Account + ' \"' + zeh.accountName + '\"; ' + Label.lbl_Zuora_Invoice_Number + ' \"' + zeh.invoiceNumber + '\"; ' +Label.lbl_Zuora_Error_Message + ' \"'+ zeh.errorMessage + '\";' + '<br>';
            }
        }
        if (htmlEmailBody != '') {
            List<String> emailsList = new List<String> { Zuora_Invoice_Mapping__c.getValues('ContactEmail').notifyErrorEmail__c };
            sendEmail(subject, htmlEmailBody, emailsList);
        }
    }

    /**
     *  @desc This method sends an email with a subject and body, to a list of addresses.
     */ 
    public static void sendEmail(String subject, String htmlEmailBody, List<String> emailsList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(emailsList);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlEmailBody);

        // Send the email (if not running in test mode)
        if (!Test.isRunningtest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    /**
     * @desc This would initialize the list for processing . It's pass by reference
     * @param List<Zuora.zObject>, Map<String, Object>
     */ 
    public void addItemToZInvoiceList(List<Zuora.zObject> zInvoiceList, Map<String, Object> zuoraInvoiceValueByFieldMap) {
        Zuora.zObject zInvoiceObject = new Zuora.zObject('Invoice');
        set<Sobject> invoiceSobjectSet= new set<Sobject>();
        try{
            for (String field : zuoraInvoiceValueByFieldMap.keySet()) {
                zInvoiceObject.setValue(field, zuoraInvoiceValueByFieldMap.get(field));
            }
        zInvoiceList.add(zInvoiceObject);
        }catch(Exception ex){
            // Create error message for Invoice Records,Create invoiceSObjectList with errors
                     for(String field : zuoraInvoiceValueByFieldMap.keySet()){
                        
                        String invoiceId = (string)zuoraInvoiceValueByFieldMap.get('Id');
                        String invoiceObjApi = Zuora_Invoice_Mapping__c.getAll().get(accountRegionMap.get(zInvoiceIdAccountIdMap.get((string)invoiceId))).Invoice_Object__c;
                        sObject sObj = Schema.getGlobalDescribe().get(invoiceObjApi).newSObject();
                        sObj.put('Id', invoiceIdByRegionalIdMap.get(invoiceId));
                        sObj.put('Z_Invoice_Error_Message__c',ex.getMessage());
                        invoiceSObjectset.add(sObj);   
                     }
                     
                     invoiceSObjectList.addAll(invoiceSObjectset);
            // Update Error in Logger Object
            ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','addItemToZInvoiceList',ex);
            // Update Email Log
             // This error is already logged so passing boolean variable as false, if schema is wrong then it will be wrong for all invoice records so not creating error log by invoice or by account
                     errorMessagesList.add(new zuoraErrorHandler('','',ex.getMessage(),'',false));
        }
    }
    /**
     * Inserts records in the Regional Invoice objects, retrieves autonumbers and stores them in a Map
     */ 
    public void generateAutoNumbers(List<Zuora.zObject> scope) {
        
        Set<String> zuoraInvoiceId = new Set<String> ();
        List<String> zuoraAccountIdSet = new List<String> ();
        List<Zuora.zObject> updateZList = new List<Zuora.zObject> ();
        // Get all the Zuora Account Ids to query Accounts in Salesforce
        for (Zuora.zObject z : scope) {
            zuoraAccountIdSet.add((String) z.getValue('AccountId'));  //list of account name
            zuoraInvoiceId.add((String) z.getValue('Id'));  //list of account id
          }
        
        List<Zuora.zObject> zobjs = new List<Zuora.zObject> ();
        if (zuoraAccountIdSet.size() > 0) {
            Decimal numOfQueries = zuoraAccountIdSet.size() / 200.0;
            Decimal roundedNumOfQueries = numOfQueries.round(System.RoundingMode.CEILING);
            // prepare zoql query to select account where Account details for Account Id  returned from Invoice object    
            for (integer i = 0; i < roundedNumOfQueries; i++) {
                String zoql = 'SELECT Id,Name FROM Account WHERE';
                // Query not more then 200 records in one Go , since at max 2000 records were returned for Invoice object , this loop would not run more then 10 times
                Integer doUntil = Math.min(i * 200 + 200, zuoraAccountIdSet.size());
                for (integer j = i * 200; j < doUntil; j++) {
                    if (j < zuoraAccountIdSet.size())
                    zoql += ' Id=' + '\'' + zuoraAccountIdSet[j] + '\'' + ' or';
                }
                zoql = zoql.removeEnd('or');
                if (! Test.isRunningtest()) {
                  try{
                    zobjs.addall(zApiInstance.zquery(zoql)); //zobjs would contain list of all Account record returned
                  }catch(Exception ex){
                     ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','generateAutoNumbers',ex); 
                  }
                }
                else {
                    Zuora.zObject account_1 = createZuoraObject('Account', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'Name' => 'Test S3' });
                    zobjs = new List<Zuora.zObject> { account_1 };
                }

            }
            for (Zuora.zObject z : zobjs) { // Create a map of account Id and name
                zAccountNameByIdMap.put((String) z.getValue('Id'), (String) z.getValue('Name'));
            }
        }
        //Retrieving the Sales Office in order to determine which Regional Invoice object to use)
        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id,
                                                           Zuora__Account__r.Sales_Office__c,
                                                           Zuora__Zuora_Id__c,Zuora__BillToCountry__c
                                                           FROM Zuora__CustomerAccount__c
                                                           WHERE Zuora__Zuora_Id__c IN :zuoraAccountIdSet];
                                                           
        
        /**
         * find for which of Account Id(zuoraAccountIdset) returned as per query to Invoice object the billingAccounts is not found.
         * If not found create error wrapper that would be sent as part of email messages
         */
        findBillingAccNotInSF(billingAccounts, zuoraAccountIdSet, zAccountNameByIdMap);

        // Create a map of Zuora Id and Accounts Sales region. This map is used to decide which Regional Invoice object to
        // use for generating Autonumbers.
        for (Zuora__CustomerAccount__c ba : billingAccounts) {
           // creates a map of zuoraId and Sales office
            if (!String.isBlank(ba.Zuora__Account__r.Sales_Office__c)){
                accountRegionMap.put(ba.Zuora__Zuora_Id__c, ba.Zuora__Account__r.Sales_Office__c);
                accountSoldToCountryMap.put(ba.Zuora__Zuora_Id__c,ba.Zuora__BillToCountry__c);
            }

            else
            errorMessagesList.add(new zuoraErrorHandler(ba.Zuora__Zuora_Id__c, zAccountNameByIdMap.get(ba.Zuora__Zuora_Id__c), Label.lbl_no_salesOffice,'',true));
        }
        // Create list of type sObject
        List<sObject> invoiceObjects = new List<sObject> ();
        list<sObject> invoiceObjectbyType = new list<sObject>();
        // Using Map instead of list to chunks sobjects of similar type together
        Map<Schema.SObjectType, List<Sobject>> sObjectMap = new Map<Schema.SObjectType, List<Sobject>>();
        // Based on the region, create a list of sObject to be inserted. This list can contain records 
        // of multiple invoice objects.
        for (Zuora.zObject z : scope) {
            
            String zAccountId = (String) z.getValue('AccountId');
            String invoiceId = (String) z.getValue('Id');
            String invoiceNumber = (String) z.getValue('InvoiceNumber');
            String isTaxCalculated = (String) z.getValue('IsTaxCalculated__c');

            System.debug('Invoice Number '+invoiceNumber);
            System.debug('Istaxcalculated '+isTaxCalculated);

            if (accountRegionMap.get(zAccountId) == null)
            continue;
            // Fetch invoice object API name from custom sertting Zuora Invoce Mapping
            if (Zuora_Invoice_Mapping__c.getAll() == null || Zuora_Invoice_Mapping__c.getAll().get(accountRegionMap.get(zAccountId)) == null)
                continue;
            if(accountSoldToCountryMap.get(zAccountId)=='Canada' && isTaxCalculated != 'true'){
                System.debug('will not post invoice for canadian contact.');
                continue;
            }

            String invoiceObjApi = Zuora_Invoice_Mapping__c.getAll().get(accountRegionMap.get(zAccountId)).Invoice_Object__c;
            sObject sObj = Schema.getGlobalDescribe().get(invoiceObjApi).newSObject();
            sObj.put('Z_Invoice_Id__c', invoiceId);
            sObj.put('Z_Invoice_Number__c', invoiceNumber);
            // Grouping sObject of Same Type together
            Schema.SObjectType objType = sObj.getSObjectType();
            if (! sObjectMap.containsKey(objType)) {
                sObjectMap.put(objType, new List<Sobject>());
            }
                sObjectMap.get(objType).add(sObj);
        }
            while(sObjectMap.size() > 0) {
                // Create a new list, which can contain a max of chunking limit, and sorted, so we don't get any errors
                for (Schema.SObjectType obj : sObjectMap.keyset()) {
                    invoiceObjectbyType.clear();
                    invoiceObjectbyType.addAll(sObjectMap.get(obj)); // Add sObject records to list for porcessing
                    // This is done to avoid chunking issue. There cannot be more then 10 chunks . if there are 2000 records and if invoice of one object type has more then 
                    // 1000 records then its more likely that we would hit chunking issue as one chunk would contain object of one type.
                     try{
                         Database.insert(invoiceObjectbyType, false);
                         sObjectMap.remove(obj); // Remove map key to reduce heapSize
                         invoiceObjects.addAll(invoiceObjectbyType); // create sobject list of invoice records
                     }catch(Exception ex){
                         ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch'+invoiceObjects.size(),'loginToZuora',ex);
                     }
                    
                }
            }
            
        Map<String, Set<String> > invoiceIdsMap = new Map<String, Set<String> > ();
        // Create a map for each region vs records created for each region.
        for (sObject sObj : invoiceObjects) {

                    String objType = sObj.getSObjectType().getDescribe().getName();
        
                    if (invoiceIdsMap.get(objType) == null) {
                        invoiceIdsMap.put(objType, new Set<String> ());
                    }
                    invoiceIdsMap.get(objType).add((String) sObj.get('Z_Invoice_Id__c'));
                 }
  
        // For each region, query the Regional Invoice records which were inserted to retrieve the Regional Invoice Number (the Autonumber Name).
        // NB - the SOQL has to be in a for loop because there is a different Regional Invoice object per region.
        for (String objType : invoiceIdsMap.keySet()) {
            Set<String> invoiceObjIdSet = invoiceIdsMap.get(objType);
            List<sObject> sObjList = Database.query('SELECT Id, Name, Z_Invoice_Id__c FROM ' + objType + ' WHERE Z_Invoice_Id__c IN:invoiceObjIdSet');

            for (sObject sObj : sObjList) {
                invoiceIdByRegionalIdMap.put((String) sObj.get('Z_Invoice_Id__c'), (String) sObj.get('Id'));
                autoNumberByInvoiceIdMap.put((String) sObj.get('Z_Invoice_Id__c'), (String) sObj.get('Name'));
            }
        }
    }
    
    /**
     *  @desc Creates a errormessage wrapper list to be used while send an email
     */ 
    public Void findBillingAccNotInSF(List<Zuora__CustomerAccount__c> billingAccounts, List<String> zuoraAccountIdSet, Map<String, String> zAccountNameByIdMap) {
        Set<String> billingAccountIdSet = new Set<String> ();
        for (Zuora__CustomerAccount__c ba : billingAccounts)
        billingAccountIdSet.add(ba.Zuora__Zuora_Id__c);
        for (String zaId : zuoraAccountIdSet) {
            if (!billingAccountIdSet.contains(zaId)){
            errorMessagesList.add(new zuoraErrorHandler(zaId, zAccountNameByIdMap.get(zaId), Label.lbl_no_billingAccount,'',true));
            }
        }
    }
    /**
     * @desc Method to Process Zuora Update results
     * @Param list of Zuora.zApi.SaveResult on Update
     */
     private void processZuoraUpdateResult(list<Zuora.zApi.SaveResult> results,String calloutName){
         //Process Results 
            zuoraProcessedRecordId.clear(); // Clear the Set every time 
            for (Zuora.zApi.SaveResult result : results) {
                    if(result.success){
                        zuoraProcessedRecordId.add(result.id);
                    }else{
                        Zuora.zObject[] errors = result.errors;
                        for(Zuora.zObject error: errors){
                             String errorDetails = callOutName+'-'+(String)error.getValue('Code')+ '' + (String)error.getValue('Message');
                             zuoraErrorRecordId.put(result.Id,errorDetails);
                        }
                    }
                }
           }
           
    /**
     * [createZuoraObject creates in the zuora object all the fields with their new values from the 'fieldValueByNameMap']
     * @param  objName                         [Zuora object name]
     * @param  id                              [id in Zuora]
     * @param  Map<String,fieldValueByNameMap> [new field value by zuora api map]
     * @desc This class is only called during test execution (and therefore the 2 callouts will not be included in the callout limit during an actual execution)
     */
    public static Zuora.zObject createZuoraObject(String objName, String id, Map<String, Object> fieldValueByNameMap) {
        Zuora.zObject obj;
        try {
            obj = new Zuora.zObject(objName);
        } catch(Exception e) {
            ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','createZuoraObject',e);
        }

        try {
            if (id != null && id != '') {
                for (String field : fieldValueByNameMap.keySet()) {
                    obj.setValue(field, fieldValueByNameMap.get(field));
                }
            }
        } catch(Exception e) {
            ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','createZuoraObject',e);
        }

        return obj;

    }
    /**
     * Method to process Error Message to more User Friendly Labels
     * @Param ErrorCodes
     */
     private string processErrorMessage(String errorCodes){
         string errorMessage ='';
         // Update Error Message to be displayed on Invoice Object to display just reason for failure
         if(errorCodes.contains('zApiInstanceCalloutForInvoiceAutoNumberUpdate'))
             errorMessage = label.lbl_RegionalInvoiceNumberCalloutError;
         else if(errorCodes.contains('zApiInstanceCalloutforPDFUpdate'))
             errorMessage = label.lbl_RegionalInvoicePDFCalloutError;
         else if(errorCodes.contains('zApiInstanceCalloutforStatusUpdate'))
             errorMessage = label.lbl_InvoiceStatusToPostedCalloutError;
         else
             errorMessage = errorCodes;
             
         return errorMessage;
     }
     
    /**
     *   @ Description: This class holds the account name, account id and error message to display on the mail being sent to the user after batch job runs.
     */ 
    public class zuoraErrorHandler {
        public String accountid;
        public String accountName;
        public String errorMessage;
        public String invoiceNumber; // Adding invoiceNumber information into error message as per R1.5
        public boolean logErrorMessage; // This boolean flag is required to check if error to be sent as part of email message has to be logged
        public zuoraErrorHandler(String accountid, String accountName, String errorMessage,string invoiceNumber,boolean logErrorMessage) {
            this.accountid = accountid;
            this.accountName = accountName;
            this.errorMessage = errorMessage;
            this.invoiceNumber = invoiceNumber; // Adding invoiceNumber information into error message as per R1.5
            this.logErrorMessage = logErrorMessage;
        }
    }
}