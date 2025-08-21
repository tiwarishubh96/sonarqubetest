@isTest
public class TestContentversionHandler {

    
    static testmethod void UpdateSyncwithZifttest(){
        Test.startTest();
       
       //Create Document Parent Record
           Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345', Synch_with_Zift__c = True, RecordtypeId = '01224000000LEwm' );
        insert testAcc;
        
     Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com');
     insert testCon;
     
    Case testCase = new Case(Type = 'Problem', ContactId = testCon.Id, Case_Category__c = 'Accounting/Payroll - Bank', Case__c = 'Accounting - Transfer', Status = 'Service - Work In Progress', Priority = 'Medium', Origin = 'Phone', Subject = 'Test Case', Recordtypeid = '01224000000gKMr');
    insert testCase;
             
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
             
            //Get Content Documents
            List<ContentDocument> docList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
             
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = testCase.Id;
            cdl.ContentDocumentId = docList[0].Id;
            cdl.shareType = 'V';
            Insert cdl;
            
            cv.Description = 'SyncwithZift';
            Update cv;
       }
}