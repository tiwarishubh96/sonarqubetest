/**
* Batch process to sync Zuora invoice line items to SFDC on payment error. 
* - Processes all invoice payment records in error,  updating or inserting invoice line items for the related invoices. (US-45670)
*
* @author Richard Wintle
**/
global class FailedInvoiceItemBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public String query;
    public string zWhereClause;
    public Map<String, Id> zInvoiceIdToInvoiceIdMap;    // Zuora invoice Id to SF Invoice ID
    public Map<Id, List<Zuora__Payment__c>> invoiceIdToPaymentIdMap;    // SF invoice ID to SF payment IDs
    public Map<String, String> errorMessageMap;
    //
    // test only
    public Zuora.zObject testZInvoiceItem;
    
    /**
    * Initialise query
    * @param zQuery - query for errored payments
    **/
    public FailedInvoiceItemBatch(String zQuery){
        this.query=zQuery;
    }
    /**
    * Batch start - initialise and query of payments.
    * @param BC
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext BC){
        errorMessageMap=new Map<String, String>();
        return Database.getQueryLocator(query);
    }
    /**
    * Process failed payments batch.
    * @param BC
    * @param scope - payment records.
    **/
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        //
        // Resets for each batch of Payments
        zInvoiceIdToInvoiceIdMap=new Map<String, Id>();
        invoiceIdToPaymentIdMap=new Map<Id, List<Zuora__Payment__c>>();
        //
        Zuora__Payment__c zp;
        ZWhereClause='';
        //
        for(Sobject s : scope){
            zp = (Zuora__Payment__c) s;
            String zInvoiceId;
            system.debug('zp: '+zp);
            system.debug('inv ref: '+zp.Zuora__Invoice__c);
            if(zp.Zuora__Invoice__c!=null) {
                system.debug('inv zId ref: '+zp.Zuora__Invoice__r.Zuora__Zuora_Id__c);
                zInvoiceId=zp.Zuora__Invoice__r.Zuora__Zuora_Id__c;
                if(zInvoiceId!=null && zInvoiceIdToInvoiceIdMap.get(zInvoiceId)==null) {
                    zInvoiceIdToInvoiceIdMap.put(zInvoiceId, zp.Zuora__Invoice__c);
                }
                // map invoices to payments
                List<Zuora__Payment__c> paymentList=invoiceIdToPaymentIdMap.get(zp.Zuora__Invoice__c);
                if(paymentList==null) paymentList=new List<Zuora__Payment__c>();
                paymentList.add(zp);
                invoiceIdToPaymentIdMap.put(zp.Zuora__Invoice__c, paymentList);
            } else {
                processRecordError(zp, 'No invoice found for payment.', BC);
            }
        } 
        system.debug('inv map: '+zInvoiceIdToInvoiceIdMap);
        for(String zInvoiceId : zInvoiceIdToInvoiceIdMap.keySet()) {
            //Build ZOQL WHere CLause ADD OR Statement
            if(ZWhereClause.length() > 0)ZWhereClause += ' OR ';
            ZWhereClause += 'InvoiceId = \'' + zInvoiceId + '\'';
        }
        //Now sync the line to SFDC
        if(ZWhereClause.length() > 0) {
            syncLineItems(BC);
        }
    }
    /**
    * Finish method. Process leftover messages.
    **/
    public void finish(Database.BatchableContext BC){
        flushMessages(BC);
    }
    
    /**
    * Sync Salesforce invoice line items with those of Zuora.
    * @param BC
    **/
    public void syncLineItems(Database.BatchableContext BC){
        system.debug('synlineItems inv map: '+zInvoiceIdToInvoiceIdMap);
        List<Zuora.zObject> zInvoiceLineItemList;
        List<Invoice_Line_Item__c> sInvoiceLineItemList = new List<Invoice_Line_Item__c>();
        List<Zuora__Payment__c> paymentProcessedList=new List<Zuora__Payment__c>();
        //
        try{
            if (!Test.IsRunningTest()) {
                Zuora.zApi api = new Zuora.zApi();
                boolean done = false;      
                api.zlogin();
                
                //Set ZOQL for query request
                Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
                qr.zoql = 'SELECT Id, InvoiceId, ProductId, ProductName, ChargeName from InvoiceItem where ' + ZWhereClause;
                system.debug('ZOQL: '+qr.zoql);
                // Call zquery() to get initial results
                Zuora.zApi.QueryResult queryResult = api.zquery(qr);
                system.debug('zAPI queryResult: '+queryResult);
                zInvoiceLineItemList = queryResult.records;
            } else {
                zInvoiceLineItemList=new List<Zuora.zObject>();
                zInvoiceLineItemList.add(testZInvoiceItem);
            }
            //Loop through the result set and build the SFDC line items
            for(Integer i=0; i<zInvoiceLineItemList.size(); i++)
            {
                //Add to the SFDC list
                Invoice_Line_Item__c invoiceLineItem = New Invoice_Line_Item__c();
                invoiceLineItem.Zuora_Id__c=String.valueOf(zInvoiceLineItemList[i].getValue('Id'));
                invoiceLineItem.Charge_Name__c = String.valueOf(String.valueof(zInvoiceLineItemList[i].getValue('ChargeName')));
                //
                // set parent invoice
                String zInvoiceId=String.valueOf(zInvoiceLineItemList[i].getValue('InvoiceId'));
                if(zInvoiceIdToInvoiceIdMap.get(zInvoiceId)!=null) {
                    String invId=zInvoiceIdToInvoiceIdMap.get(zInvoiceId);
                    invoiceLineItem.Invoice__c = invId;
                    //
                    // update gateway response - assumes only one payment record (in error) processed per invoice.
                    List<Zuora__Payment__c> zpList=invoiceIdToPaymentIdMap.get(invId);
                    invoiceLineItem.Gateway_Response__c=zpList[0].Zuora__GatewayResponse__c;
                }
                // create ZProduct lookup
                String zProdExtId=String.valueOf(zInvoiceLineItemList[i].getValue('ProductId'));
                Product2 zProductReference = new Product2(zqu__ZuoraId__c=zProdExtId);
                invoiceLineItem.Product__r = zProductReference;
                //
                //Add to list
                sInvoiceLineItemList.add(invoiceLineItem);
            }    
            
            //Now check to see if we have records to upsert
            if(sInvoiceLineItemList.size() > 0){
                Set<String> invoiceProcessedSet=new Set<String>();
                //
                // Database upsert with payments update
                Schema.SObjectField extIdField = Invoice_Line_Item__c.Fields.Zuora_Id__c;
                Database.UpsertResult[] srList = database.upsert(sInvoiceLineItemList, extIdField, false);  // allOrNone = false
                for (Integer i = 0; i < srList.size(); i++) {
                    Database.UpsertResult sr = srList[i];
                    if (!sr.isSuccess()) {
                        processRecordError(sInvoiceLineItemList[i], 'Unable to create/update Invoice Line Item record: '+sr.getErrors()[0].getMessage(), BC);
                    } else {
                        invoiceProcessedSet.add(sInvoiceLineItemList[i].Invoice__c);
                    }
                }
                // Mark payments as processed for the processed invoices
                for(String invoiceId : invoiceProcessedSet) {
                    for(Zuora__Payment__c payment : invoiceIdToPaymentIdMap.get(invoiceId)) {
                        paymentProcessedList.add(new Zuora__Payment__c(Id=payment.Id, Error_Processed__c=true));
                    }
                }
            }
            //
            // update all payment records that were processed
            if(paymentProcessedList.size()>0)
                update paymentProcessedList;
            //
            // flush messages
            flushMessages(BC);
            //
        }catch(exception e){
            System.debug('ERROR:' + e);
            ExceptionHandler.CatchException('FailedInvoiceItemBatch','syncLineItems',e);
        }
    }
    /**
    * Helper method to write out messages to logger object with job Id reference.
    * @param BC
    **/
    public void flushMessages(Database.BatchableContext BC) {
        if(errorMessageMap!=null && errorMessageMap.size()>0) {
            String jobId='<no jobId>';
            if(BC!=null) { jobId=BC.getJobId();}
            ExceptionHandler.logZuoraRecordProcessingErrors('FailedInvoiceItemBatch','syncLineItems:'+jobId, errorMessageMap);
            errorMessageMap=new Map<String, String>();
        }
    }
    /**
    * Helper method to store record error messages for later processing.
    * @param recDetail - record to reference
    * @param resultErrorMessage - message
    * @param BC
    **/
    public void processRecordError(sObject recDetail, String resultErrorMessage, Database.BatchableContext BC) {
        system.debug('Record in error: '+recDetail);
        String traceMessage='MESSAGE='+resultErrorMessage; 
        traceMessage=traceMessage +'| RECORD='+ recDetail;  
        traceMessage=traceMessage.normalizeSpace().left(1000);
        system.debug('Record error message: '+traceMessage);
        errorMessageMap.put(recDetail.Id, traceMessage);
    }
}