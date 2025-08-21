@isTest
public class QuoteChargeSummaryTriggerHandlerTest {

    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   
    private static String zuoraId2 = '2c92c0f84dfff49f014e021c79b82bb7';


    static testMethod void testNewSubscription(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);

        // setup product tier and product tier rate plan lists
        Product2 prod = TestDataUtility.createZProduct('Sage Business Cloud Financials', zuoraId);
        zqu__ProductRatePlan__c ratePlan = TestDataUtility.createRatePlan(prod.Id, 'Monthly', zuoraId);
        ratePlan.ExternalApplication__c = 'Tetris';
        update ratePlan;

        zqu__ProductRatePlanCharge__c ratePlanCharge = new zqu__ProductRatePlanCharge__c();
        ratePlanCharge.zqu__ProductRatePlan__c=ratePlan.id;
        ratePlanCharge.zqu__ZuoraId__c=zuoraId;
        insert ratePlanCharge;

        System.debug('ratePlanCharge' +ratePlanCharge.id);

        zqu__QuoteAmendment__c amendmentQuote= new zqu__QuoteAmendment__c();
        amendmentQuote.Name='Translate Product Amendement QUote';
        amendmentQuote.zqu__Quote__c=zquote.id;
        insert amendmentQuote;

        System.debug('amendmentQuote' +amendmentQuote.id);

        zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
        quoteRatePlan.zqu__Quote__c=zquote.Id;
        quoteRatePlan.zqu__QuoteAmendment__c=amendmentQuote.id;
        insert quoteRatePlan;

        System.debug('quoteRatePlan' +quoteRatePlan.id);


        Product_Tier__c pTier = TestDataUtility.createProductTier(prod.Id, 'Sage Business Cloud Financials FR', 'Financials-FR');
        Product_Tier_Rate_Plan__c pTierRate = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Monthly');
        Product_Tier_Rate_Plan__c pTierRate1 = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Annual');

        //zqu__QuoteCharge__c quoteCharge = new zqu__QuoteCharge__c();
        //quoteCharge.zqu__ProductRatePlanCharge__c=ratePlanCharge.Id;
        //quoteCharge.zqu__Quote__c=zquote.Id;
        //insert quoteCharge;
        //System.debug('quoteCharge' +quoteCharge.id);


        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
        quoteRatePlanCharge.zqu__QuoteRatePlan__c=quoteRatePlan.Id;
        insert quoteRatePlanCharge;
        List<zqu__QuoteChargeSummary__c> listSummaries = [select id from zqu__QuoteChargeSummary__c
        where zqu__QuoteRatePlanCharge__c=:quoteRatePlanCharge.id];

        System.debug('Summary Insert ' +listSummaries.size());
        System.debug('quoteRatePlanCharge' +quoteRatePlanCharge.id);
        update quoteRatePlanCharge;
        System.debug('quoteRatePlanCharge' +quoteRatePlanCharge.id);

        List<zqu__QuoteChargeSummary__c> listupdateSummaries = [select id from zqu__QuoteChargeSummary__c
        where zqu__QuoteRatePlanCharge__c=:quoteRatePlanCharge.id];
        System.debug('Summary Upsert ' +listupdateSummaries.size());
        zqu__QuoteChargeSummary__c quoteChargeSummary = new zqu__QuoteChargeSummary__c();
        quoteChargeSummary.zqu__QuoteRatePlan__c=quoteRatePlan.Id;
        insert quoteChargeSummary;
        RecursiveTriggerHandler.isFirstTime = true;
        System.debug('quoteChargeSummary'+quoteChargeSummary.id);
        update quoteChargeSummary;

    }

    static testMethod void testNewSubscription2(){
        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, zuoraId);

        // setup product tier and product tier rate plan lists
        Product2 prod = TestDataUtility.createZProduct('Sage Business Cloud Financials', zuoraId);
        zqu__ProductRatePlan__c ratePlan = TestDataUtility.createRatePlan(prod.Id, 'Monthly', zuoraId);
        ratePlan.ExternalApplication__c = 'Tetris';
        update ratePlan;


        zqu__ProductRatePlanCharge__c ratePlanCharge = new zqu__ProductRatePlanCharge__c();
        ratePlanCharge.zqu__ProductRatePlan__c=ratePlan.id;
        ratePlanCharge.zqu__ZuoraId__c=zuoraId;
        insert ratePlanCharge;

        System.debug('ratePlanCharge' +ratePlanCharge.id);

        zqu__QuoteAmendment__c amendmentQuote= new zqu__QuoteAmendment__c();
        amendmentQuote.Name='Translate Product Amendement QUote';
        amendmentQuote.zqu__Quote__c=zquote.id;
        insert amendmentQuote;

        System.debug('amendmentQuote' +amendmentQuote.id);

        zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
        quoteRatePlan.zqu__Quote__c=zquote.Id;
        quoteRatePlan.zqu__QuoteAmendment__c=amendmentQuote.id;
        quoteRatePlan.zqu__ProductRatePlan__c = ratePlan.Id;
        insert quoteRatePlan;

        System.debug('quoteRatePlan' +quoteRatePlan.id);


        Product_Tier__c pTier = TestDataUtility.createProductTier(prod.Id, 'Sage Business Cloud Financials FR', 'Financials-FR');
        Product_Tier_Rate_Plan__c pTierRate = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Monthly');
        Product_Tier_Rate_Plan__c pTierRate1 = TestDataUtility.createProductTierRatePlan(pTier.Id, ratePlan.Id, loc.Id, 'Annual');

        //zqu__QuoteCharge__c quoteCharge = new zqu__QuoteCharge__c();
        //quoteCharge.zqu__ProductRatePlanCharge__c=ratePlanCharge.Id;
        //quoteCharge.zqu__Quote__c=zquote.Id;
        //insert quoteCharge;
        //System.debug('quoteCharge' +quoteCharge.id);


        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
        quoteRatePlanCharge.zqu__QuoteRatePlan__c=quoteRatePlan.Id;
        insert quoteRatePlanCharge;
        List<zqu__QuoteChargeSummary__c> listSummaries = [select id from zqu__QuoteChargeSummary__c
        where zqu__QuoteRatePlanCharge__c=:quoteRatePlanCharge.id];

        System.debug('Summary Insert ' +listSummaries.size());
        System.debug('quoteRatePlanCharge' +quoteRatePlanCharge.id);
        update quoteRatePlanCharge;
        System.debug('quoteRatePlanCharge' +quoteRatePlanCharge.id);

        List<zqu__QuoteChargeSummary__c> listupdateSummaries = [select id from zqu__QuoteChargeSummary__c
        where zqu__QuoteRatePlanCharge__c=:quoteRatePlanCharge.id];
        System.debug('Summary Upsert ' +listupdateSummaries.size());
        zqu__QuoteChargeSummary__c quoteChargeSummary = new zqu__QuoteChargeSummary__c();
        quoteChargeSummary.zqu__QuoteRatePlan__c=quoteRatePlan.Id;
        insert quoteChargeSummary;
        RecursiveTriggerHandler.isFirstTime = true;
        System.debug('quoteChargeSummary'+quoteChargeSummary.id);
        update quoteChargeSummary;

    }

}