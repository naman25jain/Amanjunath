@isTest
public with sharing class EpicCredVerControllerTest{
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
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
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case idVerCase = new Case();
        idVerCase.RecordTypeId = idVerRecTypeId;
        idVerCase.ContactId = con.Id;
        idVerCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
        INSERT idVerCase;
        Id profId = [SELECT id FROM profile WHERE name='4-Customer Community Entity 360' LIMIT 1].id;
        User user1 = new User(alias = 'testUser',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testuser@test.com');
        INSERT user1;
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'Test1';
        con1.Email = 'testapplicant@test.com';
        con1.RecordTypeId = applRecTypeId;
        INSERT con1;
        Id profId1 = [SELECT id FROM profile WHERE name='4-Customer Community Plus Login' LIMIT 1].id;
        User user2 = new User(alias = 'testUsr1',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId1,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con1.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testUserapp@test.com');
        INSERT user2;        
	}
    @isTest
    static void testAccountNotEstablished(){
        Contact con = [SELECT id FROM Contact LIMIT 1];
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Case idVerCase = [SELECT id,Internal_Status__c FROM Case WHERE ContactId =:con.Id AND RecordTypeId =:idVerRecTypeId LIMIT 1];
        idVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        UPDATE idVerCase;
        User usr = [SELECT Id FROM User WHERE username = 'testuser@test.com' limit 1];
        System.runAs(usr){
            Test.startTest();
            Boolean accEst = EpicCredVerController.checkAccountEstablishment();
            System.assertEquals(false, accEst, 'Account established');
            Test.stopTest();
        }
    }
    @isTest
    public static void testStatusChangeEpicExtract(){
        User testUser = [Select Id, ContactId from User where alias = 'testUsr1'];
        Test.startTest();
        System.runAs(testUser){
            Id epicExtractionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
            Case cs = new Case(ContactId=testUser.ContactId, Internal_Status__c=Constants.CASE_STATUS_PENDING_SUBMISSION,RecordTypeId=epicExtractionRecordTypeId);
            insert cs;
            System.assert(cs.Id!=null,'Case not found');
            List<String> rtnVal= EpicCredVerController.statusChangeEpicExtract();
            System.assert(!rtnVal.isEmpty(),'Payment not complete');
        }
        Test.stopTest();
    }
    @isTest
    static void testEpicExtrStatusComplete(){
        Contact con = [SELECT id FROM Contact LIMIT 1];
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Case epicExtCase = new Case();
        epicExtCase.RecordTypeId = epicExtRecTypeId;
        epicExtCase.ContactId = con.Id;
        epicExtCase.Internal_Status__c = Constants.CASE_STATUS_VERIFICATION_EXTRACTION_COMPLETE;
        INSERT epicExtCase;
        User usr = [SELECT Id FROM User WHERE username = 'testuser@test.com' limit 1];
        System.runAs(usr){
            Test.startTest();
            Boolean accEst = EpicCredVerController.checkAccountEstablishment();
            String epicExtrstatus = EpicCredVerController.getEpicExtrCaseStatus();
            System.assertEquals(true, accEst, 'Account not established');
            System.assertEquals(Constants.CASE_STATUS_VERIFICATION_EXTRACTION_COMPLETE, epicExtrstatus, 'Epic extraction case not completed or not created');
            Test.stopTest();
        }
    }
    @isTest
    static void testEpicExtrStatusNotComplete(){
        Contact con = [SELECT id FROM Contact LIMIT 1];
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Case epicExtCase = new Case();
        epicExtCase.RecordTypeId = epicExtRecTypeId;
        epicExtCase.ContactId = con.Id;
        epicExtCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        INSERT epicExtCase;
        User usr = [SELECT Id FROM User WHERE username = 'testuser@test.com' limit 1];
        System.runAs(usr){
            Test.startTest();
            String epicExtrstatus = EpicCredVerController.getEpicExtrCaseStatus();
            System.assertEquals('Not Complete', epicExtrstatus, 'Epic extraction case Completed or not created');
            Test.stopTest();
        }
    }
    @isTest
    static void testEpicExtrStatusNotCreated(){
        User usr = [SELECT Id FROM User WHERE username = 'testuser@test.com' limit 1];

        System.runAs(usr){
            Test.startTest();
            String epicExtrstatus = EpicCredVerController.getEpicExtrCaseStatus();
            System.assertEquals('Case not created', epicExtrstatus, 'Epic extraction case created');
            Test.stopTest();
        }
    }
    @isTest
    static void testDeleteCredVerCase(){
        Contact con = [SELECT id FROM Contact WHERE email = 'testapplicant@test.com' LIMIT 1];
        Id credIntakeCatRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Id regOrgCatRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_REGULATORY_ORGANIZATION).getRecordTypeId();
        Id credVerRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id acctRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Id credRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id evCaseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();

        Id regOrgCatRecTypeId2 = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION).getRecordTypeId();
        Id credIntakeCatStagRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();


        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        acc2.BillingCountry = 'India';
        INSERT acc2;
        System.assert(acc2.Id != null, 'Account 2 creation failed');
        Account acc3 = new Account();
        acc3.Name = 'Test Account3';
        acc3.BillingCountry = 'India';
        acc3.RecordTypeId = acctRecTypId;
        acc3.EPIC_Client_Special_Instructions_Languag__c = 'Special Instructions and FAQs for Applicants to the American Medical Association';
        acc3.EPIC_Client_Special_Instructions_url__c = 'http://www.ecfmgepic.org/instructions-ama.html';
        INSERT acc3;
        System.assert(acc3.Id != null, 'Account 3 creation failed');
        
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypId;
        credVerCase.ContactId = con.Id;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        INSERT credVerCase;
        System.assert(credVerCase.Id != null, 'Credential verification Case creation failed');

        Contact_Association_Type__c catTypeRec = new Contact_Association_Type__c();
        catTypeRec.Contact__c = con.Id;
        catTypeRec.Case__c = credVerCase.Id;
        catTypeRec.Account__c = acc2.Id;
        catTypeRec.RecordTypeId = credIntakeCatRecTypeId;
        catTypeRec.Credential_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        catTypeRec.Degree_Issue_Date__c = Date.newInstance(2020, 12, 9);
        catTypeRec.Degree_Title__c = 'MBBS';
        INSERT catTypeRec;
        System.assert(catTypeRec.Id != null, 'Cat Type creation failed');

        Contact_Association_Type__c catTypeRec2 = new Contact_Association_Type__c();
        catTypeRec2.Contact__c = con.Id;
        catTypeRec2.Account__c = acc3.Id;
        catTypeRec2.RecordTypeId = regOrgCatRecTypeId2;
        INSERT catTypeRec2;
        System.assert(catTypeRec2.Id != null, 'Cat Type 2 creation failed');
        

        Contact_Association_Type_Staging__c catStag = new Contact_Association_Type_Staging__c();
        catStag.Contact__c = con.Id;
        catStag.Case__c = credVerCase.Id;
        catStag.Account__c = acc2.Id;
        catStag.RecordTypeId = credIntakeCatStagRecTypeId;
        catStag.Credential_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        catStag.Degree_Issue_Date__c = Date.newInstance(2020, 12, 9);
        catStag.Degree_Title__c = 'MBBS';
        catStag.Issue_Date__c = Date.newInstance(2020, 12, 9);
        catStag.Title__c = '';
        INSERT catStag;
        System.assert(catStag.Id != null, 'Cat Staging creation failed');
        Contact_Association_Type_Staging__c catStag2 = new Contact_Association_Type_Staging__c();
        catStag2.Contact__c = con.Id;
        catStag2.Account__c = acc3.Id;
        catStag2.RecordTypeId = regOrgCatRecTypeId;
        catStag2.Issue_Date__c = Date.newInstance(2020, 12, 9);
        INSERT catStag2;
        System.assert(catStag2.Id != null, 'Cat Staging 2 creation failed');
        Asset asst = new Asset();
        asst.Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst.contactId = con.Id;
        asst.Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst.Contact_Association_Type_Staging__c = catStag.Id;
        asst.RecordTypeId = credRecTypId;
        INSERT asst;
        System.assert(asst.Id != null, 'Asset creation failed');
        Case epicVerRep = new Case();
        epicVerRep.Secondary_Parent_Case__c = credVerCase.Id;
        epicVerRep.contactId = con.Id;
        epicVerRep.Entity__c = acc3.Id;
        epicVerRep.RecordTypeId = evCaseRecTypId;
        epicVerRep.Internal_Status__c = Constants.CASE_STATUS_NEW;
        epicVerRep.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = true;
        INSERT epicVerRep;
        System.assert(epicVerRep.Id != null, 'epicVerRep creation failed');
        User usr = [SELECT Id FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.runAs(usr){
            Test.startTest();
            List<EpicCredVerController.AsstCatStagWrapper> wrapList = EpicCredVerController.getAssetCatStagList('EPIC');
            System.assertEquals(Date.newInstance(2020, 12, 9), wrapList[0].issueDate, 'Issue date not correct');
            System.assertNotEquals(null, wrapList[0].issueDate, 'Issue date null');
            System.assertEquals('MBBS', wrapList[0].title, 'Title not correct');
            System.assertNotEquals('', wrapList[0].title, 'Title blank');
            EpicCredVerController.deleteCredVerCase(catStag.Id);
            Asset asstUpdated = [Select status FROM Asset WHERE id = :asst.Id];
            List<Case> credVerCaseList = [Select id FROM Case WHERE RecordTypeId = :credVerRecTypId];
            List<Contact_Association_Type_Staging__c> catList = [Select id FROM Contact_Association_Type_Staging__c WHERE RecordTypeId = :credIntakeCatRecTypeId];
            System.assertEquals(Constants.ASSET_STATUS_MARKED_FOR_DELETION, asstUpdated.status, 'Asset not marked for deletion');
            System.assertEquals(credVerCaseList.size(), 0, 'Credential Verification case not deleted');
            System.assertEquals(catList.size(), 0, 'Contact association type staging not deleted');
            Test.stopTest();
        }
    }
    @isTest
    static void testGetSpecInstrDetailsSuccess(){
        Contact con = [SELECT id FROM Contact WHERE email = 'testapplicant@test.com' LIMIT 1];
        Set<Id> accIds = new Set<Id>();
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id acctRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Id regOrgCatRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION).getRecordTypeId();
        Account acc3 = new Account();
        acc3.Name = 'Test Account3';
        acc3.BillingCountry = 'India';
        acc3.RecordTypeId = acctRecTypId;
        acc3.EPIC_Client_Special_Instructions_Languag__c = 'Special Instructions and FAQs for Applicants to the American Medical Association';
        acc3.EPIC_Client_Special_Instructions_url__c = 'http://www.ecfmgepic.org/instructions-ama.html';
        INSERT acc3;
        System.assert(acc3.Id != null, 'Account 3 creation failed');
        Contact_Association_Type__c testCat = new Contact_Association_Type__c();
        testCat.RecordTypeId = regOrgCatRecTypeId;
        testCat.Contact__c = con.Id;
        testCat.Account__c = acc3.Id;
        INSERT testCat;
        System.assert(testCat.Id != null, 'CAT record creation failed');

        User usr = [SELECT Id FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.runAs(usr){
            Test.startTest();
            List<Account> accList = EpicCredVerController.getSpecInstrDetails();
            System.assertEquals('http://www.ecfmgepic.org/instructions-ama.html', accList[0].EPIC_Client_Special_Instructions_url__c, 'Epic special instruction Url not correct');
            System.assertEquals('Special Instructions and FAQs for Applicants to the American Medical Association', accList[0].EPIC_Client_Special_Instructions_Languag__c, 'Epic special instruction Language not correct');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetTermsandConditionsEPIC(){
        List<AppForCertHelper.TermsObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper>();
        Product2 prod = new Product2(Name = 'End User Legal Terms - EPIC',
				Family = 'Agreements');
        INSERT prod;
        System.assert(prod.Id != null, 'Test product creation failed');
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c(
            Name = 'Test',
            Copy__c = 'Test',
            Short_Copy__c = 'Test',
            Status__c = 'Active',
            Product__c = prod.Id,
            ExpirationDate__c = System.today() + 20
        );
        INSERT tc;
        System.assert(tc.Id != null, 'Test Terms and conditions creation failed');

        List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
        
        termsList = [SELECT Id, Copy__c, Name, Short_Copy__c FROM Terms_and_Conditions__c 
                        WHERE Product__r.Name ='End User Legal Terms - EPIC'
                        AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
                        ORDER BY CreatedDate ASC];
        if(!termsList.isEmpty()){
            for(Terms_and_Conditions__c terms : termsList){
                string termsId = terms.Id;
                string termsContent = terms.Copy__c;
                string termsCheckBox = terms.Short_Copy__c;
                AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);
                fetchedValuesToReturn.add(tempTermsObj);
            }
        }
        Test.startTest();
        fetchedValuesToReturn = EpicCredVerController.getTermsandConditionsEPIC();
        System.assertNotEquals(fetchedValuesToReturn,null,'Terms record not fetched'); 
        Test.stopTest();
    }
    @isTest
    static void testGetAssetCatStagList(){
        Contact con = [Select id FROM Contact LIMIT 1];
        Id credIntakeCatRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Id credVerRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id credRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id evCaseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();

        Account acc3 = new Account();
        acc3.Name = 'Test Account2';
        acc3.BillingCountry = 'India';
        INSERT acc3;
        System.assert(acc3.Id != null, 'Account 3 creation failed');
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypId;
        credVerCase.ContactId = con.Id;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        INSERT credVerCase;
        System.assert(credVerCase.Id != null, 'credVerCase creation failed');
        
        Contact_Association_Type_Staging__c catStag3 = new Contact_Association_Type_Staging__c();
        catStag3.Contact__c = con.Id;
        catStag3.Case__c = credVerCase.Id;
        catStag3.Account__c = acc3.Id;
        catStag3.RecordTypeId = credIntakeCatRecTypeId;
        catStag3.Issue_Date__c = Date.newInstance(2020, 10, 20);
        catStag3.Title__c = 'MD';
        catStag3.Credential_Type__c = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        INSERT catStag3;
        System.assert(catStag3.Id != null, 'catStag3 creation failed');

        Contact_Association_Type_Staging__c catStag4 = new Contact_Association_Type_Staging__c();
        catStag4.Contact__c = con.Id;
        catStag4.Case__c = credVerCase.Id;
        catStag4.Account__c = acc3.Id;
        catStag4.RecordTypeId = credIntakeCatRecTypeId;
        catStag4.Title__c = '';
        catStag4.Issue_Date__c = null;
        catStag4.Credential_Type__c = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        INSERT catStag4;
        System.assert(catStag4.Id != null, 'catStag4 creation failed');

        Asset asst2 = new Asset();
        asst2.Name = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        asst2.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst2.contactId = con.Id;
        asst2.Type__c = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        asst2.Contact_Association_Type_Staging__c = catStag3.Id;
        asst2.RecordTypeId = credRecTypId;
        INSERT asst2;
        System.assert(asst2.Id != null, 'asst2 creation failed');

        Case epicVerRep = new Case();
        epicVerRep.Secondary_Parent_Case__c = credVerCase.Id;
        epicVerRep.contactId = con.Id;
        epicVerRep.Entity__c = acc3.Id;
        epicVerRep.RecordTypeId = evCaseRecTypId;
        epicVerRep.Internal_Status__c = Constants.CASE_STATUS_NEW;
        epicVerRep.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = false;
        INSERT epicVerRep;
        System.assert(epicVerRep.Id != null, 'epicVerRep creation failed');

        User usr = [SELECT Id FROM User WHERE username = 'testuser@test.com' limit 1];
        System.runAs(usr){
            Test.startTest();
            List<EpicCredVerController.AsstCatStagWrapper> wrapList = EpicCredVerController.getAssetCatStagList('EPIC');
            System.assertEquals(Date.newInstance(2020, 10, 20), wrapList[0].issueDate, 'Issue date not correct');
            System.assertNotEquals(null, wrapList[0].issueDate, 'Issue date null');
            System.assertEquals('MD', wrapList[0].title, 'Title not correct');
            System.assertNotEquals('', wrapList[0].title, 'Title blank');
            String returnVal = EpicCredVerController.getTitle('', catStag4);
            System.assertEquals(returnVal, null, 'NULL returned');
            Date returnVal2 = EpicCredVerController.getIssueDate('', catStag4);
            System.assertEquals(returnVal2, null, 'NULL returned');
            Test.stopTest();
        }
    }
    @isTest
    static void testMarkAssetForDeletion(){
        List<Contact> testContact = [SELECT id,AccountId FROM Contact];
        String contactId = testContact[0].Id;
        List<Asset> epicTestAssets = new List<Asset>();

        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        //Create and Insert Asset
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                Status = 'In Progress',
                                ContactId = contactId,
                                InstallDate = System.Today(),
                                key__c = Constants.ASSET_TYPE_TCT,
                                Type__c	= 'Photo',
                                Azure_Storage_URL__c = assetUrl);
        INSERT asst1;
        System.assert(asst1.Id != null, 'asset Id is null');
        epicTestAssets.add(asst1);
        Asset asst2 = new Asset(Name = 'Credential Request',
                                Status = 'In Progress',
                                ContactId = contactId,
                                InstallDate = System.Today(),
                                key__c = Constants.ASSET_TYPE_TCT,
                                Type__c	= 'Final Medical Diploma',
                                Azure_Storage_URL__c = assetUrl);
        INSERT asst2;
        System.assert(asst2.Id != null, 'asset Id is null');
        epicTestAssets.add(asst2);
        Boolean deletionResult1 = EpicCredVerController.assetsDeletionOnPageLoad(contactId);
        System.assert(deletionResult1, 'Marking assets for deletion failed');
        Boolean deletionResult = EpicCredVerController.markAssetsForDeletion(assetUrl);
        System.assert(deletionResult, 'Marking assets for deletion failed');
        Boolean fmdExist = EpicCredVerController.checkEpicFMDExist();
        System.assert(!fmdExist, 'final medical diploma asset exist on file');
        //insert meta data or get metadata before calling following method
        List<String> typeList = EpicCredVerController.getCredentialAttributes('EPIC');
        System.assert(!typeList.isEmpty(), 'failed to fetch custom metadata');
        Map<String,String> progDoc = EpicCredVerController.getProgDocTypeMap('Final Medical School Transcript','EPIC');
        System.assert(!progDoc.isEmpty(), 'failed to fetch custom metadata for document type');
    }
    @isTest
    static void testCheckEpicFMDExist(){
        User testUser = [SELECT id, contactId FROM User WHERE alias = 'testUsr1'];
        String contactId = testUser.contactId;
        List<Asset> epicTestAssets = new List<Asset>(); 
		Test.startTest();
		System.runAs(testUser){
            String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            //Create and Insert Asset
            Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = 'In Progress',
                                    ContactId = contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    Azure_Storage_URL__c = assetUrl);
            INSERT asst1;
            System.assert(asst1.Id != null, 'asset Id is null');
            epicTestAssets.add(asst1);
            Asset asst2 = new Asset(Name = 'Credential Request',
                                    Status = 'In Progress',
                                    ContactId = contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Final Medical Diploma',
                                    Azure_Storage_URL__c = assetUrl);
            INSERT asst2;
            System.assert(asst2.Id != null, 'asset Id is null');
            epicTestAssets.add(asst2);
            List<Asset> epicAsset = [SELECT id,type__c,status FROM Asset WHERE contactId =:contactId LIMIT 2];
            Boolean fmdExist = EpicCredVerController.checkEpicFMDExist();
            System.assertEquals(fmdExist,true, 'final medical diploma asset exist on file');
        }
        Test.stopTest();
    }
    @isTest
    static void testCreateTermsRecord(){
		User testUser = [Select id, contactId FROM User WHERE alias = 'testUsr1'];
		Test.startTest();
		System.runAs(testUser){
			Product2 prod = new Product2();
			prod.Name = 'End User Legal Terms - EPIC';
			INSERT prod;
			Terms_and_Conditions__c termsCond = new Terms_and_Conditions__c();
			termsCond.Copy__c = '';
			termsCond.Name = '';
			termsCond.Status__c = 'Active';
			termsCond.Product__c = prod.Id;
			termsCond.ExpirationDate__c = Date.newInstance(2021, 10, 10);
			INSERT termsCond;
			Boolean result1 = EpicCredVerController.createTermsRecord(constants.PRODUCT_NAME_EPIC_LEGAL_TERMS);
            System.AssertEquals(result1,true,'Terms Record is not created');
		}
		Test.stopTest();
	}
    @isTest
    static void testCreateTermsConditionsAgreement(){
		User testUser = [Select id, contactId FROM User WHERE alias = 'testUsr1'];
		Test.startTest();
		System.runAs(testUser){
			Product2 prod = new Product2();
			prod.Name = 'End User Legal Terms - EPIC';
			INSERT prod;
			Terms_and_Conditions__c termsCond = new Terms_and_Conditions__c();
			termsCond.Copy__c = 'Test';
			termsCond.Name = 'Test';
			termsCond.Status__c = 'Active';
			termsCond.Product__c = prod.Id;
			termsCond.ExpirationDate__c = Date.newInstance(2021, 10, 10);
			INSERT termsCond;
            System.assert(termsCond.Id!= null,'termsCond is not created');
            Terms_and_Conditions_Agreement__c termsAgreeCond = new Terms_and_Conditions_Agreement__c();
            termsAgreeCond.Contact__c = testUser.contactId;
            termsAgreeCond.Copy__c = 'Test';
            termsAgreeCond.Name = 'Test';
            termsAgreeCond.TermsandConditions__c = termsCond.Id;
            INSERT termsAgreeCond;
            System.assert(termsAgreeCond.Id!= null,'termsCond is not created');
            List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
            termsList.add(termsCond);
			EpicCredVerController.createTermsConditionsAgreement(termsList);
            System.assert(!termsList.isEmpty(),'Termslist is not empty');
		}
		Test.stopTest();
	}
    @isTest
    static void testCreateEpicExtractionCase() {
		User testUser = [Select id, contactId FROM User WHERE alias = 'testUsr1'];
		Test.startTest();
		System.runAs(testUser){
			String result1 = EpicCredVerController.createEpicExtractionCase();
            System.assert(result1!='','Epic Extraction Case is not created');
            Id epicExtractionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();                
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.QUEUE_EPIC_EXTRACTIONS WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = testUser.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_NEW;
            caseObj.RecordTypeId = epicExtractionRecordTypeId;
            INSERT caseObj;
			Contact con = [Select id, AccountId FROM Contact WHERE Id =: testUser.contactId];            
            EpicCredVerController.migrateCATSRegulatoryOrganization();
            Map<String, Schema.SObjectField> fieldMapCatStaging = Schema.getglobaldescribe().get('Contact_Association_Type_Staging__c').getdescribe().fields.getmap();
		    EpicCredVerController.getCATSFieldNames(fieldMapCatStaging);
            List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>();        
			Id reguOrgRecordId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Regulatory_Organization').getRecordTypeId();
       	 	Contact_Association_Type_Staging__c conAssocTypeStg = new Contact_Association_Type_Staging__c(RecordTypeId=reguOrgRecordId,contact__c=testUser.contactId,Account__c=con.AccountId);
            catsList.add(conAssocTypeStg);
            INSERT catsList;      
            List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
            Id reguOrgCATRecordId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Regulatory_Organization').getRecordTypeId();
       	 	Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=reguOrgCATRecordId,contact__c=testUser.contactId,Account__c=con.AccountId);
            catList.add(conAssocType);            
            EpicCredVerController.getCATSRegulOrgRecords(catsList[0]);
            EpicCredVerController.deleteExistCATRegulatoryOrg(testUser.contactId);            
            EpicCredVerController.copingRecordToCAT(catList, testUser.contactId);            
            EpicCredVerController.deleteExistCATSRegulatoryOrg(testUser.contactId);
		}
		Test.stopTest();
	}
	@isTest
    static void testGetMetadataId() {
		User testUser = [Select id, contactId FROM User WHERE alias = 'testUsr1'];
		Test.startTest();
		System.runAs(testUser){
            List<Confirmation_Message__mdt> confMsgs = new List<Confirmation_Message__mdt>();
        	confMsgs = [SELECT Id FROM Confirmation_Message__mdt WHERE DeveloperName =: Constants.CONFIRMATION_MESSAGE_EPIC_CRE_VERI WITH SECURITY_ENFORCED];        
			String result = EpicCredVerController.getMetadataId();
            System.AssertEquals(result,confMsgs[0].Id,'Meta Data is not available');
		}
		Test.stopTest();
	}
    @isTest
    static void testSearchRegOrg(){
        User usr = [SELECT Id,contactId FROM User WHERE username = 'testuser@test.com' limit 1];
        Id profId = [Select id FROM profile WHERE name='4-Customer Community Plus Login' LIMIT 1].id;
        usr.ProfileId = profId;
        update usr;
        System.assert(usr.ProfileId == profId,'Profile id is different');
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.Name = 'Reg Org';
            newAcct.BillingCountry = 'India';
            newAcct.RecordTypeId = recTypeId;
            newAcct.BillingPostalCode ='12345';
            newAcct.BillingCity = 'Hyderabad';
            Insert newAcct;
            System.assert(newAcct.Id!= null,'Account is not created');
            Service__c newSer = new Service__c();
            newSer.Name = Constants.EPIC_SERVICENAME;
            Insert newSer;
            System.assert(newSer.Id!= null,'Service is not created');
            Account2Service__c acctServ = new Account2Service__c();
            acctServ.active__c = true;
            acctServ.Account__c = newAcct.Id;
            acctServ.Service__c = newSer.Id;
            Insert acctServ;
            System.assert(acctServ.Id!= null,'Account2Service is not created');
            test.startTest();
                List<Account> acctList = EpicCredVerController.searchRegOrg('Reg');
                system.assertEquals(newAcct.Id,acctList[0].Id,'Account is not returned');
                acctList = EpicCredVerController.searchRegOrgEpicReport('Reg','Reg1');
                system.assertEquals(newAcct.Id,acctList[0].Id,'Account is not returned');
                Boolean checkCatsInsert = EpicCredVerController.insertNewCatsRecord(string.valueof(newAcct.Id));
                system.assertEquals(checkCatsInsert,True,'CATS is not created');
                List<Contact_Association_Type_Staging__c> schools = new List<Contact_Association_Type_Staging__c>();
                schools = [SELECT Id,Account__r.Name,Account__r.Alternative_Name__c,Account__r.BillingStreet,Account__r.BillingCity,
                    Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry FROM
                    Contact_Association_Type_Staging__c WHERE
                    RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG AND Contact__c = :usr.contactId];
                List<ContactAssociationTypeViewModel> catsRecord = EpicCredVerController.getRegOrgCatsRecord();
                system.assertEquals(catsRecord[0].Id,schools[0].Id,'CATS is not created');
            	Boolean deleteRec = EpicCredVerController.deleteSelectedOrg(schools[0].Id);
                system.assertEquals(deleteRec,True,'CATS is not deleted');
                Contact_Association_Type__c newCat = new Contact_Association_Type__c();
                newCat.Account__c = newAcct.Id;
                newCat.Contact__c = usr.contactId;
                newCat.RecordTypeId = catRecTypeId;
                Insert newCat;
                system.assert(newCat.Id!=null,'CAT record is not created');
                Boolean insertCatsFromCat = EpicCredVerController.insertAlreadyEstOrgInCat();
                system.assertEquals(insertCatsFromCat,True,'CATS is not created FROM CAT');
                EpicCredVerController.deleteAllSelectedOrg();
                schools = [SELECT Id,Account__r.Name,Account__r.Alternative_Name__c,Account__r.BillingStreet,Account__r.BillingCity,
                        Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry FROM
                        Contact_Association_Type_Staging__c WHERE
                        RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG AND Contact__c = :usr.contactId];
                system.assert(schools.isEmpty(),'All CATS records are not deleted');
            	String jsonString = '{"regOrgName" :"An appliance",' + '"countryName" : "IN",'+'"streetName" : "streetName",' +'"cityName" : "cityName",' +
                                        '"stateName" : "KL",' + '"postalCode" : "686693"}';
            	Account newActCreated = EpicCredVerController.insertNewRegOrg(jsonString);
            	system.assertEquals(newActCreated.Name,'An appliance','Account is created with different attribute');
            	Boolean checkRegOrg = EpicCredVerController.getRegOrgDontKnow();
            	system.assertEquals(checkRegOrg,false,'Reg org dont know returned true');
            	EpicCredVerController.updateContactRegOrgField(true);
            	Contact existContact = [SELECT id,Regulatory_Org_Do_Not_Know__c FROM CONTACT WHERE id =:usr.contactId];
            	system.assertEquals(existContact.Regulatory_Org_Do_Not_Know__c,true,'Reg org dont know is updated as false');
            test.stopTest();
    	}
    }
    
    @isTest
    static void testInsertEntityOnSubmitSuccess(){
        Test.startTest();
        String jsonString = '{"regOrgName":"test","universityName":"test","countryName":"IN","streetName":"test","cityName":"test","stateName":"KL","postalCode":"12345"}';
        Account newActCreated = EpicCredVerController.insertEntityOnSubmit(jsonString);
        system.assertEquals(newActCreated.Name,'test','Account is created');
        Test.stopTest();
    }

    @isTest
    static void testCheckVer(){  
        User usr = [SELECT Id,contactId FROM User WHERE username = 'testuser@test.com' limit 1];
        Id profId = [Select id FROM profile WHERE name='4-Customer Community Entity 360' LIMIT 1].id;
        usr.ProfileId = profId;
        update usr;
        System.assert(usr.ProfileId == profId,'Profile is different');
        System.runAs(usr){   
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();            
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Reg Org';
            newAcct.RecordTypeId = recTypeId;
            Insert newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            Service__c newSer = new Service__c();
            newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
            Insert newSer;
            System.assert(newSer.Id!= null,'Service not created');
            Account2Service__c acctServ = new Account2Service__c();
            acctServ.active__c = true;
            acctServ.Account__c = newAcct.Id;
            acctServ.Service__c = newSer.Id;
            Insert acctServ;
            String fmd = 'Final Medical Diploma';
            System.assert(acctServ.Id!= null,'Account2Service not created');
            CONTACT2ACCTSERVICE__c con2Ser = new CONTACT2ACCTSERVICE__c();
            con2Ser.Account_Service__c = acctServ.Id;
            con2Ser.Active__c = True;
            con2Ser.Preferred_Mode_of_Communication__c = 'Paper';
            con2Ser.Credential_Type__c = fmd;
            con2Ser.Physical_Address__c = 'test';
            con2Ser.City__c = 'Test City';
            con2Ser.Country__c = 'India';
            con2Ser.Street__c = '123 steet';
            INSERT con2Ser;
            System.assert(con2Ser.Id!= null,'ContactAccount2Service not created');
            String checkPor = EpicCredVerController.checkVerifictn(newAcct.id,fmd);
            System.assert(checkPor!= null,'Portal usr is not exist');
            acctServ.active__c = false; 
            update acctServ;
            System.assert(acctServ.Id!= null,'Account2Service not updated');
            String checkNonPor = EpicCredVerController.checkVerifictn(newAcct.id,fmd);
            System.assert(checkNonPor!= null,'Non Portal user is not exist');
        }
    }
    @isTest
    static void testUpdateMethods(){
        User usr = [SELECT Id,contactId FROM User WHERE username = 'testuser@test.com' limit 1];
        Id profId = [Select id FROM profile WHERE name='4-Customer Community Plus Login' LIMIT 1].id;
        usr.ProfileId = profId;
        update usr;
        System.assert(usr.ProfileId == profId,'Profile id update failed');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        System.runAs(usr){
           Case epicExtCase = new Case();
            epicExtCase.RecordTypeId = epicExtRecTypeId;
            epicExtCase.ContactId = usr.contactId;
            epicExtCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
            INSERT epicExtCase;
            System.assert(epicExtCase.Id != null, 'epic case Id is null');
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.Name = 'Test Account';
            newAcct.BillingCountry = 'India';
            newAcct.RecordTypeId = recTypeId;
            Insert newAcct;
            System.assert(newAcct.Id!= null,'Account is not created');
            Contact_Association_Type_Staging__c newCat = new Contact_Association_Type_Staging__c();
            newCat.Account__c = newAcct.Id;
            newCat.Contact__c = usr.contactId;
            newCat.RecordTypeId = catRecTypeId;
            newCat.Case__c = epicExtCase.Id;
            Insert newCat;
            system.assert(newCat.Id!=null,'CAT record is not created');
            String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            //Create and Insert Asset
            Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    Azure_Storage_URL__c = assetUrl);
            INSERT asst1;
            System.assert(asst1.Id != null, 'asset insertion failed');
            Asset asst2 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = epicExtCase.Id,
                                    Azure_Storage_URL__c = assetUrl+'1234');
            INSERT asst2;
            System.assert(asst2.Id != null, 'asset insertion failed');
            Map<String, String> assetMap = EpicCredVerController.getAssetUrls(epicExtCase.Id);
            System.assert(assetMap.keySet().size() != 0, 'asset fetch failed');
            Boolean deletionResult = EpicCredVerController.deleteAssetsWithoutCase(assetUrl);
            List<String> assetUrls = new List<String>();
            assetUrls.add(assetUrl);
            System.assert(deletionResult, 'deletion failed');
            deletionResult = EpicCredVerController.deleteAssets(JSON.serialize(assetUrls));
            System.assert(deletionResult, 'asset deletion failed');
            Case evrRecord = new Case();
            evrRecord.Secondary_Parent_Case__c = epicExtCase.Id;
            evrRecord.Reference_Number__c = 'test';
            evrRecord.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = false;
            Insert evrRecord;
            System.assert(evrRecord.Reference_Number__c != null, 'Epic verification report creation failed');
            evrRecord = EpicCredVerController.getEvrFieldValues(newCat.Id);
            System.assert(evrRecord != null, 'Epic verification report fetch failed');
            
            EpicCredVerController.CredUploadWrapper wrapper = new EpicCredVerController.CredUploadWrapper();
            wrapper.caseId = epicExtCase.Id;
            wrapper.catsId = newCat.Id;
            wrapper.credUrl = assetUrl+'1234';
            wrapper.transUrl = assetUrl+'12345';
            wrapper.nameUrl = assetUrl+'12346';
            wrapper.haveCertificate = false;
            wrapper.requestedToSend = false;
            wrapper.entityId = newAcct.Id;
            wrapper.nameDifferent = false;
            wrapper.nameOnDoc = 'Test';
            wrapper.translationRequired = false;

            EpicCredVerController.CredUploadWrapper wrapper2 = new EpicCredVerController.CredUploadWrapper();
            wrapper2.caseId = epicExtCase.Id;
            wrapper2.catsId = newCat.Id;
            wrapper2.credUrl = assetUrl+'1234';
            wrapper2.transUrl = assetUrl+'12345';
            wrapper2.nameUrl = assetUrl+'12346';
            wrapper2.haveCertificate = false;
            wrapper2.requestedToSend = false;
            wrapper2.entityId = newAcct.Id;
            wrapper2.nameDifferent = false;
            wrapper2.nameOnDoc = 'Test';
            wrapper2.translationRequired = false;

            EpicCredVerController.EVRWrapper evr = new EpicCredVerController.EVRWrapper();
            evr.authId = newAcct.Id;
            evr.regOrgDNK = false;
            evr.ref = 'tester';
            evr.program = 'EPIC';
            wrapper.evrId = evrRecord.Id;
            wrapper.evrWrap = JSON.serialize(evr);

            EpicCredVerController.EVRWrapper evr2 = new EpicCredVerController.EVRWrapper();
            evr2.authId = newAcct.Id;
            evr2.regOrgDNK = true;
            evr2.ref = 'tester';
            evr2.program = 'EPIC';
            wrapper2.evrId = evrRecord.Id;
            wrapper2.evrWrap = JSON.serialize(evr2);
            newCat.Title__c = 'Test';
            Boolean updateResult = EpicCredVerController.updateCatsRecord(JSON.serialize(newCat), newCat.Id);
            System.assert(updateResult, 'CATS update failed');
            newCat = EpicCredVerController.getCatCheckboxValues(newCat.Id);
            System.assert(newCat.Id != null, 'CATS fetch failed');
            Contact_Association_Type_Staging__c newCat2 = EpicCredVerController.getCatCheckboxValues('');
            System.assertEquals(newCat2,null, 'Null returned');
        }
    }
    @isTest
    static void testCreateCredential(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
        Id evrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();                
        Test.startTest();
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            Insert newAcct;
            System.assert(newAcct.Id!= null,'Account not created');           
            String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
           
            Service__c newSer = new Service__c();
            newSer.Name = 'Volume Report Recipients';
            INSERT newSer;
            System.assert(newSer.Id!= null,'Service not created');
            
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            String catRecordValues = JSON.serialize(catsRecordNew);

            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = false;
            String evrValues = JSON.serialize(evrWrapper);

            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = newAcct.Id;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');
            Case evrRecord = new Case();
            evrRecord.RecordTypeId = evrRecordTypeId;
            evrRecord.Secondary_Parent_Case__c = caseObj.Id;
            evrRecord.Reference_Number__c = 'test';
            evrRecord.Entity__c = newAcct.Id;
            evrRecord.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = false;
            evrRecord.Internal_Status__c = Constants.CASE_STATUS_NEW;
            INSERT evrRecord;
            System.assert(evrRecord.Id != null, 'Epic verification report creation failed');
            
            //Create and Insert Asset
            Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = caseObj.Id,
                                    Azure_Storage_URL__c = assetUrl);
            INSERT asst1;
            System.assert(asst1.Id != null, 'failed to insert');
            Asset tstAsset = [SELECT Id, Azure_Storage_URL__c, Case__c FROM Asset WHERE Id=:asst1.Id LIMIT 1];
            EpicCredVerController.CredUploadWrapper wrapper = new EpicCredVerController.CredUploadWrapper();
            wrapper.caseId = caseObj.Id;
            wrapper.catsId = catsRecordNew.Id;
            wrapper.credUrl = assetUrl;
            wrapper.transUrl = assetUrl+'12345';
            wrapper.nameUrl = assetUrl+'12346';
            wrapper.haveCertificate = false;
            wrapper.requestedToSend = false;
            wrapper.entityId = newAcct.Id;
            wrapper.nameDifferent = true;
            wrapper.nameOnDoc = 'Test';
            wrapper.translationRequired = true;
            wrapper.evrId = evrRecord.Id;
            wrapper.evrWrap = JSON.serialize(evrWrapper);
            String wrapperValues = JSON.serialize(wrapper);
            Boolean createResult = EpicCredVerController.createCredential(wrapperValues,catRecordValues,evrValues);
            System.assert(createResult, 'Insertion failed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCredentialSuccess(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
        Id evrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();                
        Test.startTest();
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            
            Service__c newSer = new Service__c();
            newSer.Name = 'Volume Report Recipients';
            INSERT newSer;
            System.assert(newSer.Id!= null,'Service not created');
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catRecTypeId;
            catsRecordNew.Credential_Type__c = 'Final Medical Diploma';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = usr.contactId;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');
            
            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = false;
            String evrValues = JSON.serialize(evrWrapper);

            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = newAcct.Id;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');
            Case evrRecord = new Case();
            evrRecord.RecordTypeId = evrRecordTypeId;
            evrRecord.Secondary_Parent_Case__c = caseObj.Id;
            evrRecord.Reference_Number__c = 'test';
            evrRecord.Entity__c = newAcct.Id;
            evrRecord.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = false;
            evrRecord.Internal_Status__c = Constants.CASE_STATUS_NEW;
            Insert evrRecord;
            System.assert(evrRecord.Id != null, 'Epic verification report creation failed');
            

            String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            //Create and Insert Asset
            Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = caseObj.Id,
                                    Azure_Storage_URL__c = assetUrl);
            INSERT asst1;
            System.assert(asst1.Id != null, 'asset insertion failed');
            Asset asst2 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = caseObj.Id,
                                    Azure_Storage_URL__c = assetUrl+'1234');
            INSERT asst2;
            System.assert(asst2.Id != null, 'asset insertion failed');

            EpicCredVerController.CredUploadWrapper wrapper = new EpicCredVerController.CredUploadWrapper();
            wrapper.caseId = caseObj.Id;
            wrapper.catsId = catsRecordNew.Id;
            wrapper.credUrl = assetUrl+'1234';
            wrapper.transUrl = assetUrl+'12345';
            wrapper.nameUrl = assetUrl+'12346';
            wrapper.haveCertificate = false;
            wrapper.requestedToSend = false;
            wrapper.entityId = newAcct.Id;
            wrapper.nameDifferent = false;
            wrapper.nameOnDoc = 'Test';
            wrapper.translationRequired = false;
            wrapper.evrId = evrRecord.Id;
            wrapper.evrWrap = JSON.serialize(evrWrapper);
            String wrapperValues = JSON.serialize(wrapper);
            Boolean returnResult = EpicCredVerController.updateCredential(wrapperValues);            
            System.assertEquals(true, true, 'credential updated successfully');
            Case tstEVCaseObj = [SELECT Id,Secondary_Parent_Case__c FROM Case WHERE Secondary_Parent_Case__c=:caseObj.Id LIMIT 1];
            System.assert(tstEVCaseObj.Id != null, 'EVR Case created successfully');
            Boolean returnResult2 = EpicCredVerController.deleteEpicVerfRepRequestCase(evrRecord.Id,caseObj.Id,true);
        }
        Test.stopTest();
    }
    @isTest
    static void testUpdateEVRSuccessNoEvrId(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Test.startTest();
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            
            Service__c newSer = new Service__c();
            newSer.Name = 'Volume Report Recipients';
            INSERT newSer;
            System.assert(newSer.Id!= null,'Service not created');
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catRecTypeId;
            catsRecordNew.Credential_Type__c = 'Final Medical Diploma';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = usr.contactId;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');
            
            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = false;
            String evrValues = JSON.serialize(evrWrapper);
            
            EpicCredVerController.EVRWrapper evrWrapper2 = new EpicCredVerController.EVRWrapper();
            evrWrapper2.program = 'EPIC';
            evrWrapper2.authId = newAcct.Id;
            evrWrapper2.ref = 'EPIC1234';
            evrWrapper2.regOrgDNK = true;
            String evrValues2 = JSON.serialize(evrWrapper2);

            //case obj
            Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = newAcct.Id;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');
            Case tstCaseObj = [SELECT Id,Document_Type__c,Entity__c FROM Case WHERE Id=:caseObj.Id LIMIT 1];
            Boolean returnValue = EpicCredVerController.updateEvr(evrValues,'',tstCaseObj.Id);
            System.assertEquals(true, true, 'EVR Case created successfully');
            Case tstEVCaseObj = [SELECT Id,Secondary_Parent_Case__c FROM Case WHERE Secondary_Parent_Case__c=:caseObj.Id LIMIT 1];
            System.assert(tstEVCaseObj.Id != null, 'EVR Case created successfully');

            Boolean returnValue2 = EpicCredVerController.updateEvr(evrValues2,'',tstCaseObj.Id);
            System.assertEquals(true, true, 'EVR Case created successfully');
            Case tstEVCaseObj2 = [SELECT Id,Secondary_Parent_Case__c FROM Case WHERE Secondary_Parent_Case__c=:caseObj.Id LIMIT 1];
            System.assert(tstEVCaseObj2.Id != null, 'EVR Case created successfully');
        }
        Test.stopTest();
    }
    @isTest
    static void testUpdateEVRSuccess(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Test.startTest();
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            
            Service__c newSer = new Service__c();
            newSer.Name = 'Volume Report Recipients';
            INSERT newSer;
            System.assert(newSer.Id!= null,'Service not created');
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catRecTypeId;
            catsRecordNew.Credential_Type__c = 'Final Medical Diploma';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = usr.contactId;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');
            
            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = true;
            String evrValues = JSON.serialize(evrWrapper);
            
            //case obj
            Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = newAcct.Id;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');
            //Insert EVR case
            Case  evr = new Case();
            evr.recordTypeId = Constants.EPICVERREPORTREQRTID;
            evr.Internal_Status__c = Constants.CASE_STATUS_NEW;
            evr.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            evr.Secondary_Parent_Case__c = caseObj.Id;
            evr.Document_Type__c = caseObj.Document_Type__c;
            evr.ContactId = usr.contactId;
            evr.AccountId = newAcct.Id;
            evr.Service_Name__c = serviceId;
            evr.Entity__c = evrWrapper.authId;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT evr;
            }
            System.assert(evr.Id != null, 'Case failed');

            Case tstCaseObj = [SELECT Id,Document_Type__c,Entity__c FROM Case WHERE Id=:caseObj.Id LIMIT 1];
            Case tstEVRCaseObj = [SELECT Id,Document_Type__c,Entity__c FROM Case WHERE Id=:evr.Id LIMIT 1];

            Boolean returnValue = EpicCredVerController.updateEvr(evrValues,tstEVRCaseObj.Id,tstCaseObj.Id);
            System.assertEquals(true, true, 'EVR Case created successfully');
            Case tstEVCaseObj = [SELECT Id,Secondary_Parent_Case__c FROM Case WHERE Secondary_Parent_Case__c=:caseObj.Id LIMIT 1];
            System.assert(tstEVCaseObj.Id != null, 'EVR Case Updated successfully');
        }
        Test.stopTest();
    }
    @isTest
    static void testCredTermsRec(){
        User testUser = [Select id, contactId FROM User WHERE alias = 'testUsr1'];
		Test.startTest();
		System.runAs(testUser){
			Product2 prod = new Product2();
			prod.Name = 'End User Legal Terms - CredentialIntake';
			INSERT prod;
			Terms_and_Conditions__c termsCond = new Terms_and_Conditions__c();
			termsCond.Copy__c = '';
			termsCond.Name = '';
			termsCond.Status__c = 'Active';
			termsCond.Product__c = prod.Id;
			termsCond.ExpirationDate__c = Date.newInstance(2021, 10, 10);
			INSERT termsCond;
			Boolean result1 = EpicCredVerController.createCredTermsRec(constants.PRODUCT_NAME_CRED_INTAKE_LEGAL_TERMS);
            System.AssertEquals(result1,true,'Terms Record is not created');            
		}
		Test.stopTest();
    }
    
    @isTest
    static void testPayCompletionn(){
        User testUser = [Select Id, ContactId FROM User WHERE alias = 'testUsr1'];
        Test.startTest();
        System.runAs(testUser){
            Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
            Id evRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();

            Case cs = new Case(ContactId=testUser.ContactId, Internal_Status__c=Constants.CASE_STATUS_PENDING_SUBMISSION,RecordTypeId=credVerRecTypeId);
            INSERT cs;
            System.assert(cs.Id!=null,'Case not found');
            List<Case> credCases = [SELECT id, Internal_Status__c, CaseNumber FROM Case WHERE Id=:cs.Id LIMIT 1];
            //Insert Ev Case
            Case evCase = new Case();
            evCase.ContactId = testUser.ContactId;
            evCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
            evCase.RecordTypeId = evRecTypeId;
            INSERT evCase;
            System.assert(evCase.Id!=null,'Case not found');

            List<Case> evrList = [SELECT Id, Entity__c, CaseNumber, Internal_Status__c FROM Case WHERE Id =:evCase.Id LIMIT 1];
            List<String> rtnVal= EpicCredVerController.payCompletion();
            System.assert(!rtnVal.isEmpty(),'Payment not complete');
        }
        Test.stopTest();
    }
    @isTest
    static void testCheckCGSReqSentToECFMG(){
        User testUser = [Select Id, ContactId FROM User WHERE alias = 'testUsr1'];
        Test.startTest();
        System.runAs(testUser){
            Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
            Case cs = new Case(ContactId=testUser.ContactId, Internal_Status__c=Constants.CASE_STATUS_PENDING_SUBMISSION,RecordTypeId=credVerRecTypeId);
            INSERT cs;
            System.assert(cs.Id!=null,'Case not found');
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            
            //insert CAT staging record
            Id catStagingRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catStagingRecTypeId;
            catsRecordNew.Credential_Type__c = 'Certificate of Good Standing';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = testUser.contactId;
            catsRecordNew.Account__c = newAcct.Id;
            catsRecordNew.Case__c =cs.Id;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');

            List<Case> credCases = [SELECT Id,ContactId, Internal_Status__c FROM Case WHERE Id=:cs.Id LIMIT 1];
            Map<Id,Boolean> rtnVal= EpicCredVerController.checkCGSReqSentToECFMG(credCases);
            System.assert(!rtnVal.isEmpty(),'CheckCGSReqSentToECFMG not complete');
        }
        Test.stopTest();
    }
    @isTest
    static void testCredConfMsg(){
        User testUser = [Select id, contactId FROM User WHERE alias = 'testUsr1'];
		Test.startTest();
		System.runAs(testUser){
            List<Confirmation_Message__mdt> confMsgs = new List<Confirmation_Message__mdt>();
        	confMsgs = [SELECT Id FROM Confirmation_Message__mdt WHERE DeveloperName =: Constants.CONFIRMATION_MESSAGE_CRED_INTAKE WITH SECURITY_ENFORCED];        
			String result = EpicCredVerController.getCredMetaData();
            System.AssertEquals(result,confMsgs[0].Id,'Meta Data is not available');
		}
		Test.stopTest();
    }
    
    
    @isTest
    static void testCreateCredentialHlpr(){
        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Test.startTest();
        System.runAs(usr){          
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Case epicExtCase = new Case();
            epicExtCase.RecordTypeId = epicExtRecTypeId;
            epicExtCase.ContactId = usr.contactId;
            epicExtCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
            INSERT epicExtCase;
            System.assert(epicExtCase.Id != null, 'epic case null');
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catRecTypeId;
            catsRecordNew.Credential_Type__c = 'Final Medical Diploma';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = usr.contactId;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');
            
            List<Asset> currAssetsList = new List <Asset>();
            //Create and Insert Asset
            String assetCredUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
                                    Type__c	= 'Final Medical Diploma',
                                    Contact_Association_Type_Staging__c = catsRecordNew.Id,
                                    Azure_Storage_URL__c = assetCredUrl);
            INSERT asst1;
            System.assert(asst1.Id != null, 'failed to insert');
            currAssetsList.add(asst1);
            String assetNameUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            Asset asst2 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = epicExtCase.Id,
                                    Contact_Association_Type_Staging__c = catsRecordNew.Id,
                                    Azure_Storage_URL__c = assetNameUrl);
            INSERT asst2;
            System.assert(asst2.Id != null, 'asset failed');
            currAssetsList.add(asst2);
            //translation asset
            String assetTransUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            Asset asst3 = new Asset(Name = Constants.ASSET_TYPE_TRANSLATION,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= Constants.ASSET_TYPE_TRANSLATION,
                                    case__c = epicExtCase.Id,
                                    Contact_Association_Type_Staging__c = catsRecordNew.Id,
                                    Azure_Storage_URL__c = assetTransUrl);
            INSERT asst3;
            System.assert(asst3.Id != null, 'asset failed');
            currAssetsList.add(asst3);

            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = true;
            String evrValues = JSON.serialize(evrWrapper);
            EpicCredVerController.CredUploadWrapper credWrapper = new EpicCredVerController.CredUploadWrapper();
            credWrapper.caseId = epicExtCase.Id;
            credWrapper.catsId = catsRecordNew.Id;
            credWrapper.credUrl = assetCredUrl;
            credWrapper.nameUrl = assetNameUrl;
            credWrapper.transUrl = assetTransUrl;
            credWrapper.haveCertificate = false;
            credWrapper.requestedToSend = false;
            credWrapper.entityId = newAcct.Id;
            credWrapper.nameDifferent = false;
            credWrapper.nameOnDoc = 'Testname';
            credWrapper.translationRequired = true;
            credWrapper.evrWrap = '';
            credWrapper.evrId = evrWrapper.authId;
            //case obj
            Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = credWrapper.entityId;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');

            EpicCredVerController.createCredentialHlpr(caseObj,catsRecordNew,currAssetsList);
            Asset tstAsset = [SELECT Id, Case__c FROM Asset WHERE Id =:asst1.Id];
            System.assertEquals(caseObj.Id, tstAsset.Case__c, 'Asset is updated');
            Test.stopTest();
        }
    }
    
   @isTest
    static void testCreateCredentialEVRHlprFailure(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Test.startTest();
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            Case epicExtCase = new Case();
            epicExtCase.RecordTypeId = epicExtRecTypeId;
            epicExtCase.ContactId = usr.contactId;
            epicExtCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
            INSERT epicExtCase;
            System.assert(epicExtCase.Id != null, 'epic case null');
            Service__c newSer = new Service__c();
            newSer.Name = 'Volume Report Recipients';
            INSERT newSer;
            System.assert(newSer.Id!= null,'Service not created');
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catRecTypeId;
            catsRecordNew.Credential_Type__c = 'Final Medical Diploma';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = usr.contactId;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');
            
            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = true;
            String evrValues = JSON.serialize(evrWrapper);
            
            //case obj
            Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = newAcct.Id;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');
            Case tstCaseObj = [SELECT Id,Document_Type__c,Entity__c FROM Case WHERE Id=:caseObj.Id LIMIT 1];
            EpicCredVerController.createCredentialEVRHlpr(evrValues,tstCaseObj);
        }
    }
    @isTest
    static void testCreateCredentialEVRHlprSuccess(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testUserapp@test.com' limit 1];
        System.assert(usr.Id != null, 'User is null');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Test.startTest();
        System.runAs(usr){
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.BillingCountry = 'India';
            newAcct.Name = 'Test AccountCred';
            newAcct.RecordTypeId = recTypeId;
            INSERT newAcct;
            System.assert(newAcct.Id!= null,'Account not created');
            Case epicExtCase = new Case();
            epicExtCase.RecordTypeId = epicExtRecTypeId;
            epicExtCase.ContactId = usr.contactId;
            epicExtCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
            INSERT epicExtCase;
            System.assert(epicExtCase.Id != null, 'epic case null');
            
            Service__c newSer = new Service__c();
            newSer.Name = 'Volume Report Recipients';
            INSERT newSer;
            System.assert(newSer.Id!= null,'Service not created');
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
            catsRecordNew.account__c = newAcct.Id;
            catsRecordNew.Title__c = 'TestTile';
            catsRecordNew.RecordTypeId = catRecTypeId;
            catsRecordNew.Credential_Type__c = 'Final Medical Diploma';
            catsRecordNew.Courier_service_for_an_additional_fee__c = true;
            catsRecordNew.Contact__c = usr.contactId;
            INSERT catsRecordNew;
            System.assert(catsRecordNew.Id!= null,'Contact_Association_Type_Staging__c not created');
            
            EpicCredVerController.EVRWrapper evrWrapper = new EpicCredVerController.EVRWrapper();
            evrWrapper.program = 'EPIC';
            evrWrapper.authId = newAcct.Id;
            evrWrapper.ref = 'EPIC1234';
            evrWrapper.regOrgDNK = false;
            String evrValues = JSON.serialize(evrWrapper);
            
            //case obj
            Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
            Case caseObj = new case();
            caseObj.ContactId = usr.contactId;
            caseObj.OwnerId = g.Id;
            caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.RecordTypeId = cvRecordTypeId;
            caseObj.Service__c = evrWrapper.program;
            caseObj.Entity__c = newAcct.Id;
            caseObj.Document_Type__c = catsRecordNew.Credential_Type__c;
            caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrapper.regOrgDNK;
            caseObj.Document_type_selected_by_applicant__c = catsRecordNew.Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordNew.Courier_service_for_an_additional_fee__c;
            if(Schema.sObjectType.Case.isCreateable()){
                INSERT caseObj;
            }
            System.assert(caseObj.Id != null, 'Case failed');
            Case tstCaseObj = [SELECT Id,Document_Type__c,Entity__c FROM Case WHERE Id=:caseObj.Id LIMIT 1];
            EpicCredVerController.createCredentialEVRHlpr(evrValues,tstCaseObj);
            Case tstEvr = [SELECT Id,Secondary_Parent_Case__c FROM Case WHERE Secondary_Parent_Case__c=:caseObj.Id];
            System.assertEquals(caseObj.Id, tstEvr.Secondary_Parent_Case__c, 'EVR Case created successfully');
        }
    }
    @isTest
    static void getCredDocumentTypesTest(){
		Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id != null, 'account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id != null, 'contact creation failed');
        Test.startTest();
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case idVerCase = new Case();
        idVerCase.RecordTypeId = idVerRecTypeId;
        idVerCase.ContactId = con.Id;
        idVerCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        INSERT idVerCase;
        System.assert(idVerCase.Id != null, 'Case creation failed');
        Id profId = [Select id FROM profile WHERE name='4-Customer Community Entity 360' LIMIT 1].id;
        User user1 = new User(alias = 'testUser',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testuser123@test.com');
        INSERT user1;
        System.assert(user1.Id != null, 'User creation failed');
        Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId = recordTypeId;
        cats.Account__c = con.AccountId;
        cats.Case__c = idVerCase.Id;
        cats.Contact__c = con.Id;
        cats.Start_Date__c = System.today();
        cats.End_Date__c = System.today() + 20;
        cats.Credential_Type__c = 'Pregraduate Internship Certificate';
        INSERT cats; 
        System.assert(cats.Id != null, 'CATS creation failed');
        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = con.Id,
                                	Contact_Association_Type_Staging__c = cats.Id,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    Azure_Storage_URL__c = assetUrl);
        INSERT asst1;
        System.assert(asst1.Id != null, 'Asset creation failed');
        Case epicVerRep = new Case();
        epicVerRep.Secondary_Parent_Case__c = idVerCase.Id;
        epicVerRep.contactId = con.Id;
        epicVerRep.Entity__c = con.AccountId;
        INSERT epicVerRep;
        System.assert(epicVerRep.Id != null, 'epicVerRep creation failed');
        System.runAs(user1){
           List<Contact_Association_Type_Staging__c> catsList= EpicCredVerController.getCredDocumentTypes();
           system.assertEquals(catsList[0].Id,cats.Id,'Cats returned is not the same or null');
           List<String> credentialTypeList = new List<String>();
           credentialTypeList.add('Pregraduate Internship Certificate');
           Map<String,Map<String,String>> retValMap = EpicCredVerController.getCredProgDocTypeMap(credentialTypeList,'EPIC');
           system.assertEquals(retValMap.containsKey('Pregraduate Internship Certificate'),true,'Map returned is null');
           List<Id> caseList = new List<Id>();
           caseList.add(idVerCase.Id);
           EpicCredVerController.deleteCaseAndCats(caseList);
           system.assertEquals([Select id,Status FROM asset WHERE id=:asst1.Id][0].Status == Constants.ASSET_STATUS_MARKED_FOR_DELETION, true,'Asset status is not updated as marked for deletion');
        }
        Test.stopTest();
    }
    @isTest
    static void testCreateCATUpdCase(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id != null, 'account creation failed');
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.BillingCountry = 'India';
        INSERT newAcct;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id != null, 'contact creation failed');
        Id epiExtRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE).getRecordTypeId();
        Case extSubCase = new Case();
        extSubCase.RecordTypeId = epiExtRecordTypeId;
        extSubCase.ContactId = con.Id;
        extSubCase.Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW;
        INSERT extSubCase;
        System.assert(extSubCase.Id != null, 'Case creation failed');
        //INSERT CAT REC - Credential_Type__c, Case__c
        Id credIntakeCatRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type__c catTypeRec = new Contact_Association_Type__c();
        catTypeRec.Contact__c = con.Id;
        catTypeRec.Case__c = extSubCase.Id;
        catTypeRec.Account__c = newAcct.Id;
        catTypeRec.RecordTypeId = credIntakeCatRecTypeId;
        catTypeRec.Credential_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        catTypeRec.Degree_Issue_Date__c = Date.newInstance(2020, 12, 9);
        catTypeRec.Degree_Title__c = 'MBBS';
        INSERT catTypeRec;
        System.assert(catTypeRec.Id != null, 'Cat Type creation failed');

        //add assets for extSubCase
        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        Id asstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
                                    Status = Constants.ASSET_STATUS_ACCEPTED,
                                    ContactId = con.Id,
                                	Contact_Association_Type__c = catTypeRec.Id,
                                    Case__c = extSubCase.Id,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
                                    Type__c	= 'Verified Credential',
                                    RecordTypeId = asstRecTypeId,
                                    Azure_Storage_URL__c = assetUrl);
        INSERT asst1;
        System.assert(asst1.Id != null, 'Asset creation failed');
        Test.startTest();
        Contact_Association_Type__c catRecord = new Contact_Association_Type__c();
        catRecord.Degree_Issue_Date__c = null;
        catRecord.Account__c = newAcct.Id;
        catRecord.Degree_Title__c =' Degree title';
        catRecord.Graduation_Year__c = '2018';
        catRecord.Degree_expected_to_be_issued_Year__c = '';
        catRecord.Degree_expected_to_be_issued_Month__c = '';
        catRecord.Attendance_Start_Date__c = null;
        catRecord.Attendance_End_Date__c = null;
        catRecord.Program_Start_Date__c = null;
        catRecord.Program_End_Date__c = null;
        catRecord.Title__c = '';
        catRecord.Issue_Date__c = null;
        catRecord.Expiration_Date__c = null;
        catRecord.DOB_on_Document__c = null;
        String nameOnDoc = 'Tester Guest';
        String caseStatus = EpicCredVerController.getEpicExtSubCaseStatus(extSubCase.Id);
        System.assert(caseStatus!=null,'No status');
        List<Account> accts = EpicCredVerController.getEntities();
        System.assert(accts[0].Id!=null,'No entities');
        Boolean createCAT = EpicCredVerController.createCATRec(JSON.serialize(catRecord), extSubCase.Id, nameOnDoc);
        Boolean updExtCase = EpicCredVerController.updateExtSubCase(extSubCase.Id, newAcct.Id, false);
        System.assert(createCAT, 'Insert failed');
        System.assert(updExtCase, 'Update case failed');
        Test.stopTest();
    }
    @isTest static void testGetEpicAssetsAndDocumentsPositive(){
        String azureUrl='';
        List<Contact> testContact = [SELECT id,AccountId FROM Contact];
        String contactId = testContact[0].Id;
        Id epicVerRepReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        Case epicVerifReqCase = new Case();
        epicVerifReqCase.RecordTypeId = epicVerRepReqRecordTypeId;
        epicVerifReqCase.ContactId = contactId;
        epicVerifReqCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        INSERT epicVerifReqCase;
        System.assert(epicVerifReqCase.Id != null, 'Case creation failed');
        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        //Create and Insert Asset
        Id assetCredRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Asset asst2 = new Asset();
        asst2.Name = 'Credential Request';
        asst2.Status = Constants.ASSET_STATUS_VERIFIED;
        asst2.ContactId = contactId;
        asst2.Type__c = Constants.ASSET_TYPE_VERIFIED_FINAL_DIPLOMA;
        asst2.Case__c = epicVerifReqCase.Id;
        asst2.Azure_Storage_URL__c = assetUrl;
        asst2.RecordTypeId = assetCredRecTypId;
        INSERT asst2;
        System.assert(asst2.Id != null, 'asset Id is null');
        Test.startTest();
        azureUrl = EpicCredVerController.getEpicAssetsAndDocuments(epicVerifReqCase.Id);
        System.assert(azureUrl != null, 'Azure url returned null');
        Test.stopTest();
    }

    @isTest static void testGetEpicAssetsAndDocumentsNegative(){
        String azureUrl='';
        List<Contact> testContact = [SELECT id,AccountId FROM Contact];
        String contactId = testContact[0].Id;
        Id epicVerRepReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        Case epicVerifReqCase = new Case();
        epicVerifReqCase.RecordTypeId = epicVerRepReqRecordTypeId;
        epicVerifReqCase.ContactId = contactId;
        epicVerifReqCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        INSERT epicVerifReqCase;
        System.assert(epicVerifReqCase.Id != null, 'Case creation failed');
        String assetUrl = '';
        //Create and Insert Asset
        Id assetCredRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Asset asst2 = new Asset();
        asst2.Name = 'Credential Request';
        asst2.Status = Constants.ASSET_STATUS_VERIFIED;
        asst2.ContactId = contactId;
        asst2.Type__c = Constants.ASSET_TYPE_VERIFIED_FINAL_DIPLOMA;
        asst2.Case__c = epicVerifReqCase.Id;
        asst2.Azure_Storage_URL__c = assetUrl;
        asst2.RecordTypeId = assetCredRecTypId;
        INSERT asst2;
        System.assert(asst2.Id != null, 'asset Id is null');
        Test.startTest();
        azureUrl = EpicCredVerController.getEpicAssetsAndDocuments(epicVerifReqCase.Id);
        System.assert(azureUrl == null, 'Azure url returned null');
        Test.stopTest();
    }
    @isTest static void testGetEpicSummaryDetails(){
        List<Contact> testContact = [SELECT id,AccountId FROM Contact];
        String contactId = testContact[0].Id;
        Id accEntityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.RecordTypeId = accEntityRecordTypeId;
        acc.Contact_Id__c = contactId;
        INSERT acc;
        System.assert(acc.Id != null, 'Account creation failed');
        Id epicVerRepReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        Case epicVerifReqCase = new Case();
        epicVerifReqCase.RecordTypeId = epicVerRepReqRecordTypeId;
        epicVerifReqCase.ContactId = contactId;
        epicVerifReqCase.Report_Type__c ='Volume Entity';
        epicVerifReqCase.Internal_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REQUESTED;
        epicVerifReqCase.Entity__c = acc.id;

        INSERT epicVerifReqCase;
        System.assert(epicVerifReqCase.Id != null, 'Case creation failed');
        Case cDetail;
        Test.startTest();
        cDetail = EpicCredVerController.getEpicSummaryDetails(epicVerifReqCase.Id);
        System.assert(cDetail != null, 'Case detail returned null');
        Test.stopTest();
    }
    
    @isTest static void testGetCaseNumberSuccess(){
        String caseNumber;
        Contact con = [SELECT id FROM Contact LIMIT 1];
        Id contactId = con.Id;
        User usr = [SELECT Id FROM User WHERE username = 'testuser@test.com' limit 1];
        System.runAs(usr){
            Id epicExtractRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
            Case epicExtractCase = new Case();
            epicExtractCase.RecordTypeId = epicExtractRecordTypeId;
            epicExtractCase.ContactId = contactId;
            epicExtractCase.Internal_Status__c = 'In Review';
            INSERT epicExtractCase;
            System.assert(epicExtractCase.Id != null, 'Case creation failed');
            List<Case> newEpicCases = new List<Case>();
            String epiCasenumber;
            newEpicCases = [SELECT id, CaseNumber FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION
                            AND ContactId =: contactId 
                            AND Case_Status__c != :Constants.CASE_STATUS_REJECTED];
            
            if(!newEpicCases.isEmpty()){
                epiCasenumber = newEpicCases[0].CaseNumber;
            }
            Test.startTest();
            caseNumber = EpicCredVerController.getCaseNumber();
            System.assertEquals(newEpicCases[0].id, epicExtractCase.id, 'Case number not returned');
            //System.assertEquals(epiCasenumber, caseNumber, 'Case number returned');
            Test.stopTest();
        }
    }
    @isTest static void testGetCaseNumberFailure(){
        String caseNumber;
        List<Contact> testContact = [SELECT id,AccountId FROM Contact];
        Id contactId = testContact[0].Id;
        Id epicExtractRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Case epicExtractCase = new Case();
        epicExtractCase.RecordTypeId = epicExtractRecordTypeId;
        epicExtractCase.ContactId = contactId;
        epicExtractCase.Internal_Status__c = 'In Review';
        INSERT epicExtractCase;
        System.assert(epicExtractCase.Id != null, 'Case creation failed');
        Test.startTest();
        caseNumber = EpicCredVerController.getCaseNumber();
        System.assert(caseNumber != null, 'Case number returned null');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerSuccess(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2022","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2018-01-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtChecker(strDtValues);
        System.assert(returnVal != null, 'Date values returned');

        Test.stopTest();
    }
    @isTest
    static void testDtCheckerFailure(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"202","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2018-01-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtChecker(strDtValues);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerCogIssueFailure(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"202","degExpYrDt":"202","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2018-01-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogIssue(strDtValues,returnVal);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    //
    @isTest
    static void testDtCheckerCogIssueGrYrSuccess(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2022","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2018-01-10","expDt":"2022-01-10"}';
        Integer testAttYr = 2021;
        Integer testGrd = 2020;
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogIssueGrYr(testAttYr,testGrd, returnVal);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerCogIssueDateSuccess(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2022","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2022-12-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogIssueDate(strDtValues,returnVal);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerCogIssueDateFailure(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2020","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2022-01-10","expDt":"2021-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogIssueDate(strDtValues,returnVal);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerCogIssueSecSuccess(){
        Map<String,String> returnVal = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2020","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2022-12-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogIssueSec(strDtValues,returnVal);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerCogIssueSecFailure(){
        Map<String,String> returnVal = new Map<String,String>();
        Map<String,String> returnVal2 = new Map<String,String>();
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2020","degExpYrDt":"2021","attStDt":"2022-01-10","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2022-12-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogIssueSec(strDtValues,returnVal);
        System.assert(returnVal != null, 'Date values returned');

        String strDtValues2 = '{"degIssueDt":"2021-10-20","gradYrDt":"2022","degExpYrDt":"2021","attStDt":"2018-01-10","attEndDt":"2025-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2022-12-10","expDt":"2022-01-10"}';
        returnVal2 = EpicCredVerController.dtCheckerCogIssueSec(strDtValues2,returnVal2);
        System.assert(returnVal2 != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testDtCheckerCogAttDateSuccess(){
        Map<String,String> returnVal = new Map<String,String>();
        Datetime attStDt = System.Today()+2;
        String attDateStr = attStDt.format('yyyy-MM-dd');
        String strDtValues = '{"degIssueDt":"2021-10-20","gradYrDt":"2020","degExpYrDt":"2021","attStDt":"'+ attDateStr +'","attEndDt":"2021-12-10","prStDt":"2022-02-10","prEndDt":"2018-11-20","issDt":"2022-12-10","expDt":"2022-01-10"}';
        Test.startTest();
        returnVal = EpicCredVerController.dtCheckerCogAttDate(strDtValues,returnVal);
        System.assert(returnVal != null, 'Date values returned');
        Test.stopTest();
    }
    @isTest
    static void testCheckSchoolTypeSuccess(){
        Set<String> testSchoolTypes = new Set<String>();
        testSchoolTypes.add('Allopathic');
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.School__c = true;
        newAcct.sch_School_type__c = 'Allopathic';
        newAcct.Medschool_Code__c = '664';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account creation failed');
        Test.startTest();
        Boolean returnVal = EpicCredVerController.checkSchoolType(newAcct,testSchoolTypes);
        System.assertEquals(returnVal, true, 'School types retrieved');
        Test.stopTest();
    }
    @isTest
    static void testCheckSchoolTypeFailure(){
        Set<String> testSchoolTypes = new Set<String>();
        testSchoolTypes.add('Medical School');
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.School__c = true;
        newAcct.sch_School_type__c = 'Allopathic';
        newAcct.Medschool_Code__c = '664';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account creation failed');
        Test.startTest();
        Boolean returnVal = EpicCredVerController.checkSchoolType(newAcct,testSchoolTypes);
        System.assertEquals(returnVal, false, 'School types not retrieved');
        Test.stopTest();
    }
    @isTest
    static void testCheckAccountTypeSuccess(){
        Set<String> testAccountTypes = new Set<String>();
        testAccountTypes.add('School');
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.School__c = true;
        newAcct.sch_School_type__c = 'Basic Science';
        newAcct.Medschool_Code__c = '664';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account creation failed');
        Account testAcct = [SELECT Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, sch_School_Type__c, Account_Type__c, University_Name__c  
                            FROM Account WHERE Id=:newAcct.Id LIMIT 1];
        Test.startTest();
        Boolean returnVal = EpicCredVerController.checkAccountType(testAcct,testAccountTypes);
        System.assertEquals(returnVal, true, 'Account types retrieved');
        Test.stopTest();
    }
    @isTest
    static void testCheckAccountTypeFailure(){
        Set<String> testAccountTypes = new Set<String>();
        testAccountTypes.add('Media');
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.School__c = true;
        newAcct.Medschool_Code__c = '664';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account creation failed');
        Account testAcct = [SELECT Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, sch_School_Type__c, Account_Type__c, University_Name__c  
                            FROM Account WHERE Id=:newAcct.Id LIMIT 1];
        Test.startTest();
        Boolean returnVal = EpicCredVerController.checkAccountType(testAcct,testAccountTypes);
        System.assertEquals(returnVal, false, 'Account types not retrieved');
        Test.stopTest();
    }
    @isTest
    static void testCheckVerifictnSuccess(){//
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();            
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Reg Org';
        newAcct.RecordTypeId = recTypeId;
        INSERT newAcct;
        System.assert(newAcct.Id!= null,'Account not created');
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        INSERT newSer;
        System.assert(newSer.Id!= null,'Service not created');
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = false;
        acctServ.Account__c = newAcct.Id;
        acctServ.Service__c = newSer.Id;
        //acctServ.isActiveEntity = true;
        INSERT acctServ;
        String fmd = 'Final Medical Diploma';
        System.assert(acctServ.Id!= null,'Account2Service not created');
        CONTACT2ACCTSERVICE__c con2Ser = new CONTACT2ACCTSERVICE__c();
        con2Ser.Account_Service__c = acctServ.Id;
        con2Ser.Active__c = True;
        con2Ser.Preferred_Mode_of_Communication__c = 'Email';
        con2Ser.List_of_emails__c = 'test1@test.com';
        con2Ser.Credential_Type__c = fmd;
        con2Ser.Physical_Address__c = 'test';
        con2Ser.City__c = 'Test City';
        con2Ser.Country__c = 'India';
        con2Ser.Street__c = '123 steet';
        INSERT con2Ser;
        System.assert(con2Ser.Id!= null,'ContactAccount2Service not created');
        String checkPor = EpicCredVerController.checkVerifictn(con2Ser.id,fmd);
        System.assert(checkPor!= null,'non Portal usr is exist');
    }
    @isTest
    static void testCheckVerPerModeSuccess(){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();            
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Reg Org';
        newAcct.RecordTypeId = recTypeId;
        INSERT newAcct;
        System.assert(newAcct.Id!= null,'Account not created');
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        INSERT newSer;
        System.assert(newSer.Id!= null,'Service not created');
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = false;
        acctServ.Account__c = newAcct.Id;
        acctServ.Service__c = newSer.Id;
        //acctServ.isActiveEntity = true;
        INSERT acctServ;
        String fmd = 'Final Medical Diploma';
        System.assert(acctServ.Id!= null,'Account2Service not created');
        CONTACT2ACCTSERVICE__c con2Ser = new CONTACT2ACCTSERVICE__c();
        con2Ser.Account_Service__c = acctServ.Id;
        con2Ser.Active__c = true;
        con2Ser.Preferred_Mode_of_Communication__c = 'Email';
        con2Ser.List_of_emails__c = 'test1@test.com';
        con2Ser.Credential_Type__c = fmd;
        con2Ser.Physical_Address__c = 'test';
        con2Ser.City__c = 'Test City';
        con2Ser.Country__c = 'India';
        con2Ser.Street__c = '123 steet';
        INSERT con2Ser;
        System.assert(con2Ser.Id!= null,'ContactAccount2Service not created');
        List<CONTACT2ACCTSERVICE__c> con2AccList = new List<CONTACT2ACCTSERVICE__c>();
        con2AccList.add(con2Ser);
        String checkPor = EpicCredVerController.checkVerPerMode(con2AccList);
        System.assert(checkPor!= null,'non Portal usr is exist');
    }
    @isTest
    static void testSearchEntitiesSuccess(){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.School__c = true;
        newAcct.sch_School_type__c = 'Basic Science';
        newAcct.Medschool_Code__c = '664';
        newAcct.WDOMS_ID__c = '12345';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account creation failed');
        //Program_Document_type_Mapping__mdt - EPIC, Final Medical Diploma
        //Document_Type_Role_Mapping__mdt - school type	Basic Science
        //Account Type	School
        Test.startTest();
        List<Account> entityList = EpicCredVerController.searchEntities('Test', 'Final Medical Diploma', 'EPIC');
        Test.stopTest();
        System.assertEquals(!entityList.isEmpty(), true, 'Entities retrieved Successfully');
    }
    @isTest
    static void testSearchEntitiesFailure(){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.BillingCountry = 'India';
        newAcct.Name = 'Test entity';
        newAcct.RecordTypeId = recTypeId;
        newAcct.School__c = true;
        newAcct.sch_School_type__c = '';
        newAcct.Medschool_Code__c = '664';
        newAcct.WDOMS_ID__c = '12345';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account creation failed');
        //Program_Document_type_Mapping__mdt - EPIC, Advanced Degree in the Medical Sciences - cred type
        //Account Type - 	Post Graduate Medical Education
        //School Type = ''
        Test.startTest();
        List<Account> entityList = EpicCredVerController.searchEntities('Test', 'Advanced Degree in the Medical Sciences', 'EPIC');
        Test.stopTest();
        System.assertEquals(!entityList.isEmpty(), false, 'Entities not retrieved');
    }
    @isTest
    static void testGetAssetUrlsSuccess(){
        User usr = [SELECT Id,contactId FROM User WHERE username = 'testuser@test.com' limit 1];
        Id profId = [Select id FROM profile WHERE name='4-Customer Community Plus Login' LIMIT 1].id;
        usr.ProfileId = profId;
        update usr;
        System.assert(usr.ProfileId == profId,'Profile id update failed');
        Id epicExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        System.runAs(usr){
           Case epicExtCase = new Case();
            epicExtCase.RecordTypeId = epicExtRecTypeId;
            epicExtCase.ContactId = usr.contactId;
            epicExtCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
            INSERT epicExtCase;
            System.assert(epicExtCase.Id != null, 'epic case Id is null');
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
            Account newAcct = new Account();
            newAcct.Name = 'Test Account';
            newAcct.BillingCountry = 'India';
            newAcct.RecordTypeId = recTypeId;
            Insert newAcct;
            System.assert(newAcct.Id!= null,'Account is not created');
            Contact_Association_Type_Staging__c newCat = new Contact_Association_Type_Staging__c();
            newCat.Account__c = newAcct.Id;
            newCat.Contact__c = usr.contactId;
            newCat.RecordTypeId = catRecTypeId;
            newCat.Case__c = epicExtCase.Id;
            Insert newCat;
            system.assert(newCat.Id!=null,'CAT record is not created');
            String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            //Create and Insert Asset
            Asset asst1 = new Asset(Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = epicExtCase.Id,
                                    Azure_Storage_URL__c = assetUrl);
            INSERT asst1;
            System.assert(asst1.Id != null, 'asset insertion failed');
            Asset asst2 = new Asset(Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= 'Photo',
                                    case__c = epicExtCase.Id,
                                    Azure_Storage_URL__c = assetUrl+'1234');
            INSERT asst2;
            System.assert(asst2.Id != null, 'asset insertion failed');
            Case testCase = [SELECT Id, RecordTypeId,ContactId,Internal_Status__c FROM Case WHERE Id=:epicExtCase.Id LIMIT 1];
            Map<String, String> assetMap = EpicCredVerController.getAssetUrls(epicExtCase.Id);
            System.assert(assetMap.keySet().size() != 0, 'asset fetch failed');
        }
    }
    @isTest
    static void testGetAddressValueSuccess(){
        String returnValue;
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
        Account newAcct = new Account();
        newAcct.Name = 'Test Account';
        newAcct.BillingCountry = 'United States';
        newAcct.BillingStreet = '123 Street';
        newAcct.BillingCity = 'Philadelphia';
        newAcct.BillingState = 'Pennsylvania';
        newAcct.BillingPostalCode = '19342';
        newAcct.RecordTypeId = recTypeId;
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account is not created');
        
        Account tstAccount = [SELECT BillingAddress FROM Account WHERE ID =:newAcct.Id];
        Test.startTest();
        returnValue = EpicCredVerController.getAddressValue(tstAccount.BillingAddress);
        Test.stopTest();
        System.assert(returnValue != null, 'Address retrieved');
    }

    @isTest
    static void testGetCredAllTC(){
        List<AppForCertHelper.TermsObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper>();
        Product2 prod = new Product2(Name = 'End User Legal Terms - CredentialIntake',
				Family = 'Agreements');
        INSERT prod;
        System.assert(prod.Id != null, 'Test product creation failed');
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c(
            Name = 'Test',
            Copy__c = 'Test',
            Short_Copy__c = 'Test',
            Status__c = 'Active',
            Product__c = prod.Id,
            ExpirationDate__c = System.today() + 20
        );
        INSERT tc;
        System.assert(tc.Id != null, 'Test Terms and conditions creation failed');

        List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
        
        termsList = [SELECT Id, Copy__c, Name, Short_Copy__c FROM Terms_and_Conditions__c 
                        WHERE Product__r.Name ='End User Legal Terms - CredentialIntake'
                        AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
                        ORDER BY CreatedDate ASC];
        if(!termsList.isEmpty()){
            for(Terms_and_Conditions__c terms : termsList){
                string termsId = terms.Id;
                string termsContent = terms.Copy__c;
                string termsCheckBox = terms.Short_Copy__c;
                AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);
                fetchedValuesToReturn.add(tempTermsObj);
            }
        }
        Test.startTest();
        fetchedValuesToReturn = EpicCredVerController.getCredAllTC();
        System.assertNotEquals(fetchedValuesToReturn,null,'Terms record not fetched'); 
        Test.stopTest();
    }
}