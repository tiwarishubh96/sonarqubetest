@isTest
public class getLocalevaluefromMappingTest {
    @isTest static void accountNotNULLTest() {
        datafactoryfortesting.createPCL();
        getLocalevaluefromMapping.getlocalefromMapping('en_US', 'US');
    }
    @isTest static void accountNULLTest() {
        datafactoryfortesting.createPCL();
        getLocalevaluefromMapping.getlocalefromMapping('', 'US');
    }
}