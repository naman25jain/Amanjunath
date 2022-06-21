@RestResource(urlMapping='/VerificationStatusAPI/*')
global with sharing class VerificationStatusAPI{
    @HttpGet
    global static string  getVerificationStatus(){
        string sender =''; 
        RestRequest request = RestContext.request;
        try{
            sender = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
            List<VerificationStatus> vs = VerificationStatusHelper.getVerificationStatus(sender);      
            return JSON.serializePretty(vs, true);
        } catch(Exception e){
            throw e; 
        }
    } 
}