public class PayNowEmailer {
    
    public static void sendPayNowEmail(Id tokenId, Id recipientId, String emailTemplateName, boolean isTetris,String emailTemplateVariable){
        try
        {
            Messaging.SingleEmailMessage semail = getEmailMessage(tokenId, recipientId, emailTemplateName,isTetris,emailTemplateVariable);
            sendEmail(semail);
        }
        catch(Exception ex) 
        {
            ExceptionHandler.CatchException('PayNowEmailer', 'sendPayNowEmail', ex);
            System.debug('EmailPayNowToken error: '+ ex);
            throw new PayNowException('Error sending PayNow Email. Please try again later or contact your Administrator for assistance. ' + ex.getMessage());
        }   
    }
    
    @TestVisible
    private static Messaging.SingleEmailMessage getEmailMessage(Id tokenId, Id recipientId, String emailTemplateName, boolean isTetris,String emailTemplateVariable){
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        
        //Modified 2016-08-14 Docmation LLC
        //If the passed emailTemplateName is blank, then uses the default value defined in PayNowSettings.
        //Email Tempalte for PayNow email link is stored on the locale record.
        //
        String pnTemplateName = emailTemplateName==''?PayNowSetting__c.getInstance('PayNowEmailTemplateName').Value__c:emailTemplateName;
        EmailTemplate emailTemplate = getEmailTemplate(pnTemplateName);
        
        string templateId = emailTemplate.Id;
        string emailSubject = emailTemplate.Subject;
       
      
        String[] sendingToBccAdd = getBccList();
        
        sendingToBccAdd.add(UserInfo.getUserEmail());
        semail.setBccAddresses(sendingToBccAdd);
        
        string displayName = getDisplayName();
        semail.setSenderDisplayName(displayName);
              
        semail.setTemplateId(templateId);
       
        semail.setTargetObjectId(recipientId);
        semail.setWhatId(tokenId);
        
        semail.setSaveAsActivity(true);
        
        //Set Email subject when quote is from tetris
       //if (isTetris == true)
       //	semail.setSubject('Complete Your Purchase of '+ emailTemplateVariable);
        return semail;
    }
    
    @TestVisible
    private static string getDisplayName(){
        PayNowSetting__c pnDisplayName = PayNowSetting__c.getInstance('PayNowEmailDisplayName');
        
        if(pnDisplayName == null)
            return null;
        
        string displayName = pnDisplayName.Value__c;
        
        return displayName;
    }
    
    @TestVisible
    private static List<string> getBccList(){
        PayNowSetting__c pnBccList = PayNowSetting__c.getInstance('PayNowEmailBccList');
        
        if (pnBccList == null) {
            return new List<string>();
        }
        
        List<string> bccList = pnBccList.Value__c.split(',');
        
        return bccList;
    }
    
    @TestVisible
    private static EmailTemplate getEmailTemplate(String templateName){
        List<EmailTemplate> templates = [select Id, name, subject,HtmlValue,Body from EmailTemplate
                                         where Name =: templateName];
        
        if(templates.isEmpty())
            return null;
        
        return templates[0];
    }
    
    @TestVisible
    private static void sendEmail(Messaging.SingleEmailMessage message){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
    }
    
    
}