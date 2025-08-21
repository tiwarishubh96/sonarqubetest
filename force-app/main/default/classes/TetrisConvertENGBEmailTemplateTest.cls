@isTest
    public class TetrisConvertENGBEmailTemplateTest{
        public static testMethod void testForTetrisConvertENGBEmailTemplate() {

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('CONVERT_CART_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'orderContactName', 'buyerEmail'},
                                                                   new List<String> {'Test Product Name', 'Test Contact Name', 'test@buyerEmail.com'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}