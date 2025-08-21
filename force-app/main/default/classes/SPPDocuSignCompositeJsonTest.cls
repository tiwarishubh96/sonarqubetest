@isTest
private class SPPDocuSignCompositeJsonTest
{

    
	@testSetup static void testData() {
		dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c();
		accConFig.dsfs__AccountId__c = 'accountID'; 
        accConFig.dsfs__DSProSFUsername__c = 'userName'; 
	    accConFig.dsfs__DSProSFPassword__c = 'pass';
	    insert accConFig;
		
        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
        
        Account acc = [select id from account limit 1];
        Associated_Product__c ass = new Associated_Product__c(Product__c='Sage Live' , Account__c=acc.Id);
        insert ass;

	}
	
	@isTest
	static void parseTest()
	{

		SPPDocuSignCompositeJson sppObj = SPPDocuSignCompositeJson.parse('{"emailSubject":"email"}');
		/*
		SPPDocuSignCompositeJson.RestAPIServices sppDocComp = new SPPDocuSignCompositeJson.RestAPIServices();
		HttpRequest req = sppDocComp.getConfig('endPoint' , 'Post' , 'contentType');
		System.debug('req : '+ req);
*/
	}

	@isTest
	static void getCustomTagsMapTest()
	{
		string fieldsAPIname = '';
        fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account
        //Query too fetch Account record details
        string strparentqry = 'Select Locale__r.Name ,Owner.Title,'+fieldsAPIname+' from Account Limit 1 ';
		Account acc = Database.query(strparentqry);
		SPPDocuSignCompositeJson.RestAPIServices sppDocComp = new SPPDocuSignCompositeJson.RestAPIServices();
		map<String , String > mapResp = sppDocComp.getCustomTagsMap(acc , 'Accountant', '');
		System.debug('mapResp : '+ mapResp);

	}


	@isTest
	static void builCompositTemplateTest()
	{
		List<Contact> conList = [Select Id ,name,email,title from Contact ];
		List<String> tempList = new List<String>();
		tempList.add('tempList1');
		string fieldsAPIname = '';
        fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 
        
        //Query too fetch Account record details
        string strparentqry = 'Select Locale__r.Name,Owner.Email, Owner.Name, Owner.Username,Owner.Title,'+fieldsAPIname+' from Account Limit 1 ';

         
		Account acc = Database.query(strparentqry);
		
        map<Integer , String > mapTemp = new map<Integer , String >();
		mapTemp.put(1,'test2');


		SPPDocuSignCompositeJson.RestAPIServices sppDocComp = new SPPDocuSignCompositeJson.RestAPIServices();
	
        
		sppDocComp.builCompositTemplate( conList , mapTemp  , acc,  'mapTemp');


	}
   


}