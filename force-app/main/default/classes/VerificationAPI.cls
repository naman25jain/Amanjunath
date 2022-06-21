// /services/apexrest/VerificationAPI/1234
@RestResource(urlMapping='/VerificationAPI/*')
global with sharing class VerificationAPI{
    @HttpGet
    global static String  getVericationResponse(){
        string strCorrelationId =''; 
        RestRequest request = RestContext.request;
        VerificationStatusResponse vsr = new VerificationStatusResponse(); 
        try{
            strCorrelationId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
            if(!String.isBlank(strCorrelationId)){
                vsr = VerificationStatusHelper.getVeficationRequest(strCorrelationId); 
            }
            return JSON.serializePretty(vsr, true); 
        }catch(Exception e){
            throw e; 
        }     
    }

    @HTTPPut
    global static Verification_Request__c upsertVerificationRequest(){
        string strCorrelationId =''; 
        RestRequest request = RestContext.request;
        Verification_Request__c vsr = new Verification_Request__c(); 
        try{
            strCorrelationId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
            if(!String.isBlank(strCorrelationId)){
                vsr = VerificationStatusHelper.updateVeficationRequest(strCorrelationId); 
            }
            return vsr; 
        }catch(Exception e){
            throw e; 
        }
    }
}