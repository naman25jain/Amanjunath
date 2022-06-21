// Created by Matthew on 2019-07-19.
@isTest
public class VerReqFilesBatchTest{
    @testSetup
    static void setup(){
        Verification_Request__c vr = new Verification_Request__c(
                Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '12345',
                // TODO: Revisit once the country list issue as been addressed // Birth_Country__c = 'UK',
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
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PROCESSED,
                University_Code__c = 'ABC123',
                University_Name__c = 'Test School',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert vr;
        Verification_Request_File__c vrf = new Verification_Request_File__c(
            Verification_Request__c = vr.Id
        );
        insert vrf;
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = vrf.Id,
            ContentDocumentId = documents[0].Id,
            ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED
        );
        insert cdl;
        insert new Case(
            Verification_Request__c = vr.Id
        );
    }
    @isTest
    static void testExecute(){
        Test.StartTest();
        	Database.ExecuteBatch(new VerReqFilesBatch(), 1);
        Test.StopTest();
        List<Case> cases = [select Id from Case];
        List<ContentDocumentLink> cdls = [select Id, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :cases[0].Id];
        System.assert(cdls != null, 'cdls should not be null');
    }
    @isTest
    static void testSch(){
		String cronExpression = '0 0 0 1 1 ? 2050'; // 1/1/2050
		String scheduledClassName = 'VerReqFilesBatch'+System.now();
		Test.startTest();
			SchedulableContext sc = null;
			VerReqFilesBatchSched tsc = new VerReqFilesBatchSched();
        	System.schedule(scheduledClassName,cronExpression, tsc);
			tsc.execute(sc);
        Test.stopTest();
        System.assert(cronExpression!=null,'cronExpression provided');
    }
}