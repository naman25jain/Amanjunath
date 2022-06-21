@isTest
public class CredIntakeDefScreenControllerTest extends ECFMGTestFactory{
        
        public static final String RejectedReason = 'RJ Reasons';
        public static final String StudentMedical = 'Student Medical School Transcript';
        public static final String ChngDocType = 'Change Document Type';
        public static final String SpecialQual = 'Specialist Qualification';
    
    @testSetup static void setup(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        UPSERT settingsInstance;
        System.assert(settingsInstance.Entity_ID__c != null, 'settingsInstance updation failed');
        CurrentECFMGIDSequence__c settingsInstanceEcfmgId = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsInstanceEcfmgId.ECFMG_ID__c = '0000001';
        UPSERT settingsInstanceEcfmgId;
        System.assert(settingsInstanceEcfmgId.ECFMG_ID__c != null, 'settingsInstanceEcfmgId updation failed');
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Applicant', RecordTypeId=applRecTypeId,Email = 'test1@test.com', Account = acc));
        run();
        Id profId1 = [SELECT id FROM profile WHERE name='4-Customer Community Plus Login' LIMIT 1].id;
        User user2 = (User)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultUserTestData.class, new User(alias = 'testUsr1',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId1,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testUserapp@test.com'));
        run();
        System.assert(user2.Id != null, 'user2 creation failed');
    }
    
    @isTest
    static void updateCredentialsTest(){
        Contact con = [SELECT Id,AccountId FROM Contact WHERE Email = 'test1@test.com'];
        User usr = [SELECT Id FROM User WHERE username = 'testUserapp@test.com'];
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id assetRecTypeCredential = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id assetRecTypeIdentity = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
        Case credVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class,new Case(
        RecordTypeId = credVerRecTypeId,
        ContactId = con.Id,
        Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE,
        Document_type_selected_by_applicant__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
        Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        System.assert(credVerCase.Id != null, 'Case creation failed');
        Case credVerCase2 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class,new Case(
        RecordTypeId = credVerRecTypeId,ContactId = con.Id,Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE,
        Document_type_selected_by_applicant__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT));
        run();
        System.assert(credVerCase2.Id != null, 'Case2 creation failed');
        Affirmation__c affr = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class,new Affirmation__c(
        Credential_Evaluation_Status__c = Constants.AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE,Translation_Evaluation_Status__c = Constants.AFFIRMATION_TRANSL_EVAL_STATUS_ACCEPTED,Document_is_not_acceptable_for_the_Clien__c = false,
        Case__c = credVerCase.Id));
        run();
        System.assert(affr.Id != null, 'Affr creation failed');
        Affirmation__c affr2 = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class,new Affirmation__c(
        Credential_Evaluation_Status__c = Constants.AFFIRMATION_CRED_EVAL_STATUS_ACCEPTED,
        Translation_Evaluation_Status__c = Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE,
        Case__c = credVerCase2.Id));
        run();
        System.assert(affr2.Id != null, 'Affr2 creation failed');
        Contact_Association_Type_Staging__c cats = (Contact_Association_Type_Staging__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,new Contact_Association_Type_Staging__c(
        Contact__c = con.Id,
        Case__c = credVerCase.Id,
        Account__c = con.AccountId));
        run();
        System.assert(cats.Id != null, 'Cats creation failed');
        Asset asst = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class,new Asset(
        Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST,
        RecordTypeId = assetRecTypeCredential,
        Case__c = credVerCase.Id,
        ContactId = con.Id,
        Azure_Storage_URL__c = 'testUrl',
        Status = Constants.IN_PROGRESS));
        run();
        System.assert(asst.Id != null, 'asst creation failed');
        Asset asst1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class,new Asset(
        Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST,
        RecordTypeId = assetRecTypeCredential,
        ContactId = con.Id,
        Azure_Storage_URL__c = 'testUrl1',
        Status = Constants.IN_PROGRESS));
        run();
        System.assert(asst1.Id != null, 'asst1 creation failed');
        Asset asst2  = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class,new Asset(
        Name = Constants.ASSET_TYPE_NAME_DOC,
        RecordTypeId = assetRecTypeIdentity,
        ContactId = con.Id,
        Azure_Storage_URL__c = 'testUrl2',
        Status = Constants.IN_PROGRESS));
        run();
        System.assert(asst2.Id != null, 'asst2 creation failed');
        Asset asst3 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class,new Asset(
        Name = Constants.ASSET_NAME_CRED_TYPE_TRANSLATION,
        RecordTypeId = assetRecTypeCredential,
        ContactId = con.Id,
        Azure_Storage_URL__c = 'testUrl3',
        Status = Constants.IN_PROGRESS));
        run();
        System.assert(asst3.Id != null, 'asst3 creation failed');
        CredIntakeDefScreenController.CredUploadWrapper wrapper = new CredIntakeDefScreenController.CredUploadWrapper();
        wrapper.credUrl = 'testUrl1';
        wrapper.transUrl = 'testUrl2';
        wrapper.nameUrl = 'testUrl3';
        wrapper.nameOnDoc = 'Test';
        wrapper.nameDifferent = true;
        wrapper.translationRequired = true;
        wrapper.caseId = credVerCase.Id;
        Test.startTest();
        System.runAs(usr){
            String docType = CredIntakeDefScreenController.getDocType(credVerCase.Id);
            System.assertEquals(Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, docType, 'Document type wrong');
            String evalStatus = CredIntakeDefScreenController.getEvalStatus(credVerCase.Id);
            System.assertEquals('credIncomplete', evalStatus, 'Evaluation status is not credUpload');
            String evalStatus2 = CredIntakeDefScreenController.getEvalStatus(credVerCase2.Id);
            System.assertEquals('transIncomplete', evalStatus2, 'Evaluation status is not transUpload');
            Boolean result = CredIntakeDefScreenController.updateCredentials(JSON.serialize(wrapper));
            System.assertEquals(true, result, 'Credentials not updated');
            Boolean docNotAccForClient = CredIntakeDefScreenController.getDocNotAcceptableForClient(credVerCase.Id);
            System.assertEquals(false, docNotAccForClient, 'Document not acceptable for client is True');
            List<String> pickListValues = CredIntakeDefScreenController.getPicklistValues();
            System.assertEquals(3, pickListValues.size(), 'Picklist values size is not 3');
            Case updatedCase = [SELECT Id, Internal_Status__c FROM Case WHERE id =:credVerCase.Id];
            System.assertEquals(Constants.CASE_STATUS_RESUBMITTED_PENDING_REVIEW, updatedCase.Internal_Status__c, 'Case status not updated');
            Asset updatedAsset = [SELECT Id, Case__c FROM Asset WHERE id =:asst1.Id];
            System.assertEquals(credVerCase.Id, updatedAsset.Case__c, 'Asset parent Case not updated');
            Asset updatedAsset2 = [SELECT Id, Status FROM Asset WHERE id =:asst.Id];
            System.assertEquals(Constants.ASSET_STATUS_OUTDATED, updatedAsset2.Status, 'Asset Status not updated as Outdated');
        }
        Test.stopTest();
    }
    @isTest
    static void credDefScreenLangTest(){
        User user1 = [SELECT Id FROM User WHERE username = 'testUserapp@test.com'];
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test1@test.com'];
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case idVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class,new Case(
        RecordTypeId = idVerRecTypeId,
        ContactId = con.Id,
        Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION,
        Document_type_selected_by_applicant__c = 'Final Medical Diploma',
        Document_Type__c = 'Final Medical Diploma'));
        run();
        System.assert(idVerCase.Id != null, 'Case - creation failed');
        Id idCVRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        affirmation__c affr = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class,new affirmation__c(
        Translation_Evaluation_Status__c = Constants.AFFIRMATION_INCOMPLETE,
        Entity_Evaluation_Status__c = Constants.CASE_STATUS_REJECTED,
        Credential_Evaluation_Status__c = Constants.AFFIRMATION_INCOMPLETE,        
        Change_Document_Type_Action__c = 'Request a New Document from Applicant',
        case__c = idVerCase.Id,
        RecordTypeId = idCVRecTypeId,
        Translation_Required__c= Constants.AFFIRMATION_TRANSLATION_REQUIRED_NOT_PROVIDED,
        Translation_is_legible__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_missing_pages__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_cut_off__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translator_is_acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_of_original_document__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_word_for_word__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        English_Certification_Statement_accept__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_signed_by_the_Translator__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_on_the_letterhead__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Reject_Translation__c= TRUE,
        Document_is_legible__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_missing_pages__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_cut_off__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Original_Language_Document_Submitted__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Title_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Graduation_Year_Acceptable_for_ECFMG__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_acceptable_for_the_Clien__c= TRUE,
        Reject_Credential__c= TRUE,
        Applicant_Request__c= Constants.AFFIRMATION_PICKLIST_VALUE_YES,
        Curriculum_Length_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_a_TCT__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_all_required_courses__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_correct_dates_of_attend__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        All_courses_were_passed_at_med_school__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Medical_school_acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Credits_transferred_from_one_med_school__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Rejection_Reason__c= RejectedReason,
        Not_acceptable_for_Client_Reason__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Confirms_that_Diploma_has_not_issued__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_is_present__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_in_the_future__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Program_Duration_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Program_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Licensure_Type_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Program_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO));      
        run();
        Test.startTest();
        System.runAs(user1){            
            List<String> defVal = new List<String>();
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);            
            idVerCase.Document_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = 'Transcript to Document Transfer Credits';
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = Constants.ASSET_NAME_DEAN_LETTER;
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = StudentMedical;
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = Constants.CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL;
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = 'Medical Registration Certificate/License to Practice Medicine';
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = SpecialQual;
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = 'Pregraduate Internship Certificate';
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE;
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            idVerCase.Document_Type__c = 'Certificate of Good Standing';
            UPDATE idVerCase;
            defVal = CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.Id);
            System.assert(defVal.size() > 0, 'Deficiency Language not present');
            idVerCase.Document_type_selected_by_applicant__c = StudentMedical;
            idVerCase.Document_Type__c = StudentMedical;
            UPDATE idVerCase;      
            affr.Change_Document_Type_Action__c = ChngDocType; 
            UPDATE affr;
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
            idVerCase.Document_type_selected_by_applicant__c = SpecialQual;
            idVerCase.Document_Type__c = SpecialQual;
            UPDATE idVerCase;      
            affr.Change_Document_Type_Action__c = ChngDocType; 
            UPDATE affr;
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
        }
        Test.stopTest();
    }
    @isTest
    static void credVerfRejectedDefScreenLangTest(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test1@test.com'];
        User user1 = [SELECT Id FROM User WHERE username = 'testUserapp@test.com'];
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case idVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class,new Case(
        RecordTypeId = idVerRecTypeId,
        ContactId = con.Id,
        Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION,
        Document_type_selected_by_applicant__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,
        Document_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT));
        run();
        System.assert(idVerCase.Id != null, 'Case creation failed 1');
        Id idCVRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        affirmation__c affr = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class,new affirmation__c(
        Translation_Evaluation_Status__c = Constants.AFFIRMATION_INCOMPLETE,
        Entity_Evaluation_Status__c = Constants.CASE_STATUS_REJECTED,
        Credential_Evaluation_Status__c = Constants.AFFIRMATION_INCOMPLETE,        
        Change_Document_Type_Action__c = 'Change Document Type',
        case__c = idVerCase.Id,
        RecordTypeId = idCVRecTypeId,
        Translation_Required__c= Constants.AFFIRMATION_TRANSLATION_REQUIRED_NOT_PROVIDED,
        Translation_is_legible__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_missing_pages__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_cut_off__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translator_is_acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_of_original_document__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_word_for_word__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        English_Certification_Statement_accept__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_signed_by_the_Translator__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_on_the_letterhead__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Reject_Translation__c= TRUE,
        Document_is_legible__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_missing_pages__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_cut_off__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Original_Language_Document_Submitted__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Title_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Graduation_Year_Acceptable_for_ECFMG__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_acceptable_for_the_Clien__c= TRUE,
        Reject_Credential__c= TRUE,
        Applicant_Request__c= Constants.AFFIRMATION_PICKLIST_VALUE_YES,
        Curriculum_Length_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_a_TCT__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_all_required_courses__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_correct_dates_of_attend__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        All_courses_were_passed_at_med_school__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Medical_school_acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Credits_transferred_from_one_med_school__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Rejection_Reason__c= RejectedReason,
        Not_acceptable_for_Client_Reason__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Confirms_that_Diploma_has_not_issued__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_is_present__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_in_the_future__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Program_Duration_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Program_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Licensure_Type_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Program_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO)); 
        run();           
        Test.startTest();
        System.assert(affr.Id != null, 'affirmation creation failed');          
        System.runAs(user1){         
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
        }
        idVerCase.Document_type_selected_by_applicant__c = 'Alternate Graduation Document';
        idVerCase.Document_Type__c = 'Alternate Graduation Document';
        Update idVerCase;
        affr.Change_Document_Type_Action__c = 'Change Document Type'; 
        UPDATE affr;
        System.runAs(user1){         
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
        }
        idVerCase.Document_type_selected_by_applicant__c = Constants.ASSET_NAME_DEAN_LETTER;
        idVerCase.Document_Type__c = Constants.ASSET_NAME_DEAN_LETTER;
        UPDATE idVerCase;
        affr.Change_Document_Type_Action__c = 'Change Document Type'; 
        UPDATE affr;
        System.runAs(user1){         
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
        }
        affr.Change_Document_Type_Action__c = 'Document cannot be verified by ECFMG'; 
        UPDATE affr;
        System.assert(affr.Change_Document_Type_Action__c  != null, 'affirmation update failed');  
        System.runAs(user1){         
            defValMethod(idVerCase);
        }
        Test.stopTest();
    }
    @isTest
    static void RejectedDefScreenLangTest(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test1@test.com'];
        User user1 = [SELECT Id FROM User WHERE username = 'testUserapp@test.com'];
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case idVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class,new Case(
        RecordTypeId = idVerRecTypeId,
        ContactId = con.Id,
        Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION,
        Document_type_selected_by_applicant__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
        Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        System.assert(idVerCase.Id != null, 'Case creation - failed 1');
        Id idCVRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        affirmation__c affr = (affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class,new affirmation__c(
        Translation_Evaluation_Status__c = Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE,
        Credential_Evaluation_Status__c = Constants.AFFIRMATION_STATUS_REJECTED,       
        Change_Document_Type_Action__c = 'Change Document Type',
        case__c = idVerCase.Id,
        RecordTypeId = idCVRecTypeId,
        Translation_Required__c = Constants.AFFIRMATION_TRANSLATION_REQUIRED_NOT_PROVIDED,
        Translation_is_legible__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_missing_pages__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_cut_off__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translator_is_acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_of_original_document__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_word_for_word__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        English_Certification_Statement_accept__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_signed_by_the_Translator__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_on_the_letterhead__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Reject_Translation__c = TRUE,
        Document_is_legible__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_missing_pages__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_cut_off__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Original_Language_Document_Submitted__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Title_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Graduation_Year_Acceptable_for_ECFMG__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_acceptable_for_the_Clien__c = TRUE,
        Reject_Credential__c = TRUE,
        Applicant_Request__c = Constants.AFFIRMATION_PICKLIST_VALUE_YES,
        Curriculum_Length_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_a_TCT__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_all_required_courses__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_correct_dates_of_attend__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        All_courses_were_passed_at_med_school__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Medical_school_acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Credits_transferred_from_one_med_school__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Rejection_Reason__c = RejectedReason,
        Not_acceptable_for_Client_Reason__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Confirms_that_Diploma_has_not_issued__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_is_present__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_in_the_future__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Program_Duration_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Program_is_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Licensure_Type_is_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Program_is_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO));      
        run();
        Test.startTest();
        System.runAs(user1){
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
            defValMethod(idVerCase);
        }
        idVerCase.Document_type_selected_by_applicant__c = Constants.CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL;
        idVerCase.Document_Type__c = Constants.CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL;
        UPDATE idVerCase;
        affr.Change_Document_Type_Action__c = ChngDocType; 
        UPDATE affr;
        System.runAs(user1){         
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
        }
        idVerCase.Document_type_selected_by_applicant__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE;
        idVerCase.Document_Type__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE;
        UPDATE idVerCase;
        affr.Change_Document_Type_Action__c = ChngDocType; 
        UPDATE affr;
        System.runAs(user1){         
            CredIntakeDefScreenController.getCredIntakeDefLang(idVerCase.id);
        }
        Test.stopTest();
    }
    public static void defValMethod(Case idVerCase){
        List<String> defVal = new List<String>();
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);           
        idVerCase.Document_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Final Medical School Transcript Failed');             
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = 'Transcript to Document Transfer Credits';             
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Transcript to Document Transfer Credits Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = Constants.ASSET_NAME_DEAN_LETTER;
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Letter from Dean Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = StudentMedical;
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Student Medical School Transcript Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = Constants.CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL;
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Postgraduate Training Credential Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = 'Medical Registration Certificate/License to Practice Medicine';
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Medical Registration Certificate Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = SpecialQual;
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Specialist Qualification Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = 'Pregraduate Internship Certificate';
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Pregraduate Internship Certificate Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE;
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Advanced Degree in the Medical Sciences Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);  
        idVerCase.Document_Type__c = 'Certificate of Good Standing';
        UPDATE idVerCase;
        System.assert(idVerCase.Document_Type__c != null, 'Certificate of Good Standing Failed');
        defVal = CredVerfRejectedDefScreen.getCredVerfDefLang(idVerCase.Id);          
    }
    
    @isTest
    public static void incompleteAssetTest(){
        Id assetRecTypeCredential = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Account acc = [SELECT Id FROM ACCOUNT LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test1@test.com'];
        User user1 = [SELECT Id FROM User WHERE username = 'testUserapp@test.com'];
        Test.startTest();
        Id idVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case idVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class,new Case(
        RecordTypeId = idVerRecTypeId,
        ContactId = con.Id,
        Internal_Status__c = Constants.CASE_STATUS_CV_INCOMPLETE,
        Document_type_selected_by_applicant__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE,
        Document_Type__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE));
        run();
        System.assert(idVerCase.Id != null, 'Case creation - failed');
        Contact_Association_Type_Staging__c cats = (Contact_Association_Type_Staging__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,new Contact_Association_Type_Staging__c(
        Contact__c = con.Id,
        Case__c = idVerCase.Id,
        Account__c = acc.Id));
        run();       
        System.assert(cats.Id != null, 'Cats creation failed');
        Asset asst = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class,new Asset(
        Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST,
        RecordTypeId = assetRecTypeCredential,
        Case__c = idVerCase.Id,
        ContactId = con.Id,
        Azure_Storage_URL__c = 'testUrl',
        Status = Constants.IN_PROGRESS,
        Uploaded_by_applicant__c = true,
        Contact_Association_Type_Staging__c = cats.Id,
        Type__c = Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE));
        run();
        System.assert(user1.Id != null, 'User creation failed');  
        Id idCVRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        affirmation__c affr = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class,new affirmation__c(
        Translation_Evaluation_Status__c = Constants.AFFIRMATION_INCOMPLETE,
        Credential_Evaluation_Status__c = Constants.AFFIRMATION_INCOMPLETE,        
        Change_Document_Type_Action__c = 'Request a New Document from Applicant',
        case__c = idVerCase.Id,
        RecordTypeId = idCVRecTypeId,  
        Translation_Required__c= Constants.AFFIRMATION_TRANSLATION_REQUIRED_NOT_PROVIDED,
        Translation_is_legible__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_missing_pages__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_not_cut_off__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translator_is_acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_of_original_document__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_word_for_word__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        English_Certification_Statement_accept__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_signed_by_the_Translator__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Translation_is_on_the_letterhead__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Reject_Translation__c= TRUE,
        Document_is_legible__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_missing_pages__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_cut_off__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Original_Language_Document_Submitted__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Title_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Graduation_Year_Acceptable_for_ECFMG__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_not_acceptable_for_the_Clien__c= TRUE,
        Reject_Credential__c= TRUE,
        Applicant_Request__c= Constants.AFFIRMATION_PICKLIST_VALUE_YES,
        Curriculum_Length_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Document_is_a_TCT__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_all_required_courses__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Transcript_lists_correct_dates_of_attend__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        All_courses_were_passed_at_med_school__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Medical_school_acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Credits_transferred_from_one_med_school__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Rejection_Reason__c= RejectedReason,
        Not_acceptable_for_Client_Reason__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Confirms_that_Diploma_has_not_issued__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_is_present__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Expected_Degree_Issue_Date_in_the_future__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Program_Duration_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Program_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Specialty_Licensure_Type_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO,
        Degree_Program_is_Acceptable__c= Constants.AFFIRMATION_PICKLIST_VALUE_NO));     
        run();
        System.runAs(user1){            
            List<CloudStorageController.PayloadWrapper> incompAsset = new List<CloudStorageController.PayloadWrapper>();
            incompAsset = CredIntakeDefScreenController.getIncompleteAssets(idVerCase.Id);  
            System.assert(incompAsset.size() > 0, 'recent incomplete assets not present');
        }
        Test.stopTest();
    }
}