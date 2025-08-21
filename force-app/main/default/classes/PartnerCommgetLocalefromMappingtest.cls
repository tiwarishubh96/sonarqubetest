@isTest
public class PartnerCommgetLocalefromMappingtest {
    
    @isTest static void invokeDescribeTest() {
        PartnerCommgetLocalefromMapping plugin = new PartnerCommgetLocalefromMapping();
        Map<String,Object> inputParams  = new Map<String,Object>();
        
        string testLoc = 'en_US';
        string testISO = 'US';
        inputParams.put('varAccountLocaleName', testLoc);
        inputParams.put('varAccountIsoCode', testISO);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.invoke(request);
        plugin.describe();
    }
}