public class TestDataUtility {
 /*-------------------------------------------------------------
    Author:        Rohit Kumar
    Company:       Salesforce.com
    Description:   TestDataUtility Method for Creating Test Data
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
  ------------------------------------------------------------*/
   /**
    * Generic method to insert sobject records.
    * @author Rohit (Salesforce)
    */
    public static String status ; // Varaible to store Zuora Status field API Name
    public static Id AccountId ; // Variable to store AccountId 
    public static List<SObject> createRecords( List<SObject> records, Boolean doInsert, Map<String, Object> attributes ){
        Integer i = 0;
        if( attributes != null ){
            for ( Integer j =0; j < records.size(); j ++ ) {
              SObject record = records[j];
              for (String key : attributes.keySet()) {
                Object value = attributes.get(key);
                if (value instanceof List<Object>) {
                  Object obj =  ((List<Object>) value).get(i);
                  if( obj instanceof SObject ){
                    Id sObjectId = ((SObject) obj).Id;
                    record.put( key,sObjectId );
                  }
                  else {
                    record.put(key,obj);
                  }
                } else {
                  record.put(key, value);
                }
              }
              i++;
            }
        }
        if (doInsert) {
          insert records;
        }
        return records;
    }

    /**
     * Create sobjects
     * Inserts sobject in all scenario for bulk testing.
     * @author Rohit (Salesforce)
     */
    public static List<SObject> createSObject( Integer numToInsert, Boolean doInsert, Map<String, Object> nameValueMap , String sobjType){
        List<SObject> objList = new List<SObject>();
        for( Integer i=0; i< numToInsert; i++ ){
          SObject obj = Schema.getGlobalDescribe().get(sobjType).newSObject();
          objList.add( obj );
        }
        return createRecords( objList, doInsert, nameValueMap );
    }
  /**
   * Create ZObject Method
   * This is a simple method to create ZObject with a purpose of creating dummy ZObject Data as we Can't make Zuora Callout
   */
  public static Zuora.zObject createZObject (){
       // Add Condition to create dummy updateZInvoiceNumberList
                    Zuora.zObject obj = new Zuora.zObject('Invoice');
                    String invoiceTestId = '2c92c0f94e001371014e02a0b2e744e7';
                    obj.setValue('Id', invoiceTestId);
                    obj.setValue('Invoice_Sequence_Number__c', 'US-00000001');
                    obj.setValue('AccountId', '2c92c0f94e001371014e02a0b2e749d6');
                    obj.setValue('Status', 'Posted');
                    return obj;
  }
  /**
   * Create Zobject Result Object
   */
   public static List<Zuora.zApi.SaveResult> createDummyResult (){
       List<Zuora.zObject> Errors = new List <Zuora.zObject> ();
       Zuora.zObject obj = createZObject();
       List<Zuora.zObject> objs = new List<Zuora.zObject>{obj};
       Zuora.zApi zApiInstance;
       String Id = '2c92c0f94e001371014e02a0b2e744e7';
       Boolean Success = true;
       Zuora.zApi.SaveResult resultObj = new Zuora.zApi.SaveResult();
       resultObj.Errors = Errors;
       resultObj.Id = Id;
       resultObj.Success = true;
       List<Zuora.zApi.SaveResult> objList =  new List<Zuora.zApi.SaveResult>(); //zApiInstance.zupdate(objs);
       objList.add(resultObj);
       return (objList);
   }
   /**
    * Create Invoice
    */
    public static Zuora__ZInvoice__c createInvoice(){
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c(Name='test');
        insert inv;
        return inv;
    }

 public static void createZuoraInvoiceMapping(){
        Zuora_Invoice_Mapping__c cSetting = new Zuora_Invoice_Mapping__c();
        cSetting.Invoice_Object__c = 'US_Invoice__c';
        cSetting.Name = 'Atlanta CBC';
        insert cSetting;
    }

    public static void createHostedPageLiteSetting(String zuoraId, String paymentMethod, String clientCode){
        zqu__HostedPageLiteSetting__c pSetting = new zqu__HostedPageLiteSetting__c();
        pSetting.Payment_Gateway_Name__c = 'sagecbcus';
        pSetting.Name = 'CBC US ' + paymentMethod + ' Test Data';// + String.valueOf(Datetime.now().getTime());  // 05/09/2019 bphan add TimeStamp for uniqueness
        pSetting.zqu__ComponentName__c = 'PaymentPage';
        pSetting.zqu__PageId__c = zuoraId;
        pSetting.zqu__PaymentMethodType__c = paymentMethod;
        pSetting.CurrencyIsoCode = 'USD';
        pSetting.Country__c = 'US - United States';
        pSetting.Client_Code__c = clientCode;
        pSetting.TradingEntity__c = 'SGS Inc';
        pSetting.Language__c = 'English';

        insert pSetting;
    }

