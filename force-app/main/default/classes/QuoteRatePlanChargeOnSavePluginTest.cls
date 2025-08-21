/**********************************************************************
Name:  QuoteRatePlanChargeOnSavePluginTest

======================================================
======================================================
Purpose: Test class for QuoteRatePlanChargeOnSavePluginTest
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Claudio     		13/03/2018			EAD-415								product Renaming
*********************************************************************/
@isTest
public class QuoteRatePlanChargeOnSavePluginTest {
    
    public static final String baseProductName = 'Sage Live Premium0';
    public static final String volumeProductName = 'Test Volume Product';
    public static final String otherProductName = 'Test Other Product';
    
    private static final String baseProductId = '12345678901234567890123456789011';
    private static final String volumeProductId = '12345678901234567890123456789012';
    private static final String otherProductId = '12345678901234567890123456789013';
    
    public static final String baseRateplanId = '23456789012345678901234567890121';
    public static final String volumeRateplanId = '23456789012345678901234567890122';
    public static final String otherRateplanId = '23456789012345678901234567890123';
    
    private static final String chargeId1 = '34567890123456789012345678901231';
    private static final String chargeId2 = '34567890123456789012345678901232';
    private static final String chargeId3 = '34567890123456789012345678901233';
    private static final String tierId1 = '45678901234567890123456789012341';
    private static final String tierId2 = '45678901234567890123456789012342';
    private static final String tierId3 = '45678901234567890123456789012343';
    private static final String uomId1 = '56789012345678901234567890123451';
    private static final String uomId2 = '56789012345678901234567890123452';
    private static final String uomId3 = '56789012345678901234567890123453';
    
    @testSetup
    public static void setupTestData() {
        final zqu__ZProduct__c testProduct = zqu.ZQTestDataSetup.prepareProductCatalog();
        createLocale(2);
        zqu__QuoteCharge__c zQuoteCharge01 = new zqu__QuoteCharge__c();
        zqu__QuoteCharge__c zQuoteCharge02 = new zqu__QuoteCharge__c();
        createZProductChargeNameMapping();
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = CreateProductRatePlanCharge(2);
        zQuoteCharge01.zqu__ProductRatePlanCharge__c = productRatePlanChargeList[0].id;
        zQuoteCharge02.zqu__ProductRatePlanCharge__c = productRatePlanChargeList[1].id;
        
        List<zqu__Quote__c> quotesList = createzQuote(2);
        zQuoteCharge01.zqu__Quote__c = quotesList[0].id;
        zQuoteCharge02.zqu__Quote__c = quotesList[1].id;
        
        zQuoteCharge01.Name = '01';
        zQuoteCharge02.Name = '02';
        zQuoteCharge01.zqu__ProductName__c = 'French';
        zQuoteCharge02.zqu__ProductName__c = 'Sage Live Premium';        
        
        List<zqu__QuoteCharge__c> zQuoteChargeList = new List<zqu__QuoteCharge__c>();
        zQuoteChargeList.add(zQuoteCharge01);
        zQuoteChargeList.add(zQuoteCharge02);
        
        insert zQuoteChargeList;
    }
    
    @isTest
    public static void testMatchingProductChargeNameMapping() {
        
        
        
        zqu__Quote__c quote = createTestQuote(null, null, null, null, true);
        List<Id> RatePlanIds = createCatalog(true, false, baseProductId, baseRateplanId, chargeId1, tierId1, uomId1);

        List<zqu__ProductRatePlanCharge__c> rateplanCharge = [SELECT id, zqu__ZuoraId__c from zqu__ProductRatePlanCharge__c where Name = 'Test ZOrder Rate Plan Charge'];
        
        
        zqu__QuoteRatePlanCharge__c zQuoteRatePlanCharge02 = new zqu__QuoteRatePlanCharge__c();
        zQuoteRatePlanCharge02.zqu__ProductRatePlanChargeZuoraId__c = rateplanCharge[0].zqu__ZuoraId__c;

        QuoteRatePlanChargeOnSavePlugin plugin = new QuoteRatePlanChargeOnSavePlugin();
        
        Boolean success = false;
        
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, RatePlanIds);
        List<zqu.zChargeGroup> addedGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        
        for(zqu.zChargeGroup zcg :addedGroups) {
            
            for (zqu.zCharge zc: zcg.zCharges) {
            	zc.chargeObject = zQuoteRatePlanCharge02;
            }
        }
        plugin.onSave(addedGroups, addedGroups, addedGroups, addedGroups);

