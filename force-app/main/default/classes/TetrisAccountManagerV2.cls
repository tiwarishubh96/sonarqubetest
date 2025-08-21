/**
 * Created by cafe on 2/2/2021.
 */

public with sharing class TetrisAccountManagerV2 {

    private Schema.DescribeSObjectResult contactDescResult = Schema.SObjectType.Contact;
    private Schema.DescribeSObjectResult leadDescResult = Schema.SObjectType.Lead;
    private Schema.DescribeSObjectResult oppDescResult = Schema.SObjectType.Opportunity;
    private final static String CONTACT_RECORDTYPE_NAME = 'Standard Contact';
    private final static String LEAD_RECORDTYPE_NAME = 'Standard Lead';
    private final static String OPPORTYNITY_RECORDTYPE_NAME = Label.OPP_RT_SMALL;
    private final static String UKI_PRICEBOOK_NAME = 'Sage UKI Price Book';
    private final static String OPPORTUNITYLINEITEM_COMMERCIALISATION_MODE = 'Subscription';
    private final static String OPPORTUNITYLINEITEM_PRODUCT_DEPLOYMENT = 'Sage Cloud';
    private final static Integer OPPORTUNITYLINEITEM_QUANTITY = 1;
    private final static Integer OPPORTUNITYLINEITEM_NONRECURRING_REVENUE = 0;

    private final static String CLASSNAME = 'TetrisAccountManagerV2';
    private final static String BUY = 'Buy';

    /*
    * @description Method to fetch default billing address by userLocale
    * @param       userLocale   userLocale like "en_GB"
    * @return      Returns the data populated in a Custom Model class with the Address info
    */
    public TetrisAddressModel getDefaultBillTo(String userLocale) {
        TetrisAddressModel billToAddress = new TetrisAddressModel();
        Tetris_Locale_Default_Address__mdt tLocalAddressObj = getUserLocaleAddress(userLocale);
        if (tLocalAddressObj != null) {
            billToAddress.addressLine1 = ''; //tLocalAddressObj.addressLine1__c;
            billToAddress.addressLine2 = ''; //tLocalAddressObj.addressLine2__c!=null ? tLocalAddressObj.addressLine2__c : '';
            billToAddress.city = '';//tLocalAddressObj.city__c;
            billToAddress.state = ''; //tLocalAddressObj.state__c;
            billToAddress.country = tLocalAddressObj.country__c;
            billToAddress.postalCode = ''; //tLocalAddressObj.postalCode__c;
        }

        return billToAddress;
    }

    /*
    * @description Method to create an account in salesforce
    * @param       name                Account Name
    * @param       cartId              Encrypted ID for the Cart
    * @param       transactionType     Indicates "Try", "Buy", "Convert" flows
    * @param       salesOffice         SalesOffice
    * @param       userLocale          UserLocale like en_GB
    * @param       userCurrency        UserCurrency
    * @param       contact             Custom Model class with the Contact Related info
    * @param       billTo              Custom Model class with the Address Related info
    * @return      Returns newly created salesforce accountId.
    */
    public String createAccount(String userLocale, String name,
            String transactionType, String userCurrency,
            TetrisContactModel contact, TetrisAddressModel billTo) {
        Account accountInfo = new Account();
        try {
            accountInfo.Name = name;

            //populate the address only in cases where this information is passed as part of the payload
            //for default address where Country is the only information available, this needs to be ignored
            if ((billTo != null) && (billTo.city != null)) {

                if (billTo.addressLine2 != null) {
                    accountInfo.BillingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    accountInfo.BillingStreet = billTo.addressLine1;
                }
                accountInfo.BillingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                accountInfo.BillingCity = billTo.city;
                accountInfo.BillingState = billTo.state;
                accountInfo.BillingPostalCode = billTo.postalCode;

                if (billTo.addressLine2 != null) {
                    accountInfo.ShippingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    accountInfo.ShippingStreet = billTo.addressLine1;
                }
                accountInfo.ShippingCity = billTo.city;
                accountInfo.ShippingState = billTo.state;
                accountInfo.ShippingPostalCode = billTo.postalCode;

            }
            if (billTo != null) {
                accountInfo.BillingCountry = billTo.country;
                accountInfo.ShippingCountry = billTo.country;
            }

            accountInfo.CurrencyIsoCode = userCurrency;
            accountInfo.Phone = contact.phone;
            String accountType = 'Customer';
            if (transactionType.equalsIgnoreCase('try')) {
                accountType = 'Prospect';
            }
            //@Rishu Garg Docmation (EADAPPI-541)
            Set<String> industrySupportedTransTypes = new Set<String>{
                    'trial', 'unknown'
            };
            if (industrySupportedTransTypes.contains(transactionType)) {
                if (String.isNotBlank(contact.industry)) {
                    System.debug('TetrisAccountManager:createAccount: ' + contact.industry);
                    Map<String, String> industryPicklistMap = getIndustryPicklistFromAccount();
                    if (industryPicklistMap.containsKey(contact.industry)) {
                        accountInfo.Industry = contact.industry;
                    }
                }
            }
            accountInfo.Type = accountType;
            accountInfo.Locale_Billing_CC__c = userLocale.substring(3);

            Locale__c accountLocaleObj = fetchCountryLocale(userLocale);
            if (accountLocaleObj != null) {
                accountInfo.Sales_Office__c = accountLocaleObj.SalesOffice__c;
            }
            // @Rishu Garg Docmation
            accountInfo.Global_Id__c = String.ValueOf(Math.round((Math.random() * (900000) + 100000)) + Datetime.now().millisecond());
            insert accountInfo;
            if (accountLocaleObj != null) {
                accountInfo.Locale__c = accountLocaleObj.Id;
                update accountInfo;
            }

            return accountInfo.Id;
        } catch (Exception ex) {
            System.debug('TetrisAccountManager: createAccount: exception ' + ex.getMessage());
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_ACCOUNT);
        }
    }

    /*
    * @description Method to fetch an account by accountId
    * @param       accountId       salesforce Account Id.
    * @return      Returns the data populated in a Custom Model class with the Account info
    */
    public TetrisAccountModel getAccount(String accountId) {
        Account acct = [SELECT Id, Name, Sales_Office__c FROM Account WHERE Id = :accountId LIMIT 1];
        TetrisAccountModel accountModel = new TetrisAccountModel();
        accountModel.accountId = acct.Id;
        accountModel.accountName = acct.Name;
        accountModel.salesOffice = acct.Sales_Office__c;

        try {
            Zuora__CustomerAccount__c billingAccount = [select id, Zuora__AccountNumber__c, Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c = :accountId LIMIT 1];
            if (billingAccount != null) {
                accountModel.zuoraAccountId = billingAccount.id;
                accountModel.zuoraAccountNumber = billingAccount.Zuora__AccountNumber__c;
                accountModel.zuoraId = billingAccount.Zuora__Zuora_Id__c;

            }
        } catch (Exception ex) {
            // Deliberately swallowing this exception.
            // A QueryException is thrown when the query intended to return a billingAccount returns no records
            // TODO The alternative to consider is to get that query to return List<Zuora__CustomerAccount__c>
        }
        return accountModel;
    }

    /*
    * @description Method to fetch an account by accountId
    * @param       acct       salesforce Account object.
    * @param       vatNumber     vat number.
    * @return      Returns the data populated in a Custom Model class with the Account info
    */
    public Account updateVATNumber(Account acct, String vatNumber) {
        //Account acct =  [SELECT Id, Name, VAT_Number__c FROM Account WHERE Id =: accountId LIMIT 1];
        if (acct != null) {
            acct.VAT_Number__c = vatNumber;
            //update acct;
        }

        return acct;
    }

    /*
     * @description Method that invokes creation of account,contact,opportunity and lead in salesforce
     * @param       name                Account Name
     * @param       cartId              Encrypted ID for the Cart (deprecated for CC replacement)
     * @param       transactionType     Indicates "Try", "Buy", "Convert" flows
     * @param       salesOffice         SalesOffice (deprecated for CC replacement)
     * @param       leadCreation        Boolean to indicate lead creation (set to false in Tetris by default)
     * @param       userLocale          UserLocale like en_GB
     * @param       userCurrency        UserCurrency
     * @param       contactModel             Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @return      Returns the data populated in a Custom Model class with the Account info
     */
    public TetrisAccountResultModel invokeNewAccountFlow(String name, String cartId, boolean leadCreation,
            String transactionType, String salesOffice, String userLocale,
            String userCurrency, TetrisContactModel contactModel, TetrisAddressModel billTo, boolean emailOptin, boolean createOpportunity) {

        TetrisAccountResultModel accountResult = new TetrisAccountResultModel();

        if (billTo == null) {
            billTo = getDefaultBillTo(userLocale);
        }

        // initialise defaultProduct (not set for CC replacement; abandoned cart handling will be in Sitecore XC)
        String defaultProduct = '';

        System.debug('TetrisAccountManager: create account without default billTo');
        String accountId = createAccount(userLocale, name, transactionType, userCurrency, contactModel, billTo);
        accountResult.accountId = accountId;

        System.debug('TetrisAccountManager: create contact without default billTo');
        String contactId = createContact(accountId, userLocale, contactModel, billTo, defaultProduct, emailOptin);
        accountResult.contactId = contactId;

        String leadId = '';
        String opportunityId = '';
        if (leadCreation) {
            System.debug('TetrisAccountManager: create Lead without default billTo');

            Locale__c accountLocaleObj = fetchCountryLocale(userLocale);
            if (accountLocaleObj != null) {
                salesOffice = accountLocaleObj.SalesOffice__c;
            }
            leadId = createLead(name, salesOffice, userCurrency, contactModel, billTo, defaultProduct, emailOptin);
            accountResult.leadId = leadId;
        }

        if (createOpportunity) {
            opportunityId = createOpportunity(name, accountId, userCurrency, defaultProduct, transactionType);
            // Added Code to Insert Opportunity Contact Roles to Fix ECOM-1072
            OpportunityContactRole oppContactRole = new OpportunityContactRole(OpportunityId = opportunityId, ContactId = contactId, Role = 'Influencer', IsPrimary = true);
            insert oppContactRole;
            accountResult.opportunityId = opportunityId;
        }

        System.debug('TetrisAccountManager: update Account and Contact info on Cart');

        accountResult.setStatus(true);
        return accountResult;
    }

    /*
     * @description Method to create contact in salesforce
     * @param       accountId           Salesforce Account Id
     * @param       contactInfo         Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @return      Returns a newly created Salesfoce Contact Id
     */
    public string createContact(String accountId, String userLocale, TetrisContactModel contactInfo, TetrisAddressModel billTo, String defaultProduct, boolean emailOptin) {

        try {
            Map<String, Schema.RecordTypeInfo> rtMapByName = contactDescResult.getRecordTypeInfosByName();
            Schema.RecordTypeInfo contactRecordTypeInfo = rtMapByName.get(CONTACT_RECORDTYPE_NAME);
            Contact ct = new Contact();
            ct.AccountId = accountId;
            //Added to add Language of the Contact
            Locale__c contactLocaleObj = fetchCountryLocale(userLocale);
            if (contactLocaleObj != null) {
                ct.Language__c = contactLocaleObj.Language__c;
                ct.Locale__c = contactLocaleObj.Id;
            }
            ct.FirstName = contactInfo.firstName;
            ct.LastName = contactInfo.lastName;
            ct.RecordTypeId = contactRecordTypeInfo.getRecordTypeId();
            if ((billTo != null) && (billTo.city != null)) {
                ct.MailingCity = billTo.city;
                ct.MailingCountry = billTo.country;
                ct.MailingPostalCode = billTo.postalCode;
                ct.MailingState = billTo.state;
                if (billTo.addressLine2 != null) {
                    ct.MailingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    ct.MailingStreet = billTo.addressLine1;
                }

            } else if ((billTo != null) && (billTo.country != null)) {
                ct.MailingCountry = billTo.country;
            }
            ct.Email = contactInfo.email;
            ct.Phone = contactInfo.phone;
            //Added for Abandoned Carts
            ct.Lead_Source__c = 'Marketing';
            ct.Product__c = defaultProduct;
            if (emailOptin == null)
                emailOptin = false;

            if (emailOptin) {
                ct.HasOptedOutOfEmail = false;
                //Added GDPR fields
                ct.GDPR__c = 'New';
                ct.GDPR_Text__c = Label.GDPR_Yes_Text;
            } else {
                ct.HasOptedOutOfEmail = true;
                //Added GDPR fields
                ct.GDPR__c = 'No';
                ct.GDPR_Text__c = '';

            }
            // @Rishu Garg Docmation
            ct.Global_Id__c = String.ValueOf(Math.round((Math.random() * (900000) + 100000)) + Datetime.now().millisecond());

            //EAD-881, the Email_Opt_Out_LMT__c should not be set on the Contact or Lead Objects by Tetris EVER
            //ct.Email_Opt_Out_LMT__c = System.now();

            insert ct;
            return ct.id;

        } catch (Exception ex) {
            System.debug('TetrisAccountManager: createContact: exception ' + ex.getMessage());
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_CONTACT);
        }
    }
    /*
         * @description Method to create lead in salesforce
         * @param       accountName         Account Name
         * @param       salesOffice         SalesOffice
         * @param       userCurrency        UserCurrency
         * @param       contactInfo         Custom Model class with the Contact Related info
         * @param       billTo              Custom Model class with the Address Related info
         * @return      Returns newly created Salesforce Lead Id
         */
    public string createLead(String accountName, String salesOffice, String userCurrency, TetrisContactModel contactInfo, TetrisAddressModel billTo, String defaultProduct, boolean emailOptin) {
        try {
            Map<String, Schema.RecordTypeInfo> rtMapByName = leadDescResult.getRecordTypeInfosByName();
            Schema.RecordTypeInfo leadRecordTypeInfo = rtMapByName.get(LEAD_RECORDTYPE_NAME);
            Lead leadObject = new Lead();
            leadObject.FirstName = contactInfo.firstName;
            leadObject.LastName = contactInfo.lastName;

            if ((billTo != null) && (billTo.city != null)) {
                if (billTo.addressLine2 != null) {
                    leadObject.Street = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    leadObject.Street = billTo.addressLine1;
                }
                leadObject.City = billTo.city;
                leadObject.State = billTo.state;
                leadObject.PostalCode = billTo.postalCode;
                leadObject.Country = billTo.country;

            } else if ((billTo != null) && (billTo.country != null)) {
                leadObject.Country = billTo.country;
            }
            leadObject.Phone = contactInfo.phone;
            leadObject.Email = contactInfo.email;
            leadObject.Sales_Office__c = salesOffice;
            leadObject.Lead_Source__c = 'Marketing';
            //leadObject.Lead_Source_Most_Recent__c = 'Other';
            leadObject.Product__c = defaultProduct;
            leadObject.Status = 'Archived'; //Per ECOM-1169 changed from New to Archived
            leadObject.Status_Reason__c = 'Future Interest';
            leadObject.RecordTypeId = leadRecordTypeInfo.getRecordTypeId();
            leadObject.Company = accountName;
            leadObject.CurrencyIsoCode = userCurrency;
            leadObject.Other_Status_Reason__c = 'This lead was created from Tetris';
            leadObject.Lead_Source_Detail_Most_Recent__c = 'Abandoned Cart';
            if (emailOptin == null)
                emailOptin = false;
            if (emailOptin) {
                leadObject.HasOptedOutOfEmail = false;
                /*Added GDPR fields
                leadObject.GDPR__c='New';
                leadObject.GDPR_Text__c=Label.GDPR_Yes_Text; */
            } else {
                leadObject.HasOptedOutOfEmail = true;
                /*Added GDPR fields
                leadObject.GDPR__c='No';
                leadObject.GDPR_Text__c='';*/

            }

            //EAD-881, the Email_Opt_Out_LMT__c should not be set on the Contact or Lead Objects by Tetris EVER
            //leadObject.Email_Opt_Out_LMT__c = System.now();

            insert leadObject;

            //Added to convert the lead status to Qualified After lead creation on 01/29/2018
            /*   leadObject.Status_Reason__c ='Other - Please Specify';
               leadObject.Other_Status_Reason__c = 'This lead was created from Tetris';
               leadObject.Lead_Source_Detail_Most_Recent__c ='Abandoned Cart';
               leadObject.Status = 'Qualified';
               update leadObject;*/
            return leadObject.id;
        } catch (Exception ex) {
            System.debug('TetrisAccountManager: createLead: exception ' + ex.getMessage());
            List<Lead> duplicateLeads = [SELECT ID, NAME FROM LEAD WHERE STATUS = 'New' and Email = :contactInfo.email];
            if (duplicateLeads != null && duplicateLeads.size() > 0) {
                return duplicateLeads[0].id;
            }
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_LEAD + ': ' + ex.getMessage());
        }
    }


    /*
     * @description Method to create opportunity in salesforce
     * @param       accountName         Account Name
     * @param       accountId           Salesforce Account Id
     * @param       userCurrency        UserCurrency
     * @param       defaultProduct      Name of the product in the cart
     * @param       transactionType     Transaction type - e.g. buy/try
     * @return      Returns newly created salesforce opportunity Id
     */
    public string createOpportunity(String accountName, String accountId, String userCurrency, String defaultProduct, String transactionType) {
        try {
            Map<String, Schema.RecordTypeInfo> rtMapByName = oppDescResult.getRecordTypeInfosByName();
            Schema.RecordTypeInfo oppRecordTypeInfo = rtMapByName.get(OPPORTYNITY_RECORDTYPE_NAME);
            Opportunity opp = new Opportunity();
            opp.name = accountName;
            //opp.OwnerId = label.Tetris_Opportunity_OwnerId;
            opp.AccountId = accountId;
            //opp.Contact__c=contactId;
            opp.Type = 'New Business';
            opp.CurrencyIsoCode = userCurrency;
            opp.CloseDate = Date.today() + 30;
            if (BUY.equalsIgnoreCase(transactionType)) {
                //opp.StageName = 'Confirming Value';
                opp.StageName = 'Qualify';
            } else {
                opp.StageName = 'Discovery';
            }
            opp.Product__c = defaultProduct;
            opp.RecordTypeId = oppRecordTypeInfo.getRecordTypeId();
            opp.Lead_Source__c = 'Marketing';
            opp.Product_Solution__c = productSolution(defaultProduct);
            insert opp;

            if (defaultProduct != null && defaultProduct.length() > 0) {
                createOpportunityLineItem(defaultProduct, userCurrency, opp.id);
            }

            return opp.id;
        } catch (Exception ex) {
            System.debug('TetrisAccountManager: createOpportuntiy: exception ' + ex.getMessage());
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_OPPORTUNITY);

        }
    }

    /*
     * @description Method to create an OpportunityLineItem in Salesforce
     * @param       defaultProduct      Default Product Name (the name of the product in the cart)
     * @param       userCurrency        User's local currency, used to determine which pricebook entry to select (e.g. GBP or EUR)
     * @param       opportunityId       Opportunity Id (the opportunity that this lineitem will be added to)
     *
     * @ModifiedBy Rishu Garg
     * @ModifiedDate July 31 2020
     */
    public void createOpportunityLineItem(String defaultProduct, String userCurrency, String opportunityId) {
        try {
            LogControl.push('createOpportunityLineItem', TetrisAccountManagerV2.CLASSNAME);

            List<Pricebook2> pricebook2Ids = [SELECT Id FROM Pricebook2 WHERE Name = :UKI_PRICEBOOK_NAME];

            if (pricebook2Ids != null && pricebook2Ids.size() > 0) {
                String pricebook2Id = pricebook2Ids[0].Id;
                List<PricebookEntry> pricebookEntries = [
                        SELECT Id, IsActive
                        FROM PricebookEntry
                        WHERE
                        Name = :defaultProduct AND
                        Pricebook2Id = :pricebook2Id AND
                        CurrencyIsoCode = :userCurrency
                ];

                String pricebookEntryId = null;
                if (pricebookEntries != null && pricebookEntries.size() > 0) {

                    // @Rishu(EADAPPI-510) check for inactive pricebook entry
                    if (pricebookEntries[0].IsActive) {
                        pricebookEntryId = pricebookEntries[0].Id;
                        OpportunityLineItem oli = new OpportunityLineItem(
                                OpportunityId = opportunityId,
                                Commercialisation_Mode__c = OPPORTUNITYLINEITEM_COMMERCIALISATION_MODE,
                                Product_Deployment__c = OPPORTUNITYLINEITEM_PRODUCT_DEPLOYMENT,
                                Quantity = OPPORTUNITYLINEITEM_QUANTITY,
                                TotalPrice = OPPORTUNITYLINEITEM_NONRECURRING_REVENUE,
                                PricebookEntryId = pricebookEntryId);
                        insert oli;
                    } else {
                        System.debug('Price Book entry for ' + defaultProduct + ' product is deactivated in ' + UKI_PRICEBOOK_NAME + '. OpportunityLineItem could not be created.');
                        throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_OPPORTUNITYLINEITEM_INACTIVE_PRICEBOOK_ENTRY);
                    }
                } else {
                    System.debug(defaultProduct + ' product was not found in ' + UKI_PRICEBOOK_NAME + '. OpportunityLineItem could not be created.');
                }
            } else {
                System.debug('TetrisAccountManager: createOpportunityLineItem: could not find Price Book: ' + UKI_PRICEBOOK_NAME + ' - OpportunityLineItem could not be created.');
            }
        } catch (Exception ex) {
            System.debug('TetrisAccountManager: createOpportunityLineItem: exception ' + ex.getMessage());
            LogControl.debugException(ex);
            //throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_OPPORTUNITYLINEITEM);
        } finally {
            LogControl.pop();
        }
    }

    /*
     * @description Method that invokes updation of account,contact,opportunity and lead in salesforce
     * @param       name                 Account Name
     * @param       accountId            Salesforce Account Id
     * @param       cartId               Encrypted ID for the Cart (deprecated for CC replacement)
     * @param       leadCreation         Boolean to indicate lead creation (always false, except perhaps in tests)
     * @param       transactionType      Indicates "Try", "Buy", "Convert" flows
     * @param       salesOffice          SalesOffice
     * @param       userLocale           UserLocale like en_GB
     * @param       userCurrency         UserCurrency
     * @param       contactModel         Custom Model class with the Contact Related info
     * @param       billTo               Custom Model class with the Address Related info
     * @return      Returns the data populated in a Custom Model class with the Account info
     */
    public TetrisAccountResultModel invokeUpdateAccountFlow(String accountId, String name, String cartId,
            boolean leadCreation, String transactionType, String salesOffice, String userLocale,
            String userCurrency, TetrisContactModel contactModel, TetrisAddressModel billTo, boolean emailOptin) {

        TetrisAccountResultModel accountResult = new TetrisAccountResultModel();

        String defaultProduct = '';

        if ((!transactionType.equalsIgnoreCase('try')) && (!transactionType.equalsIgnoreCase('trial'))) {

            //Added to return zuoraAccountId if exists in the update Call 04/03
            List<Zuora__CustomerAccount__c> billingAccount = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c = :accountId LIMIT 1];
            if (billingAccount != null && billingAccount.size() > 0) {
                accountResult.zuoraAccountId = billingAccount[0].Zuora__Zuora_Id__c;
            }
        }

        updateAccount(accountId, name, transactionType, userCurrency, contactModel, billTo, userLocale);
        accountResult.accountId = accountId;
        if (contactModel.contactId == null) {
            String contactId = createContact(
                    accountId, userLocale, contactModel, billTo, defaultProduct, emailOptin);
            accountResult.contactId = contactId;
            contactModel.contactId = contactId;
        } else {
            updateContact(accountId, contactModel, billTo, emailOptin);
            accountResult.contactId = contactModel.contactId;
        }

        String newLeadId = '';
        String newOpportunityId = '';
        if (leadCreation) {
            newLeadId = createLead(name, salesOffice, userCurrency, contactModel, billTo, defaultProduct, emailOptin);
            accountResult.leadId = newLeadId;
            newOpportunityId = createOpportunity(name, accountId, userCurrency, defaultProduct, transactionType);
            accountResult.opportunityId = newOpportunityId;
        }

        TetrisAccountModel zAccount = getAccount(accountId);
        if (zAccount.zuoraAccountId != null) {
            accountResult.zuoraAccountId = zAccount.zuoraId;
        }

        /* @Rishu Garg(Docmation) CPQP-254 */
        List<Opportunity> oppList =
            [SELECT
                Id,
                StageName
            FROM Opportunity
            WHERE AccountId =: accountId AND StageName=: 'Discovery'
            ORDER BY CREATEDDATE DESC limit 1];
        if(!oppList.isEmpty()){
            accountResult.opportunityId = oppList[0].Id;
        }

        accountResult.setStatus(true);
        return accountResult;
    }

    /*
    * @description Method to update an account in salesforce
    * @param       accountId           salesforce Account Id
    * @param       name                Account Name
    * @param       transactionType     Indicates "Try", "Buy", "Convert" flows
    * @param       userCurrency        UserCurrency
    * @param       contact             Custom Model class with the Contact Related info
    * @param       billTo              Custom Model class with the Address Related info
    * @param       userLocale          UserLocale like en_GB
    * @return      Returns updated salesforce accountId.
    */
    public String updateAccount(String accountId, String name, String transactionType, String userCurrency,
            TetrisContactModel contact, TetrisAddressModel billTo, String userLocale) {

        Account accountInfo = [SELECT id FROM Account WHERE Id = :accountId LIMIT 1];
        try {
            System.debug('Country Locel ' + userLocale);
            Locale__c accountLocaleObj = fetchCountryLocale(userLocale);
            if (accountLocaleObj != null) {
                accountInfo.Locale__c = accountLocaleObj.Id;
                accountInfo.Sales_Office__c = accountLocaleObj.SalesOffice__c;
            }
            accountInfo.Locale_Billing_CC__c = userLocale.substring(3);
            if (!String.isBlank(name)) {
                accountInfo.Name = name;
            }
            if (billTo != null) {
                if (billTo.addressLine2 != null) {
                    accountInfo.BillingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    accountInfo.BillingStreet = billTo.addressLine1;
                }
                accountInfo.BillingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                accountInfo.BillingCity = billTo.city;
                accountInfo.BillingState = billTo.state;
                accountInfo.BillingCountry = billTo.country;
                accountInfo.BillingPostalCode = billTo.postalCode;

                if (billTo.addressLine2 != null) {
                    accountInfo.ShippingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    accountInfo.ShippingStreet = billTo.addressLine1;
                }
                accountInfo.ShippingCity = billTo.city;
                accountInfo.ShippingState = billTo.state;
                accountInfo.ShippingCountry = billTo.country;
                accountInfo.ShippingPostalCode = billTo.postalCode;
            }
            if (!String.isBlank(userCurrency)) {
                accountInfo.CurrencyIsoCode = userCurrency;
            }
            if (contact.phone != null) {
                accountInfo.Phone = contact.phone;
            }
            String accountType = 'Customer';
            if (transactionType.equalsIgnoreCase('try')) {
                accountType = 'Prospect';
            }
            accountInfo.Type = accountType;
            update accountInfo;

            return accountId;
        } catch (Exception ex) {
            System.debug('TetrisAccountManager: updateAccount: exception ' + ex.getMessage());
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_UPDATE_ACCOUNT);
        }
    }

    /*
    * @description Method to update a contact in salesforce
    * @param       accountId           Salesforce AccountId
    * @param       contactInfo             Custom Model class with the Contact Related info
    * @param       billTo              Custom Model class with the Address Related info
    * @return      Returns updated salesforce contactId.
    */
    public string updateContact(String accountId, TetrisContactModel contactInfo, TetrisAddressModel billTo, boolean emailOptin) {
        try {
            Contact ct = [SELECT Id FROM Contact WHERE Id = :contactInfo.contactId];
            ct.AccountId = accountId;
            if (!String.isBlank(contactInfo.firstName)) {
                ct.FirstName = contactInfo.firstName;
            }
            if (!String.isBlank(contactInfo.lastName)) {
                ct.LastName = contactInfo.lastName;
            }
            if (billTo != null) {
                ct.MailingCity = billTo.city;
                ct.MailingCountry = billTo.country;
                ct.MailingPostalCode = billTo.postalCode;
                ct.MailingState = billTo.state;
                if (billTo.addressLine2 != null) {
                    ct.MailingStreet = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    ct.MailingStreet = billTo.addressLine1;
                }

            }
            if (!String.isBlank(contactInfo.email)) {
                ct.Email = contactInfo.email;
            }
            if (!String.isBlank(contactInfo.phone)) {
                ct.Phone = contactInfo.phone;
            }
            if (emailOptin != null) {

                if (emailOptin) {
                    ct.HasOptedOutOfEmail = false;
                    //Added GDPR fields
                    ct.GDPR__c = 'New';
                    ct.GDPR_Text__c = Label.GDPR_Yes_Text;
                } else {
                    ct.HasOptedOutOfEmail = true;

                    //Added GDPR fields
                    ct.GDPR__c = 'No';
                    ct.GDPR_Text__c = '';
                }

                //EAD-881, the Email_Opt_Out_LMT__c should not be set on the Contact or Lead Objects by Tetris EVER
                //ct.Email_Opt_Out_LMT__c = System.now();

            }
            update ct;
            return ct.Id;

        } catch (Exception ex) {
            System.debug('TetrisAccountManager: updateContact: exception ' + ex.getMessage());
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_UPDATE_CONTACT);
        }
    }


    /*
         * @description Method to create lead in salesforce
         * @param       accountName         Account Name
         * @param       salesOffice         SalesOffice
         * @param       userCurrency        UserCurrency
         * @param       contactInfo         Custom Model class with the Contact Related info
         * @param       billTo              Custom Model class with the Address Related info
         * @return      Returns newly created Salesforce Lead Id
         */
    public string updateLead(String leadId, String accountName, String salesOffice, String userCurrency, TetrisContactModel contactInfo, TetrisAddressModel billTo,
            String defaultProduct, boolean emailOptin) {
        try {
            Map<String, Schema.RecordTypeInfo> rtMapByName = leadDescResult.getRecordTypeInfosByName();
            Schema.RecordTypeInfo leadRecordTypeInfo = rtMapByName.get(LEAD_RECORDTYPE_NAME);
            Lead leadObject = [SELECT ID, NAME, FirstName, LastName, Street, City, State, PostalCode, Country, Phone, Email, Sales_Office__c, Lead_Source__c, Product__c, Email_Opt_Out_LMT__c, Do_Not_Mail__c, Company, Lead_Source_Detail_Most_Recent__c, CurrencyIsoCode, Other_Status_Reason__c FROM LEAD WHERE Id = :leadId];
            leadObject.FirstName = contactInfo.firstName;
            leadObject.LastName = contactInfo.lastName;

            if ((billTo != null) && (billTo.city != null)) {
                if (billTo.addressLine2 != null) {
                    leadObject.Street = billTo.addressLine1 + '\r\n' + billTo.addressLine2;
                } else {
                    leadObject.Street = billTo.addressLine1;
                }
                leadObject.City = billTo.city;
                leadObject.State = billTo.state;
                leadObject.PostalCode = billTo.postalCode;
                leadObject.Country = billTo.country;

            } else if ((billTo != null) && (billTo.country != null)) {
                leadObject.Country = billTo.country;
            }
            leadObject.Phone = contactInfo.phone;
            leadObject.Email = contactInfo.email;
            leadObject.Sales_Office__c = salesOffice;
            leadObject.Lead_Source__c = 'Marketing';
            //leadObject.Lead_Source_Most_Recent__c = 'Other';
            leadObject.Product__c = defaultProduct;
            leadObject.RecordTypeId = leadRecordTypeInfo.getRecordTypeId();
            leadObject.Company = accountName;
            leadObject.CurrencyIsoCode = userCurrency;
            leadObject.Other_Status_Reason__c = 'This lead was created from Tetris';
            leadObject.Lead_Source_Detail_Most_Recent__c = 'Abandoned Cart';
            if (emailOptin != null) {
                if (emailOptin) {
                    leadObject.HasOptedOutOfEmail = false;
                    /*Added GDPR fields
                    leadObject.GDPR__c='New';
                    leadObject.GDPR_Text__c=Label.GDPR_Yes_Text; */
                } else {
                    leadObject.HasOptedOutOfEmail = true;
                    /*Added GDPR fields
                    leadObject.GDPR__c='No';
                    leadObject.GDPR_Text__c=''; */

                }

                //EAD-881, the Email_Opt_Out_LMT__c should not be set on the Contact or Lead Objects by Tetris EVER
                //leadObject.Email_Opt_Out_LMT__c = System.now();

            }

            update leadObject;

            return leadObject.id;
        } catch (Exception ex) {
            System.debug('TetrisAccountManager: createLead: exception ' + ex.getMessage());
            Lead duplicateLead = [SELECT ID, NAME FROM LEAD WHERE STATUS = 'New' and Email = :contactInfo.email];
            if (duplicateLead != null) {
                return duplicateLead.id;
            }
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_CREATE_LEAD);
        }
    }


    /*
     * @description Method to fetch Contact Info by ContactId
     * @param       contactId           Salesforce Contact Id
     * @return      Returns the data populated in a Custom Model class with the Contact info.
     */
    public TetrisContactModel getContact(String contactId) {
        try {
            Contact ct = [SELECT Id, FirstName, LastName,MailingCity,MailingCountry,MailingPostalCode, MailingState, MailingStreet, Email, Phone, Do_Not_Mail__c, Email_Opt_Out_LMT__c FROM Contact WHERE Id = :contactId];
            TetrisContactModel contactInfo = new TetrisContactModel();
            contactInfo.contactId = ct.Id;
            contactInfo.firstName = ct.FirstName;
            contactinfo.lastName = ct.LastName;
            contactInfo.email = ct.Email;
            contactInfo.phone = ct.Phone;
            contactInfo.streetAddress = ct.MailingStreet;
            contactInfo.city = ct.MailingCity;
            contactInfo.state = ct.MailingState;
            contactInfo.country = ct.MailingCountry;
            contactInfo.postalCode = ct.MailingPostalCode;
            contactInfo.emailOptout = ct.Do_Not_Mail__c;

            //EAD-881, the Email_Opt_Out_LMT__c should not be set on the Contact or Lead Objects by Tetris EVER
            if (ct.Email_Opt_Out_LMT__c != null)
                contactInfo.optInOutTime = ct.Email_Opt_Out_LMT__c;

            return contactInfo;

        } catch (Exception ex) {
            System.debug('TetrisAccountManager: getContact: contactId ' + contactId + ' - Exception ' + ex.getMessage());
            throw new TetrisAccountException(TetrisAccountException.EXCEPTION_UPDATE_CONTACT);
        }
    }

    /*
    * @description Method to fetch country locale Info by countryLocale
    * @param       strCountryLocale    Country Locale
    * @return      Returns Locale Object.
    */
    public Locale__c fetchCountryLocale(String strCountryLocale) {
        Locale__c localeObject = null;
        List<Locale__c> lstLocale = [Select id,Name,Language__c,SalesOffice__c,Country_Code__c from Locale__c where name = :strCountryLocale];

        if (lstLocale != null && lstLocale.size() > 0) {
            localeObject = lstLocale[0];
        }
        return localeObject;
    }

    /*
     * @description Method to fetch default address by passing User Locale
     * @param       userLocale   User Locale
     * @return      Returns default Address Metadata.
     */
    public Tetris_Locale_Default_Address__mdt getUserLocaleAddress(String userLocale) {
        Tetris_Locale_Default_Address__mdt tetrisLocaleAddress = null;
        List<Tetris_Locale_Default_Address__mdt> lstLocaleAddress = [
                SELECT DeveloperName, AddressLine1__c,
                        AddressLine2__c, City__c, Country__c,PostalCode__c,State__c
                FROM
                        Tetris_Locale_Default_Address__mdt
                WHERE DeveloperName = :userLocale
        ];
        if (lstLocaleAddress != null && lstLocaleAddress.size() > 0) {
            tetrisLocaleAddress = lstLocaleAddress[0];
        }
        return tetrisLocaleAddress;
    }

    public String productSolution(String product) {
        if (product == null) {
            return '';
        } else if (product.contains('Sage Business Cloud Accounting')) {
            return 'Accounts';
        } else if (product.equals('Sage Business Cloud Payroll')) {
            return 'Payroll';
        } else {
            return '';
        }
    }

    /*
    * @description Method to fetch picklist from industry field of Account
    * @return Returns Map of Industry picklist from Account.
    */
    public Map<String, String> getIndustryPicklistFromAccount() {
        Schema.DescribeFieldResult fieldResult = Account.Industry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String, String> picklistValueMap = new Map<String, String>();
        for (Schema.PicklistEntry f : ple) {
            picklistValueMap.put(f.getLabel(), f.getValue());
        }
        return picklistValueMap;
    }
}