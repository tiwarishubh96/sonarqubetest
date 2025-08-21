@isTest
public class TetrisOrderConfirmENGBEmailTemplateTest{
    public static testMethod void testForTetrisOrderConfirmENGBEmailTemplate() {

        TetrisEmail.Builder tetrisEmailBuilder = new TetrisEmail.Builder('ORDER_CONFIRM_EN_GB', 'test@sage.com');
        List<TetrisEmailTemplateValueModel> templateValues = new List<TetrisEmailTemplateValueModel>();

        templateValues = EmailTemplateTestHelper.getTemplateValues(
            new List<String> {'setupYourAccountUrl', 'subscriptionName', 'firstName', 'lastName', 'createdDate'},
            new List<String> {'https://sage.com', 'Test Subscription Name', 'Test First Name', 'Test Last Name', '01/01/2019'});

        EmailTemplateTestHelper.testEmailBody(tetrisEmailBuilder, templateValues);
    }
}