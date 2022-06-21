/**
* Test Class for EntityVerificationAPI class
*
* @author        Shailaja Yerneni
* @version       1.0
* @createdDate   01-May-2021
*/

@IsTest
public with sharing class EntityVerificationAPITest{
    private static CurrentEntityIDSequence__c settingsInstance;
        
        static {
            CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
            settingsInstance.Entity_ID__c = '0000000';
            upsert settingsInstance;
        }
    @IsTest    
    public static void testEntityDetailsSuccess(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/EntityVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');

        // Setup()
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();                    // new Account 
        Account testAccount = new Account(Name =ConstantsTest.TEST_ENTITY_ACCOUNT_NAME, RecordTypeId = entityRTId, BillingCountry='India');
        INSERT testAccount;

        Account account = [SELECT id, Entity_ID__c, Name
                            FROM Account 
                            WHERE Name =: ConstantsTest.TEST_ENTITY_ACCOUNT_NAME
                            LIMIT 1];
        String strEntityId = account.Entity_ID__c;
        //Construct input payload JSON
        String temp = '{"entityid": "'+strEntityId +'"}';
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        Test.startTest();
        try{
            EntityVerificationAPI.EntityResponseWrapper entityRes;
            entityRes = EntityVerificationAPI.entityDetails();
            Test.stopTest();
            EntityVerificationAPI.EntityResponseWrapper responseBody = (EntityVerificationAPI.EntityResponseWrapper)JSON.deserialize(response.responseBody.toString(), EntityVerificationAPI.EntityResponseWrapper.class);
            System.assertEquals(account.Name, responseBody.accountName,'Success Account name');
            System.assertEquals('success', responseBody.message,'message success');
            System.assertEquals('success', responseBody.status,'Status success');
            System.assertEquals(201, response.statusCode,'Response status code 201');
            System.assertEquals(entityRes.status,'success','Successfully retrieved');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest    
    public static void testEntityDetailsFailure(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/EntityVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String temp = '{"entityid": "ENT-0000000"}';
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        Test.startTest();
        try{
            EntityVerificationAPI.EntityResponseWrapper entityRes;
            entityRes = EntityVerificationAPI.entityDetails();
            Test.stopTest();

            EntityVerificationAPI.EntityResponseWrapper responseBody = (EntityVerificationAPI.EntityResponseWrapper)JSON.deserialize(response.responseBody.toString(), EntityVerificationAPI.EntityResponseWrapper.class);
            System.assertEquals('Empty or blank json', responseBody.message,'Empty or blank json');
            System.assertEquals('failure', responseBody.status,'Status success');
            System.assertEquals(500, response.statusCode,'Response status code 500');
            System.assertEquals(entityRes.status,'failure','Failure No records retrieved');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest    
    public static void testEntityDetailsEmptyIDFailure(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/EntityVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String temp = '{"entityid": ""}';
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        Test.startTest();
        try{
            EntityVerificationAPI.EntityResponseWrapper entityRes;
            entityRes = EntityVerificationAPI.entityDetails();
            Test.stopTest();
            EntityVerificationAPI.EntityResponseWrapper responseBody = (EntityVerificationAPI.EntityResponseWrapper)JSON.deserialize(response.responseBody.toString(), EntityVerificationAPI.EntityResponseWrapper.class);
            System.assertEquals('Empty or blank json', responseBody.message,'Empty or blank json');
            System.assertEquals('failure', responseBody.status,'Status success');
            System.assertEquals(500, response.statusCode,'Response status code 500');
            System.assertEquals(entityRes.status,'failure','Failure Empty Entity ID');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest    
    public static void testEntityDetailsNoJSON(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/EntityVerification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        String temp = '';
        //Empty JSON
        request.requestBody = Blob.valueOf(temp);
        RestContext.request = request;
        Test.startTest();
        try{
            EntityVerificationAPI.EntityResponseWrapper entityRes;
            entityRes = EntityVerificationAPI.entityDetails();
            Test.stopTest();
            EntityVerificationAPI.EntityResponseWrapper responseBody = (EntityVerificationAPI.EntityResponseWrapper)JSON.deserialize(response.responseBody.toString(), EntityVerificationAPI.EntityResponseWrapper.class);
            System.assertEquals('Empty or blank json', responseBody.message,'Empty or blank json');
            System.assertEquals('failure', responseBody.status,'Status success');
            System.assertEquals(500, response.statusCode,'Response status code 500');
            System.assertEquals(entityRes.status,'failure','JSON empty');
        } catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception scenario failed');
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}