/** 
*Author : rpatnaik, 08/10/2017 , Docmation
*description : Helper class to process different operations 
**/

public class LeadTriggerHandler {
    
    public static void updateLanguageOnLead(Map<ID,Lead> oldLeadMap,List<Lead> newLeadList){
        Map<String,String> clMap = new Map<String,String>();
        
        List<Country_Lanugage__mdt> clList = [select EloquaLanguage__c ,Language__c from Country_Lanugage__mdt];
        for (Country_Lanugage__mdt cl : clList){
            clMap.put(cl.EloquaLanguage__c,cl.Language__c);
        }
        for(Lead l: newLeadList){
            if((l.ELanguage__c!=null)||(oldLeadMap!=null && oldLeadMap.get(l.id)!=null &&
                                        oldLeadMap.get(l.id).ELanguage__c!=l.ELanguage__c)){
                                            l.Language__c=(clMap.get(l.ELanguage__c)!=null)?clMap.get(l.ELanguage__c):'English';
                                        }
        }
    }
    
    public static void updateSalesOffice(List<Lead> lstLead ){
        //Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Lead.getRecordTypeInfosById();
        List<SalesOffice__mdt> soList = [select id, SalesOffice__c,Label, RecordTypeName__c ,CountryCode__c, 
                                         Product__c from SalesOffice__mdt];
        Map<String, SalesOffice__mdt> soMap = new Map<String, SalesOffice__mdt>();
        for(SalesOffice__mdt so : soList){
            soMap.put(so.CountryCode__c, so);
        }
        for(Lead l:lstLead){
            //String recordTypeName = l.RecordTypeId != null?rtMap.get(l.RecordTypeId).getName():'';
            if(soMap.get(l.Country)!= null &&l.product__c !=null && 
               (l.product__c.contains('Sage Live') || l.product__c.contains('Sage One')||
                l.product__c.contains('Financials')|| l.product__c.contains('Accounting')))
               // ||soMap.get(l.Country).RecordTypeName__c == recordTypeName))
            {
                l.Sales_Office__c = soMap.get(l.CountryCode).SalesOffice__c;
            }
            else{
                l.Sales_Office__c='None';
            }
        }
    }
    
