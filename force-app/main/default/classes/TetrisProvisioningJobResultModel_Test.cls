@isTest(SeeAllData=false) 
private class TetrisProvisioningJobResultModel_Test {
    
     static testMethod void testSettersGetters() {
    TetrisProvisioningJobResultModel tetrisProvisionModelObj = new TetrisProvisioningJobResultModel();
   tetrisProvisionModelObj.jobId ='1212';
    tetrisProvisionModelObj.jobName = 'Create SLCS Subscription';
   tetrisProvisionModelObj.createdDate =System.today();
   tetrisProvisionModelObj.accountId = '0015E00000cf5op';
   tetrisProvisionModelObj.isMock = true;
   tetrisProvisionModelObj.jobEvent ='Create SLCS Subscription';
   tetrisProvisionModelObj.jobStatus ='Completed';
   tetrisProvisionModelObj.lastProcessingDate = System.today();
  tetrisProvisionModelObj.retryAccount = 5;
  tetrisProvisionModelObj.slcsRequestPayload ='slcsRequestPayload';
  tetrisProvisionModelObj.slcsActivityUrl='slcsActivityUrl';
 tetrisProvisionModelObj.tetrisAPIRequestPayload ='tetrisAPIRequestPayload';
 tetrisProvisionModelObj.tetrisSubscriptionId ='tetrisSubscriptionId';
 tetrisProvisionModelObj.slcsResponsePayload ='slcsResponsePayload';
         
  system.assertEquals( tetrisProvisionModelObj.slcsResponsePayload, 'slcsResponsePayload') ;
  system.assertEquals( tetrisProvisionModelObj.tetrisSubscriptionId , 'tetrisSubscriptionId') ;
  system.assertEquals(tetrisProvisionModelObj.tetrisAPIRequestPayload, 'tetrisAPIRequestPayload') ;
  system.assertEquals(tetrisProvisionModelObj.slcsActivityUrl , 'slcsActivityUrl') ;
   system.assertEquals( tetrisProvisionModelObj.retryAccount, 5) ;
  system.assertEquals( tetrisProvisionModelObj.slcsRequestPayload , 'slcsRequestPayload') ;
  system.assertEquals(tetrisProvisionModelObj.jobStatus, 'Completed') ;
  system.assertEquals(tetrisProvisionModelObj.lastProcessingDate , System.Today()) ; 
   system.assertEquals(tetrisProvisionModelObj.jobEvent , 'Create SLCS Subscription') ;
   system.assertEquals( tetrisProvisionModelObj.isMock, true) ;
  system.assertEquals( tetrisProvisionModelObj.accountId , '0015E00000cf5op') ;
  system.assertEquals(tetrisProvisionModelObj.createdDate, System.Today()) ;
  system.assertEquals(tetrisProvisionModelObj.jobId ,'1212' ) ;  
  system.assertEquals(tetrisProvisionModelObj.jobName , 'Create SLCS Subscription') ;         
}
    
}