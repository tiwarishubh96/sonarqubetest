@isTest
public class PublishAccountMuleMessageTest {
    
    Static testMethod void muleResponsePareser(){
        PublishAccountMuleMessage accMule = new PublishAccountMuleMessage();
        Map<String, String> eventIdToRecId = new Map<String, String>(); 
        eventIdToRecId.put('2d3042bf-babb-8d81-9a62-207d521c593c', '0017E00000Y3gFBQAZ');
        String reponseResult = '{"publishResponse": {"responses": {"response": [{'+
            '"eventId": "2d3042bf-babb-8d81-9a62-207d521c593c","messageId": "","error": {"exceptions": {'+
            '"errordetail": [{"errorCode": "BAD_REQUEST",'+
            '"errorMessage": "Invalid messageType [Record1], Valid value is one of "'+
            '}]},"eventSource": "Global-SFDC","region": "NorthAmerica","eventDate": "2017-07-24T19:04:27:027Z",'+
            '"messageType": "Record1","recordType": "Account","messageBody": {"Account": {'+
            '"zuoraPayChangeSubmitCount": 0,"zuoraPayChangeLastSubmitDate": null,"zuoraCountryCode": "US",'+
            '"x1099CodeUSVendorsOnly": "Not 1099-able","website": null,"vendorType": null,"vatNumber": null,'+
            '"tickerSymbol": null,"technicalSupportContact": null,"taxIDNumberTIN": null,"taxIDNumber": null,'+
            '"partnerResellerTnC": false,"partnerRenewalDate": null,"partnerISVTnC": false,"partnerIntegration": false,'+
            '"partnerImplementationTnC": false,"partnerEffectiveDate": "2017-07-04","partnerAllianceTnC": false,'+
            '"partnerAgreement": "On-line","partnerAccountantId": "1233","localCRMRegion": "AMR","localCRMName": "FUS - Fusion",'+
            '"localCRMCountry": "CA - Canada","localCRMAccountId": "5000656","localAPSystemId": null,'+
            '"globalAccountId": "0017E00000Y3gFBQAZ","createdDate": "2017-06-13T13:53:55.000Z",'+
            '"billingStreet": "325 Ivy Chase  Norcross","billingState": "Georgia","billingPostalCode": "30092",'+
            '"billingCountry": "United States","billingCity": "Atlanta"}}}}]}}}';
        accMule.parseResponse(eventIdToRecId,reponseResult);
    }
}