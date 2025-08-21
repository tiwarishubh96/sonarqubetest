@isTest
public class FileUploadControllerTest {
    @isTest
    static void uploadDocument_Test(){
        Account a = new Account(name='Test');
        insert a;
        Contact c = new Contact(FirstName='test', LastName='test', AccountId=a.Id, Email = 'hasPermissionSet@sage.com');
		insert c;
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        String fileName = 'testFile',base64Data = 'Testing done for FileUploadController', contentType = 'pdf'; 
        Folder folder = [SELECT Id,Name FROM Folder where Type = 'Document' LIMIT 1];
        string folderName = folder.Name;
        system.runAs(u){
            test.startTest();
            FileUploadController.uploadDocument(fileName, base64Data, contentType, null);
            FileUploadController.uploadDocument(fileName, base64Data, contentType, folderName);
            FileUploadController.uploadDocument(fileName, base64Data, contentType, folderName);
            test.stopTest();
        }
    }
    
    public static User createPortalUser(Id contactId, String firstName, String lastName, String email, String username) {

        User u = new User();
        u.FirstName = firstName;
        u.lastName = lastName;
        u.username = username;
        u.alias = firstName;
        u.email = email;
        u.ProfileId = ([select id from profile where name = :Constants.SYSTEM_ADMINISTRATOR_PROFILE LIMIT 1]).Id;
        u.CurrencyIsoCode = 'USD';
        u.LanguageLocaleKey = 'en_US';
        //u.ContactId = contactId;
        u.TimeZoneSidKey = 'GMT';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';

        insert u;
        return u;
    }
}