@isTest
private class VerReqContactDupeCheckBatchTests{
        static final string SCHOOL ='Test School';
        static final string LNAME= 'Previous Last1';
        static final string RNAME= 'Previous First1';
        @testSetup static void setup(){
                CommunitiesTestFactory.setup();
                Id conId = CommunityIdentityVerificationController.getRunningContactId();
                Account acct = new Account(
                        Name = 'Test Entity Account',
                        RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY),
                    	BillingCountry='India' 
                );
                insert acct;
                Case c1 = new Case(contactId = conId, Internal_Status__c = 'Accepted', Service__c = 'EPIC', AccountId = acct.Id);
                insert c1;
                Verification_Request__c req1 = new Verification_Request__c(
                        Account_Exact_Scenario_Score__c = 100,
                        Account_Non_Exact_Scenario_Score__c = 100,
                        Batch_Id__c = '12345',
                        // TODO: Revisit once the country list issue as been addressed //Birth_Country__c = 'UK',
                        Birth_Date__c = Date.parse('1/1/1970'),
                        Candidate_Code__c = 'ABC123',
                        Client_Batch_Create_Date__c = Date.today(),
                        Client_Institution_ID__c = '12345',
                        Client_Provided_Entity_ID__c = '12345',
                        Client_Provided_Entity_Name__c = SCHOOL,
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
                        Institution_Name__c = SCHOOL,
                        Institution_Postal_Code__c = '75001',
                        Institution_State_Code__c = 'TX',
                        Is_EICS__c = false,
                        Is_EPIC__c = false,
                        Is_USMLE__c = false,
                        Last_Name__c = 'User1',
                        Medschool_Code__c = 'ABC123',
                        Medschool_Name__c = SCHOOL,
                        Previous_Last_Name__c = LNAME,
                        Previous_Rest_of_Name__c = RNAME,
                        Request_Id__c = 'ABC123',
                        Request_Type__c = 'Test Request',
                        Residence_Country__c = 'United States',
                        Rest_of_Name__c = 'Test1',
                        Sender__c = 'MCC',
                        Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                        University_Code__c = 'ABC123',
                        University_Name__c = SCHOOL,
                        Urgent__c = false,
                        USMLE_ID__c = 'ABC123'
                );
                insert req1;
                Verification_Request__c vr2 = new Verification_Request__c(
                        Account_Exact_Scenario_Score__c = null,
                        Account_Non_Exact_Scenario_Score__c = null,
                        Batch_Id__c = '12345',
                        // TODO: Revisit once the country list issue as been addressed  //Birth_Country__c = 'UK',
                        Birth_Date__c = Date.parse('1/1/1970'),
                        Candidate_Code__c = 'ABC123',
                        Client_Batch_Create_Date__c = Date.today(),
                        Client_Institution_ID__c = '12345',
                        Client_Provided_Entity_ID__c = '12345',
                        Client_Provided_Entity_Name__c = SCHOOL,
                        Comments__c = 'This is a comment',
                        Contact_Exact_Scenario_Score__c = 100,
                        Contact_Non_Exact_Scenario_Score__c = 50,
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
                        Institution_Name__c = SCHOOL,
                        Institution_Postal_Code__c = '75001',
                        Institution_State_Code__c = 'TX',
                        Is_EICS__c = false,
                        Is_EPIC__c = false,
                        Is_USMLE__c = false,
                        Last_Name__c = 'User1',
                        Medschool_Code__c = 'ABC123',
                        Medschool_Name__c = SCHOOL,
                        Previous_Last_Name__c = LNAME,
                        Previous_Rest_of_Name__c = RNAME,
                        Request_Id__c = 'ABC123',
                        Request_Type__c = 'Test Request',
                        Residence_Country__c = 'United States',
                        Rest_of_Name__c = 'Test1',
                        Sender__c = 'MCC',
                        Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                        University_Code__c = 'ABC123',
                        University_Name__c = SCHOOL,
                        Urgent__c = false,
                        USMLE_ID__c = 'ABC123'
                );
                insert vr2;
                Verification_Request_File__c vrf = new Verification_Request_File__c(
                        Verification_Request__c = vr2.Id
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
                        Verification_Request__c = vr2.Id
                );
                Contact con1 = new Contact(LastName='User1', FirstName='Test1', Previous_Last_Name__c = LNAME, Previous_Rest_of_Name__c = RNAME);
                insert con1;
                Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
                settings.Applicant_Bio_Change_Cancel_Statuses__c = 'Pending Review|In Review';
                settings.Builder_Test_Contact__c = '123456789656';
                settings.Builder_Test_Service__c = 'EPIC';
                settings.ID_Form_Product_Code__c = 'ID Form';
                settings.ID_Verification_Case_Paid_Status__c = 'Pending ID Review';
                settings.ID_Verification_Case_Queue_Name__c = 'ID Review Queue';
                settings.ID_Verification_Case_Unpaid_Status__c = 'New';
                settings.Passport_Product_Code__c = 'Passport';
                settings.Photo_Product_Code__c = 'Photo';
                settings.Username_Append__c = '.dev';
                upsert settings Community_Settings__c.Id;
                Terms_and_Conditions__c tc1 = new Terms_and_Conditions__c(Name='A', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
                Terms_and_Conditions__c tc2 = new Terms_and_Conditions__c(Name='Certification by Applicant', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
                insert tc1;
                insert tc2;
        }
        @isTest
        static void testExecute(){
                Test.StartTest();
                        Database.ExecuteBatch(new VerReqContactDupeCheckBatch());
                Test.StopTest();
                Verification_Request__c vReg = [SELECT id, status__c FROM Verification_Request__c WHERE Residence_Country__c = 'United States' LIMIT 1];
                System.assert(vReg.Status__c == Constants.VERIFICATION_REQUEST_STATUS_SCORED,'Status not updated');
        }
}