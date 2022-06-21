@isTest 
public class CommunityIdentityVerificationTest extends ECFMGTestFactory{
    Static final string CRENDENTIALREVIEW = 'Credential Review';
    Static final string IDFORM = 'ID Form';
    Static final string NOTSTARTED = 'New';
    Static final string INPROGRESS = 'In Progress';
    Static final string IDVER = 'ID Verification';
    Static final string PATH = 'Test.jpg';
    Static final string TESTCONTENT = 'Test Content Data';
    Static final string IDFORMNOTARIZED = 'ID Form Notarized';
    Static final string RESP = 'Do not wish to respond';
    @testSetup static void setup(){
        CommunitiesTestFactory.setup();
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.debug('con '+con);
        
        
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Account a = new Account(Name = 'Test');
        a.BillingCountry = 'United States';
        a.BillingState = 'New Jersey';
        a.BillingPostalCode = 'x123';
        INSERT a;

        //insert Association__c
        Id assotRecTypeId = Schema.SObjectType.Association__c.getRecordTypeInfosByDeveloperName().get('Employment').getRecordTypeId();
        Association__c tstAssociation = new Association__c();
        tstAssociation.RecordtypeId = assotRecTypeId;
        tstAssociation.Street__c = '123 Street';
        tstAssociation.State_Code__c = 'PA';
        tstAssociation.Postal_Code__c = '19060';
        tstAssociation.Country_Code__c = 'US';
        tstAssociation.Applicant__c = conId;
        tstAssociation.Dicipline__c = 'Pathology';
        tstAssociation.Name = 'Test2';
        tstAssociation.Title__c = 'Test';
        tstAssociation.Type__c = 'Physician';
        INSERT tstAssociation;
        
        Product2 p1 = new Product2(Name='EPIC', ProductCode='EPIC', isActive=true);
        Product2 p2 = new Product2(Name='ECFMG_Certification', ProductCode='ECFMG_Certification', isActive=true);
        Product2 p3 = new Product2(Name='GEMx', ProductCode='GEMx', isActive=true);
        Product2 p4 = new Product2(Name='J1', ProductCode='J1', isActive=true);
        Product2 p5 = new Product2(Name=CRENDENTIALREVIEW, ProductCode=CRENDENTIALREVIEW, isActive=true);
        Product2 p6 = new Product2(Name='Identity', ProductCode='Identity', isActive=true);
        Product2 p7 = new Product2(Name='Passport', ProductCode='Passport', isActive=true);
        Product2 p8 = new Product2(Name='Photo', ProductCode='Photo', isActive=true);
        Product2 p9 = new Product2(Name=IDFORM, ProductCode=IDFORM, isActive=true);
        List<Product2> prdctList = new List<Product2>();
        prdctList.add(p1);
        prdctList.add(p2);
        prdctList.add(p3);
        prdctList.add(p4);
        prdctList.add(p5);
        prdctList.add(p6);
        prdctList.add(p7);
        prdctList.add(p8);
        prdctList.add(p9);
        insert prdctList;
        Asset ap1 = new Asset(Name='EPIC', Product2Id = p1.Id, AccountId = a.Id, ContactId = conId);
        Asset ap2 = new Asset(Name='ECFMG_Certification', Product2Id = p2.Id, AccountId = a.Id, ContactId = conId);
        Asset ap3 = new Asset(Name='GEMx', Product2Id = p3.Id, AccountId = a.Id, ContactId = conId);
        Asset ap4 = new Asset(Name='J1', Product2Id = p4.Id, AccountId = a.Id, ContactId = conId);
        Asset ap5 = new Asset(Name=CRENDENTIALREVIEW, Product2Id = p5.Id, AccountId = a.Id, ContactId = conId);
        Asset ap6 = new Asset(Name='Identity', Product2Id = p6.Id, AccountId = a.Id, ContactId = conId);
        Asset ap7 = new Asset(Name='Passport', Product2Id = p7.Id, AccountId = a.Id, ContactId = conId);
        Asset ap8 = new Asset(Name='Photo', Product2Id = p8.Id, AccountId = a.Id, ContactId = conId);
        Asset ap9 = new Asset(Name=IDFORM, Product2Id = p9.Id, AccountId = a.Id, ContactId = conId);
        List<Asset> asstList = new List<Asset>();
        asstList.add(ap1);
        asstList.add(ap2);
        asstList.add(ap3);
        asstList.add(ap4);
        asstList.add(ap5);
        asstList.add(ap6);
        asstList.add(ap7);
        asstList.add(ap8);
        asstList.add(ap9);
        insert asstList;
        Affirmation__c apaff1 = new Affirmation__c(Asset__c = ap1.Id, Status__c = 'Rejected', Photo_is_Pixelated_Picklist__c = 'Yes');
        Affirmation__c apaff2 = new Affirmation__c(Asset__c = ap2.Id, Status__c = 'Rejected', ID_Document_MRZ_Visible_Picklist__c = 'No');
        Affirmation__c apaff3 = new Affirmation__c(Asset__c = ap3.Id);
        List<Affirmation__c> affrmtnList = new List<Affirmation__c>();
        affrmtnList.add(apaff1);
        affrmtnList.add(apaff2);
        affrmtnList.add(apaff3);
        Case c1 = new Case(contactId = conId, Internal_Status__c = 'Complete', Service__c = 'EPIC', AccountId = a.Id, AssetId = ap1.Id);
        Case c2 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'ECFMG_Certification', AccountId = a.Id, AssetId = ap2.Id);
        Case c3 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'GEMx', AccountId = a.Id, AssetId = ap3.Id);
        Case c4 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'J1', AccountId = a.Id, AssetId = ap4.Id);
        Case c5 = new Case(contactId = conId, Internal_Status__c = 'New', Service__c = 'GEMx', AccountId = a.Id, AssetId = ap5.Id);
        Case c6 = new Case(contactId = conId, Internal_Status__c = 'ID Review', Service__c = 'EPIC', AccountId = a.Id, AssetId = ap6.Id);
        Id identityCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        
        List<Case> cseList = new List<Case>();
        cseList.add(c1);
        cseList.add(c2);
        cseList.add(c3);
        cseList.add(c4);
        cseList.add(c5);
        cseList.add(c6);
        INSERT cseList;
        List<Asset> allAssets = new List<Asset>();
        Asset a1 = new Asset(Name = 'Photo', type__c = 'Photo', Case__c = c6.Id, AccountId = a.id, ContactId = conId, Status = 'Accepted', Product2Id = p8.Id);
        Asset a2 = new Asset(Name = 'Passport', type__c = 'Passport', Case__c = c6.Id, AccountId = a.id, ContactId = conId, Status = 'Accepted', Product2Id = p7.Id);
        Asset a3 = new Asset(Name = IDVER, type__c = IDVER, Case__c = c6.Id, AccountId = a.id, ContactId = conId, Status = INPROGRESS, Product2Id = p9.Id);
        allAssets.add(a1);
        allAssets.add(a2);
        allAssets.add(a3);
        insert allAssets;
        Affirmation__c aff1 = new Affirmation__c(Asset__c = a1.Id, Status__c = 'Rejected', Photo_is_Pixelated_Picklist__c = 'Yes');
        Affirmation__c aff2 = new Affirmation__c(Asset__c = a2.Id, Status__c = 'Rejected', ID_Document_MRZ_Visible_Picklist__c = 'No');
        Affirmation__c aff3 = new Affirmation__c(Asset__c = a3.Id);
        affrmtnList.add(aff1);
        affrmtnList.add(aff2);
        affrmtnList.add(aff3);
        insert affrmtnList;
        
        string cdidphoto = CommunitiesTestFactory.contentdocForContact('Photo', con.Id);
        System.assert(cdidphoto <> null,'content version creation failed');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = ap1.Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd2 = new ContentDocumentLink(LinkedEntityId = ap2.Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd3 = new ContentDocumentLink(LinkedEntityId = ap3.Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd4 = new ContentDocumentLink(LinkedEntityId = ap4.Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd5 = new ContentDocumentLink(LinkedEntityId = ap5.Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        ContentDocumentLink cd6 = new ContentDocumentLink(LinkedEntityId = ap6.Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        List<ContentDocumentLink> cLList = new List<ContentDocumentLink>();
        cLList.add(cdl);
        cLList.add(cd2);
        cLList.add(cd3);
        cLList.add(cd4);
        cLList.add(cd5);
        cLList.add(cd6);
        insert cLList;
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        settings.Applicant_Bio_Change_Cancel_Statuses__c = 'Pending Review|In Review';
        settings.Builder_Test_Contact__c = conId;//'0030U00000PGMbC';
        settings.Builder_Test_Service__c = 'EPIC';
        settings.ID_Form_Product_Code__c = IDFORM;
        settings.ID_Verification_Case_Paid_Status__c = 'Pending ID Review';
        settings.ID_Verification_Case_Queue_Name__c = 'ID Review Queue';
        settings.ID_Verification_Case_Unpaid_Status__c = 'New';
        settings.Passport_Product_Code__c = 'Passport';
        settings.Photo_Product_Code__c = 'Photo';
        settings.Username_Append__c = '.dev';
        upsert settings Community_Settings__c.Id;
        Security_Settings__c secSettings = Security_Settings__c.getOrgDefaults();
        secSettings.Disable_URL_Encryption__c = false;
        secSettings.Encryption_Key__c ='FeThWmEq3t5w9z$C&F)J@NcRfajXn2r4';
        upsert secSettings Security_Settings__c.Id;
        Terms_and_Conditions__c tc1 = new Terms_and_Conditions__c(Name='A', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
        Terms_and_Conditions__c tc2 = new Terms_and_Conditions__c(Name='Certification by Applicant', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
        insert tc1;
        insert tc2;
    }
    @isTest 
    static void runTest(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
            string cdidphoto = CommunitiesTestFactory.contentdocForContact('Photo', U.ContactId);
            string cdidpassport = CommunitiesTestFactory.contentdocForContact('Passport', U.ContactId);
            System.assert(cdidphoto!=null, 'Not found');
            System.assert(cdidpassport!=null, 'Not found');
    }
    @isTest 
    static void communityIdentityVerificationControllerpt1a(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        String recJ1InviteId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_J1_Invitation).getRecordTypeId();
        Case newCase = new Case();
        newCase.ContactId = conId;
        newCase.Internal_Status__c = 'New';
        newCase.Service__c = 'J1';
        newCase.RecordTypeId = recJ1InviteId;
        insert newCase;
        System.runAs(u){
            CommunityIdentityVerificationController.getCaseList('Identity Verification', 'J1');
            CommunityIdentityVerificationController.getLatestCase('J1');
            CommunityIdentityVerificationController.getAllCases();
            CommunityIdentityVerificationController.checkIdentityVerification();
            CommunityIdentityVerificationController.checkIdentityVerification_v2();
            Product2 p = [Select Id FROM Product2 LIMIT 1];
            CommunityIdentityVerificationController.getDisplayLabel(p.Id);
            CommunityIdentityVerificationController.getRunningUserId();
            CommunityIdentityVerificationController.getPrivacyAgreementAccepted();
            CommunityIdentityVerificationController.setPrivacyAgreementAccepted();
            CommunityIdentityVerificationController.checkEPIC();
            CommunityIdentityVerificationController.checkCERT();
            CommunityIdentityVerificationController.checkGEMX();
            CommunityIdentityVerificationController.checkJ1();
            CommunityIdentityVerificationController.makePayment();
            CommunityIdentityVerificationController.paymentMade('J1');
            CommunityIdentityVerificationController.getCaseNumberForPayment('J1');
            Asset a = [Select Id FROM Asset LIMIT 1];
            CommunityIdentityVerificationController.getFiles(a.Id);
            CommunityIdentityVerificationController.getFilesByVersion(a.Id);
            CommunityIdentityVerificationController.getCurrentAssetFiles('J1');
            CommunityIdentityVerificationController.getCurrentAssetFilesVersion('J1');
        }
        System.assert(newCase.Id!=null,'Case not inserted');
    }
    @isTest 
    static void communityIdentityVerificationControllerEpic(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        String idRecId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case newCase = new Case();
        newCase.ContactId = conId;
        newCase.Internal_Status__c = 'New';
        newCase.Service__c = 'EPIC';
        newCase.RecordTypeId = idRecId;
        insert newCase;
        System.runAs(u){
            CommunityIdentityVerificationController.getCaseList('Identity Verification', 'EPIC');
            CommunityIdentityVerificationController.getLatestCase('EPIC');
            CommunityIdentityVerificationController.getAllCases();
            CommunityIdentityVerificationController.checkIdentityVerification();
            CommunityIdentityVerificationController.checkIdentityVerification_v2();
            Product2 p = [Select Id FROM Product2 LIMIT 1];
            CommunityIdentityVerificationController.getDisplayLabel(p.Id);
            CommunityIdentityVerificationController.getRunningUserId();
            CommunityIdentityVerificationController.getPrivacyAgreementAccepted();
            CommunityIdentityVerificationController.setPrivacyAgreementAccepted();
            CommunityIdentityVerificationController.checkEPIC();
            CommunityIdentityVerificationController.checkCERT();
            CommunityIdentityVerificationController.checkGEMX();
            CommunityIdentityVerificationController.checkJ1();
            CommunityIdentityVerificationController.makePayment();
            CommunityIdentityVerificationController.paymentMade('EPIC');
            CommunityIdentityVerificationController.getCaseNumberForPayment('EPIC');
            Asset a = [Select Id FROM Asset LIMIT 1];
            CommunityIdentityVerificationController.getFiles(a.Id);
            CommunityIdentityVerificationController.getFilesByVersion(a.Id);
            CommunityIdentityVerificationController.getCurrentAssetFiles('EPIC');
            CommunityIdentityVerificationController.getCurrentAssetFilesVersion('EPIC');
        }
        System.assert(newCase.Id!=null,'Case not inserted');
    }
    @isTest 
    static void communityIdentityVerificationControllerpt1b(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        System.runAs(u){
            CommunityIdentityVerificationController.getContactWithRecordType();
            CommunityIdentityVerificationController.getContact();
            CommunityIdentityVerificationController.getContactDetailsUpdateCases(false);
            CommunityIdentityVerificationController.getCountries();
            CommunityIdentityVerificationController.getEmployer();
            CommunityIdentityVerificationController.getClerkships();
            CommunityIdentityVerificationController.getTerms('EPIC');
            CommunityIdentityVerificationController.getPrivacyAccepted('A');
            CommunityIdentityVerificationController.addAgreement('A');
            CommunityIdentityVerificationController.addPrivacy('A');
            CommunityIdentityVerificationController.getProgressIndicatorMappings();
            CommunityIdentityVerificationController.deleteEmployer();
            Association__c a1 = CommunityIdentityVerificationController.addClerkship('Anatomy','A', 'US', 'A', 'TN', '37122', 'Nashville', 'Bob', 'June','2010','June','2025');
            CommunityIdentityVerificationController.removeClerkship(a1.Id);
            CommunityIdentityVerificationController.caseRequiresAction('EPIC');
            CommunityIdentityVerificationController.getRunningContactId();
        }
        System.assert(conId!=null,'Contact not found');
    }
    @isTest 
    static void communityIdentityVerificationControllerpt2(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        CommunitiesTestFactory.contentdocForContact('Passport1', conId);
        CommunitiesTestFactory.contentdocForContact('Passport2', conId);
        CommunitiesTestFactory.contentdocForContact('Photo1', conId);
        CommunitiesTestFactory.contentdocForContact('Photo2', conId);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assert(documents[0].id!=null,'no document retrieved');
        CommunityIdentityVerificationController.createCaseAndAssets(documents[0].Id, documents[1].Id, documents[2].Id, documents[3].Id, 'EPIC');
        
    }
    @isTest 
    static void communityIdentityVerificationControllerpt3(){
        CommunityIdentityVerificationController.createCaseAndAssetsV2('EPIC', true);
        String caseRecIdentityVerId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case case1 = [SELECT Id from case where RecordTypeId = : caseRecIdentityVerId and ValidationPassed_Biographics__c = true limit 1 ];
        System.assert(case1.Id!=null,'case not found, method failed');
       
    }
    @isTest 
    static void communityIdentityVerificationControllerpt4(){
        CommunityIdentityVerificationController.createCaseAndAssetsV2('EPIC', false);
        String caseRecIdentityVerId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case case1 = [SELECT Id from case where RecordTypeId = : caseRecIdentityVerId and ValidationPassed_Biographics__c = false limit 1 ];
        System.assert(case1.Id!=null,'case not found, method failed');
    }   
    @isTest 
    static void communityIdentityVerificationControllerpt5(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        CommunitiesTestFactory.contentdocForContact('Passport1', conId);
        CommunitiesTestFactory.contentdocForContact('Passport2', conId);
        CommunitiesTestFactory.contentdocForContact('Photo1', conId);
        CommunitiesTestFactory.contentdocForContact('Photo2', conId);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assert(documents[0].id!=null,'no document retrieved');
        CommunityIdentityVerificationController.resubmitIdentification(documents[0].Id, documents[1].Id, documents[2].Id, documents[3].Id, 'EPIC');
    }
    @isTest 
    static void communityIdentityVerificationControllerpt6(){
        Test.startTest();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        CommunitiesTestFactory.contentdocForContact('Photo', conId);
        CommunitiesTestFactory.contentdocForContact('Passport', conId);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 10];
        List<Case> cL = [SELECT Id FROM CASE limit 5];
        Case c1 = [Select Id FROM Case WHERE Service__c = 'EPIC'][1];
        String recJ1InviteId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_J1_Invitation).getRecordTypeId();
        Case newCase = new Case();
        newCase.ContactId = conId;
        newCase.Internal_Status__c = 'New';
        newCase.Service__c = 'J1';
        newCase.RecordTypeId = recJ1InviteId;
        insert newCase;
        Id assetRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constant_Asset__mdt.getInstance('RECORD_TYPE_VERIFICATION').Value__c);
        Asset ass1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name=Constant_Asset__mdt.getInstance('ASSET_NAME_ID_FORM_NOTARIZED').Value__c, ContactId=conId, Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, Type__c =Constant_Asset__mdt.getInstance('ASSET_TYPE_ID_VERIFICATION').Value__c));
		run();
        CommunityIdentityVerificationController.resubmitNotary(documents[2].Id, 'EPIC', cL[1].Id);
        CommunityIdentityVerificationController.updateAdditionalInfo(RESP, 'English', 'Yes', '1989', 'English', 'Yes, I am currently employed');
        CommunityIdentityVerificationController.updateAdditionalInfoV2(RESP, 'Yes', '1989', 'Yes, I am currently employed.', 'EPIC', true);
        CommunityIdentityVerificationController.updateLanguageInfo('English', 'English', 'Test', 'Test');
        CommunityIdentityVerificationController.getAffirmationResults('EPIC', c1.Id);
        CommunityIdentityVerificationController.getCaseNumberById(cL[0].Id);
        CommunityIdentityVerificationController.getCaseNumberByServiceAndRecordType('ECFMG_Certification','Identity Verification');
        CommunityIdentityVerificationController.createNotaryAsset(documents[1].Id, 'EPIC', cL[0].Id);
        String encrypt = CommunityIdentityVerificationController.encryptURL('param=123&paramB=456');
        String decrypt = CommunityIdentityVerificationController.dencryptURL(encrypt);
        System.assert(decrypt!=null,'decrytpion failed');
        CommunityIdentityVerificationController.closeJ1InviteCase();
        CommunityIdentityVerificationController.updateFile(documents[2].Id, PATH);
        CommunityIdentityVerificationController.getIdVerificationCasePaidStatus();
        CommunityIdentityVerificationController.getNullSafeService('EPIC');
        CommunityIdentityVerificationController.getNullSafeService(null);
        Test.stopTest();
    }
    @isTest 
    static void communityIdentityVerificationControllerpt6b(){
        Test.startTest();
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        System.runAs(u){
            List<Case> cL = [SELECT Id FROM CASE];
            CommunitiesTestFactory.contentdocForContact('Passport1', conId);
            CommunitiesTestFactory.contentdocForContact('Passport2', conId);
            CommunitiesTestFactory.contentdocForContact('Photo1', conId);
            CommunitiesTestFactory.contentdocForContact('Photo2', conId);
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = cL[0].Id,ContentDocumentId = documents[0].Id,ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
            insert cdl;
            CommunityIdentityVerificationController.updateAdditionalInfo(RESP, 'English', 'Yes', '1989', 'English', 'Yes, I am currently employed');
            CommunityIdentityVerificationController.updateAdditionalInfoV2(RESP, 'Yes', '1989', 'Yes, I am currently employed.', 'EPIC', true);
            CommunityIdentityVerificationController.updateLanguageInfo('English', 'English', 'Test', 'Test');
            System.assert(CommunityIdentityVerificationController.getContactId()!=null, 'Assert Success');
            //CommunityIdentityVerificationController.createCaseAndAssets(documents[0].Id, documents[1].Id, documents[2].Id, documents[3].Id, 'EPIC');
            CommunityIdentityVerificationController.createCaseAndAssetsV2('EPIC', true);
            CommunityIdentityVerificationController.removeFile(documents[documents.size()-1].Id);
            Test.stopTest();
        }
    }
    @isTest 
    static void communityIdentityVerificationControllerpt8(){
        CommunityIdentityVerificationController.paymentMade('EPIC');
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        String caseId = null;
        List<Case> cases = [SELECT id FROM Case where contactId =:contactId];
        delete cases;
        Asset ap1 = new Asset(ContactId = contactId, Name = 'Passport', type__c ='Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap2 = new Asset(ContactId = contactId, Name = 'Photo', type__c = 'Photo',Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap3 = new Asset(ContactId = contactId, Name = Constants.ASSET_NAME_PASSPORT_TRANSLATION, type__c ='Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap4 = new Asset(ContactId = contactId, Name = Constants.ASSET_NAME_PASSPORT_EXPIRATION, type__c ='Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap5 = new Asset(ContactId = contactId, Name = IDFORMNOTARIZED, type__c = 'Photo',Status = Constants.ASSET_STATUS_IN_PROGRESS);
        List<Asset> asstList = new List<Asset>();
        asstList.add(ap1);
        asstList.add(ap2);
        asstList.add(ap3);
        asstList.add(ap4);  
        asstList.add(ap5);
        insert asstList;
        CommunityIdentityVerificationController.createCaseAndAssetsV2('EPIC', true);
        CommunityIdentityVerificationController.createPassportPayload(contactId);
        CommunityIdentityVerificationController.createPpExpPayload(contactId);
        CommunityIdentityVerificationController.createPhotoPayload(contactId, caseId);
        CloudStorageController.PayloadWrapper result = CommunityIdentityVerificationController.createPassportTranslationPayload(contactId);
        Test.startTest();
        CommunityIdentityVerificationController.deleteExistingAsset(contactId);       
        CommunityIdentityVerificationController.deleteExistingPassportExpirationAsset(contactId); 
        CommunityIdentityVerificationController.deleteExistingPhotoAsset(contactId, 'Yes');
        CommunityIdentityVerificationController.deleteExistingPhotoAsset(contactId, 'translation');
        CommunityIdentityVerificationController.deleteExistingPhotoAsset(contactId, 'expiration');
        CommunityIdentityVerificationController.deleteExistingPhotoAsset(contactId, '');
        test.stopTest();
        System.assert(result != null,'Payload is not getting generated');
    }
    @isTest 
    static void communityIdentityVerificationControllerpt9(){
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        String cs = null;
        CommunityIdentityVerificationController.createNotarizedPayload(contactId,cs);
        Asset ap11 = new Asset(ContactId = contactId, Name = 'Passport', type__c ='Passport', Status = 'Incomplete');
        Asset ap21 = new Asset(ContactId = contactId, Name = 'Photo', type__c = 'Photo',Status = 'Incomplete');
        Asset ap31 = new Asset(ContactId = contactId, Name = Constants.ASSET_NAME_PASSPORT_TRANSLATION, type__c ='Passport', Status = 'Incomplete');
        Asset ap41 = new Asset(ContactId = contactId, Name = Constants.ASSET_NAME_PASSPORT_EXPIRATION, type__c ='Passport', Status = 'Incomplete');
        Asset ap5 = new Asset(ContactId = contactId, Name = IDFORMNOTARIZED, type__c = 'Photo',Status = Constants.ASSET_STATUS_IN_PROGRESS);
        List<Asset> asstList1 = new List<Asset>();
        asstList1.add(ap11);
        asstList1.add(ap21);
        asstList1.add(ap31);
        asstList1.add(ap41);
        asstList1.add(ap5);
        insert asstList1;
        CommunityIdentityVerificationController.deleteExistingNotarizedAsset(contactId);
        CommunityIdentityVerificationController.createExistPassportPayload(contactId,cs);
        CloudStorageController.PayloadWrapper result = CommunityIdentityVerificationController.createResumbitExistPhotoPayload(contactId, 'EPIC');
        CommunityIdentityVerificationController.passportTranslPayloadExist(contactId,cs);
        CommunityIdentityVerificationController.passportExpirePayloadExist(contactId,cs);
        Case caseObj = new Case(contactId = contactId, Internal_Status__c = 'New', Service__c = 'EPIC');
        insert caseObj;     
        CommunityIdentityVerificationController.createPhotoPayload(contactId, caseObj.Id);
        CommunityIdentityVerificationController.createResumbitPhotoPayload(contactId, caseObj.Id,'EPIC');
        CommunityIdentityVerificationController.getIncompleteAssetNotaryPayload(contactId,cs);
        CommunityIdentityVerificationController.createNotaryPayload(contactId,cs);
        System.assert(result != null,'Payload is not getting generated');
    }
    @isTest 
    static void communityIdTest(){
        cadmus_core__Doc_Config__c cadIns =(cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'ID_FORM_TEMPLATE', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
		run();
        Test.startTest();
        CloudDataTestFactory.createCloudConfig();
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        Case caseObj = new Case(contactId = contactId, Internal_Status__c = 'New', Service__c = 'EPIC');
        insert caseObj;
        Asset asst = new Asset();
        asst.ContactId = contactId;
        asst.Name = Constants.ASSET_NAME_ID_FORM_TEMPLATE;
        asst.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        asst.Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/0035500000x3fkVAAQ_02i55000004k6boAAA.pdf';
        INSERT asst;
        Asset asst1 = new Asset();
        asst1.ContactId = contactId;
        asst1.Case__c = caseObj.Id;
        asst1.Name = Constants.ASSET_NAME_PHOTO;
        asst1.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        insert asst1;
        
        Id bioCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
        Case caseObj2 = new Case(contactId = contactId, Internal_Status__c = 'In Review', Service__c = 'EPIC', RecordTypeId=bioCaseRecType);
        INSERT caseObj2;
        Asset bioAsst = new Asset();
        bioAsst.ContactId = contactId;
        bioAsst.Name = Constants.ASSET_NAME_ID_FORM_TEMPLATE;
        bioAsst.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        bioAsst.Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/0035500000x3fkVAAQ_02i55000004k6boAAA.pdf';
        bioAsst.Case__c = caseObj2.Id;
        INSERT bioAsst;
        
        System.assert(CommunityIdentityVerificationController.getAzureUrl()!='','Assert success');
        CommunityIdentityVerificationController.getMonthPicklistEntries();
        CommunityIdentityVerificationController.getNullSafeService(null);
        CommunityIdentityVerificationController.getIdVerificationCasePaidStatus();
        CommunityIdentityVerificationController.isCaseEligibleForOnlineNotary(caseObj.Id);
    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        CommunityIdentityVerificationController.updateFile(documents[0].Id, PATH);
        Map <String, Object> fieldMap = new Map <String, Object>();
        List <Map <String, Object>> fieldlist = new List <Map <String, Object>>();
        fieldMap.put('Name', 'Test');
        fieldMap.put('Applicant__c', contactId);
        fieldlist.add(fieldMap);
        String fieldJSON = JSON.serialize(fieldlist);
        CommunityIdentityVerificationController.updateEmployer(fieldJSON.replace('[','').replace(']',''));
        fieldMap = new Map <String, Object>();
        fieldlist = new List <Map <String, Object>>();
        fieldMap.put('Id', contactId);
        fieldMap.put('Previous_EPIC_Services__c', 'false');
        fieldMap.put('Applicant_Provided_USMLE_ID__c', 'true');
        fieldMap.put('Applicant_Provided_EPIC_ID__c', 'true');
        fieldMap.put('Passport_Expiration__c', '');
        fieldMap.put('USMLE_ID__c', '12312');
        fieldlist.add(fieldMap);
        fieldJSON = JSON.serialize(fieldlist);
        CommunityIdentityVerificationController.updateContact(contactId, fieldJSON.replace('[','').replace(']',''));
        CommunityIdentityVerificationController.resubmitIdentificationV2('EPIC', false);
        CommunityIdentityVerificationController.resubmitIdentificationV3('EPIC', caseObj.Id);
        Test.stopTest();
    }
    @isTest 
    static void testGetCaseNumID(){
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        String caseRecIdentityVerId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case newCase = new Case();
        newCase.ContactId = contactId;
        newCase.Internal_Status__c = 'New';
        newCase.Service__c = 'EPIC';
        newCase.RecordTypeId = caseRecIdentityVerId;
        insert newCase;
        System.assert(newCase.Id!=null, 'Case doesnot exists');
        CommunityIdentityVerificationController.getCaseNumberIDByServiceAndRecordType('EPIC','Identity_Verification');
        CommunityIdentityVerificationController.getCaseRecordTypeById(newCase.Id);
    }
    @isTest 
    static void runTest1(){
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        String caseRecIdentityVerId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case newCase = new Case();
        newCase.ContactId = contactId;
        newCase.Internal_Status__c = 'New';
        newCase.Service__c = 'EPIC';
        newCase.RecordTypeId = caseRecIdentityVerId;
        insert newCase;
        System.assert(newCase.Id!=null, 'Case doesnot exists');
        Asset ap5 = new Asset(ContactId = contactId, Name = IDFORMNOTARIZED, type__c = IDVER,Status = Constants.ASSET_STATUS_IN_PROGRESS);
        Asset ap31 = new Asset(ContactId = contactId, Name = Constants.ASSET_NAME_PASSPORT_TRANSLATION, type__c ='Passport', Status = INPROGRESS);
        Asset ap41 = new Asset(ContactId = contactId, Name = Constants.ASSET_NAME_PASSPORT_EXPIRATION, type__c ='Passport', Status = INPROGRESS);
        List<Asset> asstList1 = new List<Asset>();
        asstList1.add(ap5);
        asstList1.add(ap31);
        asstList1.add(ap41);
        insert asstList1;
        CommunityIdentityVerificationController.createResubmitPassportPayload(contactId,null,'EPIC');
        CommunityIdentityVerificationController.createResubmitPassportTranslationPayload(contactId,null,'EPIC');
        CommunityIdentityVerificationController.createResubmitPpExpPayload(contactId,null,'EPIC');
        CommunityIdentityVerificationController.resubmitNotaryAsset(null, 'J1', null);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testValidateUSMLEIDSuccess() {
        //Arrange
        //Setup()

        //Act
            Test.startTest();
            Boolean result = CommunityIdentityVerificationController.validatePrevUSMLEID('08444135');
            Test.stopTest();
        
        //Assert
            System.assertNotEquals(false, result,'valid usmleid');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testValidateUSMLEIDFailure() {
        //Arrange
        //Setup()
         Boolean flag = false;

        //Act
            Test.startTest();
            Boolean result = CommunityIdentityVerificationController.validatePrevUSMLEID('0000000');
            Test.stopTest();
        
        //Assert
            System.assertEquals(false, result,'Invalid usmleId');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    public static void testcheckRestrictOnAppIdent(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Contact con = [SELECT Id,ServicesRestricted__c FROM Contact WHERE Id=:conId LIMIT 1];
        con.ServicesRestricted__c = 'Identity Verification - Internal and External';
        UPDATE con;
        User us = [SELECT Id, ContactId FROM User WHERE email = :CommunitiesTestFactory.emailtest AND ContactId = :conId LIMIT 1];
        String error='';
        try{
            System.runAs(us){
                Test.startTest();
                Boolean restrictExist = CommunityIdentityVerificationController.checkRestrictOnAppIdent();
                System.assert(restrictExist==TRUE,'Identity Verification Restriction not applied');
                Test.stopTest();
            }
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    
    @isTest 
    static void testGetEmployer(){
        Id conId = CommunityIdentityVerificationController.getRunningContactId();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Id=:conId LIMIT 1];
        Association__c tstAssocit1  = [SELECT ID,Name,Applicant__c FROM Association__c WHERE Applicant__c=:tstContact.Id ];
        Test.startTest();
        Association__c tstAssocit2 = CommunityIdentityVerificationController.getEmployer();
        System.assertEquals(tstAssocit1.Id, tstAssocit2.Id, 'Successfully retrieved employer');
        Test.stopTest();
    }
}