        //System.assertEquals('Sage Live Premium0', )
    }
    
    
    //Create a test Quote
    public static zqu__Quote__c createTestQuote(Account acc, Opportunity opp, Contact billTo, Contact soldTo, Boolean doInsert) {
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test Quote';
        quote.zqu__SubscriptionType__c = 'New Subscription';
        quote.zqu__StartDate__c = System.today();
        quote.zqu__ValidUntil__c = System.today();
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.zqu__InitialTerm__c = 12;
        quote.zqu__RenewalTerm__c = 12;
        quote.zqu__Account__c = createAccount(1)[0].id;
        quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
        quote.zqu__BillToContact__c = (billTo != null) ? billTo.Id : null;
        quote.zqu__SoldToContact__c = (soldTo != null) ? soldTo.Id : null;
        quote.zqu__Currency__c = 'USD';
        
        if (doInsert) {
            insert quote;
        }
        
        return quote;
    }
    
    private static zqu__ZProduct__c createProduct(Boolean doInsert, Boolean isBase, Boolean isVolume, String productId) {
        zqu__ZProduct__c prod = new zqu__ZProduct__c();
        prod.Name = (isBase) ? baseProductName : (isVolume) ? volumeProductName : otherProductName;
        prod.zqu__Description__c = 'Test Description';
        prod.zqu__Deleted__c = false;
        prod.zqu__ZuoraId__c = productId;
        prod.zqu__EffectiveStartDate__c = System.today().addYears(-1);
        prod.zqu__EffectiveEndDate__c = System.today().addYears(1);
        prod.zqu__SKU__c = 'Test SKU';
        
        if (doInsert) {
            insert prod;
        }
        return prod;
    }
    
    private static zqu__ProductRatePlan__c createProductRatePlan(zqu__ZProduct__c prod, Boolean doInsert, String rateplanId) {
        zqu__ProductRatePlan__c rateplan = new zqu__ProductRatePlan__c();
        rateplan.Name = 'Test ZOrder Rate Plan';
        rateplan.zqu__Deleted__c = false;
        rateplan.zqu__EffectiveStartDate__c = System.today().addYears(-1);
        rateplan.zqu__EffectiveEndDate__c = System.today().addYears(1);
        rateplan.zqu__ZProduct__c = prod.Id;
        rateplan.zqu__ZuoraId__c = rateplanId;
        rateplan.ExternalApplication__c = 'Tetris';
        
        if (doInsert) {
            insert rateplan;
        }
        return rateplan;
    }
    
    private static zqu__ProductRatePlanCharge__c createProductCharge(zqu__ProductRatePlan__c rateplan, zqu__ZUnitOfMeasure__c uom, Boolean doInsert, String chargeId) {
        zqu__ProductRatePlanCharge__c charge = new zqu__ProductRatePlanCharge__c();
        charge.Name = 'Test ZOrder Rate Plan Charge';
        charge.zqu__DefaultQuantity__c = 1;
        charge.zqu__Deleted__c = false;
        charge.zqu__ListPrice__c = 10;
        charge.zqu__Model__c = 'Per Unit Pricing';
        charge.zqu__ProductRatePlan__c = rateplan.Id;
        charge.zqu__RecurringPeriod__c = 'Month';
        charge.zqu__Type__c = 'Recurring';
        charge.zqu__ZUnitOfMeasure__c = uom.Id;
        charge.zqu__UOM__c = uom.Name;
        charge.zqu__ZUom_Id__c = uom.zqu__ZuoraId__c;
        charge.zqu__ZuoraId__c = chargeId;
        
        if (doInsert) {
            insert charge;
        }
        return charge;
    }
    
    private static zqu__ProductRatePlanChargeTier__c createProductTier(zqu__ProductRatePlanCharge__c charge, Boolean doInsert, String tierId) {
        zqu__ProductRatePlanChargeTier__c tier = new zqu__ProductRatePlanChargeTier__c();
        tier.Name = '1';
        tier.zqu__Currency__c = 'USD';
        tier.zqu__Deleted__c = false;
        tier.zqu__EndingUnit__c = 0;
        tier.zqu__IsOveragePrice__c = false;
        tier.zqu__Price__c = 10;
        tier.zqu__PriceFormat__c = 'Per Unit';
        tier.zqu__ProductRatePlanCharge__c = charge.Id;
        tier.zqu__StartingUnit__c = 0;
        tier.zqu__Tier__c = 1;
        tier.zqu__ZuoraId__c = tierId;
        
        if (doInsert) {
            insert tier;
        }
        return tier;
    }
    private static  List<Id> createCatalog(Boolean isBase, Boolean isVolume, String productId, String rateplanId, String chargeId, String tierId, String uomId) {
        zqu__ZUnitOfMeasure__c uom = createUOM(true, uomId);
        zqu__ZProduct__c prod = createProduct(true, isBase, isVolume, productId);
        zqu__ProductRatePlan__c rateplan = createProductRatePlan(prod, true, rateplanId);

        zqu__ProductRatePlanCharge__c charge = createProductCharge(rateplan, uom, true, chargeId);
        zqu__ProductRatePlanChargeTier__c tier = createProductTier(charge, true, tierId);
        
        /*z_CreateCatalogResult result = new z_CreateCatalogResult();
result.sProductId = prod.Id;
result.sProductRatePlanId = rateplan.Id;
result.sProductRatePlanChargeId = charge.Id;	*/
        List<Id> productRatePlanIds = new List<Id>();
        productRatePlanIds.add(rateplan.Id);
        
        return productRatePlanIds;
    }
    
    private static List<zqu.zChargeGroup> getzChargeGroup(Integer grouptype, List<zqu__Quote__c> quotes) {
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        
        for(zqu__Quote__c quote : quotes) {
            /*zqu.zChargeGroup chargeGroup;
            chargeGroup.groupID=123;
            chargeGroup.productId;
            chargeGroup.productName;
            chargeGroup.productRatePlanId;
            chargeGroup.productRatePlanZuoraID;
            chargeGroup.quote = quote;
            chargeGroup.ratePlanName;*/
            // chargeGroup.quote.id = 'null';
        }
        
        
        
        return chargeGroups;
    }
    
    private static zqu__ZUnitOfMeasure__c createUOM(Boolean doInsert, String uomId) {
        zqu__ZUnitOfMeasure__c uom = new zqu__ZUnitOfMeasure__c();
        uom.Name = 'Each';
        uom.zqu__Active__c = true;
        uom.zqu__Uom_precision__c = 0;
        uom.zqu__Uom_rounding_mode__c = 'Up';
        uom.zqu__ZuoraId__c = uomId;
        
        if (doInsert) {
            insert uom;
        }
        return uom;
    }
    
    private static List<zqu__ProductRatePlanCharge__c> CreateProductRatePlanCharge(Integer quantity) {
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlan__c> productRatePlanList = creatProductRatePlan(quantity);
        
        for(Integer i=0 ; i<quantity ; i++ ) {
            zqu__ProductRatePlanCharge__c productRatePlanCharge = new zqu__ProductRatePlanCharge__c();
            productRatePlanCharge.Name = 'productRatePlanCharge' + i;
            productRatePlanCharge.zqu__ZuoraId__c = 'someZuoraID' + i;
            productRatePlanCharge.zqu__ProductRatePlan__c = productRatePlanList[i].id;
            productRatePlanChargeList.add(productRatePlanCharge);
        }
        insert productRatePlanChargeList;
        return productRatePlanChargeList;
    }    
    
    
    
    private static List<zqu__ProductRatePlan__c> creatProductRatePlan(Integer quantity) {
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
        List<zqu__ZProduct__c> produtList = [select id, name, zqu__ZuoraId__c from zqu__ZProduct__c where zqu__ZuoraId__c = 'SomeZuoraId0' or zqu__ZuoraId__c = 'SomeZuoraId0'];
        
        for(Integer i=0 ; i<quantity ; i++ ) {
            zqu__ProductRatePlan__c prdRatePlan = new zqu__ProductRatePlan__c();
            prdRatePlan.zqu__ZProduct__c = produtList[0].id;
            prdRatePlan.zqu__ZuoraId__c = 'prdRatePlanZuoraID' + i;
            productRatePlanList.add(prdRatePlan);
        }
        insert productRatePlanList;
        return productRatePlanList;
    }
    
    
    
    private static void createLocale(Integer quantity) {
        
        List<Locale__c> localeList = new List<Locale__c>();
        for(Integer i=0 ; i<quantity ; i++ ) {
            
            Locale__c locale = new Locale__c();
            locale.Name = 'fr_FR';
            locale.LanguageLocaleKey__c = 'fr_CA';
            locale.Language__c = 'french';
            localeList.add(locale);
        }
        localeList[0].Name = 'en_us';
        localeList[0].LanguageLocaleKey__c = 'en_US';
        localeList[0].Language__c = 'english';
        
        insert localeList;
    }
    
    private static List<zqu__Quote__c> createzQuote(Integer quantity) {
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        
        List<Account> accountList = createAccount(quantity);
        
        for(Integer i=0 ; i<quantity ; i++ ) {
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'Test' + i;
            quote.zqu__Account__c = accountList[i].id;
            quoteList.add(quote);
        }
        insert quoteList;
        return quoteList;
    }
    
    
    private static List<Account> createAccount(Integer quantity) {
        
        List<Account> accList = new List<Account>();
        List<Locale__c> localeList = [SELECT id, Name from Locale__c where Name = 'en_us' or Name = 'fr_FR'];
        
        for(Integer i=0 ; i<quantity ; i++ ) {
            Account acc = new Account();
            acc.Name = 'Test' + i;
            acc.Locale__c = null;
            acc.Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100000))+Datetime.now().millisecond()+i);
            accList.add(acc);
        }
        insert accList;
        
        for(Integer i=0 ; i<quantity ; i++) {
            accList[i].Locale__c = localeList[i].Id;
        }
        update accList;
        
        return accList;
    }
    
    private static void createZProductChargeNameMapping() {
        List<ZProductChargeNameMapping__c> productChargeNameMappingList = new List<ZProductChargeNameMapping__c>();
        
        ZProductChargeNameMapping__c productChargeNameMapping01 = new ZProductChargeNameMapping__c();
        //productChargeNameMapping01.
        
        List<zqu__ZProduct__c> productList = createZProduct(2);
        
        List<Locale__c> locale = [SELECT id, Name, Tax_Text__c from Locale__c where Name = 'en_us' or Name = 'fr_FR'];
        
        productChargeNameMapping01.Locale__c = locale[0].Id;
        productChargeNameMapping01.ZProduct__c = productList[0].id;
        productChargeNameMapping01.TranslatedProductName__c = 'French';
        
        productChargeNameMappingList.add(productChargeNameMapping01);
        
        ZProductChargeNameMapping__c productChargeNameMapping02 = new ZProductChargeNameMapping__c();
        productChargeNameMapping02.Locale__c = locale[1].Id;
        productChargeNameMapping02.ZProduct__c = productList[1].id;
        productChargeNameMapping02.TranslatedProductName__c = 'French';
        
        productChargeNameMappingList.add(productChargeNameMapping02);
        
        insert productChargeNameMappingList;        
    }
    
    private static List<zqu__ZProduct__c> createZProduct(Integer quantity) {
        
        List<zqu__ZProduct__c> productsList = new List<zqu__ZProduct__c>();
        for(Integer i=0 ; i<quantity ; i++ ) {
            zqu__ZProduct__c product = new zqu__ZProduct__c();
            product.Name = 'Sage Live Premium' + i;
            product.zqu__SKU__c = 'SKU' + i;
            product.zqu__ZuoraId__c= 'SomeZuoraId' + i;
            productsList.add(product);
        }
        
        insert productsList;
        return productsList;
    }
}