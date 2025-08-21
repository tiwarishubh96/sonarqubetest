/***
* @description Lightning controller to provide various configuration data tto Lightning components.
*              Primarily used by the "merge" utility.
* @author      P-E GROS
* @date        Nov. 2019
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegConfiguration_CTL {

/***
* @description Simple method to fetch various configuration data.
*              For now, the aim is to fetch Salesforce IDs for 'Folder', 'Report'
*              or 'Dashboard' given their Dev names and actual URLs (with CSRF token
*              if needed) for 'VFP' pages.
*              Configuration item names should be provided as <Type>.<DevName> 
*              Method marked as cacheable to optimise performances.
* @param       itemList           List of configuration item names 
* @return      Map<String,String> JSON object with all the resulting configuration data
* @exception   Aura exception if unsupported config type requested.
***/
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getData(final List<String> itemList) {
        System.debug('getData: START for itemList with size ' + itemList.size());

        Map<String,List<String>> dataFetchMap = new Map<String,List<String>>();
        for (String item : itemList) {
            System.debug('getData: processing item ' + item);
            String[] itemParts = item.split('\\.');
            System.debug(LoggingLevel.FINEST, 'getData: itemParts extracted ' + itemParts);

            if (itemParts.size() != 2)
                throw new AuraHandledException('Configuration Data fetch failed for item ' + item + '!');
            if (dataFetchMap.containsKey(itemParts[0])) {
                System.debug(LoggingLevel.FINE, 'getData: adding new value for ' + itemParts[0]);
                (dataFetchMap.get(itemParts[0])).add(itemParts[1]);
            }
            else {
                System.debug(LoggingLevel.FINE, 'getData: adding new entry for ' + itemParts[0]);
                List<String> newList = new List<String>();
                newList.add(itemParts[1]);
                dataFetchMap.put(itemParts[0], newList);
            }
        }
        System.debug('getData: dataFetchMap initialized ' + dataFetchMap);

        Map<String,String> dataMap = new Map<String,String>();
        for (String key : dataFetchMap.keySet()) {
            System.debug('getData: retrieving data for ' + key);
            switch on key {
                when 'Folder' {
                    List<String> devNames = dataFetchMap.get(key);
                    List<Folder> rcdList = [SELECT DeveloperName FROM Folder
                                            WHERE DeveloperName IN :devNames];
                    System.debug(LoggingLevel.FINE,'getData: ' + rcdList.size() + ' reports fetched');
                    for (Folder rcdItem : rcdList) {
                        System.debug(LoggingLevel.FINEST,'getData: adding ID for report ' + rcdItem);
                        dataMap.put('Folder.' + rcdItem.DeveloperName,rcdItem.Id);
                    }     
                    System.debug('getData: Folders processed');
                }
                when 'Report' {
                    List<String> devNames = dataFetchMap.get(key);
                    List<Report> rcdList = [SELECT DeveloperName FROM Report
                                            WHERE DeveloperName IN :devNames];
                    System.debug(LoggingLevel.FINE,'getData: ' + rcdList.size() + ' reports fetched');
                    for (Report rcdItem : rcdList) {
                        System.debug(LoggingLevel.FINEST,'getData: adding ID for report ' + rcdItem);
                        dataMap.put('Report.' + rcdItem.DeveloperName,rcdItem.Id);
                    }     
                    System.debug('getData: Reports processed');
                }
                when 'Dashboard' {
                    List<String> devNames = dataFetchMap.get(key);
                    List<Dashboard> rcdList = [SELECT DeveloperName FROM Dashboard
                                               WHERE DeveloperName IN :devNames];
                    System.debug(LoggingLevel.FINE,'getData: ' + rcdList.size() + ' dashboards fetched');
                    for (Dashboard rcdItem : rcdList) {
                        System.debug(LoggingLevel.FINEST,'getData: adding ID for dashboard ' + rcdItem);
                        dataMap.put('Dashboard.' + rcdItem.DeveloperName,rcdItem.Id);
                    }     
                    System.debug('getData: Dashboard processed');
                }
                when 'VFP' {
                    List<String> devNames = dataFetchMap.get(key);
                    System.debug(LoggingLevel.FINE,'getData: ' + devNames.size() + ' VF pages to process');
                    for (String vfPage : devNames) {
                        System.debug(LoggingLevel.FINEST,'getData: adding URL for VF Page ' + vfPage);
                        PageReference pageRef = new PageReference('/apex/' + vfPage);
                        String pageUrl = pageRef.getUrl();
                        System.debug(LoggingLevel.FINEST,'getURLs: URL determined ' + pageUrl );
                        dataMap.put('VFP.' + vfPage,pageUrl);
                    }
                    System.debug('getData: VFPs processed');
                }
                when else {
                    throw new AuraHandledException('Unsupported Configuration Data Type ' + key + '!');
                }
            }
        } 
        System.debug(LoggingLevel.FINEST,'getData: dataMap initialized ' + dataMap);
        
        System.debug('getData: END with dataMap of size ' + dataMap.size());
        return dataMap;
    }

