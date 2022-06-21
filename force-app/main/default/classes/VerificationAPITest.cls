@IsTest
public with sharing class VerificationAPITest{
    @IsTest
    public static void getVericationResponseTest(){
        String relativeUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/TestVFPage?AcoountId=999';
        try{
            VerificationAPI.getVericationResponse();
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
        RestRequest req = new RestRequest();  
        RestResponse res = new RestResponse();
        req.requestURI = relativeUrl;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        VerificationAPI.getVericationResponse();
        System.assert(req.requestURI == relativeUrl, 'Request doesnt have a request url');
        Verification_Request__c verRe = new Verification_Request__c();
        verRe.CorrelationId__c = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        Insert verRe;
        System.assert(verRe.Id != null, 'Verification_Request__c is not created');
        Verification_Request__c verReq = VerificationAPI.upsertVerificationRequest();
        System.assert(verReq.Id == verRe.Id, 'Verification Request is null or different');
    }
}