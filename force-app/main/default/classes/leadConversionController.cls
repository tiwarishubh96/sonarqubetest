public class leadConversionController {
    @auraEnabled
    public static string getAccountName(Id acctId)
    {
        List<Account> acct = [SELECT Id, Name From Account where Id = :acctId LIMIT 1];
        if (acct.size() == 1 ){
            return acct[0].Name;
        }
        else{ return null;}
            
    }    
        
 	@auraEnabled
    public static Id convertLead (id leadRecId, boolean isNewAcct, boolean isNewContact, boolean isNewOpp, 
                                  boolean isNoCreatedOpp, boolean isUpdateLeadSource,
                                  string newAcctName, string newContactName, string newOppName,
                                  id acctRecId, id contactRecId, id oppRecId){
    
	Database.LeadConvert lc = new Database.LeadConvert();                                      
	Id retAcctId;
	Id retContactId;
	Id retOppId; 
    try{
		system.debug('======' + leadRecId); 
        system.debug('======' +	isNewAcct);
        system.debug('======' + isNewContact);
        system.debug('======' + isNewOpp);
        system.debug('======' + isNoCreatedOpp);
        system.debug('======' + isUpdateLeadSource);
        system.debug('======' + newAcctName);
        system.debug('======' + newContactName);
        system.debug('======' + newOppName);           
        system.debug('======' + acctRecId);
        system.debug('======' + contactRecId);
        system.debug('======' + oppRecId);
        // 1. create new lead convert
        lc.setLeadId(leadRecId);
        lc.setOwnerId(UserInfo.getUserId() );
          // 2. Account  
        if (isNewAcct){}       
        else {lc.setAccountId(acctRecId) ;}     
        
        // 3. Contact
        if (isNewContact){}
        else {lc.setContactId(contactRecId);
        }          
        // 4. Opportunity
        if (isNewOpp){
            if (String.isBlank(newOppName)){ 
                // allow upto 80 characters
                if (newAcctName.length() > 80) { lc.setOpportunityName(newAcctName.Left(80)); }
                else { lc.setOpportunityName(newAcctName); }
            } else { lc.setOpportunityName(newOppName); }
        } else { lc.setOpportunityId(oppRecId); }          
        
        // 5. set property
        lc.setDoNotCreateOpportunity(isNoCreatedOpp);
        lc.setOverwriteLeadSource(isUpdateLeadSource);
        
        // 6. set Lead Status
		leadstatus ls=[select id,MasterLabel,IsConverted from LeadStatus where IsConverted=true limit 1];        
        lc.setConvertedStatus(ls.MasterLabel);
        
        // 7. get conversion result
        Database.LeadConvertResult lcr=Database.convertLead(lc);
        if (lcr.isSuccess()){        
       		retAcctId=lcr.getAccountId();
       		retContactId=lcr.getContactId();
       		retOppId=lcr.getOpportunityId();
            return retAcctId;
        }
        else
            return null;        
     }catch(Exception ex) {
        System.debug('--leadconvert:'+ex.getMessage());
        throw new AuraHandledException(ex.getMessage());
     }                                     
   }     
}