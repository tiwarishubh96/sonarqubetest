/*-------------------------------------------------------------
Author:         Lakshman
Date :          08/18/2017
Company:       Docmation LLC
Description:   Test Class for test data preparation for other test class
Inputs:        None
History
<Date>            <Authors Name>                <Brief Description of Change>

------------------------------------------------------------*/
@isTest
public  class SPPTestData 
{
    static List<Account> acc {get;set;}
    static List<Opportunity> opp {get;set;}
    static List<SPP_RR_Invoice__c> inv{get;set;}
    static  List<SPP_RR_Order__c> ord {get;set;}
    static List<SPP_RR_Order_Detail__c> ordDetail {get;set;}
    static List<SPP_Commission_Invoice__c> comInv {get;set;}
    static List<Zuora__ZInvoice__c> zInv {get;set;}
    static List<Zuora__ZInvoice__c> zInvlist {get;set;}
    static List<zqu__Quote__c> zQuote{get;set;}
    static List<zqu__QuoteCharge__c> zQuoteCharge{get;set;}
    static List<zqu__QuoteRatePlanCharge__c> zQuoteRatePlanCharge{get;set;}
    static List<zqu__QuoteRatePlan__c> zQuoteRatePlan{get;set;}
    static List<zqu__QuoteAmendment__c> zQuoteAmendment{get;set;}
    static List<Product2> zProduct{get;set;}
    static List<Zuora__Subscription__c> zSubscription{get;set;}
    static List<Zuora__SubscriptionProductCharge__c> zSubscriptionCharge {get;set;}
    static List<Subscription_Product_Detail__c> zSubscriptionProdDetail{get;set;}
    //Lu 09/25/2017
    static List<Lead> leadList {get;set;}
    static List<Success_Plan__c> spList {get;set;}
    //Lu 09/25/2017
    public static void createLead(Integer num){
        leadList = new List<Lead>();
        for(Integer i=0; i<num; i++){
            //leadList.add)();
        }
        System.debug('Lead'+leadList);
        insert leadList;
    }
    
    public static void creatAccount(Integer a)    
    {
        acc=new List<Account>();
        for(Integer t=0; t< a ;t++)
        {
            acc.add(new Account(Name='TestAcc'+t,BillingStreet='Test City'+t,BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                                Phone='1234567890',Type='Analyst',BillingPostalCode='30092'));
        }
        System.debug('Accounts'+ acc);
        insert acc;
        
    }
    public static List<Account> forParentcreatAccount(Integer a)    
    {
        acc=new List<Account>();
        for(Integer t=0; t< a ;t++)
        {
            acc.add(new Account(Name='TestAcc'+t,BillingStreet='Test City'+t,BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',BillingPostalCode='30092',Sales_Office__c='Atlanta CBC',
                                Phone='1234567890',Type='Analyst'));
        }
        System.debug('Accounts'+ acc);
        insert acc;
        return acc;
        
    }
    public static void creatAccountwithParent(Integer af,List<Account> accnt)     
    {
        for(Integer wt=0; wt< af ;wt++)
        {
            
            acc.add(new Account(Name='TestAccParent'+wt,BillingStreet='Test City'+wt,BillingCity='Atlanta',BillingCountry='United States',BillingState='Georgia',Sales_Office__c='Atlanta CBC',
                                Parent=accnt[0],Phone='1234567890',Type='Analyst'));
        }
        insert acc;
        
        system.debug('>>>>'+acc);
    }
    
    public  Static List<Opportunity> createOpportunity(Integer Op)     
    {
        opp =new List<Opportunity>();
        List<Account> accnt =[Select Name,Id from Account where Name='TestAcc0' and Phone='1234567890' limit 1];
        
        system.debug('>>>>'+accnt );
        
        //1084 Added Why We Lost for Validation
        for(Integer i=0;i<Op;i++)
        {
          opp.add(new Opportunity( Name='TestOpportunity'+i,Account=accnt[0],Type='New Business',CloseDate=Date.today(),StageName='Closed Won',ForecastCategoryName='Closed',Why_We_Lost__c='No reason specified',Lead_Source__c='Marketing'));         
        }
        
        System.debug('OppsBefore'+ opp);
        insert opp;
        System.debug('Opps'+ opp);
        return opp;
    }
    
