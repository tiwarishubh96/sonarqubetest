// Added with Sharing option to class as recommended by Checkmarx Security Scanner
public with sharing class CommunityLiveAgentController{
    public String salesOffice {get;set;}
    public String userContact {get;set;}
    public String userName {get;set;}
    public String userFirstName {get;set;}
    public String userLanguage {get;set;}    
    
    public String orgId {get;set;}
    public String deploymentId {get;set;}
    public String atlantaId {get;set;}
    public String atlantafrenchcanadianId {get;set;}
    public String dublinId {get;set;}
    public String defaultId {get;set;}
    public String atlantaOffline {get;set;}
    public String atlantafrenchcanadianOffline {get;set;}
    public String dublinOffline {get;set;}
    public String defaultOffline {get;set;}
    public String atlantaOnline {get;set;}
    public String atlantafrenchcanadianOnline {get;set;}
    public String dublinOnline {get;set;}
    public String defaultOnline {get;set;}
    
    public CommunityLiveAgentController(){
        User u = [SELECT Id, Name, FirstName, Contact.Account_Sales_Office__c, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        salesOffice = u.Contact.Account_Sales_Office__c;
        userContact = u.ContactId;
        userName = u.Name;
        userFirstName = u.FirstName;
        userLanguage = UserInfo.getLanguage();
        
        Live_Support_Configuration__c config = Live_Support_Configuration__c.getInstance('Live Agent Configuration');
        orgId = config.Organization_Id__c;
        deploymentId = config.Live_Agent_Deployment_Id__c;
        atlantaId = config.Atlanta_Chat_Button_Id__c;
        atlantafrenchcanadianId=config.Atlanta_French_Canadian_Chat_Button_Id__c;
        dublinId = config.Dublin_Chat_Button_Id__c;
        defaultId = config.Default_Chat_Button_Id__c;
        
        atlantaOffline  = 'liveagent_button_offline_' + config.Atlanta_Chat_Button_Id__c;
        atlantafrenchcanadianOffline = 'liveagent_button_offline_' + config.Atlanta_French_Canadian_Chat_Button_Id__c;
        dublinOffline = 'liveagent_button_offline_' + config.Dublin_Chat_Button_Id__c;
        defaultOffline = 'liveagent_button_offline_' + config.Default_Chat_Button_Id__c;
        
        atlantaOnline  = 'liveagent_button_online_' + config.Atlanta_Chat_Button_Id__c;
        atlantafrenchcanadianOnline = 'liveagent_button_online_' + config.Atlanta_French_Canadian_Chat_Button_Id__c;
        dublinOnline = 'liveagent_button_online_' + config.Dublin_Chat_Button_Id__c;
        defaultOnline = 'liveagent_button_online_' + config.Default_Chat_Button_Id__c;
    }
    
}