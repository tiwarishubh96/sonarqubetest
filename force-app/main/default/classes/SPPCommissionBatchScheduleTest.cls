/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPCommissionBatchSchedule
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPCommissionBatchScheduleTest
{
    //Test method to schedule SPPCommissionBatchSchedule class.
    @isTest
    static void scheduleAgainTest()
    {
        Test.StartTest();
        SPPCommissionBatchSchedule sh1 = new SPPCommissionBatchSchedule();
        sh1.scheduleAgain();
        Test.stopTest(); 

    }
    
}