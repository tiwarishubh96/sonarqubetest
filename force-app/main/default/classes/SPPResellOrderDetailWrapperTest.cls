/*-------------------------------------------------------------
    Author:         Lu
    Date :          03/23/2018
    Company:       Docmation LLC
    Description:   Test Class for SPPResellOrderDetailWrapper
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

@isTest
public class SPPResellOrderDetailWrapperTest {
	
    Static TestMethod void TestOrderDetail(){
        
        SPPTestData.creatAccount(1);
        
        Account acct = [SELECT ID FROM Account LIMIT 1];
        
        SPPResellOrderDetailWrapper reg = new SPPResellOrderDetailWrapper('Test','Test','Test','Test','Test','Test','Test',acct.id);
        
        SPPResellOrderDetailWrapper noParam = new SPPResellOrderDetailWrapper();
        
        SPPResellOrderDetailWrapper threeParam = new SPPResellOrderDetailWrapper('Test',acct.id,'Test');
    }
    
}