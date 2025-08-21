@isTest
public class TetrisProvCompleteENGBEmailTemplateTest {

    public static testMethod void testForTetrisProvCompleteENGBEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('PROVISIONING_COMPLETE_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'isSageAccountantCloud', 'loginURL'},
                                                                   new List<String> {'true', 'https://sage.com'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}