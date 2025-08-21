@isTest
public with sharing class LLMCreateCasepost_test {
@isTest
    static void Contactpostunitest1() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '56789712',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch', Inactive__c = false);
        insert testCon;
                
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"56789712","tenantProp4":"UKI - 50cloud Accounts","body":"Test Limitless multiple contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "***undefined***","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    @isTest
    static void Contactpostunitest2() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345',Local_CRM_AccountID__c = '10124565',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch');
        insert testAcc;        
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '10124565',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch',Inactive__c = false);
        insert testCon;
        
        Contact testCon1 = new Contact(LastName = 'Test Contact2', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '10124565',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch',Inactive__c = false);
        insert testCon1;
        
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"10124565","tenantProp4":"UKI - 50cloud Accounts","body":"Test Limitless multiple contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "***undefined***","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    
    @isTest
    static void Contactpostunitest3() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '1234567',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch',Inactive__c = false);
        insert testCon;
        
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"256894","tenantProp4":"UKI - 50cloud Accounts","body":"Test Limitless multiple contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "***undefined***","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    
    @isTest
    static void Contactpostunitest4() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '56789712',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch',Inactive__c = false);
        insert testCon;
               
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"56789712","tenantProp4":"UKI - 50cloud Accounts","body":"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "***undefined***","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    
    @isTest
    static void Contactpostunitest5() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '1234567',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch',Inactive__c = false);
        insert testCon;
               
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"256894","tenantProp4":"UKI - 50cloud Accounts","body":"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "***undefined***","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    @isTest
    static void Contactpostunitest6() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Local_CRM_Account_ID__c = '10245689',Local_CRM_Region__c = 'EUR',Local_CRM_Country__c = 'GB - United Kingdom',Local_CRM_Name__c = 'INA - Intacct',Inactive__c = false);
        insert testCon;

        
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"","tenantProp4":"UKI - 50cloud Accounts","body":"Test Limitless multiple contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
     @isTest
    static void Contactpostunitest7() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Inactive__c = false);
        insert testCon;

        
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"undefined","tenantProp4":"UKI - Business Cloud Accounting","body":"Test Limitless  contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    @isTest
    static void Contactpostunitest8() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Inactive__c = false);
        insert testCon;
        
        Contact testCon1 = new Contact(LastName = 'Test Contact2', AccountId = testAcc.Id, Email = 'test@test.com',Inactive__c = false);
        insert testCon1;

        
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"undefined","tenantProp4":"UKI - Business Cloud Accounting","body":"Test Limitless  contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }
    @isTest
    static void Contactpostunitest9() {
        Account testAcc = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc;
        
        Account testAcc1 = new Account(Name = 'Test Account', Type = 'Other', CurrencyIsoCode = 'GBP', Sales_Office__c = 'Dublin CBC', Phone = '12345');
        insert testAcc1;
        
        Contact testCon = new Contact(LastName = 'Test Contact', AccountId = testAcc.Id, Email = 'test@test.com',Inactive__c = false);
        insert testCon;
        
        Contact testCon1 = new Contact(LastName = 'Test Contact2', AccountId = testAcc1.Id, Email = 'test@test.com',Inactive__c = false);
        insert testCon1;

        
        LLMCreateCasepost.TestPayload = '{"customerFirstName":"contact","customerEmail":"test@test.com","tenantProp5":"undefined","tenantProp4":"UKI - Business Cloud Accounting","body":"Test Limitless  contacts","groupName": "","messageId": "724ad68c-****-****-a895-***********","msgState": "new","reasonCode": null,"tenantMsgId": "","tenantMsgType": "question"}';
        LLMCreateCasepost.postcontactwrapper();

    }

 
}