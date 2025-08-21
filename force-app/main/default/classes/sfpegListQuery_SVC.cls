/***
* @author       P-E GROS
* @date         May 2021
* @description  Virtual handling class used by the sfpegList_CTL generic controller to
*               implement custom Apex queries. 
*               Provides virtual default implementations of supported methods.
*               Default implementation throws exceptions to warn about missing implementation.
* @see          sfpegList_CTL
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public virtual class sfpegListQuery_SVC {

    /***
    * @description  Method to overide in Apex the default SOQL query implementation of the 
    *               sfpegList_CTL class.
    * @param input  Context Object record containing all the input data expected
    *               by the query.
    * @param query  Text name of the query (optional) if the same override Apex class
    *               is used to implement multiple query logics.
    * @return List<Object>  Result list of the query.
    * @exception AuraHandledException   Returned systematically by default with a warning message
    *                                   to inform that real implementation is not available.
    ***/
    public virtual List<Object> getData(final Object input, final String query) {
        System.debug(LoggingLevel.ERROR,'getData: sfpegListQuery_SVC default implementation called.');
        throw new AuraHandledException('GetData Query action not implemented!');
        //return null;
    }  

    /***
    * @description  Method to overide in Apex the default SOQL implementation of the sfpegList_CTL class
    *               to fetch the total number of records in case of paginated loading of data.
    * @param input  Context Object record containing all the input data expected
    *               by the query.
    * @param query  Text name of the query (optional) if the same override Apex class
    *               is used to implement multiple query logics.
    * @return Integer   Number of records returned by the query.
    * @exception AuraHandledException   Returned systematically by default with a warning message
    *                                   to inform that real implementation is not available.
    ***/
    public virtual Integer getCount(final Object input, final String query) {
        System.debug(LoggingLevel.ERROR,'getCount: sfpegListQuery_SVC default implementation called.');
        throw new AuraHandledException('GetCount Query action not implemented!');
        //return null;
    }  

    /***
    * @description  Method to overide in Apex the default SOQL implementation of the sfpegList_CTL class
    *               to fetch each record set in case of paginated loading of data.
    * @param input  Context Object record containing all the input data expected
    *               by the query.
    * @param query  Text name of the query (optional) if the same override Apex class
    *               is used to implement multiple query logics.
    * @param lastValue Value of the last record returned previously (to be iused for pagination).
    * @return List<Object>  Result set of the query for the considered offset.
    * @exception AuraHandledException   Returned systematically by default with a warning message
    *                                   to inform that real implementation is not available.
    ***/
    public virtual List<Object> getPaginatedData(final Object input, final String query, final String lastValue) {
        System.debug(LoggingLevel.ERROR,'getPaginatedData: sfpegListQuery_SVC default implementation called.');
        throw new AuraHandledException('getPaginatedData: Query action not implemented!');
        //return null;
    }    
}