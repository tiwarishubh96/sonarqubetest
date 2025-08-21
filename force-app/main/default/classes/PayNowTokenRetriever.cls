public class PayNowTokenRetriever {
    public static string payNowBaseUrl = ''; // ex: 'https://sage-commerce-dev-a.azurewebsites.net';
       
    public static String getPayNowPurchaseRequest(string quoteId, string pdfId, Map<string, string> params) {
        // logic to determine showing CC or DD tabs in PayNow screen
        // 1. if no params (showCcPayment or showDdPayment) passed in, it will rely on Quote Payment Method to determine the flag values
        // 2. if any is passed in, it will override the value set from Quote payment method
        try{
            zqu__Quote__c quote = [SELECT Id, Name, zqu__Currency__c, zqu__Account__c, zqu__SoldToContact__c, zqu__BillToContact__c,
                                            zqu__Previewed_SubTotal__c, zqu__Previewed_Total__c, zqu__Previewed_Tax__c,
                                            zqu__Opportunity__c, zqu__PaymentMethod__c, zqu__ValidUntil__c,External_Application__c
                                   FROM zqu__Quote__c WHERE id =: quoteId];
            
            if (quote == null || quote.zqu__Account__c == null) return '';
            System.debug('Quote: '+quote.Name);
            
            Account currentAccount = [Select id,name,BillingCountryCode from Account Where id =: quote.zqu__Account__c];
            if (currentAccount == null) return '';
            System.debug('currentAccount: '+currentAccount.Name);
            
            Contact contact  = [SELECT id, Email, MailingStreet, MailingCity, MailingCountryCode, MailingPostalCode, MailingState,
                                        FirstName, LastName, Phone, zqu__County__c 
                                FROM contact WHERE id =: quote.zqu__BillToContact__c];
            if (contact == null) {
                contact  = [SELECT id, Email, MailingStreet, MailingCity, MailingCountry, MailingPostalCode, MailingState,
                                    FirstName, LastName, Phone, zqu__County__c
                            FROM contact WHERE id =: quote.zqu__SoldToContact__c];
            }
            System.debug('Contact: '+contact.Email);
            
            //This is supported in new version of Zuora Quote App
            //Set<ID> QuoteRatePlanCharges = [select zqu__ProductRatePlanCharge__c from zqu__QuoteRatePlanCharge__c where zqu__Quote__c =: quoteId];
            //List<zqu__QuoteRatePlan__c> ratePlans = [select Name, zqu__Quote__c, zqu__QuoteProductName__c,zqu__ProductRatePlanZuoraId__c from zqu__QuoteRatePlan__c where zqu__Quote__c =: quoteId];

            AggregateResult[] rpcResults = [select zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c,sum(zqu__Total__c),sum(zqu__BillingTotal__c)
                from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c =: quoteId
                group by zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c];

            System.debug('Aggregated ProductRatePlanCharges: count ='+ (rpcResults == null ? 'null' : ''+rpcResults.Size()));

            //variable to get Quote Rate Plan Product Name
            string quoteRatePlanProductName;
            Map<Id, String> ratePlanMap = new Map<Id, String>();
            for (AggregateResult ar : rpcResults) {
                System.debug('expr0='+ar.get('expr0'));
                ratePlanMap.put((ID)(ar.get('zqu__ProductRatePlan__c')), ar.get('expr0') == null ? ar.get('expr1') == null ? '0.0' : String.valueOf(((Decimal)(ar.get('expr1'))).setScale(2)) : String.valueOf(((Decimal)(ar.get('expr0'))).setScale(2)));
               /* if (String.isBlank(quoteRatePlanProductName)){
                    quoteRatePlanProductName =  String.valueOf(ar.get('zqu__QuoteRatePlan__r.zqu__QuoteProductName__c'));
                }
                else
                {
                    quoteRatePlanProductName  =  quoteRatePlanProductName + ' and ' + String.valueOf(ar.get('zqu__QuoteRatePlan__r.zqu__QuoteProductName__c'));
                }*/
            }

            System.debug('ratePlanMap: count ='+ ratePlanMap.Size());

            //AggregateResult[] rpResults = [select zqu__ZProduct__r.Name, zqu__ZuoraId__c from zqu__ProductRatePlan__c where Id in :ratePlanIds group by zqu__ZProduct__r.Name, zqu__ZuoraId__c];
            List<zqu__ProductRatePlan__c> ratePlans = [SELECT Id, zqu__Product__r.Name, zqu__ZuoraId__c
                                                       FROM zqu__ProductRatePlan__c WHERE Id in :ratePlanMap.keySet()];

            System.debug('ratePlans: count ='+ (ratePlans == null ? 'null' : ''+ratePlans.Size()));

            List<Attachment> attachments = [SELECT Id, Name, Body, ContentType
                                            FROM attachment WHERE Id = :pdfId order BY SystemModstamp DESC];
            
            string attachmentId = '';
            
            if (attachments != null && attachments.size() > 0)
                attachmentId = attachments[0].Id;
            
            string currentQuoteLocale = getCurrentQuoteLocale(quoteId);
            System.debug('Current quote locale ' + currentQuoteLocale);
            
            // Added to get the settings based on the Locale
            // Docmation 20160811
            // 
            Locale__c currentLocale = [SELECT Name, Basket_Name_Text__c, BillingBatch__c, Country__c, Country_Code__c, 
                                                Currency_Symbol__c, Default_Locale__c, Disclaimer_Detail__c, Disclaimer_Header__c,
                                                Language__c, Order_Total_Text__c, Sub_Total_before_Tax__c, Tax_Text__c,
                                                Total_footnote__c, Disclaimer_Header_BT__c, Disclaimer_Detail_BT__c,
                                                PayNow_EmailTemplateName__c
                                       FROM Locale__c WHERE name = :currentQuoteLocale];


            System.debug('###########################################################################################');            
            // these are potential candidates to be put in the configuration
            string currencySymbol = currentLocale.Currency_Symbol__c; //'$';
            // temprarily let currency determine what the word is, may need to refine the logic in the future
            string subtotalBeforeTaxText = currentLocale.Sub_Total_before_Tax__c; //'Subtotal before tax:';
            string taxText = currentLocale.Tax_Text__c; //'Tax:';
            string orderTotalText = currentLocale.Order_Total_Text__c; //'Order total:';
            string totalFootnote = currentLocale.Total_footnote__c; //'incl. Tax';
            string PayNowEmailTemplateName = currentLocale.PayNow_EmailTemplateName__c;

            string languageCode = currentQuoteLocale; //en-GB
            string pageType = 'salesforce';
            string productTeamId = '7243663';
            string disclaimerHeader = currentLocale.Disclaimer_Header__c==null?'':currentLocale.Disclaimer_Header__c; //'Disclaimer';
            string disclaimerDetail = currentLocale.Disclaimer_Detail__c==null?'':currentLocale.Disclaimer_Detail__c; //'';
            string basketUIName = currentLocale.Basket_Name_Text__c; //'Your Order';
            
            // these should be different if releasing regions have different setups
            string countryCode = currentAccount.BillingCountryCode;
            //languageCode = countryCode.replace('_', '-');
            System.debug('Country code: '+ countryCode);
            string zuoraInstanceName = 'CBC'; // PayNowConfiguration.Get('PurchaseRequest.'+countryCode+'.ZuoraInstanceName');
            //string disclaimerDetail = '<p style=font-size:x-small;>By confirming your payment below you are agreeing to our Terms & Conditions of Supply.</p><p style=font-size:xx-small;font-weight:normal>By signing this mandate form, you authorise (A) <label style=font-weight:bold;color:red;font-style:italic;>Sage</label> to send instructions to your bank to debit your account (B) your bank to debit your account in accordance with the instructions from <label style=font-weight:bold;color:red;font-style:italic;>Sage</label>.</p><p style=font-size:xx-small;font-weight:normal>As part of your rights, you are entitled to a refund from your bank under the terms and conditions of your agreement with your bank. A refund must be claimed within 8 weeks starting from the date on which your account was debited.</p>';
            
            System.debug('zuoraInstanceName: ' + zuoraInstanceName);
            //System.debug('Purchase Request Country code ' + 'PurchaseRequest.'+countryCode+'.ZuoraInstanceName');
            //if (countryCode == null)
            //    throw new PayNowException('Invalid billing country code: '+countryCode);

            System.debug('Currency: .... ' + currencySymbol + ', taxText: ' + taxText);
            System.debug('###########################################################################################');            
            
            Integer countOfRp = 0;

            List<Product_Tier_Rate_Plan__c> tierRatePlans = [SELECT Product_Rate_Plan__c,Product_Tier__r.PayNow_PageType__c,Product_Tier__r.Product_Use_Region__c FROM Product_Tier_Rate_Plan__c WHERE Product_Rate_Plan__c  IN :ratePlanMap.keySet()];
            String tierCode = null;
            String tierRatePlanCode = null;
            String pricingCode = null;
            try {
                SageApiActivity__c activity = [SELECT Payload__c,Quote__c FROM SageApiActivity__c WHERE ActivityType__c = 'TryNow' AND Quote__c =: quoteId LIMIT 1];
                if (activity != null) {
                    SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.Payload__c, SageApiTryNowActivityRequest.class);
                    if (req.products != null && req.products.size() > 0) {
                        tierCode = req.products[0].tierCode;
                        tierRatePlanCode = req.products[0].tierRatePlanCode;
                        pricingCode = (String.isBlank(req.products[0].pricingCode) ? '_LIST' : req.products[0].pricingCode);
                    }
                }
            } catch(Exception ex) {}

            List<PricingCode__c> pcs = [SELECT Name,ProductTierRatePlanCode__r.Name,Product_Tier__r.Product_Tier_Code__c,ValidFor__c FROM PricingCode__c WHERE Name=:pricingCode AND Product_Tier__r.Product_Tier_Code__c=:tierCode AND ProductTierRatePlanCode__r.Name=:tierRatePlanCode AND IsDeleted__c=false];

            List<Product> productList = new List<Product>();
            for (zqu__ProductRatePlan__c ratePlan : ratePlans) {
                Product p = new Product();
                p.productId = (tierCode == null ? null : tierCode);
                p.pricingCode = pricingCode;
                p.priceWithCurrency = String.isBlank(ratePlanMap.get(ratePlan.Id)) ? null : currencySymbol + ratePlanMap.get(ratePlan.Id);
                p.title = ratePlan.zqu__Product__r.Name;
                p.logo = 'https://shop.sage.co.uk/images/products/accounts_sm.png';
                RatePlan rp = new RatePlan();
                rp.id = (tierRatePlanCode == null ? null : tierRatePlanCode);
                p.ratePlans = new List<RatePlan> {rp};
                Feature feature = new Feature();
                feature.name = 'Trial';
                p.features = new List<Feature> {feature};
                p.eligiblePromotions = new String[] {'TryNow'};
                productList.add(p);

                System.debug('ratePlan: ' + ratePlan.zqu__Product__r.Name + ', '+ratePlan.zqu__ZuoraId__c);
                for (Product_Tier_Rate_Plan__c trp : tierRatePlans)
                    if (trp.Product_Rate_Plan__c ==  ratePlan.Id) {
                        if (String.isNotBlank(trp.Product_Tier__r.PayNow_PageType__c))
                            pageType = trp.Product_Tier__r.PayNow_PageType__c;
                        if (String.isNotEmpty(trp.Product_Tier__r.Product_Use_Region__c))
                            countryCode = trp.Product_Tier__r.Product_Use_Region__c.substring(0, 2);
                        break;
                    }

                countOfRp++;
            }

            if (String.isEmpty(countryCode))
                throw new PayNowException('No country code provided to continue');
            
            boolean showCcPayment = String.isNotEmpty(quote.zqu__PaymentMethod__c) && quote.zqu__PaymentMethod__c == 'Credit Card';
            System.debug('showCcPayment: ' + showCcPayment);
            
            boolean showDdPayment = String.isNotEmpty(quote.zqu__PaymentMethod__c) && (quote.zqu__PaymentMethod__c == 'ACH' || quote.zqu__PaymentMethod__c == 'Debit Card' || quote.zqu__PaymentMethod__c == 'Bank Transfer');
            System.debug('showDdPayment: ' + showDdPayment);
                                   
            // The new if condition replacing the above.
            // Docmation - 20160811
            if (showDdPayment) {
                disclaimerHeader = currentLocale.Disclaimer_Header_BT__c==null?'':currentLocale.Disclaimer_Header_BT__c;//'';
                disclaimerDetail = currentLocale.Disclaimer_Detail_BT__c==null?'':currentLocale.Disclaimer_Detail_BT__c; //'';                
            }

            string salesAssistanceContactDisplayName = 'Sage';
            
            System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            System.debug('countryCode ' + countryCode);
            string salesAssistanceContactPhone = getSalesContactPhone(countryCode);
            //string salesAssistanceContactPhone = ''; //getSalesContactPhone(countryCode);
            //salesAssistanceContactPhone = '1 844 789 5433';            
            System.debug('salesAssistanceContactPhone: ' + salesAssistanceContactPhone);
            DateTime quoteExpirationDateTime = DateTime.newInstance(quote.zqu__ValidUntil__c.year(), quote.zqu__ValidUntil__c.month(),quote.zqu__ValidUntil__c.day()).AddDays(1);
            
            string quoteExpiration = quoteExpirationDateTime.format('yyyy-MM-dd HH:mm:ss');
            string paymentCompleteNotificationUrl = '';
            string paymentCompleteRedirectUrl = '';
            string paymentCompleteCancelUrl = '';
            if (params != null && params.size() > 0) {
                paymentCompleteNotificationUrl = params.get('paymentCompleteNotificationUrl');
                paymentCompleteNotificationUrl = paymentCompleteNotificationUrl == null ? '' : paymentCompleteNotificationUrl;
                paymentCompleteRedirectUrl = params.get('paymentCompleteRedirectUrl');
                paymentCompleteRedirectUrl = paymentCompleteRedirectUrl == null ? '' : paymentCompleteRedirectUrl;
                paymentCompleteCancelUrl = params.get('paymentCompleteCancelUrl');
                paymentCompleteCancelUrl = paymentCompleteCancelUrl == null ? '' : paymentCompleteCancelUrl;
                showCcPayment = params.get('showCcPayment') == null ? showCcPayment : Boolean.valueOf(params.get('showCcPayment'));
                showDdPayment = params.get('showDdPayment') == null ? showDdPayment : Boolean.valueOf(params.get('showDdPayment'));
                pageType = params.get('pageType') == null ? pageType : params.get('pageType');
            }

            if (String.isNotBlank(currentAccount.Name))
                currentAccount.Name = currentAccount.Name.replace('\\', '\\\\').replace('"', '\\"');

            String address1 = null, address2 = null;
            if (String.isNotBlank(contact.MailingStreet)) {
                String[] addressLines = contact.MailingStreet.split('\r\n');
                if (addressLines.size() > 1) {
                    address1 = addressLines[0];
                    for (Integer i = 1; i < addressLines.size(); i++)
                        address2 = (String.isBlank(address2) ? '' : address2 + '\r\n') + addressLines[i];
                } else {
                    address1 = contact.MailingStreet;
                }
            }

            Request req = new Request();
            req.id = GenericUtilities.getRandomUUIDv4();
            req.version = '1.0';
            req.idpId = req.id;
            req.createDateTimeUtc = System.now();
            req.salesAssistanceContactDisplayName = salesAssistanceContactDisplayName;
            req.salesAssistanceContactPhone = salesAssistanceContactPhone;
            //req.quoteRatePlanProductName = quoteRatePlanProductName;
            //req.externalApp = quote.External_Application__c;
            SalesforceData sf = new SalesforceData();
            sf.accountId = currentAccount.Id;
            sf.opportunityId = quote.zqu__Opportunity__c;
            sf.quoteId = quote.Id;
            sf.quoteAttachmentId = attachmentId;
            sf.quoteExpirationUtcDateTime = quoteExpiration;
            sf.quoteLocale = currentQuoteLocale;
            EmailOptions emailOptions = new EmailOptions();
            emailOptions.emailTemplateName = PayNowEmailTemplateName;
            sf.emailOptions = emailOptions;
            req.salesforce = sf;
            ZuoraData zuora = new ZuoraData();
            zuora.instanceName = zuoraInstanceName;
            zuora.currencyCode = quote.zqu__Currency__c;
            zuora.accountName = currentAccount.Name;
            ContactData contactData = new ContactData();
            contactData.firstName = contact.FirstName;
            contactData.lastName = contact.LastName;
            contactData.address1 = (String.isBlank(address1) ? null : address1);
            contactData.address2 = (String.isBlank(address2) ? null : address2);
            contactData.city = contact.MailingCity;
            contactData.country = contact.MailingCountryCode;
            contactData.county = (String.isBlank(contact.zqu__County__c) ? null : contact.zqu__County__c);
            contactData.zipCode = contact.MailingPostalCode;
            contactData.state = (String.isBlank(contact.MailingState) ? null : contact.MailingState);
            contactData.workEmail = contact.Email;
            contactData.workPhone = (String.isBlank(contact.Phone) ? null : contact.Phone);
            zuora.contacts = new List<ContactData>();
            zuora.contacts.add(contactData);
            req.zuora = zuora;
            Basket basket = new Basket();
            basket.subtotalBeforeTaxWithCurrency = currencySymbol+quote.zqu__Previewed_SubTotal__c;
            basket.shippingWithCurrency = currencySymbol+'0.00';
            basket.promotionDiscountWithCurrency = currencySymbol+'0.00';
            basket.taxWithCurrency = currencySymbol+quote.zqu__Previewed_Tax__c;
            basket.totalWithCurrency = currencySymbol+quote.zqu__Previewed_Total__c;
            basket.totalAfterPromotionWithCurrency = currencySymbol+quote.zqu__Previewed_Total__c;
            basket.products = productList;
            basket.tAndC = new TermAndCondition();
            basket.tAndC.header = disclaimerHeader;
            basket.tAndC.detail = disclaimerDetail;
            req.baskets = new List<Basket> {basket};
            PageConfig pageConfig = new PageConfig();
            pageConfig.pageType = pageType;
            pageConfig.countryCode = countryCode;
            pageConfig.productTeamId = productTeamId;
            pageConfig.showCreditCardPayment = showCcPayment;
            pageConfig.showDirectDebitPayment = showDdPayment;
            pageConfig.canEditBillTo = false;
            pageConfig.paymentCompleteNotificationApi = paymentCompleteNotificationUrl;
            pageConfig.paymentCompleteRedirectUrl = paymentCompleteRedirectUrl;
            pageConfig.paymentCancelRedirectUrl = paymentCompleteCancelUrl;
            pageConfig.languageCode = languageCode;
            req.pageConfig = pageConfig;

            String returnStr = JSON.serialize(req);
/*
            string returnStr = '{"id":"ba7b05fd-2265-4e65-bddb-efc0a9798a30","version":"1.0","idp-id":null,"create-date-time-utc":"'+
                System.now()+'", "sales-assistance-contact-display-name":"'+ salesAssistanceContactDisplayName + 
                '", "sales-assistance-contact-phone":"' + salesAssistanceContactPhone + '", "salesforce":{"account-id":"'+currentAccount.Id+'","opportunity-id":"'+quote.zqu__Opportunity__c +'","quote-id":"' + 
                quote.Id +'","quote-attachment-id":"'+attachmentId+'","quote-expiration-utc-datetime":"'+
                quoteExpiration +'","quote-locale":"' + currentQuoteLocale + '", "emailOptions":{"emailTemplateName":"'+PayNowEmailTemplateName+'"}},"zuora":{"instance-name":"'+zuoraInstanceName+'","currency":"'+
                quote.zqu__Currency__c+'","request-to-create-subscription":false,"request-to-create-account":false,"request-to-create-paymentmethod":true,"account-number":"","account-name":"' + 
                currentAccount.Name + '","sold-to-contact-guid":"","bill-to-contact-guid":"","contacts":[{"address1":'+
                (String.isBlank(address1) ? null : '"'+address1+'"')+',"address2":'+(String.isBlank(address2) ? null : '"'+address2+'"')+',"city":"'+contact.MailingCity+'","country":"'+
                contact.MailingCountryCode+'","county":'+(String.isBlank(contact.zqu__County__c) ? null : '"'+contact.zqu__County__c+'"')+',"fax":null,"firstName":"'+
                contact.FirstName+'","lastName":"'+contact.LastName+'","homePhone":null,"mobilePhone":null,"nickname":null,"personalEmail":null,"zipCode":"'+
                contact.MailingPostalCode+'","state":'+(String.isBlank(contact.MailingState) ? null : '"'+contact.MailingState+'"')+',"taxRegion":null,"workEmail":"'+contact.Email+'","workPhone":'+
                (String.isBlank(contact.Phone) ? null : '"'+contact.Phone+'"')+'}],"sold-to-contact-index":0,"bill-to-contact-index":0,"payment-contact-index":0,"contract-effective-date-in-pacific-time-zone":"2015-08-01"},"baskets":[{"title":"","products":['+
                products+'],"subtotal-before-tax-with-currency":"'+currencySymbol+quote.zqu__Previewed_SubTotal__c+'","shipping-with-currency":"'+
                currencySymbol+'0.00","promotion-discount-with-currency":"'+currencySymbol+'0.00","tax-with-currency":"'+
                currencySymbol+quote.zqu__Previewed_Tax__c+'","total-with-currency":"'+currencySymbol+quote.zqu__Previewed_Total__c+'","total-after-promotion-with-currency":"'+
                currencySymbol+quote.zqu__Previewed_Total__c+'","next-periods":null,"features": [{ "name": "Trial"}],"t-and-c":{"header":"'+disclaimerHeader+'","detail":"'+
                disclaimerDetail+'","link-text":null}}],"page-config":{"country-code":"'+
                countryCode+'","page-type":"'+pageType+'","product-team-id":"'+productTeamId+'","show-creditcard-payment":'+
                showCcPayment+',"show-directdebit-payment":'+showDdPayment+',"custom-header-html":"","can-edit-bill-to":false,"edit-sold-to-url":"","edit-bill-to-url":"","edit-cart-url":"",'+
                '"payment-complete-notification-api":"'+paymentCompleteNotificationUrl+'","payment-complete-redirect-url":"'+paymentCompleteRedirectUrl+'","payment-cancel-redirect-url":"'+paymentCompleteCancelUrl+'","continue-shopping-url":"","buy-complete-notification-api":"","buy-confirmation-redirect-url":"","buy-error-redirect-url":"","language-code":"'+
                languageCode+'","custom-paynow-purchase-button-text":"","custom-cancel-button-text":"Cancel"}}';
*/            
            System.debug('returnStr: ' + returnStr);
            return returnStr;
        } Catch(Exception ex){
            return 'Error generating JSON: ' + ex.getStackTraceString();
        }
    }
    
    public static string getSalesContactPhone(string countryCode) {
        if(countryCode == null)
            throw new PayNowException('Missing billing country code.');
        
        if(countryCode != 'US' && countryCode != 'GB' && countryCode != 'IE' && countryCode != 'CA')
            countryCode = 'US';
        
        string settingsKey = 'ContactPhone_' + countryCode;

        PayNowSetting__c pnSetting = PayNowSetting__c.getInstance(settingsKey);
        
        if(pnSetting == null)
            throw new PayNowException('Cannot find Sales Contact Number for country code: '+ countryCode);
        
        return pnSetting.Value__c;
    }

    //Retrieve the locale based on the Quote ID to pass to PayNow. RETRIEVING CODE 
    // Docmation 20160805
    public static String getCurrentQuoteLocale(string quoteId) {
        String currentLocale = [SELECT account_locale__c FROM zqu__Quote__c WHERE Id = :quoteId].account_locale__c;
        currentLocale = currentLocale==null?'en_US':currentLocale;
        return currentLocale;        
    }   
    
    public static Map<ID, PayNowToken__c> createPayNowPurchaseToken(Map<ID, string> quotePayLoadMap) {
        System.debug('createPayNowPurchaseToken was called');
        if (quotePayLoadMap == null || quotePayLoadMap.size() == 0) return null;
        
        Map<ID, string> quoteTokenIdMap = new Map<ID, string>();
        Map<ID, string> quoteErrorMsgMap = new Map<ID, string>();
        Map<ID, PayNowToken__c> quoteFailedTokenMap = new Map<ID, PayNowToken__c>();

        if(payNowBaseUrl == null || payNowBaseUrl.length() < 1) {
            PayNowSetting__c pnSettings = PayNowSetting__c.getInstance('payNowBaseUrl');
            payNowBaseUrl = pnSettings.Value__c;
        }
        
        PayNowSetting__c pnUserName = PayNowSetting__c.getInstance('payNowServiceUserName');
        PayNowSetting__c pnPassword = PayNowSetting__c.getInstance('payNowServicePassword');
        string userName = pnUserName.Value__c;
        string password = pnPassword.Value__c;
        
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        
        for (ID quoteId : quotePayLoadMap.keySet()) {
            string purchaseRequestPayLoad = quotePayLoadMap.get(quoteId);
            req.setEndpoint(payNowBaseUrl + '/api/PurchaseRequest2');
            req.setMethod('POST');
            req.setBody(purchaseRequestPayLoad);
            //req.setCompressed(true); // otherwise we hit a limit of 32000
            //req.setTimeout(30000);
            
            System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            System.debug('payLoad ' + purchaseRequestPayLoad);
            System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            try {
                if (Test.isRunningTest()) {
                    Http h = new Http();
                    res = h.send(req);
                } else {
                    res = GenericUtilities.httpSend(req, SageApiActivityUtils.setting_HttpCalloutDefaultTimeoutInSeconds, SageApiActivityUtils.setting_HttpCalloutDefaultMaxRetries);
                }

                String jsonValue = res.getBody();
                System.debug(jsonValue);
                string purchaseToken = null;
                JSONParser parser = JSON.createParser(jsonValue);
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                        String fieldName = parser.getText();
                        parser.nextToken();
                        if(fieldName == 'purchase-token-id') {
                            purchaseToken = parser.getText();
                            break;
                        }
                    }
                }
                
                System.debug(purchaseToken);
                quoteTokenIdMap.put(quoteId, purchaseToken);
            } catch(Exception e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
                quoteTokenIdMap.put(quoteId, null);
                String errorMsg = e.getMessage();
                if (errorMsg.length() > 32768)
                    errorMsg = errorMsg.substring(0, 32760) + '...';
                quoteErrorMsgMap.put(quoteId, errorMsg);
                quoteFailedTokenMap.put(quoteId, new PayNowToken__c(name= 'Failed', Quote__c =quoteId, Status__c ='Failed', ErrorMessage__c = quoteErrorMsgMap.get(quoteId)));
                ExceptionHandler.CatchException('PayNowTokenRetriever', 'createPayNowPurchaseToken', e);
            }
        }
        
        if (quoteTokenIdMap.size() == 0) return quoteFailedTokenMap;
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        
        for (ID quoteId : quoteTokenIdMap.keySet()) {
            string purchaseToken = quoteTokenIdMap.get(quoteId);
            if (string.isBlank(purchaseToken)) continue;
            
            //Retrieve the locale based on the Quote ID to pass to PayNow. RETRIEVING CODE 
            // Docmation 20160805
            String currentLocale = getCurrentQuoteLocale(quoteId);
            if (String.isNotBlank(currentLocale)) currentLocale = currentLocale.replace('_', '-');
            String tokenLink = payNowBaseUrl + '/' + currentLocale + '/PayNow/Get?id=' + purchaseToken;
            PayNowToken__c t = new PayNowToken__c(name= purchaseToken, PayNowRedirectUrl__c = tokenLink, Quote__c =quoteId, Status__c ='Created');
            tokens.add(t);
        }
            
        try {
            insert tokens;
        } catch(Exception e) {
            System.debug('Insert PayNow Token error: '+ e);                 
        }    
        
        Map<ID, PayNowToken__c> quoteTokenMap = new Map<ID, PayNowToken__c>();
        for (PayNowToken__c t : tokens)
            quoteTokenMap.put(t.Quote__c, t);

        if (quoteFailedTokenMap.size() > 0)
            for (PayNowToken__c t : quoteFailedTokenMap.values())
                quoteTokenMap.put(t.Quote__c, t);

        return quoteTokenMap;
    }
    
    public static PayNowToken__c createPayNowPurchaseToken(string quoteId, string purchaseRequestPayLoad)
    {
        String purchaseToken = '';
        System.debug('createPayNowPurchaseToken was called');
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        if(payNowBaseUrl == null || payNowBaseUrl.length() < 1) {
            PayNowSetting__c pnSettings = PayNowSetting__c.getInstance('payNowBaseUrl');
            payNowBaseUrl = pnSettings.Value__c;
        }
        
        PayNowSetting__c pnUserName = PayNowSetting__c.getInstance('payNowServiceUserName');
        PayNowSetting__c pnPassword = PayNowSetting__c.getInstance('payNowServicePassword');
        string userName = pnUserName.Value__c;
        string password = pnPassword.Value__c;
        
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        string errorMsg = null;
        
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        
        req.setEndpoint(payNowBaseUrl + '/api/PurchaseRequest2');
        req.setMethod('POST');
        req.setBody(purchaseRequestPayLoad);
        //req.setCompressed(true); // otherwise we hit a limit of 32000
        
        System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        System.debug('payLoad ' + purchaseRequestPayLoad);
        System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        try {
            if (Test.isRunningTest()) {
                Http h = new Http();
                res = h.send(req);
            } else {
                res = GenericUtilities.httpSend(req, SageApiActivityUtils.setting_HttpCalloutDefaultTimeoutInSeconds, SageApiActivityUtils.setting_HttpCalloutDefaultMaxRetries);
            }

            String jsonValue = res.getBody();
            System.debug(jsonValue);
            
            JSONParser parser = JSON.createParser(jsonValue);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'purchase-token-id') {
                        purchaseToken = parser.getText();
                    }
                }
            }
            
            System.debug(purchaseToken);
            
        } catch(Exception e) 
        {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            purchaseToken = 'No Purchase Token: '+ e;
            errorMsg = e.getMessage();
            if (errorMsg.length() > 32768)
                errorMsg = errorMsg.substring(0, 32760) + '...';
            return null;
        }
    
        //Retrieve the locale based on the Quote ID to pass to PayNow. RETRIEVING CODE 
        // Docmation 20160805
        String currentLocale = getCurrentQuoteLocale(quoteId);
        String tokenLink = payNowBaseUrl + '/' + currentLocale + '/PayNow/Get?id=' + purchaseToken;        
        System.debug(quoteId);
        
        String quoteRatePlanProductName;
        quoteRatePlanProductName = '';
        List<zqu__QuoteRatePlan__c> quoteRatePlans = [select Id,zqu__QuoteProductName__c,zqu__Quote__r.External_Application__c,zqu__ProductRatePlan__r.zqu__Product__c
                                               from zqu__QuoteRatePlan__c where zqu__Quote__c =: quoteId];

        boolean isTetris;
        isTetris = false;
        List<ID> quoteRatePlanProductId = new List<ID>();
        
        for (zqu__QuoteRatePlan__c quoteRatePlan : quoteRatePlans) {
            System.debug('External app inside createPayNowPurchaseToken ' + quoteRatePlan.zqu__Quote__r.External_Application__c);
            if (quoteRatePlan.zqu__Quote__r.External_Application__c == Global_Constants.TETRIS){
                isTetris = true;
                quoteRatePlanProductId.add(quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__c);
                System.debug('quoteRatePlanProductId' + quoteRatePlanProductId);
                
            }
        }
        
        if (isTetris == false){
            quoteRatePlanProductName = 'Sage Live';
        }
        else
        {
            List <ZProductChargeNameMapping__c> zProductNames = [select TranslatedProductName__c,
                                                                               Locale__r.name, Product__r.name
                                                                               from ZProductChargeNameMapping__c
                                                               where Product__r.Id In: quoteRatePlanProductId];
            
            for (ZProductChargeNameMapping__c zProductName : zProductNames){
                System.debug('Inside ZProductChargeNameMapping__c');
                if (String.isBlank(quoteRatePlanProductName)){
                    quoteRatePlanProductName = zProductName.TranslatedProductName__c;
                }
                else
                {
                    quoteRatePlanProductName += ' and ' + zProductName.TranslatedProductName__c;
                }
            }
            
        }
        
        try{
            PayNowToken__c a = new PayNowToken__c(name= purchaseToken, PayNowRedirectUrl__c = tokenLink, Quote__c =quoteId, Status__c ='Created',Email_Template_Variable__c = quoteRatePlanProductName);
            insert a;
            
            System.assertEquals(a.Name, purchaseToken);
            return a;
        }
        catch(System.CalloutException e) 
        {
            System.debug('Insert PayNow Token Error occurred.');
            System.debug('Insert PayNow Token error: '+ e);                 
        }    
        
        return null;
        
    }

    public class Request {
        public String id;
        public String version = '1.0';
        public String idpId;
        public DateTime createDateTimeUtc;
        public ZuoraData zuora;
        public SalesforceData salesforce;
        public List<Basket> baskets;
        public PageConfig pageConfig;
        public String salesAssistanceContactDisplayName;
        public String salesAssistanceContactPhone;
    }

    public class ZuoraData {
        public String instanceName;
        public String currencyCode;
        public String accountNumber;
        public String accountName;
        public String soldToContactGuid;
        public String billToContactGuid;
        public List<ContactData> contacts;
        public Integer soldToContactIndex = 0;
        public Integer billToContactIndex = 0;
        public Integer paymentContactIndex = 0;
        public String contractEffectiveDateInPacificTimeZone;
    }

    public class ContactData {
        public String address1;
        public String address2;
        public String city;
        public String country;
        public String county;
        public String firstName;
        public String lastName;
        public String zipCode;
        public String state;
        public String workEmail;
        public String workPhone;
    }

    public class SalesforceData {
        public String accountId;
        public String opportunityId;
        public String quoteId;
        public String quoteAttachmentId;
        public String quoteExpirationUtcDateTime;
        public String quoteLocale;
        public EmailOptions emailOptions;
    }

    public class Basket {
        public String title;
        public String productUiName;
        public String subtotalBeforeTaxWithCurrency;
        public String shippingWithCurrency;
        public String prmotionDiscountPeriod;
        public String promotionDiscountWithCurrency;
        public String taxWithCurrency;
        public String totalWithCurrency;
        public String totalPeriodType;
        public String totalAfterPromotionWithCurrency;
        public String totalFootnote;
        public String subtotalBeforeTaxText;
        public String taxText;
        public String orderTotalText;
        public String nextPeriods;
        public List<Product> products;
        public TermAndCondition tAndC;
    }

    public class Product {
        public String productId;
        public String pricingCode;
        public String priceWithCurrency;
        public String periodType;
        public String title;
        public String logo;
        public List<Feature> features;
        public String tAndC;
        public List<RatePlan> ratePlans;
        public List<String> eligiblePromotions;
    }

    public class Feature {
        public String name;
    }

    public class RatePlan {
        public String id;
        public String sku;
        public Integer qty;
    }

    public class TermAndCondition {
        public String header;
        public String detail;
        public String linkText;
    }

    public class PageConfig {
        public String productTeamId;
        public string pageType;
        public String countryCode;
        public String languageCode;
        public Boolean showCreditCardPayment;
        public Boolean showDirectDebitPayment;
        public String customHeaderHtml;
        public Boolean canEditBillTo;
        public String editSoldToUrl;
        public String editBillToUrl;
        public String eidtCartUrl;
        public String continueShoppingUrl;
        public String paymentCompleteNotificationApi;
        public String paymentCompleteRedirectUrl;
        public String paymentCancelRedirectUrl;
        public String buyCompleteNotificationApi;
        public String buyConfirmationRedirectUrl;
        public String buyErrorRedirectUrl;
        public String customPayNowPurchaseButtonText;
        public String customCancelButtonText;
        public String showPromoCode;
    }

    public class EmailOptions {
        public String emailTemplateName;
    }
}