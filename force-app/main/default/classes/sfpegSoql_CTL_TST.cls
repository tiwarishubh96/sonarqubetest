/***
* @description Test class for the sfpegSoql_CTL class.
* @author      P-E GROS
* @date        Nov. 2019
* @see         sfpegSoql_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public class sfpegSoql_CTL_TST {

/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');


        System.debug('testSetup: END');
    }

/***
* @description Tests the "doQuery".
***/
    static TestMethod void testDoQuery() {
        System.debug('testDoQuery: START'); 
        Test.startTest();

        list<sObject> resultList = sfpegSoql_CTL.doQuery('select Name from Account');
        System.debug('testDoQuery: empty resultList fetched' + resultList);
        system.assertEquals(0,resultList.size());

        try {
            resultList = sfpegSoql_CTL.doQueryStorable('');
            System.debug('testDoQuery: resultList returned' + resultList);
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testDoQuery: exception raised' + e.getMessage());
            System.assert(true);
        }

        Test.stopTest();
        System.debug('testDoQuery: END');
    }

/***
* @description Tests the "doRegisteredQuery".
***/
    static TestMethod void testDoRegisteredQuery() {
        System.debug('testDoRegisteredQuery: START'); 
        Test.startTest();

        try {
            list<sObject> resultList = sfpegSoql_CTL.doRegisteredQuery('TEST','TEST');
            System.debug('testDoRegisteredQuery: resultList returned' + resultList);
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testDoRegisteredQuery: exception raised' + e.getMessage());
            System.assert(true);
        }

        Test.stopTest();
        System.debug('testDoRegisteredQuery: END');
    }
}