/*
***Getting started:
***First create Apex class in the refreshed sandbox with the code in this file
***From Developer Console, execute the following code in the Anonymous window
   Step 0. If there are any old Product Tier/Pricing records
           SageApiSandboxRefreshDataReload.DeleteAll();
   Step 1. Create Product Tiers / Pricing Codes
           SageApiSandboxRefreshDataReload.LoadStep1();
   Step 2. Create Pricing Code Rate Plans, and publish
           SageApiSandboxRefreshDataReload.LoadStep2();
*/

public with sharing class SageApiSandboxRefresh {
    public static void LoadStep1()
    {
        System.debug('++++LoadAccountingProductTiers starts ...');
        ProductTierData productTierData = new ProductTierData();
        List<Product_Tier__c> accountingProductTiers = productTierData.LoadAccountingProductTiers();

        if (accountingProductTiers == null || accountingProductTiers.isEmpty()) {
            System.debug('++++No Accounting product tiers loaded');
            return;
        }

        System.debug('++++Accounting product tiers loaded: '+String.valueOf(accountingProductTiers.size()));

        System.debug('++++LoadStartProductTiers starts ...');
        List<Product_Tier__c> startProductTiers = productTierData.LoadStartProductTiers(accountingProductTiers);

        if (startProductTiers == null || startProductTiers.isEmpty()){
            System.debug('++++No Start product tiers loaded');
            return;
        }

        System.debug('++++Start product tiers loaded: '+String.valueOf(startProductTiers.size()));

        System.debug('++++LoadAccountingProductTierRatePlans starts ...');
        ProductTierRatePlanData productTierRatePlanData = new ProductTierRatePlanData();

        List<Product_Tier__c> allProductTiers = new List<Product_Tier__c>();
        allProductTiers.addAll(accountingProductTiers);
        allProductTiers.addAll(startProductTiers);

        List<Product_Tier_Rate_Plan__c> accountingProductTierRatePlans = productTierRatePlanData.LoadAccountingProductTierRatePlans(allProductTiers);

        if (accountingProductTierRatePlans == null || accountingProductTierRatePlans.isEmpty()) {
            System.debug('++++No Accounting product tier rate plans loaded');
            return;
        }

        System.debug('++++Accounting product tier rate plans loaded: '+String.valueOf(accountingProductTierRatePlans.size()));

        System.debug('++++LoadStartProductTierRatePlans starts ...');

        List<Product_Tier_Rate_Plan__c> startProductTierRatePlans = productTierRatePlanData.LoadStartProductTierRatePlans(allProductTiers, accountingProductTierRatePlans);

        if (startProductTierRatePlans == null || startProductTierRatePlans.isEmpty()) {
            System.debug('++++No Start product tier rate plans loaded');
            return;
        }

        System.debug('++++Start product tier rate plans loaded: '+String.valueOf(startProductTierRatePlans.size()));

        System.debug('++++LoadPricingCodes starts ...');

        List<Product_Tier_Rate_Plan__c> allProductTierRatePlans = new List<Product_Tier_Rate_Plan__c>();
        allProductTierRatePlans.addAll(accountingProductTierRatePlans);
        allProductTierRatePlans.addAll(startProductTierRatePlans);

        PricingData pricingData = new PricingData();
        List<PricingCode__c> pricingCodes = pricingData.LoadPricingCodes(allProductTiers, allProductTierRatePlans);

        if (pricingCodes == null || pricingCodes.isEmpty()) {
            System.debug('++++No pricing codes loaded');
            return;
        }

        System.debug('++++Pricing codes loaded: '+String.valueOf(pricingCodes.size()));

        /*
        System.debug('++++LoadPricingCodeCharges starts ...');
        List<PricingCodeCharge__c> pricingCodeCharges = pricingData.LoadPricingCodeCharges();

        if (pricingCodeCharges == null || pricingCodeCharges.isEmpty()) {
            System.debug('++++No pricing code charges loaded');
            return;
        }

        System.debug('++++Pricing code charges loaded: '+String.valueOf(pricingCodeCharges.size()));
        */
    }

    public static void LoadStep2()
    {
        System.debug('++++LoadPricingCodeCharges starts ...');
        PricingData pricingData = new PricingData();
        List<PricingCodeCharge__c> pricingCodeCharges = pricingData.LoadPricingCodeCharges();

        if (pricingCodeCharges == null || pricingCodeCharges.isEmpty()) {
            System.debug('++++No pricing code charges loaded');
            return;
        }

        System.debug('++++Pricing code charges loaded: '+String.valueOf(pricingCodeCharges.size()));
    }

    public static void VerifySendToZBillingStep1()
    {
        TestSendToZBilling();
    }

    public static void DeleteAll(){
        //Disable trigger validation first
        CBC_Application_Control__c control = [SELECT Name,Id,Run_Triggers__c FROM CBC_Application_Control__c WHERE SetupOwnerId IN (SELECT Id FROM Organization WHERE Name='Sage')];
        if (control ==  null)
            return;
        control.Run_Triggers__c = false;
        update control;

        System.debug('++++DeleteAll starts ...');
        DELETE [SELECT Id FROM PricingCodeCharge__c WHERE IsDeleted=FALSE];
        System.debug('++++Deleted PricingCodeCharge__c ...');
        DELETE [SELECT Id FROM PricingCode__c WHERE IsDeleted=FALSE];
        System.debug('++++Deleted PricingCode__c ...');
        DELETE [SELECT Id FROM Product_Tier_Rate_Plan__c WHERE IsDeleted=FALSE];
        System.debug('++++Deleted Product_Tier_Rate_Plan__c ...');
        DELETE [SELECT Id FROM Product_Tier__c WHERE IsDeleted=FALSE];
        System.debug('++++Deleted Product_Tier__c ...');

        //Re-enable trigger validation
        control.Run_Triggers__c = true;
        update control;
    }

    private static void TestSendToZBilling()
    {
        String reqStr = '{\n' +
                '  "startDate": "2021-01-13",\n' +
                '  "endDate": "2021-02-13",\n' +
                '  "legacyUpgradeFrom": "",\n' +
                '  "referrerPromotion": null,\n' +
                '  "contact": {\n' +
                '    "identityType": "SageID",\n' +
                '    "identityId": "e0cbdd9c-de7f-446f-b519-ffe04036ee19",\n' +
                '    "leadId": null,\n' +
                '    "firstName": "Test",\n' +
                '    "lastName": "SendToZBilling",\n' +
                '    "email": "test2zbilling@testing.com",\n' +
                '    "phone": "1234567890",\n' +
                '    "address1": "C. Aristides Maillol",\n' +
                '    "address2": "s/n",\n' +
                '    "city": "Barcelona",\n' +
                '    "county": null,\n' +
                '    "postalCode": "08028",\n' +
                '    "state": "",\n' +
                '    "countryCode": "ES"\n' +
                '  },\n' +
                '  "account": {\n' +
                '    "name": "SendToZBilling Test",\n' +
                '    "phone": "1234567890",\n' +
                '    "address1": "C. Aristides Maillol",\n' +
                '    "address2": "s/n",\n' +
                '    "city": "Barcelona",\n' +
                '    "state": "",\n' +
                '    "countryCode": "ES",\n' +
                '    "postalCode": "08028",\n' +
                '    "currencyCode": "EUR",\n' +
                '    "vatNumber": null\n' +
                '  },\n' +
                '  "products": [\n' +
                '    {\n' +
                '      "tierCode": "SageOne-Accounting-ES",\n' +
                '      "tierRatePlanCode": "Monthly",\n' +
                '      "pricingCode": null\n' +
                '    }\n' +
                '  ],\n' +
                '  "tryNowCompletionNotifyUrl": null,\n' +
                '  "payNowCompletionNotifyUrl": null,\n' +
                '  "payNowSuccessRedirectUrl": "https://sage-commerce-dev2-a.azurewebsites.net/Demo/PaymentSuccess",\n' +
                '  "payNowErrorRedirectUrl": "https://sage-commerce-dev2-a.azurewebsites.net/Demo/PaymentFailure",\n' +
                '  "version": null\n' +
                '}';
        SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(reqStr, SageApiTryNowActivityRequest.class);
        req.startDate = Datetime.now().format('yyyy-MM-dd');
        req.endDate = Datetime.now().addMonths(12).format('yyyy-MM-dd');
        //String key = GuidUtil.NewGuid();
        //SageApiActivity__c activity = new SageApiActivity__c(Name=key, ActivityID__c='BuyNow:'+key, ActivityType__c='BuyNow', ActivityStatus__c='Unknown', Payload__c=JSON.serialize(req));
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        Locale__c locale = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, BillingBatch__c, SalesOffice__c FROM Locale__c WHERE Default_Locale__c = 'Yes' AND Country_Code__c='ES' AND IsDeleted = false];
        List<Product_Tier__c> listTierData = SageApiActivityUtils.getProductTiers(req.products);
        if (listTierData == null || listTierData.isEmpty())
            throw new CustomException('------Product tier not found');

        Product_Tier__c productTier = listTierData[0];

        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(req.products);
        Product_Tier_Rate_Plan__c tierData = listTierMap.get(req.products[0].tierCode+':'+req.products[0].tierRatePlanCode);
        if (tierData == null)
            throw new CustomException('------Product tier rate plan not found');

        Lead lead = new Lead(RecordTypeId=recordTypeId,FirstName=req.contact.firstName,LastName=req.contact.lastName,Company=req.account.name,Email=req.contact.email,Phone=req.account.phone,Street=req.account.address1+(String.isBlank(req.account.address2) ? '' : '\n'+req.account.address2),
                City=req.account.city,StateCode=req.account.state,PostalCode=req.account.postalCode,CountryCode=req.account.countryCode,Sales_Office__c=locale.SalesOffice__c,CurrencyIsoCode=locale.CurrencyIsoCode,Product__c=productTier.SageProduct__c);
        INSERT lead;
        //activity.Lead__c = lead.Id;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setOpportunityName(lead.Name);
        lc.setConvertedStatus('Qualified');

        Database.LeadConvertResult leadResult = Database.convertLead(lc);
        if (!leadResult.success)
            throw new CustomException('------Lead Conversion failed:'+leadResult.getErrors());

        Account acct = new Account(id=leadResult.accountId, Locale__c=locale.Id, Sales_Office__c=locale.SalesOffice__c, Type='Customer');
        UPDATE acct;

        //activity.Account__c = leadResult.accountId;
        //activity.Opportunity__c = leadResult.opportunityId;
        //activity.Contact__c = leadResult.contactId;

        zqu__Quote_Template__c qTemplate = [SELECT Country_Code__c,Country__c,Language__c,zqu__IsDefault__c,zqu__Quote_Type__c,zqu__Template_Id__c FROM zqu__Quote_Template__c WHERE zqu__Quote_Type__c='New Subscription' AND Country_Code__c = 'ES' AND Name LIKE '%New Subscription' AND language__c =: locale.Language__c LIMIT 1];
        zqu__Quote__c quote = new zqu__Quote__c(Name='Test SendToZBilling', zqu__Opportunity__c=leadResult.opportunityId, zqu__Account__c=leadResult.accountId, zqu__BillToContact__c=leadResult.contactId, zqu__SoldToContact__c=leadResult.contactId, zqu__Is_Charge_Expired__c=false, zqu__PaymentTerm__c='Due Upon Receipt',
                zqu__StartDate__c=Date.valueOf(req.startDate), zqu__ValidUntil__c=Date.valueOf(req.startDate), zqu__PaymentMethod__c='Credit Card',zqu__ElectronicPaymentMethodId__c='8ef611a0a1584b03a20a84758f544e46', zqu__QuoteTemplate__c=qTemplate.Id, zqu__BillingBatch__c=locale.BillingBatch__c,
                zqu__Currency__c=locale.CurrencyIsoCode, zqu__Subscription_Term_Type__c = tierData.Term_Type__c);

        INSERT quote;

        System.debug('Calling SendToZBilling ...');
        SendToZBilling(quote.Id, tierData.Product_Rate_Plan__c, 'PayNow-SageOne');
    }

    @future(callout=true)
    private static void SendToZBilling(string quoteId, string ratePlanId, string clientCode)
    {
        zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quoteId, ratePlanId);
        chargeGroup = zqu.ZQuoteUtil.addChargeGroup(chargeGroup);

        //String msg = SendToZBillingUtils.callZQuoteGlobal(quoteId, clientCode);
        //System.debug('------SendToZBilling result: '+msg);
    }

    public class ProductTierData
    {
        public List<Product_Tier__c> LoadAccountingProductTiers()
        {
            System.debug('LoadAccountingProductTiers starts ...');

            ZuoraData zuoraData = new ZuoraData();
            Id productId = zuoraData.LookupProductIdByName('Sage Business Cloud Accounting');
            if (productId == null)
            {
                System.debug('Zuora product not found for Sage Business Cloud Accounting');
                return null;
            }

            List<Product_Tier__c> productTiers = new List<Product_Tier__c> {
                    new Product_Tier__c(CurrencyIsoCode='USD',CurrencySymbol__c='$',EntitlementProductIdentifier__c='SageOneAccounting',Name='Sage One Accounting US',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Accounting-US',Product_Use_Region__c='US - United States',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30),
                    new Product_Tier__c(CurrencyIsoCode='EUR',CurrencySymbol__c='€',EntitlementProductIdentifier__c='SageOneAccountingFR',Name='Sage One Accounting FR',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Accounting-FR',Product_Use_Region__c='FR - France',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30),
                    new Product_Tier__c(CurrencyIsoCode='EUR',CurrencySymbol__c='€',EntitlementProductIdentifier__c='SageOneAccountingES',Name='Sage One Accounting ES',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Accounting-ES',Product_Use_Region__c='ES - Spain',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30),
                    new Product_Tier__c(CurrencyIsoCode='EUR',CurrencySymbol__c='€',EntitlementProductIdentifier__c='SageOneAccountingDE',Name='Sage One Accounting DE',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Accounting-DE',Product_Use_Region__c='DE - Germany',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30),
                    new Product_Tier__c(CurrencyIsoCode='CAD',CurrencySymbol__c='$',EntitlementProductIdentifier__c='SageOneAccountingCA',Name='Sage One Accounting CA',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Accounting-CA',Product_Use_Region__c='CA - Canada',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30)
            };

            insert productTiers;
            System.debug('LoadAccountingProductTiers succeeded ...');

            return productTiers;
        }

        public List<Product_Tier__c> LoadStartProductTiers(List<Product_Tier__c> accountingProductTiers)
        {
            System.debug('LoadStartProductTiers starts ...');

            ZuoraData zuoraData = new ZuoraData();
            Id productId = zuoraData.LookupProductIdByName('Sage Business Cloud Accounting Start');
            if (productId == null)
            {
                System.debug('Zuora product not found for Sage Business Cloud Accounting Start');
                return null;
            }

            Id usProductTierId = LookupProductTierIdByTierCode(accountingProductTiers, 'SageOne-Accounting-US');
            Id frProductTierId = LookupProductTierIdByTierCode(accountingProductTiers, 'SageOne-Accounting-FR');
            Id esProductTierId = LookupProductTierIdByTierCode(accountingProductTiers, 'SageOne-Accounting-ES');
            Id deProductTierId = LookupProductTierIdByTierCode(accountingProductTiers, 'SageOne-Accounting-DE');

            List<Product_Tier__c> productTiers = new List<Product_Tier__c> {
                    new Product_Tier__c(CurrencyIsoCode='USD',CurrencySymbol__c='$',EntitlementProductIdentifier__c='SageOneStart',Name='Sage One Start US',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Start-US',Product_Use_Region__c='US - United States',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30,UpgradeToProductTier__c=usProductTierId),
                    new Product_Tier__c(CurrencyIsoCode='EUR',CurrencySymbol__c='€',EntitlementProductIdentifier__c='SageOneStartFR',Name='Sage One Start FR',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Start-FR',Product_Use_Region__c='FR - France',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30,UpgradeToProductTier__c=frProductTierId),
                    new Product_Tier__c(CurrencyIsoCode='EUR',CurrencySymbol__c='€',EntitlementProductIdentifier__c='SageOneStartES',Name='Sage One Start ES',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Start-ES',Product_Use_Region__c='ES - Spain',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30,UpgradeToProductTier__c=esProductTierId),
                    new Product_Tier__c(CurrencyIsoCode='EUR',CurrencySymbol__c='€',EntitlementProductIdentifier__c='SageOneStartDE',Name='Sage One Start DE',PayNow_PageType__c='sageone',Product_Tier_Code__c='SageOne-Start-DE',Product_Use_Region__c='DE - Germany',SageProduct__c='GL - Sage One',Product__c=productId,Payment_Grace_Period__c=3,Trial_Period__c=30,UpgradeToProductTier__c=deProductTierId)
            };

            insert productTiers;
            System.debug('LoadStartProductTiers succeeded ...');

            return productTiers;
        }

        public Id LookupProductTierIdByTierCode(List<Product_Tier__c> productTiers, string tierCode)
        {
            Integer matched = 0;
            Id matchedId = null;

            for(Product_Tier__c p : productTiers)
            {
                if (p.Product_Tier_Code__c != tierCode)
                    continue;

                matched++;
                matchedId = p.Id;
            }

            if (matched == 0)
                throw new CustomException('ProductTierData.LookupProductTierIdByTierCode: failed for ' + tierCode);
            if (matched > 1)
                throw new CustomException('ProductTierData.LookupProductTierIdByTierCode: multiple Product Tier records returned for ' + tierCode);

            return matchedId;
        }
    }

    public class ProductTierRatePlanData
    {

        public List<Product_Tier_Rate_Plan__c> LoadAccountingProductTierRatePlans(List<Product_Tier__c> allProductTiers)
        {
            System.debug('LoadAccountingProductTierRatePlans starts ...');

            ProductTierData productTierData = new ProductTierData();
            ProductTierRatePlanData productTierRatePlanData = new ProductTierRatePlanData();
            ZuoraData zuoraData = new ZuoraData();
            LocaleData localeData = new LocaleData();

            List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c> {
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-US'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','US - Accounting - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('en_US'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='USD'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-US'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','US - Accounting - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('en_US'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='USD'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','FR - Accounting - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('fr_FR'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','FR - Accounting - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('fr_FR'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','ES - Accounting - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('es_ES'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','ES - Accounting - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('es_ES'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-DE'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','DE - Accounting - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('de_DE'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-DE'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting','DE - Accounting - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('de_DE'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='EUR')
            };

            insert productTierRatePlans;
            System.debug('LoadAccountingProductTierRatePlans succeeded ...');

            return productTierRatePlans;
        }

        public List<Product_Tier_Rate_Plan__c> LoadStartProductTierRatePlans(List<Product_Tier__c> allProductTiers, List<Product_Tier_Rate_Plan__c> accountingProductTierRatePlans)
        {
            System.debug('LoadStartProductTierRatePlans starts ...');

            ProductTierData productTierData = new ProductTierData();
            ProductTierRatePlanData productTierRatePlanData = new ProductTierRatePlanData();
            ZuoraData zuoraData = new ZuoraData();
            LocaleData localeData = new LocaleData();

            List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c> {
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-US'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','US - Accounting Start - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('en_US'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='USD',UpgradeToProductTierRatePlan__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,accountingProductTierRatePlans,'SageOne-Accounting-US','Monthly')),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-US'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','US - Accounting Start - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('en_US'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='USD'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-FR'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','FR - Accounting Start - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('fr_FR'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='EUR',UpgradeToProductTierRatePlan__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,accountingProductTierRatePlans,'SageOne-Accounting-FR','Monthly')),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-FR'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','FR - Accounting Start - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('fr_FR'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-ES'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','ES - Accounting Start - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('es_ES'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='EUR',UpgradeToProductTierRatePlan__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,accountingProductTierRatePlans,'SageOne-Accounting-ES','Monthly')),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-ES'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','ES - Accounting Start - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('es_ES'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='EUR'),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-DE'),Name='Monthly',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','DE - Accounting Start - Monthly'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('de_DE'),Payment_Grace_Period__c=3,Trial_Period__c=30,Term_Type__c='Evergreen',CurrencyIsoCode='EUR',UpgradeToProductTierRatePlan__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,accountingProductTierRatePlans,'SageOne-Accounting-DE','Monthly')),
                    new Product_Tier_Rate_Plan__c(Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers, 'SageOne-Start-DE'),Name='Monthly-BuyNow',Product_Rate_Plan__c=ZuoraData.LookupProductRatePlanIdByName('Sage Business Cloud Accounting Start','DE - Accounting Start - Buy Now'),Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'),Locale__c=localeData.LookupLocaleIdByName('de_DE'),Payment_Grace_Period__c=3,Trial_Period__c=0,Term_Type__c='Evergreen',CurrencyIsoCode='EUR')
            };

            insert productTierRatePlans;
            System.debug('LoadStartProductTierRatePlans succeeded ...');

            return productTierRatePlans;
        }

        public Id LookupProductTierRatePlanIdByTierCode(List<Product_Tier__c> allProductTiers, List<Product_Tier_Rate_Plan__c> productTierRatePlans, string tierCode, string tierRatePlanCode)
        {
            ProductTierData productTierData = new ProductTierData();
            Id tierCodeId = productTierData.LookupProductTierIdByTierCode(allProductTiers, tierCode);
            if (tierCodeId == null)
                return null;

            Integer matched = 0;
            Id matchedId = null;

            for(Product_Tier_Rate_Plan__c rp : productTierRatePlans)
            {
                if (rp.Product_Tier__c != tierCodeId || rp.Name != tierRatePlanCode)
                    continue;

                matched++;
                matchedId = rp.Id;
            }

            if (matched == 0)
                throw new CustomException('ProductTierRatePlanData.LookupProductTierRatePlanIdByTierCode: failed for ' + tierCodeId + '|' + tierCodeId);
            if (matched > 1)
                throw new CustomException('ProductTierRatePlanData.LookupProductTierRatePlanIdByTierCode: multiple results returned for  ' + tierCodeId + '|' + tierCodeId);

            return matchedId;
        }
    }

    public class PricingData
    {
        public List<PricingCode__c> LoadPricingCodes(List<Product_Tier__c> allProductTiers, List<Product_Tier_Rate_Plan__c> allProductTierRatePlans)
        {
            System.debug('LoadPricingCodes starts ...');

            ProductTierData productTierData = new ProductTierData();
            ProductTierRatePlanData productTierRatePlanData = new ProductTierRatePlanData();

            List<PricingCode__c> pricingCodes = new List<PricingCode__c> {
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-US'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-US','Monthly'),Description__c='List Price',OriginalPriceTotal__c='10',PromotionalPriceTotal__c=null,Start_Date__c=Date.valueOf('2017-01-01'),End_Date__c=Date.valueOf('2099-12-31'), CurrencyIsoCode='USD', ProductSignupBaseUrl__c='https://pre-central.na.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-US'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-US','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='10',PromotionalPriceTotal__c='6.99',Promotional_Discount_Months__c=6, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='USD', ProductSignupBaseUrl__c='https://pre-central.na.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-FR','Monthly'),Description__c='List Price',OriginalPriceTotal__c='9',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-FR','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='9',PromotionalPriceTotal__c='6.75',Promotional_Discount_Months__c=3, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-ES','Monthly'),Description__c='List Price',OriginalPriceTotal__c='10',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-ES','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='10',PromotionalPriceTotal__c='7.5',Promotional_Discount_Months__c=3, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-DE'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-DE','Monthly'),Description__c='List Price',OriginalPriceTotal__c='8',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-DE'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-DE','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='8',PromotionalPriceTotal__c='0',Promotional_Discount_Months__c=1, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-US'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-US','Monthly'),Description__c='List Price',OriginalPriceTotal__c='25',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='USD', ProductSignupBaseUrl__c='https://pre-central.na.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-US'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-US','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='25',PromotionalPriceTotal__c='19.99',Promotional_Discount_Months__c=6, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='USD', ProductSignupBaseUrl__c='https://pre-central.na.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-FR','Monthly'),Description__c='List Price',OriginalPriceTotal__c='25',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-FR','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='25',PromotionalPriceTotal__c='12.50',Promotional_Discount_Months__c=3,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly'),Description__c='List Price',OriginalPriceTotal__c='20',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='15',Promotional_Discount_Months__c=3, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-DE'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-DE','Monthly'),Description__c='List Price',OriginalPriceTotal__c='14',PromotionalPriceTotal__c=null,Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='_LIST',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-DE'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-DE','Monthly-BuyNow'),Description__c='List Price',OriginalPriceTotal__c='14',PromotionalPriceTotal__c='0',Promotional_Discount_Months__c=1, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='ESFOUNDATION50',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly-BuyNow'),Description__c='50% discount forever',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='10',Start_Date__c=Date.ValueOf('2021-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='FRFOUNDATION50',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-FR','Monthly-BuyNow'),Description__c='50% discount forever',OriginalPriceTotal__c='25',PromotionalPriceTotal__c='12.5', Start_Date__c=Date.ValueOf('2021-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='DEFOUNDATION50',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-DE'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-DE','Monthly-BuyNow'),Description__c='50% discount forever',OriginalPriceTotal__c='14',PromotionalPriceTotal__c='7',Start_Date__c=Date.ValueOf('2021-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='10EUROSOFF6',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly-BuyNow'),Description__c='50% discount for 6 months',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='10',Promotional_Discount_Months__c=6, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='14EUROSOFF3',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly-BuyNow'),Description__c='70% discount for 3 months',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='6',Promotional_Discount_Months__c=3, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='20EUROSOFF2',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly-BuyNow'),Description__c='100% discount for 2 months',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='0',Promotional_Discount_Months__c=2, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='5EUROSOFF',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-FR','Monthly-BuyNow'),Description__c='5 Euro discount for HSBC',OriginalPriceTotal__c='25',PromotionalPriceTotal__c='20', Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='5EUROSOFF6',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Start-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Start-ES','Monthly-BuyNow'),Description__c='50% discount for 6 months',OriginalPriceTotal__c='10',PromotionalPriceTotal__c='5',Promotional_Discount_Months__c=6, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='6EUROSOFF',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly-BuyNow'),Description__c='6� off for 3 months',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='14',Promotional_Discount_Months__c=3, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='ES25PCTOFFTRIAL',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly'),Description__c='Special Pricing for some customers',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='15', Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='ES75PCTOFFTRIAL',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-ES'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-ES','Monthly'),Description__c='Special Pricing for some customers',OriginalPriceTotal__c='20',PromotionalPriceTotal__c='5', Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='FR25PCTOFF',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-FR','Monthly-BuyNow'),Description__c='6,25 EUR discount for Accountant Expert',OriginalPriceTotal__c='25',PromotionalPriceTotal__c='18.75', Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='FUJI',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-FR'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-FR','Monthly'),Description__c='Special Fuji upgrade price',OriginalPriceTotal__c='25',PromotionalPriceTotal__c='20', Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new'),
                    new PricingCode__c(Name='PAYROLL',Product_Tier__c=productTierData.LookupProductTierIdByTierCode(allProductTiers,'SageOne-Accounting-DE'),ProductTierRatePlanCode__c=productTierRatePlanData.LookupProductTierRatePlanIdByTierCode(allProductTiers,allProductTierRatePlans,'SageOne-Accounting-DE','Monthly-BuyNow'),Description__c='Payroll Bundle Price',OriginalPriceTotal__c='14',PromotionalPriceTotal__c='7',Promotional_Discount_Months__c=6, Start_Date__c=Date.ValueOf('2017-01-01'), End_Date__c=Date.ValueOf('2099-12-31'), CurrencyIsoCode='EUR', ProductSignupBaseUrl__c='https://pre-central.eu.sageone.com/signup/new' )
            };

            insert pricingCodes;
            System.debug('LoadPricingCodes succeeded ...');

            return pricingCodes;
        }

        public List<PricingCodeCharge__c> LoadPricingCodeCharges()
        {
            System.debug('LoadPricingCodeCharges starts ...');

            List<PricingCodeCharge__c> allPricingCodeCharges = new List<PricingCodeCharge__c>();

            List<PricingCode__c> pricingCodes = [SELECT Id, OriginalPriceTotal__c, PromotionalPriceTotal__c, Promotional_Discount_Months__c FROM PricingCode__c WHERE Name != '_LIST' AND IsDeleted = FALSE];
            for (PricingCode__c code : pricingCodes) {
                List<PricingCodeCharge__c> codeCharges = CreatePricingCodeCharges(code.Id);
                if (codeCharges == null) {
                    return null;
                }
                allPricingCodeCharges.addAll(codeCharges);
            }

            if (allPricingCodeCharges.isEmpty())
                return null;

            insert allPricingCodeCharges;

            List<PricingCode__c> codes = [SELECT Id, ProductSignupBaseUrl__c, SyncStatus__c FROM PricingCode__c WHERE SyncStatus__c = 'is modified' AND IsDeleted = FALSE];
            for (PricingCode__c code : codes) {
                code.SyncStatus__c = 'Publish Requested';
            }
            update codes;

            System.debug('LoadPricingCodeCharges completed ...');

            return [SELECT Id, Name FROM PricingCodeCharge__c WHERE IsDeleted = FALSE];
        }

        private List<PricingCodeCharge__c> CreatePricingCodeCharges(Id pricingCodeId)
        {
            System.debug('CreatePricingCodeCharge: '+pricingCodeId);

            if (String.isBlank(pricingCodeId))
                return null;

            List<PricingCode__c> pricingCodes = [SELECT Id, Name, OriginalPriceTotal__c, PromotionalPriceTotal__c, Promotional_Discount_Months__c, PromotionalDiscountPercent__c, ProductTierRatePlanCode__c, Product_Tier__c, ProductTierRatePlanCode__r.Product_Rate_Plan__c, ProductTierRatePlanCode__r.Product_Rate_Plan__r.zqu__Product__c FROM PricingCode__c WHERE ID=:pricingCodeId];
            if (pricingCodes == null || pricingCodes.size() == 0) {
                System.debug('No pricing code found: '+pricingCodeId);
                return null;
            }
            PricingCode__c pricingCode = pricingCodes[0];

            Decimal originalTotal = 0, promotionalPriceTotal = 0, promotionalDiscountMonths = 0, promotionDiscountPercent = 0, discountFixAmount = 0;

            try {
                originalTotal = Decimal.valueOf(pricingCode.OriginalPriceTotal__c);
            } catch (Exception ex) {
                System.debug(ex);
            }
            try {
                promotionalPriceTotal = Decimal.valueOf(pricingCode.PromotionalPriceTotal__c);
            } catch (Exception ex) {
                System.debug(ex);
            }
            discountFixAmount = originalTotal - promotionalPriceTotal;
            promotionalDiscountMonths = pricingCode.Promotional_Discount_Months__c;
            promotionDiscountPercent = pricingCode.PromotionalDiscountPercent__c;

            List<PricingCodeCharge__c> codeCharges = [SELECT CurrencyIsoCode,DiscountPercent__c,DiscountPrice__c,Id,IsDeleted,ListPrice__c,Name,NumberOfPeriods__c,Pricing_Code__c,ProductTierRatePlan__c,ProductTier__c,Product_Rate_Plan_Charge__c,Product_Rate_Plan__c,RatePlanName__c,Product__c,ZuoraRatePlanId__c FROM PricingCodeCharge__c WHERE Pricing_Code__c =: pricingCodeId];

            if (codeCharges!=null && codeCharges.size() > 0) {
                System.debug('Existing code charges found for pricingCode: '+pricingCodeId);
                return null;
            }

            List<zqu__ProductRatePlanCharge__c> planCharges = [SELECT CurrencyIsoCode,Id,IsDeleted,Name,zqu__AccountingCode__c,zqu__Deleted__c,zqu__Discount_Apply_Type__c,zqu__Discount_Level__c,zqu__ListPrice__c,zqu__Model__c,zqu__ProductRatePlan__c,zqu__ProductRatePlan__r.Name,zqu__RecurringPeriod__c,zqu__Type__c,zqu__Upto_How_Many_Periods__c,zqu__ZUnitOfMeasure__c,zqu__ZuoraId__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__Deleted__c = false AND zqu__ProductRatePlan__c =: pricingCode.ProductTierRatePlanCode__r.Product_Rate_Plan__c];

            if (planCharges==null || planCharges.size()==0) {
                System.debug('No data found in zqu__ProductRatePlanCharge__c for pricingCode: '+pricingCodeId);
                return null;
            }

            List<zqu__ProductRatePlanChargeTier__c> planChargeTiers = [SELECT Id,IsDeleted,Name,zqu__Currency__c,zqu__Deleted__c,zqu__EndingUnit__c,zqu__IsOveragePrice__c,zqu__PriceFormat__c,zqu__Price__c,zqu__ProductRatePlanCharge__c,zqu__StartingUnit__c,zqu__Tier__c,zqu__ZuoraId__c FROM zqu__ProductRatePlanChargeTier__c WHERE zqu__Deleted__c = false AND zqu__ProductRatePlanCharge__c =: planCharges];

            // https://knowledgecenter.zuora.com/DC_Developers/SOAP_API/E1_SOAP_API_Object_Reference/ProductRatePlanCharge
            // http://community.zuora.com/t5/Zuora-for-Salesforce/How-can-I-find-out-what-charge-type-a-discount-charge-is-mapped/td-p/8130
            // apply type: NULL(0), ONETIME(1), RECURRING(2), USAGE(4), ONETIMERECURRING(3), ONETIMEUSAGE(5), RECURRINGUSAGE(6), ONETIMERECURRINGUSAGE(7)
            codeCharges = new List<PricingCodeCharge__c>();
            for (zqu__ProductRatePlanCharge__c planCharge : planCharges) {
                PricingCodeCharge__c codeCharge = new PricingCodeCharge__c();
                codeCharge.Name = planCharge.Name;
                codeCharge.Product_Rate_Plan__c = planCharge.zqu__ProductRatePlan__c;
                codeCharge.Product_Rate_Plan_Charge__c = planCharge.Id;
                codeCharge.ProductTier__c = pricingCode.Product_Tier__c;
                codeCharge.ProductTierRatePlan__c = pricingCode.ProductTierRatePlanCode__c;
                codeCharge.Pricing_Code__c = pricingCode.Id;
                // formula fields
                //codeCharge.RatePlanName__c = planCharge.zqu__ProductRatePlan__r.Name;
                //codeCharge.ZuoraRatePlanId__c = planCharge.zqu__ZuoraId__c;
                //codeCharge.ListPrice__c = planCharge.zqu__ListPrice__c;
                codeCharge.Product__c = pricingCode.ProductTierRatePlanCode__r.Product_Rate_Plan__r.zqu__Product__c;

                codeCharge.NumberOfPeriods__c = planCharge.zqu__Upto_How_Many_Periods__c;

                List<zqu__ProductRatePlanChargeTier__c> tiers = new List<zqu__ProductRatePlanChargeTier__c>();
                for (zqu__ProductRatePlanChargeTier__c planChargeTier : planChargeTiers) {
                    System.debug('compare: ' + planChargeTier.zqu__ProductRatePlanCharge__c + ' : ' + planCharge.Id);
                    if (planChargeTier.zqu__ProductRatePlanCharge__c == planCharge.Id)
                        tiers.add(planChargeTier);
                }

                System.debug('tiers: ' + tiers);
                if (tiers.size() == 1) {
                    codeCharge.CurrencyIsoCode = tiers[0].zqu__Currency__c;

                    if (planCharge.zqu__Model__c == 'Discount-Percentage') {
                        codeCharge.NumberOfPeriods__c = (promotionalDiscountMonths > 0)  ? promotionalDiscountMonths : null;
                        if (promotionDiscountPercent > 0) {
                            codeCharge.DiscountPercent__c = promotionDiscountPercent;
                        } else {
                            codeCharge.DiscountPercent__c = tiers[0].zqu__Price__c;
                        }
                    } else if (planCharge.zqu__Model__c == 'Discount-Fixed Amount') {
                        codeCharge.NumberOfPeriods__c = (promotionalDiscountMonths > 0)  ? promotionalDiscountMonths : null;
                        if (discountFixAmount > 0) {
                            codeCharge.DiscountPrice__c = discountFixAmount;
                        } else {
                            codeCharge.DiscountPrice__c = tiers[0].zqu__Price__c;
                        }
                    } else if (planCharge.zqu__Model__c == 'Flat Fee Pricing' && planCharges.size()==1 && promotionalPriceTotal > 0) {
                        codeCharge.DiscountPrice__c = promotionalPriceTotal;
                    } else {
                        codeCharge.DiscountPrice__c = tiers[0].zqu__Price__c;
                    }
                } else if (tiers.size() > 1) {
                    for (zqu__ProductRatePlanChargeTier__c tier : tiers) {
                        if (tier.zqu__Currency__c == 'USD')
                            continue;

                        codeCharge.CurrencyIsoCode = tier.zqu__Currency__c;
                        if (planCharge.zqu__Model__c == 'Discount-Percentage') {
                            codeCharge.NumberOfPeriods__c = (promotionalDiscountMonths > 0)  ? promotionalDiscountMonths : null;
                            if (promotionDiscountPercent > 0) {
                                codeCharge.DiscountPercent__c = promotionDiscountPercent;
                            } else {
                                codeCharge.DiscountPercent__c = tier.zqu__Price__c;
                            }
                        } else if (planCharge.zqu__Model__c == 'Discount-Fixed Amount') {
                            codeCharge.NumberOfPeriods__c = (promotionalDiscountMonths > 0)  ? promotionalDiscountMonths : null;
                            if (discountFixAmount > 0) {
                                codeCharge.DiscountPrice__c = discountFixAmount;
                            } else {
                                codeCharge.DiscountPrice__c = tier.zqu__Price__c;
                            }
                        } else if (planCharge.zqu__Model__c == 'Flat Fee Pricing' && planCharges.size()==1 && promotionalPriceTotal > 0) {
                            codeCharge.DiscountPrice__c = promotionalPriceTotal;
                        } else {
                            codeCharge.DiscountPrice__c = tier.zqu__Price__c;
                        }
                    }
                }

                codeCharges.add(codeCharge);
                System.debug('codeCharge: ' + codeCharge);
            }

            return codeCharges;
        }
    }

    public class ZuoraData
    {
        private List<Product2> Products;
        private List<zqu__ProductRatePlan__c> ProductRatePlans;

        public ZuoraData()
        {
            Products = [SELECT Name,Id FROM Product2 WHERE (Name = 'Sage Business Cloud Accounting' or Name = 'Sage Business Cloud Accounting Start') and IsDeleted = false and zqu__ZuoraId__c != null and IsDeleted = false];
            ProductRatePlans = [SELECT zqu__Product__c,Name,Id FROM zqu__ProductRatePlan__c WHERE (zqu__Product__r.Name = 'Sage Business Cloud Accounting' or zqu__Product__r.Name = 'Sage Business Cloud Accounting Start') and IsDeleted = false and zqu__Deleted__c = false];
        }

        public Id LookupProductIdByName(string product)
        {
            Integer matched = 0;
            Id matchedId = null;

            for(Product2 p : Products)
            {
                if (p.Name != product)
                    continue;

                matched++;
                matchedId = p.Id;
            }

            if (matched == 0)
                throw new CustomException('ZuoraData.LookupProductIdByName failed for ' + product);
            if (matched > 1)
                throw new CustomException('ZuoraData.LookupProductIdByName: multiple Products returned for ' + product);

            return matchedId;
        }

        public Id LookupProductRatePlanIdByName(string product, string productRatePlan)
        {
            Id productId = LookupProductIdByName(product);
            if (productId == null)
                return null;

            Integer matched = 0;
            Id matchedId = null;

            for(zqu__ProductRatePlan__c r : ProductRatePlans)
            {
                if (r.zqu__Product__c != productId || r.Name != productRatePlan)
                    continue;

                matched++;
                matchedId = r.Id;
            }

            if (matched == 0)
                throw new CustomException('ZuoraData.LookupProductRatePlanIdByName failed for ' + product + '|'+productRatePlan);
            if (matched > 1)
                throw new CustomException('ZuoraData.LookupProductRatePlanIdByName: multiple ProductRatePlans returned for ' + product + '|'+productRatePlan);

            return matchedId;
        }
    }

    public class LocaleData
    {
        private List<Locale__c> Locales;

        public LocaleData()
        {
            Locales = [select Id, Name from Locale__c where IsDeleted=false and Default_Locale__c='Yes'];
        }

        public Id LookupLocaleIdByName(string locale)
        {
            Integer matched = 0;
            Id matchedId = null;

            for(Locale__c l : Locales)
            {
                if (l.Name != locale)
                    continue;

                matched++;
                matchedId = l.Id;
            }

            if (matched == 0)
                throw new CustomException('LookupLocaleIdByName: No Locales returned for ' + locale);
            if (matched > 1)
                throw new CustomException('LookupLocaleIdByName: Multiple Locales returned for ' + locale);

            return matchedId;
        }
    }
}