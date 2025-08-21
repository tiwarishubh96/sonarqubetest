/**********************************************************************
 Name:  SPPCommissionTriggerTest

======================================================
======================================================
Purpose: Test class to test SPPCommissionInvoiceTrigger
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
1.0        	Lu               	10/20/2017			Initial Development
***********************************************************************/

@isTest
public class SPPCommissionInvoiceTriggerTest {
    
    Public static  TestMethod void  createCommissionSharingWithoutParentAccountTest() {
		
        Integer max = 10;
        SPPTestData.CreateAccountAndContactForPartnerType();
        Account acc = [select id from account limit 1];
        acc.isPartner = true;
        Account parentAcc = CreateParentAccountAndContactForPartnerType();
        Locale__c loc = createLocale();
        system.debug('loc::'+loc);
        parentAcc.IsPartner = true;
        /*
        parentAcc.Locale__c = loc.id;
        parentAcc.Locale__r.name = loc.name;
        parentAcc.Locale__r.CurrencyIsoCode = loc.CurrencyIsoCode;
		*/
        update parentAcc;
        acc.ParentId = parentAcc.id;
        update acc;
        List <Account> accountList = new List <Account>();
        List <Account> parentAccList = new List <Account>();
        accountlist.add(acc);
        parentAccList.add(parentAcc);
        
        List <Opportunity> oppList = createOpportunity(max,accountlist);
        List <Zuora__ZInvoice__c> zInvoiceList = SPPTestData.CreateZuoraInv(max, accountlist);
        List<SPP_RR_Invoice__c> sppInvoiceList = createInvoice(max,accountlist);
        
        List<SPP_Commission_Invoice__c> sppCommissionParentList = SPPTestData.createCommissionInvoice(max, parentAccList);
        List<SPP_Commission_Invoice__c> sppCommissionList = SPPTestData.createCommissionInvoice(max, accountList);
        List<SPP_RR_Order__c> sppOrderList = createOrderL(max,sppInvoiceList,oppList,sppCommissionParentList);
        
        User thisUser = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()];
        
        System.runAs(thisUser) {
            
            UserRole r = new UserRole(PortalAccountId = parentAccList[0].Id, PortalType='Partner');
            
            insert r;
            
            SPPCommissionInvoiceTriggerHandler.createCommissionSharing(sppCommissionList);
        }
        
        System.runAs(thisUser) {
            
            UserRole r = new UserRole(PortalAccountId = accountList[0].Id, PortalType='Partner');
            
            insert r;
            
            SPPCommissionInvoiceTriggerHandler.createCommissionSharing(sppCommissionParentList);
        }
                
    }
    
    public static Account CreateParentAccountAndContactForPartnerType()
    {
        Account acc =new Account();
        acc.Name = 'TestAcc1';
        acc.Partner_Accountant__c = true;
        acc.Accountant_Partner_Tier__c = 'Authorized';
        acc.Locale_Billing_CC__c = 'US';
        acc.Company_Registration_Number__c = '12122';
        
        acc.Partner_Account_ID__c = '1212';
        acc.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        acc.Sales_Office__c='Atlanta CBC';
        acc.BillingCity='Austin';
        acc.BillingPostalCode='78666';
        acc.BillingCountry='United States';
        acc.BillingState='Texas';
        acc.BillingStreet='test';
        acc.Phone='1234567890';
        insert acc;
        system.debug('acc: '+acc);
        Contact NewContact = new Contact (
            FirstName = 'Test ',
            LastName = 'Test Last1',
            Language__c = 'English',
            //line changed - waveoc
            AccountId = acc.Id,
            Email = 'xyzmail1@mail.com',
            Legal_Contact__c = true
        );
        system.debug('NewContact before: '+NewContact);
        insert NewContact;
        system.debug('NewContact: '+NewContact);
        return acc;
    }
    
    public static list<Opportunity> createOpportunity(Integer op,List<Account> acc){
        List<Opportunity> opp =new List<Opportunity>();
        //List<Account> accnt =[Select Name,Id from Account where Name='TestAcc0' and Phone='1234567890' limit 1];
        for(Integer i=0;i<Op;i++)
        {
           opp.add(new Opportunity( Name='TestOpportunity'+i,Account=acc[0],Referring_Partner_Account__c = acc[0].id,Type='New Business',
                                   CloseDate=Date.today(),StageName=Label.Opportunity_Sales_Stages_Stage1));
        }
        insert opp;
        return opp;
    }
    
    public static List<SPP_RR_Invoice__c> createInvoice(Integer temp, List<Account> acc)      
    {
        List<SPP_RR_Invoice__c> inv=new List<SPP_RR_Invoice__c>();
        //List<Account> accnt =[Select Name,Id from Account where Name='TestAcc0' and Phone='1234567890' Limit 5];
        Zuora__ZInvoice__c invoice = [Select Name,Id from Zuora__ZInvoice__c limit 1];
        for(Integer m=0;m< temp ;m++)
        {
            inv.add(new SPP_RR_Invoice__c(Account__c=acc[0].Id,Balance__c=0,Credit_Balance__c=0,Inv_Date__c=Date.today(),Payment_Amount__c=10,
                                          Adjustment_Amount__c=0,Refunded_Amount__c=10,Tax_Amount__c=0,Tax_Exempt_Amount__c=0,Total_Amount__c=10, Zuora_Invoice__c =invoice.Id));
        }
        insert inv;
        return inv;
    }
    
    public static List<SPP_RR_Order__c> createOrderL(Integer co, List<SPP_RR_Invoice__c> sppInvList, List<Opportunity> oppList,
                                                    List<SPP_Commission_Invoice__c> sppComList)     
    {
        
        List<SPP_RR_Order__c> ord=new List<SPP_RR_Order__c>();
        for(Integer z=0;z<co;z++)
        {
            ord.add(new SPP_RR_Order__c(Invoiced__c=false,Opportunity__c=oppList[0].id,Invoice__c=sppInvList[0].id,SPP_AP_Commission__c=sppComList[0].id));
        }
        insert ord;
        return ord;
    }
    
    public static Locale__c createLocale(){
        
        Locale__c loc = new Locale__c();
        
        loc.name = 'en_US';
        
        loc.CurrencyIsoCode = 'USD';
        
        loc.LanguageLocaleKey__c = 'en_US';
        
        insert loc;
        
        return loc;
        
    }
    
}