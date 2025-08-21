/***
* @author P-E GROS
* @date   Oct. 2019
* @description Lightning controller to execute custom SOQL queries.
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegSoql_CTL {
    
/***
* @description Method to execute a SOQL query registered in the SOQL custom metadata type
*              while only providing a custom where clause.
* @param       queryName        Developer Name of a  SOQL query registered in the 
*                               sfpegSoqlQuelry__mdt custom metadata. 
* @param       queryWhere       SOQL Where clause to be applied. 
* @return      list<sObject>    Result of the resulting SOQL query as a list of sObjects.
* @Exception   none really specific.
***/
    @AuraEnabled
    public static list<sObject> doRegisteredQuery(final String  queryName, final String queryInput) {
        System.debug('doRegisteredQuery: START for query ' + queryName + ' with input ' + queryInput);

        sfpegSoqlQuery__mdt query;
        
        try {
            query = [   select SOQL_Query__c,SOQL_Action__c, Bypass_FLS__c, Bypass_Sharing__c
                        from sfpegSoqlQuery__mdt 
                        where DeveloperName = :queryName LIMIT 1];
            System.debug('doRegisteredQuery: query fetched ' + query);
        }
        catch (Exception e) {
            //if (query == null) {
            System.debug('doRegisteredQuery: END KO --> query not found! --> ' + queryName);
            throw new AuraHandledException('Please provide a registered SOQL query!\n' + queryName + ' unknown.');
        }

        if (!String.isEmpty(query.SOQL_Query__c)) {
            System.debug('doRegisteredQuery: Processing standard SOQL query ' + query.SOQL_Query__c);
            String queryString = query.SOQL_Query__c;
            if (!String.isEmpty(queryInput)) queryString = queryString.replace('{{{CTX.Input}}}',queryInput);
            System.debug('doRegisteredQuery: queryString prepared ' + queryString);

            List<sObject> sobjList = Database.query(queryString);
            System.debug('doRegisteredQuery: END OK with result ' + sobjList);
            return sobjList;    
        }
        else if (!String.isEmpty(query.SOQL_Action__c)){
            System.debug('doRegisteredQuery: Processing custom SOQL action ' + query.SOQL_Action__c);

            Type soqlActionClass = Type.forName(query.SOQL_Action__c);
            if (null == soqlActionClass) {
                System.debug('doRegisteredQuery : END SOQL action handler not found');
                throw new AuraHandledException('Handler action ' + query.SOQL_Action__c + ' for query ' + queryName + ' not found!');
            } else {
                System.debug('doRegisteredQuery : SOQL action handler found');
                sfpegSoqlAction_SVC soqlActionInstance = (sfpegSoqlAction_SVC) soqlActionClass.newInstance();
                System.debug('doRegisteredQuery : END invoking SOQL action handler');
                return soqlActionInstance.doQuery(queryInput);
            }
            //throw new AuraHandledException('Custom SOQL actions not supported yet!\n' + query.SOQL_Action__c + ' not available for ' + queryName);
        }
        else {
            System.debug('doRegisteredQuery: END KO --> query badly configured! --> ' + query);
            throw new AuraHandledException('Please provide a correct SOQL query!\n' + queryName + ' badly configured.');
        }
    }

/***
* @description Simple pass-through method to execute a SOQL query from a Lightning Component.
* @param       queryString    SOQL query string to execute. 
* @return      list<sObject>  Result of the SOQL query as a list of sObjects.
* @Exception   none really specific.
***/
    @AuraEnabled
    public static list<sObject> doQuery(final String  queryString) {
        System.debug('doQuery: START for query ' + queryString);
        
        //if (queryString.contains('SECURITY_ENFORCED')) {
        if (!String.isEmpty(queryString)) {
            //System.debug('doQuery: FLS control OK');
            System.debug('doQuery: triggering query');
            List<sObject> sobjList = Database.query(queryString);
            System.debug('doQuery: END OK with result ' + sobjList);
            return sobjList;
        }
        else {
            System.debug('doQuery: END KO --> FLS control KO');
            throw new AuraHandledException('FLS Control Error: Please apply WITH SECURITY_ENFORCED in SOQL.');
        }
    }

/***
* @description Storable variant of the doQuery method.
* @param       queryString    SOQL query string to execute. 
* @return      list<sObject>  Result of the SOQL query as a list of sObjects.
* @Exception   none really specific.
***/
    @AuraEnabled(cacheable=true)
    public static list<sObject> doQueryStorable(final String  queryString) {
        System.debug('doQuery: invoking storable query ' + queryString);
        return sfpegSoql_CTL.doQuery(queryString);
    }
}