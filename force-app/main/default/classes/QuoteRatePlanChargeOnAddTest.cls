/*-------------------------------------------------------------
Author:         Yue Lu
Date :          04/18/2018
Company:       
Description:    
Inputs:        None
History
<Date>            <Authors Name>                <Brief Description of Change>


-------------------------------------------------------------*/
@isTest
public class QuoteRatePlanChargeOnAddTest {
    
    
    
    @testSetup
    public static void setupTestData() {
        
        
        String aValidPartnerString = 'A Valid Partner';
        String notAValidPartnerString = 'Not a Valid Partner';
        
        //Create Locales
        //en_GB
        Locale__c enGBLocale = new Locale__c();
        enGBLocale.Name = 'en_GB';
        enGBLocale.Language__c = 'English';
        enGBLocale.Country__c = 'GB - United Kingdom';
        enGBLocale.LanguageLocaleKey__c = 'en_GB';
        insert enGBLocale;
        
        //de_DE
        Locale__c deDELocale = new Locale__c();
        deDELocale.Name = 'de_DE';
        deDELocale.Language__c = 'German';
        deDELocale.Country__c = 'DE - Germany';
        deDELocale.LanguageLocaleKey__c = 'de';
        insert deDELocale;
        
        List<PartnerMarginTierConfiguration__c> testMargins = new List<PartnerMarginTierConfiguration__c> () ;
        
        PartnerMarginTierConfiguration__c marginConfig = new PartnerMarginTierConfiguration__c();
        marginConfig.Contains_API_Key_Keywords__c = 'sagelife';
        marginConfig.Not_Contains_API_Keywords__c = 'foundation';
        marginConfig.Authorized__c = 25.00;
        marginConfig.Silver__c = 30.00;
        marginConfig.Platinum__c = 40.00;
        marginConfig.Version__c = 'V3';
        marginConfig.Partner_Type__c = 'Reseller';
        marginConfig.Name = 'Partner Margin Tier Configuration';
        marginConfig.Product_Label__c = 'Sage Financials';
        marginConfig.Suported_Locales__c = 'en_GB';
        
        testMargins.add(marginConfig);
        //insert marginConfig;
        
        
        PartnerMarginTierConfiguration__c marginConfig2 = new PartnerMarginTierConfiguration__c();
        marginConfig2.Contains_API_Key_Keywords__c = 'foundation';
        marginConfig2.Not_Contains_API_Keywords__c = '';
        marginConfig2.Authorized__c = 20.00;
        marginConfig2.Silver__c = 20.00;
        marginConfig2.Platinum__c = 20.00;
        marginConfig2.Version__c = 'V3';
        marginConfig2.Partner_Type__c = 'Reseller';
        marginConfig2.Name = 'Partner Margin Tier Configuration 2';
        marginConfig2.Product_Label__c = 'Sage Financials Foundation';
        marginConfig2.Suported_Locales__c = 'en_GB';
        
        testMargins.add(marginConfig2);
        //insert marginConfig2;
        
        insert testMargins;
            
        //Get Locale en_GB
        List<Locale__c> enGBLocaleL = [Select id from Locale__c where name = 'en_GB'];
        
        //Get Locale de_DE
        List<Locale__c> deDELocaleL = [Select id from Locale__c where name = 'de_DE'];
        
        
        
        //Create 1st Account and Opp where record type is not a Partner Account
        SPPTestData.CreateAccountAndContactForPartnerType();
        
        //Create 2nd account where is a Partner and Opp
        SPPTestData.CreateAccountAndContactForPartnerType();
        
        //Create 2 opps in a row
        //
        List<Opportunity> oppList = SPPTestData.createOpportunity(2);
        
        List<Account> accListNP = [Select id from Account];
        accListNP[0].Partner_Agreement__c = 'V3';
        accListNP[0].Type = 'Partner';
        accListNP[0].Name = notAValidPartnerString;
        Id accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
        accListNP[0].RecordTypeId = accountRecordType;
        //accListNP[0].Local_CRM_Country__c = 'GB - United Kingdom';
        accListNP[0].BillingCountry ='United Kingdom';
        accListNP[0].Locale_Billing_CC__c = 'GB';
        accListNP[0].Locale__c = enGBLocaleL[0].Id;
        //update accListNP[0];
        Opportunity oppListNP = oppList[0];
        oppListNP.Type = 'Resell Business';
        oppListNP.Name = notAValidPartnerString;
        oppListNP.accountid = accListNP[0].id;
        update oppListNP;
        
        
        
       //List<Opportunity> oppList2 = SPPTestData.createOpportunity(1);
       // List<Account> accListPR = [Select id, name from Account where NOT Name like :notAValidPartnerString];
        accListNP[1].Partner_Agreement__c = 'V3';
        accListNP[1].Type = 'Partner';
        accListNP[1].Name = aValidPartnerString;
        accListNP[1].Partner_Reseller__c = true;
        accListNP[1].Reseller_Partner_Tier__c = 'Platinum';
        accListNP[1].Partner_Reseller_TnC__c = true;
        //accListPR[0].Local_CRM_Country__c = 'GB - United Kingdom';
        accListNP[1].BillingCountry ='United Kingdom';
        accListNP[1].Locale_Billing_CC__c = 'GB';
        accListNP[1].Locale__c = enGBLocaleL[0].Id;
        Id accountRecordType2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        accListNP[1].RecordTypeId = accountRecordType2;
        update accListNP;
        Opportunity oppListPR = oppList[1]; // [Select id, Name from Opportunity where NOT Name like :notAValidPartnerString];
        oppListPR.Type = 'Resell Business';
        oppListPR.Name = aValidPartnerString;
        oppListPR.accountid = accListNP[1].id;
        update oppListPR;
        
        
        /*
//SI
SPPTestData.CreateAccountAndContactForPartnerType();
SPPTestData.createOpportunity(1);
List<Account> accListPSI = [Select id, name from Account where NOT Name like :notAValidPartnerString];
accListPSI[0].Partner_Agreement__c = 'V3';
accListPSI[0].Type = 'Partner';
accListPSI[0].Name = aValidPartnerString;
accListPSI[0].Partner_Reseller__c = true;
accListPSI[0].Reseller_Partner_Tier__c = 'Platinum';
accListPSI[0].Partner_Reseller_TnC__c = true;
Id accountRecordType3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
accListPSI[0].RecordTypeId = accountRecordType3;
//accListPSI[0].Local_CRM_Country__c = 'GB - United Kingdom';
accListPSI[0].BillingCountry ='United Kingdom';
accListPSI[0].Locale_Billing_CC__c = 'GB';
accListPSI[0].Locale__c = enGBLocaleL[0].Id;
update accListPSI[0];
List<Opportunity> oppListPSI = [Select id, Name from Opportunity where NOT Name like :notAValidPartnerString];
oppListPSI[0].Type = 'Resell Business';
oppListPSI[0].Name = aValidPartnerString;
oppListPSI[0].accountid = accListPSI[0].id;
update oppListPSI;


//Accountant
SPPTestData.CreateAccountAndContactForPartnerType();
SPPTestData.createOpportunity(1);
List<Account> accListPAcc = [Select id, name from Account where NOT Name like :notAValidPartnerString];
accListPAcc[0].Partner_Agreement__c = 'V3';
accListPAcc[0].Type = 'Partner';
accListPAcc[0].Name = aValidPartnerString;
accListPAcc[0].Partner_Reseller__c = true;
accListPAcc[0].Reseller_Partner_Tier__c = 'Platinum';
accListPAcc[0].Partner_Reseller_TnC__c = true;
Id accountRecordType4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
accListPAcc[0].RecordTypeId = accountRecordType4;
//accListPAcc[0].Local_CRM_Country__c = 'DE - Germany';
accListPAcc[0].BillingCountry ='Germany';
accListPAcc[0].Locale_Billing_CC__c = 'DE';
accListNP[0].Locale__c = deDELocaleL[0].Id;
update accListPAcc[0];
List<Opportunity> oppListPAcc = [Select id, Name from Opportunity where NOT Name like :notAValidPartnerString];
oppListPAcc[0].Type = 'Resell Business';
oppListPAcc[0].Name = aValidPartnerString;
oppListPAcc[0].accountid = accListPAcc[0].id;
update oppListPAcc;*/
        
    }
    
    
    
