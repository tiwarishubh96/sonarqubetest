@isTest
public class TetrisWelcomeENIEEmailTemplateTest {

    public static testMethod void testForTetrisWelcomeENIEEmailTemplate(){

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('WELCOME_EN_IE', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(new List<String> {'firstName', 'lastName', 'loginURL'},
                                                                   new List<String> {'Test First Name', 'Test Last Name', 'https://sage.com'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}