    //Create Lead sharing rule based on the partner account
    public static void createpartnerRoleSharingLead(List<lead> lstLeads, Map<Id, Lead> LeadsMap){   
        Integer Time1 = Limits.getCpuTime();
        List<LeadShare> sharesToCreate = new List<LeadShare>();
        Set<Id> setReferringAccount = new Set<Id>();
        Map<string,Id> mapLeadAccount = new Map<string,Id>();
        Map<Id,Id> mapAccountRole = new Map<Id,Id>();
        Set<Id> leadIds = new Set<Id>();
        for(Lead l :lstLeads){
            leadIds.add(l.Id);
        }
        
        //Fetching all the leads
        List<lead> lstlead = [Select id,Referring_Partner_Account__c,createdBy.accountid from Lead 
                              where Id in : leadIds];
        for(Lead obj : lstlead){  
            string strLeadRefAcc = obj.Referring_Partner_Account__c!= null?obj.Referring_Partner_Account__c:obj.createdBy.accountid;
            if(strLeadRefAcc != null){
                setReferringAccount.add(strLeadRefAcc);
                mapLeadAccount.put(obj.Id,strLeadRefAcc);//Map of Lead Id and Account Id
            }
        }
        //Map of Partner User Role details it will always 1-1 based on community role setting
        Map<Id,UserRole> mapPartnerRole = new Map<Id,UserRole>([SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId,
                                                                PortalType, PortalRole,PortalAccountOwnerId FROM UserRole where PortalAccountId IN : setReferringAccount]);
        
        for(UserRole usrRole : mapPartnerRole.values()){
            mapAccountRole.put(usrRole.PortalAccountId,usrRole.Id);//Map of Account ID and User Role Id
        }
        Map<Id,Id> mapUserRoleandGroup = new Map<Id,Id>();
        
        //Fetch group Id based on User Role
        List<Group> lstGroup = [Select RelatedId, Id, Type FROM Group where RelatedId IN : mapPartnerRole.keyset()];
        
        for(Group grp : lstGroup){   
            if(grp.Type == 'RoleAndSubordinates'){
                mapUserRoleandGroup.put(grp.RelatedId,grp.Id);
            }
        }
        for(Id leadId : mapLeadAccount.keyset()){
            //Get Group Id based on UserRole Id
            string strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapLeadAccount.get(leadId)));
            //Creating lead Share record
            LeadShare Objlead = new LeadShare();
            Objlead.LeadAccessLevel = 'Read';
            Objlead.UserOrGroupId =  strgroupId;
            Objlead.LeadId= leadId;
            //adding to the sharing list to insert into lead sharing table
            sharesToCreate.add(Objlead);
        }
        if(!sharesToCreate.isEmpty()){
            Database.insert(sharesToCreate,false);//Inserting Sharing List 
        }
        Integer Time2 = Limits.getCpuTime();
        system.debug('createpartnerRoleSharingLead END  CpuTime= ' + (Time2-Time1));
    }
    
    //Method to Opportunity sharing record by Partner Role
    public static void createpartnerRoleSharingOpp(List<Lead> leads){   
        set<Id> setConvertedOpp = new set<Id>();
        for(Lead lead : leads) 
        {
            if(lead.Referring_Partner_Account__c != null && lead.IsConverted) 
            {
                setConvertedOpp.add(lead.ConvertedOpportunityId);
            }
        }
        if(!setConvertedOpp.isEmpty())
        {
            List<OpportunityShare> sharesToCreate = new List<OpportunityShare>();
            Set<Id> setReferringAccountID = new Set<Id>();
            Map<string,Id> mapOppAccount = new Map<string,Id>();
            Map<Id,Id> mapAccountRole = new Map<Id,Id>();
            
            //Fetching all the leads
            List<Opportunity> lstOpportunity = [Select id,Referring_Partner_Account__c from Opportunity 
                                                where Id in : setConvertedOpp];
            
            for(Opportunity obj : lstOpportunity)
            { 
                if(obj.Referring_Partner_Account__c != null)
                { 
                    setReferringAccountID.add(obj.Referring_Partner_Account__c);
                    mapOppAccount.put(obj.Id,obj.Referring_Partner_Account__c);//Map of Lead Id and Account Id
                }
            }
            //Map of Partner User Role details it will always 1-1 based on community role setting
            Map<Id,UserRole> mapPartnerRole = new Map<Id,UserRole>([SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId,
                                                                    PortalType, PortalRole,PortalAccountOwnerId FROM UserRole where PortalAccountId IN : setReferringAccountID]);
            
            for(UserRole usrRole : mapPartnerRole.values())
            {
                mapAccountRole.put(usrRole.PortalAccountId,usrRole.Id);//Map of Account ID and User Role Id
            }
            Map<Id,Id> mapUserRoleandGroup = new Map<Id,Id>();
            
            //Fetch group Id based on User Role
            List<Group> lstGroup = [Select RelatedId, Id, Type FROM Group where RelatedId IN : mapPartnerRole.keyset()];
            
            for(Group grp : lstGroup)
            {   
                if(grp.Type == 'RoleAndSubordinates')
                {
                    mapUserRoleandGroup.put(grp.RelatedId,grp.Id);
                }
            }
            for(Id OpportunityId : mapOppAccount.keyset())
            {
                //Get Group Id based on UserRole Id
                String strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapOppAccount.get(OpportunityId)));
                
                //Creating lead Share record
                OpportunityShare ObjOpportunity = new OpportunityShare();
                ObjOpportunity.OpportunityAccessLevel = 'Read';
                ObjOpportunity.UserOrGroupId =  strgroupId;
                ObjOpportunity.OpportunityId= OpportunityId;
                //adding to the sharing list to insert into Opportunity sharing table
                sharesToCreate.add(ObjOpportunity);
            }
            if (!sharesToCreate.isEmpty())
            {
                Database.insert(sharesToCreate,false);//Inserting Sharing List 
            }
        }            
    }
    
    //Adam Annony
    //Lead Playbook Play Status update
    public static void LeadPlaybookPlayStatusUpdate(list<Lead> newLeadList, Map<ID,Lead> oldLeadMap){
        
        for(Lead l : newLeadList){
            if (oldLeadMap != null  && 
                (oldLeadMap.get(l.id).Playbooks_Play_Status__c ==null && l.Playbooks_Play_Status__c == 'In-Flight') && 
                (l.Status != 'Archived' && l.Status != 'Qualified')){ 
                    l.Status = 'Working';
                } 
            else if(oldLeadMap.get(l.id).Playbooks_Play_Status__c== 'In-Flight' && 
                    l.Playbooks_Play_Status__c == 'Failure'){
                        l.Status_Reason__c = 'No Response';
                        l.Status = 'Archived';
                    }
        }
    } 
    
    public static void UpdateLatestMQLDateTime(list<Lead> leadList, Map<ID,Lead> oldLeadMap){
        for(Lead l : leadList){
            if (oldLeadMap != null && l.Funnel_Stage__c == 'MQL' && 
                (oldLeadMap.get(l.id).Funnel_Stage__c != l.Funnel_Stage__c) ){
                    l.Latest_MQL_Date__c = datetime.now();
                } 
        }
    }
    
    public static void UpdateLatestMQLDateTime(list<Lead> leadList){
        for(Lead l : leadList){
            if (l.Funnel_Stage__c == 'MQL' ){
                l.Latest_MQL_Date__c = datetime.now(); 
            }
        }
    }
    
    public static void updateFunnelStage(List<Lead> newLeads){//updates funnel stage on update
        
        for(Lead nLd : newLeads){
            //set Funnel stage = MQL
            
            //set Funnel stage = SAL when Lead status = Working
            if(nLd.Status=='Working'){ 
                nLd.Funnel_Stage__c='SAL';
            } 
            //set Funnel stage = SQO when Lead status = Qualified
            if(nLd.Status=='Qualified'){ 
                nLd.Funnel_Stage__c='SQO';
            } 
            //set Funnel stage = Blank when Lead status = Archived
            if(nLd.Status=='Archived'){ 
                nLd.Funnel_Stage__c='';
            }
            if ((nLd.Lead_Score__c=='A1'||nLd.Lead_Score__c=='A2'||nLd.Lead_Score__c=='A3'||nLd.Lead_Score__c=='B1'||nLd.Lead_Score__c=='B2'||nLd.Lead_Score__c=='C1')&&(nLd.Status=='New'||nLd.Status=='Open')){
                nLd.Funnel_Stage__c='MQL';
            }
            //set Funnel stage = Suspect
            if ((nLd.Lead_Score__c=='A4'||nLd.Lead_Score__c=='B4'||nLd.Lead_Score__c=='C4'||nLd.Lead_Score__c=='D4')&&(nLd.Status=='New'||nLd.Status=='Open')){
                nLd.Funnel_Stage__c='Suspect';
            }
            //set Funnel stage = Inquiry
            if ((nLd.Lead_Score__c=='B3'||nLd.Lead_Score__c=='C2'||nLd.Lead_Score__c=='C3'||nLd.Lead_Score__c=='D1'||nLd.Lead_Score__c=='D2'||nLd.Lead_Score__c=='D3')&&(nLd.Status=='New'||nLd.Status=='Open')){
                nLd.Funnel_Stage__c='Inquiry';
            }
            
        }
    }
    
    public static void partnerTierValidation(List<Lead> Leads){
        
        List<string> lstValidTiers = Label.SPPValidPartnerTierMap.split(','); 
        Set<string>  setValidTiers =  new Set<String>(lstValidTiers); 
        List<String> lstValidCountries = Label.ValidCountrytoCreateRefLead.split(',');
        Set<string>  setValidCountries =  new Set<String>(lstValidCountries);
        List<Account> lstAccount;
        
        List<User> u = [SELECT Name, AccountId,ContactId,Contact.Account.Locale__r.Name FROM User 
                        WHERE Id = :UserInfo.getUserId() and ProfileId =: Label.Sage_Partner_Community_Login_User];
        
        if(!u.isEmpty())
        {
            //Lu 09/22/2017
            
            //c Task takes partner to a referral lead form
            if(!setValidCountries.Contains(u[0].Contact.Account.Locale__r.Name))
            {
                Leads[0].addError(Label.ValidcountryReferralLeadMsg);
            }
            //Populate Referring Account and Contacts - process builder
            for(Lead l :leads){
                l.Referring_Partner_Account__c = u[0].AccountId;
                l.Referring_Partner_Contact__c = u[0].ContactId;
                l.Referring_User__c = u[0].Id;
            }
            Id accountId = u[0].AccountId;
            lstAccount = [Select Id,Partner_ISV__c,Partner_Alliance__c,Partner_Accountant__c,Partner_Implementation__c,
                          Accountant_Partner_Tier__c ,SI_Partner_Tier__c,Reseller_Partner_Tier__c,Partner_Reseller__c from Account Where Id =: accountId];
           
            for(Account acc : lstAccount)
            {
                Boolean ValidPartnerTierFound = false;
                
                if((acc.Partner_ISV__c || acc.Partner_Alliance__c) &&(acc.Partner_Accountant__c == false && acc.Partner_Implementation__c== false && acc.Partner_Reseller__c== false))
                {
                    Leads[0].addError(Label.Referral_Validation_Message);
                }
                else if(acc.Partner_Accountant__c == true && setValidTiers.Contains(acc.Accountant_Partner_Tier__c)) 
                {
                    ValidPartnerTierFound= true;
                }
                else if (acc.Partner_Implementation__c== true && setValidTiers.Contains(acc.SI_Partner_Tier__c)) 
                {
                    ValidPartnerTierFound= true;
                }
                else if(acc.Partner_Reseller__c== true && setValidTiers.Contains(acc.Reseller_Partner_Tier__c))
                {
                    ValidPartnerTierFound = true;
                }
                if(!ValidPartnerTierFound && !Test.isRunningTest())
                    Leads[0].addError(Label.Referral_Validation_Message);
            }
        }
    }
    
    public static void copyDescription(List<Lead> leads){
        for(Lead l :leads){
            if(l.Description != null){
                l.CopyDescriptionText__c = l.Description;  
            }
        }
    }
    
    //EAD-461
    /**
    * @author          Bhushan Sukumar (bhushan.sukumar@sage.com)
    * @description     logic to set the country code to UK for leads whose country code is set to GB, when inserting from
    * appexchange
    * @date            15 June 2017
    * @param leads     list of leads from before insert trigger
    */
    public static void setCountryCodeToUk(List<Lead> leads){
        
        //looping through leads and assigning the required country for 'UK' and 'US'. Currently this is hardcoded to
        //fix only for UK and US due to CPU time concerns. Ideally, a ISO Country map should be used.
        for (Lead record : leads) {
            
            //the country (integration value) will be 'GB' or 'US' for leads coming from appexchange.
            if (String.isNotBlank(record.Country) && record.Country.equals(Label.CountryCode_GB)) {
                record.Country = Label.CountryName_GB;
            } else if (String.isNotBlank(record.Country) && record.Country.equals(Label.CountryCode_US)) {
                record.Country = Label.CountryName_US;
            }
        }
    }
}