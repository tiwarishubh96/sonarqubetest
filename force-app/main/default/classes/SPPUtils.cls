/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          06/06/2017
    Company:       
    Description:   Utility Class for all SPP related module Tnc , Referral, Resell
    Inputs:        None
    History:        Lu, 10/06/2017, SPP-762 Update Mulesoft Authentication to oAuth
                    merged CalltoMuleSoft methods into one method by adding a third 
                    param to distinguish the basic and OAuth calls.
                    Lu, 10/12/2017, created sendDebugEmail method for sending debug
                    emails to the developers
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
public class SPPUtils
{
      //Variables to Stop Recurssion from making call future call from a future class
    public static Boolean isCalledFromQuoteCharge = false;
    public static Boolean isCalledFromQuoteRatePlanCharge = false;
    //public static Id sharedOppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Shared Opportunity').getRecordTypeId();
    
    public static Map<String, Zuora__Subscription__c> mapNameSubscription = new Map<String, Zuora__Subscription__c>();
    
    //public static Contact c = [select id, Email from Contact where email <> null limit 1];
    public class deserializeResponse
    {
        public String access_token;
    } 
    
    public static map<String, String> mapValidPartnerTypes= new map<String, String> {'Accountant' => 'Accountant', 
        'Reseller' => 'Reseller', 
        'System_Implementers' => 'System Implementers'};
            
    //Map of Sage Cloud Products 
     public static Map<ID,Sage_Cloud_Product__mdt> allCloudProduct
        {
            get {
                if (allCloudProduct == null) 
                {
                    allCloudProduct = new Map<ID,Sage_Cloud_Product__mdt>([SELECT ID, DeveloperName
                                                                           ,Sold_Cloud_C_line_product__c,Sold_Product_Referral_Threshold__c,Sold_ZProduct__c FROM Sage_Cloud_Product__mdt
                                                                          ]);
                }
                
                return allCloudProduct;
            }
            set;
        }

    public static Boolean isSandbox()
    {

        Organization org = new Organization();
        org = [ select IsSandbox  from Organization limit 1];
                return org.IsSandbox;
    }
    
    //SOQL on Partner Custom Meta Data to get the all the Field API names related to different Partner
    public static List<Partner_Field__mdt> partnerfieldMapping
    {
        get {
            if (partnerfieldMapping== null) 
            {
                partnerfieldMapping=[SELECT MasterLabel, QualifiedApiName,DeveloperName, Partners__c ,
                                     Partner_Tier__c,Partner_TnC_Accepted__c FROM Partner_Field__mdt];
            }
            
            return partnerfieldMapping;
        }
        set;
    } 
    
    public static Messaging.SingleEmailMessage createUserEmailListToSend(List<String> lstEmailTo,String strEmailSubject,String strEmailBody) 
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setToAddresses(lstEmailTo);
        
        email.setSubject(strEmailSubject);
        
        email.setPlainTextBody(strEmailBody);
              
