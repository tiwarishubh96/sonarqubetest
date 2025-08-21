@isTest(SeeAllData=true)
public class TetrisZuoraPaymentManager_Test {
   
    public static testmethod void testScheduleJod()
    { 
        
        Test.startTest();
        
         zqu__HostedPageLiteSetting__c testData = new zqu__HostedPageLiteSetting__c(Name ='Tetris R2 GB Credit Card', zqu__PaymentMethodType__c ='Credit Card',
                                                                         zqu__PageId__c =GUIDHelper.generateGUID().subString(0,32),zqu__ComponentName__c='PaymentPage',
                                                                                   Country__c='US - United States');
        insert testData; 
        List<zqu__HostedPageLiteSetting__c> test123 =[SELECT Id, zqu__PageId__c, Name, Country_Code__c FROM zqu__HostedPageLiteSetting__c where id =: testData.id];
        system.debug(test123); 
        String countryCode='en_US';
        String pageName = 'Credit Card';
        TetrisZuoraPaymentManager.loadPage(pageName, countryCode);
        Test.stopTest();
    }

}