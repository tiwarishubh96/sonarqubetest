/*
 * Class Name :- SP_FetchStatusAndLanguageTest
 * Author :- Shubham Kimothi
 * Created Date :- 31-07-2019
 * Description : This class test class of SP_FetchStatusAndLanguage.
 * 
 // ********************Change Logs *****************************************************************************************************************************
 */

 @isTest
 public class SP_FetchStatusAndLanguageTest {
    
     static testMethod void SP_FetchStatusAndLanguageTest1() {
         SP_FetchStatusAndLanguage SP_Fetch = new SP_FetchStatusAndLanguage();
         SP_Fetch.CurrentSPStatus = 'Drafting';
         SP_Fetch.CurrentSPLanguage = 'FR';
         SP_Fetch.getstatusInNativeLanguage();
         SP_Fetch.CurrentSPLanguage = 'ES';
         SP_Fetch.getstatusInNativeLanguage();
         SP_Fetch.CurrentSPLanguage = 'DE';
         SP_Fetch.getstatusInNativeLanguage();
         SP_Fetch.CurrentSPLanguage = 'EN';
         SP_Fetch.getstatusInNativeLanguage();
     }

}