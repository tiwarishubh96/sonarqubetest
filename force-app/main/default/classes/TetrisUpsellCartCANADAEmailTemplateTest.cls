@isTest
public class TetrisUpsellCartCANADAEmailTemplateTest {
    public static testMethod void testForTetrisUpsellCartENCAEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('UPSELL_CART_EN_CA', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'existingProductInfo', 'orderContactName'},
                                                                   new List<String> {'Test Product Name', 'Test Product Info', 'Test Contact Name'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
    
    public static testMethod void testForTetrisUpsellCartFRCAEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('UPSELL_CART_FR_CA', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'existingProductInfo', 'orderContactName'},
                                                                   new List<String> {'Test Product Name', 'Test Product Info', 'Test Contact Name'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }

}