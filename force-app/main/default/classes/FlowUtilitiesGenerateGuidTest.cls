@IsTest
private class FlowUtilitiesGenerateGuidTest {
    @IsTest
    static void testGenerateGuid() {
        Test.startTest();
            List<String> guids = FlowUtilitiesGenerateGuid.generateGuid();
            System.assert(!guids.isEmpty() && String.isNotBlank(guids[0]));
        Test.stopTest();
    }
}