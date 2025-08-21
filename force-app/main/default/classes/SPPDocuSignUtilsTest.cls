/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          06/06/2017
    Company:       
    Description:   
    Inputs:        None
    History:        Lu, 10/24/2017 created test method createDocuSignStatusRecord
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPDocuSignUtilsTest {

    @testSetup static void testData() {
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c();
		accConFig.dsfs__AccountId__c = 'accountID'; 
        accConFig.dsfs__DSProSFUsername__c = 'userName'; 
	    accConFig.dsfs__DSProSFPassword__c = 'pass';
	    insert accConFig;
        
        
        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.createOpportunity(1);
        Account acc = [Select id from account limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Partner Account' Limit 1];
        acc.RecordType = rt;
        acc.isPartner = true;
        update acc;
        //acc.RecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Partner Account');
        Opportunity Oppt = [Select id,Type from Opportunity limit 1];
        oppt.Type = 'Resell Business';
        update oppt;
        system.debug('oppt :'+oppt);
        system.debug('acc :'+acc.RecordType.Name);
        

        Associated_Product__c ass = new Associated_Product__c(Product__c='Sage Live' , Account__c=acc.Id);
        Associated_Product__c ass1 = new Associated_Product__c(Product__c='Sage Business Cloud Accounting' , Account__c=acc.Id);
        List<Associated_Product__c> assList = new List<Associated_Product__c>();
        assList.add(ass);
        assList.add(ass1);
        insert assList;
        
        //Data for createpartnerRoleSharingDocusignStatus Method
        SPPTestData.CreateTandCGlobalAndVersions();
        SPPDocuSignTestData.CreateDocuSignStatus();
        dsfs__DocuSign_Status__c doc = [Select id from dsfs__DocuSign_Status__c limit 1];
        Terms_Conditions_Version__c tnv = [Select id from Terms_Conditions_Version__c where Active__c = true limit 1];
        Contact con = [Select id from Contact limit 1];
        SPPDocuSignTestData.CreatePartnerTandCond(acc,tnv,doc,con);
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
 
        System.runAs ( thisUser ) 
        {
        
            UserRole r = new UserRole(PortalAccountId = acc.Id,PortalType = 'Partner');
            Database.insert(r);
        }
        
        
    }
    
    @isTest
	static void getConfigTest()
	{
		HttpRequest req = SPPDocuSignUtils.getConfig('endPoint' , 'Post' , 'contentType');
		System.debug('req : '+ req);

	}
    
    @isTest
	static void getProductListTest()
	{
        List<Account> accList = [select id from account limit 10];
		SPPDocuSignUtils.getProductList(accList);
		

	}
    
    static TestMethod void createpartnerRoleSharingDocusignStatusTest()
    {
        
        List<Partner_Terms_and_Condition__c> lstPTnC = [Select id from Partner_Terms_and_Condition__c];
        SPPDocuSignUtils.createpartnerRoleSharingDocusignStatus(lstPTnC);
    }

    static TestMethod void createDocuSignStatusRecordTest(){
        List<Account> accList = [select id from account limit 1];
        SPPDocuSignUtils.createDocuSignStatusRecord(accList[0].id);
        
    }
    
    //Lu, 10/24/2017, get caught in catch block of createDocuSignStatusRecordTest method
    static TestMethod void createDocuSignStatusRecordTestWithException(){
        SPPDocuSignUtils.createDocuSignStatusRecord('123');
    }
        
}