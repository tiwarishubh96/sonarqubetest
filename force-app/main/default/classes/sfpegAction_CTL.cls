/***
* @description  Lightning controller to provide details about existing Action configurations.
* @author       P-E GROS
* @date         April 2021
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegAction_CTL {

    /***
    * @description  Simple method to fetch configuration details for a List component.
    *               It provides the required input fields, the type of display (datatable...)
    *               and the corresponding display configuration.
    * @param        name                DeveloperName of the List configuration record
    * @return       Object              sfpegAction__mdt record with Actions__c,
    *                                   MasterLabel fields filled in.
    * @exception    AuraHandledException    Raised if no configuration found for the provided name
    ***/
    @AuraEnabled(cacheable=true)
    public static Object getConfiguration(final String name) {
        System.debug(LoggingLevel.FINE,'getConfiguration: START with configuration name ' + name);

        List<sfpegAction__mdt> configs = [    select Actions__c, MasterLabel
                                            from sfpegAction__mdt
                                            where DeveloperName =  :name];
        if ((configs == null) || (configs.size() != 1)) {
            System.debug(LoggingLevel.ERROR,'getConfiguration: END - Missing/wrong configuration');
            throw new AuraHandledException('Configuration not found with name ' + name);
        }
        //System.debug(LoggingLevel.FINEST,'getConfiguration: END with configuration name ' + configs[0]);
        System.debug(LoggingLevel.FINE,'getConfiguration: END ' + configs[0].MasterLabel);
        return (Object) (configs[0]);
    }

    /***
    * @description  Method to execute an Apex operation.
    * @param        action  Name of the action to be executed (as an Apex class dev name or
    *                       ClassName.MethodName to trigger various logics)
    * @param        params  Context data to be provided as input to the Apex execute method.
    * @return       Object  Result of the Apex logic.
    * @exception    AuraHandledException    Raised if no configuration found for the provided name.
    ***/
    @AuraEnabled
    public static Object executeApex(final String action, final Object params) {
        System.debug(LoggingLevel.FINE,'executeAction: START with action name ' + action);
        System.debug(LoggingLevel.FINE,'executeAction: params provided ' + params);

        if (String.isEmpty(action)) {
            System.debug(LoggingLevel.WARN,'executeAction: END - No action name provided !');
            throw new AuraHandledException('No action name provided!');
        }

        String className = action;
        String methodName = null;
        if (className.contains('.')) {
            System.debug('executeAction: splitting action in class and method');
            String[] parts = className.split('\\.');
            className = parts[0];
            methodName = parts[1];
        }
        System.debug(LoggingLevel.FINEST,'executeAction: className set '  + className);
        System.debug(LoggingLevel.FINEST,'executeAction: methodName set ' + methodName);
      
        Type actionClass = Type.forName(className);
        if (null == actionClass) {
            System.debug(LoggingLevel.WARN,'executeAction: END - action handler not found  for ' + action);
            throw new AuraHandledException('Handler class for action ' + action + ' not found!');
        }
        System.debug('executeAction: action handler found');
        sfpegAction_SVC actionInstance = (sfpegAction_SVC) actionClass.newInstance();

        System.debug('executeAction: END - invoking handler action for class');
        return actionInstance.execute(params,methodName);
    }

    /***
    * @description  Method to execute a DML operation.
    * @param        records         List of SObject on which to execute a DML
    * @param        operation       Name of the DML operation to execute (insert, update, delet).
    * @return       List<sObject>   Same list of SObjects after the DML (e.g. with IDs after insert)
    * @exception    AuraHandledException    Raised if no configuration found for the provided name.
    ***/
    @AuraEnabled
    public static List<sObject> executeDML(list<sObject> records, string operation) {
        System.debug('executeDML : START operation ' + operation);
        System.debug('executeDML : itemList provided ' + records);
      
        try {
            switch on operation {
                when 'insert' {
                    insert records;
                    System.debug('executeDML : END itemList inserted ' + records);
                }
                when 'update' {
                    update records;
                    System.debug('executeDML : END itemList updated ' + records);
                }
                when 'delete' {
                    delete records;
                    System.debug('executeDML : END itemList deleted ' + records);
                }
                when else {
                    System.debug('executeDML : unsupported operation ' + operation);
                    StringException  errInvalid = new StringException();
                    errInvalid.setMessage('Unknown or unsupported operation (' + operation + ') requested!');
                    throw errInvalid;
                }
            }
            return records;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'executeDML : END KO / returning error ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }        
    }
}