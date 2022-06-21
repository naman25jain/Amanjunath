@isTest
public class VerReqContactDupeCheckBatchSchTest{
	public static final String CRON_EXPRESSION = '0 0 0 1 1 ? 2050'; // 1/1/2050
	public static final String NEXT_FIRE_TIME = '2050-01-01 00:00:00';
	public static final String SCHEDULED_CLASS_NAME = 'ScheduleApexClassTest';
    public static final String TESTSCHOOL ='Test School';
    /************************
     * Name - setup
     * Description - Test Method
     * ******************************/
    @testSetup 
    public static void setup(){
        CommunitiesTestFactory.setup();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Account acct = new Account(
                Name = 'Test Entity Account',
            	RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY),
            	BillingCountry = 'India'
        );
        insert acct;
        System.assert(acct.Id!=null,'Account not found');
    	Case c1 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'EPIC', AccountId = acct.Id);
		insert c1;
        System.assert(c1.Id!=null,'Case doesnot exists');
        Verification_Request__c req1 = new Verification_Request__c(
                Account_Exact_Scenario_Score__c = 100,
                Account_Non_Exact_Scenario_Score__c = 100,
                Batch_Id__c = '12345',
                // TODO: Revisit once the country list issue as been addressed
                //Birth_Country__c = 'UK',
                Birth_Date__c = Date.parse('1/1/1970'),
                Candidate_Code__c = 'ABC123',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '12345',
                Client_Provided_Entity_ID__c = '12345',
                Client_Provided_Entity_Name__c = TESTSCHOOL,
                Comments__c = 'This is a comment',
                Contact_Exact_Scenario_Score__c = 35,
                Contact_Non_Exact_Scenario_Score__c = 35,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC123',
                EPIC_ID__c = 'ABC123',
                Exact_Match_Account__c = acct.Id,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse('1/1/2000'),
                Institution_Address__c = '123 Main Street',
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC123',
                Institution_Name__c = TESTSCHOOL,
                Institution_Postal_Code__c = '75001',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'User1',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = TESTSCHOOL,
                Previous_Last_Name__c = 'Previous Last1',
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Residence_Country__c = 'United States',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = TESTSCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req1;
        System.assert(req1.Id!=null,'Request not found');
        Verification_Request__c vr2 = new Verification_Request__c(
                Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '12345',
                // TODO: Revisit once the country list issue as been addressed
                //Birth_Country__c = 'UK',
                Birth_Date__c = Date.parse('1/1/1970'),
                Candidate_Code__c = 'ABC123',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '12345',
                Client_Provided_Entity_ID__c = '12345',
                Client_Provided_Entity_Name__c = TESTSCHOOL,
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
                Institution_Name__c = TESTSCHOOL,
                Institution_Postal_Code__c = '75001',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'User1',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = TESTSCHOOL,
                Previous_Last_Name__c = 'Previous Last1',
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Residence_Country__c = 'United States',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = TESTSCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert vr2;
        System.assert(vr2.Id!=null,'Verification request not found');
        Verification_Request_File__c vrf = new Verification_Request_File__c(
                Verification_Request__c = vr2.Id
        );
        insert vrf;
        System.assert(vrf.Id!=null,'Verification Request file not found');
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        System.assert(cv.Id!=null,'ContentVersion record not found');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(
                LinkedEntityId = vrf.Id,
                ContentDocumentId = documents[0].Id,
                ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED
        );
        insert cdl;
        System.assert(cdl.Id!=null,'ContentDocumentLink record not found');
        Case case1 = new Case(Verification_Request__c = vr2.Id);
        insert case1;
        System.assert(case1.Id!=null,'Case not found');
		Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
		settings.Applicant_Bio_Change_Cancel_Statuses__c = 'Pending Review|In Review';
		settings.Builder_Test_Contact__c = '123456789345';
		settings.Builder_Test_Service__c = 'EPIC';
		settings.ID_Form_Product_Code__c = 'ID Form';
		settings.ID_Verification_Case_Paid_Status__c = 'Pending ID Review';
		settings.ID_Verification_Case_Queue_Name__c = 'ID Review Queue';
		settings.ID_Verification_Case_Unpaid_Status__c = 'New';
		settings.Passport_Product_Code__c = 'Passport';
		settings.Photo_Product_Code__c = 'Photo';
		settings.Username_Append__c = '.dev';
		upsert settings Community_Settings__c.Id;
        System.assert(settings.ID_Form_Product_Code__c == 'ID Form', 'settings not updated');
		Terms_and_Conditions__c tc1 = new Terms_and_Conditions__c(Name='A', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
		Terms_and_Conditions__c tc2 = new Terms_and_Conditions__c(Name='Certification by Applicant', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
		insert tc1;
        System.assert(tc1.Id!=null,'Terms and Conditions record not found');
		insert tc2;
        System.assert(tc2.Id!=null,'Terms and Conditions record not found.');
    }
	@isTest static void test(){
		// schedule the test job
		String jobId = System.schedule(SCHEDULED_CLASS_NAME, CRON_EXPRESSION, new VerReqContactDupeCheckBatchSch());
		// get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		// verify the expressions are the same
		System.assertEquals(CRON_EXPRESSION, ct.CronExpression,'Expressions found to be different');
		// verify the job has not run
		System.assertEquals(0, ct.TimesTriggered,'Trigger time differs');
		// verify the next time the job will run
		System.assertEquals(NEXT_FIRE_TIME, String.valueOf(ct.NextFireTime),'Next Fire time differs');
        Test.StartTest();
        VerReqContactDupeCheckBatch testBatch = new VerReqContactDupeCheckBatch();
        Database.ExecuteBatch(testBatch, 200);
        Test.StopTest();
	}
}