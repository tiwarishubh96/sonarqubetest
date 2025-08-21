//
// This class is used to set the defaults values on the Zuora Payment Pages
// It replaces the Zuora plugin zqu.PaymentPageController.DefaultHostedPageLitePlugin
// The key setting is the currency field which allows the UK and IE Payment Gateways to work
// In addition it defaults the Customer fields to the Billing Customer on the Quote / Billing Account
//
global class PaymentPageDefaultValuePlugin implements zqu.PaymentPageController.IHostedPageLitePlugin {
    global Map < String, String > getAdditionalParameters(String paymentMethodType) {
        
        Map < String, String > defaultValues = new Map < String, String >();
 	    String objectId = ApexPages.currentPage().getParameters().get('Id');
        String paymentMethodTypeLookup;
        String currencyIsoCode;
        String paymentGateway;
        String zuoraAccountId;
        String countryPrefix;
        String customerName;
        String customerFirstName;
        String customerLastName;
        String customerCountry;
        String customerCountryIso3Code;
        String customerAddress1;
        String customerAddress2;
        String customerCity;
        String customerState;
        String customerPostalCode;
        String customerPhone;
        String customerEmail;
        
        system.debug('**** Inside DefaultValuePlugin ****'); 
        system.debug('**** Payment Method Type: ' + paymentMethodType);
        system.debug('**** URL Id: ' + objectId);

        // Set the default values for payment method type credit card
        if(paymentMethodType == zqu.PaymentPageController.PAYMENT_METHOD_TYPE_CREDIT_CARD) {
            paymentMethodTypeLookup = 'Credit Card';
        }
        // Set the default values for payment method type ACH
        else if(paymentMethodType == zqu.PaymentPageController.PAYMENT_METHOD_TYPE_ACH) {
            paymentMethodTypeLookup = 'ACH';
        }
        // Set the default values for payment method type Bank Transfer
        else if(paymentMethodType == zqu.PaymentPageController.PAYMENT_METHOD_TYPE_BANK_TRANSFER) {
            paymentMethodTypeLookup = 'Bank Transfer';
        }    
        // Set the default values for payment method type SEPA
        else if(paymentMethodType == 'SEPA') {
            paymentMethodTypeLookup = 'Bank Transfer';
        } 
        // Unexpected PaymentMethodType - should never happen but if it does exit without setting any values
        else {
            return defaultValues;
        }
        
        system.debug('**** Payment Method Type Lookup: ' + paymentMethodTypeLookup);
                        
        // Determine whether the Object Id is for a Quote or a Billing Account
        if(objectId == null){
            // Url is missing the Id parameter - should never happen but if it does exit without setting any values
            return defaultValues;         
        }
        String objectAPIName = ((Id)objectId).getSObjectType().getDescribe().getName();
        if (objectAPIName.toLowerCase().contains('quote')){
            // Read the Quote to get the Zuora Country Code and the Billing Contact Details
            List<zqu__Quote__c> quote = [SELECT zqu__ZuoraAccountID__c, Zuora_Country_Code__c,
                                                zqu__BillToContact__r.Name, zqu__BillToContact__r.FirstName, 
                                                zqu__BillToContact__r.LastName, zqu__BillToContact__r.MailingCountry, 
                                                zqu__BillToContact__r.MailingStreet, zqu__BillToContact__r.MailingCity, 
                                                zqu__BillToContact__r.MailingState, zqu__BillToContact__r.MailingPostalCode, 
                                                zqu__BillToContact__r.Phone, zqu__BillToContact__r.Email
                                         FROM zqu__Quote__c WHERE Id = :objectId];
            if(quote.size()==1){
                zuoraAccountId = quote.get(0).zqu__ZuoraAccountID__c;
                countryPrefix = quote.get(0).Zuora_Country_Code__c;
                customerName = quote.get(0).zqu__BillToContact__r.Name;
                customerName = quote.get(0).zqu__BillToContact__r.FirstName;
                customerName = quote.get(0).zqu__BillToContact__r.LastName;
                customerCountry = quote.get(0).zqu__BillToContact__r.MailingCountry;
                customerAddress1 = quote.get(0).zqu__BillToContact__r.MailingStreet;
                customerCity = quote.get(0).zqu__BillToContact__r.MailingCity;
                customerState = quote.get(0).zqu__BillToContact__r.MailingState;
                customerPostalCode = quote.get(0).zqu__BillToContact__r.MailingPostalCode;
                customerPhone = quote.get(0).zqu__BillToContact__r.Phone;
                customerEmail = quote.get(0).zqu__BillToContact__r.Email;
              
                system.debug('**** Found a Quote - Account Id: ' + zuoraAccountId);
                                      
            } else {
                // Zero or more than one Quote - should never happen but if it does exit without setting any values
                return defaultValues;
            }
        } else if (objectAPIName.toLowerCase().contains('customeraccount')){
            // Read the Billing Account to get the Zuora Country Code and the Billing Contact Details
            List<Zuora__CustomerAccount__c> acc = [SELECT Zuora__Zuora_Id__c, Zuora__Account__r.Zuora_Country_Code__c, 
                                                          Zuora__BillToName__c, Zuora__BillToCountry__c, 
                                                          Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, 
                                                          Zuora__BillToCity__c, Zuora__BillToState__c, 
                                                          Zuora__BillToPostalCode__c, Zuora__BillToWorkPhone__c, 
                                                          Zuora__BillToWorkEmail__c 
                                                   FROM Zuora__CustomerAccount__c WHERE Id = :objectId];
            if(acc.size()==1){
                zuoraAccountId = acc.get(0).Zuora__Zuora_Id__c;
                countryPrefix = acc.get(0).Zuora__Account__r.Zuora_Country_Code__c;
                customerName = acc.get(0).Zuora__BillToName__c;
                customerCountry = acc.get(0).Zuora__BillToCountry__c;
                customerAddress1 = acc.get(0).Zuora__BillToAddress1__c;
                customerAddress2 = acc.get(0).Zuora__BillToAddress2__c;
                customerCity = acc.get(0).Zuora__BillToCity__c;
                customerState = acc.get(0).Zuora__BillToState__c;
                customerPostalCode = acc.get(0).Zuora__BillToPostalCode__c;
                customerPhone = acc.get(0).Zuora__BillToWorkPhone__c;
                customerEmail = acc.get(0).Zuora__BillToWorkEmail__c;
                
                system.debug('**** Found a Billing Account - Account Id: ' + zuoraAccountId);
                                     
            } else {
                // Zero or more than one Billing Account - should never happen but if it does exit without setting any values
                return defaultValues;
            }
        } else {
            // Object is not a Quote or a Billing Account - should never happen but if it does exit without setting any values
            return defaultValues;        
        }

        // Read the Hosted Payment Page object for the Country Prefix and the Payment Method Type to find the Default Currency
       // List<zqu__HostedPageLiteSetting__c> pageSettings = (List<zqu__HostedPageLiteSetting__c>)Database.query('SELECT CurrencyIsoCode, Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE Name Like \'' + 'CBC ' + countryPrefix + ' ' + paymentMethodTypeLookup + '%\'');
        
        String clientCode = System.Label.Client_Code ; //Is there a way to derive this from App rather than hardcoding ?
        System.debug('___client code '+clientCode );
        
        //Fix for EAD-556: As there is no Country code "UK" in payment page settings, 
        //it needs to be changed to GB
        if(countryPrefix.equals('UK')) { countryPrefix = 'GB'; }
        
        System.debug('countryPrefix>>>'+countryPrefix);
        
        List<zqu__HostedPageLiteSetting__c> pageSettings = [SELECT zqu__PageId__c, CurrencyIsoCode, Payment_Gateway_Name__c 
                                                            FROM zqu__HostedPageLiteSetting__c 
                                                            WHERE Client_Code__c = :clientCode
                                                            AND Country_Code__c = :countryPrefix
                                                            AND zqu__PaymentMethodType__c = :paymentMethodType];
        if(pageSettings.size()==1){
            currencyIsoCode = pageSettings.get(0).CurrencyIsoCode;
            paymentGateway = pageSettings.get(0).Payment_Gateway_Name__c;
        } else {
            // Zero or more Payment Page Settings found - should never happen but if it does exit without setting any values
            return defaultValues;
        }        

        system.debug('**** Found a Payment Page Settings - Currency: ' + currencyIsoCode + ' & Gateway Name: ' + paymentGateway);

        // Convert Canada, United States and the 28 European Union countries into ISO Alpha-3 codes
        // (If a country isn't converted it just means that the Sales Ops user will have to select it
        //  manually on the payment page)
        if      (customerCountry == 'Canada') { customerCountryIso3Code = 'CAN'; }
        else if (customerCountry == 'United States') { customerCountryIso3Code = 'USA'; }
        else if (customerCountry == 'Austria') { customerCountryIso3Code = 'AUT'; }
        else if (customerCountry == 'Belgium') { customerCountryIso3Code = 'BEL'; }
        else if (customerCountry == 'Bulgaria') { customerCountryIso3Code = 'BGR'; }
        else if (customerCountry == 'Croatia') { customerCountryIso3Code = 'HRV'; }
        else if (customerCountry == 'Cyprus') { customerCountryIso3Code = 'CYP'; }
        else if (customerCountry == 'Czech Republic') { customerCountryIso3Code = 'CZE'; }
        else if (customerCountry == 'Denmark') { customerCountryIso3Code = 'DNK'; }
        else if (customerCountry == 'Estonia') { customerCountryIso3Code = 'EST'; }
        else if (customerCountry == 'Finland') { customerCountryIso3Code = 'FIN'; }
        else if (customerCountry == 'France') { customerCountryIso3Code = 'FRA'; }
        else if (customerCountry == 'Germany') { customerCountryIso3Code = 'DEU'; }
        else if (customerCountry == 'Greece') { customerCountryIso3Code = 'GRC'; }
        else if (customerCountry == 'Hungary') { customerCountryIso3Code = 'HUN'; }
        else if (customerCountry == 'Ireland') { customerCountryIso3Code = 'IRL'; }
        else if (customerCountry == 'Italy') { customerCountryIso3Code = 'ITA'; }
        else if (customerCountry == 'Latvia') { customerCountryIso3Code = 'LVA'; }
        else if (customerCountry == 'Lithuania') { customerCountryIso3Code = 'LTU'; }
        else if (customerCountry == 'Luxembourg') { customerCountryIso3Code = 'LUX'; }
        else if (customerCountry == 'Malta') { customerCountryIso3Code = 'MLT'; }
        else if (customerCountry == 'Netherlands') { customerCountryIso3Code = 'NLD'; }
        else if (customerCountry == 'Poland') { customerCountryIso3Code = 'POL'; }
        else if (customerCountry == 'Portugal') { customerCountryIso3Code = 'PRT'; }
        else if (customerCountry == 'Romania') { customerCountryIso3Code = 'ROU'; }
        else if (customerCountry == 'Slovakia') { customerCountryIso3Code = 'SVK'; }
        else if (customerCountry == 'Slovernia') { customerCountryIso3Code = 'SVN'; }
        else if (customerCountry == 'Spain') { customerCountryIso3Code = 'ESP'; }
        else if (customerCountry == 'Sweden') { customerCountryIso3Code = 'SWE'; }
        else if (customerCountry == 'United Kingdom') { customerCountryIso3Code = 'GBR'; }
        
        system.debug('**** Country ISO Alpha-3 Code Conversion : ' + customerCountry + ' => ' + customerCountryIso3Code);

        // Set the default values for payment method type credit card
        if(paymentMethodType == 'Credit Card') {
            defaultValues.put('currency', currencyIsoCode);
            defaultValues.put('field_gatewayName', paymentGateway);
            defaultValues.put('creditCardHolderName', customerName);
            defaultValues.put('creditCardCountry', customerCountryIso3Code);
            defaultValues.put('creditCardAddress1', customerAddress1);
            defaultValues.put('creditCardCity', customerCity);
            defaultValues.put('creditCardState', customerState);
            defaultValues.put('creditCardPostalCode', customerPostalCode);
            defaultValues.put('phone', customerPhone);
            defaultValues.put('email', customerEmail);
            
            system.debug('**** Set Credit Card default values');
        }
        // Set the default values for payment method type ACH
        else if(paymentMethodType == 'ACH') {
            
            defaultValues.put('currency', currencyIsoCode);
            defaultValues.put('field_gatewayName', paymentGateway);
            defaultValues.put('achBankAccountType', 'Checking');
            defaultValues.put('achBankAccountName', customerName);
            
            system.debug('**** Set ACH default values');
        }
        // Set the default values for payment method type Bank Transfer (Direct Debit)
        else if(paymentMethodType == 'Bank Transfer') {
            defaultValues.put('currency', currencyIsoCode);
            defaultValues.put('field_gatewayName', paymentGateway);
            defaultValues.put('bankTransferAccountName', customerName); // This doesn't work for Direct Debit for some reason
            defaultValues.put('firstName', customerFirstName); // This doesn't work for Direct Debit some reason
            defaultValues.put('lastName', customerLastName); // This doesn't work for Direct Debit some reason
            defaultValues.put('streetName', customerAddress1);
            defaultValues.put('city', customerCity);
            defaultValues.put('state', customerState);
            defaultValues.put('postalCode', customerPostalCode);
            defaultValues.put('country', customerCountryIso3Code);
            defaultValues.put('phone', customerPhone);
            defaultValues.put('email', customerEmail);
            
            system.debug('**** Set Bank Transfer default values');
        }
        // Set the default values for payment method type SEPA
        else if(paymentMethodType == 'SEPA') {
            defaultValues.put('currency', currencyIsoCode);
            defaultValues.put('field_gatewayName', paymentGateway);
            defaultValues.put('bankTransferAccountName', customerName); // This doesn't work for SEPA some reason
            defaultValues.put('firstName', customerFirstName); // This doesn't work for SEPA some reason
            defaultValues.put('lastName', customerLastName); // This doesn't work for SEPA some reason
            defaultValues.put('streetName', customerAddress1);
            defaultValues.put('city', customerCity);
            defaultValues.put('state', customerState); // This doesn't work for SEPA some reason
            defaultValues.put('postalCode', customerPostalCode);
            defaultValues.put('country', customerCountryIso3Code); // This doesn't work for SEPA some reason
            defaultValues.put('phone', customerPhone);
            defaultValues.put('email', customerEmail);
            
            system.debug('**** Set SEPA default values');
        }
        
        // Return the populated default values
        return defaultValues;
    }
}