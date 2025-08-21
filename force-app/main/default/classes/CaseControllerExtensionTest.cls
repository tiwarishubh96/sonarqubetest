/**
* @author Tehnologies
* @date 11/06/2020
* @Devloped By Ravi Yalamati
*
* @description SendArticleTest to test the send Article related code
*/
@isTest//(SeeAllData=true)
public class CaseControllerExtensionTest {
    
    
    /*******************************************************************************************************
* @description To setup the required test data for Send Article
* @return 
* @example
*/
    
    @testSetup static void setup(){
        
        Id paRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
        // Create test contact
        Account acc =new Account();
        acc.Name = 'TestAcc0';
        acc.Partner_Accountant__c = true;
        acc.Accountant_Partner_Tier__c = 'Authorized';
        acc.Locale_Billing_CC__c = 'US';
        acc.Company_Registration_Number__c = '12122';
        
        acc.Partner_Account_ID__c = '1212';
        acc.recordtypeid= paRecordTypeId;
        acc.Sales_Office__c='Atlanta CBC';
        acc.BillingCity='Austin';
        acc.BillingPostalCode='78666';
        acc.BillingCountry='United States';
        acc.BillingState='Texas';
        acc.BillingStreet='test';
        acc.Phone='1234567890';
        
        insert acc;
        system.debug('acc: '+acc);
        
        List<Contact> listOfTestContacts = new List<Contact>();
        List<Case> listOfTestCases = new List<Case>();
        Contact testContact = new Contact (
            FirstName = 'Test ',
            LastName = 'Test Last',
            Language__c = 'English',
            //line changed - waveoc
            AccountId = acc.Id,
            Email = 'test1@mail.com'
        );
        listOfTestContacts.add(testContact);
        
        Contact testContactFrenchLanguage = new Contact (
            LastName = 'Test Last',
            Language__c = 'French',
            //line changed - waveoc
            AccountId = acc.Id,
            Email = 'test2@mail.com'
        );
        system.debug('testContact before: '+testContactFrenchLanguage);
        listOfTestContacts.add(testContactFrenchLanguage);
        
         if(listOfTestContacts.size() > 0) insert listOfTestContacts;
        
        for(Contact contactObj : listOfTestContacts){
            Case testCase = new Case(Type = 'Problem', ContactId = contactObj.Id, Case_Category__c = 'Accounting/Payroll - Bank', Case__c = 'Accounting - Transfer', Status = 'Service - Work In Progress', Priority = 'Medium', Origin = 'Phone', Subject = 'Test Case');
            listOfTestCases.add(testCase);
        }    
        
        if(listOfTestCases.size() > 0) insert listOfTestCases;
    }
    
    /*******************************************************************************************************
* @description test method to call functions realted to send article
* @return 
* @example
*/
    static testMethod void testSendArticle() {
        
        
        // reset governor limits for the actual test of the trigger
        Test.startTest();
        
        List<Case> caseList = [Select Id, Status, ContactId, Language__c from Case];
        
        //if case found
        for(Case caseObj : caseList){
            
            PageReference pageRef = Page.SendEmail;       
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            CaseControllerExtension controller = new CaseControllerExtension(sc);
            
            System.debug('Language__c = '+ caseObj.Language__c);
            String emailTemplateName;
            
            if(caseObj.Language__c == 'English' || caseObj.Language__c == null){
                emailTemplateName = 'Global_KB_Article_Email_English';
            }else{
                emailTemplateName = 'Global_KB_Article_Email_french'; 
            }
            System.debug('emailTemplateName = '+emailTemplateName);
            List<EmailTemplate> emailTemplateList = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName =: emailTemplateName];
            
            // if email template found
            if(emailTemplateList.size() > 0){
                EmailTemplate emailTemplateObj = emailTemplateList[0];
                String htmlContent = emailTemplateObj.HtmlValue;
                System.debug('htmlContent = '+htmlContent);
                controller.init();
                controller.closePopup();
                controller.showPopup();
                controller.processSelected();
                CaseControllerExtension.sendEmailRemoteAction(caseObj.Id, 'test','test@test.com','test@test.com','test@test.com', htmlContent);
                
                //for multiple emails with ; seperate
                CaseControllerExtension.sendEmailRemoteAction(caseObj.Id, 'test','test@test.com;test2@test2.com','test@test.com;test2@test2.com','test@test.com;test2@test2.com', htmlContent);
                
                //for failure of sending email
                CaseControllerExtension.sendEmailRemoteAction(caseObj.Id, 'test',null,null,null, htmlContent);
                
                System.assert(htmlContent != null, 'Success...');   
            }else{
                System.assert(emailTemplateList.size() == 0, 'No Email Template Found...');   
            }
            
        }
        
        
        Test.stopTest();
    }// end of test method
}// end of test class