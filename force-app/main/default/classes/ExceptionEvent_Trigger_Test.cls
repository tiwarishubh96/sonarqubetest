/**
 * @author      Bhushan Sukumar (bhushan.sukumar@sage.com)
 * @date        26/10/2018
 * @description Test class to validate if ExceptionEvent platform event is creating the necessary exception logs in SF
 */

@IsTest
private class ExceptionEvent_Trigger_Test {
    @IsTest
    static void test_CreateExceptionLog() {
        ExceptionEvent__e eve = new ExceptionEvent__e();
        eve.StackTrace__c = 'This is a test stack trace';
        eve.ErrorMessage__c = 'This is a test error message';
        eve.ExceptionType__c = 'This is a test exception type';
        eve.ExceptionCause__c = 'This is a test cause';

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(eve);
        Test.stopTest();

        System.assert(sr.isSuccess());

        List<Logger__c> logs = [SELECT Id FROM Logger__c WHERE CreatedDate = TODAY];
        System.assert(!logs.isEmpty());
        System.assertEquals(logs.size(),1);
    }
}