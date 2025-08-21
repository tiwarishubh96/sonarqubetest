/**
 * Created by taa on 07/05/2020.
 */

@isTest
public class ZRulesEngineCustomActions_Test {

    static testmethod void testRules()
    {


        System.debug('------------------ZRulesEngineCustomActions_Test-------------------------');


        Locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');

        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        Opportunity Opp1 = TestDataUtility.CreateOpportunity(acc.Id,'Opportunity 1');

        //Accounting GB
        Product2 p1 = TestDataUtility.CreateProduct2('Accounting GB','TEST00000P1');

        zqu__ZProduct__c zp1 = TestDataUtility.CreateZproduct('zProduct 1',p1.Id);

        zqu__ProductRatePlan__c zprp1 = TestDataUtility.Createproductrateplan('zProductRatePlan 1',p1.Id,zp1.Id,'sage:gb:sageone:accounts:t:rrp:monthly:pct');

        zqu__ProductRatePlanCharge__c   zprpc1 = TestDataUtility.createProductRatePlanCharge('zProductRatePlanCharge 1',zprp1.id);

        zprpc1.zqu__Model__c ='Flat Fee Pricing';
        update zprpc1;
        //Payroll GB

        Product2 p2 = TestDataUtility.CreateProduct2('Payroll GB','TEST00000P1');

        zqu__ZProduct__c zp2 = TestDataUtility.CreateZproduct('zProduct 1',p2.Id);

        zqu__ProductRatePlan__c zprp2 = TestDataUtility.Createproductrateplan('zProductRatePlan 1',p2.Id,zp2.Id,'sage:gb:sageone:payroll:t:rrp:monthly:pct');

        zqu__ProductRatePlanCharge__c   zprpc2 = TestDataUtility.createProductRatePlanCharge('zProductRatePlanCharge 1',zprp2.id);

        zprpc2.zqu__Model__c ='Volume Pricing';
        update zprpc2;

        zqu__Quote__c zq1 = TestDataUtility.createZQuoteNewSubscription('zQuote 1',con.id,Opp1.id);

        /*zqu__Quote__c zq2 = [SELECT Id,zqu__StartDate__c from zqu__Quote__c where Id =: zq1.id ];
        zq2.zqu__StartDate__c = date.Today();
        update zq2;

        System.debug('zq2'+zq2);
*/
        zqu.Quote znewQuote = zqu.Quote.getInstance(zq1.id);

        System.debug('znewQuote'+znewQuote);



        zqu.Product[] productsToAdd = zqu.Product.loadProductsWithChildren(new String[] {zp1.id,zp2.id});

        znewQuote.addQuoteProducts(productsToAdd);
        znewQuote.save();

        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(zq1.id, new id[] {zprp1.id,zprp2.id});

        List < zqu.DataObject > dataChargeGroups = new List < zqu.DataObject > ();
        List < zqu.DataObject > dataCharges = new List < zqu.DataObject > ();

        for (zqu.zChargeGroup cgroup : chargeGroups ) {

            system.debug('cgroup.productRatePlanId'+cgroup.productRatePlanId);

            for ( zqu.zCharge charge : cgroup.zCharges ) {
                charge.quantity = '2';
                charge.discount = '10';
                charge.effective_price = '10';

            }

            zqu.zQuoteUtil.calculateChargesOnQuantityChange(cgroup.zCharges);
            zqu.zQuoteUtil.calculateChargesOnDiscountChange(cgroup.zCharges);

            zqu.DataObject dataChargeGroup = new zqu.ZChargeGroupDataObject(cgroup);

            //dataChargeGroup.putParent('zqu__ProductRatePlan__c',cgroup.productRatePlanId);
            dataChargeGroup.put('zqu__ProductRatePlan__c',cgroup.productRatePlanId);
            system.debug('Product rate plan charge group:::' + dataChargeGroup.get('zqu__ProductRatePlan__c'));



            dataChargeGroups.add(dataChargeGroup);
            dataCharges.addAll(dataChargeGroup.getChildren(
                    'QuoteRatePlanCharge__c'));
        }

        System.debug('chargeGroups::::: '+chargeGroups);

        chargeGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);

        //zqu__QuoteRatePlan__c[] quoteRatePlans = [select id,zqu__ProductRatePlan__c from zqu__QuoteRatePlan__c];

        //System.debug('quoteRatePlan'+quoteRatePlans);

