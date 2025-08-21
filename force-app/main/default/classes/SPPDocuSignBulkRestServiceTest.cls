@isTest
private class SPPDocuSignBulkRestServiceTest
{

    @testSetup static void testData() {
        
        SPPTestData.CreateAccountAndContactForPartnerType();
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c();
		accConFig.dsfs__AccountId__c = 'accountID'; 
        accConFig.dsfs__DSProSFUsername__c = 'userName'; 
	    accConFig.dsfs__DSProSFPassword__c = 'pass';
	    insert accConFig;
        
        List<String> partTypeList = new List<String>();
        partTypeList.add('Accountant');
        

        List<Terms_Conditions_Community__c > tccList = new List<Terms_Conditions_Community__c>();
        Locale__c loc = SPPTestData.CreateLocale();
        
        Terms_Conditions_Community__c tncc = new Terms_Conditions_Community__c(Document_Type__c='Enrollment Forms',Active__c = true ,Partner_Types__c = 'Accountant', Partner_Agreement__c ='On-line' ,Partner_Locale__c =loc.id , Partner_Tiers__c='Authorized');
        tccList.add(tncc);
        Terms_Conditions_Community__c tncc1 = new Terms_Conditions_Community__c(Document_Type__c='Enrollment Forms',Active__c = true ,Partner_Types__c = 'System Implementers', Partner_Agreement__c ='On-line' ,Partner_Locale__c =loc.id , Partner_Tiers__c='Authorized');
        //tccList.add(tncc1);
        Terms_Conditions_Community__c tncc2 = new Terms_Conditions_Community__c(Document_Type__c='Enrollment Forms',Active__c = true ,Partner_Types__c = 'ISV', Partner_Agreement__c ='On-line' ,Partner_Locale__c =loc.id , Partner_Tiers__c='Authorized');
       // tccList.add(tncc2);
        Terms_Conditions_Community__c tncc3 = new Terms_Conditions_Community__c(Document_Type__c='Enrollment Forms',Active__c = true ,Partner_Types__c = 'Reseller', Partner_Agreement__c ='On-line' ,Partner_Locale__c =loc.id , Partner_Tiers__c='Authorized');
       // tccList.add(tncc3);

        Terms_Conditions_Community__c tncc4 = new Terms_Conditions_Community__c(Document_Type__c='Enrollment Forms',Active__c = true ,Partner_Types__c = 'Alliance' , Partner_Agreement__c ='On-line',Partner_Locale__c =loc.id , Partner_Tiers__c='Corporate');
        System.debug('tncc1'+ tccList);
        //tccList.add(tncc4);

        insert tccList;



        List<Terms_Conditions_Community__c > tccList1 = [Select id , name from Terms_Conditions_Community__c];
        List<Terms_Conditions_Version__c> tcvList = new List<Terms_Conditions_Version__c>();

        for(Terms_Conditions_Community__c o :tccList1)
        {
            Terms_Conditions_Version__c tncv1 = new Terms_Conditions_Version__c(DocuSign_Bulk_Template_Id__c ='test', Docusign_Template_ID__c ='test1',Active__c = true , Terms_Conditions_Community__c = o.Id ,Start_Date_Active__c = Date.today());
            tcvList.add(tncv1) ;
        }
        
        insert tcvList;

        List<Terms_Conditions_Version__c> tnvInsertedList = [Select Id from Terms_Conditions_Version__c];

        List<Partner_Terms_and_Condition__c> partList = new List<Partner_Terms_and_Condition__c>();
    
        Account acc = [Select id from Account limit 1];
        Contact con = [Select id from Contact limit 1];
        for(Terms_Conditions_Version__c obj : tnvInsertedList )
        {

            Partner_Terms_and_Condition__c par = new Partner_Terms_and_Condition__c();
            par.Docusign_Status__c = 'pending';
            par.Account__c = acc.Id;
            par.Contact__c = con.id;
            par.Terms_Conditions_Version__c = obj.Id;
            par.DocuSign_EnvelopeId__c = 'enveId';
            partList.add(par);
        }
        


        insert partList;

        dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c();
        docStatus.dsfs__DocuSign_Envelope_ID__c = '12345';
        insert docStatus;
    }


    @isTest
    static void getCsvStringTest()
    {
        Terms_Conditions_Version__c tncv = [Select Id , Partner_Type__c ,Name from Terms_Conditions_Version__c Limit 1];
         
         String fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 
        
        //Query too fetch Account record details
        string strparentqry = 'Select Locale__r.Name ,'+fieldsAPIname+' from Account ';
        List<Account> lstacc = Database.query(strparentqry);

        SPPDocuSignBulkRestService spp = new SPPDocuSignBulkRestService();
        spp.getCsvString(tncv.Id , lstacc , tncv);
    }
    
    @isTest
    static void onActivateTnCVersionsTest()
    {

        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        Terms_Conditions_Version__c tncv = [Select Id , Name,Partner_Type__c from Terms_Conditions_Version__c where Partner_Type__c = 'Accountant' Limit 1];
        String fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 
        
        //Query too fetch Account record details
        string strparentqry = 'Select Locale__r.Name ,'+fieldsAPIname+' from Account ';
        List<Account> lstacc = Database.query(strparentqry);

        SPPDocuSignBulkRestService spp = new SPPDocuSignBulkRestService();
        test.startTest();
        spp.onActivateTnCVersions(tncv.Id , lstacc );
        test.stopTest();
    }

    
    
    @isTest
    static void updateAccountTiersTest()
    {
        List<Partner_Terms_and_Condition__c> partList = [Select id,name,Partner_Type__c,Account__c from Partner_Terms_and_Condition__c];
        SPPDocuSignBulkRestService spp = new SPPDocuSignBulkRestService();
        spp.updateAccountTiers( partList);
    }
    
    @isTest
    static void updateAccountTiersWithNullTest()
    {
        SPPDocuSignBulkRestService spp = new SPPDocuSignBulkRestService();
        spp.updateAccountTiers( null);
    }

    @isTest
    static void updatePartnerJunctionTest()
    {
        List<Partner_Terms_and_Condition__c> parJuncUpdateList = [Select id from Partner_Terms_and_Condition__c];
        SPPDocuSignBulkRestService spp = new SPPDocuSignBulkRestService();
        spp.updatePartnerJunction( parJuncUpdateList);
    }
    
    
    @isTest
    static void divideAccountsBasedOnPartnerCountTest()
    {
        List<Account> accountList = [Select id , (Select id,Account__c,DocuSign_Status__c,Partner_Type__c,Voided__c from Partner_Terms_and_Conditions__r) from account];
        Terms_Conditions_Version__c tncv = [Select Id,DocuSign_Bulk_Template_Id__c,Partner_Type__c from Terms_Conditions_Version__c limit 1];
        
        SPPDocuSignBulkRestService spp = new SPPDocuSignBulkRestService();
        spp.divideAccountsBasedOnPartnerCount(accountList, tncv);
    }
    

}