@isTest(SeeAllData=false) 
private class TetrisAddressHelper_Test {
    
    static testMethod void testretrieveStateListGBP() {
		Test.startTest();
        String strCountryISOCode = 'GBP';
        TetrisAddressHelper.retrieveStateList(strCountryISOCode);
    	Test.stopTest();    
    }

}