        return email;
    }

    //Method to add Multiple Invoices in a query
        public static String returnInvoices(set<string> lstInvoices)
        {
         
         String strInvoiceId='';
         for(string str :lstInvoices)
         {
              if(!String.IsEmpty(str))
              {
               strInvoiceId += 'InvoiceId=\''+str +'\' OR ';
              }
         }
           
         return strInvoiceId;
        } 
        
        //Method to add Rate Plans Ids in a query
        public static String returnRatePlaneIds(set<string> lstratePlanIds)
        {
         
         String strRateId='';
         for(string str :lstratePlanIds)
         {
              if(!String.IsEmpty(str))
              {
              strRateId += 'Id=\''+str +'\' OR ';
              }
         }
           
         return strRateId;
        } 
        
        //Method to add Invoic Line Items Ids in a query
        public static String returnInvoiceLineIds(set<string> lstInvoiceItemIds)
        {
         
         String strInvLineId='';
         for(string str :lstInvoiceItemIds)
         {
             if(!String.IsEmpty(str))
             {
                 strInvLineId += 'SourceId=\''+str +'\' OR ';
             }
         }
           
         return strInvLineId;
        }  
        
            
        //Method to add Invoic Credit Bal Adj Ids in a query
        public static String returnInvoiceCrediBalIds(set<string> lstInvoiceCredBalIds)
        {
         
            String strInvCredBalId='';
             
            for(string str :lstInvoiceCredBalIds)
            {
                if(!String.IsEmpty(str))
                {
                    strInvCredBalId += 'SourceTransactionId=\''+str +'\' OR ';
                }
            }
               
            return strInvCredBalId;
        } 
            
     //Method to retrive the field dynamically based on the Sobject Name
     public static String ObjectFields(String ObjectNameval)
     {
        string fieldsVal = '';
        SObjectType objToken = Schema.getGlobalDescribe().get(ObjectNameval);
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap();
            Set<String> fieldSet = fields.keySet();
        
        for(string f : fieldSet)
        {
           fieldsVal += f +',';
        }   
        
        if(fieldsVal.endsWith(','))
        fieldsVal= fieldsVal.substring(0,fieldsVal.length()-1);
        return fieldsVal;
     }
    
    //Lu 10/12/2017 implemented sendDebugEmail function in SPPUtils
    public static void sendDebugEmail(List<Messaging.SingleEmailMessage> allMails, String endpointType, String jsonData, String JSONString){
        if((!String.Isempty(Label.SendDebugEmailAddress) && Label.SendDebugEmail == 'true') || Test.isRunningTest()){
            List<String> lstEmail = Label.SendDebugEmailAddress.split(',');
            if(endpointType.equals('Commission')){
                allMails.add(SPPUtils.createEmailListToSend(lstEmail,isSandbox()?'Sandbox':'Production'+' Mulesoft Commission JSON','Json Request: '+jsonData +'\r\n\r\n'+'Json Response: '+JSONString));
            }
            else if(endpointType.equals('Margin')){
                allMails.add(SPPUtils.createEmailListToSend(lstEmail,isSandbox()?'Sandbox':'Production'+' Mulesoft Margin JSON','Json Request: '+jsonData +'\r\n\r\n'+'Json Response: '+JSONString));
            }
            system.debug('allMails'+allMails);
                    
            Messaging.sendEmail(allMails);
        }  
    }

    public static Messaging.SingleEmailMessage createEmailListToSend(List<String> lstEmailTo,String strEmailSubject,String strEmailBody) 
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setToAddresses(lstEmailTo);
        
        email.setSubject(strEmailSubject);
        
        email.setPlainTextBody(strEmailBody);
              
        return email;
    }
    
    //return partner tier assuming a parnter has only one tier or same tiers,
    //as per business requirement, the partner tier can only be changed once a year
    public static String getPartnerTier(Date subStartDate,Date subTermEndDate, Account a,String subType,Date subTermStartDate,List<Partner_Field__mdt> partnerfieldMapping)
    {
        
        String strPartnerTiers='';
        
        System.debug('Date.today():::'+Date.today());
        
        System.debug('subStartDate::'+subStartDate);
        
        System.debug('a::'+ a);
 
        for(Partner_Field__mdt objPfield : partnerfieldMapping)
        {
            //Condition to check if Partner and Partner Tier has some values 
            //and Partner_TnC_Accepted__c false to show the latest Attachments
            if(a.get(objPfield.Partners__c) == true 
               && a.get(objPfield.Partner_Tier__c) != null 
               && mapValidPartnerTypes.containskey(objPfield.DeveloperName))
            {    
                system.debug('objPfield.DeveloperName'+objPfield.DeveloperName);
                
                system.debug('subType::'+subType);
                
                system.debug('subTermStartDate::'+subTermStartDate);
                
                system.debug('startDate::'+subTermEndDate);
                
                system.debug('a.Partner_Old_Tier__c::'+a.Partner_Old_Tier__c);
                
                system.debug('a.get(objPfield.Partner_Tier__c)::'+a.get(objPfield.Partner_Tier__c));
                
                
                if(subType == 'New Subscription' || subType == 'Renew Subscription'){
                    
                    strPartnerTiers = (String)a.get(objPfield.Partner_Tier__c);
                }
                // if sub type is amend then we need to see when to use old tier type
                else{
                        //Date.today() is the day that amendment happnes and Tier_Changed_Date__c is the day that tier changed
                        //we need old tier value when the tier change and amendment happens within each subscription period.
                        if(Date.today() <=subTermEndDate && Date.today() >= subTermStartDate 
                           && a.Tier_Changed_Date__c <= subTermEndDate && a.Tier_Changed_Date__c >= subTermStartDate
                           && a.Partner_Old_Tier__c != Null){

                            strPartnerTiers = (String)a.Partner_Old_Tier__c;        
                        
                        }else{
                                
                            strPartnerTiers = (String)a.get(objPfield.Partner_Tier__c);
                        }
                }
            }
        }

        system.debug('strPartnerTiers::: '+strPartnerTiers );
        
        return strPartnerTiers;

    }
    
    public static void updateResellMarginFromTrigger(Set<ID> quoteIds){
        
        system.debug('>>>'+ SPPUtils.isCalledFromQuoteRatePlanCharge);
        
        system.debug('system.isFuture>>>'+system.isFuture());
        //avoid recursive trigger
        if(system.isFuture()) return;
        
        List<SPPResellOrderDetailWrapper> orderDetailWr=new List<SPPResellOrderDetailWrapper>();
        
        Map<string,Sage_Cloud_Product__mdt> mapSoldProduct = new Map<string,Sage_Cloud_Product__mdt>();
        
        Set<Id> setPartnerAcc = new Set<Id>();
        
        PartnerTierAndTotalMargin tierTM = new PartnerTierAndTotalMargin();
        
        //Create a Map of all the Quotes related to the Quote Charge records.
        
        List<zqu__Quote__c> lstQuote = [SELECT Id,
                                        zqu__RenewalTerm__c,
                                        zqu__Opportunity__c,
                                        RecordType.Name,
                                        zqu__StartDate__c,
                                        zqu__Opportunity__r.AccountId,
                                        zqu__Opportunity__r.Account.Partner_Agreement__c,
                                        zqu__Account__c,
                                        zqu__Account__r.Customer_Type__c,
                                        zqu__Subscription_Name__c,
                                        zqu__SubscriptionTermStartDate__c, 
                                        zqu__SubscriptionTermEndDate__c,                                                        
                                        zqu__SubscriptionType__c,
                                        zqu__InitialTerm__c 
                                        FROM zqu__Quote__c 
                                        WHERE Id in:quoteIds 
                                        AND zqu__Opportunity__r.Account.RecordType.Name = 'Partner Account' 
                                        AND (zqu__Opportunity__r.Type ='Resell Business' OR zqu__Opportunity__r.Type ='Renewal Business' OR zqu__Opportunity__r.Type ='Add-on Business')];
        
        Map<Id,zqu__Quote__c> quoteMap = new Map<Id,zqu__Quote__c>(lstQuote);
        
        system.debug('quoteMap::'+quoteMap);
        
        if(!quoteMap.isempty())
        {
            
            for(zqu__Quote__c obj :quoteMap.values())
            {
                setPartnerAcc.add(obj.zqu__Opportunity__r.AccountId);//Set of all the Partner Account related to an Oppty
            } 
            
            system.debug('spputils.allCloudProduct.values()::'+allCloudProduct.values());
            
            //Query Partner Account Details
            String fieldsAPIname = spputils.ObjectFields('Account');
            
            Map<ID,Account> mapPartnerAcc = new Map<Id, Account>(
                (List<Account>)Database.query('Select Locale__r.Name,'+fieldsAPIname+' from Account WHERE Id IN : setPartnerAcc'));
            
            system.debug('mapPartnerAcc::'+mapPartnerAcc);
            
            String qrpcFieldsAPIname = ObjectFields('zqu__QuoteRatePlanCharge__c');
            
            system.debug('qrpcFieldsAPIname::'+qrpcFieldsAPIname);
            
            List<zqu__QuoteRatePlanCharge__c> lstallSobjQuoteRateChargeRecords = Database.query('Select '+qrpcFieldsAPIname+' from zqu__QuoteRatePlanCharge__c WHERE Quote__c IN : quoteIds');
            
            system.debug('lstallSobjQuoteRateChargeRecords::'+lstallSobjQuoteRateChargeRecords);
            
            for(zqu__QuoteRatePlanCharge__c q: lstallSobjQuoteRateChargeRecords){
                
                orderDetailWr.add(new SPPResellOrderDetailWrapper(getPartnerTier(
                                                                    quoteMap.get(q.Quote__c).zqu__StartDate__c,
                                                                    quoteMap.get(q.Quote__c).zqu__SubscriptionTermEndDate__c,
                                                                    mapPartnerAcc.get(quoteMap.get(q.Quote__c).zqu__Opportunity__r.AccountID),
                                                                    quoteMap.get(q.Quote__c).zqu__SubscriptionType__c,
                                                                    quoteMap.get(q.Quote__c).zqu__SubscriptionTermStartDate__c,
                                                                    spputils.partnerfieldMapping),
                                                                  q.id,  
                                                                  quoteMap.get(q.Quote__c).zqu__Opportunity__r.Account.Partner_Agreement__c
                                                                 )); 
            }
            
            system.debug('orderDetailWr::'+orderDetailWr);
            
            //Serializing Wrapper Class to Generate the JSON structure. 
            String JSONString = JSON.serialize(orderDetailWr);
            
            System.debug('JSON String :'+JSONString);
            
            String straddReqID='{"RequestId": "'+GUIDHelper.generateGUID()+'","Async": false,"CallbackUrl": "","Orders":'+JSONString+'}';
            
            //Replacing some extra characters to correct the JSON format
            String finalJsonStr = straddReqID.replace('\\', '').replace('":"[', '":[').replace(']","','],"'); 
            
            System.debug('List of values passing to Mulesoft:'+finalJsonStr);
            
            //Pass JSON information to the Mulesoft Helper
            SPPResellConnectionMulesoftController.ResellOrderDetailListForPlugin(finalJsonStr);
        }

   
    } 
    //Wrapper class to return mdf and total margin
    public class PartnerTierAndTotalMargin{
        
        public String pTier;
        
        public Decimal totalMargin;
        
        public PartnerTierAndTotalMargin(){ 
            
            this.pTier = 'No Tier';
            
            this.totalMargin = 0;
        }
    }

    //Inner class for returning multiple maps
    public class mapList{
        
        public Map<Id, Id> mapAccountRole;
        
        public Map<Id, Id> mapUserRoleandGroup;
        
        public mapList(){
            
            this.mapAccountRole = new Map<Id, Id>();
            
            this.mapUserRoleandGroup = new Map<Id, Id>();
        }
    }  

    //Generic function to get the map of portal account id and user role account id 
    public static mapList getMapAccountRole(Set<Id> setReferringAccount){
        
        Map<Id,Id> mapAccountRole = new Map<Id,Id>();
        
        Map<Id,UserRole> mapPartnerRole = new Map<Id,UserRole>([SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId,
        PortalType, PortalRole,PortalAccountOwnerId FROM UserRole where PortalAccountId IN : setReferringAccount]);
        
        for(UserRole usrRole : mapPartnerRole.values())
        {
            system.debug('usrRole.PortalAccountId'+usrRole.PortalAccountId);
            
            mapAccountRole.put(usrRole.PortalAccountId,usrRole.Id);//Map of Account ID and User Role Id
        }
        
        mapList ml = new mapList();
        
        ml.mapUserRoleandGroup = getMapUserRoleandGroup(mapPartnerRole);
        
        ml.mapAccountRole =  mapAccountRole;
            
        return ml;
    }
    
    //Generic function to get the map of group related id and group id 
    public static Map<Id, Id> getMapUserRoleandGroup(Map<Id, UserRole> mapPartnerRole){
        
        Map<Id,Id> mapUserRoleandGroup = new Map<Id,Id>();
        
        List<Group> lstGroup = [Select RelatedId, Id, Type FROM Group where RelatedId IN : mapPartnerRole.keyset()];
        
        for(Group grp : lstGroup)
        {   
            if(grp.Type == 'RoleAndSubordinates')
            {
              system.debug('grp.RelatedId'+grp.RelatedId);
              mapUserRoleandGroup.put(grp.RelatedId,grp.Id);
            }
        }
        
        return mapUserRoleandGroup;
    }
    //-------------------------------------------------------------------------// 
    // Method to get the query with fields of an object when the object name is passed
    //------------------------------------------------------------------------// 
    public static String getAllObjectFields (String strObjectAPIName)
    { 
        //strObjectAPIName='Account';
        String strQuery='';
        list<string> lstSelectedFields = new list<string>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe().Fields.getMap();
        if(fieldsMap != null)
        {
            for (Schema.SObjectField currentFieldMap : fieldsMap.values())
            { 
                Schema.DescribeFieldResult fieldDescription = currentFieldMap.getDescribe(); 
                lstSelectedFields.add(fieldDescription.getName());
            }
        }
        if(!lstSelectedFields.isEmpty())
        { 
            for (string strField:lstSelectedFields)
            {
                strQuery += strField.trim() + ',';
            }
            if(strQuery.endsWith(','))
            {
                strQuery = strQuery.substring(0,strQuery.lastIndexOf(','));
            }
        }
        strQuery  = 'SELECT ' + strQuery + ' FROM ' + strObjectAPIName ;
        system.debug('In getAllObjectFields >>>>>>>>>>>>>>'+strQuery);
        return strQuery;
    }

    //Utility function to map country iso code and currency rate
    public static Map<String, Decimal> mapCountryCodeAndRate(){
        
        Map<String, Decimal> mapCodeAndRate = new Map<String, Decimal>();
        
        //find all active currency type
        for (CurrencyType cRates : [SELECT ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE]) {
            //Mapping country iso code and currency rate
            mapCodeAndRate.put(cRates.IsoCode, cRates.ConversionRate);
            
            System.debug('cRates.IsoCode and cRates.ConversionRate:'+cRates.ConversionRate +' '+cRates.IsoCode);
        }

        return mapCodeAndRate;
    }
    
}