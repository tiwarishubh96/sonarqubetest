global class PartnerCommgetLocalefromMapping implements Process.Plugin
{
    global Process.PluginResult invoke(Process.PluginRequest request) 
    {
        String varAccountLocaleName = (String) request.inputParameters.get('varAccountLocaleName');
        String varAccountIsoCode = (String) request.inputParameters.get('varAccountIsoCode');
        
        Map<String,String> result = new Map<String,String>();
        String Locale=getLocalevaluefromMapping.getlocalefromMapping(varAccountLocaleName,varAccountIsoCode);
        result.put('Locale',Locale);
        return new Process.PluginResult(result);
    }

    global Process.PluginDescribeResult describe()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Partner Locale Mapping';
        result.Tag = 'Validate TnC';

        result.inputParameters = new
            List<Process.PluginDescribeResult.InputParameter>{
                new Process.PluginDescribeResult.InputParameter('varAccountLocaleName',Process.PluginDescribeResult.ParameterType.String, true)
                    ,new Process.PluginDescribeResult.InputParameter('varAccountIsoCode',Process.PluginDescribeResult.ParameterType.String, true)
                    };

                        result.outputParameters = new
                        List<Process.PluginDescribeResult.OutputParameter>{
                            new Process.PluginDescribeResult.OutputParameter('Locale',Process.PluginDescribeResult.ParameterType.String)

                                };
                                    return result;
    }
}