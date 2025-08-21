/**
 * Created by cafe on 2/2/2021.
 */

@isTest
public class TetrisAccountServiceV2_Test {

    private static final String accountName = 'TestAcc';

    private static final String transactionType = 'try';

    private static final String zuoraAccountId = null;
    private static final boolean leadCreation = false;
    private static final boolean zuoraAccountCreation = false;


    private static final TetrisAddressModel billTo = new TetrisAddressModel();
    private static final TetrisContactModel contactModelObj = new TetrisContactModel();


    @testSetup static void setup() {


    }


    @isTest static void testCreateAccount() {
        String name = accountName;

        billTo.addressLine1 = '123 St';
        billTo.city = 'London';
        billTo.country = 'United Kingdom';

        contactModelObj.firstName = StringUtils.createRandomString(5);
        contactModelObj.lastName = StringUtils.createRandomString(5);
        contactModelObj.email = 'test@test.com';
        contactModelObj.phone = '252 142 1111';

        //system.debug('---------billTo-------'+billTo);
        TetrisAccountResultModel tetrisAccObject = TetrisAccountServiceV2.createAccount(name, null, false, transactionType, 'Dublin CBC', 'en_GB',
                'GBP', contactModelObj, billTo, true, false);
        System.debug('Account Created: ' + tetrisAccObject);
        System.assertNotEquals(null, tetrisAccObject.accountId);
        System.assertEquals(null, tetrisAccObject.message);
    }

    @isTest static void testCreateAccountExceptions() {
        String name = accountName;

// Exception for missing cartId

//system.debug('---------billTo-------'+billTo);
        try {
            TetrisAccountResultModel tetrisAccObject = TetrisAccountServiceV2.createAccount(name, null, false, transactionType, 'Dublin CBC', 'en_GB' ,
                   'GBP' , contactModelObj, billTo, true, false);

            //System.debug('Account Created: '+tetrisAccObject);
        } catch (Exception ex) {
            //System.debug('Account Create Error: '+ex);

        }
    }

    @isTest static void testUpdateAccount() {


        billTo.addressLine1 = '123 St';
        billTo.city = 'London';
        billTo.country = 'United Kingdom';

        contactModelObj.firstName = StringUtils.createRandomString(5);
        contactModelObj.lastName = StringUtils.createRandomString(5);
        contactModelObj.email = 'test@test.com';
        contactModelObj.phone = '252 142 1111';

        TetrisAccountResultModel tetrisAccObject = TetrisAccountServiceV2.createAccount(accountName, null, false, transactionType, 'Dublin CBC', 'en_GB',
                'GBP', contactModelObj, billTo, true, false);
        System.debug('Test Setup Account Created: ' + tetrisAccObject);
        try {
            TetrisAccountResultModel tetrisObject = TetrisAccountServiceV2.updateAccount(tetrisAccObject.accountId, accountName, NULL, zuoraAccountId,
                    leadCreation, zuoraAccountCreation,
                    transactionType, 'Dublin CBC', 'en_GB',
                    'GBP', contactModelObj, billTo, true, false, null);
//System.debug('Acc Updated: '+tetrisObject);

        } catch (Exception expObj) {
            System.assert(false, expObj.getMessage());
        }
    }

    @isTest static void testUpdateAccountExceptions() {
        contactModelObj.firstName = StringUtils.createRandomString(5);
        contactModelObj.lastName = StringUtils.createRandomString(5);
        contactModelObj.email = 'test@test.com';
        contactModelObj.phone = '252 142 1111';
        TetrisAccountResultModel tetrisAccObject = TetrisAccountServiceV2.createAccount(accountName, null, false, transactionType, 'Dublin CBC', 'en_GB',
                'GBP', contactModelObj, billTo, true, false);
        System.debug('Test Setup Account Created: ' + tetrisAccObject);
        try {
            TetrisAccountResultModel tetrisObject = TetrisAccountServiceV2.updateAccount(tetrisAccObject.accountId, accountName, NULL, zuoraAccountId,
                    leadCreation, zuoraAccountCreation,
                    transactionType, 'Dublin CBC', 'en_GB',
                    'GBP', null, billTo, true, false, null);
//System.debug('Acc Updated: '+tetrisObject);
            System.assertEquals('EXCEPTION_ACCOUNT_UPDATE_ACCOUNT', tetrisObject.message);
        } catch (Exception expObj) {
//System.debug('Assert Error: '+expObj);
//Exception should be handled by class not test case
            System.assert(false, expObj.getMessage());
        }
        try {
            TetrisAccountResultModel tetrisObject = TetrisAccountServiceV2.updateAccount(tetrisAccObject.accountId, accountName, null, zuoraAccountId,
                    leadCreation, zuoraAccountCreation,
                    transactionType, 'Dublin CBC', 'en_GB',
                    'GBP', null, billTo, true, false, null);
//System.debug('Acc Updated: '+tetrisObject);

        } catch (Exception expObj) {
//Exception should be handled by class not test case
            System.assert(false, expObj.getMessage());
        }
    }
}