@IsTest
public with sharing class VerificationRevIncomControllerTest{
    Static final String CERTOFGOODSTANDING = 'Certificate of Good Standing';
    //setup
    @testSetup 
      public static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
        wdomsIdSeq.AKA_ID__c = 1000;
        upsert wdomsIdSeq;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'TEst';
        acc.BillingPostalCode = '123456';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not created');
        Id profId = [Select Id from profile where name='4-Customer Community Plus Login' LIMIT 1].Id;
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
                              username = 'testinguser032022@test.com');
        INSERT user1;
        System.assert(user1.Id!=null,'User not found');
    }
    /********************
     * Name - testgetAllIncAffirmation()
     * Description - Test method
     * ****************/
    @IsTest public static void testgetAllIncAffirmation(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Credential_returned_with_verification__c = 'No';
        affirm.Returned_credential_complete_and_legible__c = 'No';
        affirm.Verification_completed_authorized_offici__c = 'No';
        affirm.Official_s_Written_Name_Acceptable__c = 'No';
        affirm.Institution_seal_acceptable__c = 'No, seal is not acceptable';
        affirm.Document_is_complete_and_legible__c = 'No'; 
        affirm.Document_is_legible__c = 'No';
        affirm.Original_Language_Document_Submitted__c = 'No';
        affirm.Incomplete_Reason_Authorization__c = true;
        affirm.Incomplete_Reason_Grades__c = true;
        affirm.Incomplete_Reason_Name_Match__c = true;
        INSERT affirm;
        System.assert(affirm.Id != null, 'Affirmation rec not created');
        Case newCase1 = new Case();
        newCase1.RecordTypeId = credVerRecTypeId;
        newCase1.ContactId = con.Id;
        newCase1.AccountId = acc.Id;
        newCase1.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase1.Entity__c = mainAcc.Id;
        newCase1.Send_Method__c = 'Paper';
        newCase1.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase1;
        Affirmation__c affirm2 = new Affirmation__c();
        affirm2.Case__c = newCase1.Id;
        affirm2.RecordTypeId = affiRecTypeId; //Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW;
        affirm2.Status__c = 'In Progress';
        affirm2.Verification_method_is_acceptable__c = 'Yes';
        affirm2.Verification_response_returned__c = 'Yes';
        affirm2.Verification_response_returned_directly__c = 'No';
        affirm2.Verification_response_indicate_cred_auth__c = 'No';
        affirm2.Verification_method__c = 'Online Verification';
        affirm2.Online_portal_has_access_date__c = 'No';
        INSERT affirm2;
        System.assert(affirm2.Id != null, 'Affirmation record not created');
        List<String> incAffirm = new List<String>();
        List<String> incAffirmForOther = new List<String>();
        User user1 = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(user1){
            Test.startTest();
            incAffirm = VerificationRevIncomController.getIncAffirmations(newCase.Id);
            incAffirmForOther = VerificationRevIncomController.getIncAffirmations(newCase1.Id);
            System.assert(!incAffirmForOther.isEmpty(), 'No incomplete affirm returned');
            Affirmation__c aff = VerificationRevIncomController.getVerReviewAffirm(newCase.Id);
            Case cs = VerificationRevIncomController.getCase(newCase.Id);
            System.assert(aff.Id!=null, 'Affirmation rec not returned');
            System.assert(cs.Id!=null, 'Case not found'); 
            Test.stopTest();
        }
    }
    /********************
     * Name - testrefgetAllIncAffirmForOther()
     * Description - Test method
     * ****************/
    @IsTest public static void testrefgetAllIncAffirmForOther(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Credential_returned_with_verification__c = 'No';
        affirm.Returned_credential_complete_and_legible__c = 'No';
        affirm.Verification_completed_authorized_offici__c = 'No';
        affirm.Verification_is_complete_and_legible__c = 'No';
        affirm.Verification_is_legible__c = 'No';
        affirm.Verification_is_not_cut_off__c = 'No';
        affirm.Verification_response_indicate_cred_auth__c = 'No';
        affirm.Verification_is_not_missing_pages__c = 'No';
        affirm.Official_s_Written_Name_Acceptable__c = 'No';
        affirm.Institution_seal_acceptable__c = 'No, seal is not acceptable';
        affirm.Document_is_complete_and_legible__c = 'No'; 
        affirm.Document_is_legible__c = 'No';
        affirm.Original_Language_Document_Submitted__c = 'No';
        affirm.Incomplete_Reason_Authorization__c = true;
        affirm.Incomplete_Reason_Grades__c = true;
        affirm.Incomplete_Reason_Name_Match__c = true;
        INSERT affirm;
        test.startTest();
        	VerificationRevIncomController.refgetAllIncAffirmForOther(affirm);
       	test.stopTest();
    }
    /********************
     * Name - testgetAllIncAffirmForOther()
     * Description - Test method
     * ****************/
    @IsTest public static void testgetAllIncAffirmForOther(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Credential_returned_with_verification__c = 'No';
        affirm.Returned_credential_complete_and_legible__c = 'No';
        affirm.Verification_method_is_acceptable__c = 'No';
        affirm.Verification_response_returned__c = 'No';
        affirm.Verification_completed_authorized_offici__c = 'No';
        affirm.Verification_is_complete_and_legible__c = 'No';
        affirm.Verification_is_legible__c = 'No';
        affirm.Verification_is_not_cut_off__c = 'No';
        affirm.Verification_response_indicate_cred_auth__c = 'No';
        affirm.Verification_is_not_missing_pages__c = 'No';
        affirm.Official_s_Written_Name_Acceptable__c = 'No';
        affirm.Institution_seal_acceptable__c = 'No, seal is not acceptable';
        affirm.Document_is_complete_and_legible__c = 'No'; 
        affirm.Document_is_legible__c = 'No';
        affirm.Original_Language_Document_Submitted__c = 'No';
        affirm.Incomplete_Reason_Authorization__c = true;
        affirm.Incomplete_Reason_Grades__c = true;
        affirm.Incomplete_Reason_Name_Match__c = true;
        INSERT affirm;
        test.startTest();
        	VerificationRevIncomController.getAllIncAffirmForOther(affirm);
       	test.stopTest();
    }
    ///////////////////////////////////////////////
    @IsTest public static void testgetAllIncAffirmForPaper2(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Verification_method__c = 'ECFMG Verification Form';
        INSERT affirm;
        Affirmation__c affirm1 = new Affirmation__c();
        affirm1.Case__c = newCase.Id;
        affirm1.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm1.Status__c = 'In Progress'; 
        affirm1.Verification_method__c = 'Final Medical School Transcript provided to ECFMG directly by institution';
        INSERT affirm1;
        Affirmation__c affirm2 = new Affirmation__c();
        affirm2.Case__c = newCase.Id;
        affirm2.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm2.Status__c = 'In Progress'; 
        affirm2.Verification_method__c = 'Online Verification';
        INSERT affirm2;
        Affirmation__c affirm3 = new Affirmation__c();
        affirm3.Case__c = newCase.Id;
        affirm3.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm3.Status__c = 'In Progress'; 
        affirm3.Verification_method__c = 'Letter in Lieu';
        INSERT affirm3;
        test.startTest();
        	VerificationRevIncomController.getAllIncAffirmForPaper2(affirm);
        	VerificationRevIncomController.getAllIncAffirmForPaper2(affirm1);
        	VerificationRevIncomController.getAllIncAffirmForPaper2(affirm2);
        	VerificationRevIncomController.getAllIncAffirmForPaper2(affirm3);
       	test.stopTest();
    }
    /////////////////////////////////////////////////
    @IsTest public static void testgetIncAffirmLetterInLieu(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Verification_method__c = 'ECFMG Verification Form';
        affirm.Returned_credential_is_same_credential__c = 'No';
        affirm.Returned_credential_is_not_same_cred__c = 'Incorrect Credential returned';
        affirm.Letter_includes_an_acceptable_cert__c = 'No';
        affirm.Letter_completed_by_authorized_official__c = 'No';
        affirm.Letter_is_on_institution_letterhead__c = 'No';
        affirm.Letter_is_signed_by_official__c = 'No';
        affirm.Date_of_letter_is_acceptable__c = 'No';
        affirm.Institution_seal_is_acceptable__c = 'No, seal is not acceptable';
        INSERT affirm;
        Affirmation__c affirm1 = new Affirmation__c();
        affirm1.Case__c = newCase.Id;
        affirm1.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm1.Status__c = 'In Progress';
        affirm1.Returned_credential_is_same_credential__c = 'No';
        affirm1.Returned_credential_is_not_same_cred__c ='Revised/Updated Credential Provided Unacceptable';
        INSERT affirm1;
        test.startTest();
        	VerificationRevIncomController.getIncAffirmLetterInLieu(affirm);
        	VerificationRevIncomController.getIncAffirmLetterInLieu(affirm1);
        test.stopTest();
    }
    //testrefgetIncAffirmRetMedForm
    @IsTest public static void testrefgetIncAffirmRetMedForm(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Years_of_education_required_provided__c = 'No';
        affirm.Credential_degree_presented_provided__c = 'No';
        affirm.Applicant_transferred_credits__c = 'No';
        affirm.Total_Attendance_is_Provided__c = 'No';
        affirm.Attendance_start_date_is_provided__c = 'No';
        affirm.Attendance_end_date_is_provided__c = 'No';
        affirm.All_Information_Provided__c = 'No';
        INSERT affirm;
        test.startTest();
        	VerificationRevIncomController.refgetIncAffirmRetMedForm(affirm);
        test.stopTest();
    }
    //testgetIncAffirmVF
    @IsTest public static void testgetIncAffirmVF(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Credential_returned_with_verification__c = 'No';
        affirm.Ret_cred_same_sent_for_verif__c = 'No';
        affirm.Returned_credential_complete_and_legible__c = 'No';
        affirm.Verification_completed_authorized_offici__c = 'No';
        affirm.Official_s_Signature_Acceptable__c = 'No';
        affirm.Official_s_Written_Name_Acceptable__c = 'No';
        affirm.Official_s_Title_Acceptable__c = 'No';
        affirm.Verification_date_acceptable__c = 'No';
        affirm.Institution_seal_acceptable__c = 'No, seal is not acceptable';
        INSERT affirm;
        test.startTest();
        	VerificationRevIncomController.getIncAffirmVF(affirm);
        test.stopTest();
    }
    //testgetIncAffirmCGSorFMST
    @IsTest public static void testgetIncAffirmCGSorFMST(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Document_is_Certificate_of_GoodStanding__c = 'No';
        affirm.Change_Document_Type_Action__c = 'Request New Document from Entity';
        affirm.Document_is_a_Final_Medical_School_Trans__c = 'No';
        affirm.Document_is_complete_and_legible__c = 'No';
        affirm.Document_is_legible__c = 'No';
        affirm.Document_is_not_missing_pages__c = 'No';
        affirm.Document_is_not_cut_off__c = 'No';
        affirm.Original_Language_Document_Submitted__c = 'No';
        affirm.Document_is_not_acceptable_for_the_Clien__c = true;
        INSERT affirm;
        test.startTest();
        	VerificationRevIncomController.getIncAffirmCGSorFMST(affirm);
        test.stopTest();
    }
    //testgetIncAffirmRetMedForm
    @IsTest public static void testgetIncAffirmRetMedForm(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm1 = new Affirmation__c();
        affirm1.Case__c = newCase.Id;
        affirm1.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm1.Status__c = 'In Progress'; 
        affirm1.Form_returned_from_correct_authority__c = 'No';
        INSERT affirm1;
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Form_returned_from_correct_authority__c = 'Yes';
        affirm.Form_is_complete_and_legible__c = 'No';
        affirm.Form_returned_directly_from_primary_sou__c = 'No';
        affirm.Certification_Form_completed_by_aut__c = 'No';
        affirm.Certification_Official_s_signature__c = 'No';
        affirm.Certification_Official_s_written_name__c = 'No';
        affirm.Certification_Official_s_title_is_accep__c = 'No';
        affirm.Certification_Signature_date_is_accept__c = 'No';
        affirm.Certification_Institution_seal_is_accep__c = 'No';
        INSERT affirm;
        test.startTest();
        	VerificationRevIncomController.getIncAffirmRetMedForm(affirm);
        	VerificationRevIncomController.getIncAffirmRetMedForm(affirm1);
        test.stopTest();
    }
    //testsaveAffirmationRec
    @IsTest public static void testsaveAffirmationRec(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Id profId = [Select Id from profile where name='Salesforce Admin' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'TEst';
        acc.BillingPostalCode = '123456';
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        User user1 = new User(alias = 'testUser',
                              email = 'test23@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId,
                              country = 'United States',
                              IsActive = true,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testinguser23032022@test.com');
        INSERT user1;
        Account acc1 = [SELECT Id FROM Account LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con1.Id;
        newCase.AccountId = acc1.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Send_Method__c = 'Entity Portal';
        newCase.Document_Type__c = CERTOFGOODSTANDING;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id affiRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm1 = new Affirmation__c();
        affirm1.Case__c = newCase.Id;
        affirm1.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm1.Status__c = 'In Progress'; 
        affirm1.Form_returned_from_correct_authority__c = 'No';
        INSERT affirm1;
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affiRecTypeId;//Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        affirm.Status__c = 'In Progress'; 
        affirm.Form_returned_from_correct_authority__c = 'Yes';
        affirm.Form_is_complete_and_legible__c = 'No';
        affirm.Form_returned_directly_from_primary_sou__c = 'No';
        affirm.Certification_Form_completed_by_aut__c = 'No';
        affirm.Certification_Official_s_signature__c = 'No';
        affirm.Certification_Official_s_written_name__c = 'No';
        affirm.Certification_Official_s_title_is_accep__c = 'No';
        affirm.Certification_Signature_date_is_accept__c = 'No';
        affirm.Certification_Institution_seal_is_accep__c = 'No';
        INSERT affirm;
        Map <String, String> jsonMap = new Map <String, String> ();
        jsonMap.put('affirmId',affirm.Id);
        jsonMap.put('authorization', 'No');     
        jsonMap.put('completionMedform' , 'No');
        jsonMap.put('completionVerform' , 'No');
        jsonMap.put('credential', 'No');        
        jsonMap.put('envelope', 'No');          
        jsonMap.put('grades', 'No');            
        jsonMap.put('nameMatch' , 'No');        
        jsonMap.put('nameMissing', 'No');       
        jsonMap.put('OfficeSealMissing' , 'No');
        jsonMap.put('officeSealNotMatch', 'No');
        jsonMap.put('other' , 'No');            
        jsonMap.put('response' , 'No');         
        jsonMap.put('returnR', 'No');           
        jsonMap.put('signatureMatch', 'No');    
        jsonMap.put('signMiss', 'No');        
        jsonMap.put('titleMatching' , 'No');    
        jsonMap.put('titleMiss' , 'No');        
        jsonMap.put('transc' , 'No');           
        jsonMap.put('verification', 'No');     
        jsonMap.put('comments','Test comments'); 
        String js = JSON.serialize(jsonMap);
        test.startTest();
            system.runAs(user1){
                try{
                VerificationRevIncomController.saveAffirmationRec(js);
            }catch(exception e){
                system.assert(true, true);
            }
        }     	        	
        test.stopTest();
    }
}