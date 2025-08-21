/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPBulkScheduleDocuSign
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPBulkEnvelopsTest {
     @isTest
    static void parseTest()
    {
        SPPBulkEnvelops sppObj = new SPPBulkEnvelops();
        SPPBulkEnvelops.parse('{}');
        
    }

}