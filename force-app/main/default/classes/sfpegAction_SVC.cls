/***
* @author       P-E GROS
* @date         May 2021
* @description  Virtual handling class used by the sfpegAction_CTL generic controller to
*               implement custom Apex actions. 
*               Provides virtual default implementations of supported methods.
*               Default implementation throws exceptions to warn about missing implementation.
* @see          sfpegAction_CTL
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public virtual class sfpegAction_SVC {

    /***
    * @description  Method to provide an Apex logic implementation for the 
    *               sfpegAction_CTL generic controller class.
    * @param input  Context Object record containing all the input data expected
    *               by the action.
    * @param method Text name of the method (optional) if the same Apex class
    *               is used to implement multiple business logics.
    * @return Object  Object record containing the output of the Apex logic.
    * @exception AuraHandledException   Returned systematically by default with a warning message
    *                                   to inform that real implementation is not available.
    ***/
    public virtual Object execute(final Object input, final String method) {
        System.debug(LoggingLevel.ERROR,'execute: sfpegAction_SVC default implementation called.');
        throw new AuraHandledException('Execute Apex action not implemented!');
        //return null;
    }   
}