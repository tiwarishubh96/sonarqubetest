/***
* @description Action Service class enabling to get a snapshot of the Org limits.
*              Implements the sfpegAction_SVC virtual class to be used in various
*              sfpeg components.
* @author      P-E GROS
* @date        May. 2020
* @see         sfpegAction_SVC
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegLimits_SVC extends sfpegAction_SVC {

/***
* @description Simple method the current situation of the Org limits, leveraging
*              the OrgLimits base apex class.
*              It does not taken any parameter as input and systematically returns
*              all limits as a list of objects containing the 'name', the 'value',
*              the 'limit' and the 'ratio' (i.e. 'value'/'limit') of each individual
*              limit type.
* @param       parameters   Not used, may be null.
* @return      List<Object> List of base Object containing data for each individual
*              limit type (name, limit, value, ratio)
* @exception   None.
***/
    public List<Object> getResults(Map<String,Object> parameters) {
        System.debug('getResults: START');

        List<Object> resultList = new List<Object>();
        Map<String,System.OrgLimit> limitMap = OrgLimits.getMap();

        for (String iter : limitMap.keySet()) {
            System.debug('getResults: processing limit ' + iter);

            Map<String,Object> iterObj = new Map<String,Object>();
            iterObj.put('Name',iter);
            iterObj.put('Value',(limitMap.get(iter)).getValue());
            iterObj.put('Limit',(limitMap.get(iter)).getLimit());
            iterObj.put('Ratio',100 * (limitMap.get(iter)).getValue() / math.max(1,(limitMap.get(iter)).getLimit()));
            System.debug('getResults: data prepared ' + iterObj);

            resultList.add(iterObj);
        }
        System.debug('getResults: END returning ' + resultList);
        return resultList;
    }
}