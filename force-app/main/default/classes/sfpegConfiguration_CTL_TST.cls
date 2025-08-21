/***
* @description Test class for the sfpegConfiguration_CTL class.
* @author      P-E GROS
* @date        Nov. 2019
* @see         sfpegConfiguration_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public class sfpegConfiguration_CTL_TST {

/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');

        System.debug('testSetup: END');
    }

/***
* @description Tests the "getData".
***/
    static TestMethod void testGetData() {
        System.debug('testGetData: START'); 
        Test.startTest();

        List<String> testList = new List<String>();
        testList.add('Report.SF_PEG_DUMMY_REPORT');
        testList.add('Report.SF_PEG_DUMMY_REPORT2');
        testList.add('Dashboard.SF_PEG_DUMMY_DASHBOARD');
        testList.add('Folder.SF_PEG_DUMMY_FOLDER');
        testList.add('VFP.SF_PEG_DUMMY_VFP');

        Map<String,String> testMap = sfpegConfiguration_CTL.getData(testList);
        System.debug('testGetData: empty testMap fetched' + testMap);
        System.assertEquals(1,testMap.size());
        // Only VFP works...

        try {
            testList.add('Test');
            sfpegConfiguration_CTL.getData(testList);
            //sfpegConfiguration_CTL.getFieldSetDesc('Account.SF_PEG_DUMMY_FIELDSET');
            System.debug('testGetData: no exception raised for Test');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetData: exception raised for Test' + e.getMessage());
            System.assert(true);
        }

        try {
            testList = new List<String>();
            testList.add('Test.Test');
            sfpegConfiguration_CTL.getData(testList);
            //sfpegConfiguration_CTL.getFieldSetDesc('Account.SF_PEG_DUMMY_FIELDSET');
            System.debug('testGetData: no exception raised for Test.Test');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetData: exception raised for Test.Test' + e.getMessage());
            System.assert(true);
        }

        Test.stopTest();
        System.debug('testGetData: END');
    }

/***
* @description Tests the "getFieldSetDesc" method.
***/
    static TestMethod void testGetFieldSetDesc() {
        System.debug('testGetFieldSetDesc: START'); 
        Test.startTest();

        try {
            List<String> nameList = new List<String>();
            nameList.add('Account.SF_PEG_DUMMY_FIELDSET');
            sfpegConfiguration_CTL.getFieldSetDescs(nameList);
            //sfpegConfiguration_CTL.getFieldSetDesc('Account.SF_PEG_DUMMY_FIELDSET');
            System.debug('testGetFieldSetDesc: no exception raised');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised' + e.getMessage());
            System.assert(true);
        }

        try {
            List<String> nameList = new List<String>();
            nameList.add('Test.Test');
            sfpegConfiguration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised for Test.Test');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised for Test.Test' + e.getMessage());
            System.assert(true);
        }

        try {
            List<String> nameList = new List<String>();
            nameList.add('Test');
            sfpegConfiguration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised for Test');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised for Test' + e.getMessage());
            System.assert(true);
        }
        
        Test.stopTest();
        System.debug('testGetFieldSetDesc: END');
    }

/***
* @description Tests the "getFieldSetDesc" method.
***/
    static TestMethod void testGetSoqlQueryDesc() {
        System.debug('testGetSoqlQueryDesc: START'); 
        Test.startTest();

        try {
            sfpegConfiguration_CTL.getSoqlQueryDesc('SF_PEG_DUMMY_QUERY');
            System.debug('testGetSoqlQueryDesc: no exception raised');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetSoqlQueryDesc: exception raised' + e.getMessage());
            System.assert(true);
        }
        
        Test.stopTest();
        System.debug('testGetSoqlQueryDesc: END');
    }
}