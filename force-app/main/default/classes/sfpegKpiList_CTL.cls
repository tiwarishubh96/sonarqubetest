/***
* @description  Lightning controller to provide details about existing KPI List configurations.
*               It relies on the sfpegKpiList__mdt custom metadata.
* @author       P-E GROS
* @date         July 2021
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegKpiList_CTL {
    
    /***
    * @description  Simple method to fetch configuration details for a KPI List component.
    *               It provides the display configuration as well as the actions available.
    * @param        name    DeveloperName of the KPI List configuration record
    * @return       Object  sfpegKpiList__mdt record with DisplayConfig__c, 
    *               MasterLabel fields filled in.
    * @exception    AuraHandledException    Raised if no configuration found for the provided name
    ***/
    @AuraEnabled(cacheable=true)
    public static Object getConfiguration(final String name) {
        System.debug(LoggingLevel.FINE,'getConfiguration: START with configuration name ' + name);

        List<sfpegKpiList__mdt> configs = [ SELECT MasterLabel, DisplayConfig__c
                                            FROM sfpegKpiList__mdt
                                            WHERE DeveloperName =  :name];
        if ((configs == null) || (configs.size() != 1)) {
            throw new AuraHandledException('Configuration not found with name ' + name);
        }
        //System.debug(LoggingLevel.FINEST,'getConfiguration: END with configuration name ' + configs[0]);
        System.debug(LoggingLevel.FINE,'getConfiguration: END ' + configs[0].MasterLabel);
        return (Object) (configs[0]);
    }

}