    public static List<SPP_RR_Invoice__c> createInvoice(Integer temp)      
    {
        inv=new List<SPP_RR_Invoice__c>();
        
        List<Account> accnt =[Select Name,Id from Account where Name='TestAcc0' and Phone='1234567890' Limit 5];
        Zuora__ZInvoice__c invoice = [Select Name,Id from Zuora__ZInvoice__c limit 1];
        
        for(Integer m=0;m< temp ;m++)
        {
            inv.add(new SPP_RR_Invoice__c(Account__c=accnt[0].Id,Balance__c=0,Credit_Balance__c=0,Inv_Date__c=Date.today(),Payment_Amount__c=10,
                                          Adjustment_Amount__c=0,Refunded_Amount__c=10,Tax_Amount__c=0,Tax_Exempt_Amount__c=0,Total_Amount__c=10, Zuora_Invoice__c =invoice.Id));
        }
        
        insert inv;
        
        return inv;
    }
    
    public static void createOrder(Integer co)     
    {
        
        ord=new List<SPP_RR_Order__c>();
        
        for(Integer z=0;z<co;z++)
        {
            ord.add(new SPP_RR_Order__c(Invoiced__c=false,Opportunity__c=opp[0].id,Invoice__c=inv[0].id));
        }
        
        insert ord;
    }
    public static List<SPP_RR_Order__c> createOrderL(Integer co)     
    {
        
        ord=new List<SPP_RR_Order__c>();
        for(Integer z=0;z<co;z++)
        {
            ord.add(new SPP_RR_Order__c(Invoiced__c=false,Opportunity__c=opp[0].id,Invoice__c=inv[0].id,SPP_AP_Commission__c=null));
        }
        insert ord;
        return ord;
    }
    public  static List<SPP_RR_Order_Detail__c> createOrderDetail(Integer cod)     
    {
        
        ordDetail=new List<SPP_RR_Order_Detail__c>();
        
        for(Integer q=0;q<cod;q++)
        {
            ordDetail.add(new SPP_RR_Order_Detail__c(Product__c= 'Sage Live',Licenses__c=2, Original_Licenses__c=2,X1stLine_Support__c='',Charge_Type__c='',Contract_Year__c='1',Invoice__c=inv[0].id,MDF_Eligible__c='No',Opportunity__c=opp[0].Id,Order__c=ord[0].id,Commission__c=20,Prod_RP_Charge__c=100,Invoice_Line_Adjustment__c=1.00));            
        }
        
        insert ordDetail;
        
        return ordDetail;
    }
    public  static List<SPP_Commission_Invoice__c> createCommissionInvoice(Integer ccI,List<Account> a)
    {
        comInv=new List<SPP_Commission_Invoice__c>();
        for(Integer s=0;s<ccI;s++){
            comInv.add(new SPP_Commission_Invoice__c(Amount_Paid__c=0,AP_Comission__c=0,Paid__c='No',Partner_Account__c=a[0].id,Partner_Name__c='Test Name'));
            
        }
        insert comInv;
        return comInv;
    }
    
    ///////Remove it and use the other//////////////
    public static List<Zuora__ZInvoice__c> CreateZuoraInvoice(Integer ccZ)
    {
        zInv=new List<Zuora__ZInvoice__c>();
        for(Integer v=0;v<ccZ;v++)
        {
            zInv.add(new Zuora__ZInvoice__c(Zuora__Account__c=acc[0].Id,Zuora__AdjustmentAmount__c=0,Zuora__Balance2__c=0,Zuora__InvoiceDate__c=Date.today(),Zuora__PaymentAmount__c=0, Zuora__TaxAmount__c=0,Zuora__TaxExemptAmount__c=0,Zuora__TotalAmount__c=0,Zuora__Zuora_Id__c='Test001'+v));
        }
        insert zInv;
        return zInv;
    }
    ///////////////////////////////////////////////////
    public static List<Zuora__ZInvoice__c> CreateZuoraInv(Integer ccZ,List<Account> acclist)
    {
        zInvlist=new List<Zuora__ZInvoice__c>();
        for(Integer v=0;v<ccZ;v++)
        {
            zInvlist.add(new Zuora__ZInvoice__c(Zuora__Account__c=acclist[0].Id,Zuora__AdjustmentAmount__c=0,Zuora__Balance2__c=0,Zuora__InvoiceDate__c=Date.today(),Zuora__PaymentAmount__c=0, Zuora__TaxAmount__c=0,Zuora__TaxExemptAmount__c=0,Zuora__TotalAmount__c=0,Zuora__Zuora_Id__c='Test001'+v));
        }
        insert zInvlist;
        return zInvlist;
    }
    
