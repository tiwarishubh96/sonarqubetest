@isTest
private class SPPDocuSignSendTemplateTest
{
    @testSetup static void testData() {
        
        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
        //TestData.CreateLocale();
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c();
		accConFig.dsfs__AccountId__c = 'accountID'; 
        accConFig.dsfs__DSProSFUsername__c = 'userName'; 
	    accConFig.dsfs__DSProSFPassword__c = 'pass';
	    insert accConFig;
    }
    
    @isTest
    static void sendTemplates()
    {
        Account acc = [Select id from Account limit 1];
        Locale__C loc = [Select id from Locale__C limit 1];
        acc.Locale__c = loc.Id;
        acc.Partner_Agreement__c = 'On-line';
        update acc;
        Terms_Conditions_Community__c tncc = [Select id,Document_Type__c,Partner_Agreement__c from Terms_Conditions_Community__c limit 1];
        
        tncc.Document_Type__c = 'Enrollment Forms';
        tncc.Partner_Agreement__c = 'On-line';
        update tncc;
        System.debug('tncc: '+tncc);
        Contact con = [Select id,email,name,title from Contact limit 1];
        System.debug('acc sendTemplates'+acc);
        
        system.debug('122lstcomm  :'+[Select id , Partner_Locale__r.name from Terms_Conditions_Community__c]);
        system.debug('122lstcomm  :'+[Select id from Terms_Conditions_Version__c]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        SPPDocuSignSendTemplate.sendTemplates(acc.Id,con);
        
        Test.stopTest(); 

    }
    
    @isTest
    static void sendTemplateswithError()
    {
        Account acc = [Select id from Account limit 1];
        
        Contact con = [Select id,email,name,title from Contact limit 1];
        System.debug('acc sendTemplates'+acc);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        SPPDocuSignSendTemplate.sendTemplates(acc.Id,con);
        
        Test.stopTest(); 

    }
    
    @isTest
    static void sendTemplatesWithException()
    {
        Account acc = [Select id from Account limit 1];
        Locale__C loc = [Select id from Locale__C limit 1];
        acc.Locale__c = loc.Id;
        acc.Partner_Agreement__c = 'On-line';
        update acc;
        Terms_Conditions_Community__c tncc = [Select id from Terms_Conditions_Community__c limit 1];
        
        tncc.Document_Type__c = 'Enrollment Forms';
        tncc.Partner_Agreement__c = 'On-line';
        update tncc;
        Contact con = [Select id,email,name,title from Contact limit 1];
        System.debug('acc sendTemplates'+acc);
        
        Test.startTest();
        
        SPPDocuSignSendTemplate.sendTemplates(acc.Id,con);
        
        Test.stopTest(); 

    }
    
    
    
    
}