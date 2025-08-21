/**
 * Created by Craig.Bradshaw on 12/03/2019.
 * Description:  Contains all the GLOBAL related logics
 * Use Account_ValidationRules for any REGIONAL related rules
 */
public without sharing class Account_Helper { 
  static final String CLASSNAME = 'Account_Helper';

  /**
   * @description:When Account Phone and Billing Address is updated, change the same info in the billing account's bill to and sold to contacts
   * 2019-06-29 Bob Lin 
   * @param: List of trigger new accounts
   * @param: List of trigger old accounts
   **/    
  public static void getBillingAddressandPhoneinZuora(List<Account> triggerNew, List<Account> triggerOld){
    try {
      LogControl.push('getBillingAddressandPhoneinZuora', CLASSNAME); 
      Set<Id> ChangedAccountIds = new Set<Id>();        
      for( Integer i = 0; i < triggerNew.size(); i++){
        Account newZAcc = (Account)triggerNew[i];
        Account oldZAcc = (Account)triggerOld[i];
        if( newZAcc.BillingAddress!= oldZAcc.BillingAddress || newZAcc.Phone!= oldZAcc.Phone
          || newZAcc.BillingCity!= oldZAcc.BillingCity|| newZAcc.BillingCountry!= oldZAcc.BillingCountry
          || newZAcc.BillingPostalCode!= oldZAcc.BillingPostalCode|| newZAcc.BillingState!= oldZAcc.BillingState
          || newZAcc.BillingStreet!= oldZAcc.BillingStreet ){
          ChangedAccountIds.add(newZAcc.Id);
        }
      }   
      if(ChangedAccountIds.size()>0) updateBillingAddressandPhoneinZuora(ChangedAccountIds);        
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }        
  }
   @Future(Callout=true)
   public static void updateBillingAddressandPhoneinZuora(Set<Id> vatAccIds){
   try {
     LogControl.push('updateBillingAddressandPhoneinZuora', CLASSNAME); 
     List<Account> vatUpdatedAccountIds = new List<Account>([SELECT Id,Phone,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,(SELECT Id,Zuora__Zuora_Id__c,Zuora__BillToId__c, Zuora__SoldToId__c FROM R00N40000001kyLcEAI) FROM Account WHERE Id IN :vatAccIds] );
     Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('ZuoraUpdatePhoneandorBillingAddressTriggerHandler');
     for (Account acc : vatUpdatedAccountIds ){
       for (Zuora__CustomerAccount__c zAcc : acc.R00N40000001kyLcEAI){
            //clean up billing street format to fit on one line
            acc.BillingStreet = acc.BillingStreet.replace('\r\n', ' ');
            acc.BillingStreet = acc.BillingStreet.replace('\n', ' ');
            acc.BillingStreet = acc.BillingStreet.replace('\r', ' ');
            ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Contact', new Map<String,Object> {'Id'=>zAcc.Zuora__BillToId__c,'WorkPhone'=>acc.Phone,'City'=>acc.BillingCity,'Country'=>acc.BillingCountry, 'PostalCode'=>acc.BillingPostalCode, 'State'=>acc.BillingState, 'Address1'=>acc.BillingStreet});
            ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Contact', new Map<String,Object> {'Id'=>zAcc.Zuora__SoldToId__c,'WorkPhone'=>acc.Phone,'City'=>acc.BillingCity,'Country'=>acc.BillingCountry, 'PostalCode'=>acc.BillingPostalCode, 'State'=>acc.BillingState, 'Address1'=>acc.BillingStreet});
          
        }
      }      
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
 }  
  /**
   * @description:When vat number updated on the Accounts, should also be updated on the Zuora
   * 2017-01-12 Veni Korapaty (ZuoraUpdateVatNumberTriggerHandler.afterUpdate)
   * 2019-06-29 Bob Lin     updated to accomodate Account Name as well
   * @param: List of trigger new accounts
   * @param: List of trigger old accounts
   **/
  public static void getVatAndNameUpdatedAccountIDs(List<Account> triggerNew, List<Account> triggerOld){
    try {
      LogControl.push('getVatAndNameUpdatedAccountIDs', CLASSNAME); 
      Set<Id> vatChangedAccountIds = new Set<Id>();        
      for( Integer i = 0; i < triggerNew.size(); i++){
        Account newZAcc = (Account)triggerNew[i];
        Account oldZAcc = (Account)triggerOld[i];
        if( newZAcc.VAT_Number__c!= oldZAcc.VAT_Number__c ||
            newZAcc.Name != oldZAcc.Name){
          vatChangedAccountIds.add(newZAcc.id );
        }
      }   
      // added empty check - Yong Kan@2017.03.09
      if(vatChangedAccountIds.size()>0) updateVatAndNameNumberInZuora(vatChangedAccountIds);        
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }     

  /**
   * @description: When vat number updated on the Accounts, should also be updated on the Zuora
   *   Invoke by getVatUpdatedAccountIDs
   *
   * @param: List of Account IDs
   **/
   @future(Callout=true)
   public static void updateVatAndNameNumberInZuora(Set<ID> vatAccIds){
   try {
     LogControl.push('updateVatAndNameNumberInZuora', CLASSNAME); 
     List<Account> vatUpdatedAccountIds = new List<Account>([SELECT Id,Name,VAT_Number__c,TaxExemptStatus__c,(SELECT Id,Name,Zuora__Zuora_Id__c FROM R00N40000001kyLcEAI) FROM Account WHERE Id IN :vatAccIds] );
     Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('ZuoraUpdateVatNumberTriggerHandler');
     Zuora.zObject zObject;
     if( !Test.isRunningTest()) zObject = new Zuora.zObject('Account'); 
     for (Account acc : vatUpdatedAccountIds ){
       for (Zuora__CustomerAccount__c zAcc : acc.R00N40000001kyLcEAI){
          if(String.isBlank(acc.VAT_Number__c ) && !Test.isRunningTest()){                     
            zObject.setValue('fieldsToNull', acc.VAT_Number__c); 
            ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zAcc.Zuora__Zuora_Id__c,'Name'=>acc.Name,'VAT_Number__c'=>zObject,'TaxExemptCertificateID'=>zObject, 'TaxExemptStatus'=>acc.TaxExemptStatus__c});               
          }else{
            ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zAcc.Zuora__Zuora_Id__c,'Name'=>acc.Name,'VAT_Number__c'=>acc.VAT_Number__c,'TaxExemptCertificateID'=>acc.VAT_Number__c, 'TaxExemptStatus'=>acc.TaxExemptStatus__c});
          } 
        }
      }       
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
 }       
    
  /**
   * @description: Set SyncDateTime to null if the user updating the record is not in the skipUserSet
   * 25/9/2017 Rani Thumma (PopulateLocalCRMFieldsOnAccount)
   * @param: List of new trigger Account
   * @param: map of old trigger Account
   **/    
  public static void updateSyncDateTime(List<Account> accs, Map<Id, Account> oldAccountsMap){
    try{
      LogControl.push('updateSyncDateTime', CLASSNAME); 
      //18 digit user ids are added in the SPPDataSyncSkipUsers label, some of them are - Eloqua interation user, Inside sales, Informatica UserAccount
      List<String> skipUsers = Label.SPPDataSyncSkipUsers.split(',');
      Set<String> skipUserSet = new Set<String>();
      skipUserSet.addAll(skipUsers);
      for(Account a :accs){
        //Set SyncDateTime to null if the user updating the record is not in the skipUserSet
        if((oldAccountsMap != null && oldAccountsMap.get(a.Id)!= null && a.SyncDateTime__c == oldAccountsMap.get(a.Id).SyncDateTime__c)
                    && (skipUserSet != null && !skipUserSet.contains(UserInfo.getUserId())) ){
          a.SyncDateTime__c = null;
        }
      }
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }
  /**
   * @description: update quote owner. If the previous owner of the account is Sage Foundation, then set the Owner of the quote to Graeme Houghton
   *  (accountTriggerHandler.onAfterUpdate)
   * @param: list of new trigger accounts
   * @param: list of old trigger accounts
   * @param: map of new triggier account
   **/    
  public static void updateZquQuoteOwner(List<Account> triggerNew, List<Account> triggerOld, Map<Id, Account> triggerNewMap){
    try {
      LogControl.push('updateZquQuoteOwner', CLASSNAME);  
      List<zqu__Quote__c> listzqu_Quote = new List<zqu__Quote__c>();
      Map<String, User> mapStringUser = new Map<String, User>();
      Set<Id> setIdtriggerOld = new Set<Id>();        
      //get the account ids of the updated records
      for(Account accnt: triggerOld){
            setIdtriggerOld.add(accnt.Id);
      }        
      //get the user records of Graeme Houghton and Sage Foundation
      for(User usr: [SELECT FirstName, Id, LastName FROM User WHERE (FirstName =: 'Graeme' AND LastName =: 'Houghton') OR (FirstName =: 'Sage' AND LastName =: 'Foundation')]){
         mapStringUser.put(usr.FirstName + usr.LastName, usr);
      }       
      //get the related quotes of the accounts
      for(zqu__Quote__c zqu_Quote: [SELECT Id, OwnerId, zqu__Account__c FROM zqu__Quote__c WHERE zqu__Account__c IN: setIdtriggerOld]){
        //if the previous owner of the account is Sage Foundation, then set the Owner of the quote to Graeme Houghton
        if(triggerNewMap.get(zqu_Quote.zqu__Account__c).OwnerId == mapStringUser.get('SageFoundation').Id){
           zqu_Quote.Id = zqu_Quote.Id;
           zqu_Quote.OwnerId = mapStringUser.get('GraemeHoughton').Id;
           listzqu_Quote.add(zqu_Quote);
        }
      }
      update listzqu_Quote;
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }
  /**
   * @description: update partner old tier field in before update event
   * 3/7/2018 Yue Lu (accountTriggerHandler)
   * @param: List of new trigger accounts
   * @param: map of old trigger account
   **/    
  public static void updatePartnerOldTier(List<Account> listNewAccount,Map<Id, Account> mapOldAccount){
    try {
      LogControl.push('updatePartnerOldTier', CLASSNAME);            
      for(Account a: listNewAccount){            
        Account oldAccount = mapOldAccount.get(a.Id);
        a.Partner_Old_Tier__c = oldAccount.Accountant_Partner_Tier__c != a.Accountant_Partner_Tier__c? oldAccount.Accountant_Partner_Tier__c : 
                                oldAccount.Reseller_Partner_Tier__c != a.Reseller_Partner_Tier__c? oldAccount.Reseller_Partner_Tier__c :
                                oldAccount.SI_Partner_Tier__c != a.SI_Partner_Tier__c? oldAccount.SI_Partner_Tier__c: oldAccount.Partner_Old_Tier__c;            
        if(a.Partner_Old_Tier__c != null){
          //if partner tier is Terminated or Prospect then no need to store the value in the partner old tier
          if(Label.Invalid_Tier.contains(a.Partner_Old_Tier__c)){                    
            a.Partner_Old_Tier__c = null;
          }
        }            
        //04/02/2018 update tier change date if there is a change in tier
        if(a.Partner_Old_Tier__c != oldAccount.Partner_Old_Tier__c){                
          a.Tier_Changed_Date__c = Date.today();                
        }            
      }    
     } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  } 
  /**
   * @description: Get Accounts with Billing Accounts and Subscription Master
   * (AccountMergerHelper)
   * @param: map of trigger old account
   **/   
   public static void getBillingAccountsAndSubscriptionMaster(Map<ID,Account> oldAccMap) {
   try {
     LogControl.push('getBillingAccountsAndSubscriptionMaster', CLASSNAME);  
     List<Account> accwithBA  = [SELECT Id, (SELECT Id FROM R00N40000001kyLcEAI__r), (SELECT Id FROM Subscription_Master__r) FROM Account WHERE Id IN : oldAccMap.keySet()];
     for (Account a : accwithBA){
       // Do not delete accounts with billing accounts and subscription master          
        if((a.R00N40000001kyLcEAI__r!=null &&a.R00N40000001kyLcEAI__r.size() >0) || 
           (a.Subscription_Master__r!=null&&a.Subscription_Master__r.size() >0)){    
            Account actualAcc = oldAccMap.get(a.Id); 
            actualAcc.addError(System.Label.CC360_Merge_Error);
        }
     }           
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }
  /**
   * @description: Update number of contacts for account
   * (AccountMergerHelper)
   * @param: List trigger new accounts
   * @param
   **/
/*  public static void populateNumAccountContacts(List<Account> accounts){
  try {
    LogControl.push('populateNumAccountContacts', CLASSNAME);  
    Map<id,Account> accountMap = new Map<Id,Account>();
    for(Account acc: accounts){
      accountMap.put(acc.Id,acc);
    }
    Map<Id,Account> updateAccounts = new Map<Id,Account>([select Id, Number_of_contacts__c, (select Id from Contacts) from Account where Id IN :accountMap.keySet()]);
    for(Id accId:updateAccounts.keySet()){
      if((updateAccounts.get(accId)).Contacts != null){
        (accountMap.get(accId)).Number_of_contacts__c = (updateAccounts.get(accId)).Contacts.size();
      }
    }
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }    
*/
    
       
    /**
* @description: Update foundation fields on related contacts 
* 07/12/2020 Dharani Chennupati
* EAD-1564
*/
    public static void updateFoundationFieldsOnContact(List<Account> triggerNew, List<Account> triggerOld){
    try {
      LogControl.push('updateFoundationFieldsOnContact', CLASSNAME); 
      Map<Id,Account> changedIdsToAccount = new Map<Id,Account>();        
      for( Integer i = 0; i < triggerNew.size(); i++){
        Account newAcc = (Account)triggerNew[i];
        Account oldAcc = (Account)triggerOld[i];
        if( newAcc.Foundation_Customer__c!= oldAcc.Foundation_Customer__c || newAcc.Eligibility_Start_Dateone__c!= oldAcc.Eligibility_Start_Dateone__c
          || newAcc.Eligibility_Expiration_Date__c!= oldAcc.Eligibility_Expiration_Date__c || newAcc.Sage_Foundation_Customer__c!= oldAcc.Sage_Foundation_Customer__c
          || newAcc.Military_Veteran_Owned_Business__c!= oldAcc.Military_Veteran_Owned_Business__c || newAcc.Grant_Recipient__c!= oldAcc.Grant_Recipient__c
          || newAcc.Product_Recipient__c!= oldAcc.Product_Recipient__c || newAcc.Volunteer_Recipient__c!= oldAcc.Volunteer_Recipient__c
          || newAcc.FreeTrial__c!= oldAcc.FreeTrial__c ){
          changedIdsToAccount.put(newAcc.Id,newAcc);
        }
      }   
      if(changedIdsToAccount!=null && !(changedIdsToAccount.isEmpty())) setupdateFoundationFieldsOnContact(changedIdsToAccount);        
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }        
  }
    
    public static void setupdateFoundationFieldsOnContact(Map<Id,Account> idToAccount){
        try {
            LogControl.push('setupdateFoundationFieldsOnContact', CLASSNAME);              
            List<Contact> contactToUpdate = new  List<Contact>();
            contactToUpdate = [SELECT ID, AccountId,Foundation_Customer__c,Eligibility_Start_Dateone__c,
                               Eligibility_Expiration_Date__c,Sage_Foundation_Customer__c,
                               Military_Veteran_Owned_Business__c,Grant_Recipient__c,Product_Recipient__c,
                               Volunteer_Recipient__c,FreeTrial__c FROM Contact WHERE AccountId IN:idToAccount.keySet()];
            if(!contactToUpdate.isEmpty()){
                for (Contact con: contactToUpdate)
                {                    
                    Account acc=idToAccount.get(con.AccountId);
                    if(acc!=null){
                        con.Foundation_Customer__c=acc.Foundation_Customer__c;
                        con.Eligibility_Start_Dateone__c=acc.Eligibility_Start_Dateone__c;
                        con.Eligibility_Expiration_Date__c=acc.Eligibility_Expiration_Date__c;
                        con.Sage_Foundation_Customer__c=acc.Sage_Foundation_Customer__c;
                        con.Military_Veteran_Owned_Business__c=acc.Military_Veteran_Owned_Business__c;
                        con.Grant_Recipient__c=acc.Grant_Recipient__c;
                        con.Product_Recipient__c=acc.Product_Recipient__c;
                        con.Volunteer_Recipient__c=acc.Volunteer_Recipient__c;
                        con.FreeTrial__c=acc.FreeTrial__c;
                    }
                }
            }
            update contactToUpdate;
        }           
        catch (Exception e) { 
            LogControl.debugException(e); 
        } finally { 
            LogControl.pop(); 
        }
    }
    
    /**
   * @description: Populate Eligibility Start Date when Foundation Eligibility is set to Approved
   * 14/10/2020 Dharani Chennupati
   * @param: List of new trigger Account
   * @param: map of old trigger Account
   **/  
   public static void UpdateStartDateBasedOnFoundationEligibility(List<Account> accounts, Map<Id, Account> oldAccounts){
        for(Account account:accounts){
            if(oldAccounts.containsKey(account.id)){
                Date oldDate=account.Eligibility_Start_Dateone__c;
                String eligibility=account.Foundation_Customer__c;
                String oldEligibility=oldAccounts.get(account.Id).Foundation_Customer__c;
                if(oldDate==null&&eligibility=='Approved'){
                    account.Eligibility_Start_Dateone__c=System.today();  
                }
                else if(eligibility==oldEligibility){
                    account.Eligibility_Start_Dateone__c=oldDate;
                }
                else if((eligibility!=oldEligibility)&&eligibility=='Approved'){
                    account.Eligibility_Start_Dateone__c=System.today();
                }
                else if((eligibility=='Expired')
                        &&(eligibility!=oldEligibility)&&oldEligibility=='Approved'){
                    account.Eligibility_Start_Dateone__c=oldDate;
                }
                else if(oldDate!=null&&(eligibility=='Rejected')
                        &&(eligibility!=oldEligibility)&&oldEligibility=='Expired'){
                     account.Eligibility_Start_Dateone__c=oldDate;
                }
                else{
                    account.Eligibility_Start_Dateone__c=null;
                }                
            }
            else{
                Date oldDate=account.Eligibility_Start_Dateone__c;
                String eligibility=account.Foundation_Customer__c;
                if((oldDate==null||oldDate!=null)&&(eligibility=='Approved')){
                    account.Eligibility_Start_Dateone__c=System.today();
                }
                else{
                    account.Eligibility_Start_Dateone__c=null;
                }
            }            
        }
    }


    /**
   * @description method to update the Account's Sales Office  Country is changed.
   *
   * @param newAccounts new trigger Account
   * @param oldAccounts old trigger Accounts
   * If there are two address fields, BillingCountry and BillingCountryCode,
   * when State and Country picklist feature is enabled,
   * we will get the updated values for BillingCountryCode and not for BillingCountry.
   */
    public static void updateSalesOffice(List<Account> newAccounts, Map<Id, Account> oldAccounts) {

        try {
            LogControl.push('updateSalesOffice', CLASSNAME);
            //building a map of country and its respective sales office
            Map<String, SalesOffice__mdt> soMap = new Map<String, SalesOffice__mdt>();
            for (SalesOffice__mdt mdt : Settings_DAC.getSalesOffices()) {
                soMap.put(mdt.Country__c, mdt);
                soMap.put(mdt.CountryCode__c, mdt);
            }
            for (Account accRecord : newaccounts) {
                if (oldAccounts.containsKey(accRecord.id)) {
                    if (String.isNotBlank(accRecord.BillingCountryCode)
                            && (!accRecord.BillingCountryCode.equals(oldAccounts.get(accRecord.id).BillingCountryCode))
                            ) {

                        if (accRecord.BillingCountryCode != null &&
                                soMap != null &&
                                soMap.containsKey(accRecord.BillingCountryCode)
                                ) {
                            accRecord.Sales_Office__c = soMap.get(accRecord.BillingCountryCode).SalesOffice__c;
                        } else {
                            accRecord.Sales_Office__c = 'None';
                        }
                    }
                } else {
                    if (((String.isNotBlank(accRecord.BillingCountryCode) || String.isNotBlank(accRecord.BillingCountry)) &&
                            (soMap != null && (soMap.containsKey(accRecord.BillingCountryCode)
                                    || soMap.containsKey(accRecord.BillingCountry))))) {
                        if (accRecord.BillingCountry != null) {
                            accRecord.Sales_Office__c = soMap.get(accRecord.BillingCountry).SalesOffice__c;
                        } else {
                            accRecord.Sales_Office__c = soMap.get(accRecord.BillingCountryCode).SalesOffice__c;
                        }
                    } else {
                        accRecord.Sales_Office__c = 'None';
                    }
                }
            }
        } catch (Exception e) {
            LogControl.debugException(e);
        } finally {
            LogControl.pop();
        }
    }

           
/**
* @description: Align NonProfitOrganisation fields on related contacts with Account
* 02/25/2021 Betty Phan EAD-2114
*/
public static void updateNonProfitOrganisationContacts(List<Account> newAccounts,List<Account> oldAccounts){  
    try {  
        LogControl.push('updateNonProfitOrganisationContacts', CLASSNAME);
        Map<Id,Account> accIds = new Map<Id,Account>(); 
        List<SObject> updateList = new List<SObject>();
        for( Integer i = 0; i < newAccounts.size(); i++){    
            Account newAcc = (Account)newAccounts[i];
            Account oldAcc = (Account)oldAccounts[i];    
            if ( newAcc.NonProfitOrganisation__c != oldAcc.NonProfitOrganisation__c) {        
                accIds.put(newAcc.Id, newAcc);
            }    
        }
        if ((accIds != null) && (!(accIds.isEmpty()))){ setNonProfitOnContacts(accIds);}
    } catch (Exception e) { LogControl.debugException(e); 
    } finally { LogControl.pop(); }            
} 

private static void setNonProfitOnContacts(Map<Id,Account> accIds){
  try{   
       LogControl.push('setNonProfitOnContacts', CLASSNAME);
       List<Contact> contacts = new  List<Contact>();                    
       contacts = [SELECT ID, AccountId, NonProfitOrganisation__c FROM Contact WHERE AccountId IN:accIds.keySet()];
       if(!contacts.isEmpty()){
         for (Contact con: contacts){         
           Account acc=accIds.get(con.AccountId);
             if(acc!=null){ con.NonProfitOrganisation__c = acc.NonProfitOrganisation__c;} 
         } 
       }   
       update contacts;              
  } catch (Exception e) { LogControl.debugException(e); 
  } finally { LogControl.pop(); }    
}    
    

// 5 May 2021 Dharani
// Update NonProfitOrganisation on Account based on Foundation Eligibility
// EAD-2262
public static void updateNonProfitOrganisation(List<Account> accounts, Map<Id, Account> oldAccounts){
    try{
        LogControl.push('UpdateNonProfitOrganisation',CLASSNAME);
        for(Account account:accounts){
            if(oldAccounts.containsKey(account.id)){
                if( account.NonProfitOrganisation__c == false && account.Foundation_Customer__c=='Approved'){
                        account.NonProfitOrganisation__c=true;  
                    }  
            }
            else{
                 if(account.Foundation_Customer__c=='Approved'){
                    account.NonProfitOrganisation__c=true;
            }            
        }
    }
    }
    catch (Exception e) { 
        LogControl.debugException(e); 
        
    } finally { 
        LogControl.pop(); 
    }
} 

    //Added this method as part of EAD-2363
    public static void updateRegionOnOpportunity(List<Account> newAccList){
    
        Map<String,String> crMap = new Map<String,String>();
        List<CountryMapping__mdt> clList = [select Sage_Region__c ,CountryName__c from CountryMapping__mdt];
        for (CountryMapping__mdt cl : clList) {
            crMap.put(cl.CountryName__c,cl.Sage_Region__c);
        }
        for(Account acc: newAccList) {
            if(acc.BillingCountry!=null) {
                acc.Sage_Region__c=(crMap.get(acc.BillingCountry)!=null)?crMap.get(acc.BillingCountry):'Other'; 
            }
        }
    }

      
}