    public static List<zqu__Quote__c> CreateZuoraQuote(Integer x,Account accoun,Opportunity Oppt)
    {
        zQuote=new List<zqu__Quote__c>();
        for(Integer zq=0;zq<x;zq++)
        {
            zQuote.add(new zqu__Quote__c(zqu__Account__c=accoun.Id,zqu__InvoiceDate__c=Date.today(),zqu__Opportunity__c=Oppt.Id,zqu__ExistSubscriptionID__c='qwerty11'+zq,zqu__ZuoraSubscriptionID__c='qwerty11'+zq));                         
        }
        insert zQuote;
        return zQuote;
    }

    public static List<zqu__QuoteAmendment__c> CreateZuoraQuoteAmendment(Integer t,List<zqu__Quote__c> zQc)
    {
        zQuoteAmendment=new List<zqu__QuoteAmendment__c>();
        for(integer zChar=0;zChar<t;zChar++)
        {
            zQuoteAmendment.add(new zqu__QuoteAmendment__c(zqu__Quote__c=zQc[0].id,zqu__Type__c='UpdateProduct')); 
        }
        insert zQuoteAmendment;
        return zQuoteAmendment;
    }
    public static List<zqu__QuoteRatePlan__c> CreateZuoraQuoteRatePlan(Integer rt,List<zqu__QuoteAmendment__c> zQA,List<zqu__Quote__c> zQco)
    {
        zQuoteRatePlan=new List<zqu__QuoteRatePlan__c>();
        for(integer zR=0;zR<rt;zR++)
        {
            zQuoteRatePlan.add(new zqu__QuoteRatePlan__c(zqu__QuoteAmendment__c=zQA[0].id,zqu__AmendmentType__c='UpdateProduct'));
        }
        insert zQuoteRatePlan;
        return zQuoteRatePlan;
    }
    public static List<zqu__QuoteRatePlanCharge__c> CreateZuoraQuoteRatePlanCharge(Integer rtc,List<zqu__QuoteRatePlan__c> zQRP)
    {
        zQuoteRatePlanCharge=new List<zqu__QuoteRatePlanCharge__c>();
        for(integer zRC=0;zRC<rtc;zRC++)
        {
            zQuoteRatePlanCharge.add(new zqu__QuoteRatePlanCharge__c( zqu__QuoteRatePlan__c=zQRP[0].id,zqu__Description__c='Test'));
        }
        insert zQuoteRatePlanCharge;
        return zQuoteRatePlanCharge;
    }
    public static List<Product2> CreateZuoraProduct(Integer p)
    {
        zProduct=new List<Product2>();
        for(Integer tem=0;tem<P;tem++)
        {
            //zProduct.add(new Product2(Name='TestProduct'+tem,Zuora__EffectiveEndDate__c=Date.today(),Zuora__Description__c='Test Description'));  
            zProduct.add(new Product2(Name='TestProduct'+tem));  
        }
        insert zProduct;
        return zProduct;
    }
    public static List<Zuora__Subscription__c> CreateZuoraSubscription(Integer p,List<Account> a)
    {
        zSubscription=new List<Zuora__Subscription__c>();
        for(Integer tem=0;tem<P;tem++)
        {
            zSubscription.add(new Zuora__Subscription__c(Name='TestAccSub'+tem,Zuora__Account__c=a[0].id,Zuora__SubscriptionStartDate__c=date.today(),Zuora__TermEndDate__c=Date.today()));  
        }
        insert zSubscription;
        return zSubscription;
    }
    public static List<Zuora__SubscriptionProductCharge__c> CreateSubscriptionProductCharge(Integer p,List<Account> a,List<Product2> prod,List<Zuora__Subscription__c> sub,Integer tempint)
    {
        zSubscriptionCharge=new List<Zuora__SubscriptionProductCharge__c>();
        if(tempint==0)
        {
            for(Integer tem=0;tem<P;tem++)
            {
                
                //zSubscriptionCharge.add(new Zuora__SubscriptionProductCharge__c(Name='TestAccSubcharge'+tem,Zuora__Account__c=a[0].id,Product2=prod[0].id,   Zuora__Subscription__c=sub[0].id,Zuora__ProductName__c='Test Product',Zuora__ChargeNumber__c='test'));  
                zSubscriptionCharge.add(new Zuora__SubscriptionProductCharge__c(Name='TestAccSubcharge'+tem,Zuora__Account__c=a[0].id,   Zuora__Subscription__c=sub[0].id,Zuora__ProductName__c='Test Product',Zuora__ChargeNumber__c='test'));  
            }
        }
        else{
            for(Integer tem=0;tem<P;tem++)
            {
                
                //zSubscriptionCharge.add(new Zuora__SubscriptionProductCharge__c(Name='TestAccSubcharge'+tem,Zuora__Account__c=a[0].id,Product2=prod[0].id,   Zuora__Subscription__c=sub[0].id,Zuora__ChargeNumber__c='test'));  
                zSubscriptionCharge.add(new Zuora__SubscriptionProductCharge__c(Name='TestAccSubcharge'+tem,Zuora__Account__c=a[0].id,   Zuora__Subscription__c=sub[0].id,Zuora__ChargeNumber__c='test'));   
                
            }
        }
        insert zSubscriptionCharge;
        System.debug('Subscription Charge'+zSubscriptionCharge);
        return zSubscriptionCharge;
    }
    public static List<Subscription_Product_Detail__c> CreateSubscriptionDetail(Integer p,List<Account> a)
    {
        zSubscriptionProdDetail=new List<Subscription_Product_Detail__c>();
        List<Subscription_Product_Detail__c> UpdateList=new List<Subscription_Product_Detail__c>();
        for(Integer tem=0;tem<P;tem++)
        {
            zSubscriptionProdDetail.add(new Subscription_Product_Detail__c(Name='TestAccSubcharge'+tem,Account__c=a[0].id,Product_Name__c='Test Product',Rate_Plan_Name__c='Test RatePlan'));  
        }
        insert zSubscriptionProdDetail;
        for(Subscription_Product_Detail__c t:[Select Name,Product_Name__c,Rate_Plan_Name__c from Subscription_Product_Detail__c where Id in: zSubscriptionProdDetail ])
        {
            //System.debug('Test'+t.Unq_Key__c);
            UpdateList.add(t);
        }
        
        update UpdateList;        
        return UpdateList;
    }
    public static void CreateAccountAndContactForPartnerType()
    {
        Account acc =new Account();
        acc.Name = 'TestAcc0';
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
            LastName = 'Test Last',
            Language__c = 'English',
            //line changed - waveoc
            AccountId = acc.Id,
            Email = 'xyzmail@mail.com',
            Legal_Contact__c = true
        );
        system.debug('NewContact before: '+NewContact);
        insert NewContact;
        system.debug('NewContact: '+NewContact);
        
    }
    
    public static void CreateTandCGlobalAndVersions()
    {
        Locale__c loc = CreateLocale();
        Terms_Conditions_Community__c tncc = new Terms_Conditions_Community__c(Document_Type__c='Enrollment Forms', Active__c = true ,Partner_Types__c='Accountant', Partner_Locale__c =loc.id , Partner_Tiers__c='Authorized');
        insert tncc;
        
        Terms_Conditions_Version__c tncv = new Terms_Conditions_Version__c(DocuSign_Bulk_Template_Id__c ='test', Docusign_Template_ID__c ='test1',Active__c = false , Terms_Conditions_Community__c = tncc.Id ,Start_Date_Active__c = Date.today() );
        insert tncv;
        
        Terms_Conditions_Version__c tncv1 = new Terms_Conditions_Version__c(DocuSign_Bulk_Template_Id__c ='test', Docusign_Template_ID__c ='test1',Active__c = true , Terms_Conditions_Community__c = tncc.Id ,Start_Date_Active__c = Date.today());
        insert tncv1;
        Terms_Conditions_Version__c tncv2 = new Terms_Conditions_Version__c(DocuSign_Bulk_Template_Id__c ='test', Docusign_Template_ID__c ='test1',Active__c = true , Terms_Conditions_Community__c = tncc.Id ,Start_Date_Active__c = Date.today() , End_Date_Active__c = Date.today());
        insert tncv2;
        Terms_Conditions_Version__c tncv3 = new Terms_Conditions_Version__c(DocuSign_Bulk_Template_Id__c ='test', Docusign_Template_ID__c ='test1',Active__c = false , Terms_Conditions_Community__c = tncc.Id ,Start_Date_Active__c = Date.today() , End_Date_Active__c = Date.today());
        insert tncv3;   
    }
    
    public static Locale__c CreateLocale()
    {
        Locale__c loc = new Locale__c();
        loc.Country__c = 'US - United States';
        loc.Language__c = 'English';
        loc.Name = 'en_US';
        loc.LanguageLocaleKey__c = 'en_US';
        
        insert loc;
        return loc;
        
    }
    
    //Lu 11/2/2017 to create business plan list for SPPSuccessPlanTriggerHandlerTest
    public static list<Success_Plan__c> createSuccessBusinessPlanList(Integer num, String aID){
        Id recordId = Schema.SObjectType.Success_Plan__c.getRecordTypeInfosByName().get('Partner Business Plan').getRecordTypeId();
        spList = new List<Success_Plan__c>();
        for(integer i=0; i<num; i++){
            spList.add(new Success_Plan__c(name='TestBP'+i, Account__c = aID, RecordTypeId = recordId));
        }
        insert spList;
        return spList;
    }
    
    
    public static List<Account> createAccountAndContactAndOppListForPartnerType(Integer n)
    {
    
        List <Account> accList = new List<Account>();
    
        for (integer i = 0; i < n; i++){
            Account acc =new Account();
            acc.Name = 'TestAcc'+ i;
            acc.Partner_Accountant__c = true;
            acc.Accountant_Partner_Tier__c = 'Authorized';
            acc.Locale_Billing_CC__c = 'US';
            acc.Company_Registration_Number__c = '12122'+ i;
            acc.Partner_Account_ID__c = '1212'+ i;
            acc.Recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
            acc.Sales_Office__c='Atlanta CBC';
            acc.BillingCity='Austin';
            acc.BillingPostalCode='78666';
            acc.BillingCountry='United States';
            acc.BillingState='Texas';
            acc.BillingStreet='test';
            acc.Phone='123456789'+ i;
            //acc.isPartner = true;
            accList.add(acc);
        }
    
        insert accList;
    
        system.debug('accList: '+ accList);
    
        List<Contact> conList = new List<Contact>();
    
        for (Integer i = 0; i < n; i++){
            Contact con = new Contact ();
            con.FirstName = 'Test';
            con.LastName = 'Test Last';
            con.Language__c = 'English';
            //line changed - waveoc
            con.AccountId = accList[i].Id;
            con.Email = 'xyzmail'+i+'@mail.com';
            con.Legal_Contact__c = true;
            conList.add(con);
        }
        system.debug('ConList: '+conList);
        insert conList;
    
        List<opportunity> oppList = new List<opportunity>();
    
        for (Integer i=0; i<n; i++){
    
            opportunity opp = new opportunity();
            opp.name = 'TestOpp'+i;
            opp.AccountId = accList[i].id;
            opp.CurrencyIsoCode = 'USD';
            opp.StageName = '02 Discovery';
            opp.CloseDate = Date.today();
            opp.Recordtypeid = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get(Label.OPP_RT_MED_STANDARD).getRecordTypeId();
            oppList.add(opp);
        }
        system.debug('OppList: '+oppList);
        insert oppList;
        
        return accList;
    }
    
    //Lu 11/20/2017
    public static User createPartnerUser(Contact c, Profile p){
        User u = new User();
        u.alias = 'test123';
        u.email='test123@noemail.com';
        u.emailencodingkey='UTF-8'; 
        u.lastname='Testing1'; 
        u.languagelocalekey='en_US';
        u.localesidkey='en_US'; 
        u.profileid = p.id; 
        u.country='United States'; 
        u.IsActive =true;
        u.ContactId = c.Id;
        u.timezonesidkey='America/Los_Angeles'; 
        u.username='helloWorld0@noemail.com';
        //u.UserRoleId = r.id;
        insert u;
        system.debug('user:>>>>'+u);
        return u;
    }
    //Lu 11/20/2017
    public static OpportunityTeamMember createOppTeamMember(Opportunity opp, User u){
        system.debug('user:>>>>'+u);
        OpportunityTeamMember oppTeamMem= new OpportunityTeamMember();
        oppTeamMem.OpportunityId = opp.Id;
        oppTeamMem.UserId = u.Id;
        oppTeamMem.TeamMemberRole = 'Partner';
        oppTeamMem.CurrencyIsoCode = 'USD';
        oppTeamMem.OpportunityAccessLevel = 'Edit';
        
        insert oppTeamMem;
        return oppTeamMem;
    }
    
    public static List<zqu__QuoteCharge__c> CreateZuoraQuoteCharge(Integer t,List<zqu__Quote__c> zQc)
    {
        zQuoteCharge=new List<zqu__QuoteCharge__c>();
        for(integer zChar=0;zChar<t;zChar++)
        {
            zQuoteCharge.add(new zqu__QuoteCharge__c(zqu__Quote__c=zQc[zChar].id)); 
        }
        insert zQuoteCharge;
        return zQuoteCharge;
    }
    
}