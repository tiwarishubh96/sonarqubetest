@isTest
public class PartnerCommRegistrationEmailTest {
    
 @testSetup static void testdata() {
    Id FolderId = [select id from folder where name = 'sage'].id;
  EmailTemplate e = new EmailTemplate (developerName = 'test', Body='Test',IsActive=true,FolderId = FolderId, TemplateType= 'Text', Name = 'Partner Community Registration email'); 
    insert e;  
     }
 @isTest static void sendPartnerRegistration() {
        Locale__c 	  			Loc = DataFactoryForTesting.createLocale();
        Account 	  			Acc = DataFactoryForTesting.createAccountWithLoc(Loc.Id);
        Contact 	  			Con = DataFactoryForTesting.createContact(Acc.Id);
        CommunityX__c 			commnty = DataFactoryForTesting.createComm();
        Community_Membership__c cm = DataFactoryForTesting.createCommMem(Con.Id, commnty.Id);
        
     
        system.debug(cm.Community__c);
        system.debug(cm.Contact__c);
      
        List<Id> dummyConId = new List<Id>();
        dummyConId.add(Con.Id);
          Partner_Community_Locale_Settings__c tu1=new Partner_Community_Locale_Settings__c(Locale__c='en_US',Registration_Email_Template_Name__c='Partner Community Registration email',Name='Partner Community Registration email');
        insert tu1;
     Partner_Community_Locale_Mapping__c tu2=new Partner_Community_Locale_Mapping__c(Account_Locale__c='en_US',Contact_User_Locale__c ='en_US',Country_Name__c ='United States of America (USA)',ISO_Country_Code__c ='US',Name='US');
   insert tu2;
   test.startTest();
PartnerCommRegistrationEmail.sendPartnerCommRegistrationEmail(dummyConId);
         test.stopTest();
    }

}