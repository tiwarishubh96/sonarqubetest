@isTest
public class TetrisProvCompleteENIEEmailTemplateTest {

    public static testMethod void testForTetrisProvCompleteENIEEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('PROVISIONING_COMPLETE_EN_IE', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'loginURL'}, new List<String> {'https://sage.com'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}