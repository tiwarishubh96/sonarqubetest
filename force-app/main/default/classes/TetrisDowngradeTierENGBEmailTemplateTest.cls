@isTest
public class TetrisDowngradeTierENGBEmailTemplateTest {

    public static testMethod void testForTetrisDowngradeTierENGBEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('DOWNGRADE_TIER_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'productNames', 'orderContactName'},
                                                                   new List<String> {'Test Product Name', 'Test Contact Name'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}