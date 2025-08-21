/*-------------------------------------------------------------
Author:         Raja Patnaik
Date :          06/02/2017
Company:       
Description:   Zuora Helper Class to Make ZOQL API call to get Invoice Item, Invoice Line Item,Rate Plan Charge,Credit Balance Adjusment
and update Credit Balance and Invoice Line Adj on Invoice and Order Details respectively.
Inputs:        None
History
<Date>            <Authors Name>                <Brief Description of Change>

------------------------------------------------------------*/
global class SPPUpdateZuoraInvoicesDetails
{
    
    @InvocableMethod
    global static List<String> ZuoraInvoiceDetails(List<Id> ZuoraIds) 
    {
        ZuoraCalloutAsync(ZuoraIds);
        return null;
    }
    
    @future(callout=true)
    global static void ZuoraCalloutAsync(List<Id> ZuoraIds)
    {
        string strInvoiceIds;
        string strRatePlanIds;
        string strInvoiceitemsIds;
        string strCreditBalInvIds;
        set<string> setZuoraInvoicesId = new set<String>();
        Set<String> setZuoraInvoicesLineId = new Set<String>();
        Set<String> setZuoraCreditBalAdjInvId = new Set<String>();
        Map<String,Zuora.zObject> mapInvCreditBalAdj = new Map<String,Zuora.zObject>();
        Map<string,set<Zuora.zObject>> InvItemsMap = new Map<string,set<Zuora.zObject>>();
        Map<string,set<Zuora.zObject>> InvAndInvItemMap = new Map<string,set<Zuora.zObject>>();
        set<string> setZuoraIds = new set<String>();
        
        string strAddSupportData='';
        
        try
        {
            //Fetching all the fields of Zuora Invoice object
            string fieldsAPIname=SPPUtils.ObjectFields('Zuora__ZInvoice__c');
            
            List<SPP_RR_Invoice__c> lstNoInvoice = [Select Id,Credit_Balance__c,Zuora_Invoice__r.Id from SPP_RR_Invoice__c where Zuora_Invoice__r.Id in: ZuoraIds and Invoiced__c = 0];
            for(SPP_RR_Invoice__c obj : lstNoInvoice)
            {
                setZuoraIds.add(obj.Zuora_Invoice__r.Id);
            }
            
            //Retriving data based on the Zuora Invoice IDs   
            List<Zuora__ZInvoice__c> zInvId = Database.query('Select '+fieldsAPIname+' from Zuora__ZInvoice__c WHERE Id  in : setZuoraIds');
            
            
            for(Zuora__ZInvoice__c z:zInvId)
            {
                setZuoraInvoicesId.add(z.Zuora__Zuora_Id__c);//Collection of Zuora Invoice Ids
            }
            
              if(!setZuoraInvoicesId.isempty())
              {
              strAddSupportData+= '\r\n'+string.valueOf(setZuoraInvoicesId);
            
              strInvoiceIds  = SPPUtils.returnInvoices(setZuoraInvoicesId);//Preparing Dynamic query to add More than One Zuora Invoice IDs in Bulk upload
              strInvoiceIds  = strInvoiceIds.trim().removeEnd('OR');//Removing the end TEXT
            
              //ZOQL query on Invoice Item to fetch subscription,RatePlanIDs,Tax and Other Amount related fields for the invoices
            String invoiceItemzoql = 'Select ServiceEndDate,Id,ChargeDate,AccountingCode,UnitPrice,SubscriptionId,ProcessingType,UOM,Quantity,InvoiceId,ChargeAmount,ServiceStartDate,CreatedById,CreatedDate,TaxAmount,ChargeName,SKU,RatePlanChargeId,TaxCode,TaxExemptAmount,TaxMode,UpdatedById,UpdatedDate from InvoiceItem where ';
            invoiceItemzoql += strInvoiceIds ; //Appending all the Invoice Ids
            
            system.debug('???????????????'+invoiceItemzoql);
            
            strAddSupportData+= '\r\n'+string.valueOf(invoiceItemzoql);
            
            Zuora.zApi zApiInstance = new Zuora.zApi();
            
            
            List<Zuora.zObject> zinvoiceItemsobjs ;   
            if (!Test.isRunningtest())
            {
                zApiInstance.zlogin();
                zinvoiceItemsobjs = zApiInstance.zquery(invoiceItemzoql);
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                Zuora__ZInvoice__c zinvTest = [Select id, Zuora__ZuoraId__c  from Zuora__ZInvoice__c limit 1];
                Zuora.zObject invoice_1 = createZuoraObject('InvoiceItem', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income','ChargeName' => 'test','InvoiceId' => 'testId' });
                Zuora.zObject invoice_2 = createZuoraObject('InvoiceItem', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income','ChargeName' => 'Essentials Business Users','InvoiceId' => zinvTest.Zuora__ZuoraId__c});
                zinvoiceItemsobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
                     }
            
            strAddSupportData+= '\r\n'+string.valueOf(zinvoiceItemsobjs);
            
            Map<String,Zuora.zObject> mapChargeNameInv = new Map<String,Zuora.zObject>();
            
            System.debug('zobjs' +zinvoiceItemsobjs);
            
            for (Zuora.zObject objInvLineItems : zinvoiceItemsobjs) 
            {
                setZuoraInvoicesLineId.add((String)objInvLineItems.getValue('Id'));
                
                //Map to update Invoice Line Item/Order Detail
                mapChargeNameInv.put((String)objInvLineItems.getValue('InvoiceId')+(String)objInvLineItems.getValue('ChargeName'),objInvLineItems);
                
                system.debug('INVOICE'+(String)objInvLineItems.getValue('InvoiceId'));
                
                system.debug('INVOICE ITEM'+(String)objInvLineItems.getValue('Id'));
            }       
            
            strInvoiceitemsIds  = SPPUtils.returnInvoiceLineIds(setZuoraInvoicesLineId);//Preparing Dynamic query to add More than One Zuora Invoice Line Adj IDs in Bulk upload
            strInvoiceitemsIds = strInvoiceitemsIds.trim().removeEnd('OR');//Removing the end TEXT
            
            //ZOQL to get InvoiceItemAdjustment details
            String strInvoiceLineItem = 'SELECT TransferredToAccounting,Status,SourceType,SourceId,Type,InvoiceNumber,InvoiceId,Id,Amount from InvoiceItemAdjustment where ';
            strInvoiceLineItem +=  strInvoiceitemsIds; //Appending all the Invoice Items Ids
            //strInvoiceLineItem +=  ' and TransferredToAccounting= \'Yes\'';
            
            strAddSupportData+= '\r\n'+string.valueOf(strInvoiceLineItem);
            
            List<Zuora.zObject> zinvoiceLineItemsobjs ; 
            
            if (!Test.isRunningtest())
            {
                
                zinvoiceLineItemsobjs = zApiInstance.zquery(strInvoiceLineItem);
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                Zuora.zObject invoice_1 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income' });
                Zuora.zObject invoice_2 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income'});
                zinvoiceLineItemsobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
                    }   
            
            
            strAddSupportData+= '\r\n'+string.valueOf(zinvoiceLineItemsobjs);
            
            System.debug('zobjs' +zinvoiceLineItemsobjs);
            
            
            //Creating a Map of Invoice Item and Invoice Item Adjusment 
            // One Invoice Item can have Multiple Inovie Item Adjusments    
            for (Zuora.zObject objInvAdjItems : zinvoiceLineItemsobjs) 
            {
                
                if(InvItemsMap.containskey((String)objInvAdjItems.getValue('SourceId')))
                {
                    set<Zuora.zObject> tempInvAdjItemsSet=InvItemsMap.get((String)objInvAdjItems.getValue('SourceId'));
                    tempInvAdjItemsSet.add(objInvAdjItems);
                    InvItemsMap.remove((String)objInvAdjItems.getValue('SourceId'));
                    InvItemsMap.put((String)objInvAdjItems.getValue('SourceId'),tempInvAdjItemsSet);
                }
                else
                {
                    set<Zuora.zObject> lstTempInvAdjItems = new set<Zuora.zObject>();
                    lstTempInvAdjItems.add(objInvAdjItems);
                    InvItemsMap.put((String)objInvAdjItems.getValue('SourceId'),lstTempInvAdjItems);
                }
            }
            
            strCreditBalInvIds = SPPUtils.returnInvoiceCrediBalIds(setZuoraInvoicesId);//Preparing Dynamic query to add More than One invoice IDs in Bulk upload
            strCreditBalInvIds = strCreditBalInvIds.trim().removeEnd('OR');//Removing the end TEXT
            
            //ZOQL to get CreditBalanceAdjustment details
            String strInvCredAdj = 'SELECT Amount,Id,SourceTransactionId,SourceTransactionType,Status,TransferredToAccounting,Type from CreditBalanceAdjustment WHERE ';
            strInvCredAdj +=  strCreditBalInvIds; //Appending all the Invoice Ids
            //strInvCredAdj +=  ' and TransferredToAccounting= \'Yes\'';
            
            // One Invoice can have multiple Credit Balance Adj.
            Map<string,set<Zuora.zObject>> InvCreditBalMap = new Map<string,set<Zuora.zObject>>();
            
            strAddSupportData+= '\r\n'+string.valueOf(strInvCredAdj);
            
            List<Zuora.zObject> zinvoiceCreditBalobjs;   
            
            if (!Test.isRunningtest())
            {
                
                zinvoiceCreditBalobjs = zApiInstance.zquery(strInvCredAdj);
            }
            /////////////////Added for Test Class//////////////////
            else
            {
                Zuora.zObject invoice_1 = createZuoraObject('CreditBalanceAdjustment', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income' });
                Zuora.zObject invoice_2 = createZuoraObject('CreditBalanceAdjustment', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income'});
                zinvoiceCreditBalobjs = new List<Zuora.zObject> { invoice_1, invoice_2 }; 
                    } 
            
            strAddSupportData+= '\r\n'+string.valueOf(zinvoiceCreditBalobjs);
            
            System.debug('zinvoiceCreditBalobjs' +zinvoiceCreditBalobjs);
            
            for (Zuora.zObject objInvCredAdjItems : zinvoiceCreditBalobjs) 
            {
                
                //SourceTransactionId = Zuora Invoice Id
                if(InvCreditBalMap.containskey((String)objInvCredAdjItems.getValue('SourceTransactionId')))
                {
                    set<Zuora.zObject> tempInvCreditBalItemsSet=InvCreditBalMap.get((String)objInvCredAdjItems.getValue('SourceTransactionId'));
                    tempInvCreditBalItemsSet.add(objInvCredAdjItems);
                    InvCreditBalMap.remove((String)objInvCredAdjItems.getValue('SourceTransactionId'));
                    InvCreditBalMap.put((String)objInvCredAdjItems.getValue('SourceTransactionId'),tempInvCreditBalItemsSet);
                }
                else
                {
                    set<Zuora.zObject> lstTempInvCreditBalItems = new set<Zuora.zObject>();
                    lstTempInvCreditBalItems.add(objInvCredAdjItems);
                    InvCreditBalMap.put((String)objInvCredAdjItems.getValue('SourceTransactionId'),lstTempInvCreditBalItems);
                }
            }
            
            
            List<SPP_RR_Invoice__c> lstSPPRRInvoice = [Select Id,Credit_Balance__c,Zuora_Invoice__r.Zuora__Zuora_Id__c from SPP_RR_Invoice__c where Zuora_Invoice__r.Zuora__Zuora_Id__c in: setZuoraInvoicesId];
            
            strAddSupportData+= '\r\n'+string.valueOf(lstSPPRRInvoice);
            
            for(SPP_RR_Invoice__c objSPPInv :lstSPPRRInvoice)
            {
                Set<Zuora.zObject> SetobjInvCreditBalObj= InvCreditBalMap.get(objSPPInv.Zuora_Invoice__r.Zuora__Zuora_Id__c);
                
                Decimal TotalCreditBalAdj = 0.0;
                if(null != SetobjInvCreditBalObj)
                {
                    for(Zuora.zObject objInvCreditBalObj: SetobjInvCreditBalObj)
                    {
                        TotalCreditBalAdj += (Decimal)objInvCreditBalObj.getValue('Amount');
                    }
                }  
                
                objSPPInv.Credit_Balance__c=TotalCreditBalAdj ;
            }
            
            update lstSPPRRInvoice;// Updating Credit Balance Adjustment on Invoice
            
            List<SPP_RR_Order_Detail__c> lstSPPRROrderDetail = [Select Id,Quote_Charge_Name__c,Invoice_Line_Adjustment__c,Invoice__r.Zuora_Invoice__r.Zuora__Zuora_Id__c from SPP_RR_Order_Detail__c where Invoice__r.Zuora_Invoice__r.Zuora__Zuora_Id__c in: setZuoraInvoicesId];
            
            strAddSupportData+= '\r\n'+string.valueOf(lstSPPRROrderDetail);
            
            system.debug('>>>>>>>>'+lstSPPRROrderDetail.size());
            system.debug('>>>>>>>>'+InvItemsMap);
            for(SPP_RR_Order_Detail__c objSPPorderDetail : lstSPPRROrderDetail)
            {
                
                system.debug('>>>>>>>>'+objSPPorderDetail.Invoice__r.Zuora_Invoice__r.Zuora__Zuora_Id__c);
                system.debug('>>>>>>>>'+objSPPorderDetail.Quote_Charge_Name__c);
                System.debug('>>>>>>>>'+objSPPorderDetail.Invoice__r.Zuora_Invoice__r.Zuora__Zuora_Id__c+objSPPorderDetail.Quote_Charge_Name__c);
                Zuora.zObject objInvItems =  mapChargeNameInv.get(objSPPorderDetail.Invoice__r.Zuora_Invoice__r.Zuora__Zuora_Id__c+objSPPorderDetail.Quote_Charge_Name__c);//InvAndInvItemMap.get(objSPPorderDetail.Invoice__r.Zuora_Invoice__r.Zuora__Zuora_Id__c);
                
                system.debug('>>>>>>>>'+objInvItems );
                Set<Zuora.zObject> objInvItemAdjusment;
                if(!test.isRunningTest())
                {
                    objInvItemAdjusment = InvItemsMap.get((String)objInvItems.getValue('Id'));
                }else
                {
                    Zuora.zObject invoice_1 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a3b4bd64537', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income' ,'SourceType' => 'InvoiceDetail' , 'Amount' => 10});
                    Zuora.zObject invoice_2 = createZuoraObject('InvoiceItemAdjustment', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'AccountingCode'=>'US Deferred Income','SourceType' => 'Tax' , 'Amount' => 10});
                    objInvItemAdjusment = new set<Zuora.zObject> { invoice_1, invoice_2 }; 
                        }
                system.debug('>>>>>>>>'+objInvItemAdjusment );
                
                system.debug('>>>>>>>>'+InvItemsMap);
                
                if(objInvItemAdjusment != null)
                {
                    
                    Decimal TotalInVAdj = 0.0;
                    Decimal TotalInVAdjTax = 0.0;
                    if(null != objInvItemAdjusment)
                    {
                        for(Zuora.zObject objItemInv: objInvItemAdjusment)
                        {
                            if((String)objItemInv.getValue('SourceType') == 'InvoiceDetail')
                            {
                                TotalInVAdj += (Decimal)objItemInv.getValue('Amount');
                            }
                            else if((String)objItemInv.getValue('SourceType') == 'Tax')
                            {
                                TotalInVAdjTax += (Decimal)objItemInv.getValue('Amount');
                            }
                            
                        }
                        objSPPorderDetail.Invoice_Line_Adjustment__c = TotalInVAdj ;
                        objSPPorderDetail.Invoice_Line_Adj_tax__c = TotalInVAdjTax;
                        
                    }
                }
            }
            
            update lstSPPRROrderDetail;//Updating Order detail

           }           
        }
        catch(Exception e)
        {     
            System.debug('error :'+e.getMessage());
            ExceptionHandler.CatchException('SPPUpdateZuoraInvoicesDetails', 'ZuoraCalloutAsync', e,strAddSupportData);
        }
        
    }
    
    //////////////////Added for test class////////////////////////
    public static Zuora.zObject createZuoraObject(String objName, String id, Map<String, Object> fieldValueByNameMap) 
    {
        Zuora.zObject obj;
        try 
        {
            obj = new Zuora.zObject(objName);
        }
        catch(Exception e)
        {
            System.debug('e1'+e.getMessage());
            ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','createZuoraObject',e);
        }
        
        try 
        {
            if (id != null && id != '') 
            {
                for (String field : fieldValueByNameMap.keySet()) 
                {
                    obj.setValue(field, fieldValueByNameMap.get(field));
                }
            }
        } 
        catch(Exception e)
        {
            System.debug('e2'+e.getMessage());
            ExceptionHandler.CatchException('ZuoraUpdateInvoiceBatch','createZuoraObject',e);
        }
        
        return obj;
        
    }   
}