/***
* @description Simple method to fetch the list of fields allowed for the user included in
*              a configured field set.
* @param       fieldSet             Dev Name of the Field Set 
* @return      Map<String,Object>   Map containing 3 entries:
*                                   'label' with the label of the field set,
*                                   'fields' with the list of included field API names allowed for the user,
*                                   'labels' with the corresponding field labels
* @exception   none really specific.
***/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getFieldSetDesc(final String name) {
        System.debug('getFieldSetDesc: START with field set name ' + name);

        String[] fsParts = name.split('\\.');
        System.debug('getFieldSetDesc: fsParts extracted ' + fsParts);
        if (fsParts.size()<> 2) throw new AuraHandledException(
            'Bad field set name format for ' + name + '\n Should be "object.fsName".');

        String objName = fsParts[0];
        System.debug('getFieldSetDesc: objName extracted ' + objName);
        String fsName  = fsParts[1];
        System.debug('getFieldSetDesc: fsName extracted ' + fsName);

        Schema.SObjectType objDesc = Schema.getGlobalDescribe().get(objName);
        if (objDesc == null) throw new AuraHandledException(
            'Unknown Object Name for field set ' + name + ' !');
        System.debug('getFieldSetDesc: object descriptor found ');

        Schema.FieldSet fsDesc = objDesc.getDescribe().fieldSets.getMap().get(fsName);
        if (fsDesc == null) throw new AuraHandledException(
            'Unknown Field Set Name for field set ' + name + ' !');
        System.debug('getFieldSet: field set descriptor found ');

        Map<String,Object> descResult = new Map<String,Object>();
        descResult.put('label',fsDesc.getLabel());
        System.debug('getFieldSet: field set Label set ' + fsDesc.getLabel());

        List<String> fieldList = new List<String>();
        List<String> labelList = new List<String>();
        descResult.put('fields',fieldList);
        descResult.put('labels',labelList);
        for (Schema.FieldSetMember fieldIter : fsDesc.getFields()) {
            System.debug('getFieldSet: processing field ' + fieldIter);

            Schema.DescribeFieldResult fieldDesc = fieldIter.getSObjectField().getDescribe();
            System.debug('getFieldSet: fieldDesc fetched ' + fieldDesc);

            if (fieldDesc.isAccessible()) {
                System.debug('getFieldSet: adding field ' + fieldIter);
                fieldList.add(fieldIter.getFieldPath());
                labelList.add(fieldIter.getLabel());
            }
            else {
                System.debug('getFieldSet: field not acessible ' + fieldIter);
            }
        }
        System.debug('getFieldSet: fieldList prepared ' + fieldList);
        System.debug('getFieldSet: descResult finalised ' + descResult);

        System.debug('getFieldSet: END for fieldList with size ' + fieldList.size());
        return descResult;
    }

