@isTest
public class OpportunityMesgExtTest {
    
    @testSetup static void createData(){
        Profile mrkp = [SELECT Id, Name FROM Profile WHERE Name = :Label.Profile_SageMarketingOperationsUser LIMIT 1];
        User mrkUser = new User(Alias = 'mrkst', Email='marketinguser@test.com',
                    EmailEncodingKey='UTF-8', LastName='MrkTesting', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = mrkp.Id,TimeZoneSidKey='America/Los_Angeles',
                    UserName='marketingusercontactrole@testoppmsg.com');
        insert mrkUser;
        Profile cbcp = [SELECT Id, Name FROM Profile WHERE Name = :Label.Profile_SageCBCUser LIMIT 1];
        User cbcUser = new User(Alias = 'cbctt', Email='cbcuser@test.com',
                    EmailEncodingKey='UTF-8', LastName='MrkTesting', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = cbcp.Id,TimeZoneSidKey='America/Los_Angeles',
                    UserName='cbcusercontactrole@testoppmsg.com');
        insert cbcUser;
        
        Account acc = new Account(Name='TestAcc',BillingStreet='Test City',BillingCity='Bucks',
                                  BillingCountry='United Kingdom',
                                  BillingState='Angus',Sales_Office__c='Dublin CBC',
                                  Phone='1234567890',Type='Analyst',BillingPostalCode='30092',
                                  VAT_Number__c='B78361482');
        
        insert acc;
        Contact con = new Contact(FirstName = 'VAT',LastName = 'Validation',AccountId = acc.Id,
                        Email = 'xyzmail123@mail.com');
        insert con;
        Opportunity o = new Opportunity(AccountId = acc.Id, Name = 'TestOpportunity',
                                        StageName = 'Qualify', CloseDate = Date.today());
        insert o;
        
        Opportunity oLock = new Opportunity(AccountId = acc.Id, Name = 'TestOpportunityLocked', Integration_Record_Status__c ='Pending - Send to Local (Self)',
                                        StageName = 'Qualify', CloseDate = Date.today());
        insert oLock;
        
        Opportunity oNotLock = new Opportunity(AccountId = acc.Id, Name = 'TestOpportunityNotLocked' ,
                                        StageName = 'Qualify', CloseDate = Date.today());
        insert oNotLock;
    }

    @isTest static void OpportunityLockedMesgTest(){
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND 
                  UserName = 'cbcusercontactrole@testoppmsg.com' LIMIT 1];
        String str;
        System.runAs(u){
            Opportunity o = [SELECT ID, Name, AccountId, CloseDate FROM Opportunity where Name = 'TestOpportunityLocked' ];      
            ApexPages.StandardController sc = new ApexPages.StandardController(o);
            Test.startTest();
            opportunityMesgExt oppExt = new opportunityMesgExt(sc);
            PageReference pageRef = Page.opportunityMessages ;
            pageRef.getParameters().put('Id', o.id);
            Test.setCurrentPage(pageRef);
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            Test.stopTest();
        }
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            str = msg.getDetail();
            if (str.contains(Label.Opportunity_Local_CRM_Sync))
            { System.assertEquals(msg.getDetail(), Label.Opportunity_Local_CRM_Sync); }
        }
    } 
    
    @isTest static void OpportunityNotLockedMesgTest(){
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND 
                  UserName = 'cbcusercontactrole@testoppmsg.com' LIMIT 1];
        
        Boolean bNotLocked = false;
        
        String str;
        System.runAs(u){
            Opportunity o = [SELECT ID, Name, AccountId, CloseDate FROM Opportunity where Name = 'TestOpportunityNotLocked' ];      
            ApexPages.StandardController sc = new ApexPages.StandardController(o);
            Test.startTest();
            opportunityMesgExt oppExt = new opportunityMesgExt(sc);
            PageReference pageRef = Page.opportunityMessages ;
            pageRef.getParameters().put('Id', o.id);
            Test.setCurrentPage(pageRef);
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            Test.stopTest();
        }
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            str = msg.getDetail();
            if (str.contains(Label.Opportunity_Local_CRM_Sync))
            { bNotLocked = true; }
        }
        
        if (bNotLocked == true)
        {
            System.assertEquals(str, Label.Opportunity_Local_CRM_Sync);
        }    
            
    } 
    @isTest static void OpportunityWarnMesgTest(){
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND 
                  UserName = 'marketingusercontactrole@testoppmsg.com' LIMIT 1];
        System.runAs(u){
            Opportunity o = [SELECT ID, Name, AccountId, CloseDate FROM Opportunity LIMIT 1];      
            ApexPages.StandardController sc = new ApexPages.StandardController(o);
            Test.startTest();
            opportunityMesgExt oppExt = new opportunityMesgExt(sc);
            PageReference pageRef = Page.opportunityMessages ;
            pageRef.getParameters().put('Id', o.id);
            Test.setCurrentPage(pageRef);
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            Test.stopTest();
        }
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals(msg.getDetail(), Label.Opportunity_Contact_Role); 
        }
    }
    @isTest static void OpportunityMesgTest(){
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND 
                  UserName = 'cbcusercontactrole@testoppmsg.com' LIMIT 1];
        System.runAs(u){
            Opportunity o = [SELECT ID, Name, AccountId, CloseDate FROM Opportunity LIMIT 1];
            Contact con = [SELECT Id, Name, AccountID FROM Contact WHERE AccountID = :o.AccountId LIMIT 1];
            List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
            for(Integer i=0; i<=20; i++){
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.ContactId = con.Id;
                ocr.OpportunityId = o.Id;
                ocrs.add(ocr);
            }        
            OpportunityContactRole ocrPrimary = new OpportunityContactRole();
            ocrPrimary.ContactId = con.Id;
            ocrPrimary.OpportunityId = o.Id;
            ocrPrimary.IsPrimary = true;
            ocrs.add(ocrPrimary);
            insert ocrs;
            Test.startTest();
            ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
            opportunityMesgExt oppExt2 = new opportunityMesgExt(sc2);
            PageReference pageRef2 = Page.opportunityMessages ;
            pageRef2.getParameters().put('Id', o.id);
            Test.setCurrentPage(pageRef2);
            Test.stopTest();
        }
        System.assertEquals(false, Apexpages.hasMessages());
    }
}