/*****************************************************************************************
    Author      : Rani Thumma
    Company     : Docmation
    Date        : 5/6/2017
    Description : Class is developed to Sync SPP Partner Accounts to Local CRMs
*****************************************************************************************/
global class SPPAccountSyncBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful 
{
     public String query;
    
    public SPPAccountSyncBatch()
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
                                                       FROM Publish_Mulesoft_Field__mdt WHERE ObjectName__c = 'Account'];
        PublishMuleMessageWrapper.PublishMuleRequest requestWrapper ;
        PublishMuleMesssagesHelper publishMuleMessage = new PublishMuleMesssagesHelper();
        try{
            System.debug('Scope.size() = '+scope.size());
            for(SObject rec : scope)
            {
                requestWrapper = new PublishMuleMessageWrapper.PublishMuleRequest();
                requestWrapper.record = rec;
                requestWrapper.mdtFields = new List<Publish_Mulesoft_Field__mdt>(); 
                requestWrapper.mdtFields.addAll(mdtFields); 
                requestWrapper.recordtype = 'Account';
                requestWrapper.messageType = 'Record'; 
                requestWrapper.eventSource = 'Global - SFDC';
                requestWrapper.eventDate = System.now().format('yyyy-MM-dd\'T\'HH:mm:ss:sss\'Z\'');
                requestWrapper.sfObjectName = 'Account';
                Account a = (Account)rec;
                //LocalCRM__c crm;
                if(a != null && a.Local_CRM_Country__c != null){
                    String countryCode = a.Local_CRM_Country__c.substringBefore('-').trim();
                    LocalCRM__c crm = LocalCRM__c.getValues(countryCode);
                    if(crm != null && crm.SQSName__c != null ){
                        if(a.Local_CRM_Country__c == 'GB - United Kingdom' || 
                           a.Local_CRM_Country__c == 'US - United States' ||
                          	a.Local_CRM_Country__c == 'CA - Cananda'){
                            requestWrapper.region = crm.SQSName__c;
                            } else {
                               requestWrapper.region =  a.Local_CRM_Country__c.substringAfter('-').trim();
                            }
                        requestWrapperList.add(requestWrapper);
                        //System.debug('requestWrapperList >>>> in batch '+requestWrapperList); 
                    }
                }
            }
            if(requestWrapperList.size() > 0){
                System.debug('requestWrapperList.size() == '+requestWrapperList.size());
                publishResponseList = publishMuleMessage.generateMessageJSON(requestWrapperList);
                updateSyncDateTime(publishResponseList);
            } 
        } Catch(Exception e){
            ExceptionHandler.CatchException('SPPAccountSyncBatch', 'Execute', e);
        }
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public void updateSyncDateTime(List<PublishMuleMessageWrapper.publishMuleResponse> reponseList){
        List<Account> accounts = new List<Account>();
        try{
            if(reponseList != null && reponseList.size()>0)
            {
                for(PublishMuleMessageWrapper.publishMuleResponse res :reponseList){
                    //update Account record with current datetime in SyncDateTime field
                    //this will indicate that the Partner Account is successfully published to SQS queue
                    Account a = new Account(Id=res.recordId);
                    a.SyncDateTime__c = System.now();
                    accounts.add(a);
                }
                system.debug('Accounts.size() before update>>>'+accounts.size());
                Database.update(accounts, false);
            }
        } Catch(Exception e){
            ExceptionHandler.CatchException('SPPAccountSyncBatch', 'updateSyncDateTime', e);
        }
    }
    
    public String buildQuery()
    {
        List<Partner_Field__mdt> partnerfieldMapping = new List<Partner_Field__mdt>();
        Map<String, String> fieldMapping = new Map<String, String>();
        //retreive all the account fields from the custom metadate type
        List<Publish_Mulesoft_Field__mdt> accFields = [SELECT SF_Field_Name__c, Message_Field_Name__c FROM 
                                                       Publish_Mulesoft_Field__mdt WHERE ObjectName__c = 'Account'];
        if(accFields != null && accFields.size() > 0)
        {
            for(Publish_Mulesoft_Field__mdt accField :accFields)
            {
                fieldMapping.put(accField.SF_Field_Name__c, accField.Message_Field_Name__c);
            }
        }
        String query = 'SELECT ';
        for(String field : fieldMapping.keySet())
        {
            query += field+',';
        }
        if(query.endsWith(','))
           query= query.substring(0,query.length()-1);
        query += ' FROM Account WHERE (((';
        //retreive Partner type fields and Partner Tier fields from the custom metadata type
        partnerfieldMapping = [SELECT MasterLabel, QualifiedApiName,DeveloperName, Partners__c ,Partner_Tier__c,
                               Partner_TnC_Accepted__c FROM Partner_Field__mdt];
        for(Partner_Field__mdt obj : partnerfieldMapping) 
        {
          query += ' (' +obj.Partners__c+' = true AND '+obj.Partner_Tier__c+' != null AND ' +obj.Partner_TnC_Accepted__c+' = true) OR';
        }
        if(query.endsWith('R'))
           query= query.substring(0,query.length()-2);
        query += ')AND (SyncDateTime__c = null) AND (Partner_Agreement__c = \'' + String.escapeSingleQuotes('On-line')+'\' OR Partner_Agreement__c = \'' + String.escapeSingleQuotes('Old V1')+'\')) OR (Partner_Agreement__c = \'' + String.escapeSingleQuotes('Local')+'\' AND SyncDateTime__c = null))AND RecordType.Name = \'' + String.escapeSingleQuotes('Partner Account')+'\' AND LastModifiedBy.Name != \'' + String.escapeSingleQuotes('Informatica UserAccount')+'\'';
        System.debug('Query>> '+query); 
        return query;
    }
}