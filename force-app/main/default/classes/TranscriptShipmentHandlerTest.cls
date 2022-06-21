@isTest
private class TranscriptShipmentHandlerTest extends ECFMGTestFactory{   
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {
         // Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        // Create a new case to be used in all applicable test functions
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User user = [SELECT id, contactId 
                        FROM User 
                        WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                        AND profileId =: profile.id
                        LIMIT 1];
        Contact contact = [SELECT id, AccountId 
                            FROM Contact 
                            WHERE Id =: user.contactId
                            LIMIT 1];
        // new case 
        Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                AccountId = contact.AccountId,
                                                Internal_Status__c = ConstantsTest.TEST_CASE_STATUS_NEW);
        insert caseWithWorkingStatus;
        //Shipment Set up
        zkmulti__MCShipment__c shipment = ShipmentTestFactory.getShipment();
        //Shipment Label from Attachments
        BaseTestFactory.getPDFAttachment(shipment.Id);
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case parcas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ECFMG_CERT').Value__c));    
        run();
        Case csNew = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        csNew.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
        csNew.ParentId = parcas.Id;
        Update csNew; 
        System.assertEquals(csNew.ParentId != NULL, TRUE);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseLineTestData.class, new Case_Line__c(Case__c = parcas.Id, Secondary_Case__c = cas.Id));
        run();
        Transcript_Request__c transcript = (Transcript_Request__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptRequestTestData.class, new Transcript_Request__c(Case__c = cas.Id, Courier__c = TRUE, Contact__c = contact.Id));
        run();
        // Add a new transcript to this shipment
        shipment.Transcript_Request__c = transcript.Id;
        update shipment;
        System.assertEquals(shipment.Transcript_Request__c != NULL, TRUE);
        // Cloud test data
        CloudDataTestFactory.createCloudConfig();  
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testShippingLabelPayloadReturnsNotNull() {
        //Arrange
            // Get Shipment
            zkmulti__MCShipment__c shipment = [SELECT Id
                                                FROM zkmulti__MCShipment__c 
                                                WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                LIMIT 1];
        //Act
            Test.startTest();
            string payload = TranscriptShipmentHandler.shippingLabelPayload(shipment.Id);
            Test.stopTest();
        //Assert
            System.assertNotEquals(null, payload,'Shipping label payload is null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testSaveShippingLabelToCloudReturnsSuccess() {
        //Arrange
            // Get Shipment
            zkmulti__MCShipment__c shipment = [SELECT Id
                                                FROM zkmulti__MCShipment__c 
                                                WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                LIMIT 1];
            List<Id> shipments = new List<Id>();
            shipments.add(shipment.Id);
        //Act
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
            TranscriptShipmentHandler.saveShippingLabelToCloud(shipments);
            Test.stopTest();
        //Assert
            List<Attachment> attachments =  [SELECT Id, Body, ContentType 
                                                FROM Attachment 
                                                WHERE ParentId =: shipment.Id
                                                WITH SECURITY_ENFORCED
                                                ];
            System.assertEquals(0, attachments.size(),'Shipping attachment is not deleted');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}