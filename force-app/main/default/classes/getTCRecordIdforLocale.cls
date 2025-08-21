global class getTCRecordIdforLocale implements Process.Plugin
{
    global Process.PluginResult invoke(Process.PluginRequest request) 
    {  
        String Locale = (String) request.inputParameters.get('varAccountLocaleName');
        Map<String,Object> result = new Map<String,Object>();
        ID tcid = [SELECT Id FROM Terms_Conditions_Community__c WHERE Active__c = true and Community_Only__c = true and Partner_Locale__r.Name =: Locale LIMIT 1].ID;
        try {
            
        } catch(DmlException e) {
            throw new getTCRecordIdforLocaleHandlerException('An unexpected error has occurred: ' + e.getMessage());
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        result.put('TCID',tcid);
        return new Process.PluginResult(result);
        // return tcid;
    }
    
    global Process.PluginDescribeResult describe() 
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Community T&C Version';
        result.Tag = 'Validate TnC';
        result.inputParameters = new
            List<Process.PluginDescribeResult.InputParameter>{
                new Process.PluginDescribeResult.InputParameter('varAccountLocaleName',Process.PluginDescribeResult.ParameterType.String, true)
                    
                    };
                        result.outputParameters = new
                        List<Process.PluginDescribeResult.OutputParameter>{
                            new Process.PluginDescribeResult.OutputParameter('TCID',Process.PluginDescribeResult.ParameterType.ID)
                                
                                };
                                    return result;
    }
    public class getTCRecordIdforLocaleHandlerException extends Exception{}
}