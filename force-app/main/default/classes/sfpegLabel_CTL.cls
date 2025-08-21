/***
* @description  Lightning controller to provide custom label values dynamically,
*               (according to the user language).
*               Also used as VF controler as technical workaround to fetch the the
*               translated labels via the sfpegGetLabels_VFP page.
* @author       P-E GROS
* @date         May 2021
* @see          sfpegGetLabels_VFP
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegLabel_CTL {

    /***
    * @description  For the VF controller part, list of requested Custom Label Names
    ***/
    private List<String> labelNames;

    /***
    * @description  Constructor of the VF page controler part, parsing the provided
    *               'labels' page string parameter as JSON String list of custom label
    *               dev names.
    ***/
    public sfpegLabel_CTL() {
        System.debug('Constructor: START');

        String labelList = Apexpages.currentPage().getParameters().get('labels');
        System.debug('Constructor: labelList fetched ' + labelList);

        labelNames = new List<String>();
        if (String.isEmpty(labelList)) {
            System.debug('Constructor: END no label provided ');
        }
        else {
            System.debug('Constructor: parsing labels ');
            //labelNames = (List<String>)JSON.deserializeUntyped(labelList);
            List<Object> parsedList = (List<Object>)JSON.deserializeUntyped(labelList);
            for (Object iter : parsedList) {
                labelNames.add((String)iter);
            }
            System.debug('Constructor: END labels init ' + labelNames);
        }
    }
    /***
    * @description  Accessor for the VF page controler part to fetch the list of
    *               custom label dev names to display.
    ***/
    public List<String> getLabelNames() {
        return labelNames;
    }

    /***
    * @description  Simple method to fetch the actual values for a list of custom labels
    *               for the current user language.
    * @param        labelNames          List of custom label Developer Names
    * @return       Map<String, String> Resulting Map of labels values per label dev name.
    * @exception    AuraHandledException Raised if no configuration found for the provided name
    ***/

    /*@AuraEnabled(cacheable=true)
    public static Map<String, Object> getLabels(List<String> labelNames) {
        System.debug('getLabels: START with ' + labelNames);

        String userLanguage = UserInfo.getLanguage();
        System.debug('getLabels: userLanguage fetched ' + userLanguage);

        if (null == labelNames) {
            System.debug(LoggingLevel.ERROR,'getLabels: END - Missing label names');
            throw new AuraHandledException('Missing Label names!');
        }
        PageReference ref = Page.sfpegGetLabels_VFP;
        ref.getParameters().putAll(
            new Map<String, String> {
                'lang' => userLanguage,
                'labels' => JSON.serialize(labelNames)
            });
        Map<String, Object> returnMap = (Map<String, Object>)JSON.deserializeUntyped((ref.getContent()).tostring());
        returnMap.remove('END');
        
        System.debug('getLabels: END - returning returnMap ' + returnMap);
        return returnMap;
    }*/
}