/*******************************************************************************************************
    * @description TO be used to send article to the case contact based on language
    * @author : Ravi Yalamati
    * @return
   */   

global class CaseControllerExtension {
    
    public Case caseObj { get; set; }
   // public String raURL { get; set; }
    public String contactId { get; set; }
    public String htmlFromTemplate { get; set; }
    public String language { get; set; }
    public String subject { get; set; }
    public String Status { get; set; }
    public boolean isSuccess {get;set;}
    public String message { get; set; }
    public Map<String, String> emailTemplateMappings;
    public boolean displayPopup {get;set;}
    public List<ArticleWrapper> rightAnswersList {get;set;}
    public String urls { get; set; }
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public CaseControllerExtension(ApexPages.StandardController stdController) {
        this.caseObj = (Case)stdController.getRecord();
        emailTemplateMappings = new Map<String, String>();
        for(Email_Template_Mapping__mdt templateMapping : [SELECT Id, DeveloperName, Email_Template_Name__c FROM Email_Template_Mapping__mdt]){
            emailTemplateMappings.put(templateMapping.DeveloperName, templateMapping.Email_Template_Name__c);
        }
        displayPopup = false;
        urls = '';
        rightAnswersList = new List<ArticleWrapper>();
        for(RightAnswersAttached__c objRightAnswer : [SELECT Id, Solution_URL__c, Solution_Title__c, Public__c FROM RightAnswersAttached__c 
                                                                WHERE CaseNumber__c =: caseObj.Id]){
                                                                rightAnswersList.add(new ArticleWrapper(objRightAnswer));
                                                                }
    }
    
    public PageReference processSelected() {
        //List<RightAnswersAttached__c> rightAnswers = new List<RightAnswersAttached__c>();
        urls = '';
        for(ArticleWrapper wrapRAObj : rightAnswersList) {
            if(wrapRAObj.selected == true) {
                urls += wrapRAObj.rightAnswer.Solution_URL__c + ',';
                wrapRAObj.selected = false;
            }
        }
        urls = urls.removeEnd(',');
        displayPopup = false;
        return null;
    }
    
    public class ArticleWrapper {
        public RightAnswersAttached__c rightAnswer {get; set;}
        public Boolean selected {get; set;}
 
        public ArticleWrapper(RightAnswersAttached__c objR) {
            rightAnswer = objR;
            selected = false;
        }
    }
    
    public PageReference closePopup() 
    {
        displayPopup = false;
        for(ArticleWrapper wrapRAObj : rightAnswersList) {
            if(wrapRAObj.selected == true) {
                wrapRAObj.selected = false;
            }
        }
        System.debug('displayPopup '+displayPopup);
        return null;
    } 
    public PageReference showPopup() 
    {
        displayPopup = true;
        return null;
    }
  /*******************************************************************************************************
    * @description init action to be invoked immediately before VF page is loaded and instantiate instance variable to be used on VF page
    * @return
   */   
    public void init(){
        
        System.debug('Id = '+ caseObj.Id);
        String emailTemplateName = '';
        
        List<Case> caseList = [Select Id, Status, ContactId, Contact.FirstName,Owner.Name, Language__c FROM Case where Id = : caseObj.Id];
        
        Case caseDetails = null;
        if(caseList.size() > 0){
            
            caseDetails = caseList[0];
            contactId = caseDetails.ContactId;
            language = caseDetails.Language__c;
            Status = caseDetails.Status;
            System.debug('Id = '+ caseDetails.Language__c);
            if(caseDetails.Language__c != null && emailTemplateMappings.containsKey(caseDetails.Language__c)){
                emailTemplateName = emailTemplateMappings.get(caseDetails.Language__c);
                system.debug('emailTemplateName'+emailTemplateName);
            }else{
                emailTemplateName = emailTemplateMappings.get('Default');
            }
            /*if(caseDetails.Language__c == 'English' || caseDetails.Language__c == null){
                emailTemplateName = 'Global_KB_Article_Email_English';
            }else{
                emailTemplateName = 'Global_KB_Article_Email_french'; 
            }*/
            
            if(emailTemplateName !=  null){
                
                List<EmailTemplate> emailTemplates = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = : emailTemplateName];
                
                if(emailTemplates.size() > 0){
                    
                    EmailTemplate emailTemplateObj = emailTemplates[0];
                    System.debug('HtmlValue = '+emailTemplateObj.HtmlValue);
                    Subject = emailTemplateObj.Subject;
                    String htmlBody = emailTemplateObj.HtmlValue;
                    
                    if(caseDetails.Contact.FirstName != null){
                        htmlBody = htmlBody.replace('{!Contact.FirstName}', caseDetails.Contact.FirstName);
                    }else{
                        htmlBody = htmlBody.replace('{!Contact.FirstName}','');
                    }
                    
                    
                    if(caseDetails.Owner.Name != null){
                        htmlBody = htmlBody.replace('{!Case.OwnerFullName}', caseDetails.Owner.Name);
                    }
                    
              
                    htmlFromTemplate = htmlBody;
                }
                
                
            }
        }
    }
    
    
    /*******************************************************************************************************
    * @description send article based on language
    * @param caseId Id to get contact and case details
    * @param raURL the name of the field to look up
    * @param toEmail Email Value
    * @param ccEmail Email Value
    * @param bccEmail Email Value
    * @param htmlContent Html to be used in email
    * @return Map of result wuth success and message
   */
    @RemoteAction
    global static Map<String,Object> sendEmailRemoteAction(String caseId, String raURL, String toEmail, String ccEmail, String bccEmail, String htmlContent){
        System.debug(' caseId '+caseId);
        System.debug(' raURL '+raURL);
        System.debug(' toEmail '+toEmail);
        System.debug(' ccEmail '+ccEmail);
        System.debug(' bccEmail '+bccEmail);
        System.debug(' htmlContent '+htmlContent);
        Map<String, String> emailTemplateMappings = new Map<String, String>();
        for(Email_Template_Mapping__mdt templateMapping : [SELECT Id, DeveloperName, Email_Template_Name__c FROM Email_Template_Mapping__mdt]){
            emailTemplateMappings.put(templateMapping.DeveloperName, templateMapping.Email_Template_Name__c);
        }
        Map<String,Object> returnMap = new Map<String,Object>();
        returnMap.put('isSuccess',false); 
        List<Case> caseList = [Select Id, Status, Contact.Name,  Contact.Email, Language__c , Owner.Name FROM Case where Id = : caseId];
        List<String> toEmailAddresses = new List<String> ();
        List<String> ccEmailAddresses =  new List<String> ();
        List<String> bccEmailAddresses = new List<String> ();
        
        if(toEmail != null && toEmail.indexOf(';')  >= 0){
            toEmailAddresses = toEmail.split(';');
        }else if(toEmail != null && toEmail.indexOf(';') < 0){
            toEmailAddresses.add(toEmail);
        }
        
        if(ccEmail != null && ccEmail.indexOf(';')  >= 0){
            ccEmailAddresses = ccEmail.split(';', 0);
        }else if(ccEmail != null && ccEmail.indexOf(';') < 0){
            ccEmailAddresses.add(ccEmail);
        }
        
        if(bccEmail != null && bccEmail.indexOf(';')  >= 0){
            bccEmailAddresses = bccEmail.split(';', 0);
        }else if(bccEmail != null && bccEmail.indexOf(';') < 0){
            bccEmailAddresses.add(bccEmail);        
        }
        
        //If case exist
        if(caseList.size() > 0 && toEmailAddresses.size() > 0){
            
            Case caseObj = caseList[0];
            String emailTemplateName;
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply15@sage.com'];
            if ( owea.size() > 0 ) {
                emailMessage.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            //emailMessage.setSenderDisplayName('Sage Support'); 
            emailMessage.setReplyTo('no-reply15@sage.com');
            emailMessage.setUseSignature(false); 
            emailMessage.setSaveAsActivity(true); 
            
            if(caseObj.Language__c != null && emailTemplateMappings.containsKey(caseObj.Language__c)){
                emailTemplateName = emailTemplateMappings.get(caseObj.Language__c);
            }else{
                emailTemplateName = emailTemplateMappings.get('Default');
            }
            /*if(caseObj.Language__c == 'English' || caseObj.Language__c == null){
                emailTemplateName = 'Global_KB_Article_Email_English';
            }else{
                emailTemplateName = 'Global_KB_Article_Email_french';
            }*/
            
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = : emailTemplateName];
            
            
            emailMessage.setTemplateID(emailTemplate.Id); 
            emailMessage.setHtmlBody(htmlContent);
            emailMessage.setSubject(emailTemplate.Subject);
            emailMessage.toAddresses = toEmailAddresses;
            emailMessage.setWhatId(caseObj.Id);
            if(bccEmail != '' && bccEmailAddresses.size() > 0){ System.debug('inside bcc');emailMessage.bccaddresses = bccEmailAddresses; }
            if(ccEmail != '' &&  ccEmailAddresses.size() > 0){  emailMessage.ccaddresses = ccEmailAddresses; }
            
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {emailMessage};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            
            if (results[0].success) 
            {
                //createFeedForSentArticle(caseObj, toEmail, htmlContent.stripHtmlTags());
                createEmailMessageFeed(caseObj, toEmail, htmlContent.stripHtmlTags());
                returnMap.put('isSuccess',true); 
                returnMap.put('message','The email was sent successfully.');
                return returnMap;
            } else {
                returnMap.put('isSuccess',false); 
                returnMap.put('message', 'The email failed to send: ' + results[0].errors[0].message);
                System.debug(LoggingLevel.INFO + 'The email failed to send: ' +  results[0].errors[0].message);
                return returnMap;
            }
        }//if end
        
        System.debug('The email was sent returnMap.'+ returnMap);
        return returnMap;
    }//end of method
    
    
    /*******************************************************************************************************
    * @description Creates Feed Item for the Case
    * @param Case contains case details
    * @param toEmail email value to be used for appenind to title
    * @param body contans content of email body
    * @return 
    */
   /* public static void createFeedForSentArticle(Case caseObj, String toEmail, String body){
        
        FeedItem fi = new FeedItem();
        fi.ParentId = caseObj.Id;
        fi.Title = 'Email Sent to '+ toEmail;
        fi.Body = body;
        
        insert fi;
        
    }
*/
/*******************************************************************************************************
    * @description Creates Feed Item for the Case
    * @param Case contains case details
    * @param toEmail email value to be used for appenind to title
    * @param body contans content of email body
    * @return 
    */
    public static void createEmailMessageFeed(Case caseObj, String toEmail, String body){
        
        EmailMessage em = new EmailMessage();
        em.ParentId = caseObj.Id;
        em.Subject = 'Email Sent to '+ toEmail;
        em.ToAddress = toEmail;
        em.TextBody = body;
        
        insert em;
        
    }    
}