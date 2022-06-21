@isTest
private class ApplicantMyProfileControllerTests extends ECFMGTestFactory{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    Static final String EXAMTYPE = 'USMLE Step 1';
    Static final String TESTVAL = 'Test Value';
    public static final String UNITED_STATES  = 'United States';
    public static final String AMERICA_LA = 'New Jersey';
    public static final String POSTALCD = 'x123';    
    @testSetup static void setup(){
        CommunitiesTestFactory.setup();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Account a = new Account(Name = 'Test');
        a.BillingCountry = 'United States';
        a.BillingState = 'New Jersey';
        a.BillingPostalCode = 'x123';
        insert a;
        List<Product2> productList = new List<Product2>();
        Product2 p1 = new Product2(Name = 'EPIC', ProductCode = 'EPIC', isActive = true);
        Product2 p2 = new Product2(Name = 'ECFMG_Certification', ProductCode = 'ECFMG_Certification', isActive = true);
        Product2 p3 = new Product2(Name = 'GEMx', ProductCode = 'GEMx', isActive = true);
        Product2 p4 = new Product2(Name = 'J1', ProductCode = 'J1', isActive = true);
        Product2 p5 = new Product2(Name = 'Credential Review', ProductCode = 'Credential Review', isActive = true);
        Product2 p6 = new Product2(Name = 'Identity', ProductCode = 'Identity', isActive = true);
        Product2 p7 = new Product2(Name = 'Passport', ProductCode = 'Passport', isActive = true);
        Product2 p8 = new Product2(Name = 'Photo', ProductCode = 'Photo', isActive = true);
        Product2 p9 = new Product2(Name = 'ID Form', ProductCode = 'ID Form', isActive = true);
        productList.add(p1);
        productList.add(p2);
        productList.add(p3);
        productList.add(p4);
        productList.add(p5);
        productList.add(p6);
        productList.add(p7);
        productList.add(p8);
        productList.add(p9);
        insert productList;
        List<Asset> assetList = new List<Asset>();
        Asset ap1 = new Asset(Name = 'EPIC', Product2Id = p1.Id, AccountId = a.Id, ContactId = conId);
        Asset ap2 = new Asset(Name = 'ECFMG_Certification', Product2Id = p2.Id, AccountId = a.Id, ContactId = conId);
        Asset ap3 = new Asset(Name = 'GEMx', Product2Id = p3.Id, AccountId = a.Id, ContactId = conId);
        Asset ap4 = new Asset(Name = 'J1', Product2Id = p4.Id, AccountId = a.Id, ContactId = conId);
        Asset ap5 = new Asset(Name = 'Credential Review', Product2Id = p5.Id, AccountId = a.Id, ContactId = conId);
        Asset ap6 = new Asset(Name = 'Identity', Product2Id = p6.Id, AccountId = a.Id, ContactId = conId);
        Asset ap7 = new Asset(Name = Constants.ASSET_NAME_PASSPORT, status = Constants.ASSET_STATUS_VERIFIED, AccountId = a.Id, ContactId = conId);
        assetList.add(ap1);
        assetList.add(ap2);
        assetList.add(ap3);
        assetList.add(ap4);
        assetList.add(ap5);
        assetList.add(ap6);
        assetList.add(ap7);
        insert assetList;
        List<Affirmation__c> affirmationList = new List<Affirmation__c>();
        Affirmation__c apaff1 = new Affirmation__c(Asset__c = ap1.Id, Status__c = 'Rejected', Photo_is_Pixelated_Picklist__c = 'Yes');
        Affirmation__c apaff2 = new Affirmation__c(Asset__c = ap2.Id, Status__c = 'Rejected', ID_Document_MRZ_Visible_Picklist__c = 'No');
        Affirmation__c apaff3 = new Affirmation__c(Asset__c = ap3.Id);
        affirmationList.add(apaff1);
        affirmationList.add(apaff2);
        affirmationList.add(apaff3);
        insert affirmationList;
        List<Case> caseList = new List<Case>();
        Case c1 = new Case(contactId = conId, Internal_Status__c = 'Complete', Service__c = 'EPIC', AccountId = a.Id, AssetId = ap1.Id);
        Case c2 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'ECFMG_Certification', AccountId = a.Id, AssetId = ap2.Id);
        Case c3 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'GEMx', AccountId = a.Id, AssetId = ap3.Id);
        Case c4 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'J1', AccountId = a.Id, AssetId = ap4.Id);
        Case c5 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'GEMx', AccountId = a.Id, AssetId = ap5.Id);
        Case c6 = new Case(contactId = conId, Internal_Status__c = 'ID Review', Service__c = 'EPIC', AccountId = a.Id, AssetId = ap6.Id);
        caseList.add(c1);
        caseList.add(c2);
        caseList.add(c3);
        caseList.add(c4);
        caseList.add(c5);
        caseList.add(c6);
        insert caseList;
        List<Asset> allAssets = new List<Asset>();
        Asset a1 = new Asset(Name = 'Photo', type__c = 'Photo', case__c = c6.Id, AccountId = a.id, ContactId = conId, Status = 'Accepted', Product2Id = p8.Id);
        Asset a2 = new Asset(Name = 'Passport', type__c = 'Passport', case__c = c6.Id, AccountId = a.id, ContactId = conId, Status = 'Accepted', Product2Id = p7.Id);
        Asset a3 = new Asset(Name = 'ID Verification', type__c = 'ID Verification', case__c = c6.Id, AccountId = a.id, ContactId = conId, Status = 'In Progress', Product2Id = p9.Id);
        allAssets.add(a1);
        allAssets.add(a2);
        allAssets.add(a3);
        insert allAssets;
        Affirmation__c aff1 = new Affirmation__c(Asset__c = a1.Id, Status__c = 'Rejected', Photo_is_Pixelated_Picklist__c = 'Yes');
        Affirmation__c aff2 = new Affirmation__c(Asset__c = a2.Id, Status__c = 'Rejected', ID_Document_MRZ_Visible_Picklist__c = 'No');
        Affirmation__c aff3 = new Affirmation__c(Asset__c = a3.Id);
        insert aff1;
        insert aff2;
        insert aff3;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion cv1 = new ContentVersion(Title = 'Photo', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv2 = new ContentVersion(Title = 'Passport', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv3 = new ContentVersion(Title = 'Translation', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv4 = new ContentVersion(Title = 'Expiration', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv5 = new ContentVersion(Title = 'Gov', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv6 = new ContentVersion(Title = 'Doc1', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv7 = new ContentVersion(Title = 'Doc2', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv8 = new ContentVersion(Title = 'Doc3', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv9 = new ContentVersion(Title = 'Doc4', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        ContentVersion cv10 = new ContentVersion(Title = 'Doc5', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        contentVersionList.add(cv1);
        contentVersionList.add(cv2);
        contentVersionList.add(cv3);
        contentVersionList.add(cv4);
        contentVersionList.add(cv5);
        contentVersionList.add(cv6);
        contentVersionList.add(cv7);
        contentVersionList.add(cv8);
        contentVersionList.add(cv9);
        contentVersionList.add(cv10);
        insert contentVersionList;
        List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = ap1.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd2 = new ContentDocumentLink(LinkedEntityId = ap2.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd3 = new ContentDocumentLink(LinkedEntityId = ap3.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd4 = new ContentDocumentLink(LinkedEntityId = ap4.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd5 = new ContentDocumentLink(LinkedEntityId = ap5.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd6 = new ContentDocumentLink(LinkedEntityId = ap6.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cdla1 = new ContentDocumentLink(LinkedEntityId = a1.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd2a2 = new ContentDocumentLink(LinkedEntityId = a2.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd3a3 = new ContentDocumentLink(LinkedEntityId = a3.Id, ContentDocumentId = documents[0].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        documentLinkList.add(cdl);
        documentLinkList.add(cd2);
        documentLinkList.add(cd3);
        documentLinkList.add(cd4);
        documentLinkList.add(cd5);
        documentLinkList.add(cd6);
        documentLinkList.add(cdla1);
        documentLinkList.add(cd2a2);
        documentLinkList.add(cd3a3);
        insert documentLinkList;
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        settings.Applicant_Bio_Change_Cancel_Statuses__c = 'Pending Review|In Review';
        // Removed Hardcoded value settings.Builder_Test_Contact__c = '0030U00000PGMbC';
        settings.Builder_Test_Contact__c = conId;
        settings.Builder_Test_Service__c = 'EPIC';
        settings.ID_Form_Product_Code__c = 'ID Form';
        settings.ID_Verification_Case_Paid_Status__c = 'Pending ID Review';
        settings.ID_Verification_Case_Queue_Name__c = 'ID Review Queue';
        settings.ID_Verification_Case_Unpaid_Status__c = 'New';
        settings.Passport_Product_Code__c = 'Passport';
        settings.Photo_Product_Code__c = 'Photo';
        settings.Username_Append__c = '.dev';
        upsert settings Community_Settings__c.Id;
        Security_Settings__c secSettings = Security_Settings__c.getOrgDefaults();
        secSettings.Disable_URL_Encryption__c = false;
        secSettings.Encryption_Key__c = 'FeThWmEq3t5w9z$C&F)J@NcRfajXn2r4';
        upsert secSettings Security_Settings__c.Id;
        Terms_and_Conditions__c tc1 = new Terms_and_Conditions__c(Name = 'A', Status__c = 'Active', ExpirationDate__c = Date.Today() + 7);
        Terms_and_Conditions__c tc2 = new Terms_and_Conditions__c(Name = 'Certification by Applicant', Status__c = 'Active', ExpirationDate__c = Date.Today() + 7);
        insert tc1;
        insert tc2;
    }
    public static testMethod void runTest(){
        test.startTest();
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000456';
        upsert settingsInstance;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000456';
        upsert settingsECFMGInstance;
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
        run();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        Contact c = [Select Id from Contact WHERE Id = :conId];
        List<ContentDocument> documents = [SELECT Id, ParentId, Title, LatestPublishedVersionId FROM ContentDocument];
        List<Asset> allAssets = [Select Id from Asset];
        Terms_and_Conditions__c tc = [Select Id FROM Terms_and_Conditions__c][0];
        // Create Case
        Id applBioaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
        Case caseobj = new Case();
        caseobj.ContactId= conId;
        caseobj.RecordTypeId = applBioaseRecordTypeId;
        caseobj.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);
        run();
        List<Case> caseL = [Select Id FROM Case];
        List<String> assetIds = new List<String>();
        List<String> entIds = new List<String>();
        Case c1 = [Select Id FROM Case WHERE Service__c = 'EPIC'][1];
        assetIds.add(allAssets[0].Id);
        entIds.add(documents[0].ParentId);
        ApplicantMyProfileController.getContact();
        ApplicantMyProfileController.updateContact(c);
        ApplicantMyProfileController.updateContactInformation(conId, 'US', 'A', 'A', 'CA', '38570', '1111', 'Cell');
        Map<String, String>inputMap = new Map<String, String>();
        inputMap.put('fName', 'John');
        inputMap.put('lName', 'Doe');
        inputMap.put('genderVal', 'Male');
        inputMap.put('ppCountry', 'USA');
        inputMap.put('reason', 'Test');
        inputMap.put('confirm', tc.Id);
        String mapInput = JSON.serialize(inputMap);
        System.runAs(u){
        ApplicantMyProfileController.updateContactBiographics(false, '', Date.today() - 700, Date.Today() - 7, Date.Today() + 7, '11111', mapInput);
        ApplicantMyProfileController.getCountriesMap();
        ApplicantMyProfileController.checkRestrictedCountry('United States');
        ApplicantMyProfileController.checkRestrictedCountry('North Korea');
        ApplicantMyProfileController.checkRestrictedCountry('KP');
        ApplicantMyProfileController.checkRestrictedCountry('NK');
        ApplicantMyProfileController.getCaseDetails(caseL[0].Id);
        ApplicantMyProfileController.cancelCase(caseL[0].Id, 'Reason', 'XXXX', 'Agent');
        ApplicantMyProfileController.getAffirmationResults('EPIC', c1.Id);
        ApplicantMyProfileController.addNote(caseL[0].Id, 'Note', 'Body');
        }
        Terms_and_Conditions__c tc1 = [Select Id FROM Terms_and_Conditions__c][0];
        Contact_Staging__c s1 = new Contact_Staging__c(
                Case__c = caseL[0].Id,
                Contact__c = conId,
                First_Name__c = 'John', Last_Name__c = 'Doe', Gender__c = 'Male', Legal_Name_Consists_of_One_Name_Only__c = false, Passport_Country__c = 'USA',
                Passport_Expiration__c = Date.Today() + 365, Passport_Issue_Date__c = Date.Today() - 20, Passport_Number__c = '1111', Reason_for_Change__c = 'XXX', T_C_Agreement__c = tc1.Id);
        Contact_Staging__c s2 = new Contact_Staging__c(
                Case__c = caseL[5].Id,
                Contact__c = conId,
                First_Name__c = 'John', Last_Name__c = 'Doe', Gender__c = 'Male', Legal_Name_Consists_of_One_Name_Only__c = false, Passport_Country__c = 'USA',
                Passport_Expiration__c = Date.Today() + 365, Passport_Issue_Date__c = Date.Today() - 20, Passport_Number__c = '1111', Reason_for_Change__c = 'XXX', T_C_Agreement__c = tc1.Id);
        insert s1;
        insert s2;
        ContentVersion cv1 = new ContentVersion(Title = 'Photo', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true, Document_Type__c = 'Photo');
        ContentVersion cv2 = new ContentVersion(Title = 'Passport', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true, Document_Type__c = 'Passport');
        ContentVersion cv3 = new ContentVersion(Title = 'Translation', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true, Document_Type__c = 'Passport Translation');
        ContentVersion cv4 = new ContentVersion(Title = 'Photo', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true, Document_Type__c = 'Photo');
        ContentVersion cv5 = new ContentVersion(Title = 'Passport', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true, Document_Type__c = 'Passport');
        ContentVersion cv6 = new ContentVersion(Title = 'Translation', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true, Document_Type__c = 'Passport Translation');
        insert cv1;
        insert cv2;
        insert cv3;
        insert cv4;
        insert cv5;
        insert cv6;
        documents = [SELECT Id, ParentId, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = s1.Id, ContentDocumentId = documents[documents.size() - 6].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd2 = new ContentDocumentLink(LinkedEntityId = s1.Id, ContentDocumentId = documents[documents.size() - 5].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd3 = new ContentDocumentLink(LinkedEntityId = s1.Id, ContentDocumentId = documents[documents.size() - 4].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd4 = new ContentDocumentLink(LinkedEntityId = s2.Id, ContentDocumentId = documents[documents.size() - 3].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd5 = new ContentDocumentLink(LinkedEntityId = s2.Id, ContentDocumentId = documents[documents.size() - 2].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd6 = new ContentDocumentLink(LinkedEntityId = s2.Id, ContentDocumentId = documents[documents.size() - 1].Id, ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        insert cdl;
        insert cd2;
        insert cd3;
        insert cd4;
        insert cd5;
        insert cd6;
        ApplicantMyProfileController.getAssetFiles(assetIds);        
        CurrentECFMGIDSequence__c settingsECFMGInstanceCh = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstanceCh.ECFMG_ID__c = '10700001';
        upsert settingsECFMGInstanceCh;
        Contact con = new Contact();
        con.FirstName = 'Test1auto';
        con.LastName = 'Test1auto';
        con.Email = 'Test1@testauto.test';
        Insert con;
        System.assert(con.Id != null, 'Contact record insert failed');
        ApplicantMyProfileController.activateUserNew(con.Id);
        test.stopTest();
        System.assertEquals(true, [Select Id, IsActive FROM User WHERE ContactId =:con.Id].IsActive, 'The portal user should be active');
    }
    public static testMethod void userTests(){
        test.startTest();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        Case c2 = [SELECT ID FROM Case WHERE Internal_Status__c = 'Complete' AND Service__c = 'EPIC'];
        System.runAs(u) {
            ApplicantMyProfileController.getContactDetailsUpdateCases(false);
            ApplicantMyProfileController.getContactDetailsUpdateCases(true);
            ApplicantMyProfileController.createNotificationCase();
            ApplicantMyProfileController.getRunningContactId();
            ApplicantMyProfileController.getAssets();
            ApplicantMyProfileController.getAllAssets();
            ApplicantMyProfileController.getCancelableCaseStatuses();
            try{
            	ApplicantMyProfileController.getUserInfo(conId);
                ApplicantMyProfileController.getContactById(conId);
            }catch(Exception e){
                System.assertEquals(e.getMessage(), 'Insufficient permissions: secure query included inaccessible field', 'Exception should be thrown');
            }
            ApplicantMyProfileController.getTerms('A');
            ApplicantMyProfileController.getCountries();
            ApplicantMyProfileController.getRunningContactId();
            ApplicantCommunityController.getCountryAndStatePicklistEntries();
            ApplicantCommunityController.getContact(conId);
            ApplicantCommunityController.getGeoData();
            ApplicantCommunityController.getCaseImages(c2.Id);
            try{
                ApplicantCommunityController.errorTest();
            }catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Test exception thrown by Apex', 'Exception should be thrown');
            }
            ApplicantCommunityController.getGeoData();
            ApplicantCommunityController.getCaseImages(c2.Id);
        }
        test.stopTest();
    }
    public static testMethod void testMethodCaseDetails(){
        test.startTest();
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '3006000';
        upsert settingsInstance;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '10906901';
        upsert settingsECFMGInstance;
        date birthdate1 = date.valueOf('2001-01-01');
        
        List<Transcript_Request__c> myRecords = new List<Transcript_Request__c>();
        
        Account a = new Account(Name = 'Test');  
        a.BillingCountry = UNITED_STATES;
        a.BillingState = AMERICA_LA;
        a.BillingPostalCode = POSTALCD;
        insert a;
		Contact cont = new Contact(Firstname='FirstEerudRR1',Lastname='LastEdreiRR1',Birthdate=birthdate1, Gender__c='Male',Email='noemeredailerr1@nomeal.com');       
        insert cont;
		cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
        cadmus_core__Doc_Config__c docConfig1 = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c));    
        run();
        Id conId = cont.Id;
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE Id=:cont.Id ORDER BY CreatedDate DESC LIMIT 1];
        Case parcas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
      run();
        Case testCase = cas;
        testCase.parentId = parcas.Id;
        update testCase;
        System.assert(testCase.Id != null, 'Case record insert failed');
        Transcript_Request__c recToIns = new Transcript_Request__c(Case__c = testCase.Id, City__c = 'Chennai', Contact__c = conId, Country__c = 'India', Name_of_Recipient__c = 'Test User', Organization__c = 'Test Organisation', Send_to_Same_Address__c = true, Send_to_Self__c = true, State__c = 'TamilNadu', Street__c = 'Adyar Main Road', Zip_Postal_Code__c = '1234');
        insert recToIns;
        myRecords = ApplicantMyProfileController.getTrascriptRecs(testCase.Id);
        test.stopTest();
    }
    public static testMethod void testcheckPEForm(){
        test.startTest();
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '4000000';
        upsert settingsInstance;
        Boolean retVal;
        Account a = new Account(Name = 'Test');
        a.BillingCountry = UNITED_STATES;
        a.BillingState = AMERICA_LA;
        a.BillingPostalCode = POSTALCD;
        insert a;
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact_Association_Type__c' AND DeveloperName = 'Degree_Medical_School'];
        Id recTypeId = rt.Id;
        Contact_Association_Type__c newRec = new Contact_Association_Type__c(RecordTypeId = recTypeId, Account__c = a.Id, Contact__c = conId);
        insert newRec;
        System.assert(newRec.Id != null, 'CAT record insert failed');
        System.runAs(u) {
            retVal = ApplicantMyProfileController.checkPEForm();
        }
        test.stopTest();
    }
    public static testMethod void testgetInternalStatus(){
        test.startTest();
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '1100000';
        upsert settingsInstance;
        Boolean retVal;
        Account acc = new Account(Name = 'Test');  
        acc.BillingCountry = UNITED_STATES;
        acc.BillingState = AMERICA_LA;
        acc.BillingPostalCode = POSTALCD;
		insert acc;
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Case parentCase = new Case(Internal_Status__c = 'ID Review', contactId = conId, account = acc);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, parentCase);
        run();

        System.assert(parentCase.Id != null, 'Case record insert failed');
        Case childCase = new Case(Enrollment_Verification_Parent__c = parentCase.Id, contactId = conId, accountId = acc.Id);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, childCase);
        run();

        retVal = ApplicantMyProfileController.getInternalStatus(childCase.Id);
        test.stopTest();
    }
    public static testMethod void testcheckPermitForm(){
        test.startTest();
      	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '5000000';
        upsert settingsInstance;
        Boolean retVal;
        Account acc = new Account(Name = 'Test');  
        acc.BillingCountry = UNITED_STATES;
        acc.BillingState = AMERICA_LA;
        acc.BillingPostalCode = POSTALCD;
		insert acc;
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Case parentCase = new Case(Internal_Status__c = 'ID Review', contactId = conId, account = acc);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, parentCase);

        Exam_Registration__c examRec = new Exam_Registration__c(Exam_Status__c = 'Pass', Exam_Types__c = EXAMTYPE, Case__r = parentCase);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, examRec);
        run();

        System.assert(parentCase.Id != null, 'Case record insert failed');
        retVal = ApplicantMyProfileController.checkPermitForm(parentCase.Id);
        test.stopTest();
    }
    public static testMethod void testcontactStagingLicenseVal(){
        test.startTest();
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '8000000';
        upsert settingsInstance;
        String retVal;
        Account a = new Account(Name = 'Test');
        a.BillingCountry = UNITED_STATES;
        a.BillingState = AMERICA_LA;
        a.BillingPostalCode = POSTALCD;
        insert a;

        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact_Staging__c' AND DeveloperName = 'Exam_Registration'];
        Contact_Staging__c newRec = new Contact_Staging__c(Contact__c = conId, Previous_License__c = 'Yes', RecordTypeId = rt.Id);
        insert newRec;
        System.assert(newRec.Id != null, 'Contact Staging record insert failed');
        retVal = ApplicantMyProfileController.contactStagingLicenseVal();
        test.stopTest();
    }
    public static testMethod void testgetExamRegistrations(){
        test.startTest();
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '9000001';
        upsert settingsInstance;
        List<ApplicantMyProfileController.ExamRegRecordWrapper> retVal = new List<ApplicantMyProfileController.ExamRegRecordWrapper>();
        Account a = new Account(Name = 'Test');
        a.BillingCountry = UNITED_STATES;
        a.BillingState = AMERICA_LA;
        a.BillingPostalCode = POSTALCD;
		insert a;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '52000001';
        upsert settingsECFMGInstance;
        date birthdate1 = date.valueOf('2001-01-01');
        Contact cont = new Contact(Firstname='FirstERR33',Lastname='LastERR33',Birthdate=birthdate1, Gender__c='Male',Email='noemailerr34@nomeal.com');    
        insert cont;
       
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        Exam_Region_Surcharge__c regionSurcharge = new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
        regionSurcharge.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case newCase = new Case(
                RecordTypeId = examRegRecordTypeId,
                ContactId = cont.Id,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
        );
        insert newCase;

        System.assert(newCase.Id != null, 'Case record insert failed');
        date epStartDate = System.Today() + 1;
        date epEndDate = System.Today() - 25;
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
        updateExamRegistration.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        updateExamRegistration.Test_Accommodations_needed__c = 'yes';
        updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.Applicant__c = cont.Id;
        updateExamRegistration.Case__c = newCase.Id;
        updateExamRegistration.EP_Start_Date__c = epStartDate;
        updateExamRegistration.EP_End_Date__c = epEndDate;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, updateExamRegistration);
        run();

        retVal = ApplicantMyProfileController.getExamRegistrations(newCase.Id);
        test.stopTest();
    }
    public static testMethod void testgetStagingRecord(){
        test.startTest();
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '1200000';
        upsert settingsInstance;
        ApplicantMyProfileController.StagingRecordWrapper retVal;
        Account a = new Account(Name = 'Test');
        a.BillingCountry = UNITED_STATES;
        a.BillingState = AMERICA_LA;
        a.BillingPostalCode = POSTALCD;
       insert a;
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        Contact newRec2 = new Contact(Native_Language__c = 'English', Ethnicity__c = 'Asian', National_ID_Country__c = 'Bhutan', US_Social_Security__c = 'ABCDEF12345', National_Identification__c = TESTVAL, Id = conId);
        update newRec2;
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact_Staging__c' AND DeveloperName = :Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION];
        Id recTypeId = rt.Id;
        System.runAs(u) {
            Contact_Staging__c newRec = new Contact_Staging__c(RecordTypeId = recTypeId, Native_Language__c = 'English', Ethnicity__c = 'Asian', National_ID_Country__c = 'Bhutan', US_Social_Security__c = 'ABCDEF12345', National_Identification__c = TESTVAL, Contact__c = conId);
            insert newRec;
            Exam_Registration__c examRec = new Exam_Registration__c(Exam_Types__c = EXAMTYPE, Basic_Sciences_Requirement__c = 'Yes', Officially_Enrolled__c = 'Yes', Applicant__c = conId);
            insert examRec;
            System.assert(examRec.Id != null, 'Exam Registration record insert failed');
            retVal = ApplicantMyProfileController.getStagingRecord();
            newRec.Native_Language__c = NULL;
            update newRec;
            retVal = ApplicantMyProfileController.getStagingRecord();
        }
        test.stopTest();
    }
    public static testMethod void testsonarFixGetStaging(){
        test.startTest();
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '1300000';
        upsert settingsInstance;
        ApplicantMyProfileController.StagingRecordWrapper retVal;
        Account a = new Account(Name = 'Test');
        a.BillingCountry = UNITED_STATES;
        a.BillingState = AMERICA_LA;
        a.BillingPostalCode = POSTALCD;
        insert a;
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        Contact newRec = new Contact(Native_Language__c = 'English', Ethnicity__c = 'Asian', National_ID_Country__c = 'Bhutan', US_Social_Security__c = 'ABCDEF12345', National_Identification__c = TESTVAL, Id = conId);
        update newRec;
        System.runAs(u) {
            Exam_Registration__c examRec = new Exam_Registration__c(Exam_Types__c = EXAMTYPE, Basic_Sciences_Requirement__c = 'Yes', Officially_Enrolled__c = 'Yes', Applicant__c = conId);
            insert examRec;
            System.assert(examRec.Id != null, 'Exam Registration record insert failed');
            retVal = ApplicantMyProfileController.getStagingRecord();
        }
        test.stopTest();
    }
    public static testMethod void testgetDateInUserZone(){
        List<DateTime> returnVal = new List<DateTime>();
        List<DateTime> parameterList = new list<DateTime>();
        parameterList.add(System.now());
        returnVal = ApplicantMyProfileController.getDateInUserZone(parameterList);
        System.assertEquals(1, returnVal.size(), 'getDateInUserZone is good' );
    }
    public static testMethod void testisApplicantStudentOrGraduate(){
        test.startTest();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        System.assert(conId != null, 'Contact record not available');
        Contact newRec2 = new Contact(School_Enrollment_Status__c = 'Student', Id = conId);
        update newRec2;
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        Boolean check;
        System.runAs(u) {
            check = ApplicantMyProfileController.isApplicantStudentOrGraduate();
        }
        Contact newRec = new Contact(School_Enrollment_Status__c = 'Graduate', Id = conId);
        update newRec;
        System.runAs(u) {
            check = ApplicantMyProfileController.isApplicantStudentOrGraduate();
        }
        test.stoptest();
    }
    public static testMethod void testgetExamRegistrationforSummary(){
        test.startTest();
        List<ApplicantMyProfileController.RegionRecordWrapper> returnVal = new List<ApplicantMyProfileController.RegionRecordWrapper>();
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        Exam_Region_Surcharge__c regionSurcharge = new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
        regionSurcharge.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        Exam_Region__c region2 = new Exam_Region__c();
        region2.name = 'test_Region2';
        region2.Region_Name__c = 'test_Region2';
        insert region2;
        Exam_Region_Surcharge__c regionSurcharge2 = new Exam_Region_Surcharge__c();
        regionSurcharge2.Exam_Region__c = region2.Id;
        regionSurcharge2.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        regionSurcharge2.Surcharge__c = 100;
        insert regionSurcharge2;
        Exam_Registration__c examRec = new Exam_Registration__c(Exam_Types__c = EXAMTYPE);
        insert examRec;
        System.assert(examRec.Id != null, 'Exam Registration record insert failed');
        Case caseVal = new Case(Exam_Registration__c = examRec.Id, Exam_Region_Surcharge__c = regionSurcharge.Id);
        insert caseVal;
        returnVal = ApplicantMyProfileController.getExamRegistrationforSummary(caseVal.Id);
        test.stopTest();
    }
    public static testMethod void testgetUpdatedEPEx(){
        test.startTest();
        List<Case> returnVal = new List<Case>();
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        Exam_Region_Surcharge__c regionSurcharge = new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
        regionSurcharge.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        Exam_Registration__c examRec = new Exam_Registration__c(Exam_Types__c = EXAMTYPE);
        insert examRec;
        System.assert(examRec.Id != null, 'Exam Registration record insert failed');
        Case caseVal = new Case(Exam_Registration__c = examRec.Id, Exam_Region_Surcharge__c = regionSurcharge.Id);
        insert caseVal;
        returnVal = ApplicantMyProfileController.getUpdatedEPEx(caseVal.Id);
        test.stopTest();
    }
    public static testMethod void testgetAssetRec(){
        test.startTest();
        Boolean retVal;
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Asset' AND DeveloperName = 'Exam_Registration'];
        Exam_Registration__c examRec = new Exam_Registration__c(Exam_Types__c = EXAMTYPE);
        insert examRec;
        System.assert(examRec.Id != null, 'Exam Registration record insert failed');
        Case caseVal = new Case(Exam_Registration__c = examRec.Id);
        insert caseVal;
        Asset newAssetRec = new Asset(Name = 'SampleRecord', Type__c = 'Score Recheck Letter', RecordTypeId = rt.Id, Case__c = caseVal.Id, ContactId = conId);
        insert newAssetRec;
        retVal = ApplicantMyProfileController.getAssetRec(caseVal.Id);
        List<String> myStrVal = new List<String>();
        myStrVal = ApplicantMyProfileController.getAssetRecords(caseVal.Id);
        test.stopTest();
    }
    public static testMethod void testgetScoreReportInfo(){
        List<ScoreReportHelper.ExamScoreWrapper> retVal = new List<ScoreReportHelper.ExamScoreWrapper>();
        test.startTest();
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        Exam_Region_Surcharge__c regionSurcharge = new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
        regionSurcharge.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        date postedDate = date.parse('06/07/2018');
        Exam_Registration__c examRec = new Exam_Registration__c(Exam_Types__c = EXAMTYPE, Posted_Date__c = postedDate, Withheld_Reason__c = 'Pending Id Verification');
        insert examRec;
        System.assert(examRec.Id != null, 'Exam Registration record insert failed');
        Case caseVal = new Case(Exam_Registration__c = examRec.Id, Exam_Region_Surcharge__c = regionSurcharge.Id);
        insert caseVal;
        retVal = ApplicantMyProfileController.getScoreReportInfo(caseVal.Id);
        test.stopTest();
    }
    public static testMethod void testCheckAcceptedAsset(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        System.assert(conId != null, 'Contact record not available');
        string contactId = string.valueof(conId);
        string assetName = Constants.ASSET_NAME_PASSPORT;
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        Boolean check;
        test.startTest();
        System.runAs(u) {
            check = ApplicantMyProfileController.checkForAcceptedDoc();
            ApplicantMyProfileController.createAcceptedPhotoPayload(contactId, assetName);
        }
        List<Asset> assetList = [SELECT id FROM Asset where contactId = :conId AND status = :Constants.ASSET_STATUS_VERIFIED AND status != :Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        Delete assetList;
        System.runAs(u) {
            check = ApplicantMyProfileController.checkForAcceptedDoc();
        }
        test.stoptest();
    }
    public static testMethod void testGetPEFormURL(){
        test.startTest();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Case evCase = new Case(contactId = conId, Internal_Status__c = 'Complete', Service__c = 'EPIC');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, evCase);
        
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Enrollment Verification').getRecordTypeId();
        Asset ap1 = new Asset(Name = 'EPIC', Type__c = 'Enrollment Verification Form', RecordTypeId = assetRTId, ContactId = conId, Case__c = evCase.Id, Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_ApplicationSummary.pdf');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, ap1);
        
        run();
        
        evCase.AssetId = ap1.Id;
        update evCase;
        Case newCase = new Case(contactId = conId, Enrollment_Verification_Parent__c = evCase.Id, Internal_Status__c = 'Complete', Service__c = 'EPIC');
        insert newCase;
        System.assert(newCase.Id != null, 'Case record insert failed');
        ApplicantMyProfileController.getPEFormURL(newCase.Id);
        test.stopTest();
    }
    public static testMethod void testPdfTronMethods(){
        test.startTest();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        System.assert(conId != null, 'Contact record not available');
        Asset ap1 = new Asset(ContactId = conId, Name = 'Passport', type__c = 'Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap2 = new Asset(ContactId = conId, Name = 'Photo', type__c = 'Photo', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap3 = new Asset(ContactId = conId, Name = Constants.ASSET_NAME_PASSPORT_TRANSLATION, type__c = 'Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap4 = new Asset(ContactId = conId, Name = Constants.ASSET_NAME_PASSPORT_EXPIRATION, type__c = 'Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        List<Asset> asstList = new List<Asset>();
        asstList.add(ap1);
        asstList.add(ap2);
        asstList.add(ap3);
        asstList.add(ap4);
        insert asstList;
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
        Case testCase = new Case(ContactId = conId, Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION, RecordTypeId = caseRecordTypeId);
        try{
        insert testCase;
        }catch(Exception e){
            testCase = null;
        }
        if(testCase!=null){
            Contact_Staging__c cs = new Contact_Staging__c(Case__c = testCase.Id);
                try{
                    insert cs;
                }catch(Exception e){
                    cs = null;
                }
            }
        String cloudUrl = 'https://ecfmgdev001.blob.core.windows.net/sfdc-applicant-documents/00317000017f5GhAAI_Passport_Translation_Page_0.pdf';        
        ApplicantMyProfileController.createPassportPayload(conId);
        ApplicantMyProfileController.createPassportTranslationPayload(conId);
        ApplicantMyProfileController.createPhotoPayload(conId);
        ApplicantMyProfileController.createBirthCertificatePayload(conId);
        ApplicantMyProfileController.createMarriageCertificatePayload(conId);
        ApplicantMyProfileController.createOfficialCourtOrderPayload(conId);
        ApplicantMyProfileController.createUsResidentAlienCardPayload(conId);
        ApplicantMyProfileController.createUsNaturalizationCertificatePayload(conId);
        ApplicantMyProfileController.createUsPassportCardPayload(conId);
        ApplicantMyProfileController.updateBirthCertificatePayload(conId, cloudUrl);
        ApplicantMyProfileController.updateMarriageCertificatePayload(conId, cloudUrl);
        ApplicantMyProfileController.updateOfficialCourtOrderPayload(conId, cloudUrl);
        ApplicantMyProfileController.updateUsResidentAlienCardPayload(conId, cloudUrl);
        ApplicantMyProfileController.updateUsNaturalizationCertificatePayload(conId, cloudUrl);
        ApplicantMyProfileController.updateUsPassportCardPayload(conId, cloudUrl);
        ApplicantMyProfileController.deleteExistingAsset(conId);
        ApplicantMyProfileController.deleteExistingExpirationAsset(conId);
        ApplicantMyProfileController.deleteExistingPassportAssets(conId);
        test.stopTest();
    }
    @isTest
    public static void testcheckRestrictOnAppBio(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Contact con = [SELECT Id,ServicesRestricted__c FROM Contact WHERE Id=:conId LIMIT 1];
        con.ServicesRestricted__c = 'Biographic Change - Internal and External';
        UPDATE con;
        User us = [SELECT Id, ContactId FROM User WHERE email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        String error='';
        try{
            System.runAs(us){
            	Test.startTest();
        		Boolean restrictExists = ApplicantMyProfileController.checkRestrictOnAppBio();
        		System.assert(restrictExists==true,'Bio Change Restriction not applied');
        		Test.stopTest();
        	}   
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @isTest
    public static void testGetIdentityVerifSummaryAsset(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        RecordType rtAsset = [SELECT Id FROM RecordType WHERE sObjectType = 'Asset' AND DeveloperName = 'Summary'];
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        //get identity verification case
        Case identityVerifCase = new Case();
		identityVerifCase.RecordTypeId = caseRTId;
		identityVerifCase.ContactId = conId;
		INSERT identityVerifCase;
        System.assert(identityVerifCase.Id != NULL, 'Identity Verification case creation failed.');
        Asset ap1 = new Asset(ContactId = conId, Case__c=identityVerifCase.Id, Name = 'Application Summary', Type__c = 'Application Summary', Status = Constants.ASSET_STATUS_ACCEPTED, RecordTypeId = rtAsset.Id, Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/003e000001NJIrfAAH_ApplicationSummary_2021-5-31_6_41_16.pdf');
		List<Asset> asstList = new List<Asset>();
        asstList.add(ap1);
        insert asstList;
        String error='';
        String myStrVal = '';
        try{
            test.startTest();
            myStrVal = ApplicantMyProfileController.getIdentityVerifSummaryAsset(identityVerifCase.Id);
            System.assert(myStrVal!='','Identity Verification Summary Asset not retrieved');
            test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @isTest
    private static void testCancelCase(){
        Test.startTest();  
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '2000001';
        upsert settingsInstance;
        Account a1 = new Account(Name = 'Test');
        a1.BillingCountry = UNITED_STATES;
        a1.BillingState = AMERICA_LA;
        a1.BillingPostalCode = POSTALCD;
        insert a1;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '20000001';
        upsert settingsECFMGInstance;
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='FirstERR2',Lastname='LastERR2',Birthdate=birthdate1, Gender__c='Male',Email='noemailERR2@nomeal.com');
        insert c1;
        
        // Create Case
        Id cvCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case caseobj = new Case();
        caseobj.ContactId= c1.Id;
        caseobj.AccountId = a1.Id;
        caseobj.RecordTypeId = cvCaseRecordTypeId;
        caseobj.Internal_Status__c = 'ID Review';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);
        run();

        // Create Asset
        List<RecordType> rts = [select Id from RecordType where Name = 'Identity' and SobjectType = 'Asset'];
        RecordType rt = rts[0];
        Asset asst = new Asset();
        asst.RecordType = rt;
        asst.Status = 'In Progress';
        asst.Type__c = 'Passport';
        asst.Case__c = caseobj.Id;
        asst.ContactId = c1.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssest.class, asst);
        run();
        
        // Create Affirmations
        Affirmation__c aff = new Affirmation__c();
        aff.Asset__c = asst.Id;
        insert aff;
        
        String retString = ApplicantMyProfileController.cancelCase(caseobj.Id, 'Other', 'No reason', 'Agent');
        System.assertEquals(retString, 'Success', 'Cancel Case failed');
        Test.stopTest();
    }
    @isTest
    private static void testgetCaseRestrictionDtl(){
        Test.startTest();  
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '6000000';
        upsert settingsInstance;
        Account a1 = new Account(Name = 'Test');
        a1.BillingCountry = UNITED_STATES;
        a1.BillingState = AMERICA_LA;
        a1.BillingPostalCode = POSTALCD;
        insert a1;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '30000001';
        upsert settingsECFMGInstance;
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='FirstERR3',Lastname='LastERR3',Birthdate=birthdate1, Gender__c='Male',Email='noemailERR3@nomeal.com');
        insert c1;
        // Create Case
        Id cvCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case caseobj = new Case();
        caseobj.ContactId= c1.Id;
        caseobj.AccountId = a1.Id;
        caseobj.RecordTypeId = cvCaseRecordTypeId;
        caseobj.Internal_Status__c = 'ID Review';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);
        run();

        String returnString = ApplicantMyProfileController.getCaseRestrictionDtl(caseobj.Id);
        System.assertEquals(returnString, '','Restriction no found');
        Test.stopTest();
    }
    @isTest
    private static void testcheckVisaLetter(){
        Test.startTest(); 
       	CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '2100001';
        upsert settingsInstance;
        Account a1 = new Account(Name = 'Test');
        a1.BillingCountry = UNITED_STATES;
        a1.BillingState = AMERICA_LA;
        a1.BillingPostalCode = POSTALCD;
        insert a1;
		CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '22000021';
        upsert settingsECFMGInstance;        
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='FirstERRr5',Lastname='LastERRr5',Birthdate=birthdate1, Gender__c='Male',Email='noemailERR5@nomeal.com');
        insert c1;
        
        // Create Case
        Id examCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case caseobj = new Case();
        caseobj.ContactId= c1.Id;
        caseobj.AccountId = a1.Id;
        caseobj.RecordTypeId = examCaseRecordTypeId;
        caseobj.Internal_Status__c = 'Registered';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);
        run();
        // Create Asset
        List<RecordType> rts = [select Id from RecordType where Name = 'Exam Registration' and SobjectType = 'Asset'];
        RecordType rt = rts[0];
        Asset asst = new Asset();
        asst.RecordType = rt;
        asst.Status = 'In Progress';
        asst.Type__c = 'Visa Letter';
        asst.Case__c = caseobj.Id;
        asst.ContactId = c1.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssest.class, asst);
        run();

        // Create ExamRegistration
        Exam_Registration__c exam = new Exam_Registration__c();
        exam.case__c = caseobj.Id;
        exam.Exam_Status__c ='';
        exam.Visa_Letter_Needed__c = True;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, exam);
        run();

        Boolean retVal = ApplicantMyProfileController.checkVisaLetter(caseobj.Id);
        System.assertEquals(false, retVal, 'No Return value');
        Test.stopTest();
    }
    @isTest
    private static void testActivateUser(){
        Test.startTest();   
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '8909001';
        upsert settingsECFMGInstance;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test1auto';
        cont.LastName = 'Test1auto';
        cont.Email = 'Test1@testauto.test';
        Insert cont;
        String usId = ApplicantMyProfileController.activateUser(cont.Id);
        System.assert(usId!=null,'User not created');
        Test.stopTest();
    }
    @isTest
    private static void testcreateAppBioPendingSubCase(){
        Test.startTest();    
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        System.runAs(u){
            ApplicantMyProfileController.createAppBioPendingSubCase();
            String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
            Case cs = [SELECT id FROM Case WHERE Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION  AND ContactId =: conId  AND RecordTypeId=:caseRecordTypeId LIMIT 1];
            System.assert(cs!=null,'Applicant Bio case is not Created');
        }
        Test.stopTest();
    }
    @isTest
    private static void testUpdateAppBioPendingSubCase(){
        Test.startTest();    
         cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
            run();
        Id conId = ApplicantMyProfileController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        System.runAs(u){
            ApplicantMyProfileController.createAppBioPendingSubCase();
            Boolean updateStatus = ApplicantMyProfileController.updateAppBioCaseStatus();
            Id appBioChangeReqRecordTypeId = Constants.APP_BIO_CHANGE_RDTYPEID;
            Case cs = [SELECT Id FROM Case WHERE Internal_Status__c =: Constants.CASE_STATUS_PENDING_REVIEW AND ContactId =: conId AND RecordTypeId=:appBioChangeReqRecordTypeId LIMIT 1];
            System.assert(cs!=null,'Applicant Bio case is not Updates');
        }
        Test.stopTest();
    }

    @isTest
    private static void testCheckAndGetCSAssosiated(){
        Test.startTest();    
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        System.runAs(u){
            String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
            Case testCase = new Case(ContactId = conId, Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION, RecordTypeId = caseRecordTypeId);
            try{
            insert testCase;
            }catch(Exception e){
            testCase = null;
            }
            if(testCase!=null){
            Contact_Staging__c cs = new Contact_Staging__c(Case__c = testCase.Id);
            try{
                insert cs;
            }catch(Exception e){
                cs = null;
            }
            }
            Contact_Staging__c testCS = ApplicantMyProfileController.checkAndGetCSAssosiated();
            System.assert(testCS!=null,'CS is not Created');
            ApplicantMyProfileController.deleteExistingPassportAssets(conId);
            testCS = ApplicantMyProfileController.checkAndGetCSAssosiated();
            System.assert(testCS==null,'CS is not deleted');
        }
        Test.stopTest();
    }
}