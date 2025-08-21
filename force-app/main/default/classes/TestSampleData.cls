@isTest
public class TestSampleData {
   
    public Static Set<String> getValues()
    {
        String data = 'test';
        Set<String> fetchData = new Set<String>();
		for(Integer i=1; i<=10; i++)
        {
            String newData = data+i;
            fetchData.add(newData);
        }
        return fetchData;
    }
    
    public Static string getObject()
    {
        return 'Account';
    }
}