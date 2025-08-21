/**********************************************************************
 Name:  SPPCommissionTriggerTest

======================================================
======================================================
Purpose: Test class to test SPPSuccessPlanTriggerHandler
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
1.0        	Lu               	11/2/2017			Initial Development
***********************************************************************/

@isTest
public class SPPSuccessPlanTriggerHandlerTest {
    
    public static testmethod void createBusinessPlanSharingTest(){
        Integer max = 10;
        SPPTestData.CreateAccountAndContactForPartnerType();
        Account acc = [select id from account limit 1];
        acc.isPartner = true;
        
        Account parentAcc = CreateParentAccountAndContactForPartnerType();
        parentAcc.IsPartner = true;
        update parentAcc;
        acc.ParentId = parentAcc.Id;
        update acc;
        List<Success_Plan__c> spList = SPPTestData.createSuccessBusinessPlanList(max, acc.id);
        
        User thisUser = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()];
        
        System.runAs(thisUser) {
            
            UserRole r = new UserRole(PortalAccountId = acc.Id, PortalType='Partner');
            
            insert r;
            
            SPPSuccessPlanTriggerHandler.createBusinessPlanSharing(spList);
            
        }
        
        System.runAs(thisUser) {
            
            UserRole r = new UserRole(PortalAccountId = parentAcc.Id, PortalType='Partner');
            
            insert r;
            
            SPPSuccessPlanTriggerHandler.createBusinessPlanSharing(spList);
        }
        
        
    }
    
    public static Account CreateParentAccountAndContactForPartnerType()
    {
        Account acc =new Account();
        acc.Name = 'TestAcc1';
        acc.Partner_Accountant__c = true;
        acc.Accountant_Partner_Tier__c = 'Authorized';
        acc.Locale_Billing_CC__c = 'US';
        acc.Company_Registration_Number__c = '12122';
        
        acc.Partner_Account_ID__c = '1212';
        acc.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        acc.Sales_Office__c='Atlanta CBC';
        acc.BillingCity='Austin';
        acc.BillingPostalCode='78666';
        acc.BillingCountry='United States';
        acc.BillingState='Texas';
        acc.BillingStreet='test';
        acc.Phone='1234567890';
        
        insert acc;
        system.debug('acc: '+acc);
        Contact NewContact = new Contact (
            FirstName = 'Test ',
            LastName = 'Test Last1',
            Language__c = 'English',
            //line changed - waveoc
            AccountId = acc.Id,
            Email = 'xyzmail1@mail.com',
            Legal_Contact__c = true
        );
        system.debug('NewContact before: '+NewContact);
        insert NewContact;
        system.debug('NewContact: '+NewContact);
        return acc;
    }

}