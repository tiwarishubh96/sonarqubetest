/***
* @author P-E GROS
* @date   Nov. 2019
* @description Virtual custom SOQL Action handling class used by the sfpegSoql_CTL
*              controller to handle custom SOQL queries.
*              Default implementation throws exceptions to warn about possible issues.
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public virtual class sfpegSoqlAction_SVC {

    public virtual list<sObject> doQuery(final String queryInput) {
        System.debug(LoggingLevel.ERROR,'doQuery : sfpegSoqlAction_SVC default implementation called.');
        throw new AuraHandledException('Action not implemented!');
        //return null;
    }

}