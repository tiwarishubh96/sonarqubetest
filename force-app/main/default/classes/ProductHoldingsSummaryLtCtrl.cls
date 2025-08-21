/**
* ProductHoldingsSummaryLtCtrl Controller class supporting the ProductHoldingSummary component
* @author cjbradshaw
* @date June 2019
*
*	History
*	VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
*	0.1         Robert Speight   	08/22/2019          Increase Coverage					   EAD-1092	
*
*/
public with sharing class ProductHoldingsSummaryLtCtrl {

    // Challenges: test classes for external objects.
    // eg http://grahambarnard.com/development/2016/02/08/mocking-external-objects/

    // IMPORTANT NOTE!! 
    /* This method should return a subset of the Product Holdings for a given account
       Normally such a restriction would be added to a SOQL where clause
       However in early testing (not thorough) it appear that increasing the where clause was slowing the speed of the query
       This may be due to indices need on the target database

       At present the filtering is now done after the query in apex code.
       There main drawback of this is that we will be pulling back more external object rows into Salesforce and there are limits on this.

       It is recommended to switch to filtering via where clause once we are happy the queries will not be impacted by it.

    */

    /**
    * For supporitng Testing of ext objects - we need to mock out the response
    */
    @TestVisible 
    private static List<VW_Connect_ProductHoldings__x> mockedProdHolingResponse = new List<VW_Connect_ProductHoldings__x>();
    
    @TestVisible 
    private static List<VW_Connect_ProductHoldingModules__x> mockedProdHolingModResponse = new List<VW_Connect_ProductHoldingModules__x>();

    @AuraEnabled
    public static List<VW_Connect_ProductHoldings__x> getProductHoldings(Id accountId) {
        Datetime now = Datetime.now();
        //Increased Test coverage by allowing a conditional assignment the mock data or query 
        List<VW_Connect_ProductHoldings__x> listph = (!mockedProdHolingResponse.isEmpty()) ? mockedProdHolingResponse : [
            SELECT 
            NoOfCompanies__c,
            NoOfEmployees__c,
            NoOfUsers__c,
            ProductHoldingStatus__c,
            ProductHolding_Key__c,
            ProductID__c,
            ProductName__c,
            ProductType__c,
            ProductVersion__c,
            SalesforceAccountId__c,
            SerialNumber__c,
            SupportExpiryDate__c,
            SupportTier__c,
            ValidCover__c,
            SupportLevel__c
            FROM VW_Connect_ProductHoldings__x 
            WHERE SalesforceAccountId__c = :accountId 
            ];
        System.debug(LoggingLevel.DEBUG, 'getProductHoldings->' + listph);
        List<VW_Connect_ProductHoldings__x> retlistph = new List<VW_Connect_ProductHoldings__x>();
        for (VW_Connect_ProductHoldings__x ph : listph) {
            if (ph.SupportExpiryDate__c > now) {
                retlistph.add(ph);
            }
        }
        System.debug(LoggingLevel.DEBUG, 'getProductHoldings->' + retlistph);

        return retlistph;
    } 

    // IMPORTANT NOTE!! 
    /*  This method should return a subset of the Product Holdings Modules for a given account but in reality it may not need all of these
        We only need to have the modules that are asoociated with an active product holding.
        So ideally we should pass this method a list of product holding keys and add to the where clause that we are only looking for module with product keys in that set

        However this has not been implemented as we are not comfortable that the where clause will not negatively impact performance

       It is recommended to switch to adding in the list of product holding keys and filtering via where clause once we are happy the queries will not be impacted by it.

    */


    @AuraEnabled
    public static List<VW_Connect_ProductHoldingModules__x> getProductHoldingModules(Id accountId) {
        //Increased Test coverage by allowing a conditional assignment the mock data or query 
        List<VW_Connect_ProductHoldingModules__x> listphm = (!mockedProdHolingModResponse.isEmpty()) ? mockedProdHolingModResponse :[
            SELECT 
            Id,
            ProductName__c,
            NoOfCompanies__c,
            NoOfEmployees__c,
            NoOfUsers__c,
            ProductHoldingModules_Key__c,
            ModuleVersion__c,
            ProductHoldingStatus__c,
            ProductHolding_Key__c,
            ProductID__c, 
            RegistrationDate__c
            FROM VW_Connect_ProductHoldingModules__x where SalesforceAccountId__c = :accountId ];
         System.debug(LoggingLevel.DEBUG, 'getProductHoldingModules->' + listphm);
        return listphm;
    } 

}