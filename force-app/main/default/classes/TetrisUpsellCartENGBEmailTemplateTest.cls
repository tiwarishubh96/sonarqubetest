@isTest
public class TetrisUpsellCartENGBEmailTemplateTest {

    public static testMethod void testForTetrisUpsellCartENGBEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('UPSELL_CART_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'existingProductInfo', 'orderContactName'},
                                                                   new List<String> {'Test Product Name', 'Test Product Info', 'Test Contact Name'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}