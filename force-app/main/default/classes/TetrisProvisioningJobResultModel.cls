global class TetrisProvisioningJobResultModel extends TetrisBaseModel {
    
	global String jobId;
    global String jobName;
    global Datetime createdDate;
    global String accountId;
    global Boolean isMock;
    global String jobEvent;
    global String jobStatus;
    global Datetime lastProcessingDate;
    global Decimal retryAccount;
    global String slcsRequestPayload;
    global String slcsActivityUrl;
    global String tetrisAPIRequestPayload;
    global String tetrisSubscriptionId;
    global String slcsResponsePayload;

}