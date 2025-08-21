//@author: Ravi Yalamati
//@date: 26-02-2019
//@descrption: Test class for OpenAndClosedCasesController
@isTest
public class OpenAndClosedCasesControllerTest {
private static testMethod void testDoAction() {
    Id idRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Case').getRecordTypeId();
System.debug('RecordTypeId based on Developer Name ---> '+idRecordId);

    //create test data
    Account testAccount = new Account(name='TestAccount');
    insert testAccount;
    Case testCase1 = new Case (subject='Test subject 1', accountId = testAccount.Id ,Remote_Support__c='Remote PC connected',Status ='New',Recordtypeid = idRecordId);
    Case testCase2 = new Case(Subject = 'Test subject 2', accountId = testAccount.Id,Status ='New',Recordtypeid = idRecordId);
    insert new List<Case> {testCase1, testCase2};
    //Start test
    Test.startTest();
    //set the page reference
    PageReference pageRef = Page.OpenAndClosedCasesPage;
    Test.setCurrentPage(pageRef);
    //set the id of account
    pageRef.getParameters().put('Id', String.valueOf(testAccount.Id));
    ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
    OpenAndClosedCasesController testAccPlan = new OpenAndClosedCasesController(sc);
    //test the main method which will calculate the open and close case
    testAccPlan.doAction();
    OpenAndClosedCasesController.getRemoteSupport(testAccount.Id);
    System.assertEquals(OpenAndClosedCasesController.openCaseCount, 2);
    System.assertEquals(OpenAndClosedCasesController.closeCaseCount, 0);
    Test.stopTest();
    }
}