/**
* Test Class for ApplicantVerificationAPI class
*
* @author        Shailaja Yerneni
* @version       1.0
* @createdDate   01-May-2021
*/
@IsTest
public with sharing class ApplicantVerificationAPITest{
    private static CurrentECFMGIDSequence__c settingsInstance;
        
        static {
            CurrentECFMGIDSequence__c settingsInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
            settingsInstance.ECFMG_ID__c = '00000000';
            upsert settingsInstance;
            System.debug('settingsInstance.ECFMG_ID__c '+settingsInstance.ECFMG_ID__c);
        }
        
    @IsTest    
    public static void testApplicantDetailsSuccess(){
        // Set up a Test Request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/ApplicantVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');

        // Setup()
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Contact testContact = new Contact(LastName=ConstantsTest.TEST_NAME,Firstname=ConstantsTest.TEST_NAME, RecordTypeId = applRecTypeId);
        insert testContact;
        System.assert(testContact.Id != null, 'Test contact creation failed');
        Contact contact = [SELECT id, ECFMG_ID__c,FirstName, LastName FROM Contact WHERE LastName =: ConstantsTest.TEST_NAME LIMIT 1];
        contact.ECFMG_ID__c='ECFMG-00000001';
        update contact;
        String strEcfmg = contact.ECFMG_ID__c;
        //Construct Input payload JSON
        String temp = '{"ecfmgid": "'+strEcfmg +'"}';
        request.requestBody = Blob.valueOf(temp);
        
        RestContext.request = request;
        RestContext.response= response;

        Test.startTest();
        try{
            ApplicantVerificationAPI.ResponseWrapper appRes;
            appRes = ApplicantVerificationAPI.applicantDetails();
            Test.stopTest();
            ApplicantVerificationAPI.ResponseWrapper responseBody = (ApplicantVerificationAPI.ResponseWrapper)JSON.deserialize(response.responseBody.toString(), ApplicantVerificationAPI.ResponseWrapper.class);
            Contact newContact = [SELECT Id, FirstName,LastName FROM Contact WHERE LastName=:ConstantsTest.TEST_NAME];
            System.assertEquals(newContact.FirstName, responseBody.firstName,'Success first name');
            System.assertEquals(newContact.LastName, responseBody.lastName,'Last name success');
            System.assertEquals(newContact.FirstName, responseBody.restOfName,'Last name success');
            System.assertEquals('success', responseBody.message,'message success');
            System.assertEquals(201, response.statusCode,'Response status code 201');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest    
    public static void testApplicantDetailsFailure(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/ApplicantVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String temp = '{"ecfmgid": "ECFMG-0000000"}';
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        try{
            ApplicantVerificationAPI.ResponseWrapper appRes;
            appRes = ApplicantVerificationAPI.applicantDetails();
            Test.stopTest();
            ApplicantVerificationAPI.ResponseWrapper responseBody = (ApplicantVerificationAPI.ResponseWrapper)JSON.deserialize(response.responseBody.toString(), ApplicantVerificationAPI.ResponseWrapper.class);
            System.assertEquals('failure', responseBody.status,'Failure No records retrieved');
            System.assertEquals(500, response.statusCode,'Response status code 500');
            System.assertEquals(appRes.status,'failure','Failure No records retrieved');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
     @IsTest    
    public static void testApplicantDetailsEmptyIDFailure(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/ApplicantVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String temp = '{"ecfmgid": ""}';
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        try{
            ApplicantVerificationAPI.ResponseWrapper appRes;
            appRes = ApplicantVerificationAPI.applicantDetails();
            Test.stopTest();
            ApplicantVerificationAPI.ResponseWrapper responseBody = (ApplicantVerificationAPI.ResponseWrapper)JSON.deserialize(response.responseBody.toString(), ApplicantVerificationAPI.ResponseWrapper.class);
            System.assertEquals(responseBody.status,'failure','Failure empty ECFMG ID');
            System.assertEquals(500, response.statusCode,'Response status code 500');
            System.assertEquals(appRes.status,'failure','Failure empty ECFMG ID');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest    
    public static void testApplicantDetailsNoJSON(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/ApplicantVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String temp = '';
        //Empty JSON
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        try{
            ApplicantVerificationAPI.ResponseWrapper appRes;
            appRes = ApplicantVerificationAPI.applicantDetails();
            Test.stopTest();
            ApplicantVerificationAPI.ResponseWrapper responseBody = (ApplicantVerificationAPI.ResponseWrapper)JSON.deserialize(response.responseBody.toString(), ApplicantVerificationAPI.ResponseWrapper.class);
            System.assertEquals(responseBody.status,'failure','JSON empty');
            System.assertEquals(500, response.statusCode,'Response status code 500');
            System.assertEquals(appRes.status,'failure','JSON empty');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}