    @IsTest
    public static void testNotValidPartner() {
        String notAValidPartnerString = 'Not a Valid Partner';
        
        List<Account> accList = [Select id, name from Account where Name = :notAValidPartnerString];
        List<Opportunity> oppListP = [Select id, Name from Opportunity where Name = :notAValidPartnerString];
        //Create the quote
        List<zqu__Quote__c> lstQuote = SPPTestData.CreateZuoraQuote(1, accList[0], oppListP[0]);
        
        
        //create test product rate plan charge List
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = CreateProductRatePlanCharge(1, 'charge', '');
        List<String> addedRatePlans = new List<String>();
        
        for(zqu__ProductRatePlanCharge__c zprpc:productRatePlanChargeList ) {
            addedRatePlans.add(zprpc.zqu__ProductRatePlan__c);
        }
        
        test.startTest();
        //Call plugin
        QuoteRatePlanChargeOnAdd plugin = new QuoteRatePlanChargeOnAdd();
        plugin.onAdd(lstQuote[0].id,addedRatePlans);
        plugin.onRemove(lstQuote[0].id,addedRatePlans);
        test.stopTest();
        
    }
    
    
    @IsTest
    public static void testIsValidPartner() {
        
        String aValidPartnerString = 'A Valid Partner';
        
        List<Account> accList = [Select id, name, Locale__r.Name from Account where Name = :aValidPartnerString limit 1];
        List<Locale__c> enGBLocaleL = [Select id from Locale__c where name = 'en_GB'];
        accList[0].Locale__c = enGBLocaleL[0].id;
        update accList;
        
        System.debug('Local from account:' + accList);
        List<Opportunity> oppListP = [Select id, Name from Opportunity where Name = :aValidPartnerString];
        //Create the quote
        List<zqu__Quote__c> lstQuote = SPPTestData.CreateZuoraQuote(1, accList[0], oppListP[0]);
        
        //Create partner margin
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c>  productRatePlanCharge = createProduct('Partner Margin','SKU02312','123456799', 'sage:partner:margin:annual', 'Annual');
        
        zqu__QuoteRatePlan__c quoteRatePlan = createQuoteRatePlan(lstQuote[0].ID, productRatePlanCharge[0].zqu__ProductRatePlan__c, 'Partner Margin');
        System.debug('quoteRatePlan:: ' + quoteRatePlan);
        
        //create test product rate plan charge List
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = createProduct('Financials Product','SKU0231','123456789', 'sage:fr:sagelife:best:donated:annual' , 'Annual');
        List<String> addedRatePlans = new List<String>();
        
        for(zqu__ProductRatePlanCharge__c zprpc : productRatePlanChargeList) {
            addedRatePlans.add(zprpc.zqu__ProductRatePlan__c);
        }
        
        test.startTest();
        
        
        List<ID> productRatePlanIdsList = new List<ID>();
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeDiscountList = [Select id, Name, zqu__ProductRatePlan__r.APIServiceId__c from  zqu__ProductRatePlanCharge__c where Name = 'Partner Margin 0'];
        system.debug('productRatePlanChargeDiscountList: ' +productRatePlanChargeDiscountList);
        
        try {
            //Call plugin
            QuoteRatePlanChargeOnAdd plugin = new QuoteRatePlanChargeOnAdd();
            plugin.onAdd(lstQuote[0].id,addedRatePlans);
            List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT Id,Name, zqu__Quote__c, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :lstQuote[0].id];
            system.debug('quoteRatePlans: ' +quoteRatePlans);
            plugin.onRemove(lstQuote[0].id,addedRatePlans);
            
        } catch(Exception ex) {
            System.AssertEquals(true, true);
        }
        test.stopTest();
    }
    
    @IsTest
    public static void testValidPartnersWithFoundation1Product() {
        
        String aValidPartnerString = 'A Valid Partner';
        
        List<Account> accList = [Select id, name, Locale__r.Name from Account where Name = :aValidPartnerString limit 1];
        List<Locale__c> enGBLocaleL = [Select id from Locale__c where name = 'en_GB'];
        accList[0].Locale__c = enGBLocaleL[0].id;
        update accList;
        
        System.debug('Local from account:' + accList);
        List<Opportunity> oppListP = [Select id, Name from Opportunity where Name = :aValidPartnerString];
        //Create the quote
        List<zqu__Quote__c> lstQuote = SPPTestData.CreateZuoraQuote(1, accList[0], oppListP[0]);
        
        
        //Create partner margin
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c>  productRatePlanCharge = createProduct('Partner Margin','SKU023124','123456899', 'sage:partner:margin:foundation:annual', 'Annual');
        zqu__QuoteRatePlan__c quoteRatePlan = createQuoteRatePlan(lstQuote[0].ID, productRatePlanCharge[0].zqu__ProductRatePlan__c, 'Partner Margin');
        System.debug('quoteRatePlan:: ' + quoteRatePlan);
        
        //create test product rate plan charge List
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = createProduct('Financials Product','SKU0241','0123456789', 'sage:fr:sagelife:best:foundation:donated:annual' , 'Annual');
        List<String> addedRatePlans = new List<String>();
        
        for(zqu__ProductRatePlanCharge__c zprpc : productRatePlanChargeList) {
            addedRatePlans.add(zprpc.zqu__ProductRatePlan__c);
        }

        test.startTest();
        
        List<ID> productRatePlanIdsList = new List<ID>();
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeDiscountList = [Select id, Name, zqu__ProductRatePlan__r.APIServiceId__c from  zqu__ProductRatePlanCharge__c where Name = 'Partner Margin 0'];
        system.debug('productRatePlanChargeDiscountList: ' +productRatePlanChargeDiscountList);
        
        try {
            //Call plugin
            QuoteRatePlanChargeOnAdd plugin = new QuoteRatePlanChargeOnAdd();
            plugin.onAdd(lstQuote[0].id,addedRatePlans);
            List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT Id,Name, zqu__Quote__c, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :lstQuote[0].id];
            system.debug('quoteRatePlans: ' +quoteRatePlans);
            plugin.onRemove(lstQuote[0].id,addedRatePlans);
            
        } catch(Exception ex) {
            System.AssertEquals(true, true);
        }
        test.stopTest();
    }
    
    
    @IsTest
    public static void testValidPartnersISV() {
        
        String aValidPartnerString = 'A Valid Partner';
        
        List<Account> accList = [Select id, name, Locale__r.Name from Account where Name = :aValidPartnerString limit 1];
        List<Locale__c> enGBLocaleL = [Select id from Locale__c where name = 'en_GB'];
        accList[0].Locale__c = enGBLocaleL[0].id;
        update accList;
        
        System.debug('Local from account:' + accList);
        List<Opportunity> oppListP = [Select id, Name from Opportunity where Name = :aValidPartnerString];
        //Create the quote
        List<zqu__Quote__c> lstQuote = SPPTestData.CreateZuoraQuote(1, accList[0], oppListP[0]);
       /* lstQuote[0].zqu__SubscriptionType__c = 'Amend Subscription';
        update lstQuote;*/
        
        //Create partner margin
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c>  productRatePlanCharge = createProduct('Partner Margin','SKU023124ISV','123456899ISV', 'sage:partner:margin:isv:annual', 'Annual');
        
        zqu__QuoteRatePlan__c quoteRatePlan = createQuoteRatePlan(lstQuote[0].ID, productRatePlanCharge[0].zqu__ProductRatePlan__c, 'Partner Margin');
        System.debug('quoteRatePlan:: ' + quoteRatePlan);
        
        //create test product rate plan charge List
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = createProduct('Financials Product','SKU0241ISV','0123456789ISV', 'sage:fr:sagelife:best:isv:donated:annual' , 'Annual');
        List<String> addedRatePlans = new List<String>();
        
        for(zqu__ProductRatePlanCharge__c zprpc : productRatePlanChargeList) {
            addedRatePlans.add(zprpc.zqu__ProductRatePlan__c);
        }
        
        
        
        test.startTest();
        
        List<ID> productRatePlanIdsList = new List<ID>();
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeDiscountList = [Select id, Name, zqu__ProductRatePlan__r.APIServiceId__c from  zqu__ProductRatePlanCharge__c where Name = 'Partner Margin 0'];
        system.debug('productRatePlanChargeDiscountList: ' +productRatePlanChargeDiscountList);
        
        try {
            //Call plugin
            QuoteRatePlanChargeOnAdd plugin = new QuoteRatePlanChargeOnAdd();
            plugin.onAdd(lstQuote[0].id,addedRatePlans);
            List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT Id,Name, zqu__Quote__c, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :lstQuote[0].id];
            system.debug('quoteRatePlans: ' +quoteRatePlans);
            plugin.onRemove(lstQuote[0].id,addedRatePlans);
            
        } catch(Exception ex) {
            System.AssertEquals(true, true);
        }
        test.stopTest();
    }
    
    @IsTest
    public static void testValidPartnersISVAmmendment() {
        
        String aValidPartnerString = 'A Valid Partner';
        
        List<Account> accList = [Select id, name, Locale__r.Name from Account where Name = :aValidPartnerString limit 1];
        List<Locale__c> enGBLocaleL = [Select id from Locale__c where name = 'en_GB'];
        accList[0].Locale__c = enGBLocaleL[0].id;
        update accList;
        
        System.debug('Local from account:' + accList);
        List<Opportunity> oppListP = [Select id, Name from Opportunity where Name = :aValidPartnerString];
        //Create the quote
        List<zqu__Quote__c> lstQuote = SPPTestData.CreateZuoraQuote(1, accList[0], oppListP[0]);
        lstQuote[0].zqu__SubscriptionType__c = 'Amend Subscription';
        update lstQuote;
        
        //Create partner margin
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c>  productRatePlanCharge = createProduct('Partner Margin','SKU023124ISVV','123456899ISV', 'sage:partner:margin:isv:annual', 'Annual');
        
        zqu__QuoteRatePlan__c quoteRatePlan = createQuoteRatePlan(lstQuote[0].ID, productRatePlanCharge[0].zqu__ProductRatePlan__c, 'Partner Margin');
        System.debug('quoteRatePlan:: ' + quoteRatePlan);
        
        //create test product rate plan charge List
        //String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = createProduct('Financials Product','SKU0241ISVV','0123456789ISVV', 'sage:fr:sagelife:best:isv:donated:annual' , 'Annual');
        List<String> addedRatePlans = new List<String>();
        
        for(zqu__ProductRatePlanCharge__c zprpc : productRatePlanChargeList) {
            addedRatePlans.add(zprpc.zqu__ProductRatePlan__c);
        }
        
        
        
        test.startTest();
        
        List<ID> productRatePlanIdsList = new List<ID>();
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeDiscountList = [Select id, Name, zqu__ProductRatePlan__r.APIServiceId__c from  zqu__ProductRatePlanCharge__c where Name = 'Partner Margin 0'];
        system.debug('productRatePlanChargeDiscountList: ' +productRatePlanChargeDiscountList);
        
        try {
            //Call plugin
            QuoteRatePlanChargeOnAdd plugin = new QuoteRatePlanChargeOnAdd();
            plugin.onAdd(lstQuote[0].id,addedRatePlans);
            List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT Id,Name, zqu__Quote__c, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :lstQuote[0].id];
            system.debug('quoteRatePlans: ' +quoteRatePlans);
            plugin.onRemove(lstQuote[0].id,addedRatePlans);
            
        } catch(Exception ex) {
            System.AssertEquals(true, true);
        }
        test.stopTest();
    }
    
    private static List<zqu__ProductRatePlanCharge__c> CreateProductRatePlanCharge(Integer quantity, String name, String aPIServiceId) {
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        
        zqu__ZProduct__c testProduct = zqu.ZQTestDataSetup.prepareProductCatalog();
        
        List<zqu__ProductRatePlan__c> productRatePlanList = creatProductRatePlan(quantity, testProduct, aPIServiceId);
        
        for(Integer i=0 ; i<quantity ; i++ ) {
            zqu__ProductRatePlanCharge__c productRatePlanCharge = new zqu__ProductRatePlanCharge__c();
            productRatePlanCharge.Name = name + i;
            productRatePlanCharge.zqu__ZuoraId__c = testProduct.zqu__ZuoraId__c;
            productRatePlanCharge.zqu__ProductRatePlan__c = productRatePlanList[i].id;
            productRatePlanCharge.zqu__RecurringPeriod__c = 'annual';
            productRatePlanChargeList.add(productRatePlanCharge);
        }
        insert productRatePlanChargeList;
        return productRatePlanChargeList;
    }   
    
    private static List<zqu__ProductRatePlan__c> creatProductRatePlan(Integer quantity, zqu__ZProduct__c testProduct, String aPIServiceId) {
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
        
        system.debug('testProduct>>>'+testProduct);
        for(Integer i=0 ; i<quantity ; i++ ) {
            zqu__ProductRatePlan__c prdRatePlan = new zqu__ProductRatePlan__c();
            prdRatePlan.zqu__ZProduct__c = testProduct.id;
            prdRatePlan.zqu__ZuoraId__c = testProduct.zqu__ZuoraId__c;
            prdRatePlan.APIServiceId__c = aPIServiceId;
            prdRatePlan.zqu__Deleted__c = False;
            prdRatePlan.ExternalApplication__c = Global_Constants.TETRIS;
            Date myDate = Date.today();
            prdRatePlan.zqu__EffectiveEndDate__c = myDate.addDays(10);
            productRatePlanList.add(prdRatePlan);
        }
        insert productRatePlanList;
        return productRatePlanList;
    }
    
    private static List<zqu__ProductRatePlanCharge__c> createProduct(String name, string sku, String uniqueID, String apiServiceID, String recurringPeriod) {
        
        Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
        Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);
        
        zqu__ZProduct__c testProduct = new zqu__ZProduct__c();
        testProduct.Name = name;
        testProduct.zqu__Active__c = true;
        testProduct.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
        testProduct.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
        testProduct.zqu__SKU__c = sku;
        testProduct.zqu__ZuoraId__c = uniqueID;
        testProduct.zqu__Deleted__c = false;
        insert testProduct;
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlan__c> productRatePlanList = creatProductRatePlan(1, testProduct, apiServiceID);
        
        for(Integer i=0 ; i<1 ; i++ ) {
            zqu__ProductRatePlanCharge__c productRatePlanCharge = new zqu__ProductRatePlanCharge__c();
            productRatePlanCharge.Name = name + i;
            productRatePlanCharge.zqu__ZuoraId__c = testProduct.zqu__ZuoraId__c;
            productRatePlanCharge.zqu__ProductRatePlan__c = productRatePlanList[i].id;
            productRatePlanCharge.zqu__RecurringPeriod__c = recurringPeriod;//'Month';
            //productRatePlanCharge.zqu__A = 'sage:partner:margin:annual';
            productRatePlanChargeList.add(productRatePlanCharge);
        }
        insert productRatePlanChargeList;
        return productRatePlanChargeList;
    }
    
    private static zqu__QuoteRatePlan__c createQuoteRatePlan(ID quoteId, ID productRatePlan, String name) {
        zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
        quoteRatePlan.zqu__ProductRatePlan__c = productRatePlan;
        quoteRatePlan.zqu__Quote__c = quoteId;
        quoteRatePlan.Name = name;
        
        zqu__QuoteAmendment__c newQuoteAmendment = makeQuoteAmendment(quoteID); 
        
        quoteRatePlan.zqu__QuoteAmendment__c = newQuoteAmendment.Id;
        insert quoteRatePlan;
        
        return quoteRatePlan;
    }
    
    private static zqu__QuoteAmendment__c makeQuoteAmendment(ID quoteID) {
        
        zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
        
        testQuoteAmendment.Name = 'my test quote amendment';
        testQuoteAmendment.zqu__Quote__c = quoteID;
        insert testQuoteAmendment;
        return testQuoteAmendment;
    }
}