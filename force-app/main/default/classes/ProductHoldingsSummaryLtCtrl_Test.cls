/**
* Test class for ProductHoldingsSummaryLtCtrl
* @author cjbradshaw
* @date June 2019
*/
@isTest
public with sharing class ProductHoldingsSummaryLtCtrl_Test {
   



    @isTest
    public static void testGetProductHoldings() {
        VW_Connect_ProductHoldings__x mockProdHoldings = new VW_Connect_ProductHoldings__x(
            NoOfCompanies__c='1',
            NoOfEmployees__c='100',
            NoOfUsers__c='4',
            ProductHoldingStatus__c='NR',
            ProductHolding_Key__c = 456568,
            ProductID__c='42291',
            ProductName__c='L100 COMMERCIALS M/U',
            ProductType__c='Line 100',
            ProductVersion__c='8.0',
            SalesforceAccountId__c='0019E000010LxfwQAC',
            SerialNumber__c='0213073D',
            SupportExpiryDate__c=Date.today().addDays(7),
            SupportTier__c='1.0',
            ValidCover__c=1);
        ProductHoldingsSummaryLtCtrl.mockedProdHolingResponse.add(mockProdHoldings);
        Test.startTest();
            List<VW_Connect_ProductHoldings__x> productHoldings = ProductHoldingsSummaryLtCtrl.getProductHoldings('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(1, productHoldings.size(),'Should have returned 1 record');
        System.assertEquals('L100 COMMERCIALS M/U', productHoldings[0].ProductName__c);
    }


      @isTest
    public static void testGetProductHoldingModules(){
        VW_Connect_ProductHoldingModules__x phModule = new VW_Connect_ProductHoldingModules__x(
            NoOfCompanies__c='1',
            NoOfEmployees__c='5',
            ProductName__c ='Sage 50 Accounts Foreign Trader',
            NoOfUsers__c='4',
            ProductHoldingStatus__c='NR',
            ProductHoldingModules_Key__c = 456568,
            ProductID__c='42291',
            RegistrationDate__c=Date.today().addMonths(-7)
        );
        ProductHoldingsSummaryLtCtrl.mockedProdHolingModResponse.add(phModule);
        Test.startTest();
            List<VW_Connect_ProductHoldingModules__x> productHoldingModules = ProductHoldingsSummaryLtCtrl.getProductHoldingModules('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(1, productHoldingModules.size(),'Should have returned 1 record');
        System.assertEquals('5', productHoldingModules[0].NoOfEmployees__c);

    }
}