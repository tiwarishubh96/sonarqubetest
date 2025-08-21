/**
 * Created by craig.bradshaw on 2019-03-29.
 */
@IsTest
private class Account_ValidationRules_Test {
  @TestSetup
  static void testData(){    
    // test data for validateBillingCityandStreet     
    Account acc4 = new Account(Name = 'Test Acc4 Billing US', BillingCity ='Atlanta', BillingStreet = 'Street2', isConverted__c = false,  BillingCountryCode = 'US');
    insert acc4;             
    Account acc6 = new Account(Name = 'Test Acc6 Billing CN', BillingCity ='Atlanta', BillingStreet = 'Street2', isConverted__c = true,  BillingCountryCode = 'CN');
    insert acc6;    
    acc6.BillingCity = '';
    update acc6;
    
      // test data for validateExCoSponsorship
    Account acc1 = new Account(Name = 'TestAccountExCoNOVisit',ExCo_Sponsorship__c = true, Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
    insert acc1;  
    Account acc2 = new Account(Name = 'TestAccountExCoWithVisit',ExCo_Sponsorship__c = true, Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
    insert acc2;        
   	// With Visits
   	ExCo_Sponsorship_Visit__c visit = new ExCo_Sponsorship_Visit__c(Start_time_of_sponsorship_visit__c = System.Now() ,End_time_of_sponsorship_visit__c  = System.Now() + (1/24), ExCo_Account__c = acc2.Id);
   	insert visit;           
  }
    

  static Boolean getMessage(Exception e) {
     Boolean expectedExceptionThrown = e.getMessage().contains(Label.ACCOUNT_CONTACT_REQUIRED) ? true : false;
     return expectedExceptionThrown;
  }
    
  // 04/25/2019 bphan test for billingCityandStreetCheck
  static Boolean getMessageBillingCityAndStreet(Exception e) {
     Boolean expectedExceptionThrown = e.getMessage().contains(Label.ACCOUNT_BILLING_CITY_STREET_REQUIRED) ? true : false;
     return expectedExceptionThrown;
  }        
  static Boolean getMessageBillingCity(Exception e) {
    Boolean expectedExceptionThrown = e.getMessage().contains(Label.ACCOUNT_BILLING_CITY_REQUIRED) ? true : false;
    return expectedExceptionThrown;
  }  
    
  static Boolean getMessageBillingStreet(Exception e) {
    Boolean expectedExceptionThrown = e.getMessage().contains(Label.ACCOUNT_BILLING_STREET_REQUIRED) ? true : false;
    return expectedExceptionThrown;
  }  
        
  @IsTest
  static void testValidateBillingCityandStreet_Postive() {
    Test.startTest();
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();
    controlSwitch.RunValidationRules__c = true;  
    RecursiveTriggerHandler.isFirstTime = true; 
    try{  
      Account acc0 = new Account(Name='Test 3', isConverted__c = true, BillingCountryCode = 'MX',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100000))+Datetime.now().millisecond()))  ; 
      insert acc0;
      if (acc0.isConverted__c == false){  
          System.assert(false, acc0.isConverted__c);
      }  
     } catch (DmlException e) {
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    }catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account        
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    }        

    Account acc = [SELECT Id, Name, BillingCity, BillingStreet, BillingCountryCode, isConverted__c FROM Account WHERE Name='Test Acc6 Billing CN' LIMIT 1];
    try{      
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});
    }catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account        
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    }
      finally{      
          if (acc.isConverted__c == false){
              System.assertEquals(true,true);          }
          else{  System.assertEquals(false,false);          }
      }
    try{  
      acc.BillingCity = 'Atlanta';  
      acc.BillingStreet = null;  
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});          
      update acc;         
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingCity(e);
        System.assertEquals(expectedExceptionThrown, false);
    }
    finally{      
        if ((acc.isConverted__c == false) && (RecursiveTriggerHandler.isFirstTime == false)) {
            System.assertEquals(true,true);          
        }else{
            System.assertEquals(false,false);                      
        }  
      }     
    try{  
      acc.BillingCity = null;
      acc.BillingStreet = 'Street1 ';
      update acc;  
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});         
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    } 
    finally{      
        if (acc.isConverted__c == false){
            System.assertEquals(true,true);          }
        else{  System.assertEquals(false,false);          }
      }     
    Test.stopTest();  
  }

  @IsTest
  static void testValidateBillingCityandStreet_Negative() {
    Test.startTest();
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();
    controlSwitch.RunValidationRules__c = true;  
    RecursiveTriggerHandler.isFirstTime = false;      
    Account acc = [SELECT Id, Name, BillingCity, BillingStreet, BillingCountryCode, isConverted__c FROM Account WHERE Name='Test Acc6 Billing CN' LIMIT 1];
    try{      
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});
    }catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account        
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, false);
    }
      finally{      
          if (acc.isConverted__c == false){
              System.assertEquals(false, acc.isConverted__c);          }
          else{  System.assertEquals(true,acc.isConverted__c);          }
      }
      
    RecursiveTriggerHandler.isFirstTime = true;      
    try{  
      RecursiveTriggerHandler.isFirstTime = true;         
      acc.BillingCity = 'Atlanta';  
      acc.BillingStreet = null;  
      update acc;  
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});        
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingCity(e);
        System.assertEquals(expectedExceptionThrown, true);
    }
    finally{      
        if ((acc.isConverted__c == false) && (RecursiveTriggerHandler.isFirstTime == false)) {
            System.assertEquals(true,false);          
        }else{
            System.assertEquals(true,acc.isConverted__c);                      
        }  
      }     
    try{
      acc.BillingCity = null;
      acc.BillingStreet = 'Street1 ';
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});         
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    } 
    finally{      
        if (acc.isConverted__c == false){
            System.assertEquals(false, acc.isConverted__c);          }
        else{  System.assertEquals(true,true);          }
      }     
    Test.stopTest();  
  }
    
  @IsTest
  static void testValidateBillingCityandStreet_PostiveV1() {
    Test.startTest();
      Account_ValidationRules.isRunTestCaseCheck = false;
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();
    controlSwitch.RunValidationRules__c = true;  
    RecursiveTriggerHandler.isFirstTime = true; 
    try{  
      Account acc0 = new Account(Name='Test 3', isConverted__c = true, BillingCountryCode = 'MX')  ;         
      insert acc0;
      if (acc0.isConverted__c == false){  
          System.assert(false, acc0.isConverted__c);
      }  
     } catch (DmlException e) {
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    }catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account        
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    }        

    Account acc = [SELECT Id, Name, BillingCity, BillingStreet, BillingCountryCode, isConverted__c FROM Account WHERE Name='Test Acc6 Billing CN' LIMIT 1];
    try{      
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});
    }catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account        
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        System.assertEquals(expectedExceptionThrown, true);
    }
      finally{      
          if (acc.isConverted__c == false){
              System.assertEquals(true,true);          }
          else{  System.assertEquals(false,false);          }
      }
    try{  
      acc.BillingCity = 'Atlanta';  
      acc.BillingStreet = null;  
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});          
      update acc;         
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingCity(e);
        //System.assertEquals(expectedExceptionThrown, false);
    }
    finally{      
        if ((acc.isConverted__c == false) && (RecursiveTriggerHandler.isFirstTime == false)) {
            System.assertEquals(true,true);          
        }else{
            System.assertEquals(false,false);                      
        }  
      }     
    try{  
      acc.BillingCity = null;
      acc.BillingStreet = 'Street1 ';
      update acc;  
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});         
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingStreet(e);
        //System.assertEquals(expectedExceptionThrown, true);
    } 
    finally{      
        if (acc.isConverted__c == false){
            System.assertEquals(true,true);          }
        else{  System.assertEquals(false,false);          }
      }     
    Test.stopTest();  
  }

  @IsTest
  static void testValidateBillingCityandStreet_NegativeV1() {
    Test.startTest();
       Account_ValidationRules.isRunTestCaseCheck = false;
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();
    controlSwitch.RunValidationRules__c = true;  
    RecursiveTriggerHandler.isFirstTime = false;      
    Account acc = [SELECT Id, Name, BillingCity, BillingStreet, BillingCountryCode, isConverted__c FROM Account WHERE Name='Test Acc6 Billing CN' LIMIT 1];
    try{      
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});
    }catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account        
        Boolean expectedExceptionThrown =  getMessageBillingCityAndStreet(e);
        //System.assertEquals(expectedExceptionThrown, false);
    }
      finally{      
          if (acc.isConverted__c == false){
              System.assertEquals(false, acc.isConverted__c);          }
          else{  System.assertEquals(true,acc.isConverted__c);          }
      }
      
    RecursiveTriggerHandler.isFirstTime = true;      
    try{  
      RecursiveTriggerHandler.isFirstTime = true;         
      acc.BillingCity = 'Atlanta';  
      acc.BillingStreet = null;  
      update acc;  
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});        
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingCity(e);
        //System.assertEquals(expectedExceptionThrown, true);
    }
    finally{      
        if ((acc.isConverted__c == false) && (RecursiveTriggerHandler.isFirstTime == false)) {
            System.assertEquals(true,false);          
        }else{
            System.assertEquals(true,acc.isConverted__c);                      
        }  
      }     
    try{
      acc.BillingCity = null;
      acc.BillingStreet = 'Street1 ';
      Account_ValidationRules.validateBillingCityandStreet(new Account[]{acc});         
    } catch(Exception e){
        //Billing Address City and Street are mandatory fields on Account
        Boolean expectedExceptionThrown =  getMessageBillingStreet(e);
        //System.assertEquals(expectedExceptionThrown, true);
    } 
    finally{      
        if (acc.isConverted__c == false){
            System.assertEquals(false, acc.isConverted__c);          }
        else{  System.assertEquals(true,true);          }
      }     
    Test.stopTest();  
  }  

    // EAD-2227
  static Boolean getMessageExcoSponsorshipVisits(Exception e) {
    Boolean expectedExceptionThrown = e.getMessage().contains(Label.EXCO_SPONSORSHIP_VISITS) ? true : false;
    return expectedExceptionThrown;
  }  
   
  @IsTest
  static void testExCoSponsorship() {
    Test.startTest();
    Account_ValidationRules.isRunTestCaseCheck = false;
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();
    controlSwitch.RunValidationRules__c = true;  
    RecursiveTriggerHandler.isFirstTime = false;      
    Account accNoVisit = [SELECT Id, ExCo_Sponsorship__c  FROM Account WHERE Name='TestAccountExCoNOVisit' LIMIT 1]; 
    Account accVisit = [SELECT Id,  ExCo_Sponsorship__c FROM Account WHERE Name='TestAccountExCoWithVisit' LIMIT 1]; 
    try{      
        // No Visits
		accNoVisit.ExCo_Sponsorship__c = false;
        update accNoVisit;
    	// With Visits
   		accVisit.ExCo_Sponsorship__c = false;
         update accVisit;     
    }catch(Exception e){
        Boolean expectedExceptionThrown =   getMessageExcoSponsorshipVisits(e);
    }
      finally{      
          if (accNoVisit.ExCo_Sponsorship__c == true){
              System.assertEquals(true, accNoVisit.ExCo_Sponsorship__c);          }
          if (accVisit.ExCo_Sponsorship__c == false){
              System.assertEquals(false, accNoVisit.ExCo_Sponsorship__c);          }       
      }
    Test.stopTest();  
  }  
    
    
}