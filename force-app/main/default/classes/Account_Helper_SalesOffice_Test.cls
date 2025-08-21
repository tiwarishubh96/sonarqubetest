/**
 * @description  Account_Helper_SalesOffice_Test Test
    ***Sales Office Verification  on Insert/Update ***
      -If Account Biiling Country is US/CA - then expected SalesOffice is 'Atlanta CBC'
	  -If Account Biiling Country is CA - then expected SalesOffice is 'Canada CBC'
      -If Account Biiling Country is UK/IE/FR/ES/DE - then expected SalesOffice is 'Dublin CBC'
	  -If Account Biiling Country is not in UK/IE/FR/ES/DE/US/CA - then expected SalesOffice is None
      - If Account Biiling Country is not set  - then expected SalesOffice is 'None'
 	* @author Veni Korapaty
    * @date Decemeber 6 2020
 **/
@IsTest
private class Account_Helper_SalesOffice_Test {

  @TestSetup static void setup() {
      
    //// Test Account WITHOUT Country
    Account acc = new Account(Name = 'TestAccountWithOutCountry');
    insert acc;
    
    //USA Test Account
    Account usAccount = new Account(Name = 'USATestAccount', 
                                    BillingCity = 'Atlanta',
       								 BillingCountry = 'United States',
									 BillingStreet ='Some Street',
                                     BillingPostalCode = '30318' );
     insert usAccount;
      
     //Canada Test Account
    Account canadaAccount = new Account(Name = 'CanadaTestAccount', 
                                    BillingCity = 'Canada City',
       								 BillingCountry = 'Canada',
									 BillingStreet ='Canada Street',
                                     BillingPostalCode = 'L5M1v7' );
     insert canadaAccount;
      
    //France Test Account
    Account franceAccount = new Account(Name = 'FranceTestAccount', 
                                    BillingCity = 'France City',
       								 BillingCountry = 'France',
									 BillingStreet ='France Street');
     insert franceAccount;
      
    
     //UK Test Account
    Account UkAccount = new Account(Name = 'UKTestAccount', 
                                    BillingCity = 'UK City',
       								 BillingCountry = 'United Kingdom',
									 BillingStreet ='UK Street');
     insert UkAccount;
      
     //India Test Account
    Account indiaAccount = new Account(Name = 'IndiaTestAccount', 
                                    BillingCity = 'Inida City',
       								 BillingCountry = 'India',
									 BillingStreet ='IndiaStreet');
     insert indiaAccount;
      
   }

  /*** Sales Office Verification on Insert
     * If Account Biiling Country is UK/IE/FR/ES/DE - then expected SalesOffice is 'Dublin CBC'
    **/
  @IsTest static void testUKAndFRAccSalesOffice() {
     Test.startTest();
     String expectedSalesOffice='Dublin CBC';
     Account UkSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE   Name='UKTestAccount' LIMIT 1];
	 System.assertEquals(expectedSalesOffice, UkSalesOffice.Sales_Office__c);   
     Account franceSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE   Name='FranceTestAccount' LIMIT 1];
	 System.assertEquals(expectedSalesOffice, franceSalesOffice.Sales_Office__c); 
  	 Test.stopTest();        
    }
    
    /*** Sales Office Verification on Insert
     * If Account Biiling Country is US/CA - then expected SalesOffice is 'Atlanta CBC'
    **/
  @IsTest static void testUSAccSalesOffice() {
     Test.startTest();
     String expectedSalesOffice='Atlanta CBC';
     Account usSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE   Name='USATestAccount' LIMIT 1];
	 System.assertEquals(expectedSalesOffice, usSalesOffice.Sales_Office__c);
  	 Test.stopTest();        
    }
    
    /*** Sales Office Verification on Insert
     * If Account Biiling Country is CA - then expected SalesOffice is 'Dublin CBC'
    **/
  @IsTest static void testCanadaAccSalesOffice() {
     Test.startTest();
     String expectedSalesOffice='Canada CBC';
     Account canadaSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE   Name='CanadaTestAccount' LIMIT 1];
	 System.assertEquals(expectedSalesOffice, canadaSalesOffice.Sales_Office__c);
  	 Test.stopTest();        
    }
    
    
    /*** Sales Office Verification  on Update 
     * Update the Country from US to UK , salesoffice should be updated to Dublin CBC
    **/
    @IsTest static void testUSToUKAccSalesOffice() {
        Test.startTest();
        String expectedSalesOffice = 'Dublin CBC';
        Account usSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountryCode,BillingCountry FROM Account WHERE Name = 'USATestAccount' LIMIT 1];
        usSalesOffice.BillingCountryCode = 'GB';
        update usSalesOffice;

        Account ukSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry,BillingCountryCode FROM Account WHERE Name = 'USATestAccount' LIMIT 1];
        System.assertEquals(expectedSalesOffice, ukSalesOffice.Sales_Office__c);
        Test.stopTest();
    }

    /*** Sales Office Verification  on Update
    * Update the Country from UK to USA , salesoffice should be updated to Atlanta CBC
   **/
    @IsTest static void testUKToUSAccSalesOffice() {
        Test.startTest();
        String expectedSalesOffice = 'Atlanta CBC';
        Account ukSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry,BillingCountryCode FROM Account WHERE Name = 'UKTestAccount' LIMIT 1];
        ukSalesOffice.BillingCountryCode = 'US';
        update ukSalesOffice;

        Account usSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE Name = 'UKTestAccount' LIMIT 1];
        System.assertEquals(expectedSalesOffice, usSalesOffice.Sales_Office__c);
        Test.stopTest();
    }
    
    
 
  /*** Sales Office Verification  on Insert 
     No country on Account - No SalesOffice
    **/    
  @IsTest static void testNoSalesOffice() {
     Test.startTest();
     String expectedSalesOffice='None';
     Account NoSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE   Name='TestAccountWithOutCountry' LIMIT 1];
     System.assertEquals(expectedSalesOffice, NoSalesOffice.Sales_Office__c); 
     Test.stopTest();        
    }
    
    /*** Sales Office Verification  on Insert 
     No country on Account Specified in the List - No SalesOffice
    **/
  @IsTest static void testSalesOfficeWithNoCountryInMetadata() {
     Test.startTest();
     String expectedSalesOffice='None';
     Account NoSalesOffice = [SELECT Id, Name, Sales_Office__c,BillingCountry FROM Account WHERE   Name='IndiaTestAccount' LIMIT 1];
     System.assertEquals(expectedSalesOffice, NoSalesOffice.Sales_Office__c); 
     Test.stopTest();        
    }
  

}