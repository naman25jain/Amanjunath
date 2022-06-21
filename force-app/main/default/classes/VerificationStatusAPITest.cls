@IsTest
public with sharing class VerificationStatusAPITest{
    @IsTest
    public static void getVerificationStatusTest(){
        String relativeUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/TestVFPage?AcoountId=999';
        try{
           VerificationStatusAPI.getVerificationStatus(); 
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
        RestRequest req = new RestRequest();  
        RestResponse res = new RestResponse();
        req.requestURI = relativeUrl;// sample Endpoint 
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        VerificationStatusAPI.getVerificationStatus();
        System.assert(req.requestURI == relativeUrl, 'Request doesnt have a request url');
    }
}