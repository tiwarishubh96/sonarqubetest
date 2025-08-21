/*
 * AccountAssignmentTriggerTest
 * Tests the AccountAssignmentTrigger and its helper class
 */
@IsTest
public class AccountAssignmentTriggerTest {
    @TestSetup
    static void dataSetup() {
      Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(Alias='accounta',
                           Email='a@aaa.com',
                           EmailEncodingKey='ISO-8859-1',
                           FirstName='aaa',
                           LastName='aaa',
                           LanguageLocaleKey='en_US',
                           LocaleSidKey='en_GB',
                           ProfileId=p1.Id,
                           TimeZoneSidKey='Europe/London',
                           CommunityNickname = 'aaa',
                           IsActive=true,
                           Username='a@aaa.com.sage');
        insert u1;
                
        // Create Account
        List<Account> aList = new List<Account>();    
        for (Integer i=0; i<10; i++) {
            Account a = new Account();            
            a.Name = 'EAD1539Account' + i;
            a.Type = 'Accountant Customer';
            a.BillingCity = 'Atlanta';
            a.BillingStreet = '123' + i + ' Technology dr';
            a.BillingState = '';
            a.BillingCountry = 'Iceland';
            a.BillingPostalCode = '22222-2222';
            a.CurrencyIsoCode = 'USD';
            a.Industry = 'Retail';
            a.Partner_Type__c = 'Accountant';
            a.OwnerId = u1.id;
            a.Phone = '9999999999';
            a.Sales_Office__c = 'Atlanta CBC';      
            aList.add(a);           
        } 
        System.Debug('Create Accounts=' + aList);
        insert aList;
    }
    
    @IsTest
    static void testAccountAssignment() {       
        System.debug('AccountAssignmentTriggerTest: testAccountAssignment START');
        // Retrieve test data
        List<Account> accIds = [SELECT Id FROM Account];     
        // Switch on validation rules which have the bypass setting to catch Account errors
        AccountControlSwitch__c setting = new AccountControlSwitch__c ();
		setting.Name = 'VR';
		setting.RunValidationRules__c = true;
		insert setting;
        
        Test.startTest();
        System.Debug('AccountAssignmentTriggerTest accIds=' + accIds);         
        // create Account Assignments
        List<Account_Assignment__c> aaList = new List<Account_Assignment__c>();        
        for (Integer i=0; i<10; i++) {
            Account_Assignment__c aa = new Account_Assignment__c();
			// update new value
			aa.Account__c = accIds[i].Id;
            aa.Account_Name__c = 'EAD1539AcctUpdated' + i;
            aa.Account_Billing_City__c = 'Atlanta';
            aa.Account_Billing_Street__c = '222' + i + ' Technology dr';
            aa.Insight_1__c = 'Insight_1__c';
            aa.Insight_2__c = 'Insight_2__c';
            aa.Insight_3__c = 'Insight_3__c';
            aa.Insight_4__c = 'Insight_4__c';
            aa.Insight_5__c = 'Insight_5__c';
            aa.Insight_6__c = 'Insight_6__c';
            aa.Account_Billing_Country__c = 'Haiti';
            aa.Account_Billing_Postal__c = '33333';
            aa.Account_Industry__c = 'Education';
            aa.Account_Owner__c = '00524000000GluHAAS';
            aa.Account_Phone__c = '9999999999';
            aa.Account_Sales_Office__c = 'Atlanta CBC';  

            // fail case, USA needs to have State
            if  (i == 9){
                aa.Account_Billing_Country__c = 'United States';
                aa.Account_Billing_State__c = '';
            } 
            aaList.add(aa);
        }
                           
        // Duplicate case same Account id
        Account_Assignment__c aaDuplicated = new Account_Assignment__c();   
	    aaDuplicated.Account__c = accIds[0].Id;  // same Account ID
        aaDuplicated.Account_Name__c = 'EAD1539AcctDuplicated';
        aaList.add(aaDuplicated);
        
        // Inserting the Account_Assignment__c objects should fire the associated trigger       
        insert aaList;  
                
        // Ensure trigger completed (and hopefully the batch)
		Long startingTime = System.now().getTime(); 
	    Integer delayInMilliseconds = 1000; // One-second delay
		while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
 		}
                
        Test.stopTest();        
        // Check only the good 
        System.debug('AccountAssignmentTriggerTest: GoodAccounts');
        Integer goodAccounts = [SELECT COUNT() FROM Account where Name like 'EAD1539AcctUpdated%' ];
        System.assertEquals(9, goodAccounts);
        // Check all of the Account Assignments changed status appropriately
        // 
        System.debug('AccountAssignmentTriggerTest: Success');
        List<Account_Assignment__c> aaAfter  = new List<Account_Assignment__c>();   
        aaAfter = [SELECT Id, Status__c FROM Account_Assignment__c];
        System.Debug('---- Results=' + aaAfter);
        Integer retOAs = [SELECT COUNT()  
                          FROM Account_Assignment__c
                          WHERE Status__c = 'Success'];              
        System.assertEquals(9, retOAs);
        System.debug('AccountAssignmentTriggerTest: Fail');
        Integer retOAs2 = [SELECT COUNT()  
                          FROM Account_Assignment__c
                          WHERE Status__c = 'Fail'];
        System.assertEquals(1, retOAs2);
        
        System.debug('AccountAssignmentTriggerTest: Duplicate');
        Integer retOAs3 = [SELECT COUNT()  
                           FROM Account_Assignment__c
                           WHERE Status__c = 'Duplicate'];
        System.assertEquals(1, retOAs3);
        System.debug('AccountAssignmentTriggerTest: testAccountAssignment FINISH');

    }
}