public with sharing class MuleIntegrate {
    Public MuleIntegrate(){
        
    }
    Public string resp{get;set;}
    Public string ProdName{get;set;}
    Public Boolean NCA{get;set;}
    Public Boolean MultiYear{get;set;}
    Public Integer ContLength{get;set;}
    Public Integer Price{get;set;}
    
    public pagereference makeAPICall(){
        makeAPICallout();
        return null;
    }
    public string makeAPICallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //Enpoint URL that points the Mule Cloudhub
        request.setEndpoint('http://javatest1.cloudhub.io/java?isNCA='+NCA+'&isMultiYear='+MultiYear);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        resp = response.getBody();
        System.debug(resp);
        return resp;
    }        
    
}