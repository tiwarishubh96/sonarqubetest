/**
 *@Author : Manjusha Guthikonda
  @Description: Once the customer submits the question to Expert from LLM data will be send to Salesforce and this class will take care of creating the case
  @last Modified On: 12/22/2020
**/

@RestResource(urlMapping='/limitlesscase/*')
global with sharing class LLMCreateCasepost {
    public static string TestPayload;
    @Httppost
    global static contactcasewrapper postcontactwrapper(){
        contactcasewrapper ccw = new contactcasewrapper();
        string strReqBody;
        RestResponse res;
        if(system.test.isRunningTest()){
            strReqBody = TestPayload;  
        }
        else{
            RestRequest req = RestContext.request;
            res = Restcontext.response;
            res.addHeader('Content-Type', 'application/json');
            strReqBody = req.requestBody.toString();
        }
        EntitlementServiceRequest ReqObj = (EntitlementServiceRequest)JSON.deserialize(strReqBody,EntitlementServiceRequest.class);
        try{
            List<Contact> Contactlist = new list<Contact>();
            List<Contact> ContactLocallist= new list<Contact>();
            system.debug('tenantprompt5'+ReqObj.tenantProp5);
            If(ReqObj.tenantProp5!= null && ReqObj.tenantProp5!= 'undefined'){
                Contactlist = [select id, Local_CRM_Account_ID__c,Email,Local_CRM_Name__c, Accountid from Contact where Local_CRM_Account_ID__c=: ReqObj.tenantProp5 AND Email=:ReqObj.customerEmail AND Local_CRM_Name__c = 'INT - InTouch' AND Inactive__c = false order by createddate desc];
                system.debug('Contactlist'+Contactlist.Size());
                if(Contactlist != null && !Contactlist.isEmpty() && Contactlist.Size() == 1 ){
                    ccw.tenantMsgId = createcase(Contactlist[0].id,ReqObj.customerEmail,ReqObj.tenantProp4,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp8,ReqObj.tenantProp9).id;
                }
                else{
                    ContactLocallist = [select id, Local_CRM_Account_ID__c,Email, Accountid from Contact where Local_CRM_Account_ID__c=: ReqObj.tenantProp5 AND Local_CRM_Name__c = 'INT - InTouch' AND Inactive__c = false];
                    if(ContactLocallist != null && !ContactLocallist.isEmpty() && ContactLocallist.Size() == 1 ){
                        ccw.tenantMsgId = createcase(ContactLocallist[0].id,ReqObj.customerEmail,ReqObj.tenantProp4,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp8,ReqObj.tenantProp9).id;
                    }
                    else {
                        Contactlist = [select id, Local_CRM_Account_ID__c,Email,Local_CRM_Name__c, Accountid from Contact where Email=:ReqObj.customerEmail AND Local_CRM_Name__c = 'INT - InTouch' AND Inactive__c = false order by createddate desc];
                        if(Contactlist != null && !Contactlist.isEmpty() && Contactlist.Size() == 1 ){
                            ccw.tenantMsgId = createcase(Contactlist[0].id,ReqObj.customerEmail,ReqObj.tenantProp4,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp8,ReqObj.tenantProp9).id;
                        }                   
                    
                        else{
                            
                            ccw.tenantMsgId = createOrphanedcase(ReqObj.customerEmail,ReqObj.tenantProp4,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp5,ReqObj.tenantProp8,ReqObj.tenantProp9).id;
                        }
                    }
                }
               
            }
             
            else{
                List<string> LLMProducts = Label.LLM_Products.split(','); 
             	Set<string>  setLLMProducts =  new Set<String>(LLMProducts);
                Set<Id> accountids = new Set<Id>();
                system.debug('LLMNewProducts'+ReqObj.tenantProp4);
                system.debug('LLMEmail'+ ReqObj.customerEmail);
              	if(setLLMProducts.contains(ReqObj.tenantProp4)){
               		Contactlist = [select id, Local_CRM_Account_ID__c,Email,Accountid from Contact where Email=:ReqObj.customerEmail AND Inactive__c = false]; 
                    system.debug('ContactlistSize'+ Contactlist.Size());
                    
                    if(Contactlist != null && !Contactlist.isEmpty() && Contactlist.Size() == 1 ){
                           ccw.tenantMsgId = createcase(Contactlist[0].id,ReqObj.customerEmail,ReqObj.tenantProp4,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp8,ReqObj.tenantProp9).id;
                            system.debug('CreateCaseInside');   
                    } 
                    if(Contactlist != null && !Contactlist.isEmpty() && Contactlist.Size() >= 2){
                        for(Contact c:Contactlist){
                           accountids.add(c.Accountid); 
                        }
                        system.debug('AccountSize'+accountids.size());
                        system.debug('AccountSet'+accountids);
                        if(accountids.size()==1){
                            ccw.tenantMsgId = createSBCAOrphanedcase(ReqObj.customerEmail,Contactlist[0].Accountid,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp4,ReqObj.tenantProp8,ReqObj.tenantProp9).id;
                        }
                        else{
                          ccw.tenantMsgId = createSBCANoAccOrphanedcase(ReqObj.customerEmail,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp4,ReqObj.tenantProp8,ReqObj.tenantProp9).id;  
                        	system.debug('ContactInsideelse');
                        }
                        
                    }
                    else if(Contactlist.Size() == 0){ 
                       ccw.tenantMsgId = createSBCANoAccOrphanedcase(ReqObj.customerEmail,ReqObj.body,ReqObj.messageId,ReqObj.tenantProp6,ReqObj.tenantProp7,ReqObj.tenantProp4,ReqObj.tenantProp8,ReqObj.tenantProp9).id; 
                    }
                }   
            }
            
        }
        catch(Exception e){
            System.debug('Caused Exception with res ' + e);  
        }
        if(ccw.tenantMsgId != null){
        ccw.status = 'success';
        ccw.statuscode = 201;
        }
        if(ccw.tenantMsgId == null ){
        ccw.status = 'Product is not Mapped correctly/Local CRM ID not present';
        ccw.statuscode = 500;
        }        
            
        return ccw;
        
    }
    global static Case createcase(id Cid,string customerEmail, string tenantProp4, string body, string messageId,string tenantProp6,string tenantProp7,string tenantProp8,string tenantProp9){
         Case c = new Case();
        c.contactId= Cid;
        if(body != null && body.length()>255){
            c.Subject = body.substring(0,253);
        }
        else{
            c.Subject = body;
        }
        c.Description = body + '\n' + 'Solution URL:'  + ' ' + tenantProp8 + '\n' + 'Solution Name:' + ' '+ tenantProp9 ;
        c.Status = 'New';
        c.Type = 'Problem';
        c.Product__c = tenantProp4;
        c.Origin= 'Crowdsourcing';
        c.priority = 'Medium';
        c.recordtypeId = Label.GlobalCaseRecordType;
        c.LLM_Message_ID__c = messageId;
        c.case_Category__c = tenantProp6;
        c.Case__c = tenantProp7; 
        try{
         insert c;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Case: ' + ex); 
        }
        return c;
    }
    global static Case createOrphanedcase(string customerEmail, string tenantProp4, string body,string messageId,string tenantProp6,string tenantProp7,String tenantProp5,string tenantProp8,string tenantProp9){
        List<Account> AccountList = new list<Account>();
        system.debug('tenantProp5value'+ tenantProp5);
        if(tenantProp5 != null){
        AccountList = [select id, Local_CRM_AccountID__c,Local_CRM_Name__c from Account where Local_CRM_AccountID__c=: tenantProp5 AND Local_CRM_Name__c = 'INT - InTouch'];
        system.debug('Accountlistvalue'+ Accountlist);
        system.debug('Accountlistvalue'+AccountList.Size());       
        }
        
        Case c = new Case();
        if(body != null && body.length()>255){
            c.Subject = body.substring(0,254);
        }
        else{
            c.Subject = body;
        }
        c.Description = body + '\n' + 'Solution URL:' + ' ' + tenantProp8 + '\n' + 'Solution Name:' + ' ' + tenantProp9 ;
        c.Status = 'New';
        c.Product__c = tenantProp4;
        c.Type = 'Problem';
        c.Origin= 'Crowdsourcing';
        c.priority = 'Medium';
        c.recordtypeId = Label.GlobalCaseRecordType;
        c.LLM_Message_ID__c= messageId;
        c.case_Category__c = tenantProp6;
        c.Case__c = tenantProp7;
        if(AccountList != null && !AccountList .isEmpty() && AccountList.Size() == 1){
        c.AccountId = AccountList[0].id;
        } 
        try{
         insert c;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Case: ' + ex); 
        }
        
        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'Customer Email:' + ' ' + customerEmail  + '\n' + 'Local CRM Account ID:' + ' ' + tenantProp5 ;
        cc.Ispublished = false;
        try{
         insert cc;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Casecomment: ' + ex); 
        }
        return c;
        
    }
    global static Case createSBCAOrphanedcase(string customerEmail, Id accountid, string body,string messageId,string tenantProp6,string tenantProp7,String tenantProp4,string tenantProp8,string tenantProp9){
        
        
        Case c = new Case();
        if(body != null && body.length()>255){
            c.Subject = body.substring(0,254);
        }
        else{
            c.Subject = body;
        }
        c.Description = body + '\n' + 'Solution URL:' + ' ' + tenantProp8 + '\n' + 'Solution Name:' + ' ' + tenantProp9 ;
        c.Status = 'New';
        c.Product__c = tenantProp4;
        c.Type = 'Problem';
        c.Origin= 'Crowdsourcing';
        c.priority = 'Medium';
        c.recordtypeId = Label.GlobalCaseRecordType;
        c.LLM_Message_ID__c= messageId;
        c.case_Category__c = tenantProp6;
        c.Case__c = tenantProp7;        
        c.AccountId = accountid;
 
        try{
         insert c;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Case: ' + ex); 
        }
        
        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'Customer Email:' + ' ' + customerEmail;
        cc.Ispublished = false;
        try{
         insert cc;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Casecomment: ' + ex); 
        }
        return c;
        
    }
    global static Case createSBCANoAccOrphanedcase(string customerEmail,string body,string messageId,string tenantProp6,string tenantProp7,String tenantProp4,string tenantProp8,string tenantProp9){
        
        
        Case c = new Case();
        if(body != null && body.length()>255){
            c.Subject = body.substring(0,254);
        }
        else{
            c.Subject = body;
        }
        c.Description = body + '\n' + 'Solution URL:' + ' ' + tenantProp8 + '\n' + 'Solution Name:' + ' ' + tenantProp9 ;
        c.Status = 'New';
        c.Product__c = tenantProp4;
        c.Type = 'Problem';
        c.Origin= 'Crowdsourcing';
        c.priority = 'Medium';
        c.recordtypeId = Label.GlobalCaseRecordType;
        c.LLM_Message_ID__c= messageId;
        c.case_Category__c = tenantProp6;
        c.Case__c = tenantProp7;        
        try{
         insert c;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Case: ' + ex); 
        }
        
        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'Customer Email:' + ' ' + customerEmail;
        cc.Ispublished = false;
        try{
         insert cc;
        }
        
        catch(Exception ex){
            System.debug('Error Creating Casecomment: ' + ex); 
        }
        return c;
        
    }
    //wrapper for request body
    global class EntitlementServiceRequest{        
        string customerFirstName;
        string customerEmail;
        string tenantProp5;
        string tenantProp4;
        string body;
        string tenantProp6;
        string tenantProp7;
        string tenantProp8;
        string tenantProp9;
        string tenantMsgId;
        string msgState;
        string reasonCode;
        string groupName;
        string tenantMsgType; 
        string messageId;
               
    }
    
    global class contactcasewrapper{
        string status;
        integer statuscode;
        string tenantMsgId;
    }
   // "/services/apexrest/limitlesscase/"
}