    public static void createHostedPageLiteSetting(String zuoraId, String clientCode){
        createHostedPageLiteSetting(zuoraId, 'Credit Card', clientCode);
    }

    public static void createHostedPageLiteSetting(String zuoraId){
        createHostedPageLiteSetting(zuoraId, 'Credit Card', 'CBC');
    }

    //CreateInvoice template for backward compatibility
    public static void createComunicationProfile(String zuoraId){
        createComunicationProfile(zuoraId, 'US Active');
    }

    public static void createComunicationProfile(String zuoraId, String name){
        zqu__CommunicationProfile__c cProfile = new zqu__CommunicationProfile__c();
        cProfile.zqu__ZuoraId__c = zuoraId;
        cProfile.Name = name;
        cProfile.Country__c = 'US - United States';
        cProfile.Language__c = 'English';
        cProfile.TradingEntity__c = 'SGS Inc';
        insert cProfile;
    }

    //CreateInvoice template for backward compatibility
    public static void createInvoiceTemplate(String zuoraId){
        createInvoiceTemplate(zuoraId, 'US Active');
    }

    public static void createInvoiceTemplate(String zuoraId, String name){
        zqu__InvoiceTemplate__c template = new zqu__InvoiceTemplate__c();
        template.zqu__ZuoraId__c = zuoraId;
        template.Name = name;
        template.Country__c = 'US - United States';
        template.Language__c = 'English';
        template.TradingEntity__c = 'SGS Inc';
        insert template;
    }

    public static void createInvoiceTemplateForTetris(String zuoraId, String name){
        zqu__InvoiceTemplate__c template = new zqu__InvoiceTemplate__c();
        template.zqu__ZuoraId__c = zuoraId;
        template.Name = name;
        template.Country__c = 'US - United States';
        template.Language__c = 'English';
        template.Platform__c = 'Tetris';
        template.TradingEntity__c = 'SGS Inc';
        insert template;
    }
    
    public static void createInvoiceTemplate(String zuoraId, String name, String platform){
        zqu__InvoiceTemplate__c template = new zqu__InvoiceTemplate__c();
        template.zqu__ZuoraId__c = zuoraId;
        template.Name = name;
        template.Country__c = 'US - United States';
        template.Language__c = 'English';
        template.Platform__c = platform;
        template.TradingEntity__c = 'SGS Inc';
        insert template;
    }

    public static Zuora__CustomerAccount__c createBillingAccountAndPaymentMethod(Account acc, String zuoraId){
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Zuora_Id__c = zuoraId;
        billingAccount.Zuora__Account__c = acc.Id;
        insert billingAccount;
        // 05/09/2019 bphan only create the new Zuora__PaymentMethod when it doesn't exist.        
        Zuora__PaymentMethod__c pMethod = new Zuora__PaymentMethod__c();
        List<Zuora__PaymentMethod__c> matches = new List<Zuora__PaymentMethod__c>([SELECT Id, Zuora__External_Id__c, Zuora__BillingAccount__c, Zuora__Type__c FROM Zuora__PaymentMethod__c
                                       WHERE Zuora__Type__c =:'CreditCard' ]);
        if(matches.size() == 0)
        {
          pMethod.Zuora__External_Id__c = zuoraId;
          pMethod.Zuora__BillingAccount__c = billingAccount.Id;
          pMethod.Zuora__Type__c = 'CreditCard';
          insert pMethod;
        }else{
          for (Zuora__PaymentMethod__c zp: matches)
          {
              pMethod = zp;
              break;
          }
        }

        billingAccount.Zuora__Default_Payment_Method__c = pMethod.Id;
        update billingAccount;
        return billingAccount;
    }

    /**
    * Creates a Z Product 
    * @param name of the ZProduct to create
    * @return ZProduct record created
    **/
    public static Product2 createZProduct(String name, String zuoraId) {
        Product2 p = new Product2();
        p.Name = name;
        p.zqu__SKU__c = name;
        p.zqu__ZuoraId__c = zuoraId;
        insert p;
        return p;
    }

