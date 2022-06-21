@isTest
private class VerReqAccountDupeCheckBatchTests extends ECFMGTestFactory{
    @testSetup
    static void setup(){
        Verification_Request__c vr = new Verification_Request__c(
                Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '12345',
                // TODO: Revisit once the country list issue as been addressed //Birth_Country__c = 'UK',
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
                Medschool_Name__c = 'Test school',
                Previous_Last_Name__c = 'Previous Last1',
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Residence_Country__c = 'United States',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = 'Test school',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert vr;
        Id acctEntityRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Account', 'Entity');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class,new Account(Name = 'Test School', Institution_ID__c='ABC12'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class,new Account(Name = 'Test School', Institution_ID__c='ABC123', RecordTypeId = acctEntityRecTypeId));
        run();
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
            Database.ExecuteBatch(new VerReqAccountDupeCheckBatch(), 1);
        Test.StopTest();
        Verification_Request__c vReg = [SELECT id, status__c FROM Verification_Request__c WHERE Residence_Country__c = 'United States' LIMIT 1];
        System.assert(vReg.Status__c == Constants.VERIFICATION_REQUEST_STATUS_SCORED,'Status not updated');
    }
    @isTest
    static void testError1(){
        Test.StartTest();
        VerReqAccountDupeCheckBatch b = new VerReqAccountDupeCheckBatch();
        b.testError = 1;
            try{
                Database.ExecuteBatch(b, 1);
            }
            catch(Exception e){    
                    throw e;    
            }
        Test.StopTest();
        Verification_Request__c vReg = [SELECT id, status__c FROM Verification_Request__c WHERE Residence_Country__c = 'United States' LIMIT 1];
        System.assert(vReg.Status__c == Constants.VERIFICATION_REQUEST_STATUS_SCORED,'Status not updated');
    }
    @isTest
    static void testError2(){
        Test.StartTest();
        VerReqAccountDupeCheckBatch b = new VerReqAccountDupeCheckBatch();
        b.testError = 2;
            try{
                Database.ExecuteBatch(b, 1);
            }
            catch (Exception e){
                throw e;          
            }
        Test.StopTest();
        Verification_Request__c vReg = [SELECT id, status__c FROM Verification_Request__c WHERE Residence_Country__c = 'United States' LIMIT 1];
        System.assert(vReg.Status__c == Constants.VERIFICATION_REQUEST_STATUS_SCORED,'Status not updated');
    }
}