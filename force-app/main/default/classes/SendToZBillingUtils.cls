/**
* This Class provides access to SendToZBilling Method from the Zuora
* Package, generates the Invoice number in salesforce, then calls the UpdateInvoiceStatusQueued to
* update the obligatory fields on Zuora invoice and send the regional invoice number over to Zuora
*/
global class SendToZBillingUtils
{
    /**
* [callZQuoteGlobal performs various checks and collects various reference data and if successful calls the Zuora sendToZBilling method
*  which will create/update the account and subscription in zuora based on the information in the quote
*  If the sendToZBilling call is successful and an invoice has been generated then it calls the UpdateInvoiceStatusQueued queue to insert
*  the regional invoice number into the invoice before re-generating it and posting it so that it is emailed to the customer.
*  If the sendToZBilling call is successful and an invoice has not been generated then it calls the enableAccCommProfileAndBatch2 to update
*  the account settings in zuora so that it is ready for when the invoice is created in the future (on the date that the service starts)]
* @param quoteId [SFDC quote id]
* @return [return status message of the send to z-billing process: "Send to Z-Billing was successful" if the operation succeeded
*                  else "Send to Z-Billing was unsuccessful:" + the error message]
*/
    webservice static String callZQuoteGlobal(String quoteId, String clientCode){
        Date subscriptionTermEndDate;
        Boolean generateInvoice;
        String invoiceTemplateId;
        String communicationProfileId;
        String defaultPaymentMethodId;
        String defaultPaymentMethodType;
        String defaultPaymentGateway;
        zqu__quote__c zQuote;
        List<zqu__QuoteRatePlanCharge__c> zQuoteRatePlanCharges;
        List<zqu__QuoteCharge__c> zQuoteCharge;
        Set<ID> ratePlanIds = new Set<ID>();
        Boolean isTranslatedProductName = true;
        Boolean isAmend = false;
        /*Boolean isBundle = false;
        Boolean isAccountingGb  = false;
        Boolean isPayrollGb =  false;*/
        
        try {
            zQuote = [SELECT zqu__Status__c,zqu__Currency__c,zqu__Account__r.Sales_Office__c,zqu__Account__r.VAT_Number__c,
                      zqu__Account__r.TaxExemptStatus__c,zqu__SubscriptionTermStartDate__c,zqu__ExistSubscriptionID__c,zqu__SubscriptionType__c, zqu__Account__c,
                      zqu__Account__r.BillingCountryCode,zqu__CancellationDate__c,zqu__Previewed_SubTotal__c,
                      zqu__Previewed_Total__c, zqu__StartDate__c,zqu__TermStartDate__c,zqu__SubscriptionTermEndDate__c,
                      Id, zqu__ZuoraAccountID__c,zqu__ElectronicPaymentMethodId__c,zqu__PaymentMethod__c,
                      zqu__Previewed_Delta_TCV__c,zqu__Previewed_Delta_MRR__c,
                      zqu__Account__r.locale__r.language__c, RecordType.Name, zqu__quote__c.Customer_Initiated_Payment__c, zqu__Subscription_Name__c, External_Application__c
                      FROM zqu__quote__c
                      WHERE Id =: quoteId LIMIT 1];
            
            /*for tretris CPQ Sales Process*/
            system.debug('zQuote.External_Application__c: ' + zQuote.External_Application__c);
            
            
        } catch (Exception e){
            ExceptionHandler.CatchException('SendToZBillingUtils', 'callZQuoteGlobal', e);
            return ('DML Exception:'+ e);
        }
        if(zQuote.zqu__Status__c == 'Sent to Z-Billing'){
            
            return message(Label.lbl_Already_Sent_to_Z_Billing);
        }
        
        //  2017/12/12 bphan EAD-271:  ZA quotes, can’t send to ZBilling.
        String strCountries = Label.lbl_Locale_No_ZBilling;
        String strCountryCode = zquote.zqu__Account__r.BillingCountryCode;


        //Re-inforces the Sales Office in the account. Quote cannot be sent without it.
        if(String.isBlank(zQuote.zqu__Account__r.Sales_Office__c)) {
            //TODO Label!
            return message('Sales Office cannot be empty. Please contact your System Administrator with this message.');
        }
        System.debug('Sales Office: ' +zQuote.zqu__Account__r.Sales_Office__c);
        String tradingEntity = getTradingEntityBySaleOffice(zQuote.zqu__Account__r.Sales_Office__c);
        System.debug('Ttrading Entity: ' +tradingEntity);

        if (!(strCountries.contains(strCountryCode))){
            return message('Z-Billing not support for country: ' + strCountryCode + '\n' + 'Supported countries: ' + strCountries + '\n' + 'Please send quote to local Sales Ops.');
        }
        
        zqu.zQuoteUtil.ZBillingQuoteCollection quoteCollection = new zqu.zQuoteUtil.ZBillingQuoteCollection(); //zqu.zQuoteUtil.sendToZBilling method parameter
        
        // SFDC CRM Account ID
        quoteCollection.sfdcAccountId = zQuote.zqu__Account__c;
        quoteCollection.zAccountId = 'new'; //if account is not new this value will be overwritted
        
        // Check to see if the Electronic Payment Method Id on the Quote is populated
        // If not read the Default Payment Method Id and Payment Method Type from the Billing Account
        System.debug('zquote.zqu__ElectronicPaymentMethodId__c: ' + zquote.zqu__ElectronicPaymentMethodId__c);
        if(zquote.zqu__ElectronicPaymentMethodId__c == null){
            if(zQuote.zqu__ZuoraAccountID__c != null && zQuote.zqu__ZuoraAccountID__c.trim() != ''){
                List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Zuora__PaymentMethod_Type__c FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c =: zQuote.zqu__ZuoraAccountID__c ];
                if(billingAccounts.size() == 0) return message('Billing account not found'); //this error should never happen
                if(billingAccounts.size() > 1) return message('More than one billing account found'); //this error should never happen
                if(billingAccounts.get(0).Zuora__Default_Payment_Method__c == null && zquote.RecordType.Name == 'Default'){
                    return message(Label.lbl_No_Electronic_Payment_Method);
                } else {
                    defaultPaymentMethodId = billingAccounts.get(0).Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
                    defaultPaymentMethodType = billingAccounts.get(0).Zuora__PaymentMethod_Type__c;
                }
            } else {
                return message(Label.lbl_No_Electronic_Payment_Method);
            }
        } else {
            // Set the Default Payment Method Id to the Electronic Payment Method Id from the Quote
            // and set the Default Payment Method Type to the Payment Method from the Quote
            defaultPaymentMethodId = zquote.zqu__ElectronicPaymentMethodId__c;
            defaultPaymentMethodType = zquote.zqu__PaymentMethod__c;
            //Inn case of BACS
            if(String.isBlank(defaultPaymentMethodType) && zQuote.Customer_Initiated_Payment__c == true) {
                defaultPaymentMethodType = 'Bank Transfer';
            }
            System.debug('defaultPaymentMethodType: ' +defaultPaymentMethodType);
            
        }
        
        // Determine whether the service will be starting today or in the future
        // Only generate an invoice if the service will be starting today
        
        Date quoteEffectiveStartDate = zquote.zqu__SubscriptionTermStartDate__c != null ? zquote.zqu__SubscriptionTermStartDate__c : (zquote.zqu__TermStartDate__c != null ? zquote.zqu__TermStartDate__c : zquote.zqu__StartDate__c);
            // mikem investigating if it should be this: Date quoteEffectiveStartDate = zquote.zqu__StartDate__c;
            
            // Zuora is using PDT time zone, so we have to compare quoteEffectiveStartDate against current date/time in PDT time zone.
            //** Not used anymore due to "generateInvoice = false"
            //String pdtDateNowString = DateTime.now().format('yyyy-MM-dd', 'America/Los_Angeles');
            //Date pdtNowDate = Date.valueOf(pdtDateNowString);
            
            //** A temp fix to resolve "Issue with Tax on Sage One and compromise req'd from biz EC-419 & EC-420" on 2017-01-19
            //** Will have impact on SendToZBilling via Salesforce Quote UI, i.e. Sage One manual upgrade/downgrade or Sage Live
            //generateInvoice = quoteEffectiveStartDate > pdtNowDate ? false : true;
            generateInvoice = false;
        System.debug('generateInvoice: ' + generateInvoice);
        
        // For an Amendment Quote check that the amendment and service start date will not result in a negative invoice
        // For a Cancelation Quote check that the service is being cancelled at the end of the term
        if(zQuote.zqu__ZuoraAccountID__c != null && zQuote.zqu__ZuoraAccountID__c.trim() != ''){
            if(zQuote.zqu__SubscriptionType__c == 'Amend Subscription'){
                if(zQuote.zqu__Previewed_SubTotal__c < 0 || zQuote.zqu__Previewed_Total__c < 0 || (zQuote.zqu__Previewed_Total__c == 0 && (zQuote.zqu__Previewed_Delta_TCV__c < 0 || zQuote.zqu__Previewed_Delta_MRR__c < 0))){
                    if(zQuote.zqu__StartDate__c >= subscriptionTermEndDate){
                        
                        return message(Label.lbl_AMD_Date_err);
                    } else{
                        return message(Label.lbl_amd_Quote_Total_Amount_Err);
                    }
                }
                // Santiago Colman, 5/23: This condition was modified following a suggestion made by mike.martin@sage.com, to resolve task #47195
                // I'm leaving the previous condition commented out, just in case
                // } else if(zQuote.zqu__SubscriptionType__c == 'Cancel Subscription' && subscriptionTermEndDate != Date.today()){
            } else if(zQuote.zqu__SubscriptionType__c == 'Cancel Subscription' && (zQuote.zqu__Previewed_SubTotal__c < 0 || zQuote.zqu__Previewed_Total__c < 0 || (zQuote.zqu__Previewed_Total__c == 0))){
                return message(Label.lbl_CNCL_Subscription_Date_Err);
            }
            
            quoteCollection.zAccountId = zquote.zqu__ZuoraAccountID__c;
            
            // For an existing Zuora Account we need to set the Comm Profile to Inactive and the Batch to Batch 1
            // This is because the Zuora SendToZBilling call will create a "Posted" invoice (if generating and invoice)
            // and this would be immediately emailed to the customer if we don't set the Comm Profile to Inactive
            // We don't want this to happen immediately because we need to insert the regional invoice number first.
            // Similarly we set the Batch to Batch 1 so that the invoice isn't picked up by the Zuora overnight payment run
            // before we have inserted the regional invoice number. (You can't unpost an invoice which has an associated payment.)
            
            if(generateInvoice && !disableAccCommProfileAndBatch1(zQuote.zqu__ZuoraAccountID__c))
            {
                
                return message(Label.lbl_Comm_Profile_Batch_1_Failed);
            }
        }
        
        // Retrieve the appropriate invoice template Id and communication profile Id and default payment gateway
        //Added additional language conditions for multi-lingual support 2016-07-17 Docmation
        //Added platform to pick Non Tetris Related Templates, The Tetris Related templates are populated with Platform As 'Tetris'
        
        String countryCode = zquote.zqu__Account__r.BillingCountryCode;
        String language = zquote.zqu__Account__r.locale__r.language__c;
        
        //We use the CBC to clientCode to get the Payment Pages from/for CBC to Tetris CPQ, so we can reuse them.
        String client_Code = clientCode == null?'CBC':clientCode;
        String platform;

         //Identifies the application this quote belongs to, e.g.: Tetris, thru the Salesforce/Zuora CPQ
         if(string.isNotBlank(zQuote.External_Application__c)) { 
                platform = zQuote.External_Application__c;
         }
        
        List<zqu__InvoiceTemplate__c> templates;
        //get's the templates based on the platform
        if(String.isNotBlank(platform) && platform.equals(Global_Constants.TETRIS)) {
            templates = (List<zqu__InvoiceTemplate__c>)Database.query('SELECT zqu__ZuoraId__c FROM zqu__InvoiceTemplate__c WHERE Country_Code__c = \'' + countryCode + '\' AND language__c = \'' + language + '\' AND Platform__c = \'' + platform + '\' AND TradingEntity__c = \'' + tradingEntity + '\'');
            
        } else { // Is Not Tetris (check end condition in the SOQL!)
            templates = (List<zqu__InvoiceTemplate__c>)Database.query('SELECT zqu__ZuoraId__c FROM zqu__InvoiceTemplate__c WHERE Country_Code__c = \'' + countryCode + '\' AND language__c = \'' + language + '\' AND Platform__c != \'' + Global_Constants.TETRIS + '\' AND TradingEntity__c = \'' + tradingEntity + '\'');
            
        }
        
        //Validates templates
		if(templates.size() == 0){
            return message(Label.lbl_No_Invoice_Template_Found);
        }
        if(templates.size() > 1){
            return message(Label.lbl_More_Than_One_Invoice_Template_Found);
        }
        List<zqu__CommunicationProfile__c> profiles = (List<zqu__CommunicationProfile__c>)Database.query('SELECT zqu__ZuoraId__c FROM zqu__CommunicationProfile__c WHERE Country_Code__c = \'' + countryCode + '\' AND language__c = \'' + language + '\' AND TradingEntity__c = \'' + tradingEntity + '\'');
        if(profiles.size() == 0){
            return message(Label.lbl_No_Communication_Profile_Found);
        }
        if(profiles.size() > 1){
            return message(Label.lbl_More_Than_One_Comm_Profile_Found);
        }
        System.debug('SELECT Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE Client_Code__c = \'' + client_Code + '\' AND Country_Code__c = \'' + countryCode + '\' AND zqu__paymentMethodType__c = \'' + defaultPaymentMethodType + '\' AND TradingEntity__c = \'' + tradingEntity + '\'');
        List<zqu__HostedPageLiteSetting__c> pageSettings = (List<zqu__HostedPageLiteSetting__c>)Database.query('SELECT Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE Client_Code__c = \'' + client_Code + '\' AND Country_Code__c = \'' + countryCode + '\' AND zqu__paymentMethodType__c = \'' + defaultPaymentMethodType + '\' AND TradingEntity__c = \'' + tradingEntity + '\'');
        if(pageSettings.size() == 0){
            return message(Label.lbl_error_no_payment_page_found);
        }
        if(pageSettings.size() > 1){
            return message(Label.lbl_error_many_payment_page_found);
        }
        if (pageSettings.get(0).Payment_Gateway_Name__c == null){
            return message(Label.lbl_error_payment_page_gateway_is_blank);
        }
        
        invoiceTemplateId = templates.get(0).zqu__ZuoraId__c;
        communicationProfileId = profiles.get(0).zqu__ZuoraId__c;
        defaultPaymentGateway = pageSettings.get(0).Payment_Gateway_Name__c;
        
        quoteCollection.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
        zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
        
        // SFDC Quote ID
        req.sfdcQuoteId = zQuote.Id;
        req.generateInvoice = generateInvoice;
        req.processPayment = false; // Do not process payment as we need to insert the regional invoice number into the invoice first
        
        quoteCollection.quoteRequests.add(req);
        List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteCollectionList = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
        quoteCollectionList.add(quoteCollection);
        
        // Call the SendToZBilling Zuora method
        zqu.ZQuoteUtil.ZBillingResult result = zqu.zQuoteUtil.sendToZBilling(quoteCollectionList).get(0);
        //System.debug( '*************logger = ' + Zuora.zApi.currentLogger.toString() );
        System.debug( '**** SendToZBilling Result: QuoteId = ' + result.sfdcQuoteId + ', Success = ' + result.success + ', message = ' + result.message + ', ZAccountId = ' + result.zAccountId );
        
        
        if(!result.success && !Test.isRunningTest()){
            Map<String, String> errorMessageMap = new Map<String, String>();
            errorMessageMap.put(zQuote.Id, result.message);
            ExceptionHandler.logZuoraRecordProcessingErrors('SendToZBillingUtils', 'callZQuoteGlobal', errorMessageMap);
            return message(Label.lbl_Send_Z_Billing_Failed);
        }
        
        // If Zuora has generated an invoice then calls the UpdateInvoiceStatusQueued queue to insert the regional invoice number into the invoice
        // else call the enableAccCommProfileAndBatch to update the account settings in zuora so that it is ready for when the invoice is created in the future
        if(generateInvoice){
            
            System.debug('enqueuing UpdateInvoiceStatusQueued');
            //Commented by Veni as it never comes to the below as generate Invoice is set to false
            //To get the code coverage, we are commenting the below line
            // System.enqueueJob(new UpdateInvoiceStatusQueued(zQuote.Id, getAutoGeneratedInvoiceId(zQuote.Id), invoiceTemplateId, communicationProfileId, defaultPaymentMethodId, defaultPaymentGateway));
            
        } else if( string.isNotBlank(platform) && platform.equals(Global_Constants.TETRIS)) { //added as a part of the new sales process for Accounting GB
            System.debug('enqueuing EnableAccCommProfile for Tetris - Batch3');
            System.enqueueJob(new EnableAccCommProfileAndBatch2Queued(communicationProfileId, invoiceTemplateId, result.zAccountId == null ? zQuote.zqu__ZuoraAccountID__c : result.zAccountId, zQuote.zqu__Account__r.VAT_Number__c,zQuote.zqu__Account__r.TaxExemptStatus__c,defaultPaymentMethodId, defaultPaymentGateway, zQuote.Customer_Initiated_Payment__c, 'Batch3', tradingEntity,countryCode));
            //Call future method to update subscription details on a bundle scenario
            String strForBundleDescription = '';

            if (zQuote.zqu__SubscriptionType__c == 'New Subscription' || zQuote.zqu__SubscriptionType__c == 'Amend Subscription'){
                List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = [SELECT Id,Name, zqu__QuoteRatePlan__r.Id, zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c,zqu__Quantity__c,zqu__Model__c FROM zqu__QuoteRatePlanCharge__c WHERE Quote__c  =: quoteId];

                System.debug('zSubscriptionId--------' +result.zSubscriptionId);
                System.debug('quoteRatePlanCharges--------' + quoteRatePlanCharges);
                List <QuoteRatePlanChargeHelper> quoteRatePlanChargesInfo = new List<QuoteRatePlanChargeHelper>();

                Set<ID> setProductRatePlanID = new Set<ID>();

               // ID payrollProductRatePlanId;

                for (zqu__QuoteRatePlanCharge__c quoteRatePlanCharge : quoteRatePlanCharges) {
                    QuoteRatePlanChargeHelper quoteRatePlanChargeInfo = new QuoteRatePlanChargeHelper();
                    quoteRatePlanChargeInfo.quoteRatePlanChargeId = quoteRatePlanCharge.Id;
                    quoteRatePlanChargeInfo.productRatePlanID = quoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                    quoteRatePlanChargeInfo.quoteRatePlanChargeQuantity = quoteRatePlanCharge.zqu__Quantity__c;
                    quoteRatePlanChargeInfo.quoteRatePlanChargeModel = quoteRatePlanCharge.zqu__Model__c;

                    setProductRatePlanID.add(quoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c);
                    quoteRatePlanChargesInfo.add(quoteRatePlanChargeInfo);
                }

                BundleHelper quoteRatePlanChargeBundle = new BundleHelper();

                quoteRatePlanChargeBundle = getBundleInfo(setProductRatePlanID);

                /*List<zqu__ProductRatePlan__c> productRatePlans = [SELECT Id,name,APIServiceId__c
                FROM zqu__ProductRatePlan__c
                WHERE Id IN:setProductRatePlanID];

                System.debug('productRatePlans--------' + productRatePlans);

                for (zqu__ProductRatePlan__c addedProductRatePlan : ProductRatePlans) {
                    if (addedProductRatePlan.APIServiceId__c.contains('sage:gb:sageone:payroll:t:rrp:monthly:pct')) {
                        isPayrollGb = true;
                        payrollProductRatePlanId = addedProductRatePlan.Id;
                    }

                    if (addedProductRatePlan.APIServiceId__c.contains('sage:gb:sageone:accounts:t:rrp:monthly:pct')) {
                        isAccountingGb = true;
                    }

                }

                if (isAccountingGb == true && isPayrollGb == true){
                    isBundle = true;
                }
*/
                System.debug('isAccountingGb--------' + quoteRatePlanChargeBundle.isAccountingGb);
                System.debug('isPayrollGb--------' + quoteRatePlanChargeBundle.isPayrollGb);
                System.debug('isBundle--------' + quoteRatePlanChargeBundle.isBundle);
                System.debug('payrollProductRatePlanId--------' + quoteRatePlanChargeBundle.payrollProductRatePlanId);



                if (quoteRatePlanChargeBundle.isBundle==false && zQuote.zqu__SubscriptionType__c == 'Amend Subscription'){ //check if it's an amendment and if it is still a bundle
                    if (setProductRatePlanID.size()>0)
                        setProductRatePlanID.clear();
                    List<zqu__QuoteChargeDetail__c> quoteChargeDetails = [SELECT Id, zqu__ProductRatePlan__c FROM zqu__QuoteChargeDetail__c WHERE zqu__Quote__c  =: quoteId];
                    for (zqu__QuoteChargeDetail__c quoteChargeDetail : quoteChargeDetails) {
                        setProductRatePlanID.add(quoteChargeDetail.zqu__ProductRatePlan__c);
                    }

                    //check if it is a bundle and save on a different variable. if it is bundle and the amended charge is the payroll, then update strForBundleDescription
                    //                    // with new quantity. Otherwise, on the future call don't update the bundle description but leave it as bundle

                    BundleHelper quoteChargeDetailBundle = new BundleHelper();

                    quoteChargeDetailBundle = getBundleInfo(setProductRatePlanID);


                    System.debug('isAccountingGbQs--------' + quoteChargeDetailBundle.isAccountingGb);
                    System.debug('isPayrollGbQs--------' + quoteChargeDetailBundle.isPayrollGb);
                    System.debug('isBundleQs--------' + quoteChargeDetailBundle.isBundle);
                    System.debug('payrollProductRatePlanIdQs--------' + quoteChargeDetailBundle.payrollProductRatePlanId);

                    isAmend = true;

                    //if the quote summary is a bundle and if what's in the quote rate plan charge is payroll we need to make sure the quote is
                    //treated like a bundle when we need to update Zuora
                    if (quoteChargeDetailBundle.isBundle == true && quoteRatePlanChargeBundle.isPayrollGb == true){
                        System.debug('is going to set isBundle to true again--------');
                        quoteRatePlanChargeBundle.isBundle=true;
                    }
                }


                if (quoteRatePlanChargeBundle.isBundle==true){
                    for (integer j = 0; j < quoteRatePlanChargesInfo.size(); j++) {
                        System.debug('quoteRatePlanChargesInfo[j].productRatePlanID--------' + quoteRatePlanChargesInfo[j].productRatePlanID);
                        System.debug('payrollProductRatePlanId--------' + quoteRatePlanChargeBundle.payrollProductRatePlanId);
                        System.debug('quoteRatePlanChargesInfo[j].quoteRatePlanChargeModel--------' + quoteRatePlanChargesInfo[j].quoteRatePlanChargeModel);

                        if (quoteRatePlanChargesInfo[j].productRatePlanID == quoteRatePlanChargeBundle.payrollProductRatePlanId && quoteRatePlanChargesInfo[j].quoteRatePlanChargeModel == 'Volume Pricing'){
                            strForBundleDescription = 'Accounting  Bundle - Accounting and Payroll for ' + String.valueOf(Integer.valueOf(quoteRatePlanChargesInfo[j].quoteRatePlanChargeQuantity)) + ' Employees.';
                        }
                    }


                }

                System.debug('strForBundleDescription--------' + strForBundleDescription);

                updateBundleFields(result.zSubscriptionId,strForBundleDescription,quoteRatePlanChargeBundle.isBundle,isAmend);

            }
        }else {            
            System.debug('enqueuing EnableAccCommProfile');
            //Uncommented by Veni as per the triage with Mike and Mick
            System.enqueueJob(new EnableAccCommProfileAndBatch2Queued(communicationProfileId, invoiceTemplateId, result.zAccountId == null ? zQuote.zqu__ZuoraAccountID__c : result.zAccountId, zQuote.zqu__Account__r.VAT_Number__c,zQuote.zqu__Account__r.TaxExemptStatus__c,defaultPaymentMethodId, defaultPaymentGateway, zQuote.Customer_Initiated_Payment__c, 'Batch2', tradingEntity,countryCode));
        }
        
        return Label.lbl_successful_send;
    }
    
    /**
    * [message creates message from error text, in form which is visible to user. Used only for unsuccessful messages]
    * @param text [Error message text]
    * @return [final message text]
    */
    private static String message(String text){
        
        return Label.lbl_unsuccessful_send + '\n' + text;
    }

    /**
   * [message returns information about product rate plans in quote to understand if there's a bundle inside the quote ]
   * @param Set<ID> [List of Product Rate Plan Ids ]
   * @return [Bundle Helper Class]
   */
    private static BundleHelper getBundleInfo(Set<ID> setProductRatePlanIDparam){


        System.debug('isQuoteBundle');

        BundleHelper bundleHelper = new BundleHelper();

        bundleHelper.isBundle=false;

        List<zqu__ProductRatePlan__c> productRatePlans = [SELECT Id,name,APIServiceId__c
        FROM zqu__ProductRatePlan__c
        WHERE Id IN:setProductRatePlanIDparam];

        System.debug('productRatePlans--------' + productRatePlans);

        for (zqu__ProductRatePlan__c addedProductRatePlan : ProductRatePlans) {
            if (addedProductRatePlan.APIServiceId__c.contains('sage:gb:sageone:payroll:t:rrp:monthly:pct')) {
                bundleHelper.isPayrollGb = true;
                bundleHelper.payrollProductRatePlanId = addedProductRatePlan.Id;
            }

            if (addedProductRatePlan.APIServiceId__c.contains('sage:gb:sageone:accounts:t:rrp:monthly:pct')) {
                bundleHelper.isAccountingGb = true;
            }

        }

        if (bundleHelper.isAccountingGb == true && bundleHelper.isPayrollGb == true){
            bundleHelper.isBundle = true;
        }

        return bundleHelper;
    }
        /**
    * [getAutoGeneratedInvoiceId generates a regional invoice number for the invoice based on the account sales office field]
    * @return [auto generated name by SFDC, this is regional invoice number]
    */
        /*** Commented by Veni as it never comes to the below as generate Invoice is set to false
    To get the code coverage, we are commenting the below line**/
        
        /** private static String getAutoGeneratedInvoiceId(String quoteId){
    try{
    
    zqu__quote__c zQuoteUpdated = [SELECT zqu__InvoiceID__c, zqu__Account__r.Sales_Office__c FROM zqu__quote__c WHERE Id =: quoteId]; //zqu.zQuoteUtil.sendToZBilling populates zqu__InvoiceID__c field on quote, so it has to be query again.
    
    String invoiceObjApi = Zuora_Invoice_Mapping__c.getAll().get(zQuoteUpdated.zqu__Account__r.Sales_Office__c).Invoice_Object__c;
    sObject sObj = Schema.getGlobalDescribe().get(invoiceObjApi).newSObject() ;
    sObj.put('Z_Invoice_Id__c',zQuoteUpdated.zqu__InvoiceID__c);
    insert sObj;
    String invoiceNumber = (String)Database.query('SELECT Name FROM ' + invoiceObjApi + ' WHERE Id=\'' + sObj.Id + '\'').get(0).get('Name');
    return invoiceNumber;
    } catch(Exception e){
    ExceptionHandler.CatchException('SendToZBillingUtils', 'getAutoGeneratedInvoiceId', e);
    System.debug('Error getAutoGeneratedInvoiceId:'+e.getMessage());
    return '';
    },
    } **/
        
        /**
    * [disableAccCommProfileAndBatch1 updates comm profile to 'inactive' and the batch to 'batch1' on the account object in Zuora]
    * @return [true for success, false for fail]
    */
    private static Boolean disableAccCommProfileAndBatch1(string zuoraAccountId){
        if(Test.isRunningTest()) return true; //cannot control zuora calls in test class
        Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('SendToZBillingUtils.disableAccCommProfileAndBatch1'); //loginToZuora parameter is used to track errors
        String inactiveComm = Zuora_Invoice_Mapping__c.getValues('InactiveComm').comm_profile__c;
        return ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zuoraAccountId,'CommunicationProfileId'=>inactiveComm,'Batch'=>'Batch1'}, 'SendToZBillingUtils');
    }


    /**
    * [disableAccCommProfileAndBatch1 updates comm profile to the supplied active profile and the batch to 'batch definition' on the account object in Zuora.
    *  It also sets the invoice template, the VAT Number, the default payment method, the default payment gateway and autopay to true.
    *  It is run when invoice is not generated, so it is used to set default parameters on the account so that it is ready when the batch generates the invoice and takes the payment]
    * @param commProfileId [Zuora Id of the communication profile]
    * @param invTemplateId [Zuora Id of the invoice template]
    * @param zuoraAccountId [Zuora Id of the account]
    * @param vatNumber [VAT Number]
    * @param  taxExemptStatus [Tax Exempt Status]
    * @param defaultPaymentMethodId [Name of the Zuora Id of the default payment method]
    * @param defaultPaymentGateway [Name of the default payment gateway]
    * @param itsBACSPayment Identifies if the bank transfer is initiated by the customer]
    * @param batch [Name of the Batch]
    * Zuora Account will be updated with TaxcertificateId[Passing the VatNumber] and TaxExemptStatus
    */
    @future(callout=true) //method has to be future because zqu.zQuoteUtil.sendToZBilling executes update DML, which prevents further callouts
    public static void enableAccCommProfileAndBatch(String commProfileId, String invTemplateId, String zuoraAccountId, String vatNumber, String taxExemptStatus, String defaultPaymentMethodId, String defaultPaymentGateway, boolean itsBACSPayment, String batch, String tradingEntity){
        System.debug('**** enableAccCommProfileAndBatch variables: Comm Profile Id = ' + commProfileId + ' Invoice Template Id = ' + invTemplateId + ' Zuora Account Id = ' + zuoraAccountId + ' VAT Number = ' + vatNumber + ' TaxExemptStatus= ' + taxExemptStatus +  ' Default Payment Method Id = ' + defaultPaymentMethodId + ' Default Payment Gateway = ' + defaultPaymentGateway + 'Is BACS = ' +  itsBACSPayment + ' Batch = ' +  batch + ' Trading Entity = ' +  tradingEntity);
        Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('SendToZBillingUtils.enableAccCommProfileAndBatch'); //loginToZuora parameter is used to track which method called the ZuoraUpdateUtility in case it needs to log any errors
        
        if(itsBACSPayment) {
            ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zuoraAccountId,'CommunicationProfileId'=>commProfileId,'InvoiceTemplateId'=>invTemplateId,'VAT_Number__c'=>vatNumber, 'TaxExemptCertificateID'=>vatNumber, 'TaxExemptStatus'=>taxExemptStatus,'Batch'=>batch,'PaymentGateway'=>defaultPaymentGateway, 'TradingEntity__c'=>tradingEntity}, 'SendToZBillingUtils.enableAccCommProfileAndBatch');
        } else {     
            ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zuoraAccountId,'CommunicationProfileId'=>commProfileId,'InvoiceTemplateId'=>invTemplateId,'VAT_Number__c'=>vatNumber, 'TaxExemptCertificateID'=>vatNumber, 'TaxExemptStatus'=>taxExemptStatus,'Batch'=>batch,'DefaultPaymentMethodId'=>defaultPaymentMethodId,'PaymentGateway'=>defaultPaymentGateway,'AutoPay'=>true, 'TradingEntity__c'=>tradingEntity}, 'SendToZBillingUtils.enableAccCommProfileAndBatch');
        }


    }

    /**
       *
    *
    * @param salesOffice
    * The sales office is always comming from the CRM/salesforce account
    *
    * @return
    * The corresponding Value of a Sales Office to a Trading Entity
    */
    private static String getTradingEntityBySaleOffice(String salesOffice) {

        String tradingEntity = null;
        if(salesOffice.equals(Global_Constants.SALES_OFFICE_DUBLIN_CBC)) {
            tradingEntity = Global_Constants.TRADING_ENTITY_SGS_LTD;
        } else if(salesOffice.equals(Global_Constants.SALES_OFFICE_ATLANTA_CBC)) {
            tradingEntity = Global_Constants.TRADING_ENTITY_SGS_Inc;
        } else if (salesOffice.equals(Global_Constants.SALES_OFFICE_US_SSI_INC)) {
            tradingEntity = Global_Constants.TRADING_ENTITY_SSI_Inc;
        } else if (salesOffice.equals(Global_Constants.SALES_OFFICE_CANADA_CBC)) {
            tradingEntity = Global_Constants.TRADING_ENTITY_SSC_LTD;
        }
        return tradingEntity;
    }


    @future(callout=true)
    public static void updateBundleFields(String zuoraSubscriptionId, String BundleDescription,Boolean isBundle, Boolean isAmend){
        boolean returnUpdate;
        List<String> ratePlanChargesIds = new List<String>();
        List<String> productRatePlanChargesIds = new List<String>();
        //List<String> bundleInstanceIds = new List<String>();
        List<STring> ratePlanIds = new List<String>();
        Boolean hasBundleDesc = false;
        System.Debug('updateBundleFields');
       // System.Debug('Select RatePlanCharge.Id, RatePlanCharge.Quantity from RatePlanCharge where Subscription.Id=\'' + zuoraSubscriptionId + '\'');


      // List <Zuora__SubscriptionProductCharge__c> ratePlanChargelst= [SELECT Zuora__RatePlanId__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__r.Zuora__Zuora_Id__c =:zuoraSubscriptionId and (NOT Zuora__Model__c like: '%Discount%')];
       // System.Debug('ratePlanChargelst'+ratePlanChargelst);

        Zuora.zApi.QueryRequest qr;
        Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('SendToZBillingUtils.updateBundleFields'); //loginToZuora parameter is used to track which method called the ZuoraUpdateUtility in case it needs to log any errors


      /*  returnUpdate =  ZuoraUpdateUtility.updateZuoraObject(zApiInstance, 'RatePlanCharge', new Map<String, Object>{
                'Id' => '2c92c0f870e7d20d0170e860d7336128', 'BundleDescription__c' => BundleDescription}, 'SendToZBillingUtils.updateBundleFields');
        system.Debug('returnUpdate'+returnUpdate);*/

        qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'Select Id from RatePlan where  SubscriptionId=\'' + zuoraSubscriptionId + '\'';

        Zuora.zApi.QueryResult queryResultRatePlan = new Zuora.zApi.QueryResult();
        if(!Test.isRunningTest()) // Only call Zuora if not in test mode
        {
            queryResultRatePlan = zApiInstance.zquery(qr);

            if (queryResultRatePlan.records.size() > 0) {
                for (integer i = 0; i < queryResultRatePlan.records.size(); i++) {
                    ratePlanIds.add((String) queryResultRatePlan.records.get(i).getValue('Id'));
                }
            }
        }

        if (ratePlanIds.size()>0){
            for ( integer j=0;j<ratePlanIds.size();j++) {
                qr = new Zuora.zApi.QueryRequest();
                qr.zoql = 'Select Id,ProductRatePlanChargeId,BundleInstanceId__c from RatePlanCharge where  RatePlanId=\'' + ratePlanIds[j] + '\' and islastsegment=true';


                Zuora.zApi.QueryResult queryResult = zApiInstance.zquery(qr);

                if (queryResult.records.size() > 0) {
                    for (integer i=0; i< queryResult.records.size() ;i++){
                        System.Debug((String) queryResult.records.get(i).getValue('Id'));
                        System.Debug('productRatePlanChargeId');
                        System.Debug((String) queryResult.records.get(i).getValue('ProductRatePlanChargeId'));
                       System.Debug('Bundle Instance ID: '+ (String) queryResult.records.get(i).getValue('BundleInstanceId__c'));
                        //subscriptionNumber = (String)queryResult.records.get(0).getValue('Name');
                        /*ZuoraUpdateUtility.updateZuoraObject(zApiInstance, 'RatePlanCharge', new Map<String, Object>{
                                'Id' => (String) queryResult.records.get(0).getValue('Id'), 'BundleDescription__c' => BundleDescription}, 'SendToZBillingUtils.updateBundleFields');
        */
                        ratePlanChargesIds.add((String) queryResult.records.get(i).getValue('Id'));
                        productRatePlanChargesIds.add((String) queryResult.records.get(i).getValue('ProductRatePlanChargeId'));
                        if (String.isBlank((String) queryResult.records.get(i).getValue('BundleInstanceId__c') ) == false)
                            if (isBundle==true && isAmend==true && (String) queryResult.records.get(i).getValue('BundleInstanceId__c') == 'Accounting Bundle')
                                hasBundleDesc = true;
                        //else
                        //    bundleInstanceIds.add((String) queryResult.records.get(i).getValue('BundleInstanceId__c'));
                        System.Debug('hasBundleDesc'+hasBundleDesc);
                    }

                    //if bundle description does not correspond to a bundle on a amendment
                    // then it should keep be considered as non bundle
                    if (isBundle==true && isAmend==true && hasBundleDesc == false)
                        isBundle = false;

                }
            }


        }



        if (ratePlanChargesIds.size()>0){
            for(integer i=0; i< ratePlanChargesIds.size();i++){


                system.Debug('isBundle'+isBundle);

                if (isBundle==true || hasBundleDesc == true ){
                    system.Debug('isBundle==true || hasBundleDesc == true');
                    returnUpdate =  ZuoraUpdateUtility.updateZuoraObject(zApiInstance, 'RatePlanCharge', new Map<String, Object>{
                            'Id' => ratePlanChargesIds[i], 'BundleDescription__c' => BundleDescription,'BundleInstanceId__c' => 'Accounting Bundle','BundleName__c'=>'Accounting Bundle'}, 'SendToZBillingUtils.updateBundleFields');
                }
                else{
                    system.Debug('else');
                    returnUpdate =  ZuoraUpdateUtility.updateZuoraObject(zApiInstance, 'RatePlanCharge', new Map<String, Object>{
                            'Id' => ratePlanChargesIds[i], 'BundleInstanceId__c' => 'I'+productRatePlanChargesIds[i],'BundleDescription__c' => '','BundleName__c'=>''}, 'SendToZBillingUtils.updateBundleFields');

                }
                                system.Debug('returnUpdate'+returnUpdate);
            }
        }

        System.debug('ratePlanChargesIds'+ratePlanChargesIds);
    }


    @future(callout=true)
    public static void updatePaymentMethod(String paymentMethodId,String countryCode){
        String paymentMethodType;
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'SELECT Type FROM PaymentMethod WHERE Id=\'' + paymentMethodId + '\'';

        Zuora.zApi zApi = ZuoraUpdateUtility.loginToZuora('SendToZBillingUtils.updateBundleFields'); //loginToZuora parameter is used to track which method called the ZuoraUpdateUtility in case it needs to log any errors
		
        System.Debug('**** zApi: ' + zApi);
        if(!Test.isRunningTest()) {// Only call Zuora if not in test mode
            Zuora.zApi.QueryResult queryResult = zApi.zquery(qr);
            System.Debug('**** Zuora Account Payment Method Query Result: ' + queryResult);

            if(queryResult.records.size() == 1){
                paymentMethodType = (String)queryResult.records.get(0).getValue('Type');
            }
        } else {    //Set the Payment Method Type to "Credit Card" for testing purposes
            paymentMethodType = 'CreditCard';
        }

        //Update Payment Retry fields

        //Specify Payment Retry fields in Zuora for Payment Method
        Integer MaxConsecutivePaymentFailures;
        Integer PaymentRetryWindow;

        if (countryCode == 'US' || countryCode == 'CA'){
            MaxConsecutivePaymentFailures =  3;
            PaymentRetryWindow = 24;
        }
        else if (paymentMethodType == 'CreditCard' || paymentMethodType == 'DebitCard' || paymentMethodType == 'ACH'){
            MaxConsecutivePaymentFailures =  4;
            PaymentRetryWindow = 24;
        }
        else{
            MaxConsecutivePaymentFailures =  2;
            PaymentRetryWindow = 24;
        }
        //Call Payment Retry fields update
        boolean returnUpdate;

        returnUpdate =  ZuoraUpdateUtility.updateZuoraObject(zApi, 'PaymentMethod', new Map<String, Object>{
                'Id' => paymentMethodId, 'MaxConsecutivePaymentFailures' => MaxConsecutivePaymentFailures,'PaymentRetryWindow' => PaymentRetryWindow,'UseDefaultRetryRule' => false});

        if(!returnUpdate && !Test.isRunningTest()){
            Map<String, String> errorMessageMap = new Map<String, String>();
            errorMessageMap.put(paymentMethodId, 'Update failed for payment method.');
            ExceptionHandler.logZuoraRecordProcessingErrors('SendToZBillingUtils', 'updatePaymentMethod', errorMessageMap);
        }

        System.debug('returnUpdate '+returnUpdate);

    }

    public  class QuoteRatePlanChargeHelper {

        //Quote Rate Plan Charge ID
        public ID quoteRatePlanChargeId;
        //Quote Rate Plan ID
        public ID quoteRatePlanID;
        //Product Rate Plan
        public ID productRatePlanID;
        //Rate Plan Charge Quantity
        public Decimal quoteRatePlanChargeQuantity;
        //Rate Plan Charge Model
        public String quoteRatePlanChargeModel;

    }

    public class BundleHelper{
        boolean isBundle;
        boolean isPayrollGb;
        boolean isAccountingGb;
        ID payrollProductRatePlanId;
    }
    
}