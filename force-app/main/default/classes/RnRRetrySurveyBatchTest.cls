/**
* Sage.
*
* @category  Batch Test
* @author    Ravi Yalamati
* @copyright 
* @license   
* @CreatedDate  07/10/2020 

*/
@isTest 
public class RnRRetrySurveyBatchTest {
    
    @testSetup static void setup() {
        
        
        
        Account accountObj = DataFactoryForTesting.createAccount();
        Contact contactObj = DataFactoryForTesting.createContact(accountObj.Id);
        Case rnrTestingCase = DataFactoryForTesting.createCase(contactObj);
        
        
        rnrTestingCase.Is_Survey_Sent__c = true;
        rnrTestingCase.Last_survey_sent_date__c = null;
        update rnrTestingCase;
        
        RRFrontline__RAndR_Solicit_Settings__c tokenCustomSetting = new RRFrontline__RAndR_Solicit_Settings__c();     
        tokenCustomSetting.Name = 'Solicit Settings';
        tokenCustomSetting.RRFrontline__Default_Recipient_Field__c = 'Email';        
        tokenCustomSetting.RRFrontline__Default_Workflow__c = 'Sage_English';        
        tokenCustomSetting.RRFrontline__Enable_Logging__c = true;  
        insert tokenCustomSetting;
      
    }
    
    static testMethod void testRnRRetryBatch() 
    {
     
        Test.startTest();

        List<Case> caseList = [Select Id,Is_Survey_Sent__c,Last_survey_sent_date__c From Case];
        System.debug('caseList'+caseList);
        if(caseList.size() > 0){
           
          
                //invoke batch class
                RnRRetrySurveyBatch obj = new RnRRetrySurveyBatch();
                DataBase.executeBatch(obj); 
          
        }
        
            
        System.assertEquals(1, caseList.size() );
        Test.stopTest();
    }

}