@isTest
private class ComponentConfigHelperTest
{
    
    @testSetup static void testSetup()
    {
        //Insert Test data for communityComConfig
        
        Community_Component_Config__c communityComConfig = new Community_Component_Config__c
            (
                Name = 'TestCommunityComponentConfig',
                Community_Id__c = 'communityId',
                Settings__c = 'Test Settings',
                Component_Name__c = 'Test Comonents',
                Component_Type__c = 'Article Data Categories Component',
                Permission_Name__c = 'Custom CC Admin'
            );   
        insert communityComConfig;
        
    }
    
    @isTest
    static void testGetComponentConfigJson()
    {
        // Soql to Get Test Data of Community_Component_Config__c
        Community_Component_Config__c communityComConfig = [Select Community_Id__c, Component_Name__c, Component_Type__c 
                                                            from Community_Component_Config__c communityComConfig limit 1];
        
        // Call getComponentConfigJson Method with ID 
        String componentConfigJson = ComponentConfigHelper.getComponentConfigJson(communityComConfig.Community_Id__c,
                                                                                  communityComConfig.Component_Name__c,
                                                                                  communityComConfig.Component_Type__c);
        System.assertNotEquals(componentConfigJson,null);
        // Call getComponentConfigJson Method withOut ID 
        String componentConfigJson1 = ComponentConfigHelper.getComponentConfigJson('',
                                                                                   communityComConfig.Component_Name__c,
                                                                                   communityComConfig.Component_Type__c);
        System.assertNotEquals(componentConfigJson1,null);
        
        // Exception
        
        String componentConfigJson2 = ComponentConfigHelper.getComponentConfigJson('','','');
        system.debug('componentConfigJson2 : '+componentConfigJson2);
        System.assertEquals(componentConfigJson2,'{}');
        
        
    }//End of The Method
    
    @isTest
    static void testSaveSettings()
    {
        // Soql to Get Test Data of Community_Component_Config__c
        Community_Component_Config__c communityComConfig = [Select Id,Community_Id__c, Component_Name__c, Component_Type__c,Settings__c 
                                                            from Community_Component_Config__c communityComConfig limit 1];
        System.debug('communityComConfig: '+ communityComConfig);
        //Testing saveSettings Method with communityComConfig Id
        ComponentConfigHelper.saveSettings(communityComConfig.Id, communityComConfig.Community_Id__c, 
                                           communityComConfig.Component_Name__c , communityComConfig.Component_Type__c
                                           , communityComConfig.Settings__c);
        //Testing saveSettings Method without communityComConfig Id
        ComponentConfigHelper.saveSettings('', communityComConfig.Community_Id__c, 
                                           communityComConfig.Component_Name__c , communityComConfig.Component_Type__c
                                           , communityComConfig.Settings__c);
        
    }
    
    @isTest
    static void testUpdateComponentConfig ()
    {
        // Soql to Get Test Data of Community_Component_Config__c
        Community_Component_Config__c communityComConfig = [Select Id,Community_Id__c, Component_Name__c, Component_Type__c,Settings__c 
                                                            from Community_Component_Config__c communityComConfig limit 1];
        
        //Testing updateComponentConfig
        ComponentConfigHelper.updateComponentConfig
            (
                communityComConfig.Id,
                communityComConfig.Community_Id__c,
                communityComConfig.Component_Name__c,
                communityComConfig.Component_Type__c,
                communityComConfig.Settings__c
            );
        
        
    }
    
    
}