@RestResource(urlMapping='/TetrisZuoraEffectiveDatesServiceV2')
global with sharing class TetrisZuoraEffectiveDatesServiceV2 {

    @HttpPost
    global static TetrisZuoraModel getZuoraNextInvoiceDate(String zuoraSubscriptionId) {

        TetrisZuoraModel response = new TetrisZuoraModel();

        try {
            If (!String.IsBlank(zuoraSubscriptionId)) {
                response = TetrisZuoraHelperV2.getZuoraNextInvoiceDate(zuoraSubscriptionId);
            }

            else {
                throw new TetrisSubscriptionException(TetrisSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_ZUORA_SUBSCRIPTION_NUMBER);
            }
        } catch (Exception ex) {
            response.setErrorMessage(ex.getMessage());
            response.setStatus(false);
            ExceptionHandler.CatchException('TetrisZuoraEffectiveDatesService', 'getZuoraNextInvoiceDate', ex);
        }
        return response;
    }
}