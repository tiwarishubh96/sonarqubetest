@IsTest 
public class PayNowEmailerTest {
    
    // Test to make sure required Custom Settings have been added
    @IsTest(SeeAllData=true) static void testForRequiredCustomSettings(){
        PayNowSetting__c pnDisplayName = PayNowSetting__c.getInstance('PayNowEmailDisplayName');
        System.assertNotEquals(null, pnDisplayName, 'PayNow Custom Setting "PayNowEmailDisplayName" is not set.');
        
        PayNowSetting__c pnBccList = PayNowSetting__c.getInstance('PayNowEmailBccList');
        System.assertNotEquals(null, pnBccList, 'PayNow Custom Setting "PayNowEmailBccList" is not set.');
        
        PayNowSetting__c pnTemplateName = PayNowSetting__c.getInstance('PayNowEmailTemplateName');
        System.assertNotEquals(null, pnTemplateName, 'PayNow Custom Setting "PayNowEmailTemplateName" is not set.');
    }
    
    // Test to make sure required email template has been added
    @IsTest(SeeAllData=true) static void testGetEmailTemplate(){
        PayNowSetting__c pnTemplateName = PayNowSetting__c.getInstance('PayNowEmailTemplateName');
        
        EmailTemplate template = payNowEmailer.getEmailTemplate(pnTemplateName.Value__c);
        
        System.assert(template != null);
    }
    
    static testMethod void testGetEmailTemplateNonExistant(){
        EmailTemplate template = payNowEmailer.getEmailTemplate('jaklsjdflk;ajsdf');
        
        System.assert(template == null);
    }
    
    static testMethod void testGetEmailMessage(){
        PayNowToken__c token = new PayNowToken__c();
        token.Name = 'TestToken';
        insert token;
        
        System.assertNotEquals(null, token, 'Token is null.');
        System.assertNotEquals(null, token.Id, 'Token.Id is null.');
        
        Contact recipient = new Contact();
        recipient.FirstName = 'Joe';
        recipient.LastName = 'Tester';
        recipient.Email = 'test.email@sage.com';
        insert recipient;
        
        System.assertNotEquals(null, recipient, 'Recipient is null.');
        System.assertNotEquals(null, recipient.Id, 'Recipient.Id is null.');

        upsert new PayNowSetting__c(
            Name = 'PayNowEmailTemplateName',
            Value__c = 'PayNow Completion Link'
        );
        
        User testUser = [Select Id From User Where Alias ='pinte'];
        
        System.RunAs(testUser){
                	String pnTemplateName ='PayNow Completion Link';
       			  
            
            Messaging.SingleEmailMessage message = payNowEmailer.getEmailMessage(token.id, recipient.Id,pnTemplateName,false,'Accounting');
            
            System.assert(message.getBccAddresses().isEmpty() == false);
        }
    }
    
    static testMethod void testGetDisplayName() {
        string key = 'PayNowEmailDisplayName';
        
        System.assert(payNowEmailer.getDisplayName() == null);
       
        PayNowSetting__c newDisplayName = new PayNowSetting__c();
        newDisplayName.Name = key;
        newDisplayName.Value__c = 'test.email.01@sage.com';
        insert newDisplayName;
        
        System.assertEquals('test.email.01@sage.com', payNowEmailer.getDisplayName());
    }
    
    static testMethod void testGetBccList() {
        string key = 'PayNowEmailBccList';
        
        List<string> emptyList = payNowEmailer.getBccList();
        System.assert(emptyList.isEmpty());
        
        PayNowSetting__c newBccList = new PayNowSetting__c();
        newBccList.Name = key;
        newBccList.Value__c = 'test.email.01@sage.com';
        insert newBccList;
        
        List<string> bssList = payNowEmailer.getBccList();
        
        System.assert(bssList.isEmpty() == false);
        
        System.assertEquals('test.email.01@sage.com', bssList[0]);
        
        newBccList.Value__c = 'test.email.01@sage.com,test.email.02@sage.com';
        update newBccList;
        
        List<string> bssList2 = payNowEmailer.getBccList();
        
        System.assert(bssList2.isEmpty() == false);
        System.assertEquals('test.email.01@sage.com', bssList2[0]);
        System.assertEquals('test.email.02@sage.com', bssList2[1]);
    }
    
    static testMethod void testSendPayNowEmail() {
        PayNowToken__c token = new PayNowToken__c();
        token.Name = 'TestToken';
        insert token;
        
        System.assertNotEquals(null, token, 'Token is null.');
        System.assertNotEquals(null, token.Id, 'Token.Id is null.');
        
        Contact recipient = new Contact();
        recipient.FirstName = 'Joe';
        recipient.LastName = 'Tester';
        recipient.Email = 'test.email@sage.com';
        insert recipient;
        
        System.assertNotEquals(null, recipient, 'Recipient is null.');
        System.assertNotEquals(null, recipient.Id, 'Recipient.Id is null.');

        upsert new PayNowSetting__c(
            Name = 'PayNowEmailTemplateName',
            Value__c = 'PayNow Completion Link'
        );
        
        
        User testUser = [Select Id From User Where Alias ='pinte'];
        
        System.RunAs(testUser){
            try{
                String pnTemplateName ='PayNow Completion Link';
                payNowEmailer.sendPayNowEmail(token.Id, recipient.Id, pnTemplateName,false,'Accounting' );
            } Catch (Exception ex){
                System.debug('Error sending PayNow test email: ' + ex);
                System.assert(ex.getMessage().contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') || ex.getMessage().contains('NO_MASS_MAIL_PERMISSION') || ex.getMessage().contains('REQUIRED_FIELD_MISSING'));
            }
        }
    }
}