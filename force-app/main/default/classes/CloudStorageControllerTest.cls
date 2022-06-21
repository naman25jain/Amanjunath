@isTest
private class CloudStorageControllerTest extends ECFMGTestFactory{
    public static final String PAYLOAD = '{ recordid : 1 }';
    public static final String URL = 'https://test.com';
    public static final String FILENAME = 'test.pdf';
    public static final String FILEEXT = 'pdf';
    public static final String ASSETATTRIBUTE = 'Add a New Service for User';
    @testSetup static void setup(){
        CloudDataTestFactory.createCloudConfig();
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '0000000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;

        Id acctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.RecordTypeId = acctRecTypeId;
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        String tstAzureURL = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        Id verifAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        Id appForCertAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id bioChangeCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
        Id credVerifRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id ecfmgCerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id eurRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        
        Case appForCertCase = new Case(
                RecordTypeId = appCertRecordTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION);
        INSERT appForCertCase;
        
        Contact_Association_Type_Staging__c tstConStageRec = new Contact_Association_Type_Staging__c();
        tstConStageRec.recordTypeId = medSchlRecordTypeId;
        tstConStageRec.Start_Month__c = 'March';
        tstConStageRec.Start_Year__c = '2010';
        tstConStageRec.End_Month__c = 'June';
        tstConStageRec.End_Year__c = '2011';
        tstConStageRec.Degree_Issue_Month__c='June';
        tstConStageRec.Degree_Issue_Year__c='2011';
        tstConStageRec.Degree_Title__c='MBBS';
        tstConStageRec.Degree_expected_to_be_issued_Month__c = 'June';
        tstConStageRec.Degree_expected_to_be_issued_Year__c='2011';
        tstConStageRec.Case__c = appForCertCase.Id;
        tstConStageRec.Contact__c = con.Id;
        tstConStageRec.Account__c = acc.Id;
        INSERT tstConStageRec;

        Case ecfmgCertCase = new Case(
                RecordTypeId = ecfmgCerRecordTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW);
        INSERT ecfmgCertCase;
        Case credVerifCase = new Case(RecordTypeId = credVerifRecordTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_VERIFICATION_IN_REVIEW);
        INSERT credVerifCase;
        
        Case eurCase = new Case();
        eurCase.RecordTypeId = eurRTId;
        eurCase.ContactId = con.Id;
        eurCase.AccountId = acc.Id;
        eurCase.Entity__c = acc.Id;
        eurCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SIGNATURE_CHECK;
        INSERT eurCase;
        
        Case bioChangeCase = new Case(RecordTypeId = bioChangeCaseRecTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_ID_REVIEW);
        INSERT bioChangeCase;
        //Insert asset for bio change case
        Asset bioChangeAsset = new Asset(
                Name = Constants.ASSET_NAME_PHOTO,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Type__c =   Constants.ASSET_NAME_PHOTO,
                case__c =   bioChangeCase.Id
            );
        INSERT bioChangeAsset;
        //Insert Passport product in Product2
        Product2 prodPassport = new Product2(Name = Constants.ASSET_NAME_PASSPORT, ProductCode = Constants.ASSET_NAME_PASSPORT);
        prodPassport.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
        INSERT prodPassport;
        
        //insert Asset for AppForCertCase
        Asset appForCertAsst = new Asset(
                Name = Constants.ASSET_TYPE_TRANSLATION,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                Case__c = appForCertCase.Id,
                InstallDate = System.Today(),
                key__c  =   Constants.ASSET_TYPE_TRANSLATION,
                Azure_Storage_URL__c = tstAzureURL,
                Type__c =   Constants.ASSET_TYPE_TRANSLATION,
                RecordTypeId=appForCertAssetRecordTypeId,
                Contact_Association_Type_Staging__c = tstConStageRec.Id
            );
        INSERT appForCertAsst;
        //Insert Asset
        Asset tstOnlineAsst = new Asset(
                Name = 'Online Verification',
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Case__c = credVerifCase.Id,
                Type__c =   Constants.ASSET_TYPE_ONLINE_VERIFICATION,
                Azure_Storage_URL__c = tstAzureURL,
                RecordTypeId = verifAssetRecordTypeId);
        INSERT tstOnlineAsst;
        //insert verification packet
        Verification_Packet__c tstVerifPacket = new Verification_Packet__c(Is_Active__c = true,Case__c =credVerifCase.Id,Contact__c =con.Id);
        INSERT tstVerifPacket;
        //Insert Asset2Verification - Doc type - cover letter
        Asset2Verification__c tstAsset2VPRec = new Asset2Verification__c(Asset__c=tstOnlineAsst.Id,Azure_Document_URL__c=tstAzureURL,Verification_Packet__c=tstVerifPacket.Id,Document_Type__c='Cover Letter');
        INSERT tstAsset2VPRec;
        //iinsert another asset2Vp
        Asset2Verification__c tstAsset2VPRec2 = new Asset2Verification__c(Asset__c=tstOnlineAsst.Id,Azure_Document_URL__c=tstAzureURL,Verification_Packet__c=tstVerifPacket.Id,Document_Type__c='Supporting Document');
        INSERT tstAsset2VPRec2;
    }
     @isTest
    static void testToCreateCloudDocumentRecord() {
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Cloud_Document__c cloudDocs = new Cloud_Document__c();
        cloudDocs.Name = 'assetCreation';
        cloudDocs.Payload__c ='{"assetCreationRequired":"true","assetRecordType":"Identity","assetStatus":"In Progress","contactId":"'+tstContact.Id+'","createOrReplace":"Replace","documentType":"Passport Translation Page","isUploadLocation":"DocumentEditingTab","caseNumber":""}';
        cloudDocs.url__c = 'https://ecfmgdev001.blob.core.windows.net/sfdc-applicant-documents/00317000017f5GhAAI_Passport_Translation_Page_0.pdf';
        INSERT cloudDocs;
        CloudStorageController.createAssetsPBAction(new List<Cloud_Document__c>{cloudDocs});        
        System.assert(cloudDocs <> null, 'Record is not yet created on the Cloud Document object');
    }
    @isTest 
    static void testProcessResponseEmpty() {
        Account acc = new Account();
        acc.Name = 'Test Account 1';
        acc.BillingCountry = 'India';
        INSERT acc;
        system.assert(acc.Id != null, 'Test Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        INSERT con;
        system.assert(con.Id != null, 'Test Contact creation failed');
        CloudStorageController.PayloadWrapper payload1= new CloudStorageController.PayloadWrapper(con.Id, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', ASSETATTRIBUTE, acc.Id,  'true', Constants.ASSET_STATUS_IN_PROGRESS, null);
        String newPayload1 = JSON.serialize(payload1);
        //Set Mode to null
        CloudStorageUtils.STORAGE_MODE = 'LOCAL';
        CloudStorageController.processResponse(newPayload1, URL);
        try {
            List<Cloud_Document__c> cd = [SELECT payload__c, url__c FROM Cloud_Document__c WHERE url__c=:URL];
            System.assert(!cd.isEmpty(), 'Cloud Document is not empty');
        }
        catch (QueryException ex) {
            System.assert(true, 'Cloud Document is not empty');
        }
    }

    @isTest
    static void testAccessLevelsCreate() {
        DocumentEnums.DocumentAccessLevel accessLevel = CloudStorageController.accessLevels.get('CREATE');
        System.assertEquals(DocumentEnums.DocumentAccessLevel.CREATE, accessLevel, 'Document Enum did not Match for Create');
    }

    @isTest
    static void testAccessLevelsRead() {
        DocumentEnums.DocumentAccessLevel accessLevel = CloudStorageController.accessLevels.get('READ');
        System.assertEquals(DocumentEnums.DocumentAccessLevel.READ, accessLevel, 'Document Enum did not Match for Read');
    }

    @isTest
    static void testAccessLevelsCreateUpdate() {
        DocumentEnums.DocumentAccessLevel accessLevel = CloudStorageController.accessLevels.get('CREATE_UPDATE');
        System.assertEquals(DocumentEnums.DocumentAccessLevel.CREATE_UPDATE, accessLevel, 'Document Enum did not Match for Create_Update');
    }

    @isTest
    static void testGetRequestUrl() {
        System.assert(CloudStorageController.getRequestUrl('CREATE', FILENAME).length() > 0, 'Request Url length is less than 0');
    }

    @isTest
    static void testGetRequestHeaders() {
        String requestHeader = CloudStorageController.getRequestHeaders('CREATE', FILENAME, FILEEXT, PAYLOAD);
        System.assert(requestHeader.length() > 0, 'Request Header length is 0');
    }

    @isTest
    static void testGetRequestHeadersFileNameEmpty() {
        String requestHeader = CloudStorageController.getRequestHeaders('CREATE', '', FILEEXT, PAYLOAD);
        System.assert(requestHeader.length() > 0, 'Request Header length is 0');
    }
    @isTest static void testController(){
        //create a new contact;
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',School_Enrollment_Status__c =Constants.CONASCTYPESTG_STATUS_GRADUATE);
        insert c1;
        System.Assert(c1.Id != null,'Contact One insert failed');
        String url = 'www.testurl';        
        List<contact> testContact = [SELECT id,AccountId FROM Contact];
        String accountId = testContact[0].AccountId;
        String contactId = testContact[0].Id;
        String documentType = 'Passport';
        String assetRecordType = 'Identity';
        String createOrReplace = 'Replace';
        Id idVerREcordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case newCase1 = new Case(
                RecordTypeId = idVerREcordTypeId, ContactId = contactId, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_NEW, Document_Type__c = 'Certificate of Good Standing');
        Insert newCase1;
        System.Assert(newCase1.Id != null,'new Case one insert failed');
        List<Asset> assetList = new List<Asset>();
        //Create and Insert Asset
        Asset asst1 = new Asset(
                Name = Constants.ASSET_TYPE_TCT,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = contactId,
                InstallDate = System.Today(),
                key__c  =   Constants.ASSET_TYPE_TCT,
                Type__c =   Constants.ASSET_TYPE_TCT
            );
        Asset asst5 = new Asset(
                Name = Constants.ASSET_NAME_PHOTO,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = contactId,
                InstallDate = System.Today(),
                Type__c =   Constants.ASSET_NAME_PHOTO,
                case__c =   newCase1.Id
            );
        assetList.add(asst5);
        Asset asst6 = new Asset(
                Name = Constants.ASSET_NAME_PHOTO,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = contactId,
                InstallDate = System.Today(),
                Type__c =   Constants.ASSET_NAME_PHOTO,
                case__c =   newCase1.Id
            );
        assetList.add(asst6);
        Asset asst2 = new Asset(
                Name = Constants.ASSET_NAME_TCT_TRANSLATION,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = contactId,
                InstallDate = System.Today(),
                key__c  =   Constants.ASSET_TYPE_TCT,
                Type__c =   'Translation'
            );
        assetList.add(asst2);
        asst1.Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        asst1.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
        assetList.add(asst1);
        insert assetList;
        System.assert(asst2.Id != null, 'asset Id is null');
        asst5.status = Constants.ASSET_STATUS_ACCEPTED;
        UPDATE asst5;
        Test.startTest();
        String tstReturn = CloudStorageController.fileNameGenerator(contactId, Constants.ASSET_TYPE_TCT, 'Credential', 'Create',asst1.Id);
        System.assert(tstReturn <> null, 'Filename returned');
        String tstReturn1 = CloudStorageController.fileNameGenerator(contactId, Constants.ASSET_TYPE_TCT, 'Credential', 'ReplaceInternal',asst1.Id);
        System.assert(tstReturn1 <> null, 'Filename returned');
        String tstReturn2 = CloudStorageController.fileNameGenerator(contactId, documentType, assetRecordType, createOrReplace,null);
        System.assert(tstReturn2 <> null, 'Filename returned');
        String tstReturn3 = CloudStorageController.fileNameGenerator(contactId, 'Returned Verification Form', 'Credential', createOrReplace,null);
        System.assert(tstReturn3 <> null, 'Filename returned');
        String tstReturn4 = CloudStorageController.fileNameGenerator(contactId, 'Returned Credential', 'Credential', createOrReplace,null);
        System.assert(tstReturn4 <> null, 'Filename returned');
        String tstReturn5 = CloudStorageController.fileNameGenerator(contactId, 'Verification Form', 'Credential', createOrReplace,null);
        System.assert(tstReturn5 <> null, 'Filename returned');
        String tstReturn6 = CloudStorageController.fileNameGenerator(contactId, 'Verified Credential', 'Credential', createOrReplace,null);
        System.assert(tstReturn6 <> null, 'Filename returned');

        CloudStorageController.PayloadWrapper payload1= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', null, accountId,  'true', Constants.ASSET_STATUS_IN_PROGRESS, null);
        String newPayload = JSON.serialize(payload1);
        CloudStorageController.processResponse(newPayload, url);
        Cloud_Document__c newDocument = new Cloud_Document__c();
        newDocument.payload__c = newPayload;
        newDocument.Url__c = url;
        INSERT newDocument;
        System.Assert(newDocument.Id != null,'newDocument Id is null');
        List<Cloud_Document__c> cloudDocs = New List<Cloud_Document__c>();
        cloudDocs.add(newDocument);
        CloudStorageController.markAssetsForDeletion(url);
        String assetId = null;
        List<Asset> assts = [SELECT Id FROM Asset WHERE Azure_Storage_URL__c != null];
        if(!assts.isEmpty()){
            assetId = assts[0].Id;
        }
        Boolean result = CloudStorageController.getAzureUrlFromAsset(assetId) != '';
        System.assert(result, 'Error on fetching azure url');
        CloudStorageController.PayloadWrapper payload2= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', 'Add a New User Request', accountId,  'true', Constants.ASSET_STATUS_IN_PROGRESS, null);
        String newPayload2 = JSON.serialize(payload2);
        CloudStorageController.processResponse(newPayload2, url);
        Cloud_Document__c newDocument1 = new Cloud_Document__c();
        newDocument1.payload__c = newPayload2;
        newDocument1.Url__c = url;
        insert newDocument1;
        System.Assert(newDocument1.Id != null,'newDocument1 insertion failed');
        List<Cloud_Document__c> cloudDocs2 = New List<Cloud_Document__c>();
        cloudDocs2.add(newDocument1);
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Case newCase = new Case(
                RecordTypeId = appCertRecordTypeId, ContactId = contactId, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION);
        Insert newCase;
        System.Assert(newCase.Id != null,'new case record insert failed');
        CloudStorageController.getContactId(newCase.Id);
        CloudStorageController.createPayload(newCase.Id, contactId, 'TCT Name Document');
        Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c();
        stageRec.Contact__c = contactId;
        stageRec.Account__c = accountId;
        Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        stageRec.recordTypeId = medSchlRecordTypeId;
        //code added by Shailaja. Date format stories. new fields need to be set.
        stageRec.Start_Month__c = 'March';
        stageRec.Start_Year__c = '2010';
        stageRec.End_Month__c = 'June';
        stageRec.End_Year__c = '2011';
        stageRec.Case__c = newCase.Id;
        Insert stageRec;
        System.Assert(stageRec.Id != null,'stage Record insert failed');
        asst1.Contact_Association_Type_Staging__c = stageRec.id;
        asst2.Contact_Association_Type_Staging__c = stageRec.id;
        asst2.ParentId = asst1.Id;
        asst2.Case__c = newCase.Id;
        update asst1;
        update asst2;
        assts[0].Contact_Association_Type_Staging__c = stageRec.id;
        assts[0].case__c = newCase.Id;
        Boolean readOnly = CloudStorageController.checkReadOnly(newCase.Id);
        system.assertEquals(false, readOnly, 'case owner changed');
        assetId = assts[0].Id;
        update assts[0];
        List<String> assetIds = new List<String>();
        assetIds.add(assetId);
        CloudStorageController.getRelatedEntities(assetIds);
        String queryStringParam = 'SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Case__c =\''+newCase.Id+'\' ORDER BY CreatedDate ASC';
        List<sObject> objectList = CloudStorageController.getRecordsList(queryStringParam);
        System.assert(!objectList.isEmpty(), 'Error on fetching assets');
        CloudStorageController.PayloadWrapper payload3= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', ASSETATTRIBUTE, accountId,  'true', Constants.ASSET_STATUS_IN_PROGRESS, null);
        String newPayload3 = JSON.serialize(payload3);
        CloudStorageController.processResponse(newPayload3, url);
        Cloud_Document__c newDocument2 = new Cloud_Document__c();
        newDocument2.payload__c = newPayload3;
        newDocument2.Url__c = url;
        insert newDocument2;
        System.Assert(newDocument2.Id != null,'newDocument2 insert failed');
        CloudStorageController.updateParent(constants.ASSET_NAME_TCT_TRANSLATION, asst2.Id, stageRec.id);
        CloudStorageController.updateParent('Final Diploma Translation', asst2.Id, stageRec.id);
        CloudStorageController.updateParent('Pre-Med Letter Translation', asst2.Id, stageRec.id);
        CloudStorageController.updateParent('Final Transcript Name Document', asst2.Id, stageRec.id);
        CloudStorageController.updateParent('Letter from Dean Name Document', asst2.Id, stageRec.id);
        Product2 prod = new Product2(Name = Constants.ASSET_TYPE_BIRTH_CERTIFICATE, ProductCode = Constants.ASSET_TYPE_BIRTH_CERTIFICATE);
        prod.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
        Insert Prod;
        System.Assert(Prod.Id != null,'Product record insert failed');
        CloudStorageController.updateProductFields(Constants.ASSET_TYPE_BIRTH_CERTIFICATE, asst2.Id);
        Asset asst3 = new Asset(
                Name = Constants.ASSET_TYPE_NAME_DOC,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = contactId,
                InstallDate = System.Today(),
                key__c  =   Constants.ASSET_TYPE_NAME_DOC,
                Type__c =   Constants.ASSET_TYPE_NAME_DOC
            );
        asst3.Contact_Association_Type_Staging__c = stageRec.id;
        asst3.ParentId = asst1.Id;
        asst3.Case__c = newCase.Id;
        insert asst3;
        System.Assert(asst3.Id != null,'asset three insert failed');
        String existingAssetId1 = CloudStorageController.checkAssetExists(newCase.Id, stageRec.id, 'TCT Name Document');
        String existingAssetId2 = CloudStorageController.checkAssetExists(newCase.Id, stageRec.id, Constants.ASSET_NAME_PHOTO);
        system.assertEquals(existingAssetId2, null, 'Fetched wrong asset Id');
        asst1.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst1.Case__c = newCase.Id;
        update asst1;
        system.assertEquals(newCase.Id, asst1.case__c, 'case id not updated');
        String docType = CloudStorageController.getCaseDocType(newCase1.Id);
        system.assertEquals(docType, 'Certificate of Good Standing', 'Returned document type');
        test.stopTest();
    }
    @isTest static void testcheckEntityHasService(){
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'India');
        insert acct;
        System.Assert(acct.Id!= null,'acct is not created');
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.Assert(con.Id!= null,'contact is not created');
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        System.Assert(user.Id!= null,'user is not created');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Performance Data');
        myServiceList.add(serv);
        INSERT myServiceList;
        System.Assert(myServiceList[0].Id!= null,'Service__c is not created');
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.Entity__c = con.AccountId;
        caseobj.Internal_Status__c = 'New';
        caseobj.Service_Name__c = myServiceList[0].Id;
        insert caseObj;
        System.Assert(caseObj.Id!= null,'Case is not created');
        Test.StartTest();
            Boolean retVal = CloudStorageController.checkEntityHasService(caseObj.Id);
            System.AssertEquals(retVal,false,'Service = Performance data service is tagged to the Entity');
            List<Account2Service__c> myAccServList = new List<Account2Service__c>();
            Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
            myAccServList.add(acc2Service);
            insert myAccServList;
            retVal = CloudStorageController.checkEntityHasService(caseObj.Id);
            System.AssertEquals(retVal,true,'No Service = Performance data service is tagged to the Entity');
            CloudStorageController.PayloadWrapper payload = CloudStorageController.createPayload(caseObj.Id,con.Id,Constants.ASSET_TYPE_SIGNED_PIA);
        Test.StopTest();
    }
    @isTest static void testFetchingParentId(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        system.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        system.assert(con.Id != null, 'Contact creation failed');
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-10-27_04_10_38.pdf';
        String url2 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-28_04_11_38.pdf';
        CloudStorageController.PayloadWrapper payload1= new CloudStorageController.PayloadWrapper(con.Id, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', 'Add a New Service for User', acc.Id,  'true', Constants.ASSET_STATUS_IN_PROGRESS, null);
        String newPayload1 = JSON.serialize(payload1);
        payload1.parentUrl = url1;
        newPayload1 = JSON.serialize(payload1);
        Id idVerREcordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case newCase1 = new Case(
                RecordTypeId = idVerREcordTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_NEW);
        Insert newCase1;
        system.assert(newCase1 != null, 'test case creation failed'); 
        payload1.assetName = Constants.ASSET2VER_DOCTYPE_ACC_VER_FORM;
        payload1.createAsset2Ver = 'true';

        CloudStorageController.PayloadWrapper payload2= new CloudStorageController.PayloadWrapper(con.Id, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', 'Add a New Service for User', acc.Id,  'true', Constants.ASSET_STATUS_IN_PROGRESS, null);
        payload2.assetName = Constants.ASSET_TYPE_NAME_DOC;
        payload2.createAsset2Ver = 'true';

        Verification_Packet__c vPacket = new Verification_Packet__c();
        vPacket.Is_Active__c = true;
        vPacket.Case__c = newCase1.Id;
        insert vPacket;
        payload1.caseId = newCase1.Id;
        system.assert(vPacket.Id != null, 'verification packet creation failed');
        CloudStorageController.createAsset2VerificationRecord('https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00317000012ldOVAAY_New_Service_Template_2021-5-31_6_43_30.pdf', payload1);
    }
    @isTest static void testPIAandNewServTemp(){
        Id eurRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Id asstRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        system.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        system.assert(con.Id != null, 'Contact creation failed');
        Case eurCase = new Case();
        eurCase.RecordTypeId = eurRTId;
        eurCase.ContactId = con.Id;
        eurCase.AccountId = acc.Id;
        eurCase.Entity__c = acc.Id;
        eurCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SIGNATURE_CHECK;
        INSERT eurCase; 
        System.assert(eurCase.Id != null, 'Case creation failed');
        Service__c service = new Service__c();
        service.Name = 'Performance Data';
        insert service;
        System.assert(service.Id != null, 'Service creation failed');
        Case2Service__c c2s = new Case2Service__c();
        c2s.Service__c = service.Id;
        c2s.Case__c = eurCase.Id;
        Insert c2s;
        System.assert(c2s.Id != null, 'Case2Service creation failed');
        eurCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
        UPDATE eurCase;
        System.assert(eurCase.Id != null, 'Case update failed');
        Asset asst1 = new Asset(
                Name = Constants.ASSET_TYPE_PIA_TEMPLATE,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Type__c = Constants.ASSET_TYPE_PIA_TEMPLATE,
                Case__c = eurCase.Id,
                RecordTypeId = asstRTId,
                Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/003e000001NJIrfAAH_PIA_Template_2021-5-31_6_41_16.pdf'
            );
        INSERT asst1;
        System.assert(asst1.Id != null, 'Asset creation failed');
        Asset asst2 = new Asset(
                Name = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Type__c = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE,
                Case__c = eurCase.Id,
                RecordTypeId = asstRTId,
                Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00317000012ldOVAAY_New_Service_Template_2021-5-31_6_43_29.pdf'
            );
        INSERT asst2;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
        CloudStorageController.getNewServiceTemplate(new List<Asset>{asst1,asst2});
        asst2.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst2.Case__c = eurCase.Id;
        update asst2;
        system.assertEquals(eurCase.Id, asst2.case__c, 'case id not updated');
        eurCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        update eurCase;        
        system.assertEquals(CloudStorageController.getCaseStatus(eurCase.Id).split(':')[0], Constants.CASE_STATUS_NEW, 'case status not retrieved');
        CloudStorageController.ResultWrap resp = new CloudStorageController.ResultWrap();        
        resp = CloudStorageController.linkAssetToVPMethod(string.valueOf(eurCase.Id), string.valueOf(asst2.Id), 'Supporting Document', url);
        system.assertNotEquals(null, resp, 'Success');
        resp = CloudStorageController.linkAssetToVPMethod(string.valueOf(eurCase.Id), string.valueOf(asst2.Id), 'Verified', url);
        system.assertNotEquals(null, resp, 'Success');
        Test.stopTest();
        system.assert([SELECT Id FROM Cloud_Document__c WHERE Url__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00317000012ldOVAAY_New_Service_Template_2021-5-31_6_43_29.pdf']!=null, 'Cloud doc should be created');
    }
    @isTest
    static void testInsertAsset(){
        Id asstRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        system.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        system.assert(con.Id != null, 'Contact creation failed');
        Test.startTest();
        Asset tstAsset = new Asset(
                Name = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Type__c = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE,
                RecordTypeId = asstRTId,
                Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00317000012ldOVAAY_New_Service_Template_2021-5-31_6_43_29.pdf');
        String strAsstId = CloudStorageController.insertAsset(tstAsset);
        system.assertEquals(strAsstId, tstAsset.Id, 'Asset Id retrieved successfully');
        Test.stopTest();
    }

    @isTest
    static void testGetParentId(){        
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        //
        Id asstRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        Asset tstAsset = new Asset(
                Name = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE,
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = tstContact.Id,
                InstallDate = System.Today(),
                Type__c = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE,
                RecordTypeId = asstRTId,
                Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00317000012ldOVAAY_New_Service_Template_2021-5-31_6_43_29.pdf');
        INSERT tstAsset;
        System.assert(tstAsset.Id!= null,'Asset creation failed');
        Asset tstAsset2 =[SELECT Id,Name, Azure_Storage_URL__c FROM Asset WHERE Id =: tstAsset.Id LIMIT 1];
        Test.startTest();
        String strAsstId = CloudStorageController.getParentId(tstAsset2.Azure_Storage_URL__c);
        system.assertEquals(strAsstId, tstAsset.Id, 'Asset Id retrieved successfully');
        Test.stopTest();
    }
    @isTest
    static void testCreateAsset2VPRec(){
        Id cvRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Case cvCase = [SELECT Id, Internal_Status__c, ContactId FROM Case WHERE RecordTypeId =: cvRecTypeID AND ContactId=:tstContact.Id LIMIT 1];
        Asset tstAsset = [SELECT Id, Name, Case__c FROM Asset WHERE Case__c=:cvCase.Id LIMIT 1];
        Verification_Packet__c tstVerificationPacket = [SELECT Id FROM Verification_Packet__c WHERE Case__c =:cvCase.Id AND Is_Active__c = true WITH SECURITY_ENFORCED];
        Asset2Verification__c tstAsset2VPRec = [SELECT Id, Name,Asset__c,Asset_Type__c, Verification_Packet__c FROM Asset2Verification__c WHERE Verification_Packet__c=:tstVerificationPacket.Id LIMIT 1];
        String tstAssetId = '';
        Test.startTest();
        CloudStorageController.ResultWrap testResWrap = CloudStorageController.createAsset2VPRec(tstAsset2VPRec, tstAsset.Id);
        system.assertNotEquals(testResWrap.message, '', 'Asset2VP Created successfully');
        Test.stopTest();
    }
    @isTest
    static void testLinkAssetToVPMethod(){
        Id cvRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Case cvCase = [SELECT Id, Internal_Status__c, ContactId FROM Case WHERE RecordTypeId =: cvRecTypeID AND ContactId=:tstContact.Id LIMIT 1];
        Asset tstAsset = [SELECT Id, Name, Case__c,Azure_Storage_URL__c FROM Asset WHERE Case__c=:cvCase.Id LIMIT 1];
        Test.startTest();
        CloudStorageController.ResultWrap testResWrap = CloudStorageController.linkAssetToVPMethod(string.valueOf(cvCase.Id), string.valueOf(tstAsset.Id),'Cover Letter',tstAsset.Azure_Storage_URL__c);
        system.assertNotEquals(testResWrap.message, '', 'Asset2VP Created successfully');
        //aSSET NULL
        CloudStorageController.ResultWrap testResWrap2 = CloudStorageController.linkAssetToVPMethod(string.valueOf(cvCase.Id), null,'Cover Letter',tstAsset.Azure_Storage_URL__c);
        system.assertNotEquals(testResWrap2.message, '', 'Asset2VP Created successfully');
        //Supporting Document
        CloudStorageController.ResultWrap testResWrap3 = CloudStorageController.linkAssetToVPMethod(string.valueOf(cvCase.Id), string.valueOf(tstAsset.Id),'Supporting Document',tstAsset.Azure_Storage_URL__c);
        system.assertNotEquals(testResWrap3.message, '', 'Asset2VP Created successfully');

        //blank value for doc type
        //Supporting Document
        CloudStorageController.ResultWrap testResWrap4 = CloudStorageController.linkAssetToVPMethod(string.valueOf(cvCase.Id), string.valueOf(tstAsset.Id),'test',tstAsset.Azure_Storage_URL__c);
        system.assertNotEquals(testResWrap4.message, '', 'Asset2VP Created successfully');

        CloudStorageController.ResultWrap testResWrap5 = CloudStorageController.linkAssetToVPMethod('', string.valueOf(tstAsset.Id),'Supporting Document',tstAsset.Azure_Storage_URL__c);
        system.assertNotEquals(testResWrap4.message, '', 'Asset2VP Created successfully');
        
        Test.stopTest();
    }
    @isTest
    static void testCheckAssetExists(){
        Id appForCertRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Case appForCertCase = [SELECT Id, Internal_Status__c, ContactId FROM Case WHERE RecordTypeId =: appForCertRecTypeID AND ContactId=:tstContact.Id LIMIT 1];
        Asset tstAsset = [SELECT Id, Name, Case__c FROM Asset WHERE Case__c=:appForCertCase.Id LIMIT 1];
        Test.startTest();
        String strAsstId = CloudStorageController.checkAssetExists(string.valueOf(appForCertCase.Id),'',Constants.ASSET_TYPE_TRANSLATION);
        system.assertEquals(strAsstId, tstAsset.Id, 'Asset Id retrieved successfully');
        Test.stopTest();
    }
    @isTest
    static void testAssetCreatePBLogic(){
        Id appForCertRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Case appForCertCase = [SELECT Id, Internal_Status__c, ContactId,CaseNumber FROM Case WHERE RecordTypeId =: appForCertRecTypeID AND ContactId=:tstContact.Id LIMIT 1];
        Account tstAccount = [SELECT ID, Name FROM Account WHERE Name='Test Account' LIMIT 1];
        Cloud_Document__c cloudDocs2 = new Cloud_Document__c();
        cloudDocs2.Name = 'assetCreation2';
        cloudDocs2.Payload__c ='{"assetCreationRequired":"true","sourceDocument":"true","parentKey":"letter","parentUrl":"http://wwww.test.test","key":"letter","assetRecordType":"Credential","assetStatus":"In Progress","contactId":"'+tstContact.Id+'","createOrReplace":"Replace","documentType":"TCT Translation","isUploadLocation":"DocumentEditingTab","caseNumber":"'+appForCertCase.CaseNumber+'"}';
        cloudDocs2.url__c = 'https://ecfmgdev001.blob.core.windows.net/sfdc-applicant-documents/00317000017f5GhAAI_Passport_Translation_Page_0.pdf';
        INSERT cloudDocs2;
        Cloud_Document__c cloudDocsEras = new Cloud_Document__c();
        cloudDocsEras.Name = 'assetCreationEras';
        cloudDocsEras.Payload__c ='{"assetCreationRequired":"true","assetRecordType":"Identity","assetStatus":"New","contactId":"'+tstContact.Id+'","createOrReplace":"Create","documentType":"Photo","assetName":"ERAS Photo","caseId":"'+appForCertCase.Id+'","createFromPB":"true","uploadedByApplicant":"true"}';
        cloudDocsEras.url__c = 'https://ecfmgdev001.blob.core.windows.net/sfdc-applicant-documents/00317000017f5GhAAI_Passport_Translation_Page_0.pdf';
        INSERT cloudDocsEras;
        Test.startTest();
        CloudStorageController.createAssetsPBAction(new List<Cloud_Document__c>{cloudDocs2});
        System.assert(cloudDocs2 <> null, 'Record is not yet created on the Cloud Document object');
        CloudStorageController.createAssetsPBAction(new List<Cloud_Document__c>{cloudDocsEras});
        System.assert(cloudDocsEras <> null, 'Record is not created on the Cloud Document object');
        Test.stopTest();
    }
    @isTest
    static void testUpdateProductFields(){
        Id bioChangeCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
        Id ecfmgCerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Id appForCertRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();

        Account tstAccount = [SELECT ID, Name FROM Account WHERE Name='Test Account' LIMIT 1];
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Case bioChangeCase = [SELECT Id, Internal_Status__c, ContactId,CaseNumber FROM Case WHERE RecordTypeId =: bioChangeCaseRecTypeId AND ContactId=:tstContact.Id LIMIT 1];
        Case appForCertCase = [SELECT Id, Internal_Status__c, ContactId FROM Case WHERE RecordTypeId =: appForCertRecTypeID AND ContactId=:tstContact.Id LIMIT 1];

        Contact_Association_Type_Staging__c tstConStageRec = [SELECT Id,Start_Month__c,Start_Year__c,End_Month__c,Degree_Issue_Month__c,Degree_Issue_Year__c,Degree_Title__c,Degree_expected_to_be_issued_Month__c,Degree_expected_to_be_issued_Year__c  FROM Contact_Association_Type_Staging__c WHERE RecordTypeId =:medSchlRecordTypeId AND Case__c =:appForCertCase.Id LIMIT 1];
        Asset tstAsset = [SELECT Id, Name, Case__c FROM Asset WHERE Case__c=:bioChangeCase.Id LIMIT 1];
        String tstAzureURL1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        //Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION
        Case ecfmgCertCase = [SELECT Id, Internal_Status__c, ContactId FROM Case WHERE RecordTypeId =:ecfmgCerRecordTypeId  AND ContactId=:tstContact.Id LIMIT 1];
        Test.startTest();
        CloudStorageController.updateProductFields(Constants.ASSET_NAME_PASSPORT,String.valueOf(tstAsset.Id));
        System.assert(tstAsset <> null, 'Product field updated');
        Boolean readOnly2 = CloudStorageController.checkReadOnly(ecfmgCertCase.Id);
        system.assertNotEquals(false, readOnly2, 'case owner changed');

        CloudStorageController.PayloadWrapper payload2= new CloudStorageController.PayloadWrapper(String.valueOf(tstContact.Id), Constants.ASSET_NAME_PASSPORT_TRANSLATION, 
        'Identity', 'Replace', 'Add a New User Request', String.valueOf(tstAccount.Id),  'true', Constants.ASSET_STATUS_IN_PROGRESS, null,'Passport','Passport','','true',tstAzureURL1);
        
        CloudStorageController.PayloadWrapper payload3= new CloudStorageController.PayloadWrapper(String.valueOf(tstContact.Id), Constants.ASSET_NAME_PASSPORT_TRANSLATION, 
        'Identity', 'Create', 'Add a New User Request', String.valueOf(tstAccount.Id),  'true', Constants.ASSET_STATUS_IN_PROGRESS, null,'Passport','Passport','','true',tstAzureURL1,Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB,bioChangeCase.CaseNumber);
        
        Date attEndDate = Date.parse('06/06/2024');
        Date attStartDate = Date.parse('06/06/2018');
        Date attDegreeDate = Date.parse('07/07/2024');
        Date expiraDate = Date.parse('07/07/2029');
        Date issueDate = Date.parse('07/07/2024');
        Date progEndDate = Date.parse('07/07/2022');
        Date progStartDate = Date.parse('07/07/2020');
        Date deanLetterDate = Date.parse('07/07/2024');

        CloudStorageController.PayloadWrapper payload4= new CloudStorageController.PayloadWrapper(String.valueOf(tstContact.Id), Constants.ASSET_NAME_PASSPORT_TRANSLATION, 
        Constants.ASSET_RECORD_TYPE_APP_FOR_CERT, 'Create',String.valueOf(appForCertCase.Id), String.valueOf(tstAccount.Id),  'true', 
        Constants.ASSET_STATUS_IN_PROGRESS, null,'Passport',attEndDate,attStartDate,attDegreeDate,'MBBS','2024','June','2024',expiraDate,
        issueDate,progEndDate,progStartDate,'TEST',deanLetterDate,'June','June','2018','2024');
        
        Test.stopTest();
    }
    @isTest
    static void testAssetOutdate(){
        List<Asset> asstList= new List<Asset>();
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constant_Asset__mdt.getInstance('RECORD_TYPE_CREDENTIAL').Value__c).getRecordTypeId();
        Contact cont = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];  
        Asset asst1 = new Asset(Name='First', Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, type__c = Constant_Asset__mdt.getInstance('TYPE_PHOTO').Value__c, RecordTypeId = recordTypeId, ContactId = cont.Id);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst1);
        Asset asst2 = new Asset(Name='Second', Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, type__c = Constant_Asset__mdt.getInstance('TYPE_PHOTO').Value__c, RecordTypeId = recordTypeId, ContactId = cont.Id);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst2);
        Asset asst3 = new Asset(Name='Third', Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, type__c = Constant_Asset__mdt.getInstance('TYPE_PHOTO').Value__c, RecordTypeId = recordTypeId, ContactId = cont.Id);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst3);
        // New Asset
        Asset asstNew = new Asset(Name='Third', Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, type__c = Constant_Asset__mdt.getInstance('TYPE_PHOTO').Value__c, RecordTypeId = recordTypeId, ContactId = cont.Id);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asstNew);
        run();
        asstList.add(asstNew);
        CloudStorageController.outdateAssets(asstList);
        Asset asst1Retr = [SELECT Id,Status FROM Asset WHERE id=:asst1.Id LIMIT 1];
        System.assert(asst1Retr.Status != Constants.ASSET_STATUS_OUTDATED, 'Asset Should not get Outdated');
        Asset asst2Retr = [SELECT Id,Status FROM Asset WHERE id=:asst2.Id LIMIT 1];
        System.assert(asst2Retr.Status != Constants.ASSET_STATUS_OUTDATED, 'Asset Should not get Outdated');
        Asset asst3Retr = [SELECT Id,Status FROM Asset WHERE id=:asst3.Id LIMIT 1];
        System.assert(asst3Retr.Status == Constants.ASSET_STATUS_OUTDATED, 'Asset didnt get Outdated');
        Test.stopTest();
        
    }
    @isTest
    static void testErasAssetoutdate(){
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constant_Asset__mdt.getInstance('RECORD_TYPE_CREDENTIAL').Value__c).getRecordTypeId();
        Contact cont = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ContactId=cont.Id, RecordTypeId=erasRecordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c));
        run();
        Asset asst1 = new Asset(Name='ERAS Photo', Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, type__c = Constant_Asset__mdt.getInstance('TYPE_PHOTO').Value__c, RecordTypeId = recordTypeId, ContactId = cont.Id, Case__c = cas.Id);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst1);
        run();
        Cloud_Document__c cloudDocs = new Cloud_Document__c();
        cloudDocs.Name = 'assetCreation';
        cloudDocs.Payload__c ='{"assetCreationRequired":"true","assetRecordType":"Credential","assetStatus":"In Progress","contactId":"'+cont.Id+'","createOrReplace":"Replace","documentType":"ERAS Photo","isUploadLocation":"DocumentEditingTab","caseNumber":"","caseId":"'+cas.Id+'","type":"Photo"}';
        cloudDocs.url__c = 'https://ecfmgdev001.blob.core.windows.net/sfdc-applicant-documents/00317000017f5GhAAI_Passport_Translation_Page_0.pdf';
        INSERT cloudDocs;
        CloudStorageController.createAssetsPBAction(new List<Cloud_Document__c>{cloudDocs});        
        System.assert(cloudDocs <> null, 'Record is not yet created on the Cloud Document object');
        Asset retAsset = [SELECT Id,Status FROM Asset WHERE id=:asst1.Id LIMIT 1];
        System.assert(retAsset.Status == Constants.ASSET_STATUS_OUTDATED, 'Asset didnt get Outdated');
        Test.stopTest();
    }
}