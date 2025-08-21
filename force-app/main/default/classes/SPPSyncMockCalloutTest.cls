@isTest
global class SPPSyncMockCalloutTest{
    

global class SPPAccountMockTest implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String respone = '{'+
    '"publishResponse": {'+
        '"responses": {'+
            '"response": ['+
                '{'+
                    '"eventId": "8202ce6c-6be9-4ed7-b431-4efd24d41114",'+
                    '"messageId": "9383e53e-40b4-56ee-a3e8-b73e341ae3ef"'+
                '},'+
                '{'+
                    '"eventId": "8202ce6c-6be9-4ed7-b441-4efd24d41113",'+
                    '"messageId": "",'+
                    '"error": {'+
                     '   "exceptions": {'+
                      '      "errordetail": ['+
                       '         {'+
                        '            "errorCode": "400",'+
                         '           "errorMessage": "Another Message with the same Event ID was processed earlier"'+
                          '      }'+
                           ' ]'+
                        '},'+
                        '"eventSource": "Global-SFDC",'+
                        '"region": "UKI",'+
                        '"eventDate": "2013-09-29T18:46:19:123Z",'+
                        '"messageType": "Record",'+
                        '"recordType": "Account",'+
                        '"messageBody": {'+
                         '   "Account ": {'+
                          '      "globalAccountId": "0019E000009ShyyQAC",'+
                           '     "billingStreet": "1 Street",'+
                             '   "billingCity": "Beverly Hills",'+
                              '  "billingState": "California",'+
                                '"billingPostalCode": "90210-1234",'+
                                '"billingCountry": "United States",'+
                                '"currencyIsoCode": "USD",'+
                                '"description": "Initial Load description",'+
                                '"industry": "Apperal",'+
                                '"name": "Initial Load",'+
                                '"numberOfEmployees ": "1-4 Employees",'+
                                '"sic": "20 - Apperal"'+
                                
                            '}'+
                       ' }'+
                    '}'+
                '}'+
           ' ]'+
        '}'+
    '}'+
'}';
        res.setBody(respone);
        return res;
    }
    
}
    global class SPPContactMockTest implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req) 
        {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String respone = '{'+
        '"publishResponse": {'+
        '"responses": {'+
            '"response": ['+
                '{'+
                    '"eventId": "8202ce6c-6be9-4ed7-b431-4efd24d41114",'+
                    '"messageId": "9383e53e-40b4-56ee-a3e8-b73e341ae3ef"'+
                '},'+
                '{'+
                    '"eventId": "8202ce6c-6be9-4ed7-b441-4efd24d41113",'+
                    '"messageId": "",'+
                    '"error": {'+
                     '   "exceptions": {'+
                      '      "errordetail": ['+
                       '         {'+
                        '            "errorCode": "400",'+
                         '           "errorMessage": "Another Message with the same Event ID was processed earlier"'+
                          '      }'+
                           ' ]'+
                        '},'+
                        '"eventSource": "Global-SFDC",'+
                        '"region": "UKI",'+
                        '"eventDate": "2013-09-29T18:46:19:123Z",'+
                        '"messageType": "Record",'+
                        '"recordType": "Contact",'+
                        '"messageBody": {'+
                         '   "Contact ": {'+
                            '"twitter": null,"title": null,"technical": true,"tacticId": null,'+
                            '"salutation": null,"sales": true,"reportsTo": null,"product": null,"primary": true,'+
                            '"preferredMethodOfContact": null,"phone": "234-567-7889","ownerId": null,"otherStreet": null,'+
                            '"otherState": null,"otherPostalCode": null'+
                            '}'+
                       ' }'+
                    '}'+
                '}'+
           ' ]'+
        '}'+
    '}'+
'}';
        res.setBody(respone);
        return res;
    }
    
}
 global class RnRSurveyMockTest implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest req){
  HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String respone ='{'+
        '   \"publishResponse\": {'+
        '       \"responses\": {'+
        '           \"response\": ['+
        '               {'+
        '                   \"eventId\": \"8202ce6c-6be9-4ed7-b431-4efd24d41114\",'+
        '                   \"messageId\": \"9383e53e-40b4-56ee-a3e8-b73e341ae3ef\"'+
        '               },'+
        '               {'+
        '                   \"eventId\": \"8202ce6c-6be9-4ed7-b441-4efd24d41113\",'+
        '                   \"messageId\": \"\",'+
        '                   \"error\": {'+
        '                       \"exceptions\": {'+
        '                           \"errordetail\": ['+
        '                               {'+
        '                                   \"errorCode\": \"400\",'+
        '                                   \"errorMessage\": \"Another Message with the same Event ID was processed earlier\"'+
        '                               }'+
        '                           ]'+
        '                       },'+
        '                       \"eventSource\": \"Germany-CRM\",'+
        '                       \"region\": \"Survey\",'+
        '                       \"eventDate\": \"2013-09-29T18:46:19:123Z\",'+
        '                       \"messageType\": \"Record\",'+
        '                       \"recordType\": \"Survey\",'+
        '                       \"messageBody\": {'+
        '                           \"Survey\": {'+
        '                               \"commentId\": null,'+
        '                               \"callSource\": \"Email\",'+
        '                               \"notes\": null,'+
        '                               \"callCommentcategory\": \"Customer Care\",'+
        '                               \"territory\": \"Deutschland\",'+
        '                               \"accountNumber\": 142182682,'+
        '                               \"agentSalutation\": \"MR.\",'+
        '                               \"agentFirstName\": \"John\",'+
        '                               \"agentLastName\": \"Dow\",'+
        '                               \"agentName\": \"Mr.John Dow\",'+
        '                               \"customerPhone\": \"004969500070\",'+
        '                               \"agentmanager\": \"Paul Mathew\",'+
        '                               \"customerTenure\": \"2000-02-22 23:00:00.000\",'+
        '                               \"serialNumber\": \"H243101\",'+
        '                               \"companyName\": \"Solarkraftwerk Ebsdorf\",'+
        '                               \"callDateTime\": \"2017-11-17 14:18:21\",'+
        '                               \"callDuration\": \"831\",'+
        '                               \"productName\": \"Personalwirtschaft Standard Payroll\",'+
        '                               \"productTenure\": null,'+
        '                               \"agentId\": \"U6UJ9A00003K\",'+
        '                               \"courtesyCall\": \"False\",'+
        '                               \"customerEmail\": \"john@example.com\",'+
        '                               \"customerType\": \"Business Partner\",'+
        '                               \"sageCoverLevel\": \"7\",'+
        '                               \"sageStratergy\": \"RantAndRaveTechRequestBuilder\",'+
        '                               \"reason\": \"Softwarefehler Sage\",'+
        '                               \"subject\": null,'+
        '                               \"createdDate\": \"2017-03-01 09:16:11.000\",'+
        '                               \"contactName\": \"John Dow\",'+
        '                               \"customerMobile\": \"0049152123456\",'+
        '                               \"caseId\": \"2995845\",'+
        '                               \"team\": \"F6UJ9A00002X\",'+
        '                               \"prefix\": \"Dipl.-Ing.\",'+
        '                               \"escalation\": \"2\",'+
        '                               \"pmSystem\": \"Aufgabendatenbank\"'+
        '                           }'+
        '                       }'+
        '                   }'+
        '               }'+
        '           ]'+
        '       }'+
        '   }'+
        '}';
         res.setBody(respone);
        return res;
        }
        }
}