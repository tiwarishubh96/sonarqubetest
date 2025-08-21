/***
* @description Test class for the sfpegGetFieldsetData_CTL class.
* @author      P-E GROS
* @date        Dec. 2020
* @see         sfpegGetFieldsetData_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public class sfpegGetFieldsetData_CTL_TST {
    
/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');

        System.debug('testSetup: END');
    }


/***
* @description Tests the "getData" method.
***/
    
    static TestMethod void testGetData() {
        System.debug('testGetData: START'); 

        ApexClass ac = [SELECT NameSpacePrefix FROM ApexClass
                        WHERE Name LIKE 'sfpegGetFieldSet_CTL_TST'];
        System.debug('testGetData: NameSpace extracted' + ac);
        String nsRoot = (ac.NameSpacePrefix == null ? '' : ac.NameSpacePrefix + '__');
        String FieldSetName =  nsRoot + 'sfpegTest__c.' + nsRoot + 'TestFS';
        System.debug('testGetData: FieldSetName init' + FieldSetName);

        Test.startTest();
        
        sfpegTest__c newTest = new sfpegTest__c(Name = 'Test1',Data__c = 'Data1');
        insert newTest;
        sfpegGetFieldsetData_CTL.DataRequest newReq = new sfpegGetFieldsetData_CTL.DataRequest();
        newReq.records = new List<SObject>();
        newReq.records.add(newTest);
        newReq.fieldset = FieldSetName;
        newReq.fieldNames = 'CreatedById';
        List<sfpegGetFieldsetData_CTL.DataRequest> requests = new List<sfpegGetFieldsetData_CTL.DataRequest>();
        requests.add(newReq);
        System.debug('testGetData: test data ready ' + requests); 

        List<List<SObject>>  results;
        try {
	        results = sfpegGetFieldsetData_CTL.getData(null);
            System.debug('testGetData: null request fetched ' + results); 
            system.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetData: null request error / ' + e.getMessage());  
            system.assert(true);           
        }

        try {
	        results = sfpegGetFieldsetData_CTL.getData(requests);
            System.debug('testGetData: good request fetched ' + results); 
            system.assertEquals(results.size(),1);
            system.assertEquals(results[0].size(),1);
        }
        catch (Exception e) {
            System.debug('testGetData: good request error / ' + e.getMessage());  
            system.assert(false);           
        }

        newReq.fieldset = 'dummy';
        try {
	        results = sfpegGetFieldsetData_CTL.getData(requests);
            System.debug('testGetData: dummy FS request fetched ' + results); 
            system.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetData: dummy FS request error / ' + e.getMessage());  
            system.assert(true);           
        }

        Test.stopTest();
        System.debug('testGetData: END');
    }

}