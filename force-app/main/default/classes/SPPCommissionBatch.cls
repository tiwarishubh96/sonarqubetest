/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:    This Batch is used to create Account Payable Invoices quarterly for all the paid Invoices/Completed Orders by their
                    Partner Referring Accounts
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
global class SPPCommissionBatch implements Database.Batchable<sobject> ,Database.Stateful,Database.AllowsCallouts
{
    global String query{get;set;}
    global List<SPP_RR_Order__c> commissionPayableList{get;set;} 
    global List<SPP_Commission_Invoice__c> commissionInvList{get;set;}
    global Map<Id,SPP_Commission_Invoice__c> mapCommPartnerAcc= new Map<Id,SPP_Commission_Invoice__c>();
    global Map<string,set<SPP_RR_Order__c>> mapSPPRROrder = new Map<string,set<SPP_RR_Order__c>>();
    global Map<String, Double> CurrencyRates  =  new Map <String, Double>();
    global Map<String,Decimal> mapPartnerVat = new Map<String,Decimal>();
    
    global Map<String, Decimal> mapCodeRate = new Map<String, Decimal>();
         
    global SppCommissionBatch(String q) 
    { 
        this.query = q;
        commissionPayableList = new List<SPP_RR_Order__c>();
        commissionInvList = new List<SPP_Commission_Invoice__c>(); 
        
    }
    
    global Database.Querylocator start (Database.BatchableContext BC) 
    {
        //query to fetch Completely Paid Invoices/orders
        //query='Select Commission_Payable__c,Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,Id,Opportunity__r.Referring_Partner_Account__r.BillingPostalCode from SPP_RR_Order__c where Invoiced__c = false and SPP_AP_Commission__c=null and Commission_Payable__c > 0'; //and Opportunity__r.Referring_Partner_Account__c =\'0017E00000XLQ23\'';
       
        system.debug('Start query:'+this.query);
        //System.debug('Query String'+ query);
        
        //This solution creates a map of currency and exchanges rates in the memory and uses it for every conversion.
        // The convertCurrency method can be used in for currency conversions.
          
      	mapCodeRate = SPPUtils.mapCountryCodeAndRate();
        
        System.debug('mapCodeRate::'+mapCodeRate);
       
        return Database.getQueryLocator(query);  
    }
    
    //Execute method- To insert SPP Commission Invoices
    global void execute (Database.BatchableContext BC, List<SPP_RR_Order__c> scope) 
    {
        
        System.debug('Scope execute:'+ scope);
        try
        {
        for(SPP_RR_Order__c spp :scope)//Iterating Over Orders records
        {
             //Creating a Map of Partner Referring Account and List of Orders
            if(mapSPPRROrder.containskey(spp.Opportunity__r.Referring_Partner_Account__c))
            {
                set<SPP_RR_Order__c> tempPartnerAccOppSet=mapSPPRROrder.get(spp.Opportunity__r.Referring_Partner_Account__c);
                tempPartnerAccOppSet.add(spp);
                mapSPPRROrder.remove(spp.Opportunity__r.Referring_Partner_Account__c);
                mapSPPRROrder.put(spp.Opportunity__r.Referring_Partner_Account__c,tempPartnerAccOppSet);
            }
            else
            {
                set<SPP_RR_Order__c> lstTempPartnerAccOpp = new set<SPP_RR_Order__c>();
                lstTempPartnerAccOpp.add(spp);
                mapSPPRROrder.put(spp.Opportunity__r.Referring_Partner_Account__c,lstTempPartnerAccOpp);
            }
        }
        
        
            System.debug('mapSPPRROrder:'+ mapSPPRROrder);
        
            Set<Id> setAccountId = new Set<Id>();
        
            for(SPP_RR_Order__c sppRROrder : scope)
            {
               string strPartnerAcc = sppRROrder.Opportunity__r.Referring_Partner_Account__r.ParentId != null ?
               sppRROrder.Opportunity__r.Referring_Partner_Account__r.ParentId :sppRROrder.Opportunity__r.Referring_Partner_Account__c;
                           
               System.debug('strPartnerAcc:'+ strPartnerAcc);
                   
               if(!setAccountId.Contains(strPartnerAcc))
               {   
                   //List of Commission Invoice records with Partner Account Details
                   commissionInvList.add(new SPP_Commission_Invoice__c(Partner_Account__c=strPartnerAcc,CurrencyISOCode=sppRROrder.CurrencyISOCode));
                   
                   setAccountId.add(strPartnerAcc);
                   
                    if(sppRROrder.Opportunity__r.Referring_Partner_Account__r.Locale__r.Country_Code__c != null)
                        {
                            //Callout to Avalara to get the VAT% by Partner Locale
                            mapPartnerVat.put(sppRROrder.Opportunity__r.Referring_Partner_Account__r.Locale__r.Country_Code__c,
                                            CalloutToAvalaraForVAT(sppRROrder.Opportunity__r.Referring_Partner_Account__r.Locale__r.Country_Code__c,sppRROrder.Opportunity__r.Referring_Partner_Account__r.BillingPostalCode));
                        }
                   
               }
            }
        
            system.debug('??????????'+mapPartnerVat);
            
        //Inserting SPP Commission Records
        insert commissionInvList;
        
        System.debug('commissionInvList:'+ commissionInvList);
        
        //Iterating over Comission Records and Creating a Map of Account and Commission Record
        for(SPP_Commission_Invoice__c sppComm : commissionInvList)
        {
          mapCommPartnerAcc.put(sppComm.Partner_Account__c,sppComm);
        }
        
        System.debug('mapCommPartnerAcc:'+ mapCommPartnerAcc);
        
        for(String strAccID : mapSPPRROrder.Keyset())
        {    
            //Get the Order List based on the Partner Account
             set<SPP_RR_Order__c> setRROrder = mapSPPRROrder.get(strAccID);
             
             for(SPP_RR_Order__c sppObj : setRROrder)
             {
                  
                  //Check to see if the Account has a Parent Account
                  System.debug('mapCommPartnerAcc:'+ sppObj.Opportunity__r.Referring_Partner_Account__c);
                  string strPartnerAcc = sppObj.Opportunity__r.Referring_Partner_Account__r.ParentId != null ?
                  sppObj.Opportunity__r.Referring_Partner_Account__r.ParentId :sppObj.Opportunity__r.Referring_Partner_Account__c;
                   
                   System.debug('strPartnerAcc:'+ strPartnerAcc);
                  
                 if(mapCommPartnerAcc.ContainsKey(strPartnerAcc))
                 { 
                   //Set AP commission record ID in Order and Update the same
                   commissionPayableList.add(new SPP_RR_Order__c(Id=sppObj.Id,SPP_AP_Commission__c =
                   mapCommPartnerAcc.get(strPartnerAcc).Id,Invoiced__c=true));
                 }
                 
             }
        }
        
        System.debug('Final Scope execute:'+ scope);
        
        update commissionPayableList;
        
         List<SPP_Commission_Invoice__c> lstAPbyComm = new List<SPP_Commission_Invoice__c>();
            
                
                AggregateResult[] aggCommByAP = [SELECT  SUM(Commission_Amount__c) commAmt ,SPP_AP_Commission__c,CurrencyIsoCode FROM SPP_RR_Order__c 
                where SPP_AP_Commission__c != null and SPP_AP_Commission__c  in: commissionInvList  GROUP BY SPP_AP_Commission__c,CurrencyIsoCode];
                
                 Map<Id,SPP_Commission_Invoice__c> APcommMap = new Map<Id,SPP_Commission_Invoice__c>([Select Id,Name,Partner_Account__r.Locale__r.VAT__c,Partner_Account__r.Locale__r.Country_Code__c,
                                                                                                      Partner_Account__r.Locale__r.CurrencyISOCode
                                                                from SPP_Commission_Invoice__c
                                                                where Id in:commissionInvList]);
               
                system.debug('aggCommByAP::'+aggCommByAP);
            
                for (AggregateResult ar : aggCommByAP) 
                {
                    system.debug('AP COMISSION'+(Id)ar.get('SPP_AP_Commission__c') +'COMMISION AMT'+(Decimal)ar.get('commAmt'));
                    
                    //get the conversion rate from my company default currency by querying the currencytype object
                    // to get the correct amount, I have to multiply the aggregated sum by the conversion rate to the quotation currency
                    Double CurrencyRate  = mapCodeRate.get((String)ar.get('CurrencyIsoCode'));
                    //
                    
                    system.debug('>>>>'+APcommMap.get((Id)ar.get('SPP_AP_Commission__c')).Partner_Account__r.Locale__r.CurrencyIsoCode);
                    
                    //Double CurrencyRate  = mapCodeRate.get(APcommMap.get((Id)ar.get('SPP_AP_Commission__c')).Partner_Account__r.Locale__r.CurrencyIsoCode);
                    
                    system.debug('>>>>>>>>>'+CurrencyRate);
                    
                    system.debug('>>>>ar.get(SPP_AP_Commission__c)>>>>'+ar.get('SPP_AP_Commission__c'));
                    
                    system.debug('>>>>ar.get(commAmt)*CurrencyRate>>>>'+(Decimal)ar.get('commAmt')*CurrencyRate);
                    
                    //system.debug('>>>>mapPartnerVat.get(APcommMap.get((Id)ar.get(SPP_AP_Commission__c)).Partner_Account__r.Locale__r.Country_Code__c>>>>'+mapPartnerVat.get(APcommMap.get((Id)ar.get('SPP_AP_Commission__c'))).Partner_Account__r.Locale__r.Country_Code__c);
                              
                    lstAPbyComm.add((new SPP_Commission_Invoice__c(Id=(Id)ar.get('SPP_AP_Commission__c'),
                    AP_Comission__c=(Decimal)ar.get('commAmt')*CurrencyRate,VAT__c=mapPartnerVat.get(APcommMap.get((Id)ar.get('SPP_AP_Commission__c')).Partner_Account__r.Locale__r.Country_Code__c)*100)));
                    
                    System.debug('lstAPbyComm::'+lstAPbyComm);
                    //AP_Comission__c=(Decimal)ar.get('commAmt')*CurrencyRate,VAT__c=APcommMap.get((Id)ar.get('SPP_AP_Commission__c')).Partner_Account__r.Locale__r.VAT__c)));
                }
                update lstAPbyComm;
                
          system.debug('>>>>>'+Limits.getQueueableJobs());
          system.debug('>>>>>'+Limits.getLimitQueueableJobs());
          
          if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())// Checking the limit for Queueable 
          {
           // Passing the payload to a Queueable interface class to create PDF
           // When you pass the ID to the PDF controller directly after the insert from the same controller method the record is not available. 
           //hence, we get visualforce exception : Unable to retrieve object
           //It's an error with sf it seems.this issue already raised as an IDEA
           System.enqueueJob(new SPPAPCommissionPDFQueueableController(new List<SPP_Commission_Invoice__c>(commissionInvList)));
          }
         
       
        }
          catch(Exception e) 
          {     
            ExceptionHandler.CatchException('SppCommissionBatch', 'Execute Method', e);
          }
        }
    //Making calls to Avalara to get the tax
    public Decimal CalloutToAvalaraForVAT(string strPartnerCountryCode, string strPartnerZipCode)
    {
          
        system.debug('strPartnerZipCode>>>'+strPartnerZipCode);
        
        String companyCode = Label.CompanyCodeForAvalara;//'SGSUS';
        
        String customerCode = Label.CustomerCodeForAvalara;//'Sage';
        
        TetrisTaxModel tax = new TetrisTaxModel();
        
        ITetrisCustomMetadataTypeDAO avaConfigMetadata = TetrisDAOFactory.getCustomMetadataTypeDAO();
        
        String configResourceName = avaConfigMetadata.getAvalaraBaseEndpoint();
        
        try{
            
            Callout_Configuration__mdt avalaraConfig = TetrisCustomMetadataTypeDAO.getResourceInfo(configResourceName);
                    
            System.debug('avalaraConfig.Endpoint_URL__c ' + avalaraConfig.Endpoint_URL__c);
            System.debug('avalaraConfig.Username__c ' + avalaraConfig.Username__c);
            System.debug('avalaraConfig.Password__c ' + avalaraConfig.Password__c);
                        
            tax = TetrisTaxUtil.calculateTax(avalaraConfig.Endpoint_URL__c,
            		avalaraConfig.Username__c, avalaraConfig.Password__c, companyCode, customerCode, 
                    strPartnerCountryCode,0.00,strPartnerZipCode,strPartnerCountryCode);
                        
            System.debug('Tax response ' + tax +'Tax taxAmount ' + tax.taxAmount+
            'Tax totalTaxable ' + tax.taxableAmount+'Tax rate ' + tax.taxrate+'Tax country ' + tax.country);
            
        }catch(Exception e){
            
            ExceptionHandler.CatchException('SPPCommissionBatch','CalloutToAvalaraForVAT',e);
        }
        
        
     	return tax.taxrate;   
    }
    
    //Finish Method
    
    global void finish(Database.BatchableContext BC)
    {
         // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
        /*
         AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email, ExtendedStatus
          from AsyncApexJob where Id = :BC.getJobId()];
          
         // Email the Batch Job's submitter that the Job is finished.
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {a.CreatedBy.Email};
         mail.setToAddresses(toAddresses);
         mail.setSubject('SppCommission Batch Status: ' + a.Status);
         mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
          ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);
           
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         */
        
    } 
    
}