/***
* @description Simple method to fetch the list of fields allowed for the user included in
*              a listt of configured field sets.
* @param       fieldSets            List of Field Set's Dev Names  
* @return      Map<String,Object>   Map of maps containing 3 entries for each fieldSet API name:
*                                   'label' with the label of the field set,
*                                   'fields' with the list of included field API names allowed for the user,
*                                   'labels' with the corresponding field labels
* @exception   none really specific.
***/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getFieldSetDescs(final list<String> names) {
        System.debug('getFieldSetDescs: START with ' + names.size() + ' elements');
        Map<String,Object> nameDescs = new Map<String,Object>();

        for (String iterName : names) {
            System.debug('getFieldSetDescs: processing field set ' + iterName);
            nameDescs.put(iterName, sfpegConfiguration_CTL.getFieldSetDesc(iterName));
        }

        System.debug('getFieldSetDescs: END with nameDescs ' + nameDescs);
        return nameDescs;
    }

/***
* @description Simple method to fetch the details of a SOQL query registered
*              in the sfpegSoqlQuery__mdt custom metadata type.
* @param       fieldSet             Dev Name of the Field Set 
* @return      Map<String,Object>   Map containing 3 entries:
*                                   'MasterLabel' with the label of the SOQL query
*                                   'Query_Input__c' with the parameters to be provided as query input,
*                                   'Query_Output__c' with the way query results should be presented in a table
* @exception   Aura exception if SOQL query not found for input dev name.
***/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getSoqlQueryDesc(final String name) {
        System.debug('getSoqlQueryDesc: START with SOQL query name ' + name);

        sfpegSoqlQuery__mdt soqlQuery;
        try {
            soqlQuery = [   select MasterLabel, Query_Input__c, Query_Output__c 
                            from sfpegSoqlQuery__mdt 
                            where DeveloperName = :name LIMIT 1];
            System.debug('getSoqlQueryDesc: soqlQuery fetched ' + soqlQuery);
        }
        catch (Exception e) {
            System.debug('getFieldSet: END KO ' + e);
            throw new AuraHandledException('SOQL query not found with name ' + name + '!');
        }

        Map<String,Object> queryDesc = new Map<String,Object>();
        queryDesc.put('MasterLabel',soqlQuery.MasterLabel);
        queryDesc.put('Query_Input__c',soqlQuery.Query_Input__c);
        queryDesc.put('Query_Output__c',soqlQuery.Query_Output__c);
        System.debug('getSoqlQueryDesc: END OK with ' + queryDesc);

        return queryDesc;
    }

/***
* @description Simple method to fetch the details of a list of actions registered
*              in the sfpegAction__mdt custom metadata type.
* @param       list<String>         List of Dev Name of sfpegAction__mdt records.
* @return      Map<String,Object>   Map containing the details for each sfpegAction__mdt record.
* @exception   Aura exception if Action not found for any dev name provided.
***/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getActionDesc(final list<String> actionNames) {
        System.debug('getActionDesc: START with names ' + actionNames);

        if (actionNames.size() == 0) {
            System.debug('getActionDesc: END KO - Missing action names');
            throw new AuraHandledException('No action name provided!');
        }

        list<sfpegAction__mdt> actionList;
        try {
            actionList = [  select DeveloperName, MasterLabel, TOLABEL(ActionLabel__c),
                            PageRef__c, Scope__c 
                            from sfpegAction__mdt 
                            where DeveloperName in :actionNames];
            System.debug('getActionDesc: actionList fetched ' + actionList);
        }
        catch (Exception e) {
            System.debug('getActionDesc: END KO ' + e);
            throw new AuraHandledException('Action configuration fetch issue\n' + e.getMessage());
        }

        if (actionList.size() == 0) {
            System.debug('getActionDesc: END KO - No action configuration found for names ' + actionNames);
            throw new AuraHandledException('No action configuration found for ' + actionNames + '!');
        }

        Map<String,Object> actionMap = new Map<String,Object>();
        for (sfpegAction__mdt iter : actionList){
            actionMap.put(iter.DeveloperName,iter);
        }
        System.debug('getActionDesc: END OK with ' + actionMap);

        return actionMap;
    }
}