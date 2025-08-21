public class PayNowConfiguration {
    
    public static string Get(string key){
        string returnValue = '';
        try
        {
            PayNowSetting__c pnTemplateName = PayNowSetting__c.getInstance(key);
            if (pnTemplateName == null) {
                System.debug('PayNow configuration key (' + key + ') missing');
                return '';
            }
            returnValue = pnTemplateName.Value__c;
        }
        catch(Exception ex) 
        {
            System.debug('PayNowConfiguration.Get('+key+') error: '+ ex);
        }
        return returnValue;
    }
}