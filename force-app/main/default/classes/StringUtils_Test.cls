@isTest(SeeAllData=false) 
private class StringUtils_Test {
    
    static testMethod void testIsEmptyNull() {
		Test.startTest();
	    Boolean blnCheckEmptyString = StringUtils.isEmpty(null);
        Test.stopTest();     
    }
    
    static testMethod void testIsEmpty() {
		Test.startTest();
        String strString = 'Test fds ';
	    Boolean blnCheckEmptyString = StringUtils.isEmpty(strString);
        Test.stopTest();     
    }
    
    static testMethod void testIsIntegerOnlyException() {
		Test.startTest();
        String strString = 'Test fds ';
	    Boolean blnCheckEmptyString = StringUtils.isIntegerOnly(strString);
        Test.stopTest();     
    }
    
    static testMethod void testIsIntegerNull() {
		Test.startTest();
        Boolean blnCheckEmptyString = StringUtils.isIntegerOnly(null);
        Test.stopTest();     
    }
    
    static testMethod void testIsIntegerOnly() {
		Test.startTest();
        String strString = '8';
	    Boolean blnCheckEmptyString = StringUtils.isIntegerOnly(strString);
        Test.stopTest();     
    }
    
    static testMethod void testCreateListAlphaNumerics() {
		Test.startTest();
        List<String> lstAlphaNum = StringUtils.createListAlphaNumerics(5,5);
        Test.stopTest();     
    }
    static testMethod void testCreateAlphaNumeric() {
		Test.startTest();
        String strAlphaNum = StringUtils.createAlphaNumeric(5);
        Test.stopTest();     
    }
	
}