    /**
    * Creates a Product2 with no Zuora Id
    * @param name of the Product to create
    * @param ProductCode of the Product to create
    * @return ZProduct record created
    **/
    public static Product2 createProduct2(String name, String ProductCode) {
        Product2 p = new Product2(Name = name,
                ProductCode = ProductCode
        );
        insert p;
        return p;
    }

    /**
   * Creates a Z Product
   * @param name of the ZProduct to create
   * @return ZProduct record created
   **/
    public static zqu__ZProduct__c createZProduct(String name, Id Product2Id) {
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = name,
                zqu__Product__c = Product2Id
        );
        insert zp;
        return zp;
    }

    /**
    * Creates a Z Product Rate Plan
    * @param name of the product rate plan to create
    * @param productId of the product rate plan to create
    * @param zProductId of the product rate plan to create
    * @param apiServiceId of the product rate plan to create
    * @return zqu__ProductRatePlan__c record created
    **/

    public static zqu__ProductRatePlan__c createProductRatePlan(String name, Id productId, Id zProductId, String apiServiceId) {

        zqu__ProductRatePlan__c zprp = new zqu__ProductRatePlan__c(Name=name,
        zqu__Product__c = productId,
        zqu__ZProduct__c = zProductId,
        APIServiceId__c = apiServiceId
        );
        insert zprp;
        return zprp;
    }

    /**
    * Creates a Z Product Rate Plan
    * @param name of the product rate plan to create
    * @param productId of the product rate plan to create
    * @param zProductId of the product rate plan to create
    * @param apiServiceId of the product rate plan to create
    * @return zqu__ProductRatePlan__c record created
    **/

    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(String name, Id productRatePlan) {

        zqu__ProductRatePlanCharge__c zprpc = new zqu__ProductRatePlanCharge__c(Name= name,
                zqu__ProductRatePlan__c = productRatePlan
        );
        insert zprpc;
        return zprpc;
    }

    /**
    * Creates a Z Product Rate Plan
    * @return ZProduct record created
    **/
    public static zqu__ProductRatePlan__c createRatePlan(Id zProductId, String name, String zuoraId) {
        zqu__ProductRatePlan__c rp = new zqu__ProductRatePlan__c();
        rp.Name = name;
        rp.zqu__Product__c = zProductId;
        rp.zqu__ZuoraId__c = zuoraId;
        rp.ExternalApplication__c = 'Tetris';
        insert rp;
        return rp;
    }

    /**
    * Creates a product tier
    * @param name of the tier to create
    * @return tier record created
    **/
    public static Product_Tier__c createProductTier(Id zProductId, String name, String code) {

        Product_Tier__c tier = new Product_Tier__c();
        tier.Name = name;
        tier.Product_Tier_Code__c = code;
        tier.Product__c = zProductId;
		tier.Product_Use_Region__c='US - United States';
        tier.PayNow_PageType__c='SageOne';
        insert tier;
        return tier;
    }


     /**
    * Creates a product tier
    * @param name of the tier to create
    * @param name of the Product_Use_Region__c
    * @param name of the PayNow_PageType__c
    * @return tier record created
    **/
    public static Product_Tier__c createProductTier(Id zProductId, String name, String code,String Region,String PageType) {

        Product_Tier__c tier = new Product_Tier__c();
        tier.Name = name;
        tier.Product_Tier_Code__c = code;
        tier.Product__c = zProductId;
		tier.Product_Use_Region__c=Region;
        tier.PayNow_PageType__c=PageType;
        insert tier;
        return tier;
    }




    /**
    * Creates a product tier rate plan
    * @param tierId of the tier to associate this rate plan to
    * @param name of the tier to create
    * @return tier rate plan record created
    **/
    public static Product_Tier_Rate_Plan__c createProductTierRatePlan(Id tierId, Id ratePlanId, Id locId, String name) {
        Product_Tier_Rate_Plan__c ratePlanTier = new Product_Tier_Rate_Plan__c();
        ratePlanTier.Name = name;
        ratePlanTier.Start_Date__c = System.today();
        ratePlanTier.End_Date__c = System.today().addDays(100);
        ratePlanTier.Product_Rate_Plan__c = ratePlanId;
        ratePlanTier.Product_Tier__c = tierId;
        ratePlanTier.Locale__c = locId;
        ratePlanTier.Is_Foundation__c = false;
        insert ratePlanTier;
        return ratePlanTier;
    }


    /**
    * Creates a product tier rate plan
    * @param tierId of the tier to associate this rate plan to
    * @param name of the tier to create
    * @param isFoundation of the tier - to make it a foundation rateplan set it to true otherwise false
    * @return tier rate plan record created
    * 
    **/
    public static Product_Tier_Rate_Plan__c createProductTierRatePlan(Id tierId, Id ratePlanId, Id locId, String name, Boolean isFoundation) {
        Product_Tier_Rate_Plan__c ratePlanTier = new Product_Tier_Rate_Plan__c();
        ratePlanTier.Name = name;
        ratePlanTier.Start_Date__c = System.today();
        ratePlanTier.Is_Foundation__c = isFoundation;
        ratePlanTier.End_Date__c = System.today().addDays(100);
        ratePlanTier.Product_Rate_Plan__c = ratePlanId;
        ratePlanTier.Product_Tier__c = tierId;
        ratePlanTier.Locale__c = locId;

        insert ratePlanTier;
        return ratePlanTier;
    }
    /**
    * Creates a locale 
    * @param name 
    * @return locale record created
    **/

    public static Locale__c createLocale(String country, String default_locale, String name, String Language) {
        // 05/09/2019 bphan  only create if not exist
       List<Locale__c> matches = new List<Locale__c>([SELECT Id, Country__c, Default_Locale__c, Name, Language__c FROM Locale__c
                                       WHERE Country__c =: country AND Default_Locale__c =: default_locale AND Name =:name AND Language__c =:Language]);
       Locale__c loc = new Locale__c();
       if (matches.size() == 0){
          loc.Country__c = country;
          loc.Default_Locale__c = default_locale;
          loc.Name = name;
          loc.Language__c = Language;
          loc.LanguageLocaleKey__c = 'en_US';
          insert loc;
       }
       else
       {
         for (Locale__c l:matches){
           loc = l;
           break;
        }
       }
      return loc;
    }

    /**
     * [createAccount creates new account in SFDC]
     * @return [new SFDC account]
     * Docmation 2017-07
     * Kept this for backward compatability 
     */
    public static Account createAccount(){
        Id locId = null;
        return createAccount(locId);
    }

    /**
     * [createAccount creates new account in SFDC]
     * @return [new SFDC account]
     * Docmation 2017-07
     * Added locale context
     */
    public static Account createAccount(Id locId){
        Account acc = new Account();
        acc.Name = 'acme';// + String.valueOf(Datetime.now().getTime());
        acc.BillingCity = 'Atlanta';
        acc.BillingCountry = 'United States';
        acc.BillingCountryCode = 'US';
        acc.BillingStreet ='Some Street';
        acc.BillingPostalCode = '30318';
        acc.BillingState = 'Georgia';
        acc.BillingStateCode = 'GA';
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.Locale_Billing_CC__c = 'US';
        acc.Locale__c = locId;
        insert acc;

        //To evaluate the cross reference values and derive the formula 
        acc.Locale__c = locId;
        upsert acc;

        //Get the locale tied to the quote account
        //account a = [select locale__c, locale__r.name, RecordTypeId from account where id  = :acc.id];

        return acc;
    }

    /**
     * [createContact creates new contact in SFDC]
     * @param  accountId [SFDC account id]
     * @return           [new SFDC contact]
     */
    public static Contact createContact(Id accId){
        Contact con = new Contact();
        con.FirstName = 'john';
        con.LastName = 'galt' + String.valueOf(Datetime.now().getTime());   // 05/09/2019 bphan Add TimeStamp for uniqueness 
        con.AccountId = accId;
        con.MailingCity = 'New York';
        con.MailingCountry = 'United States';
        con.MailingStreet = 'Some Street';
        con.MailingPostalCode = '10082';
        con.MailingState = 'New York';
        con.Language__c = 'English';
        con.ELanguage__c = 'EN';

        insert con;
        return con;
    }

    public static zqu__Quote__c createZQuote(Id accId, Id contactId, String zuoraId){
        return createZQuote(accId, contactId, null, null, zuoraId);
    }

    /**
     * [createZQuote creates new zuora quote in SFDC]
     * @param  accountId [SFDC account id]
     * @param  contactId [SFDC contact id]
     * @return           [new SFDC quote]
     */
    public static zqu__Quote__c createZQuote(Id accId, Id contactId, String subscriptionType, String electronicPaymentMethodId, String zuoraId)
    {
        zqu__Quote__c zquote = new zqu__Quote__c();

        zquote.zqu__Account__c = accId;
        zquote.zqu__BillToContact__c = contactId;
        zquote.zqu__SoldToContact__c = contactId;
        zquote.zqu__Currency__c = 'USD';
        zquote.zqu__ProcessPayment__c = false;
        zquote.zqu__RenewalTerm__c = 12;
        zquote.zqu__InitialTerm__c = 12;
        zquote.zqu__ValidUntil__c  = Date.today().addDays(2);
        zquote.zqu__StartDate__c = Date.today();
        zquote.zqu__GenerateInvoice__c = true;
        zquote.zqu__PaymentMethod__c = 'Credit Card';
        zquote.zqu__ZuoraAccountID__c = zuoraId;
        zquote.zqu__Previewed_Total__c = 10;
        zquote.zqu__InvoiceID__c = zuoraId;
        zquote.zqu__SubscriptionType__c = subscriptionType;
        zquote.zqu__ElectronicPaymentMethodId__c = electronicPaymentMethodId;
        zquote.zqu__ExistSubscriptionID__c = '';
        insert zquote;
        return zquote;
    }

    /**
     * [createZQuote creates new zuora quote in SFDC for new Subscription]
     * @param  accountId [SFDC account id]
     * @param  contactId [SFDC contact id]
     * @return           [new SFDC quote]
     */
    public static zqu__Quote__c createZQuoteNewSubscription(String name, Id contactId,Id opportunityId)
    {
        zqu__Quote__c zquote = new zqu__Quote__c();

        zquote.Name=name;
        zquote.zqu__Opportunity__c = opportunityId;
        zquote.zqu__SoldToContact__c = contactId;
        zquote.zqu__Service_Activation_Date__c = date.Today();
        zquote.zqu__Currency__c = 'USD';
        zquote.zqu__InitialTerm__c = 12;
        zquote.zqu__ValidUntil__c  = Date.today().addDays(2);
        zquote.zqu__BillToContact__c = contactId;
        zquote.zqu__SoldToContact__c = contactId;
        zquote.zqu__SubscriptionType__c  = 'New Subscription';
        zquote.External_Application__c = 'Tetris';
        zquote.zqu__ElectronicPaymentMethodId__c = '2c92c0f855c9f4540155dc42153960e7';
        zquote.zqu__PaymentMethod__c = 'Credit Card';
        insert zquote;
        return zquote;

    }

    /**
     * [createZQuote creates new opportunity in SFDC]
     * @param  accId [SFDC account id]
     * @param Name [Opp name]
     * @return           [new SFDC quote]
     */

    public static Opportunity createOpportunity(Id accId, String Name){
        Opportunity Opp1 = new Opportunity(Name =Name,
                AccountId = accId,
                StageName = 'Closed Won',
                CloseDate = date.today()+5,
                Probability = 100,
                Type = 'New Business'

        );
        insert Opp1;
        return Opp1;
    }


    public static Call_Item__c createCallitem(Id accId,Id contactId){

        Call_Item__c ci = new Call_Item__c();
        ci.Account__c=accId;
        ci.Active_Start_Date__c=Date.today()+5;
        ci.Name='Test call item';
        ci.Call_List_Name__c='Test call item';
        ci.FederationUserID__c='testfedid1@sage.com';
        ci.Hint__c='Test hint';
        ci.Local_CRM_AccountID__c='Test12';
        ci.Contact__c=contactid;
        insert ci;
        return ci;

    }

    public static User createUser(){

        User u = new User();
        u.Alias = 'test';
        u.Email='testuser@test.com';
        u.EmailEncodingKey='UTF-8';
        u.LastName='Testing';
        u.LanguageLocaleKey='en_GB';
        u.LocaleSidKey='en_GB';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        u.TimeZoneSidKey='Europe/London';
        u.UserName='testuser@sage.com';
        u.FederationIdentifier='testfedid1@sage.com';
        //Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        insert u;
        return u;
    }

    /**
     * Create Local CRM custom setting data
     * @return           void
     */
    public static void createLocalCrmCustomSetting() {
        List<LocalCRM__c> listLocalCrm = new List<LocalCRM__c>();
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'AU'
                ,   Country__c = 'AU - Australia'
                ,   Default_CRM__c = 'AUS - None'
                ,   Region__c = 'AUS'
        ));
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'GB'
                ,   Country__c = 'GB - United Kingdom'
                ,   Default_CRM__c = 'INT - InTouch'
                ,   Region__c = 'EUR'
        ));
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'US'
                ,   Country__c = 'US - United States'
                ,   Default_CRM__c = 'FUS - Fusion'
                ,   Region__c = 'AMR'
        ));
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'ZA'
                ,   Country__c = 'ZA - South Africa'
                ,   Default_CRM__c = 'ENI - Enigma'
                ,   Region__c = 'AFR'
        ));
        Database.insert(listLocalCrm);
    }

    /**
     * Create Global Sales User
     * @return           User
     */
    public static List<User> createGlobalSalesUser(Integer intCount, Boolean doInsert, String cCaaSPermSetName, String activeCallCenterName) {
        List<SObject> listSObjectInsert = new List<SObject>();
        List<User> listUserInsert = new List<User>();
        List<PermissionSetAssignment> listPermSetAssignmentInsert = new List<PermissionSetAssignment>();
        List<CallCenter> listCallCenter = [ SELECT Id FROM CallCenter WHERE InternalName = :activeCallCenterName ];

        String userName;
        for (Integer iterator = 0; iterator < intCount; iterator++) {
            userName = 'global.sales.test.user@' + (String.isNotBlank(cCaaSPermSetName) ? cCaaSPermSetName : 'NO_CC') + String.valueOf(System.now().millisecond()) + '.com';
            listUserInsert.add(new User(
                        FirstName = 'Global'
                    ,   LastName = 'Sales User'
                    ,   Alias = 'GS' + String.valueOf(System.now().millisecond())
                    ,   Email = 'global.sales.test.user@qwertyuioplkj.com'
                    ,   ProfileId = [ SELECT Id FROM Profile WHERE Name = 'Sage: Global Sales User' LIMIT 1 ].get(0).Id
                    ,   Username = userName
                    ,   EmailEncodingKey = 'UTF-8'
                    ,   LanguageLocaleKey = 'en_GB'
                    ,   LocaleSidKey = 'en_GB'
                    ,   TimeZoneSidKey='Europe/London'
                    ,   CallCenterId = listCallCenter != null && !listCallCenter.isEmpty() ? listCallCenter.get(0).Id : null
                    ,   External_Id__c = userName
            ));
            if (doInsert) {
                listPermSetAssignmentInsert.addAll(TestDataUtility.assignGlobalSalesPermissionSet(
                        new User(External_Id__c = userName), false, cCaaSPermSetName));
            }
        }
        if (doInsert) {
            // MULTIPLE LISTS TO AVOID APEX EXCEPTION OF MORE THAN 10 CHUNKS
            listSObjectInsert.addAll((List<SObject>) listUserInsert);
            if (!listPermSetAssignmentInsert.isEmpty()) listSObjectInsert.addAll((List<SObject>) listPermSetAssignmentInsert);
            Database.insert(listSObjectInsert);
        }

        return doInsert ? [ SELECT Id FROM User WHERE External_Id__c LIKE 'global.sales.test.user@%.com' ] : listUserInsert;
    }

    public static List<PermissionSetAssignment> assignGlobalSalesPermissionSet(User salesUser, Boolean doInsert, String cCaaSPermSetName) {
        List<PermissionSetAssignment> listPermSetAssignmentInsert = new List<PermissionSetAssignment>();
        List<PermissionSet> listPermissionSet = [   SELECT Id
                                                            , Name
                                                    FROM PermissionSet
                                                    WHERE Name = 'Sage_NCA_plus'
                                                        OR Name = 'Transfer_Opportunity_Ownership'
                                                        OR Name = 'Export_Reports'
                                                        OR Name = 'Q_assign_Manager'
                                                        OR Name = 'Q_assign_User'
                                                        OR Name = 'Bypass_Opportunity_Close_Validation'
                                                        OR Name = :cCaaSPermSetName ];
        for (PermissionSet eachPermissionSet :listPermissionSet) {
            listPermSetAssignmentInsert.add(new PermissionSetAssignment(
                        Assignee = new User(External_Id__c = salesUser.External_Id__c)
                    ,   PermissionSetId = eachPermissionSet.Id
            ));
        }

        if (doInsert) {
            Database.insert(listPermSetAssignmentInsert);
        }

        return listPermSetAssignmentInsert;
    }
}