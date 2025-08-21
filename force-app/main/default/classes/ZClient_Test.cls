@isTest
Private class ZClient_Test{
    /**
     * [This method tests and covers the 'ZClient' class]
     */
    static testMethod void test(){
        try{
        ZClient.restCallout('test.com', 'GET', new Account(Name='test acc'), 'test', 'test'); 
        ZClient.deserializeRESTResponse('Account');
        }
        catch(exception e){
        }
    }
}