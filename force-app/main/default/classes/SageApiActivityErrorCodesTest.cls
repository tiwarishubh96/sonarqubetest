@IsTest
private class SageApiActivityErrorCodesTest
{
    @IsTest(SeeAllData=false) static void testStaticVariables()
    {
        System.assertNotEquals( null, SageApiActivityErrorCodes.RequiredItemMissing );
        System.assertNotEquals( null, SageApiActivityErrorCodes.ValueOutOfRange );
        System.assertNotEquals( null, SageApiActivityErrorCodes.InvalidValue );
        System.assertNotEquals( null, SageApiActivityErrorCodes.UnhandledException );
    }

}