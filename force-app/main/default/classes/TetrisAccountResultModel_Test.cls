@isTest(SeeAllData=false)
private class TetrisAccountResultModel_Test {
	
    static testMethod void testSettersGetters() {
       	TetrisAccountResultModel tetrisModel = new TetrisAccountResultModel();
    		tetrisModel.accountId = '0013242342';
    		tetrisModel.contactId = '0032342131';
    		tetrisModel.leadId = '0021424124';
    		tetrisModel.opportunityId = '00423423422';
    		tetrisModel.zuoraAccountId = 'C-23423';
    		tetrisModel.cartId = '234234213421';
    		tetrisModel.communicationProfileId = '2412341243';
    		tetrisModel.invoiceTemplateId = '4124145452';
    		tetrisModel.paymentGateway = '34324234114';
    		tetrisModel.vatNumber = 'VAT2321';
    		tetrisModel.taxExempt = true;
    		system.assertEquals(tetrisModel.accountId , '0013242342') ;
    		system.assertEquals(tetrisModel.contactId , '0032342131') ;
    		system.assertEquals(tetrisModel.leadId , '0021424124') ;
    		system.assertEquals(tetrisModel.opportunityId , '00423423422') ;
    		system.assertEquals(tetrisModel.zuoraAccountId , 'C-23423') ;
    		system.assertEquals(tetrisModel.cartId , '234234213421') ;
    		system.assertEquals(tetrisModel.communicationProfileId , '2412341243') ;
    		system.assertEquals(tetrisModel.invoiceTemplateId , '4124145452') ;
    		system.assertEquals(tetrisModel.paymentGateway , '34324234114') ;
    		system.assertEquals(tetrisModel.vatNumber , 'VAT2321') ;
    		system.assertEquals(tetrisModel.taxExempt , true) ;
    		
    		tetrisModel.message = 'Success';
    		tetrisModel.status = true;
    		
    		tetrisModel.setErrorMessage('Success');
    		tetrisModel.setStatus(true);
    		tetrisModel.getErrorMessage();
    		tetrisModel.getStatus();
    }
}