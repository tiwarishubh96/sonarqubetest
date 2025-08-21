@isTest
private class KnowledgeDataCategoryWrapperTest
{


@isTest
static void test1()
{
    DataCategoryWrapper dc = new DataCategoryWrapper();
    dc.DataCategoryGroupName = 'testGroupName';
    dc.DataCategoryName = 'TestCategoryName';
    KnowledgeDataCategoryWrapper kdc = new KnowledgeDataCategoryWrapper(dc);

    Integer res = kdc.compareTo(kdc);
    System.assertEquals(res , 0);

}


@isTest
static void test2()
{
    DataCategoryWrapper dc = new DataCategoryWrapper();
    dc.DataCategoryGroupName = 'testGroupName';
    dc.DataCategoryName = 'TestCategoryName';
    KnowledgeDataCategoryWrapper kdc = new KnowledgeDataCategoryWrapper(dc);


    DataCategoryWrapper dc1 = new DataCategoryWrapper();
    dc1.DataCategoryGroupName = 'testGroupNameTest';
    dc1.DataCategoryName = 'TestCategoryNameTest';
    KnowledgeDataCategoryWrapper kdc1 = new KnowledgeDataCategoryWrapper(dc1);


    Integer res =  kdc1.compareTo(kdc);
    // 1
    System.assertEquals(res , 1);
    
}

@isTest
static void test3()
{
    DataCategoryWrapper dc = new DataCategoryWrapper();
    dc.DataCategoryGroupName = 'testGroupName';
    dc.DataCategoryName = 'TestCategoryName';
    KnowledgeDataCategoryWrapper kdc = new KnowledgeDataCategoryWrapper(dc);


    DataCategoryWrapper dc1 = new DataCategoryWrapper();
    dc1.DataCategoryGroupName = 'testGroup';
    dc1.DataCategoryName = 'TestCategory';
    KnowledgeDataCategoryWrapper kdc1 = new KnowledgeDataCategoryWrapper(dc1);


    Integer res = kdc1.compareTo(kdc);
    System.assertEquals(res , -1);
    // -1
    
}

}