        zqu__QuoteRatePlanCharge__c[] quoteRatePlanCharges = [select id from zqu__QuoteRatePlanCharge__c];

        System.debug('quoteRatePlanCharges'+quoteRatePlanCharges);


        zqu__Quote__c[] quoteObj = [select id,name,zqu__ZuoraAccountID__c,zqu__InvoiceID__c from zqu__Quote__c];

        System.debug('-------------quoteobj----------------------------::::'+quoteObj);

        //source https://knowledgecenter.zuora.com/CPQ/I_Development_Resources/C_Component_Library/C_Global_Classes/D1_RulesEngine_Class
        // Step #1
// Set the master quote id. Rules are all run in the context of this record.
// Required Ids are the Ids of records that need to be queried from database.
        String quoteId = (String) quoteObj[0].Id;
        Set < zqu.CacheId > requiredIds = new Set < zqu.CacheId > ();
        requiredIds.add( new zqu.CacheId( 'zqu__Quote__c', quoteId ) );


        //Create rule id

        zqu__ZRule__c zRule = new zqu__ZRule__c();

        zrule.Name = 'test rule';
        zrule.zqu__active__c = true;
        zrule.zqu__ObjectType__c = 'zqu__Quote__c';
        zrule.zqu__Json__c = '{"criteriaType":"CONJUNCTION_CRITERIA","operationType":"OR_TYPE","parameters":[{"operationType":"EQUAL","dataType":"STRING_TYPE","criteriaType":"COMPARISON_CRITERIA","leftTerm":{"valueType":"OBJECTFIELD_VAL","dataType":"STRING_TYPE","baseObject":"zqu__Quote__c","fieldPath":"zqu__Quote__c.zqu__SubscriptionType__c"},"rightTerm":{"valueType":"CONSTANT_VAL","dataType":"STRING_TYPE","value":"New Subscription"}}]}';
        zrule.zqu__ActionJson__c = '[{"actionType":"CUSTOM_ACTION","className":"ZRulesEngineCustomActions","attributes":{"scenario":"cross-sell"}}]';

    insert zrule;

// Step #2
// Optionally, supply a subset of rules.
        List < zqu__ZRule__c > rulesToRun =
        [SELECT Id, Name, zqu__Json__c, zqu__ActionJson__c FROM zqu__ZRule__c LIMIT 5];

// Step #3
// Convert Charge Groups to DataObject
// and attach those to the quote DataObject as children.
// DataObjects are objects that are in memory, but not in the database.
// For example, ChargeGroups that have not yet been saved
        //Map < String, List < zqu.DataObject > > dataObjects = makeDataObjects(quoteId);
        Map < String, List < zqu.DataObject > > dataObjects = new Map < String, List < zqu.DataObject > >{
                'QuoteRatePlan__c' => dataChargeGroups,
                'QuoteRatePlanCharge__c' => dataCharges
        };
// Step #4
// Initialize the Rules Engine with the API name of master object
// and a subset of rules.
        zqu.RulesEngine re = new zqu.RulesEngine('zqu__Quote__c', rulesToRun);
        re.initialize(dataObjects, requiredIds);

// Step #5
// Execute the Rules Engine.
        zqu.RulesEngineResponse response = re.run(zqu.RulesEngine.RuleType.ALL);

        System.debug(response);


    }

    static Map < String, List < zqu.DataObject > > makeDataObjects(Id quoteId) {
        List < zqu.DataObject > dataChargeGroups = new List < zqu.DataObject > ();
        List < zqu.DataObject > dataCharges = new List < zqu.DataObject > ();

        List < zqu.ZChargeGroup > chargeGroups = zqu.zQuoteUtil.getChargeGroups( quoteId );

        // Create a DataObject for ZChargeGroup (QuoteRatePlan)
        // and ZCharges (QuoteRatePlanCharge).
        for(zqu.ZChargeGroup chargeGroup : chargeGroups){

            zqu.DataObject dataChargeGroup = new zqu.ZChargeGroupDataObject(chargeGroup);
            dataChargeGroups.add(dataChargeGroup);
            dataCharges.addAll(dataChargeGroup.getChildren(
                     'QuoteRatePlanCharge__c'));
        }

        return new Map < String, List < zqu.DataObject > >{
                 'QuoteRatePlan__c' => dataChargeGroups,
                 'QuoteRatePlanCharge__c' => dataCharges
        };
    }
}