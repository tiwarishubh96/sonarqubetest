@IsTest(SeeAllData=false)
private class TetrisPingService_Test {

    @IsTest
    static void testBehaviour() {
        Test.startTest();

        String response = TetrisPingService.ping();
        System.assertEquals('pong', response);

        Test.stopTest();
    }
}