@isTest
public with sharing class VerReqAssetBatchTest {

    @testSetup
    static void setup(){
        string verReqCredentialReviewRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW).getRecordTypeId();
        Contact cnt = new Contact(
            FirstName = 'Test',
            LastName = 'User1'
        );
        insert cnt;
        Verification_Request__c vr = new Verification_Request__c(
                Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '12345',                
                Birth_Date__c = Date.parse('1/1/1970'),
                Candidate_Code__c = 'ABC123',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '12345',
                Client_Provided_Entity_ID__c = '12345',
                Client_Provided_Entity_Name__c = 'TestSchool',
                Comments__c = 'This is a comment',
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC123',
                EPIC_ID__c = 'ABC123',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse('1/1/2000'),
                Institution_Address__c = '123 Main Street',
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC123',
                Institution_Name__c = 'TestSchool',
                Institution_Postal_Code__c = '75001',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'User1',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = 'Test School',
                Previous_Last_Name__c = 'Previous Last1',
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Residence_Country__c = 'United States',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'PCRC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PROCESSED,
                University_Code__c = 'ABC123',
                University_Name__c = 'Test School',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123',
                RecordTypeId = verReqCredentialReviewRecordTypeId
        );
        insert vr;       
        Verification_Request_File__c vrf = new Verification_Request_File__c(
            Verification_Request__c = vr.Id,
            Document_Type__c = 'PHOTO',
            status__c= 'Pending'

        );
        insert vrf;

        insert new Case(
            Verification_Request__c = vr.Id,            
            RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId(),
            Internal_Status__c=Constants.CASE_STATUS_PENDING_VER_REVIEW,
            ContactId = cnt.Id

        ); 
    }
    @isTest
    static void testExecute(){
        String message =''; 
        Test.StartTest();
            try {
                Database.ExecuteBatch(new VerReqAssetBatch(), 1);
            } catch (Exception e) {              
                 message = e.getMessage();
            } 
        	
        Test.StopTest();
        List<Case> cases = [select Id from Case];
        List<Asset> assets = [select Id from Asset where Case__c =:cases[0].Id];        
        System.assert(assets != null, 'Assets should not be null');  
    }
    @isTest
    static void testSch(){
		String cronExpression = '0 0 0 1 1 ? 2050'; 
		String scheduledClassName = 'VerReqAssetBatch'+System.now();
		Test.startTest();
			SchedulableContext sc = null;
			VerReqAssetBatchSched tsc = new VerReqAssetBatchSched();
        	System.schedule(scheduledClassName,cronExpression, tsc);
			tsc.execute(sc);
        Test.stopTest();
        System.assert(cronExpression!=null,'cronExpression provided');
    }
}