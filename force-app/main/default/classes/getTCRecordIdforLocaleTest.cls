@isTest
public class getTCRecordIdforLocaleTest {
    static testmethod void correctLocaleTest() {
  Locale__c Localerec= DataFactoryForTesting.createLocale();
        DataFactoryForTesting.createTC_en_US(Localerec);
        
        //instantiated
        getTCRecordIdforLocale plugin = new getTCRecordIdforLocale();
        Map<String,Object> inputParams = new Map<String,Object>();
        
        string test = 'en_US';
        inputParams.put('varAccountLocaleName', test);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.invoke(request);
    }
    
    static testmethod void describeTest() {
         Locale__c Localerec= DataFactoryForTesting.createLocale();
        DataFactoryForTesting.createTC_en_US(Localerec);
        
        //instantiated
        getTCRecordIdforLocale plugin = new getTCRecordIdforLocale();
        Map<String,Object> inputParams = new Map<String,Object>();
        
        string test = 'en_US';
        inputParams.put('varAccountLocaleName', test);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.describe();
    }
}