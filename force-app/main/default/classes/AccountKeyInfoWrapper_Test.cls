@isTest
public with sharing class AccountKeyInfoWrapper_Test {

    @isTest static void testComparatorSort(){
        AccountKeyInfoWrapper wrapper1 =  new AccountKeyInfoWrapper('ONE',new String []{''},1);
        AccountKeyInfoWrapper wrapper2 =  new AccountKeyInfoWrapper('TWO',new String []{''},2);
        AccountKeyInfoWrapper wrapper3 =  new AccountKeyInfoWrapper('THREE',new String []{''},3);

        List<AccountKeyInfoWrapper> unorderedWrapperList = new List<AccountKeyInfoWrapper>();
        unorderedWrapperList.add(wrapper2);
        unorderedWrapperList.add(wrapper1);
        unorderedWrapperList.add(wrapper3);
        System.assertEquals(unorderedWrapperList.get(0),wrapper2);
        System.assertEquals(unorderedWrapperList.get(1),wrapper1);
        System.assertEquals(unorderedWrapperList.get(2),wrapper3);

        unorderedWrapperList.sort();
        System.assertEquals(unorderedWrapperList.get(0),wrapper1,'Expected 1 but got : ' + unorderedWrapperList.get(0).priority);
        System.assertEquals(unorderedWrapperList.get(1),wrapper2,'Expected 2 but got : ' + unorderedWrapperList.get(0).priority);
        System.assertEquals(unorderedWrapperList.get(2),wrapper3,'Expected 3 but got : ' + unorderedWrapperList.get(0).priority);

    }

}