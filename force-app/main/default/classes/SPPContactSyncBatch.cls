/***************************************************************************************
    Author      : Rani Thumma
    Company     : Docmation
    Date        : 5/6/2017
    Description : This is class is developed to Sync SPP Partner Contacts to Local CRMs
****************************************************************************************/
global class SPPContactSyncBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful 
{
        public String query;
    
    public SPPContactSyncBatch()
    {
        query = buildQuery();
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    { 
        List<PublishMuleMessageWrapper.PublishMuleRequest> requestWrapperList = new List<PublishMuleMessageWrapper.PublishMuleRequest>();
        List<PublishMuleMessageWrapper.publishMuleResponse> publishResponseList = new List<PublishMuleMessageWrapper.publishMuleResponse>();
        List<Publish_Mulesoft_Field__mdt> mdtFields = [SELECT SF_Field_Name__c, Message_Field_Name__c, Lookup__c, ObjectName__c 
                                                       FROM Publish_Mulesoft_Field__mdt WHERE ObjectName__c = 'Contact'];
        PublishMuleMessageWrapper.PublishMuleRequest requestWrapper ;
        PublishMuleMesssagesHelper publishMuleMessage = new PublishMuleMesssagesHelper();
        try{
        	for(SObject rec : scope)
        	{
                System.debug('Scope.size() = '+scope.size());
                requestWrapper = new PublishMuleMessageWrapper.PublishMuleRequest();
                requestWrapper.record = rec;
                requestWrapper.mdtFields = new List<Publish_Mulesoft_Field__mdt>(); 
                requestWrapper.mdtFields.addAll(mdtFields); 
                requestWrapper.recordtype = 'Contact';
                requestWrapper.messageType = 'Record'; 
                requestWrapper.eventSource = 'Global - SFDC';
                requestWrapper.eventDate = System.now().format('yyyy-MM-dd\'T\'HH:mm:ss:sss\'Z\'');
                requestWrapper.sfObjectName = 'Contact';
                Contact c = (Contact)rec;
                //LocalCRM__c crm;
                if(c != null && c.Local_CRM_Country__c != null){
                    String countryCode = c.Local_CRM_Country__c.substringBefore('-').trim();
                    LocalCRM__c crm = LocalCRM__c.getValues(countryCode);
                    if(crm != null && crm.SQSName__c != null){
                        if(c.Local_CRM_Country__c == 'GB - United Kingdom' || 
                           c.Local_CRM_Country__c == 'US - United States' ||
                           c.Local_CRM_Country__c == 'CA - Cananda'){
                            requestWrapper.region = crm.SQSName__c;
                    	} else {
                        	requestWrapper.region =  c.Local_CRM_Country__c.substringAfter('-').trim();
                        }
                        requestWrapperList.add(requestWrapper);
                    }
                }
            }
            if(requestWrapperList.size() > 0){
                publishResponseList = publishMuleMessage.generateMessageJSON(requestWrapperList);
                updateSyncDateTime(publishResponseList);
            }     
        } catch(Exception e)
        {
           ExceptionHandler.CatchException('SPPContactSyncBatch', 'Execute', e); 
        }
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public void updateSyncDateTime(List<PublishMuleMessageWrapper.publishMuleResponse> reponseList)
    {
        try
        {
            List<Contact> contacts = new List<Contact>();
            if(reponseList != null && reponseList.size()>0)
            {
                for(PublishMuleMessageWrapper.publishMuleResponse res :reponseList){
                    //update Contact record with current datetime in SyncDateTime field
                    //this will indicate that the Partner Contact is successfully published to SQS queue
                    Contact c = new Contact(Id=res.recordId);
                    c.SyncDateTime__c = System.now();
                    contacts.add(c);
                }
                system.debug('contacts.size() before update>>>'+contacts.size());
                Database.update(contacts, false);
            }
        } catch(Exception e){
            ExceptionHandler.CatchException('SPPContactSyncBatch', 'Execute', e);
        }
    }
    
    public String buildQuery()
    {
        List<Partner_Field__mdt> partnerFieldMapping = new List<Partner_Field__mdt>();
        Map<String, String> fieldMapping = new Map<String, String>();
        String query = 'SELECT ';
        //List<SPP_Contact_Field__mdt> sfFields = [SELECT Message_Field_Name__c, SF_Field_Name__c FROM SPP_Contact_Field__mdt];
        List<Publish_Mulesoft_Field__mdt> sfFields = [SELECT SF_Field_Name__c, Message_Field_Name__c FROM 
                                                       Publish_Mulesoft_Field__mdt WHERE ObjectName__c = 'Contact'];
        if(sfFields!=null && sfFields.size()>0)
        {
            for(Publish_Mulesoft_Field__mdt sfField :sfFields)
            {
                query += sfField.SF_Field_Name__c + ',' ; 
            }
        }
        if(query.endsWith(','))
           query= query.substring(0,query.length()-1);
        //WHERE Clause
        //retreive Partner type fields and Partner Tier fields from the custom metadata type
        partnerFieldMapping = [SELECT MasterLabel, QualifiedApiName,DeveloperName, Partners__c ,Partner_Tier__c,
                               Partner_TnC_Accepted__c FROM Partner_Field__mdt];
        query += ' FROM Contact WHERE (((';
        for(Partner_Field__mdt obj : partnerFieldMapping) 
        {
          query += ' (Account.'+obj.Partners__c+' = true AND Account.'+obj.Partner_Tier__c+' != null AND Account.' +obj.Partner_TnC_Accepted__c+' = true) OR';
        }
        if(query.endsWith('R'))
           query= query.substring(0,query.length()-2);
        
        query += ')AND (SyncDateTime__c = null)AND (Account.Partner_Agreement__c = \'' + String.escapeSingleQuotes('On-line')+'\' OR Account.Partner_Agreement__c = \'' + String.escapeSingleQuotes('Old V1')+'\')) OR (Account.Partner_Agreement__c = \'' + String.escapeSingleQuotes('Local')+'\' AND SyncDateTime__c = null))AND Account.RecordType.Name = \'' + String.escapeSingleQuotes('Partner Account')+'\' AND LastModifiedBy.Name != \'' + String.escapeSingleQuotes('Informatica UserAccount')+'\'';   
        System.debug('Query>> '+query);
        return query;
    }
}