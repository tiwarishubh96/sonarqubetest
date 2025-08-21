/**
 * Created by cafe on 2/2/2021.
 */

/**
* @author Rishu Garg, Docmation
* @creationDate Feb 2, 2021
*
* @description REST API to create Account,Contact,Lead and Opportunity In Salesforce which is invoked by MuleSoft. This API
*			   is used in TETRIS R2.
*
* Modification Log
* ------------------------------------------------------------------------------------------------------------
* 1.0 - Feb 2, 2021 - Rishu Garg
*       Created the initial version to create Account,Contact,Lead and Opportunity in Salesforce through a REST API.
* ------------------------------------------------------------------------------------------------------------
 *
 * Dependencies
    TetrisAccountModel
    TetrisAccountResultModel
    TetrisContactModel
    TetrisAddressModel
    TetrisAccountManagerV2
    Tetris_Locale_Default_Address__mdt
    TetrisAccountException
*/

@RestResource(urlMapping='/TetrisAccountServiceV2')
global with sharing class TetrisAccountServiceV2 {

    /*
     * @description HTTP POST method to create Account,Contact,Lead and Opportunity in Salesforce
     * @param		name				Account Name
     * @param       cartId      		Encrypted ID for the Cart (deprecated for CC replacement)
     * @param       transactionType		Indicates "Try", "Buy", "Convert" flows
     * @param       leadCreation        Boolean to indicate lead creation (always true except perhaps in tests)
     * @param       salesOffice         SalesOffice (deprecated for CC replacement)
     * @param       userLocale          UserLocale like en_GB
     * @param       userCurrency        UserCurrency
     * @param       contact             Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @return		Returns the data populated in a Custom Model class with the Account Related info
     */
    @HttpPost
    global static TetrisAccountResultModel createAccount(String name, String cartId, boolean leadCreation,
            String transactionType, String salesOffice, String userLocale,
            String userCurrency, TetrisContactModel contact, TetrisAddressModel billTo, boolean emailOptin) {
        Boolean createOpportunity = true;
        return createAccount(name, cartId, leadCreation, transactionType, salesOffice, userLocale, userCurrency, contact, billTo, emailOptin, createOpportunity);
    }

    /*
     * @description Method to create Account,Contact,Lead and Opportunity in Salesforce
     * @param		name				Account Name
     * @param       cartId      		Encrypted ID for the Cart (deprecated for CC replacement)
     * @param       transactionType	    Indicates "Try", "Buy", "Convert" flows
     * @param       leadCreation        Boolean to indicate lead creation (always true except perhaps in tests)
     * @param       salesOffice         SalesOffice (deprecated for CC replacement)
     * @param       userLocale          UserLocale like en_GB
     * @param       userCurrency        UserCurrency
     * @param       contact             Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @param       createOpportunity   Boolean to indicate opportunity creation (always true except in tests)
     * @return		Returns the data populated in a Custom Model class with the Account Related info
     */
    global static TetrisAccountResultModel createAccount(String name, String cartId, boolean leadCreation,
            String transactionType, String salesOffice, String userLocale,
            String userCurrency, TetrisContactModel contact, TetrisAddressModel billTo, boolean emailOptin,
            boolean createOpportunity) {
        TetrisAccountResultModel accountResult = new TetrisAccountResultModel();
        try {
            TetrisAccountManagerV2 accountManager = new TetrisAccountManagerV2();
            return accountManager.invokeNewAccountFlow(name, cartId, leadCreation,
                    transactionType, salesOffice, userLocale,
                    userCurrency, contact, billTo, emailOptin, createOpportunity);
        } catch (Exception ex) {
            accountResult.setErrorMessage(ex.getMessage());
            accountResult.setStatus(false);
            ExceptionHandler.CatchException('TetrisAccountService', 'createAccount', ex);
        }
        return accountResult;
    }

    /*
    * TODO: we should remove the unused arguments at some point (requires careful release co-ordination though!)
    * @description HTTP PATCH method to update Account,Contact and Opportunity in Salesforce
    * @param		accountId		     Salesforce Account ID
    * @param       name                 Account Name
    * @param       cartId      		 Encrypted ID for the Cart (deprecated for CC replacement)
    * @param       transactionType		 Indicates "Try", "Buy", "Convert" flows
    * @param       leadCreation         Boolean to indicate lead creation (always false, except perhaps in tests)
    * @param       salesOffice          SalesOffice (deprecated for CC replacement)
    * @param       userLocale           UserLocale like en_GB
    * @param       userCurrency         UserCurrency
    * @param       zuoraAccountId       Zuora Account Id
    * @param       zuoraAccountCreation Boolean to Indicate creation of account in Zuora
    * @param       contact              Custom Model class with the Contact Related info
    * @param       billTo               Custom Model class with the Address Related info
    * @return		Returns the data populated in a Custom Model class with the Account Related info
    */
    @HttpPatch
    global static TetrisAccountResultModel updateAccount(String accountId, String name, String cartId, String zuoraAccountId,
            boolean leadCreation, boolean zuoraAccountCreation,
            String transactionType, String salesOffice, String userLocale,
            String userCurrency, TetrisContactModel contact, TetrisAddressModel billTo, boolean emailOptin, boolean leadUpdate, String leadId) {

        TetrisAccountResultModel accountResult = new TetrisAccountResultModel();

        try {
            TetrisAccountManagerV2 accountManager = new TetrisAccountManagerV2();
            accountResult = accountManager.invokeUpdateAccountFlow(
                    accountId, name, cartId, leadCreation, transactionType, salesOffice,
                    userLocale, userCurrency, contact, billTo, emailOptin);

            accountResult.transactionType = transactionType;

            return accountResult;
        } catch (Exception ex) {
            accountResult.setErrorMessage(ex.getMessage());
            accountResult.setStatus(false);
            ExceptionHandler.CatchException('TetrisAccountService', 'updateAccount', ex);
        }
        return accountResult;
    }
}