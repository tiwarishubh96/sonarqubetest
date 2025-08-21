@isTest
public with sharing class AccountKeyInfoSimpleDecorator_Test {
    

    @isTest static void testGroupMessagesByHeadline(){
        AccountKeyInfoWrapper wrapper1 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.PASSWORD_TYPE,new String []{''},1);
        AccountKeyInfoWrapper wrapper2 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.PASSWORD_TYPE,new String []{''},2);
        AccountKeyInfoWrapper wrapper3 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.COMPLAINT_TYPE,new String []{''},3);
        List<AccountKeyInfoWrapper> wrapperList = new List<AccountKeyInfoWrapper>();
        wrapperList.add(wrapper3);
        wrapperList.add(wrapper2);
        wrapperList.add(wrapper1);
        AccountKeyInfoSimpleDecorator decorator = new AccountKeyInfoSimpleDecorator();
        Test.startTest();
            Map<String, List<AccountKeyInfoWrapper>> results = decorator.groupMessagesByHeadline(wrapperList);
        Test.stopTest();
        System.assertEquals(results.get(AccountKIBaseSvc.PASSWORD_TYPE).size(),2,'Should have been 2 password messages');

        System.assertEquals(results.get(AccountKIBaseSvc.COMPLAINT_TYPE).size(),1,'Should have been 2 Complaint messages');
        System.assertEquals(results.get(AccountKIBaseSvc.OTHER_TYPE),null,'Should be no OTHER messages');
    }

    @isTest static void testGroupMessagesByCard(){
        AccountKeyInfoWrapper wrapper1 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.PASSWORD_TYPE,new String []{''},1);
        AccountKeyInfoWrapper wrapper2 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.CREDIT_TYPE,new String []{''},1);
        AccountKeyInfoWrapper wrapper3 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.COMPLAINT_TYPE,new String []{''},2);
        AccountKeyInfoWrapper wrapper4 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.INCIDENT_TYPE,new String []{''},2);
        List<AccountKeyInfoWrapper> wrapperList = new List<AccountKeyInfoWrapper>();
        wrapperList.add(wrapper3);
        wrapperList.add(wrapper2);
        wrapperList.add(wrapper1);
        wrapperList.add(wrapper4);
        Test.startTest();
            AccountKeyInfoSimpleDecorator decorator = new AccountKeyInfoSimpleDecorator();
        Test.stopTest();
        Map<String, List<AccountKeyInfoWrapper>> messagesByHeadline = decorator.groupMessagesByHeadline(wrapperList);
        Map<Integer, Map<String,List<AccountKeyInfoWrapper>>> results = decorator.groupMessagesByCard(messagesByHeadline);
        System.assertEquals(results.keySet().size(),2,'Should have returned 2 cards');
    }

    @isTest static void testDecorate(){
        AccountKeyInfoWrapper wrapper1 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.PASSWORD_TYPE,new String []{'123456'},1);
        AccountKeyInfoWrapper wrapper2 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.CREDIT_TYPE,new String []{'Good'},1);
        AccountKeyInfoWrapper wrapper3 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.COMPLAINT_TYPE,new String []{'Lost Invoice'},2);
        AccountKeyInfoWrapper wrapper4 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.INCIDENT_TYPE,new String []{'Outage for 48 hours'},2);

        AccountKeyInfoWrapper wrapper5 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.EXPORT_TYPE,new String []{'true'},2);
        AccountKeyInfoWrapper wrapper6 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.PARTNER_TYPE,new String []{'0109902'},2);
        AccountKeyInfoWrapper wrapper7 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.PROMPT_TYPE,new String []{'Meet at the train staition'},2);
        AccountKeyInfoWrapper wrapper8 =  new AccountKeyInfoWrapper(AccountKIBaseSvc.OTHER_TYPE,new String []{'Other info'},2);
        
        List<AccountKeyInfoWrapper> wrapperList = new List<AccountKeyInfoWrapper>();
        wrapperList.add(wrapper3);
        wrapperList.add(wrapper2);
        wrapperList.add(wrapper1);
        wrapperList.add(wrapper4);
        wrapperList.add(wrapper5);
        wrapperList.add(wrapper6);
        wrapperList.add(wrapper7);
        wrapperList.add(wrapper8);
        
        AccountKeyInfoSimpleDecorator decorator = new AccountKeyInfoSimpleDecorator();
        Test.startTest();
            List<AccountKeyInfoWrapper> decoratedCards = decorator.decorate(wrapperList);
        Test.stopTest();
        System.assertEquals(decoratedCards.size(),2,'Should have returned 2 cards' + decoratedCards);
        AccountKeyInfoWrapper card1 = decoratedCards.get(0);
        System.assertEquals(card1.priority,1,'Card 1 should have been first');
        
        
    }
}