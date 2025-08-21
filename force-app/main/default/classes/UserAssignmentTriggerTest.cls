/*
 * UserAssignmentTriggerTest
 * Tests the UserAssignmentTrigger and its helper class
 */
@IsTest
public class UserAssignmentTriggerTest {
    @TestSetup
    static void dataSetup() {
      Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(Alias='usera',
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
        User u2 = new User(Alias='userb',
                           Email='b@bbb.com',
                           EmailEncodingKey='ISO-8859-1',
                           FirstName='bbb',
                           LastName='bbb',
                           LanguageLocaleKey='en_US',
                           LocaleSidKey='en_GB',
                           ProfileId=p1.Id,
                           TimeZoneSidKey='Europe/London',
                           CommunityNickname = 'bbb',
                           IsActive=true,
                           Username='b@bbb.com.sage');
        insert u2;
                
        // Create User
        List<User> uList = new List<User>();
        for (Integer i=0; i<10; i++) {
            User u = new User();            
            u.FirstName = 'TestFirstName' + i;            
            u.LastName = 'TestLastName' + i;
            u.UserRoleId = '00E24000000Q0uOEAS';
            u.ManagerId = '0051o00000Cd1vAAAR';
            u.EmployeeNumber = '999000' + i;
            u.isActive = true;
            u.New_manager__c = '0051o00000Cd1vAAAR'; // user this field to update the manager.
            // required field
            u.Username = 'TestUN' + i + '@testua.com';
            u.Alias = 'xxxxxxxx';
            u.TimeZoneSidKey ='Europe/London';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.ProfileId = '00e24000000S23rAAC';
            u.LanguageLocaleKey = 'en_US'; 
            u.Email = 'TestEmail' + i + '@testua.com';            
            uList.add(u);
        } 
        insert uList;
    }
    
    @IsTest
    static void testUserAssignment() {       
        System.debug('UserAssignmentTriggerTest: testUserAssignment START');
        // Retrieve test data
        List<User> uIds = [SELECT Id FROM User 
                            WHERE FirstName like 'TestFirstName%' 
                                   and isActive = true 
                                   and Email like 'TestEmail%' 
                                   and UserRoleId = '00E24000000Q0uOEAS'
                                   and ManagerId = '0051o00000Cd1vAAAR'
                                   and TimeZoneSidKey ='Europe/London' ];     
        // Switch on validation rules which have the bypass setting to catch User errors
        UserControlSwitch__c setting = new UserControlSwitch__c ();
		setting.Name = 'VR';
		setting.RunValidationRules__c = true;
		insert setting;
        
        Test.startTest();
        System.Debug('UserAssignmentTriggerTest Users uids=' + uids);        
        List<User_Assignment__c> uaList = new List<User_Assignment__c>();        
        for (Integer i=0; i<10; i++) {
            User_Assignment__c ua = new User_Assignment__c();
            ua.User__c = uIds[i].Id;   
            ua.FirstName__c = 'UAFirst' + i;
            ua.LastName__c= 'UALast' + i;
            ua.UserRole__c = '00E1o0000016OcMEAU';
            ua.Manager__c = '0051o000007cSq5AAE';
            ua.EmployeeNumber__c = '11111' + i;                       
            uaList.add(ua);
        }
        
        System.Debug('UserAssignmentTriggerTest uaList=' + uaList);
               
        // Inserting the User_Assignment__c objects should fire the associated trigger
        insert uaList;   
        // Ensure trigger completed (and hopefully the batch)
        Test.stopTest();
        
         // Check all of the User Assignments changed status appropriately
         System.debug('UserAssignmentTriggerTest: Success');     
        Integer retOAs = [SELECT COUNT()  
                          FROM User_Assignment__c
                          WHERE Status__c = 'Success' and FirstName__c like 'UAFirst%'and LastName__c like 'UALast%'
                                and UserRole__c = '00E1o0000016OcMEAU'and Manager__c = '0051o000007cSq5AAE'                          
                         ];              
        System.assertEquals(10, retOAs);
        System.debug('UserAssignmentTriggerTest: Fail');
        Integer retOAs2 = [SELECT COUNT()  
                          FROM User_Assignment__c
                          WHERE Status__c = 'Fail' and FirstName__c like 'UAFirst%'and LastName__c like 'UALast%'
                                and UserRole__c = '00E1o0000016OcMEAU'and Manager__c = '0051o000007cSq5AAE'                          ];
        System.assertEquals(0, retOAs2);
        
        System.debug('UserAssignmentTriggerTest: Duplicate');
        Integer retOAs3 = [SELECT COUNT()  
                           FROM User_Assignment__c
                           WHERE Status__c = 'Duplicate' and FirstName__c like 'UAFirst%'and LastName__c like 'UALast%'
                                and UserRole__c = '00E1o0000016OcMEAU'and Manager__c = '0051o000007cSq5AAE'                          ];
        System.assertEquals(0, retOAs3);
        System.debug('UserAssignmentTriggerTest: testUserAssignment FINISH');
    }
}