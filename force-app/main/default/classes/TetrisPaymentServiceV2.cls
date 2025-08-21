/**
 * Created by cafe on 2/4/2021.
 */
@RestResource(urlMapping='/TetrisPaymentServiceV2')
global without sharing class TetrisPaymentServiceV2 {

    @HttpPost
    global static TetrisPaymentModel getPaymentMethods(String countryCode, String paymentMethod) {
        TetrisPaymentModel paymentModel = new TetrisPaymentModel();
        try {
            TetrisPaymentHelperV2 paymentHelper = new TetrisPaymentHelperV2();
            if (String.isBlank(paymentMethod)) {
                paymentModel = paymentHelper.getPaymentPageSettings(countryCode, null);
            } else {
                paymentModel = paymentHelper.getPaymentPageSettings(countryCode, paymentMethod);
            }
            paymentModel.setStatus(true);
        } catch (Exception ex) {
            paymentModel.setErrorMessage(ex.getMessage());
            paymentModel.setStatus(false);
            ExceptionHandler.CatchException('TetrisPaymentService', 'getPaymentMethods', ex);
        }
        return paymentModel;
    }

    @RemoteAction
    global static TetrisPaymentModel fetchPaymentMethods(String countryCode, String paymentMethod) {
        return getPaymentMethods(countryCode, paymentMethod);
    }
}