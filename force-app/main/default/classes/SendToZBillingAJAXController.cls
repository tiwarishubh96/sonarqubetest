/**
 * This Class controls the send to Z-Billing button, it calls SendToZBilling Method from the Zuora
 * Package, generates the Invoice number in salesforce, then calls the UpdateInvoiceStatusQueued to
 * update the obligatory fields on Zuora invoice and send the regional invoice number over to Zuora
 */
global class SendToZBillingAJAXController
{

    //Consolidated thhe logic for Sage Live and Sage one into SendToZBillingUtils
    //based on conversation with Yong and Docmation. 
    //2016-07-19  

    /**
     * [callZQuoteGlobal performs various checks and collects various reference data and if successful calls the Zuora sendToZBilling method
     *  which will create/update the account and subscription in zuora based on the information in the quote
     *  If the sendToZBilling call is successful and an invoice has been generated then it calls the UpdateInvoiceStatusQueued queue to insert
     *  the regional invoice number into the invoice before re-generating it and posting it so that it is emailed to the customer.
     *  If the sendToZBilling call is successful and an invoice has not been generated then it calls the enableAccCommProfileAndBatch2 to update
     *  the account settings in zuora so that it is ready for when the invoice is created in the future (on the date that the service starts)]
     * @param quoteId [SFDC quote id]
     * @return [return status message of the send to z-billing process: "Send to Z-Billing was successful" if the operation succeeded
     *                  else "Send to Z-Billing was unsuccessful:" + the error message]
     */
     //Added String clientCode by VENI
    webService static String callZQuoteGlobal(String quoteId,String clientCode){

        //Returns the Invoice Status
        //Added String clientCode by Veni
        return(SendToZBillingUtils.callZQuoteGlobal(quoteId,clientCode));

    }

 
}