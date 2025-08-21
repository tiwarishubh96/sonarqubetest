@isTest
public class TetrisWelcomeSBCENGBEmailTemplateTest {

    public static testMethod void testForTetrisWelcomeSBCENGBEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('WELCOME_SBC_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'completeOrderURL'}, new List<String> {'https://sage.com'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}