global class PartnerCommRegistrationEmail
{
    
    @InvocableMethod
    global static void sendPartnerCommRegistrationEmail(List<Id> contactId) 
    {
        Map<string,string> maplocaleEmailtemap = new Map<string,string>();
        Map<string,string> mapEmailTempId = new Map<string,string>();
        
        List<Partner_Community_Locale_Settings__c> listB = Partner_Community_Locale_Settings__c.getAll().values();  // Query Partner Custom Setting
        set<string> settemplatename = new set<string>();
        
        for(Partner_Community_Locale_Settings__c p : listB)
        {
            settemplatename.add(p.Registration_Email_Template_Name__c);
        }
        
        List<EmailTemplate> Templateid=[Select id,Name from EmailTemplate where Name in : settemplatename]; // Query Email Templates  
        for(EmailTemplate e :  Templateid)
        {
            mapEmailTempId.put(e.Name,e.Id); // Preparing  Map of Email template Name and ID
        }
        system.debug(' mapEmailTempId :'+ mapEmailTempId);      
        for(Partner_Community_Locale_Settings__c p : listB)
        {
            if(mapEmailTempId.ContainsKey(p.Registration_Email_Template_Name__c))// Check if the Name Exists in the Map    
                maplocaleEmailtemap.put(p.Locale__c,mapEmailTempId.get(p.Registration_Email_Template_Name__c));// Preparing Map of Locale and Email template Id
  
        }
        
        system.debug('>>>>'+maplocaleEmailtemap);
    
        List<contact> lstcon  = [select Name,id,email,Account.Locale__r.Name,Account.Locale_Billing_CC__c,(Select Id, Name, Community__c, Contact__c, Invite_Code__c, Status__c From Community_Membership__r order by Expiration_Date__c desc Limit 1) from contact where id in : contactId]; // Querying Contact and its related Commuinty Membership
        
        Map<string,string> mapconuser= new Map<string,string>();
        
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply15@sage.com'];
        for(Contact c : lstcon)
        {
            if(c.Email != null)
            {
                string strCommuId = '';
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                for(Community_Membership__c comm : c.Community_Membership__r)
                {
                    strCommuId = comm.Id;
                }
                
                
                if ( owea.size() > 0 ) {
                    emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                String[] Email=new String[]{};
                    Email.add(c.Email);
                
                emailToSend.setToAddresses(Email);
                system.debug('sendPartnerCommRegistrationEmail'+getLocalevaluefromMapping.getlocalefromMapping(c.Account.Locale__r.Name,c.Account.Locale_Billing_CC__c));
                
                String Locale=getLocalevaluefromMapping.getlocalefromMapping(c.Account.Locale__r.Name,c.Account.Locale_Billing_CC__c);
                
                if(maplocaleEmailtemap.containsKey(Locale))
                {
                    emailToSend.setTemplateId(maplocaleEmailtemap.get(Locale));
                }
                else{
                    Locale='Default';
                    emailToSend.setTemplateId(maplocaleEmailtemap.get(Locale));
                }
                system.debug('>>>>>strCommuId '+strCommuId );
                
                emailToSend.setWhatId((Id)strCommuId);
                
                emailToSend.setTargetObjectId(c.id);
                 emailToSend.setSaveAsActivity(false);
                msgListToBeSend.add(emailToSend);
                
            }
            
        }
        Messaging.sendEmail(msgListToBeSend);
        
    }
}