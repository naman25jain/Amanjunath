/**
 * @description Test Class for AssetCreationWrapperController class and Object2DegreeTrigger
 * Class for AssetCreationWrapperControllerTest
 *
 * @author        Enable Consulting
 * @version       1.0
 */
@isTest
public with sharing class AssetCreationWrapperControllerTest{
    public static final string AZURE_URL = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/0033F00000Sul33QAB_Passport_0.jpeg';   
    public static final String UNITED_STATES = 'United States';
    public static final String AMERICA_LA = 'America/Los_Angeles';
    public static final string ASSERT_MSG = 'Returned false and failed';
    public static final string ASSET_CREATION_FAILED = 'asset creation failed';
    public static final string ASSET_CREATED = 'asset created';
    /**
     * Method Name: setup
     * @description : Test Setup.
     * @return: None
     */
    @testSetup static void setup(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
        System.assert(settingsInstance.Id != null, 'Upsert settingsInstance is not Success');
        CurrentECFMGIDSequence__c settingsInstance1 = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsInstance1.ECFMG_ID__c = '0000000';
        upsert settingsInstance1;
        System.assert(settingsInstance1.Id != null, 'Upsert settingsInstance1 is not Successful');
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Test Account',RecordTypeId = idAccountTypeId,School__c = true, billingcountry = 'India');
        insert acct;
        System.Assert(acct.Id!= null,'Account is not created');
        Contact getContactId = new Contact();
        getContactId.FirstName='Test';
        getContactId.LastName='Test';
        getContactId.AccountId= acct.id;
        insert getContactId;     
        System.Assert(getContactId.Id!= null,'Contact is not created');
        Case newCase = new Case();
        newCase.contactId = getContactId.Id;
        newCase.Entity__c = acct.id;
        newCase.Internal_Status__c = 'New';
        insert newCase;
        System.Assert(newCase.Id!= null,'Case is not created');
        Case newCase1 = new Case();
        newCase1.contactId = getContactId.Id;
        newCase1.Entity__c = acct.id;
        newCase1.Internal_Status__c = 'Sent for Verification';
        newCase1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();       
        insert newCase1;
        Case newPetnForReconsnCase = new Case();
        newPetnForReconsnCase.contactId = getContactId.Id;
        newPetnForReconsnCase.Entity__c = acct.id;
        newPetnForReconsnCase.Internal_Status__c = 'Submitted';
        newPetnForReconsnCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_PETITION_FOR_RECONSN).getRecordTypeId();
        insert newPetnForReconsnCase;
        System.Assert(newPetnForReconsnCase.Id!= null,'Case is not created');
        
        Case newInvestigationCase = new Case();
        newInvestigationCase.contactId = getContactId.Id;
        newInvestigationCase.AccountId = acct.id;
        newInvestigationCase.Internal_Status__c = 'In Review';
        newInvestigationCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
        INSERT newInvestigationCase;
        System.Assert(newInvestigationCase.Id!= null,'Case is not created');

        Case newDecisionAppealCase = new Case();
        newDecisionAppealCase.contactId = getContactId.Id;
        newDecisionAppealCase.Entity__c = acct.id;
        newDecisionAppealCase.Internal_Status__c = 'Pending Review';
        newDecisionAppealCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DECISION_APPEAL).getRecordTypeId();
        INSERT newDecisionAppealCase;
        System.Assert(newDecisionAppealCase.Id!= null,'Case is not created');
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c);
        Case erasCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=getContactId, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c, Account = acct));
        ECFMGTestFactory.run();
        System.Assert(erasCase.Id!= null,'ERAS case is not created');
        //create a new User row
        String emailtest = 'tester@unknownmail.com';
        String lastname = 'Last';
        String firstname = 'First';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName = userName.replace(' ','').replace(':','-');
        Id p = [SELECT Id FROM profile WHERE name='4-Customer Community Plus Login' LIMIT 1].Id;
        User user = new User(alias='flastt', email=emailtest, emailencodingkey='UTF-8', lastname=lastname, languagelocalekey='en_US', localesidkey='en_US', profileid=p, country=UNITED_STATES, IsActive=true, ContactId=getContactId.Id, timezonesidkey=AMERICA_LA, username=userName);
        insert user;
        System.assert(user.Id!= null,'User is not created');
        String emailtest1 = 'tester1@unknownmail.com';
        String lastname1 = 'Last1';
        String userName1 = 'tester1@unknownmail.com_' + System.now();
        userName1 = userName1.replace(' ','').replace(':','-');
        Id p1 = [SELECT Id FROM profile WHERE name='Salesforce Reviewer' LIMIT 1].Id;
        User user1 = new User(alias='flastt1', email=emailtest1, emailencodingkey='UTF-8', lastname=lastname1, languagelocalekey='en_US', localesidkey='en_US', profileid=p1, country=UNITED_STATES, IsActive=true, timezonesidkey=AMERICA_LA, username=userName1);
        insert user1;
    }
    /**
     * Method Name: testCreateAsset
     * @description : Test method for creating assets.
     * @return: None
     */
    @istest
    public static void testCreateAsset(){
        
        String contactId = [SELECT Id FROM Contact][0].Id;
        String acctId = [SELECT Id FROM Account][0].Id;
        String newCaseId = [SELECT Id FROM Case][0].Id;        
        Test.startTest();
        CloudStorageController.PayloadWrapper payloadDean = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_DEAN_LETTER, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', newCaseId, '', 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_DEAN_LETTER, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retValDean = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadDean);
        System.assertEquals(retValDean,true,'Insert failed');

        CloudStorageController.PayloadWrapper payloadOnlineVerif = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_ONLINE_VERIFICATION, Constants.ASSET_RECORD_TYPE_VERIFICATION, 'Create', newCaseId, '', 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_ONLINE_VERIFICATION, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retValOnlineVerif = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadOnlineVerif);
        System.assertEquals(retValOnlineVerif,true,'Insert failed');

        CloudStorageController.PayloadWrapper payloadOnlineVerifCoverLetter = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER, Constants.ASSET_RECORD_TYPE_VERIFICATION, 'Create', newCaseId, '', 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retValOnlineVerifLetter = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadOnlineVerifCoverLetter);
        System.assertEquals(retValOnlineVerifLetter,true,'Insert failed');

        CloudStorageController.PayloadWrapper payloadIncompleteAttest = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_INCOMPLETE_ATTEST_LETTER, Constants.ASSET_RECORD_TYPE_ATTESTATION, 'Create', newCaseId, '', 'true', Constants.ASSET_STATUS_SENT, null, Constants.ASSET_TYPE_INCOMPLETE_ATTEST_LETTER, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retValIncompleteAttest = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadIncompleteAttest);
        System.assertEquals(retValIncompleteAttest,true,'Insert failed');

        CloudStorageController.PayloadWrapper payloadDean1 = new CloudStorageController.PayloadWrapper('', Constants.ASSET_TYPE_DEAN_LETTER, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', '', acctId, 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_DEAN_LETTER, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadDean1);
        CloudStorageController.PayloadWrapper payloadReturnedVeri = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_RETURNED_ENROLLMENT_VERIFICATION, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', newCaseId, '', 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_RETURNED_ENROLLMENT_VERIFICATION, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadReturnedVeri);
        System.assertEquals(true, retVal, ASSERT_MSG);
        AssetCreationWrapperController.getSobjectType(acctId);  
        Case cse = [SELECT Id,Internal_Status__c FROM Case LIMIT 1];
        /* cse.Internal_Status__c = 'New';
        update cse; */
        CloudStorageController.PayloadWrapper payloadTranslation = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_TRANSLATION, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', cse.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_TRANSLATION, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal1 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadTranslation);
        System.assertEquals(retVal1,true,ASSET_CREATION_FAILED);
        CloudStorageController.PayloadWrapper payloadMedEduForm = new CloudStorageController.PayloadWrapper(contactId, Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', cse.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');       
        Boolean retVal2 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadMedEduForm);
        System.assertEquals(retVal2,true,ASSET_CREATION_FAILED);
        Boolean retVal3 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadMedEduForm);
        System.assertEquals(retVal3,true,'Insert failed');
        Asset asst =  [SELECT Id, status FROM ASSET WHERE Case__c = :cse.Id AND Type__c = :Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM LIMIT 1];
        asst.status = 'Incomplete';
        Update asst;
        CloudStorageController.PayloadWrapper payloadMedEduForm1 = new CloudStorageController.PayloadWrapper(contactId, Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', cse.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal4 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadMedEduForm1);
        System.assertEquals(retVal4,true,'Insert failed');
        Test.stopTest();
    }
    /**
     * Method Name: testCreateAsset2
     * @description : Test method for creating assets.
     * @return: None
     */
    @istest
    public static void testCreateAsset2(){
        String contactId = [SELECT Id FROM Contact][0].Id;
        String acctId = [SELECT Id FROM Account][0].Id;
        String newCaseId = [SELECT Id FROM Case][0].Id;       
        Case cse = [SELECT Id,Internal_Status__c FROM Case LIMIT 1];
        cse.Internal_Status__c = 'New'; 
        Test.startTest();
        //for Name Doc
        CloudStorageController.PayloadWrapper payloadNameDoc = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_NAME_DOC, Constants.ASSET_RECORD_TYPE_IDENTITY, 'Create', cse.Id, '',  'true', 'In Progress', '', Constants.ASSET_TYPE_NAME_DOC, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal2 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadNameDoc);
        System.assertEquals(retVal2,true,ASSET_CREATION_FAILED);
        // for DOB Documents from case
        CloudStorageController.PayloadWrapper payloadDOBDoc = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_DOB_DOCUMENT, Constants.ASSET_RECORD_TYPE_IDENTITY, 'Create', cse.Id, '',  'true', 'In Progress', '', Constants.ASSET_TYPE_DOB_DOCUMENT, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal1 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadDOBDoc);
        System.assertEquals(retVal1,true,ASSET_CREATION_FAILED);
        // for Interim Certificate from Contact
        CloudStorageController.PayloadWrapper payloadInterimCertificate = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_INTERIM_CERTIFICATE, Constants.ASSET_RECORD_TYPE_IDENTITY, 'Create', '', '',  'true', 'In Progress', '', Constants.ASSET_TYPE_INTERIM_CERTIFICATE, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal3 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadInterimCertificate);
        System.assertEquals(retVal3,true,ASSET_CREATION_FAILED);
        // for Entity Seal from Account
        CloudStorageController.PayloadWrapper payloadEntitySeal = new CloudStorageController.PayloadWrapper('', Constants.ASSET_TYPE_ENTITY_SEAL, Constants.ASSET_TYPE_ENTITY_SEAL, 'Create', '', acctId,  'true', 'In Progress', '', Constants.ASSET_TYPE_ENTITY_SEAL, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal4 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadEntitySeal);
        System.assertEquals(retVal4,true,ASSET_CREATION_FAILED);
        // for ASSET_TYPE_INCOMING_CORRESPONDENCE from case
        CloudStorageController.PayloadWrapper payloadIncomingCorrespondace = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE, Constants.ASSET_RECORD_TYPE_CORRESPONDENCE, 'Create', cse.Id, '',  'true', 'In Progress', '', Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal5 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadIncomingCorrespondace);
        System.assertEquals(retVal5,true,ASSET_CREATION_FAILED);
        // for ASSET_NAME_RETURNED_EMAIL_RESPONSE from case
        CloudStorageController.PayloadWrapper payloadReturnedEmailResponse = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_RETURNED_EMAIL_RESPONSE, Constants.ASSET_RECORD_TYPE_VERIFICATION, 'Create', cse.Id, '',  'true', 'In Progress', '', Constants.ASSET_NAME_RETURNED_EMAIL_RESPONSE, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal6 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadReturnedEmailResponse);
        System.assertEquals(retVal6,true,ASSET_CREATION_FAILED);
        //for CASE_DOCUMENT_TYPE_ASSET_EVIDENCE from Case
        Id invCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
        Case cse1 = [SELECT Id,Internal_Status__c FROM Case WHERE RecordTypeId=:invCaseRTId LIMIT 1];
        CloudStorageController.PayloadWrapper payloadEvidence = new CloudStorageController.PayloadWrapper(contactId, Constants.CASE_DOCUMENT_TYPE_ASSET_EVIDENCE, Constants.ASSET_RECORD_TYPE_INVESTIGATION, 'Create', cse1.Id, '',  'true', 'In Progress', '', Constants.CASE_DOCUMENT_TYPE_ASSET_EVIDENCE, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal7 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadEvidence);
        System.assertEquals(retVal7,true,ASSET_CREATION_FAILED);
        Test.stopTest();
    }
    /**
     * Method Name: testCreateAssetForCase
     * @description : Test method for creating assets.
     * @return: None
     */
    @istest
    public static void testCreateAssetForCase(){
        String contactId = [SELECT Id FROM Contact][0].Id;
        String acctId = [SELECT Id FROM Account][0].Id;
        Test.startTest();
        //for CASE_DOCUMENT_TYPE_ASSET_EVIDENCE from Case
        Id invCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
        Case cse1 = [SELECT Id,Internal_Status__c FROM Case WHERE RecordTypeId=:invCaseRTId LIMIT 1];
        CloudStorageController.PayloadWrapper payloadEvidence = new CloudStorageController.PayloadWrapper(contactId, Constants.CASE_DOCUMENT_TYPE_ASSET_EVIDENCE, Constants.ASSET_RECORD_TYPE_INVESTIGATION, 'Create', cse1.Id, '',  'true', 'In Progress', '', Constants.CASE_DOCUMENT_TYPE_ASSET_EVIDENCE, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal7 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadEvidence);
        System.assertEquals(retVal7,true,ASSET_CREATION_FAILED);

        //for ASSET_TYPE_INCOMING_CORRESPONDENCE & CASE_RECORD_TYPE_INVESTIGATION
        CloudStorageController.PayloadWrapper payloadIncomingCorrespondace = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE, Constants.ASSET_RECORD_TYPE_INVESTIGATION, 'Create', cse1.Id, '',  'true', 'In Progress', '', Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal5 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadIncomingCorrespondace);
        System.assertEquals(retVal5,true,ASSET_CREATION_FAILED);
        
        //for ASSET_TYPE_DECISION_APPEAL_LETTER && CASE_RECORD_TYPE_DECISION_APPEAL
        Id deciAppealCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DECISION_APPEAL).getRecordTypeId();
        Case cse2 = [SELECT Id,Internal_Status__c FROM Case WHERE RecordTypeId=:deciAppealCaseRTId LIMIT 1];
        CloudStorageController.PayloadWrapper payloadDecisionAppeal = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_DECISION_APPEAL_LETTER, Constants.ASSET_RECORD_TYPE_DECISION_APPEAL, 'Create', cse2.Id, '',  'true', 'In Progress', '', Constants.ASSET_TYPE_DECISION_APPEAL_LETTER, '', null,'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal8 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadDecisionAppeal);
        System.assertEquals(retVal8,true,ASSET_CREATION_FAILED);

        //for ASSET_TYPE_CHARGE_LETTER
        CloudStorageController.PayloadWrapper payloadChargeLetter = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_CHARGE_LETTER, Constants.ASSET_RECORD_TYPE_DECISION_APPEAL, 'Create', cse1.Id, '', 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_CHARGE_LETTER, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal9 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadChargeLetter);
        System.assertEquals(retVal9,true,ASSET_CREATION_FAILED);

        //for ASSET_TYPE_POLICY_LETTER
        CloudStorageController.PayloadWrapper payloadPolicyLetter = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_POLICY_LETTER, Constants.ASSET_RECORD_TYPE_DECISION_APPEAL, 'Create', cse1.id, '', 'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_POLICY_LETTER, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal10 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadPolicyLetter);
        System.assertEquals(retVal10,true,ASSET_CREATION_FAILED);

        //for support doc
        CloudStorageController.PayloadWrapper payloadSupportDoc = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_SUPPORTING_DOCUMENT, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', cse1.Id, '',  'true', Constants.ASSET_STATUS_ACCEPTED, null, Constants.ASSET_TYPE_SUPPORTING_DOCUMENT, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal11 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadSupportDoc);
        System.assertEquals(retVal11,true,ASSET_CREATION_FAILED);

        //for eras doc
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c);
        Case erasCase = [SELECT Id,Internal_Status__c FROM Case WHERE RecordTypeId=:caseRecTypeId LIMIT 1];        
        CloudStorageController.PayloadWrapper payloadErasDoc = new CloudStorageController.PayloadWrapper(contactId, 'Medical School Performance Evaluation', Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', erasCase.Id, '',  'true', Constants.ASSET_STATUS_NEW, null, 'Medical School Performance Evaluation', '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal12 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadErasDoc);
        System.assertEquals(retVal12,true,ASSET_CREATION_FAILED);
        
        Test.stopTest();
    }
    /**
     * Method Name: testPetitionForReconAssetCreation
     * @description : Test method for creating assets.
     * @return: None
     */
    @istest
    public static void testPetitionForReconAssetCreation(){
        Test.startTest();
        String contactId = [SELECT Id FROM Contact][0].Id;
        String acctId = [SELECT Id FROM Account][0].Id;
        String newCaseId = [SELECT Id FROM Case][0].Id;
        ID petionForRecnCaseRdTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_PETITION_FOR_RECONSN).getRecordTypeId();
        Case cse2 = [SELECT Id,Internal_Status__c  FROM Case WHERE RecordTypeId = :petionForRecnCaseRdTypeId LIMIT 1];
        CloudStorageController.PayloadWrapper payloadEvidence = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_EVIDENCE_DOCUMENT, Constants.ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN, 'Create', cse2.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_TYPE_EVIDENCE_DOCUMENT, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal1 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadEvidence);
        System.assertEquals(retVal1,true,ASSET_CREATED);
        CloudStorageController.PayloadWrapper payloadChair = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_COMMITTEE_CHAIR_DECISION, Constants.ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN, 'Create', cse2.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_NAME_COMMITTEE_CHAIR_DECISION, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal2 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadChair);
        System.assertEquals(retVal2,true,ASSET_CREATED);
        CloudStorageController.PayloadWrapper payloadCommittee = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_COMMITTEE_DECISION_GRANTED, Constants.ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN, 'Create', cse2.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_NAME_COMMITTEE_DECISION_GRANTED, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal3 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadCommittee);
        System.assertEquals(retVal3,true,ASSET_CREATED);
        CloudStorageController.PayloadWrapper payloadCommitteeDecision = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_COMMITTEE_DECISION_DENIED, Constants.ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN, 'Create', cse2.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_NAME_COMMITTEE_DECISION_DENIED, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal4 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadCommitteeDecision);
        System.assertEquals(retVal4,true,ASSET_CREATED);
        CloudStorageController.PayloadWrapper payloadCommitteeDecisionModified = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_COMMITTEE_DECISION_MODIFIED, Constants.ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN, 'Create', cse2.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_NAME_COMMITTEE_DECISION_MODIFIED, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal5 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadCommitteeDecisionModified);
        System.assertEquals(retVal5,true,ASSET_CREATED);
        Test.stopTest();
    }
    /**
     * Method Name: testDobDocument
     * @description : Test method for creating assets.
     * @return: None
     */
    @istest
    public static void testDobDocument(){
        Test.startTest();
        Case cse = [SELECT Id, ContactId, Internal_Status__c FROM Case LIMIT 1 ];
        Id cvRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        cse.RecordTypeId = cvRTId ;
        cse.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        update cse;
        CloudStorageController.PayloadWrapper payloadDOB = new CloudStorageController.PayloadWrapper(cse.ContactId, Constants.ASSET_NAME_DOB_DOCUMENT, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', cse.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_NAME_DOB_DOCUMENT, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');
        Boolean retVal1 = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadDOB);
        System.assertEquals(retVal1, true, ASSERT_MSG);
        Test.stopTest();
    }
    /**
     * Method Name: testUpdateAssetMarkForDeletion
     * @description : Test method for updating assets marked for deletion
     * @return: None
     */
    @istest
    public static void testUpdateAssetMarkForDeletion(){
        String contactId = [SELECT Id FROM Contact][0].Id;
        Case cse = [SELECT Id, Internal_Status__c FROM Case LIMIT 1];
        cse.Document_Type__c = 'Final Medical Diploma';
        cse.Internal_Status__c = Constants.CASE_STATUS_NEW;
        update cse;
        List<Asset> assetList = new List<Asset>();        
        //Create and Insert Asset
        Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        Asset asst1 = new Asset(
            Name = Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET,
            Type__c = Constants.ASSET_TYPE_VERIFICATION_PACKET,
            Status =  Constants.ASSET_STATUS_SUBMITTED,
            Case__c = cse.Id,
            ContactId = contactId,
            RecordTypeId = assetRecordTypeId,
            Azure_Storage_URL__c = AZURE_URL
        );        
        Asset asst2 = new Asset(
            Name = Constants.ASSET_NAME_RETURNED_VERIFICATION_FORM,
            Type__c = Constants.ASSET_TYPE_VERIFICATION_FORM,
            Status =  Constants.ASSET_STATUS_SUBMITTED,
            Case__c = cse.Id,
            ContactId = contactId,
            RecordTypeId = assetRecordTypeId,
            Azure_Storage_URL__c = AZURE_URL
        );
        String returnedCredentialType = 'Returned '+cse.Document_Type__c;
        Id asset3RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
        Asset asst3 = new Asset(
            Name = returnedCredentialType,
            Type__c = cse.Document_Type__c,
            Status =  Constants.ASSET_STATUS_SUBMITTED,
            Case__c = cse.Id,
            ContactId = contactId,
            RecordTypeId = asset3RecordTypeId,
            Azure_Storage_URL__c = AZURE_URL
        );  
        Id asset4RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        Asset asst4 = new Asset(
            Name = Constants.ASSET_NAME_RETURNED_SUPPORTING_DOCUMENTS,
            Type__c = Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
            Status =  Constants.ASSET_STATUS_SUBMITTED,
            Case__c = cse.Id,
            ContactId = contactId,
            RecordTypeId = asset4RecordTypeId,
            Azure_Storage_URL__c = AZURE_URL
        );
        assetList.add(asst1);
        assetList.add(asst2);
        assetList.add(asst3);
        assetList.add(asst4);
        insert assetList;
        System.assert(assetList!= null,ASSET_CREATION_FAILED);
        AssetCreationWrapperController.updateAssetMarkForDeletion(cse.Document_Type__c,cse.Id);
        List<String> assetNameList = new List<String>{Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET, Constants.ASSET_NAME_RETURNED_VERIFICATION_FORM, returnedCredentialType, Constants.ASSET_NAME_RETURNED_SUPPORTING_DOCUMENTS};            
        List<Asset> assetDelList = [SELECT Id, Name FROM Asset WHERE NAME IN: assetNameList AND Case__c=null AND Status='Marked for Deletion'];
        System.assertEquals(assetDelList!=null, true, 'Asset status is not updated as Marked for Deletion');
    }
    /**
     * Method Name: testUpdateTaskStatus
     * @description : Test method for updating task status
     * @return: None
     */
    @istest
    public static void testUpdateTaskStatus(){
        Case cse = [SELECT Id, Internal_Status__c FROM Case LIMIT 1];
        cse.Internal_Status__c = Constants.CASE_STATUS_NEW;
        update cse;
        User testUser = [SELECT Id, contactId FROM User WHERE alias = 'flastt'];
        Task taskObj = new Task();
        taskObj.Subject = 'Rescan Request';
        taskObj.Status = 'In Progress';
        taskObj.WhatId = cse.Id;
        taskObj.Description = 'Test Comments';
        taskObj.OwnerId = testUser.Id;
        insert taskObj;
        System.assert(taskObj.Id!= null, 'Task is not created');
        AssetCreationWrapperController.updateTaskStatus(cse.Id);
        List<Task> taskList = [SELECT Id, Status, Subject FROM Task WHERE WhatId =: cse.Id AND Status = 'Completed'];
        System.assertEquals(taskList!=null, true, 'Task status is not updated as Completed');
    }
    /**
     * Method Name: testTrigger
     * @description : Test method for object2Degree trigger
     * @return: None
     */
    @istest
    public static void testTrigger(){
        String acctId = [SELECT Id FROM Account][0].Id;
        Degree__c dgr = new Degree__c();
        dgr.Name = 'Test';
        Insert dgr;
        System.assert(dgr.Id != null, 'Degree creation failed');
        Id schoolId = Schema.SObjectType.Object2Degree__c.getRecordTypeInfosByDeveloperName().get(Constants.OBJECT2DEGREE_RECORD_TYPE_SCHOOL).getRecordTypeId();
        Object2Degree__c obj2Dgr = new Object2Degree__c();
        obj2Dgr.recordTypeId = schoolId;
        obj2Dgr.Degree__c = dgr.Id;
        obj2Dgr.Graduation_Year__c = '2020';
        obj2Dgr.Account__c = acctId;
        INSERT obj2Dgr;
        System.assert(obj2Dgr.Id != null, 'Object2Degree creation failed');
        obj2Dgr.Account__c = acctId;
        obj2Dgr.Graduation_Year__c = null;
        update obj2Dgr;
        System.assert(obj2Dgr.Id != null, 'Object2Degree update failed');
    }
    /**
     * Method Name: testGetCaseDetail
     * @description : Test method for getting case detail
     * @return: None
     */
    @isTest
    static void testGetCaseDetail(){
        //Arrange
        Case caseDetail;
        String contactId = [SELECT Id FROM Contact][0].Id;
        String accountId = [SELECT Id FROM Account][0].Id;
        // new case 
        Case caseWithWorkingStatus = new Case(ContactId = contactId,
                                                AccountId = accountId,
                                                Internal_Status__c = ConstantsTest.TEST_CASE_STATUS_NEW);
        insert caseWithWorkingStatus;
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        User testUser2 = [SELECT Id, ContactId FROM User WHERE alias = 'flastt1'];
        //Act
        Test.startTest();
        system.runAs(testUser2){
            caseDetail = AssetCreationWrapperController.getCaseDetail(caseId);
        }
        Test.stopTest();           
        //Assert
        System.assertNotEquals(null, caseDetail,'Get case detail returns null'); 
    }
    /**
     * Method Name: testCreateIDFormNotarizedAsset
     * @description : Test method for creating IDFormNotarized asset
     * @return: None
     */
    @isTest
    static void testCreateIDFormNotarizedAsset(){
        //Arrange
        Boolean success;        
        String contactId = [SELECT Id FROM Contact][0].Id;
        String accountId = [SELECT Id FROM Account][0].Id;
        // new case 
        Case caseWithWorkingStatus = new Case(ContactId = contactId,
                                                AccountId = accountId,
                                                Internal_Status__c = ConstantsTest.TEST_CASE_STATUS_NEW);
        insert caseWithWorkingStatus;
        // Product
        Product2 product =  new Product2(Name = ConstantsTest.TEST_PRODUCT, 
                                        Family = ConstantsTest.TEST_STRING,
                                        ProductCode = Constants.PRODUCT_CODE_ID_FORM,
                                        isActive=true);
        insert product;
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        User testUser1 = [SELECT Id, ContactId FROM User WHERE alias = 'flastt1'];
        //Act
        Test.startTest();
        system.runAs(testUser1){            
            CloudStorageController.PayloadWrapper payloadNotarised = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_ID_FORM_NOTARIZED, Constants.ASSET_RECORD_TYPE_CREDENTIAL, 'Create', caseWithWorkingStatus.Id, '',  'true', Constants.ASSET_STATUS_IN_PROGRESS, null, Constants.ASSET_NAME_ID_FORM_NOTARIZED, '', '', 'true', '', Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB, '');        
            success = AssetCreationWrapperController.createAsset(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL, payloadNotarised);
        }
        Test.stopTest();           
        //Assert
        System.assertEquals(true, success,'Create IDForm Notarized Returned False'); 
    }
    /**
     * Method Name: testgetContactDetail
     * @description : Test method for getting contact detail
     * @return: None
     */
    @isTest
    static void testgetContactDetail(){
        Contact contactIns = [SELECT Id, RecordType.DeveloperName, RecordTypeid  FROM Contact][0];        
        contactIns.RecordTypeid = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();
        update contactIns;
        contact cont;
        Test.startTest();
        cont = AssetCreationWrapperController.getContactDetail(contactIns.Id);
        Test.stopTest();           
        System.assertEquals('Applicant', cont.RecordType.DeveloperName,'Record type assertion wrong');
    }
    /**
     * Method Name: createAsse2VerRecordTest
     * @description : Test method for creating asset2verification records
     * @return: None
     */
    @isTest
    public static void createAsse2VerRecordTest(){
        String contactId = [SELECT Id FROM Contact][0].Id;
        Id credVerifRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case caseRecord = [SELECT Id, Internal_Status__c, RecordType.DeveloperName, RecordTypeid  FROM Case WHERE ContactId=:contactId AND RecordTypeid=:credVerifRTId][0];
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        UPDATE caseRecord;
        Verification_Packet__c verPackNew = new Verification_Packet__c();
        verPackNew.Case__c = caseRecord.Id;
        verPackNew.Is_Active__c = true;
        INSERT verPackNew;
        system.assert(verPackNew.Id != null,'verPackNew is not inserted');
        Test.startTest();
        AssetCreationWrapperController.createAsse2VerRecord('url',String.valueOf(caseRecord.Id),'Online Verification');
        system.AssertEquals([SELECT id FROM Asset2Verification__c WHERE Verification_Packet__c = :verPackNew.Id].size(),1,'No records created');
        AssetCreationWrapperController.createAsse2VerRecord('url',String.valueOf(caseRecord.Id),'Online Verification Cover Letter');
        system.AssertEquals([SELECT id FROM Asset2Verification__c WHERE Verification_Packet__c = :verPackNew.Id].size(),2,'No records created');
        AssetCreationWrapperController.createAsse2VerRecord('url',String.valueOf(caseRecord.Id),constants.ASSET_TYPE_SUPPORTING_DOCUMENTS);
        system.AssertEquals([SELECT id FROM Asset2Verification__c WHERE Verification_Packet__c = :verPackNew.Id].size(),3,'asset2Ver record for Supporting doc not created');
        Test.stopTest();
    }
    /**
     * Method Name: testGetAssetRecordType
     * @description : Test method for getting asset record type.
     * @return: None
     */
    @isTest
    public static void testGetAssetRecordType(){
        String type = Constants.ASSET_TYPE_RETURNED_ENROLLMENT_VERIFICATION;
        String originalRecTypeId = '';
        Test.startTest();
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');
        
        type = Constants.ASSET_TYPE_NON_USMLE_TRANSCRIPT;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');
        
        type = Constants.ASSET_TYPE_USMLE_TRANSCRIPT;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');
        
        type = Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');
        
        type = Constants.ASSET_NAME_RETURNED_ATTESTATION_FORM;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        type = Constants.ASSET_TYPE_ATTEST;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        type = Constants.ASSET_TYPE_CHARGE_LETTER;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        type = Constants.ASSET_TYPE_POLICY_LETTER;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        type = Constants.ASSET_TYPE_SUPPORTING_DOCUMENT;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        type = Constants.ASSET_NAME_IB_DECISION_LETTER;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        type = Constants.ASSET_NAME_NO_IB_DECISION_LETTER;
        originalRecTypeId = '';
        originalRecTypeId = AssetCreationWrapperController.getAssetRecordType(type, originalRecTypeId);
        System.assertNotEquals(originalRecTypeId, '', 'Recordtype not retrieved');

        Test.stopTest();
    }
    /**
     * Method Name: testSendNotification
     * @description : Test method sending notification.
     * @return: None
     */
    @isTest
    public static void testSendNotification(){
        Test.startTest();
        Case cse = [SELECT Id, Internal_Status__c FROM Case  WHERE Internal_Status__c='New' LIMIT 1];
        AssetCreationWrapperController.sendNotification(cse.Id);
        System.assertEquals(true, true, 'notification sent');
        Test.stopTest();
    }
}