/***
* @description Lightning controller for the App Builder to provide the list of 
*              Message configurations registered in the sfpegMessage__mdt custom metadata
*              and available on the current Object type, for use in a configuration
*              attribute data source (to display a picklist).
* @author      P-E GROS
* @date        August 2021
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

global with sharing class sfpegMessageSelector_CTL extends VisualEditor.DynamicPickList {

    /***
    * @description Context of the Lightning page calling the picklist controller.
    ***/
    VisualEditor.DesignTimePageContext pageContext;
    
    /***
    * @description Constructor enabling to fetch the Lightning page context (and especially
    *              the entityName of the record being displayed in the page).
    * @param       VisualEditor.DesignTimePageContext   Current page context
    * @exception   none really specific.
    ***/    
    
    global sfpegMessageSelector_CTL(VisualEditor.DesignTimePageContext pageContext) {
        System.debug(LoggingLevel.FINEST,'Constructor START with page context ' + pageContext);
        System.debug(LoggingLevel.FINEST,'Constructor entityName ' + pageContext.entityName);
        this.pageContext = pageContext;
    }
    
    
    /***
    * @description Override of the method providing the default value.
    * @return      VisualEditor.DataRow   Always returns the default ('---','N/A') value.
    * @exception   none really specific.
    ***/
    global override VisualEditor.DataRow getDefaultValue() {
        System.debug(LoggingLevel.FINEST,'getDefaultValue START Number');
        return new VisualEditor.DataRow('---','N/A');
    }
        
    /***
    * @description Override of the method providing the set of picklist values.
    *              Returns label / names couples for all field sets 
    *              defined on entity. Includes a default ('---','N/A') value.
    * @return      VisualEditor.DynamicPickListRows  List of field set names for datasource.
    * @exception   none really specific.
    ***/
    global override VisualEditor.DynamicPickListRows getValues() {
        System.debug(LoggingLevel.FINEST,'getValues: START');
    
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addRow(new VisualEditor.DataRow('---','N/A'));
        System.debug(LoggingLevel.FINEST,'getValues: picklistValues init ' + picklistValues);
    
    
        System.debug(LoggingLevel.FINEST,'getValues: entity name fetched ' + pageContext.entityName);
        Map<ID,sfpegMessage__mdt> queries = new Map<ID,sfpegMessage__mdt>(
            [   select MasterLabel,  DeveloperName
                from sfpegMessage__mdt 
                where Scope__c LIKE '%GLOBAL%'  ]);
        if (! String.isEmpty(pageContext.entityName)) {
            System.debug(LoggingLevel.FINEST,'getValues: fetching GLOBAL, Record and object specific queries');
            queries.putAll(new Map<ID,sfpegMessage__mdt>(
                [   select MasterLabel,  DeveloperName
                    from sfpegMessage__mdt 
                    where Scope__c LIKE '%RECORDS%']));
            String entityPattern = '%' + pageContext.entityName + '%';
            queries.putAll(new Map<ID,sfpegMessage__mdt>(
                [   select MasterLabel,  DeveloperName
                    from sfpegMessage__mdt 
                    where Scope__c LIKE :entityPattern]));
        }
        System.debug(LoggingLevel.FINEST,'getValues: queries initialized ' + queries);
    
        for (ID iter : queries.keySet()){
            sfpegMessage__mdt queryIter = queries.get(iter);
            System.debug(LoggingLevel.FINEST,'getValues: processing query ' + queryIter);
            picklistValues.addRow(new VisualEditor.DataRow(
                queryIter.MasterLabel,
                queryIter.DeveloperName));
        }
        System.debug(LoggingLevel.FINEST,'getValues: picklistValues completed ' + picklistValues);
        System.debug(LoggingLevel.FINE,'getValues: END with #Items ' + picklistValues.size());
        return picklistValues;
    }
}