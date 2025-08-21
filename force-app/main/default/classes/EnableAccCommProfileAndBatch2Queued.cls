public class EnableAccCommProfileAndBatch2Queued implements Queueable {
    private String commProfileId;
    private String invTemplateId;
    private String zuoraAccountId;
    private String vatNumber;
    private String taxExemptStatus;
    private String defaultPaymentMethodId;
    private String defaultPaymentGateway;
    private boolean isBACS;
    private String batch;
    //#TradingM
    private String tradingEntity;
    private String country;


    //#TradingM
    public EnableAccCommProfileAndBatch2Queued(String commProfileId, String invTemplateId, String zuoraAccountId, String vatNumber,String taxExemptStatus, String defaultPaymentMethodId, String defaultPaymentGateway, boolean isBACS, string batch, String tradingEntity, string country) {
        this.commProfileId = commProfileId;
        this.invTemplateId = invTemplateId;
        this.zuoraAccountId = zuoraAccountId;
        this.vatNumber = vatNumber;
        this.taxExemptStatus =taxExemptStatus;
        this.defaultPaymentMethodId = defaultPaymentMethodId;
        this.defaultPaymentGateway = defaultPaymentGateway;
        this.isBACS = isBACS;
        this.batch = batch;
        //#TradingM
        this.tradingEntity = tradingEntity;
        this.country = country;
    }

    public void execute(QueueableContext context) {
        System.debug('TestZuoraLoginQueuable start');
        //#TradingM
        SendToZBillingUtils.enableAccCommProfileAndBatch(commProfileId, invTemplateId, zuoraAccountId, vatNumber,taxExemptStatus, defaultPaymentMethodId, defaultPaymentGateway, isBACS, batch, tradingEntity);
        SendToZBillingUtils.updatePaymentMethod(defaultPaymentMethodId, country);
        System.debug('TestZuoraLoginQueuable end');
    }
}