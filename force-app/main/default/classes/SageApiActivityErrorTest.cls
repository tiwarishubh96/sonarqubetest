/**
 * @description Written by Salesforce Services on behalf of Mick Andrew’s team for code coverage.
 * 
 *              Tests for associated class.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest(SeeAllData=false)
private class SageApiActivityErrorTest
{
    static private void setup()
    {
        //TestData.setup();
    }

    @IsTest static void testEmptyConstructorInitialisesWithoutErrors()
    {
        setup();
    
        Test.startTest();

            SageApiActivityError err;
        
            try {
                err = new SageApiActivityError();
            }
            catch( Exception ex ) {
                TestExc.isExcThrown = true;
            }
    
        Test.stopTest();

        System.assertEquals( null, err.code );
        System.assertEquals( null, err.target );
        System.assertEquals( null, err.message );

        System.assertEquals( false, TestExc.isExcThrown, 'Constructor initialised with exception' );
    }

    @IsTest static void testConstructorInitialisesWithoutErrors()
    {
        setup();
    
        
    
        Test.startTest();

            SageApiActivityError err;
        
            try {
                err = new SageApiActivityError( '123', 'unknown', 'explanation here' );
            }
            catch( Exception ex ) {
                TestExc.isExcThrown = true;
            }
    
        Test.stopTest();

        System.assertNotEquals( null, err.code );
        System.assertNotEquals( null, err.target );
        System.assertNotEquals( null, err.message );

        System.assertEquals( false, TestExc.isExcThrown, 'Constructor initialised with exception' );
    }
}