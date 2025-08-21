public class ComponentConfigHelper {

    /*
     * Utility method to retrieve Component Configuration based on Community Id, Component Name and Type
     */ 
    public static String getComponentConfigJson(String communityId, String componentName, String componentType) {
    	Community_Component_Config__c componentConfig = null;
        try {
            if ((communityId != null) &&  (!communityId.trim().equals(''))) {
                componentConfig = [SELECT Id, Community_Id__c, Component_Name__c, Permission_Name__c, Component_Type__c, Settings__c FROM Community_Component_Config__c WHERE Community_Id__c =:communityId AND  Component_Name__c =:componentName AND Component_Type__c =:componentType LIMIT 1];
            }
            else {
                componentConfig = [SELECT Id, Community_Id__c, Component_Name__c, Permission_Name__c, Component_Type__c, Settings__c FROM Community_Component_Config__c WHERE Component_Name__c =:componentName AND Component_Type__c =:componentType LIMIT 1];            
            }            
        }
        catch (Exception ex) {
            System.debug('ComponentConfigHelper: getComponentConfigJson: ex ' + ex.getMessage());
        }
        String componentConfigJson = '';
        if (componentConfig != null) {
        	String componentConfigId = componentConfig.Id;
            String  customSettingsJson = componentConfig.Settings__c;
           	communityId = componentConfig.Community_Id__c;
            system.debug('@@@ component config details :'+ componentConfig);
            componentConfigJson = '"ComponentConfigId": "' + componentConfigId + '", ';
            componentConfigJson += '"CommunityId" : "' + communityId + '", ';
            componentConfigJson += '"ComponentName" : "' + componentName + '", ';
            componentConfigJson += '"PermissionName" : "' + componentConfig.Permission_Name__c + '", ';
            componentConfigJson += '"ComponentType" : "' + componentType + '", ';
            componentConfigJson += '"Settings" : ' + customSettingsJson;
        }
        componentConfigJson = '{' + componentConfigJson + '}';
       return componentConfigJson;
    }
    
    /*
     * Utility method to persist Component Config
     */ 
    public static void saveSettings(String componentConfigId, String communityId, 
                                    String componentName, String componentType, String settings) {
           saveSettings(componentConfigId, communityId, componentName, Label.DEFAULT_COMPONENT_PERMISSION, 
                        componentType, settings);                                        
    }
    
    /*
     * Utility method to persist Component Config
     */ 
    public static void saveSettings(String componentConfigId, String communityId, String componentName,
                                    String permissionName, String componentType, String settings) {
        if ((componentConfigId == null) || (componentConfigId.equals('')) || (componentConfigId.equals('null'))) {
            createComponentConfig(communityId, componentName, permissionName, componentType, settings);
		}    
        else {
            updateComponentConfig(componentConfigId, communityId, componentName, permissionName, componentType, settings);
        }
    }

    /*
     * Helper method to create Component Config
     */
    public static void createComponentConfig(String communityId, String componentName, 
                                             String permissionName, String componentType, String settings) {
            system.debug('In createComponentConfig' + communityId + componentName + permissionName + settings);
            Community_Component_Config__c componentConfig = new Community_Component_Config__c();
            componentConfig.Community_Id__c = communityId;
            componentConfig.permission_name__c = permissionName;
            componentConfig.Component_Name__c = componentName;
            componentConfig.Settings__c = settings;
            componentConfig.Component_Type__c = componentType;
            insert componentConfig;        
        
    }
    
    /*
     * Helper method to update Component Config
     */
    public static void updateComponentConfig(String componentConfigId, String communityId, String componentName,
                                             String componentType, String settings) {
          updateComponentConfig(componentConfigId,  communityId,  componentName,
                                 '', componentType,  settings);            
   }
    
    /*
     * Helper method to update Component Config
     */
    public static void updateComponentConfig(String componentConfigId, String communityId, String componentName,
                                             String permissionName, String componentType, String settings) {                                                 
   		Community_Component_Config__c componentConfig = [SELECT Id, Community_Id__c, Component_Name__c, Permission_Name__c, Component_Type__c, Settings__c FROM Community_Component_Config__c WHERE Id =:componentConfigId LIMIT 1];        
       	if (componentConfig != null) {
			componentConfig.Community_Id__c = communityId;
        	componentConfig.Component_Name__c = componentName;
            componentConfig.Permission_Name__c = permissionName;
        	componentConfig.Settings__c = settings;
        	componentConfig.Component_Type__c = componentType;
        	update componentConfig;                                         
        }                                         
        else {
            createComponentConfig(communityId, componentName, permissionName, componentType, settings);
        }        
	}

}