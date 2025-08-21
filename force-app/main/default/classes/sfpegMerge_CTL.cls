/***
* @description  Lightning controller to provide various data for teh merge utility.
* @author       P-E GROS
* @date         June 2021
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegMerge_CTL {
    
    /***
    * @description  Method to fetch configuration values for the merge service.
    *               For a list of configuration data grouped by domain, it provides
    *               the corresponding data. It may be salesforce IDs for various
    *               elements such as reports or articles, full URL (with security token)
    *               for a VF page...
    * @param        configMap                Map of configuratiuon elements grouped by domain
    * @return       Map<String,Object>       Map of the requested elements with corresponding data.
    * @exception    AuraHandledException     Raised if no configuration found for the provided name
    ***/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getConfig(Map<Object,Object> configMap) {
        System.debug(LoggingLevel.FINE,'getValues: START with configuration ' + configMap);

        if (configMap == null) {
            System.debug(LoggingLevel.WARN,'getValues: END - No configuration map provided !');
            throw new AuraHandledException('No configuration map provided!');
        }

        Set<String> keySet = new Set<String>();
        for (Object iter : configMap.keySet()) keySet.add((String)iter);
        List<sfpegConfiguration__mdt> refConfig =
            [   select Field__c, Query__c, DeveloperName from sfpegConfiguration__mdt
                where  DeveloperName in :keySet];
        Map<String,sfpegConfiguration__mdt> refMap = new Map<String,sfpegConfiguration__mdt>();
        if (refConfig != null) {
            for (sfpegConfiguration__mdt iter : refConfig) refMap.put(iter.DeveloperName,iter);
        }
        System.debug(LoggingLevel.FINE,'getValues: refMap init ' + refMap);

        
        Map<String,Object> returnMap = new Map<String,Object>();
        for (Object iter : configMap.keySet()) {
            System.debug(LoggingLevel.FINEST,'getValues: processing iter ' + iter);
            Map<String,Object> iterResults = new Map<String,Object>();
            returnMap.put((String)iter,(Object)iterResults);

            List<Object> iterList = (List<Object>)(configMap.get((String)iter));
            if (iterList == null) {
                System.debug(LoggingLevel.WARN,'getValues: END - No configuration provided for key ' + iter);
                throw new AuraHandledException('No configuration provided for key ' + iter + ' ! ');
            }
            System.debug(LoggingLevel.FINEST,'getValues: #Items to process ' + iterList.size());

            
            switch on (String)iter {
                when 'VFP' {
                    System.debug(LoggingLevel.FINEST,'getValues: processing VF page URLs');
                    for (Object iterVF : iterList) {
                        System.debug(LoggingLevel.FINEST,'getValues: adding URL for VF Page ' + iterVF);
                        PageReference iterRef = new PageReference('/apex/' + iterVF);
                        String iterURL = iterRef.getUrl();
                        System.debug(LoggingLevel.FINEST,'getValues: URL determined ' + iterURL);
                        iterResults.put((String)iterVF,iterURL);
                    }
                    System.debug(LoggingLevel.FINEST,'getValues: VFPs processed' + iterResults);
                }
                when 'LBL' {
                    System.debug(LoggingLevel.FINEST,'getValues: processing Custom Labels');

                    String userLanguage = UserInfo.getLanguage();
                    System.debug('getValues: userLanguage fetched ' + userLanguage);

                    PageReference labelPageRef = Page.sfpegGetLabels_VFP;
                    labelPageRef.getParameters().putAll(
                        new Map<String, String> {
                            'lang' => userLanguage,
                            'labels' => JSON.serialize(iterList)
                        });
                    Map<String, Object> labelMap = (Map<String, Object>)JSON.deserializeUntyped((labelPageRef.getContent()).tostring());
                    labelMap.remove('END');
                    for (String iterLabel : labelMap.keySet()) {
                        iterResults.put(iterLabel, (String)(labelMap.get(iterLabel)));
                    }
                    System.debug(LoggingLevel.FINEST,'getValues: Custom Labels processed' + iterResults);
                }
                when 'RT' {
                    System.debug(LoggingLevel.FINEST,'getValues: processing Record Types');
                
                    for (Object iterRT : iterList) {
                        System.debug(LoggingLevel.FINEST,'getValues: processing RT ' + iterRT);

                        String[] iterParts = ((String)iterRT).split('\\.');
                        System.debug(LoggingLevel.FINEST,'getValues: RT parts extracted ' + iterParts);
                        if (iterParts.size() <> 2) throw new AuraHandledException('Record type ID fetch error: ' + iterParts + ' should be in objectApiName.rtDevName format');
                        
                        Schema.RecordTypeInfo iterDesc = Schema.getGlobalDescribe().get(iterParts[0])?.getDescribe().getRecordTypeInfosByDeveloperName()?.get(iterParts[1]);
                        System.debug(LoggingLevel.FINEST,'getValues: RT desc fetched ' + iterDesc);
                        if (iterDesc == null) throw new AuraHandledException('Record type ID fetch error: ' + iterParts + ' RT not found');

                        iterResults.put((String)iterRT,iterDesc.getRecordTypeId());
                    }
                    System.debug(LoggingLevel.FINEST,'getValues: RTs processed' + iterResults);
                }
                when 'PERM' {
                    System.debug(LoggingLevel.FINEST,'getValues: processing Custom Permissions (enabled)');
                    for (Object iterPerm : iterList) {
                        System.debug(LoggingLevel.FINEST,'getValues: testing permission ' + iterPerm);
                        Boolean hasPermission = FeatureManagement.checkPermission((String)iterPerm);
                        System.debug(LoggingLevel.FINEST,'getValues: permission checked ' + hasPermission);
                        iterResults.put((String)iterPerm,hasPermission);
                    }
                    System.debug(LoggingLevel.FINEST,'getValues: Custom Permissions (enabled) processed' + iterResults);
                }
                when 'NPERM' {
                    System.debug(LoggingLevel.FINEST,'getValues: processing Custom Permissions (disabled)');
                    for (Object iterPerm : iterList) {
                        System.debug(LoggingLevel.FINEST,'getValues: testing permission ' + iterPerm);
                        Boolean hasPermission = FeatureManagement.checkPermission((String)iterPerm);
                        System.debug(LoggingLevel.FINEST,'getValues: permission checked ' + hasPermission);
                        iterResults.put((String)iterPerm,!hasPermission);
                    }
                    System.debug(LoggingLevel.FINEST,'getValues: Custom Permissions (disabled) processed' + iterResults);
                }
                when else {
                    System.debug(LoggingLevel.FINEST,'getValues: processing registered query');
                    
                    sfpegConfiguration__mdt iterConfig = refMap.get((String)iter);
                    if (iterConfig == null) {
                        System.debug(LoggingLevel.WARN,'getValues: END - Unsupported configuration provided for key ' + iter);
                        throw new AuraHandledException('Unsupported configuration provided for key ' + iter + ' ! ');
                    }
                    String iterQuery = iterConfig.Query__c + '(\'' + String.join(iterList, '\',\'') + '\')';
                    System.debug(LoggingLevel.FINEST,'getValues: query initialized ' + iterQuery );
                    List<sObject> resultList = database.query(iterQuery);
                    System.debug(LoggingLevel.FINEST,'getValues: resultList fetched ' + resultList );

                    for (SObject iterObj : resultList) {
                        iterResults.put((String)(iterObj.get(iterConfig.Field__c)),iterObj.Id);
                    }
                    System.debug(LoggingLevel.FINEST,'getValues: items processed' + iterResults);
                }
            }
        }

        System.debug(LoggingLevel.FINE,'getValues: END with ' + returnMap);
        return returnMap;
    }

    /***
    * @description  Method to fetch field values details for a given record.
    *               Replaces LDS whene @wire is not used to fetch User/Record
    *               context data.
    * @param        objectName          API name of the record object
    * @param        recordId            ID of the record
    * @param        fieldNames          List of API field names requested
    * @return       Object              Record with the requested fields filled in.
    * @exception    AuraHandledException    Raised if no record found for the provided ID
    ***/
    @AuraEnabled(cacheable=false)
    public static Object getRecord(String objectName, String recordId, List<String> fieldNames) {
        System.debug(LoggingLevel.FINE,'getRecord: START with recordId ' + recordId);
        System.debug(LoggingLevel.FINE,'getRecord: objectName provided ' + objectName);
        System.debug(LoggingLevel.FINE,'getRecord: fieldNames requested ' + fieldNames);

        if ((objectName == null) || (recordId == null) || (fieldNames == null) || (fieldNames.size() == 0)) {
            System.debug(LoggingLevel.WARN,'getRecord: END - Missing input !');
            throw new AuraHandledException('Missing input!');
        }

        String soqlQuery = 'select ' + String.join(fieldNames,',') + ' from ' + objectName + ' where Id = \'' + recordId + '\' WITH SECURITY_ENFORCED';
        System.debug(LoggingLevel.FINEST,'getRecord: soqlQuery prepared ' + soqlQuery);

        List<sObject> sobjList = Database.query(soqlQuery);
        System.debug(LoggingLevel.FINEST,'getRecord: sobjList retrieved ' + sobjList);

        if ((sobjList == null) || (sobjList.size() != 1)) {
            System.debug(LoggingLevel.WARN,'getRecord: END - No record found !');
            throw new AuraHandledException('Missing record (or non accessible fields)! ' + recordId);
        }
        System.debug(LoggingLevel.FINE,'getRecord: END');
        return (Object)sobjList[0];
    }
}