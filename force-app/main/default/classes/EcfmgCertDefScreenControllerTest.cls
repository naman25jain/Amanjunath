@isTest
public class EcfmgCertDefScreenControllerTest extends ECFMGTestFactory{
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
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Test Account'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
        System.assert(acc.id!=null, 'Account failed');
    }
    @isTest static void testAffirmationReviewRejection(){
       Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
       Account acc1 = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
       Contact conQurd = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
       Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
       User userCon = (User)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultUserTestData.class, new User(alias='eUser',email='test@usr.com',emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='Bhutan',IsActive=true,ContactId=conQurd.Id,username='test@user123.abc.com',timezonesidkey='America/Los_Angeles'));
       run();           
       String medschoolJson = '{"recordIdVal":"a112h000000WFhEAAW","numberOfYearsAttended":"4.00","otherSchool":"Test Entity","otherSchoolId":"0013C00000EU51FQAT","startMonth":"February","endMonth":"March","startYear":"2017","endYear":"2020","transferCreditsCheckbox":true}';
       String recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
       Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();
       Id credVerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
       System.runAs(userCon){
            List<Case> caselist = New List<Case>();
            Case ecfmgCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = ecfmgCertRecordTypeId,ContactId = conQurd.Id,Internal_Status__c = Constants.CASE_STATUS_FINAL_QA_COMPLETE));
            Case credVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = credVerRecordTypeId, ContactId = conQurd.Id,Internal_Status__c = Constants.CASE_STATUS_ACCEPTED));
            run();
            system.assertEquals(credVerCase.Id != null, true, 'credVerCase not created');
            Affirmation__c affr = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c( Asset_Type__c = Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA,Status__c = Constants.AFFIRMATION_STATUS_REJECTED,case__c = ecfmgCase.Id,Verification_Form_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_YES,Document_is_legible__c = 'No',Document_is_not_missing_pages__c = 'No', Document_is_not_cut_off__c = 'No', Original_Language_Document_Submitted__c = 'No',  Document_is_a_Final_Medical_Diploma__c = 'No', Diploma_Format_Acceptable__c = 'No', Degree_Title_Acceptable__c = 'No', Graduation_Year_Acceptable_for_ECFMG__c = 'No', Reject_Credential__c = true));
            Affirmation__c affrTranscript = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(Asset_Type__c = Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT, Status__c = Constants.AFFIRMATION_STATUS_REJECTED,case__c = ecfmgCase.Id, Verification_Form_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,Document_is_legible__c = 'No', Document_is_not_missing_pages__c = 'No', Document_is_not_cut_off__c = 'No', Original_Language_Document_Submitted__c = 'No',Document_is_a_Final_Medical_School_Trans__c = 'No',Transcript_Format_Acceptable__c = 'No', Degree_Title_Acceptable__c = 'No', Graduation_Year_Acceptable_for_ECFMG__c = 'No',  Curriculum_Length_Acceptable__c = 'No', Reject_Credential__c = true));
            Affirmation__c affrTct = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c( Transfer_Credit_Exception_Granted__c = false,Translation_is_complete_and_legible__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO, Asset_Type__c = Constants.AFFIRMATION_ASSET_TYPE_TCT, Status__c = Constants.AFFIRMATION_STATUS_REJECTED,case__c = ecfmgCase.Id, Verification_Form_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,Name_on_Document__c = Constants.AFFIRMATION_NAME_DOC_REQUIRES_REVIEW,TCT_Required__c = 'TCT required, not provided', Document_is_legible__c = 'No', Document_is_not_missing_pages__c = 'No', Document_is_not_cut_off__c = 'No', Original_Language_Document_Submitted__c = 'No', Document_is_a_TCT__c = 'No', Transcript_lists_all_required_courses__c = 'No', Transcript_lists_correct_dates_of_attend__c = 'No', All_courses_were_passed_at_med_school__c = 'No', Medical_school_acceptable__c = 'No', Credits_transferred_from_one_med_school__c = 'No', Reject_Credential__c = true, Translation_Required__c = 'Translation required, not provided', Translation_is_legible__c = 'No', Translation_is_not_missing_pages__c = 'No', Translation_is_not_cut_off__c = 'No', Translator_is_acceptable__c = 'No', Translation_is_of_original_document__c = 'No', Translation_is_word_for_word__c = 'No', English_Certification_Statement_accept__c = 'No', Translation_is_signed_by_the_Translator__c = 'No', Translation_is_on_the_letterhead__c = 'No', Reject_Translation__c = true));
            run();
            system.assertEquals(affr.Id != null, true, 'affr not created');
            system.assertEquals(affrTranscript.Id != null, true, 'affrTranscript not inserted');

        }
        Case credVerCase = [SELECT id FROM Case WHERE RecordTypeId =: credVerRecordTypeId];
        Case ecfmgCase = [SELECT id FROM Case WHERE RecordTypeId =: ecfmgCertRecordTypeId];
        Affirmation__c affr = [SELECT id,status__c FROM Affirmation__c WHERE case__c=:ecfmgCase.Id AND Asset_Type__c =:  Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA LIMIT 1];
        Affirmation__c affrTranscript = [SELECT id,status__c FROM Affirmation__c WHERE case__c=:ecfmgCase.Id AND Asset_Type__c =:  Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT LIMIT 1];
        Affirmation__c affrTct = [SELECT id,status__c FROM Affirmation__c WHERE case__c=:ecfmgCase.Id AND Asset_Type__c =: Constants.AFFIRMATION_ASSET_TYPE_TCT LIMIT 1];
        run();
        system.assertEquals(affrTct.Id != null, true, 'affrTct not inserted');
        Set<Id> affrIds = NEW Set<Id>();
        affrIds.add(affr.id);
        affrIds.add(affrTranscript.id);
        affrIds.add(affrTct.id);
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Id degMedRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id credIntakeRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
        Contact_Association_Type__c cat = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = 2,Credential_Type__c = 'Transcript to Document Transfer Credits', Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Credential_Type__c = 'Final Medical Diploma', Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = degMedRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = 2, Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = NULL, Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = credIntakeRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id,Credential_Type__c = 'Final Medical School Transcript' , Transfer_Credit_to_Degree_School__c = true));
        run();
        Map<String,Id> catAcctMap = new Map<String,Id>();
        List<Contact_Association_Type__c> catRecList = new List<Contact_Association_Type__c>([SELECT Id, recordTypeId, Transfer_Credit_to_Degree_School__c,Account__c,Credential_Type__c FROM Contact_Association_Type__c
                                    WHERE contact__c =: conQurd.Id  AND 
                                    (recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL OR
                                    recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE OR
                                    (Transfer_Credit_to_Degree_School__c = true AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL))]);
            for (Contact_Association_Type__c catRec : catRecList) {
            if (catRec.Credential_Type__c == 'Transcript to Document Transfer Credits') {
                catAcctMap.put('TCT', catRec.Account__c);
            }else if (catRec.Credential_Type__c == 'Final Medical Diploma'){
                catAcctMap.put('FinalDiploma', catRec.Account__c);
            }else if (catRec.Credential_Type__c == 'Final Medical School Transcript'){
               catAcctMap.put('FinalTranscript', catRec.Account__c);
            }
        }
        system.assertEquals(catList.size() != null, true, 'catList not created');
        Asset asst = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, contactId=conQurd.id,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        Id credRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        List<Asset> assList = new List<Asset>();
        Asset asst1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,case__c=credVerCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL,case__c=credVerCase.Id,Contact_Association_Type__c = cat.id));
        Asset asst3 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_TCT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_TCT,case__c=credVerCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_NAME_DOC, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_NAME_DOC,case__c=credVerCase.Id, parentid = asst3.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_TRANSLATION, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_TRANSLATION,case__c=credVerCase.Id, parentid = asst3.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        system.assertEquals(assList.size() != null, true, 'assList not created');
        Id nameRevCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NAME_REVIEW).getRecordTypeId();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTransferCreditTestData.class, new Transfer_Credit__c(Contact_Association_Type__c = cat.Id,Course_Outcome__c = 'Pass', Credits_Earned_Month__c = 'January', Credits_Earned_Year__c = '2019', Transfer_Credit_Course__c = 'MBBS', Transfer_Credit_Grade__c = '6', Applicant__c = conQurd.Id ));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTransferCreditTestData.class, new Transfer_Credit__c(Contact_Association_Type__c = cat.Id,Course_Outcome__c = 'Pass', Credits_Earned_Month__c = 'January', Credits_Earned_Year__c = '2015', Transfer_Credit_Course__c = 'MBBS', Transfer_Credit_Grade__c = '6', Applicant__c = conQurd.Id ));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTransferCreditTestData.class, new Transfer_Credit__c(Contact_Association_Type__c = cat.Id,Course_Outcome__c = 'Pass', Credits_Earned_Month__c = 'January', Credits_Earned_Year__c = '2015', Transfer_Credit_Course__c = 'MBBS', Transfer_Credit_Grade__c = '6', Applicant__c = conQurd.Id ));
        run();
        test.startTest();
        EcfmgCertAffirmationHelper.affirmationReviewRejection(affrIds);
        Id cvCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id qId = [select Id from Group where Type = 'Queue' and Name = 'Credential Review Queue' limit 1].Id;
        EcfmgCertDefScreenController.createCVCaseForDiploma(assList,ecfmgCase.Id, conQurd.Id, qId, cvCaseRecordTypeId, acc1.Id);
        test.stopTest();
    }
    @isTest static void testAffirmationReviewRejection1(){
       Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
       Account acc1 = [SELECT Id FROM Account where Name= 'Test Account'];
       Contact conQurd = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
       Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
       User userCon = (User)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultUserTestData.class, new User(alias='eUser',email='test@usr.com',emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='Bhutan',IsActive=true,ContactId=conQurd.Id,username='test@user123.abc.com',timezonesidkey='America/Los_Angeles'));
       run();
       String recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
       Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();
       Id credVerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
       System.runAs(userCon){
            List<Case> caselist = New List<Case>();
            Case ecfmgCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = ecfmgCertRecordTypeId,ContactId = conQurd.Id,Internal_Status__c = Constants.CASE_STATUS_FINAL_QA_COMPLETE));
            run();           
            system.assertEquals(ecfmgCase.Id != null, true, 'ecfmgCase not created');
            Case credVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = credVerRecordTypeId, ContactId = conQurd.Id,Internal_Status__c = Constants.CASE_STATUS_ACCEPTED));
            run();            
            system.assertEquals(credVerCase.Id != null, true, 'credVerCase not created');
        }
        Case credVerCase = [SELECT id FROM Case WHERE RecordTypeId =: credVerRecordTypeId];
        Case ecfmgCase = [SELECT id FROM Case WHERE RecordTypeId =: ecfmgCertRecordTypeId];
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Id degMedRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id credIntakeRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
        Contact_Association_Type__c cat = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = 2,Credential_Type__c = 'Transcript to Document Transfer Credits', Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Credential_Type__c = 'Final Medical Diploma', Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = degMedRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = 2, Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = NULL, Transfer_Credit_to_Degree_School__c = true));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = credIntakeRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id,Credential_Type__c = 'Final Medical School Transcript' , Transfer_Credit_to_Degree_School__c = true));
        run();
        Map<String,Id> catAcctMap = new Map<String,Id>();
        List<Contact_Association_Type__c> catRecList = new List<Contact_Association_Type__c>([SELECT Id, recordTypeId, Transfer_Credit_to_Degree_School__c,Account__c,Credential_Type__c FROM Contact_Association_Type__c
                                    WHERE contact__c =: conQurd.Id AND
                                    (recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL OR
                                    recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE OR
                                    (Transfer_Credit_to_Degree_School__c = true AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL))]);
            for (Contact_Association_Type__c catRec : catRecList) {
                if (catRec.Credential_Type__c == 'Transcript to Document Transfer Credits') {
                    catAcctMap.put('TCT', catRec.Account__c);
                }else if (catRec.Credential_Type__c == 'Final Medical Diploma'){
                    catAcctMap.put('FinalDiploma', catRec.Account__c);
                }else if (catRec.Credential_Type__c == 'Final Medical School Transcript'){
                catAcctMap.put('FinalTranscript', catRec.Account__c);
                }
            }
        system.assertEquals(catList.size() != null, true, 'catList not created');
        Asset asst = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, contactId=conQurd.id,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        Id credRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        List<Asset> assList = new List<Asset>();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,case__c=credVerCase.Id));
        Asset asst1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL,case__c=credVerCase.Id,Contact_Association_Type__c = cat.id));
        Asset asst3 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_TCT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_TCT,case__c=credVerCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_NAME_DOC, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_NAME_DOC,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_TRANSLATION, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_TRANSLATION,case__c=credVerCase.Id, parentid = asst3.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        system.assertEquals(assList.size() != null, true, 'assList not created');
        test.startTest();
        EcfmgCertDefScreenController.createVerificationCase(assList,ecfmgCase.Id,conQurd.Id,catAcctMap);
        EcfmgCertDefScreenController.updateCATidOfinalDip(catList,assList);
        EcfmgCertDefScreenController.updateCATidOfTCT(catList,assList);
        test.stopTest();
    }  
    @isTest static void testAffirmationReviewRejection2(){
       Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
       Account acc1 = [SELECT Id FROM Account where Name= 'Test Account'];
       Contact conQurd = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
       Contact conQurd1 = [Select id from Contact where FirstName= 'Test'];
       Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
       User userCon = (User)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultUserTestData.class, new User(alias='eUser',email='test@usr.com',emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='Bhutan',IsActive=true,ContactId=conQurd.Id,username='test@user123.abc.com',timezonesidkey='America/Los_Angeles'));
       run();
       String recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
       Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();
       Id credVerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
       Case ecfmgCase1;
       System.runAs(userCon){
            List<Case> caselist = New List<Case>();
            ecfmgCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = ecfmgCertRecordTypeId,ContactId = conQurd.Id,Internal_Status__c = Constants.CASE_STATUS_FINAL_QA_COMPLETE));
            run();           
            system.assertEquals(ecfmgCase1.Id != null, true, 'ecfmgCase not created');
            Case credVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = credVerRecordTypeId, ContactId = conQurd.Id,Internal_Status__c = Constants.CASE_STATUS_ACCEPTED));
            run();            
            system.assertEquals(credVerCase.Id != null, true, 'credVerCase not created');
            Affirmation__c affr = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c( Asset_Type__c = Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA,Status__c = Constants.AFFIRMATION_STATUS_REJECTED,case__c = ecfmgCase1.Id,Verification_Form_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_YES,Document_is_legible__c = 'No',Document_is_not_missing_pages__c = 'No', Document_is_not_cut_off__c = 'No', Original_Language_Document_Submitted__c = 'No',  Document_is_a_Final_Medical_Diploma__c = 'No', Diploma_Format_Acceptable__c = 'No', Degree_Title_Acceptable__c = 'No', Graduation_Year_Acceptable_for_ECFMG__c = 'No', Reject_Credential__c = true));
            run();  
            system.assertEquals(affr.Id != null, true, 'affr not created');
            Affirmation__c affrTranscript = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(Asset_Type__c = Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT, Status__c = Constants.AFFIRMATION_STATUS_REJECTED,case__c = ecfmgCase1.Id, Verification_Form_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,Document_is_legible__c = 'No', Document_is_not_missing_pages__c = 'No', Document_is_not_cut_off__c = 'No', Original_Language_Document_Submitted__c = 'No',Document_is_a_Final_Medical_School_Trans__c = 'No',Transcript_Format_Acceptable__c = 'No', Degree_Title_Acceptable__c = 'No', Graduation_Year_Acceptable_for_ECFMG__c = 'No',  Curriculum_Length_Acceptable__c = 'No', Reject_Credential__c = true));
            run();
            system.assertEquals(affrTranscript.Id != null, true, 'affrTranscript not inserted');
            Affirmation__c affrTct = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c( Transfer_Credit_Exception_Granted__c = false,Translation_is_complete_and_legible__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO, Asset_Type__c = Constants.AFFIRMATION_ASSET_TYPE_TCT, Status__c = Constants.AFFIRMATION_STATUS_REJECTED,case__c = ecfmgCase1.Id, Verification_Form_Acceptable__c = Constants.AFFIRMATION_PICKLIST_VALUE_NO,Name_on_Document__c = Constants.AFFIRMATION_NAME_DOC_REQUIRES_REVIEW,TCT_Required__c = 'TCT required, not provided', Document_is_legible__c = 'No', Document_is_not_missing_pages__c = 'No', Document_is_not_cut_off__c = 'No', Original_Language_Document_Submitted__c = 'No', Document_is_a_TCT__c = 'No', Transcript_lists_all_required_courses__c = 'No', Transcript_lists_correct_dates_of_attend__c = 'No', All_courses_were_passed_at_med_school__c = 'No', Medical_school_acceptable__c = 'No', Credits_transferred_from_one_med_school__c = 'No', Reject_Credential__c = true, Translation_Required__c = 'Translation required, not provided', Translation_is_legible__c = 'No', Translation_is_not_missing_pages__c = 'No', Translation_is_not_cut_off__c = 'No', Translator_is_acceptable__c = 'No', Translation_is_of_original_document__c = 'No', Translation_is_word_for_word__c = 'No', English_Certification_Statement_accept__c = 'No', Translation_is_signed_by_the_Translator__c = 'No', Translation_is_on_the_letterhead__c = 'No', Reject_Translation__c = true));
            run();
            cadmus_core__Doc_Config__c docConfig1 = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'PIA Template', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ECFMG_CERT').Value__c));
            run();                          
        }
        Case credVerCase = [SELECT id FROM Case WHERE RecordTypeId =: credVerRecordTypeId];
        Case ecfmgCase = [SELECT id FROM Case WHERE RecordTypeId =: ecfmgCertRecordTypeId];
        Affirmation__c affr = [SELECT id,status__c FROM Affirmation__c WHERE case__c=:ecfmgCase.Id AND Asset_Type__c =:  Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA LIMIT 1];
        Affirmation__c affrTranscript = [SELECT id,status__c FROM Affirmation__c WHERE case__c=:ecfmgCase.Id AND Asset_Type__c =:  Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT LIMIT 1];
        Affirmation__c affrTct = [SELECT id,status__c FROM Affirmation__c WHERE case__c=:ecfmgCase.Id AND Asset_Type__c =: Constants.AFFIRMATION_ASSET_TYPE_TCT LIMIT 1];
        system.assertEquals(affrTct.Id != null, true, 'affrTct not inserted');
        Set<Id> affrIds = NEW Set<Id>();
        affrIds.add(affr.id);
        affrIds.add(affrTranscript.id);
        affrIds.add(affrTct.id);
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Id degMedRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id credIntakeRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
        Contact_Association_Type__c cat = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = 2,Credential_Type__c = 'Transcript to Document Transfer Credits', Transfer_Credit_to_Degree_School__c = true   ));
        run();
        Contact_Association_Type__c cat1 = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Credential_Type__c = 'Final Medical Diploma', Transfer_Credit_to_Degree_School__c = true   ));
        run();
        Contact_Association_Type__c cat2 = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = degMedRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = 2, Transfer_Credit_to_Degree_School__c = true   ));
        run();
        Contact_Association_Type__c cat3 = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = catRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id, Number_of_Years_Attended__c = NULL, Transfer_Credit_to_Degree_School__c = true   ));
        run();
        Contact_Association_Type__c cat4 = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(RecordTypeId = credIntakeRecTypeId,Contact__c = conQurd.Id, Account__c = acc1.id,Credential_Type__c = 'Final Medical School Transcript' , Transfer_Credit_to_Degree_School__c = true   ));
        run();
        Map<String,Id> catAcctMap = new Map<String,Id>();
        List<Contact_Association_Type__c> catRecList = new List<Contact_Association_Type__c>([SELECT Id, recordTypeId, Transfer_Credit_to_Degree_School__c,Account__c,Credential_Type__c FROM Contact_Association_Type__c
                                    WHERE contact__c =: conQurd.Id AND
                                    (recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL OR
                                    recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE OR
                                    (Transfer_Credit_to_Degree_School__c = true AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL))]);
            for (Contact_Association_Type__c catRec : catRecList) {
            if (catRec.Credential_Type__c == 'Transcript to Document Transfer Credits') {
                catAcctMap.put('TCT', catRec.Account__c);
            }else if (catRec.Credential_Type__c == 'Final Medical Diploma'){
                catAcctMap.put('FinalDiploma', catRec.Account__c);
            }else if (catRec.Credential_Type__c == 'Final Medical School Transcript'){
               catAcctMap.put('FinalTranscript', catRec.Account__c);
            }
        }
        system.assertEquals(catList.size() != null, true, 'catList not created');
        Asset asst = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, contactId=conQurd.id,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        Id credRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        List<Asset> assList = new List<Asset>();
        Asset asst1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,case__c=credVerCase.Id));
        Asset asst2 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL,case__c=credVerCase.Id,Contact_Association_Type__c = cat.id));
        Asset asst3 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_TCT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_TCT,case__c=credVerCase.Id));
        Asset asst4 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_NAME_DOC, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_NAME_DOC,case__c=credVerCase.Id, parentid = asst3.id));
        Asset asst5 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_TRANSLATION, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_TRANSLATION,case__c=credVerCase.Id, parentid = asst3.id));
        Asset asst6 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM,case__c=credVerCase.Id, parentid = asst1.id));
        Asset asst7 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        Asset asst8 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        Asset asst9 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION,Type__c = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT,case__c=credVerCase.Id, parentid = asst1.id));
        Asset asst10 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA, contactId=conQurd.id,RecordtypeId = credRecordTypeId,Status = Constants.ASSET_STATUS_ACCEPTED,Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
      system.assertEquals(assList.size() != null, true, 'assList not created');
      Id nameRevCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NAME_REVIEW).getRecordTypeId();
      List<Transfer_Credit__c> tcList = new List<Transfer_Credit__c>();
      List<Transfer_Credit__c> tcList1 = new List<Transfer_Credit__c>();
      Transfer_Credit__c tc = (Transfer_Credit__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTransferCreditTestData.class, new Transfer_Credit__c(Contact_Association_Type__c = cat.Id,Course_Outcome__c = 'Pass', Credits_Earned_Month__c = 'January', Credits_Earned_Year__c = '2019', Transfer_Credit_Course__c = 'MBBS', Transfer_Credit_Grade__c = '6', Applicant__c = conQurd.Id ));
      run();
      Transfer_Credit__c tc1 = (Transfer_Credit__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTransferCreditTestData.class, new Transfer_Credit__c(Contact_Association_Type__c = cat.Id,Course_Outcome__c = 'Pass', Credits_Earned_Month__c = 'January', Credits_Earned_Year__c = '2015', Transfer_Credit_Course__c = 'MBBS', Transfer_Credit_Grade__c = '6', Applicant__c = conQurd.Id ));
      run();
      Transfer_Credit__c tc2 = (Transfer_Credit__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTransferCreditTestData.class, new Transfer_Credit__c(Contact_Association_Type__c = cat.Id,Course_Outcome__c = 'Pass', Credits_Earned_Month__c = 'January', Credits_Earned_Year__c = '2015', Transfer_Credit_Course__c = 'MBBS', Transfer_Credit_Grade__c = '6', Applicant__c = conQurd.Id ));
      run();
      tcList.add(tc);
      tcList.add(tc1);
      tcList1.add(tc2);
      String affrmTypeFD = 'FD';
      String affrmTypeFT = 'FT';
      String affrmTypeTCT = 'TCT';
      test.startTest();
      EcfmgCertAffirmationHelper.affirmationReviewRejection(affrIds);
      String medschoolJson = '{"recordIdVal":"'+tc2+'","numberOfYearsAttended":"4.00","otherSchool":"Test Entity","otherSchoolId":"'+acc1.Id+'","startMonth":"February","endMonth":"March","startYear":"2017","endYear":"2020","transferCreditsCheckbox":true}';
      System.runAs(userCon){
            EcfmgCertDefScreenController.getECFMGCertCase(conQurd.Id);
            EcfmgCertDefScreenController.getECFMGCertCase(conQurd1.Id);
            EcfmgCertDefScreenController.getMedicalSchoolWithTc(conQurd.Id);
            EcfmgCertDefScreenController.getMedicalSchoolWithTc(conQurd1.Id);
            EcfmgCertDefScreenController.checkRejectedAffirmations(ecfmgCase.Id);
            EcfmgCertDefScreenController.checkRejectedAffirmationsRefr(affr,affrTranscript,affrTct);
            EcfmgCertDefScreenController.markAssetsForDeletion(conQurd.Id);
            AppForCertHelper.OtherSchoolObjWrapper medSchObject= (AppForCertHelper.OtherSchoolObjWrapper) JSON.deserialize(medschoolJson, AppForCertHelper.OtherSchoolObjWrapper.class);
            AppForCertHelper.TcObjWrapper tcobj = new AppForCertHelper.TcObjWrapper('',acc1.id, 'MBBS','6','Pass','undefined','undefined' );
            medSchObject.tcWrapperList = new list <AppForCertHelper.TcObjWrapper>();
            medSchObject.tcWrapperList.addAll(New List< AppForCertHelper.TcObjWrapper>{tcobj}) ;
            Contact_Association_Type__c conAsso = EcfmgCertDefScreenController.createCATrec(medSchObject,ecfmgCase.Id,recordTypeDeveloperName);
            System.assert(conAsso.Id != null,'CAT is Created');
            EcfmgCertDefScreenController.getRejectedAffirmationLang(ecfmgCase.Id,affrmTypeFD);
            EcfmgCertDefScreenController.getRejectedAffirmationLang(ecfmgCase.Id,affrmTypeFT);
            EcfmgCertDefScreenController.getRejectedAffirmationLang(ecfmgCase.Id,affrmTypeTCT);
            EcfmgCertDefScreenController.resubmitCredential(ecfmgCase1.Id,conQurd.Id, medschoolJson);
            EcfmgCertDefScreenController.saveOtherMedicalSchoolsRefactorContTranCredMethod(medSchObject ,conAsso,ecfmgCase1.Id);
            test.stopTest();
        }
    }
}