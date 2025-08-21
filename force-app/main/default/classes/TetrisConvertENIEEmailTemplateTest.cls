@isTest
public class TetrisConvertENIEEmailTemplateTest{
    public static testMethod void testForTetrisConvertENIEEmailTemplate() {

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('CONVERT_CART_EN_IE', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'orderContactName', 'buyerEmail'},
                                                                   new List<String> {'Test Product Name', 'Test Contact Name', 'test@sage.com'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}