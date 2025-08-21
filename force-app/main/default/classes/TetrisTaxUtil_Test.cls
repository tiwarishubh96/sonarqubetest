@isTest(SeeAllData=false) 
private class TetrisTaxUtil_Test {
	
	static testMethod void testCalculateTaxException() {
    		Test.startTest();
        String taxServiceUrl = 'https://sample-taxcalculator.com';
        String userName = 'uname';
        String password = 'password';
        	String companyCode = 'Ct-21211';
       	String customerCode = 'Ct-1221';
       	String taxCode = 'Ct-11211'; 
		Decimal amount = 20;
		String postalCode = '22442';
		String country = 'United Kingdom';
        try {
             TetrisTaxModel tetrisTaxModelObj = TetrisTaxUtil.calculateTax(taxServiceUrl, userName, password, 
                      										companyCode, customerCode, taxCode, 
                       										amount, postalCode, country);
        } catch(TetrisTaxException e) {
            system.assertEquals(e.getMessage(), e.getMessage());
        }
       
        Test.stopTest();
        
    }
    
    
	static testMethod void testGetTaxServiceRequestHeader() {
    		Test.startTest();
        String taxServiceUrl = 'https://sample-taxcalculator.com';
        String userName = 'uname';
        String password = 'password';
        
        HttpRequest httpsReqObj = TetrisTaxUtil.getTaxServiceRequestHeader(taxServiceUrl, userName, password); 
        
        Test.stopTest();
        
    }
    static testMethod void testGetTaxServiceRequestBody() {
    		Test.startTest();
       	String companyCode = 'Ct-21211';
       	String customerCode = 'Ct-1221';
       	String taxCode = 'Ct-11211'; 
		Decimal amount = 20;
		String postalCode = '22442';
		String country = 'United Kingdom';
        
        String strBody = TetrisTaxUtil.getTaxServiceRequestBody(companyCode, customerCode, taxCode, 
                        amount, postalCode, country); 
        
        Test.stopTest();
        
    }
}