/***
* @description Test class for the sfpegForceDML_CTL class.
* @author      P-E GROS
* @date        Dec. 2020
* @see         sfpegForceDML_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public class  sfpegForceDML_CTL_TST {
    
/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');

        System.debug('testSetup: END');
    }


/***
* @description Tests the "executeDML" method.
***/
    
    static TestMethod void testExecuteDML() {
        System.debug('testExecuteDMLs: START'); 
        Test.startTest();
        
        Task newTask = new Task(Subject = 'Test', Status = 'En cours', ActivityDate = date.newinstance(2021,01,01));
        Task newTask2 = new Task(Subject = 'Test2', Status = 'En cours', ActivityDate = date.newinstance(2021,01,02));
        sfpegForceDML_CTL.DmlRequest newRequest = new sfpegForceDML_CTL.DmlRequest();
        newRequest.record = newTask;
        newRequest.operation = 'insert';
        list<sfpegForceDML_CTL.DmlRequest> requestList = new list<sfpegForceDML_CTL.DmlRequest>();
        requestList.add(newRequest);
        System.debug('testExecuteDMLs: data ready'); 
         
        List<SObject> results;
        try {
	        results = sfpegForceDML_CTL.executeDML(null);
            System.debug('testExecuteDMLs: null request fetched' + results); 
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testExecuteDMLs: null request error' + e.getMessage());
            System.assert(true);          
        }
         
        try {
	        results = sfpegForceDML_CTL.executeDML(requestList);
            System.debug('testExecuteDMLs: insert done ' + results); 
            System.assertEquals(results.size(),1);
            System.assertNotEquals(results[0].Id,null);
        }
        catch (Exception e) {
            System.debug('testExecuteDMLs: duplicates error' + e.getMessage());  
            System.assert(false);           
        }

        newTask.Id = results[0].Id;
        newTask.Subject = 'Test Update';
        newRequest.operation = 'update';
        sfpegForceDML_CTL.DmlRequest newRequest2 = new sfpegForceDML_CTL.DmlRequest();
        newRequest2.record = newTask2;
        newRequest2.operation = 'insert';
        requestList.add(newRequest2);
        System.debug('testExecuteDMLs: test data updated ');
        
        try {
	        results = sfpegForceDML_CTL.executeDML(requestList);
            System.debug('testExecuteDMLs: combined DML done ' + results); 
            System.assertEquals(results.size(),2);
        }
        catch (Exception e) {
            System.debug('testExecuteDMLs: combined DML error' + e.getMessage());
            System.assert(false);          
        }

        newTask.Subject = 'Test Failure';
        newRequest.operation = 'dummy';
        try {
	        results = sfpegForceDML_CTL.executeDML(requestList);
            System.debug('testExecuteDMLs: dummy DML done ' + results); 
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testExecuteDMLs: dummy DML error' + e.getMessage()); 
            System.assert(true);            
        }
		
		Test.stopTest();
        
		System.debug('testGetDuplicates: END');
    }

}