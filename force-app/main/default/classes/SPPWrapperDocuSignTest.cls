/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPWrapperDocuSign
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/


@isTest
private class SPPWrapperDocuSignTest
{
    @isTest
    static void SPPWrapperDocuSignTest()
    {
        SPPWrapperDocuSign sp = new SPPWrapperDocuSign();
        SPPWrapperDocuSign obj = SPPWrapperDocuSign.parseJson('{"envelopeId":"test"}'); 
        System.debug(obj);

        System.assertEquals(obj.envelopeId , 'test');
        SPPWrapperDocuSign.BulkEnvelopeStatus innClass = new SPPWrapperDocuSign.BulkEnvelopeStatus();

    }
}