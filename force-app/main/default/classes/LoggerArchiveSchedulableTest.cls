/**
 * @description Logger archive schedule job test
 * Tests for LoggerArchiveSchedulable class and CleanUpBatch
 * @author Pete Wilson
 */
@IsTest
public class LoggerArchiveSchedulableTest {
    @TestSetup
    static void setupLoggerData() {
        List <Logger__c> testLogs = new List<Logger__c>();
        Logger__c log1 = new Logger__c(Name='LOG1', Record_Details__c='Purge');
        Logger__c log2 = new Logger__c(Name='LOG2', Record_Details__c='Purge');
        testLogs.add(log1);
        testLogs.add(log2);
        insert testLogs;
    }

    /**
     * Test: running LoggerArchiveSchedulable gets scheduled
     */
    @IsTest
    static void testLoggerSchedulable() {
        CleanUpSetting__c cus = new CleanUpSetting__c(Name = 'LoggerArchiveSchedulable', Archive_Before_Days__c = 90);
        insert cus;

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('CleanUpTest.testCleanUpSchedulable', '0 30 0 1 12 ? 2099', new LoggerArchiveSchedulable());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals('0 30 0 1 12 ? 2099', ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('00:30:00'));

        // check here - batch has not run yet
        Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(0, runningJobs);

        // force schedule to run
        Test.stopTest();

        // batch has started - but will complete after this test.
        runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, runningJobs);
    }

    /**
     * Test: running LoggerArchiveSchedulable gets scheduled, custom setting present with zero value
     */
    @IsTest
    static void testLoggerSchedulableZeroSetting() {
        CleanUpSetting__c cus = new CleanUpSetting__c(Name = 'LoggerArchiveSchedulable', Archive_Before_Days__c = 0);
        insert cus;

        Test.startTest();
        // Schedule the test job
        System.schedule('CleanUpTest.testCleanUpSchedulable', '0 30 0 1 12 ? 2099', new LoggerArchiveSchedulable());

        // check here - batch has not run yet
        Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(0, runningJobs);

        // force schedule to run
        Test.stopTest();

        // batch has started - but will complete after this test.
        runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, runningJobs);
    }

    /**
     * Test: scheduleAgain method execution with no custom setting for Logger__c cleanup available
     */
    @IsTest
    static void testScheduleAgain() {
        // NO CUSTOM SETTING AT THIS POINT - JOB WILL NOT BE SCHEDULED
        Test.startTest();
        LoggerArchiveSchedulable sched = new LoggerArchiveSchedulable();
        sched.scheduleAgain();
        Test.stopTest();	// forces schedule to run
        Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(0,runningJobs);
    }

    /**
     * Test: scheduleAgain method execution
     */
    @IsTest
    static void testScheduleAgainWithSettings() {
        // Full purge, zero day setting
        CleanUpSetting__c cus = new CleanUpSetting__c(Name = 'LoggerArchiveSchedulable', Archive_Before_Days__c = 10);
        insert cus;
        Test.startTest();
        LoggerArchiveSchedulable sched = new LoggerArchiveSchedulable();
        sched.scheduleAgain();
        Test.stopTest();	// forces schedule to run
        Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1,runningJobs);
    }

    /**
     * Test: Logger Cleanup
     */
    @IsTest
    static void testLoggerCleanUp() {
        CleanUpSetting__c cus = new CleanUpSetting__c(Name = 'LoggerArchiveSchedulable', Archive_Before_Days__c = 10);
        insert cus;
        // The query used by the batch job.
        String query = 'SELECT Id FROM Logger__c WHERE CreatedDate < LAST_N_DAYS:10';

        Test.startTest();

        CleanUpBatch c = new CleanUpBatch(query, 'Logger__c', 'LoggerArchiveTest');
        Database.executeBatch(c);

        Test.stopTest();

        // all our logs are recent, so none should have been deleted
        Integer remainingLogs = [SELECT COUNT() FROM Logger__c WHERE Record_Details__c = 'Purge'];
        System.assertEquals(2, remainingLogs);
    }

    /**
     * Test: Logger Cleanup with zero day setting
     */
    @IsTest
    static void testLoggerCleanUpZeroSetting() {
        CleanUpSetting__c cus = new CleanUpSetting__c(Name = 'LoggerArchiveSchedulable', Archive_Before_Days__c = 0);
        insert cus;
        // The query used by the batch job.
        String query = 'SELECT Id FROM Logger__c';

        Test.startTest();

        CleanUpBatch c = new CleanUpBatch(query, 'Logger__c', 'LoggerArchiveTest');
        Database.executeBatch(c);

        Test.stopTest();

        // all our logs are recent, but should have been deleted due to the zero-value archive setting which removes all records
        Integer remainingLogs = [SELECT COUNT() FROM Logger__c WHERE Record_Details__c = 'Purge'];
        System.assertEquals(0, remainingLogs);
    }
}