/*********************************************************************
Name    : SPPTnCValidationsStrings
Company : Docmation LLC 
Author  : Lakshman Jaasti
Date    : 06/15/2017
Description :  Class is used Display Validation Messages.
**********************************************************************/

public class SPPTnCValidationsStrings 
{
    //Validation for SPPActivateNewT&c
    public String validateDeActivated = 'Partner Legal Agreements De-activated Can not Activate it';
    public String validateActivated = 'Partner Legal Agreements Already activated';
    public String activated = 'Activated Successfully';
    
    //onActivateTnCVersions SPPTnCUtils
    public String BulkSentSuccess = 'Partner Legal Agreements Sent Successfully';
    public String bulkTempEmpty = 'Please insert the Bulk Template Id';
    
    //SPPSendTnCWithDocuSignController
    public String tncAlreadySent = 'Partner Legal Agreements already sent, Please wait for response';
    public String successSent = 'Partner Legal Agreements sent successfully';
    public String catchError = 'API Exception';
    public String errorMsg = 'Error While Sending Aggrement';
    
    //SPPTnCUtils getTemplateList
    public String bespokeMsg = 'We cannot send Bespoke Partner Legal Agreements with Docusign';
    public String noLegal = 'There is no Legal Contact to send Partner Legal Agreements';
    public static final String noTemplates = 'There are no Partner Legal Agreements Templates to send';
    
}