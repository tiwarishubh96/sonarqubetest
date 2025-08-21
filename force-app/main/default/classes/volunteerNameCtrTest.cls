@isTest    
public class volunteerNameCtrTest{
    @istest
    static void test1(){
    Test.startTest();  
    User u = new User();
    u.Lastname='test';
    u.FirstName='test';    
    u.username='testuser1234@sage.com';
    u.email = 'test@sage.com';
    u.Alias = 'tUser';
    u.TimeZoneSidKey = 'America/New_York';
    u.LocaleSidKey = 'en_US';
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    Profile prof = [Select Id from Profile Where Name = 'System Administrator'];
    u.ProfileId = prof.id;
    
    insert u;
    
    ApexPages.StandardController cnt = new ApexPages.StandardController(u);
    volunteerNameCtr vNCnt = new volunteerNameCtr (cnt);
    vNCnt.redirect();
    Test.stopTest();
    }
}