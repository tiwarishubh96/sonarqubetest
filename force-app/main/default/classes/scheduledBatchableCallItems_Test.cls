@istest
public class scheduledBatchableCallItems_Test {
    static testmethod void test() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('test', CRON_EXP, new scheduledBatchableCallItems() );   
        Test.stopTest();
    }
}