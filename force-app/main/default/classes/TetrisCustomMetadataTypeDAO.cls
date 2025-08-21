global class TetrisCustomMetadataTypeDAO {

	global static Callout_Configuration__mdt getResourceInfo(String resourceName) {
       List<Callout_Configuration__mdt> lstCallOutConfig = [SELECT Endpoint_URL__c, SSL_Certificate__c, HTTP_Method__c, 
                                                            Timeout__c, Authorization__c, Content_Type__c, Client_Id__c, 
                                                            Client_Secret__c, Disabled__c, Username__c, Password__c 
            												FROM Callout_Configuration__mdt 
            												WHERE DeveloperName =: resourceName];
     	Callout_Configuration__mdt callOutConfigObj = new Callout_Configuration__mdt();
        if(lstCallOutConfig!=null && lstCallOutConfig.size()>0)
        {
            callOutConfigObj = lstCallOutConfig[0];
        }
        return callOutConfigObj;
    }

}