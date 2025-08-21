@isTest
public class TetrisWelcomeENGBEmailTemplateTest {
    public static testMethod void testForTetrisWelcomeENGBEmailTemplate() {

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('WELCOME_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'firstName'}, new List<String> {'Test First Name'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}