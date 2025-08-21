/**
* Tests for EntitlementMessageTrigger, EntitlementMessageTriggerHandler and EntitlementProcessorAsync class
*/
@isTest
public class EntitlementMessageTriggerTest {
    public static Entitlement_Message_Definition__c entDef;
    public static Entitlement_Message_Definition__c entDef2;
    public static Subscription_Master__c entSubscriptionMaster;
    public static Account acc;
    //
    static {
        insert new Application_Control__c(Run_Triggers__c = true);
        insert new CBC_Application_Control__c(Run_Triggers__c = true);
        
        String entLocation=System.Label.ENT_API_LOCATION;//'https://dummy-entitlement.com/v1'
        // setup custom settings
        insert new EntitlementSetting__c(Name='Preview', Location__c=entLocation, Key__c='testKey', Username__c='testUsername');

        // Create account
        acc = new Account(Name = 'Test Account', Sales_Office__c = 'Dublin CBC', Type = 'Customer', Industry = 'Finance', Phone = '12345678',BillingCity='Test City',BillingCountry='Poland', BillingStreet ='Sample Street');
        insert acc;
        Product2 entProduct = new Product2(Name = 'basicProduct', zqu__ZuoraId__c = 'zprodExtId456', zqu__SKU__c = 'sku456');
        insert entProduct;
        // Create an Subscription_Master__c
        entSubscriptionMaster = new Subscription_Master__c(Account__c = acc.Id, Entitlement_Id__c='1234-5678-9012');
        
        //entitlement definition
        entDef=new Entitlement_Message_Definition__c(URL__c='/entitlements/{!Param_Entitlement_Id__c}',
                                                     Method__c='POST', Message_Format__c='{"msgField1":"{!Param_Account_Principal_Id__c }"}',
                                                     Action_Name__c='test call');
        insert entDef;
        //entitlement definition
        entDef2=new Entitlement_Message_Definition__c(URL__c='/entitlements',
                                                     Method__c='POST', Message_Format__c='{"msgField1":"{!Param_Account_Principal_Id__c }"}',
                                                     Action_Name__c='test call2');
        insert entDef2;
    }
    /*
    * entitlement request/response - trigger insert
    */
    static testmethod void entitlementMessageInsert() {
		insert entSubscriptionMaster;
        String startEntId=entSubscriptionMaster.Entitlement_Id__c;
        //
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST());
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Entitlement_Message_Definition__c=entDef.Id, Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        Test.stopTest();
        //
        // check message is processed
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Message_Response__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Processed',entResp[0].Status__c,'Should be processed');
        // message was expanded with account id
        String expandedMsg=entResp[0].message__c;
        system.assert(expandedMsg.contains(entResp[0].Param_Account_Principal_Id__c));
        // url was expanded with starting entitlement id
        String expandedURL=entResp[0].URL__c;
        system.assert(expandedURL.contains(startEntId));
        // response message set
        String respMsg=entResp[0].Message_Response__c;
        system.assert(respMsg.contains('111-111-111'),'Response has mock Id value');
        // Subscription_Master has been set with new Id
        system.assertEquals('111-111-111',entResp[0].Subscription_Master__r.Entitlement_Id__c,'Response has mock Id value');
    }
    /*
    * entitlement request/response - trigger update
    */
    static testmethod void entitlementMessageUpdate() {
		insert entSubscriptionMaster;
        String startEntId=entSubscriptionMaster.Entitlement_Id__c;
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c=null, Entitlement_Message_Definition__c=entDef.Id, Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        //
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST());
        entMsg.Status__c='New';
        update entMsg;
        Test.stopTest();
        //
        // check message is processed
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Message_Response__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Processed',entResp[0].Status__c,'Should be processed');
    }
    /*
    * fail with no definition
    */
    static testmethod void failNoDefinitionRequest() {
		insert entSubscriptionMaster;        
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST());
        // message with no definition
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        Test.stopTest();
        //
        // check message error
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Error',entResp[0].Status__c,'Should be Error status');
        system.debug(entResp);
        String respMsg=entResp[0].Error_Message__c;
        system.assert(respMsg.contains('Entitlement Defintion record not found'),'Should throw Entitlment Exception');
    }
    /*
    * fail - expanding message
    */
    static testmethod void failExpandMessage() {
        entSubscriptionMaster.Entitlement_Id__c=null;
        insert entSubscriptionMaster;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST());
        // message with no definition
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Entitlement_Message_Definition__c=entDef.Id, Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        Test.stopTest();
        //
        // check message error
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Error',entResp[0].Status__c,'Should be Error status');
        system.debug(entResp);
        String respMsg=entResp[0].Error_Message__c;
        system.assert(respMsg.contains('Parameter field is blank'),'Should throw Entitlement Exception');
    }
    /*
    * response trigger failure
    */
    static testMethod void responseTriggerFail() {
        // response should fail with no Subscription_Master, but ensure definition has no Subscription_Master parameters so the request process passes.
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Entitlement_Message_Definition__c=entDef2.Id);
        insert entMsg;
        List<String> msgIdList=new List<String>();
        msgIdList.add((String)entMsg.Id);
        //
        Map<String,String> respHeaders=new Map<String,String>();
        respHeaders.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST(200, 'SUCCESS','{"id" : "111-111-111"}',respHeaders));
        EntitlementProcessorAsync.enqueueNewJob(msgIdList);
        Test.stopTest();
        //
        // check message errored with expected message text.
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Error',entResp[0].Status__c,'Should be Error');
        system.debug(entResp);
        String respMsg=entResp[0].Error_Message__c;
        system.assert(respMsg.contains('Subscription Master record not found'),'Should throw Entitlement Exception');
    }
    /*
    * async job 204 response (similating DELETE entitlement)
    */
    static testMethod void asyncFutureDelete() {
        insert entSubscriptionMaster;
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Entitlement_Message_Definition__c=entDef.Id, Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        List<String> msgIdList=new List<String>();
        msgIdList.add((String)entMsg.Id);
        //
        Map<String,String> respHeaders=new Map<String,String>();
        respHeaders.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST(204, 'SUCCESS','',respHeaders));
        //
        // testing future call (e.g. if already queued)
        EntitlementProcessorAsync.enqueueNewJob(msgIdList);
        Test.stopTest();
        //
        // check message successful
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Processed',entResp[0].Status__c,'Should be Processed');
    }
    /*
    * aync process http error
    */
    static testMethod void asyncError() {
        insert entSubscriptionMaster;
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Entitlement_Message_Definition__c=entDef.Id, Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        List<String> msgIdList=new List<String>();
        msgIdList.add((String)entMsg.Id);
        //
        Map<String,String> respHeaders=new Map<String,String>();
        respHeaders.put('Content-Type', 'application/json');
        Test.startTest();
        //
        // test ERROR http response
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST(401, 'ERROR','',respHeaders));
        System.enqueueJob(new EntitlementProcessorAsync(msgIdList));
        Test.stopTest();
        //
        // check message errored
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Error',entResp[0].Status__c,'Should be Error');
    }
    /*
    * async job handles upto X callouts (value of ENT_MESSAGE_MAX_PER_QUEUE)
    */
    static testMethod void asyncMultipleCallout() {
        insert entSubscriptionMaster;
        //
        // insert messages (check async job ENT_MESSAGE_MAX_PER_QUEUE for maximum)
        List<Entitlement_Message__c> msgList=new List<Entitlement_Message__c>();
        for(Integer i=0; i<EntitlementProcessorAsync.ENT_MESSAGE_MAX_PER_QUEUE; i++) {
            msgList.add(new Entitlement_Message__c(Status__c='New', Entitlement_Message_Definition__c=entDef.Id, Subscription_Master__c=entSubscriptionMaster.Id));
        }
        insert msgList;
        // gather IDs
        List<String> msgIdList=new List<String>();
        Set<Id> msgIdSet=new Set<Id>();
        for(Entitlement_Message__c msg : msgList) {
            msgIdList.add(msg.Id);
            msgIdSet.add(msg.Id);
        }
        //
        Map<String,String> respHeaders=new Map<String,String>();
        respHeaders.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST(201, 'SUCCESS','',respHeaders));
        System.enqueueJob(new EntitlementProcessorAsync(msgIdList));
        Test.stopTest();
        //
        // check messages successful
        for(Entitlement_Message__c entResp : [select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                              Param_Account_Principal_Id__c from entitlement_message__c where id IN:msgIdSet]) {
        	system.assertEquals('Processed',entResp.Status__c,'Should be Processed');
        }
    }
    /*
    * async job exception error
    */
    static testMethod void asyncException() {
        insert entSubscriptionMaster;
        // cause error - message with no definition
        Entitlement_Message__c entMsg=new Entitlement_Message__c(Status__c='New', Subscription_Master__c=entSubscriptionMaster.Id);
        insert entMsg;
        List<String> msgIdList=new List<String>();
        msgIdList.add((String)entMsg.Id);
        //
        Map<String,String> respHeaders=new Map<String,String>();
        respHeaders.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EntitlementMockREST(200, 'SUCCESS','',respHeaders));
        System.enqueueJob(new EntitlementProcessorAsync(msgIdList));
        Test.stopTest();
        //
        // check message errored
        List<Entitlement_Message__c> entResp=[select id, status__c, message__c, URL__c, Error_Message__c, Subscription_Master__r.Entitlement_Id__c,
                                               Param_Account_Principal_Id__c from entitlement_message__c where id=:entMsg.Id];
        system.assertEquals('Error',entResp[0].Status__c,'Should be Error');
    }
}