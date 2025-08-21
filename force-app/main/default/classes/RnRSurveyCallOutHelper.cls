public class RnRSurveyCallOutHelper {
    
	private static final String WEB_ORIGIN = 'Web';
    private static final String CHAT_ORIGIN = 'Chat';
    private static final String PHONE_ORIGIN = 'Phone';
    private static final String EMAIL_ORIGIN = 'Email';
    private static final String CUSTOMER_EMAIL_ORIGIN = 'Customer Email';
    private static final String QA_ORIGIN = 'Q&A';
    private static final String COMMUNITY_ORIGIN = 'Community';
    private static final String CS_ORIGIN = 'Crowdsourcing';
    private static final String SM_ORIGIN = 'Social Media';
    
    public static void sendSurveyRnR(List<Id> caseId, Map<Id, Case> oldItems){
        system.debug('sendSurveyRnR caseIds---- '+ caseId);
        List<case> cases = new List<Case>();
        List<Id> caseIds = new List<Id>();
        List<String> contactIds = new List<String>();
        List<case> casesToUpdate = new List<Case>();
     
        //survey will be sent out to standard cases and Global Cases only
       
        List<String> recordTypes = RnRSurveyCallOutHelper.getCaseRTFromMD();
        if(!Test.isRunningTest()){
            //0121o000000sgRxAAI, 012240000001fxtAAA)
            String GLOBAL_CASE_RECORDTYPE = recordTypes[0];
            String STANDARD_CASE_RECORDTYPE = recordTypes[1];
            
            cases =[select id,Contact.Allow_Experience_Feedback__c ,Contact.Local_CRM_Name__c , contactId, Reason, subject, description, Origin,createdDate, SourceId, ContactEmail, ContactPhone, ContactMobile,Product__c,OwnerId,
                     Last_survey_sent_date__c,contact.Last_Survey_Date__c, Status, Status_Reason__c,
                     Owner.Name,Owner.FirstName, Owner.LastName , contact.FirstName, Contact.LastName, Contact.Name, Contact.Salutation, Contact.Title, Contact.AccountId,
                     Contact.HasOptedOutOfEmail, Account.Name ,
                     Account.BillingCountry, Account.Type, contact.language__c 
                    From case where id IN :caseId and Status_Reason__c NOT IN ('Duplicate/Invalid Case','No Response')
                    AND ( (RecordTypeId = :STANDARD_CASE_RECORDTYPE and Reason != 'Duplicate Case') 
                         or 
                         (RecordTypeId = :GLOBAL_CASE_RECORDTYPE )
                        )		  
                   ];
           
        }
        else{
            cases = [select id, contactId, Reason, subject, description, Origin,createdDate, SourceId, ContactEmail, ContactPhone, ContactMobile,Product__c,OwnerId,
                     Last_survey_sent_date__c,contact.Last_Survey_Date__c, Status,Status_Reason__c,
                     Owner.Name,Owner.FirstName, Owner.LastName , contact.FirstName, Contact.LastName, Contact.Name, Contact.Salutation, Contact.Title, Contact.AccountId,
                     Contact.HasOptedOutOfEmail, Account.Name ,contact.language__c, 
                     Account.BillingCountry, Account.Type,Contact.Allow_Experience_Feedback__c,Contact.Local_CRM_Name__c
                     From case where id IN :caseId]; 
        }
        
        
        try{
            system.debug('cases = '+cases);
            
            CaseSurveyHandler surveyHandler = new CaseSurveyHandler();
            //surveyHandler.solicitSurvey(cases, oldItems);
            
            
        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('RnRSurveyCallOutHelper', 'Execute', e); 
        }
    }   
    
    public static void updateSurveySentFlag(List<Id> listOfCases){
        
        List<Case> cases = new List<Case>();
        
        if(listOfCases != null && listOfCases.size()>0)
        {
            for(Id caseId :listOfCases){
                //update Case record with true
                //this will indicate that the survey is successfully sent
                Case c = new Case(Id=caseId);
                
                c.Is_Survey_Sent__c = true;
                cases.add(c);
            }
            Database.update(cases, false);
            
        }
    }  
    
    public static List<String> getCaseOriginFromMD(){
        
        List<Survey_Origin__mdt> caseOriginMDTList = [SELECT Web__c,Chat__c,Email__c,Phone__c,Q_A__c,Community__c,CrowdSourcing__c,Social_Media__c,Customer_Email__c FROM Survey_Origin__mdt where DeveloperName = 'Contact_Case'];
        List<String> caseOriginInclusive = new List<String>();
        
        if(!caseOriginMDTList.isEmpty()){
          
            Survey_Origin__mdt caseOriginMDT = caseOriginMDTList[0];
       
            if(caseOriginMDT.Web__c)
            	caseOriginInclusive.add(WEB_ORIGIN);
            
            if(caseOriginMDT.Chat__c)
            	caseOriginInclusive.add(CHAT_ORIGIN);
            
            if(caseOriginMDT.Phone__c)
            	caseOriginInclusive.add(PHONE_ORIGIN);
            
            if(caseOriginMDT.Email__c)
            	caseOriginInclusive.add(EMAIL_ORIGIN);
            
            if(caseOriginMDT.Customer_Email__c)
            	caseOriginInclusive.add(CUSTOMER_EMAIL_ORIGIN);
            
            	if(caseOriginMDT.Q_A__c)
              caseOriginInclusive.add(QA_ORIGIN);
			  
			if(caseOriginMDT.Community__c)
              caseOriginInclusive.add(COMMUNITY_ORIGIN);
			  
			if(caseOriginMDT.CrowdSourcing__c)
              caseOriginInclusive.add(CS_ORIGIN);
			  
			if(caseOriginMDT.Social_Media__c)
              caseOriginInclusive.add(SM_ORIGIN);
            
        }
        
        return caseOriginInclusive;
    }
    
    public static List<String> getCaseRTFromMD(){
        
        List<Survey_Recordtype__mdt> caseRTMDTList = [SELECT Record_Type_Id__c,Record_Type_Name__c FROM Survey_Recordtype__mdt];
        
        List<String> caseRecordTypeList = new List<String>();
         
        if(!caseRTMDTList.isEmpty()){
            
            for(Survey_Recordtype__mdt caseRTMDT : caseRTMDTList){
                caseRecordTypeList.add(caseRTMDT.Record_Type_Id__c);
            }
        }
        
        return caseRecordTypeList;
    }
    
}