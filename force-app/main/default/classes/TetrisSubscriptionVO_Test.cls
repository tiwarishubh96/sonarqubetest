@isTest
public class TetrisSubscriptionVO_Test {
    
    public static testmethod void testForRequest(){ 
    TetrisSubscriptionVO.Request tetRequest = new TetrisSubscriptionVO.Request();
    tetRequest.subscriptionItemId='1234567899';
    tetRequest.subscriptionId='123456';
    tetRequest.actionType='Test';
    tetRequest.cancellationEffectiveDate=Date.today();
    tetRequest.notes='Test';
    tetRequest.reactivationDate = Date.today();
    tetRequest.promotionType = '';
    tetRequest.bundleName ='Bundle';
    tetRequest.bundleInstance ='123'; 
    tetRequest.bundleDesc ='Bundle Desc'; 
    tetRequest.zuoraSubscriptionId='12345';
    tetRequest.zuoraSubscriptionName='Test';
    tetRequest.billingFrequency='Monthly';
    tetRequest.couponCode = 'test12';
    tetRequest.couponId='1222l';
    tetRequest.length ='3';
    tetRequest.period ='Month';
    tetRequest.products=null;
	
        TetrisSubscriptionVO.Errors tetErr = new TetrisSubscriptionVO.Errors();
        tetErr.errorCode ='401';
        tetErr.message= 'unauthorized';
        List<TetrisSubscriptionVO.Errors> tetErrList = new List<TetrisSubscriptionVO.Errors>();
        tetErrList.add(tetErr);
  
        TetrisSubscriptionVO.Result tetResult = new TetrisSubscriptionVO.Result();
        TetrisSubscriptionVO.Response tetRes = new TetrisSubscriptionVO.Response();
        tetRes.success='Success';
        tetRes.result= tetResult;
        tetRes.errors=tetErrList;
        
    }

}