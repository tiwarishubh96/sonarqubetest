@isTest
public class TetrisCrossSellENIEEmailTemplateTest{

    public static testMethod void testForTetrisCrossSellENIEEmailTemplate() {

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('CROSS_SELL_EN_IE', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'existingProductInfo', 'orderContactName'},
                                                                   new List<String> {'Test Product Name', 'Test Product Info', 'Test Contact Name'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}