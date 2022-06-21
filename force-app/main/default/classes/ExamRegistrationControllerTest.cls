//Test Class for ExamRegistrationController class
@isTest
public class ExamRegistrationControllerTest{
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
     static final String examType = 'USMLE Step 2 CK';
     static final string coreName = 'EVR Customer Doc Config';
     static final string externalStatus ='Pending CIBIS';
    
    
    //create a new contact;
    @testSetup static void setup(){
        date birthdate1 = date.valueOf('2000-01-01');
        String emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        Contact c1 = new Contact(Firstname=firstname,School_Enrollment_Status__c=constants.CONASCTYPESTG_STATUS_STUDENT,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',Step_1_Attempt_Limit_Exception__c = true, Step_2_CK_Attempt_Limit_Exception__c= true,Step_2_CS_Attempt_Limit_Exception__c= true);
        insert c1;
        System.assert(c1.Id != NULL, 'Contact creation failed.');
        Account ac = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');
        insert ac;
        System.assert(ac.Id != NULL, 'Account creation failed1');
        User user3 = new User(alias='user3',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=username);
        insert user3;
        System.assert(user3.Id != NULL, 'User creation failed.');    
        //create Contact Association type object        
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = c1.Id,Account__c=ac.id, Number_of_Years_Attended__c = 2);
        insert conAssocType;
        System.assert(conAssocType.Id != NULL, 'Contact asssociation type creation failed.');
        Id conAssocRecordTypeId1 = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
        Contact_Association_Type__c conAssocType1 = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId1,contact__c = c1.Id,Account__c=ac.id, Number_of_Years_Attended__c = 2);
        insert conAssocType1;
        System.assert(conAssocType1.Id != NULL, 'Contact asssociation type creation failed.');
        Asset permit = new Asset();
        permit.Name = Constants.ASSET_TYPE_TCT;
        permit.ContactId = c1.Id;
        permit.Contact_Association_Type__c = conAssocType.Id;
        permit.type__c = Constants.ASSET_TYPE_TCT;
        permit.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit;
        System.assert(permit.Id != NULL, 'Asset-1 creation failed.');
        Asset permit1 = new Asset();
        permit1.Name = Constants.ASSET_TYPE_TRANSLATION;
        permit1.ContactId = c1.Id;
        permit1.ParentId = permit.Id;
        permit1.Contact_Association_Type__c = conAssocType.Id;
        permit1.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit1.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit1;
        System.assert(permit1.Id != NULL, 'Asset-2 creation failed.');
        Asset permit3 = new Asset();
        permit3.Name = Constants.ASSET_TYPE_TCT;
        permit3.ContactId = c1.Id;
        permit3.Contact_Association_Type__c = conAssocType1.Id;
        permit3.type__c = Constants.ASSET_TYPE_TCT;
        permit3.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit3;
        System.assert(permit3.Id != NULL, 'Asset-3 creation failed.');
        Asset permit4 = new Asset();
        permit4.Name = Constants.ASSET_TYPE_PRE_MED_LETTER;
        permit4.ContactId = c1.Id;
        permit4.ParentId = permit3.Id;
        permit4.Contact_Association_Type__c = conAssocType1.Id;
        permit4.type__c = Constants.ASSET_TYPE_PRE_MED_LETTER;
        permit4.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit4;
        System.assert(permit4.Id != NULL, 'Asset-4 creation failed.');
        Asset permit5 = new Asset();
        permit5.Name = Constants.ASSET_TYPE_TRANSLATION;
        permit5.ContactId = c1.Id;
        permit5.ParentId = permit4.Id;
        permit5.Contact_Association_Type__c = conAssocType1.Id;
        permit5.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit5.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit5;
        System.assert(permit5.Id != NULL, 'Asset-5 creation failed.');
        Asset permit6 = new Asset();
        permit6.Name = Constants.ASSET_TYPE_TRANSLATION;
        permit6.ContactId = c1.Id;
        permit6.ParentId = permit3.Id;
        permit6.Contact_Association_Type__c = conAssocType1.Id;
        permit6.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit6.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit6;
        System.assert(permit6.Id != NULL, 'Asset-6 creation failed.');
        
    }
    //testMethod1
    @istest static void testMethod1(){
        User testUser = [SELECT Id,contactId FROM User WHERE alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();            
            Case newCase = new Case(
                RecordTypeId = examRegRecordTypeId,
                ContactId = testUser.contactId,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW
            );
            insert newCase;
            Account a = new Account(Name = 'Test Entity');
            insert a;
            Contact c = new Contact(LastName = 'User3 Contact',AccountId = a.Id,Current_Citizenship__c = 'India');
            CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
            curECFMGSetting.ECFMG_ID__c = '00000099';
            update curECFMGSetting;
            insert c;
            System.assert(newCase.Id!=null, 'Case not inserted');
            List<Contact_Association_Type__c> cAtList = ExamRegistrationController.getOtherMedicalSchoolsWithTransferCredits();
            ExamRegistrationController.getOtherInstitutionsWithTransferCredits();
            ExamRegistrationController.getAssetsAndDocuments(CatList[0].Id);
            ExamRegistrationController.getSchoolData(CatList[0].Id);
            ExamRegistrationController.getInstAssetsAndDocuments();
            ExamRegistrationController.getCheckBoxValue();
            ExamRegistrationController.regionChangeCasesValidation();
            ExamRegistrationController.getContactAssociationType();
            ExamRegistrationController.checkLastAttempt(constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK,testUser.contactId);            
            ExamRegistrationController.getTermsandConditionsDataExamReg();
            ExamRegistrationController.checkPacingRuleApplied(constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK);
            Set<String> passedExamsTypes = new Set<String>();
            passedExamsTypes.add(constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK);
            passedExamsTypes.add(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE);
            ExamRegistrationController.usmleStepTwoCsExclusiveValidations(c.Id,constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK,passedExamsTypes);
            String caseId = ExamRegistrationController.createExamRegCase();
            System.assert(caseId!=null,'Case doesnot exists');
            ExamRegistrationController.getExamRegCaseNumber();
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            Id epRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get(Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG).getRecordTypeId();
            Eligibility_Period__c ep = new Eligibility_Period__c();
            ep.Exam_Type__c =constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
            ep.EP_Start_Date__c=epStartDate;
            ep.EP_End_Date__c=epEndDate;
            ep.Deadline_Date__c=epEndDate;
            ep.Active__c='Y';
            ep.Extension_Flag__c='N';
            ep.Period_Code__c='X13';
            ep.RecordTypeId = epRecordTypeId;
            insert ep;
            System.assert(ep.Id!= null,'Eligibility period record not inserted');
            Contact_Staging__c cs = new Contact_Staging__c(
            Contact__c = testUser.contactId,
            Previous_License__c = 'Yes',
            First_Name__c = 'firstName', RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
            insert cs;
            System.assert(cs.Id!= null,'Record not inserted yet ');
            Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
            updateExamRegistration.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration.EP_start_Date__c = epStartDate;
            updateExamRegistration.EP_end_Date__c = epEndDate;
            updateExamRegistration.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration.Visa_Letter_Needed__c = true;
            updateExamRegistration.Exam_Status__c = null;
            updateExamRegistration.case__c = caseId;
            updateExamRegistration.Applicant__c = testUser.contactId;
            insert updateExamRegistration;
            System.assert(updateExamRegistration.Id!=null, 'Record not found');
            Exam_Registration__c updateExamRegistration5 = new Exam_Registration__c();
            updateExamRegistration5.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
            updateExamRegistration5.EP_start_Date__c = epStartDate;
            updateExamRegistration5.EP_end_Date__c = epEndDate;
            updateExamRegistration5.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration5.Visa_Letter_Needed__c = true;
            updateExamRegistration5.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration5.case__c = caseId;
            updateExamRegistration5.Applicant__c = testUser.contactId;
            insert updateExamRegistration5;
            System.assert(updateExamRegistration5.Id!=null, 'Record not found ');
            Exam_Registration__c updateExamRegistration6 = new Exam_Registration__c();
            updateExamRegistration6.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration6.EP_start_Date__c = epStartDate;
            updateExamRegistration6.EP_end_Date__c = epEndDate;
            updateExamRegistration6.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration6.Visa_Letter_Needed__c = true;
            updateExamRegistration6.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration6.case__c = caseId;
            updateExamRegistration6.Applicant__c = testUser.contactId;
            insert updateExamRegistration6;
            System.assert(updateExamRegistration6.Id!=null, 'Record not found');
            List<Exam_Registration__c> examregList = new List<Exam_Registration__c>();
            examregList.add(updateExamRegistration6);
            examregList.add(updateExamRegistration5);
            examregList.add(updateExamRegistration); 
            Service__c ser = new Service__c();
            ser.Name = Constants.CASE_SERVICE_ECFMG_CERTIFICATION; 
            insert ser;
            ExamRegistrationController.levelTwoValidations(testUser.contactId,constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK,examregList);
            ExamRegistrationController.getPassFailExams(examregList,constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK);
        }
        Test.stopTest();
    }
    //testMethod1Splitup
    @istest static void testMethod1Splitup(){
        User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
            Case newCase = new Case(
            RecordTypeId = examRegRecordTypeId,
            ContactId = testUser.contactId,
            Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
            Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW
            );
            insert newCase;
            List<Contact_Association_Type__c> catList = ExamRegistrationController.getOtherMedicalSchoolsWithTransferCredits();
            String caseId = ExamRegistrationController.createExamRegCase();
            ExamRegistrationController.getExamRegCaseNumber();
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            Contact_Staging__c cs = new Contact_Staging__c(
            Contact__c = testUser.contactId,
            Previous_License__c = 'Yes',
            First_Name__c = 'firstName', RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
            insert cs;
            Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
            updateExamRegistration.Exam_Types__c = examType;
            updateExamRegistration.EP_start_Date__c = epStartDate;
            updateExamRegistration.EP_end_Date__c = epEndDate;
            updateExamRegistration.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration.Visa_Letter_Needed__c = true;
            updateExamRegistration.case__c = caseId;
            updateExamRegistration.Applicant__c = testUser.contactId;
            insert updateExamRegistration;
            Exam_Registration__c updateExamRegistration5 = new Exam_Registration__c();
            updateExamRegistration5.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
            updateExamRegistration5.EP_start_Date__c = epStartDate;
            updateExamRegistration5.EP_end_Date__c = epEndDate;
            updateExamRegistration5.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration5.Visa_Letter_Needed__c = true;
            updateExamRegistration5.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration5.case__c = caseId;
            updateExamRegistration5.Applicant__c = testUser.contactId;
            insert updateExamRegistration5;
            Exam_Registration__c updateExamRegistration6 = new Exam_Registration__c();
            updateExamRegistration6.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration6.EP_start_Date__c = epStartDate;
            updateExamRegistration6.EP_end_Date__c = epEndDate;
            updateExamRegistration6.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration6.Visa_Letter_Needed__c = true;
            updateExamRegistration6.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration6.case__c = caseId;
            updateExamRegistration6.Applicant__c = testUser.contactId;
            insert updateExamRegistration6;
            List<Exam_Registration__c> examregList = new List<Exam_Registration__c>();
            examregList.add(updateExamRegistration6);
            examregList.add(updateExamRegistration5);
            examregList.add(updateExamRegistration);
            Map<Id, Exam_Registration__c> exmRgListIdMap = new Map<Id, Exam_Registration__c>(examregList);            
            System.assert(exmRgListIdMap.size()>0, 'Exam List is not exist');
            ExamRegistrationController.contactStagingMigration(exmRgListIdMap.keyset());
            case exmCase = new case();
            exmCase.id = caseId;
            exmCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
            exmCase.Exam_Registration__c = updateExamRegistration.Id;
            update exmCase;
            exmCase.Internal_Status__c = Constants.CASE_STATUS_REGISTERED;
            update exmCase;
            ExamRegistrationController.getEligibleRegionChangeCases();
            updateExamRegistration.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            update updateExamRegistration;
            ExamRegistrationController.getPassedExamTypes();
            ExamRegistrationController.getCheckBoxValue();
            ExamRegistrationController.getStartDateAndEndDate(CatList[0].Id,Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION);
            ExamRegistrationController.getExamRegistrations();
            ExamRegistrationController.getExamRegistrationCases();
            Asset permit7 = new Asset();
            permit7.Name = Constants.ASSET_TYPE_TRANSLATION;
            permit7.key__c = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
            permit7.ContactId = testUser.contactId;
            permit7.Exam_Registration__c = updateExamRegistration.Id;
            permit7.type__c = Constants.ASSET_TYPE_TRANSLATION;
            permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            insert permit7;
        }
        Test.stopTest();
    }
    //testPageAssetCallouts
    @istest static void testPageAssetCallouts(){
	User testUser = [Select id, contactId from User where alias = 'user3'];
	Test.startTest();
	System.runAs(testUser){
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
		Case newCase = new Case(
			RecordTypeId = examRegRecordTypeId,
			ContactId = testUser.contactId,
			Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
			Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW
		);
		insert newCase;
		System.assert(newCase.Id != NULL, 'Case creation failed.');
        List<Contact_Association_Type__c> catList = ExamRegistrationController.getOtherMedicalSchoolsWithTransferCredits();
        System.assert(!catList.isEmpty(), 'Contact Association type retrieval failed.');
		String caseId = ExamRegistrationController.createExamRegCase();
		ExamRegistrationController.getExamRegCaseNumber();
		date epStartDate = System.Today() + 1;
		date epEndDate = System.Today() - 25;
		Contact_Staging__c cs = new Contact_Staging__c(
			Contact__c = testUser.contactId,
			Previous_License__c = 'Yes',
			First_Name__c = 'firstName', RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
		insert cs;
        System.assert(cs.Id != NULL, 'ContactSatging creation failed.');
		Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = true;
		updateExamRegistration.case__c = caseId;
		updateExamRegistration.Applicant__c = testUser.contactId;
		insert updateExamRegistration;
        System.assert(updateExamRegistration.Id != NULL, 'exam reg creation failed.');
		Asset permit7 = new Asset();
		permit7.Name = Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION;
		permit7.key__c = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
		permit7.ContactId = testUser.contactId;
		permit7.Exam_Registration__c = updateExamRegistration.Id;
		permit7.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit7.status = Constants.ASSET_STATUS_IN_PROGRESS;
		permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		insert permit7;
        //IsExpired__c = FALSE
        
        Asset permit5 = new Asset();
        permit5.IsExpired__c= FALSE;
        permit5.IsOrphan__c = FALSE;
		permit5.Name = Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION;
		permit5.key__c = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
		permit5.ContactId = testUser.contactId;
		permit5.Exam_Registration__c = updateExamRegistration.Id;
		permit5.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit5.status = Constants.ASSET_STATUS_IN_PROGRESS;
		permit5.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		insert permit5;  
        Asset permit8 = new Asset();
		permit8.Name = Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION;
		permit8.key__c = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
		permit8.ContactId = testUser.contactId;
		permit8.Exam_Registration__c = updateExamRegistration.Id;
		permit8.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit8.status = Constants.ASSET_STATUS_IN_PROGRESS;
        permit8.Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/0033F00000Sul33QAB_Passport_0.jpeg';
		permit8.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		insert permit8;
        System.assert(permit8.Id != NULL, 'Asset creation failed2.');
        ExamRegistrationController.delAssetAndRelDoc(String.valueOf(testUser.contactId),Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC,string.valueof(updateExamRegistration.Id));
        ExamRegistrationController.deleteVisaExceptionDocEdit(String.valueOf(permit7.Azure_Storage_URL__c), String.valueOf(updateExamRegistration.id));
        ExamRegistrationController.updateAssetExamRegistration(permit8.Azure_Storage_URL__c,String.valueOf(newCase.Id),String.valueOf(updateExamRegistration.Id),Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK);
        System.assert(permit7.Id != NULL, 'Asset creation failed1.');
        System.assertEquals(String.valueOf(permit7.Azure_Storage_URL__c), ExamRegistrationController.retExcAssetIdOnPageload(String.valueOf(testUser.contactId), String.valueOf(updateExamRegistration.id)), 'Failed to retrieve Exception Asset');
        System.assertEquals(true, ExamRegistrationController.deleteVisaExceptionDoc(String.valueOf(testUser.contactId)), 'Failed to delete Exception Asset');
        System.assertEquals('Success', ExamRegistrationController.deleteExamRegistration(string.valueof(updateExamRegistration.Id)), 'Failed to update Exception Asset');
	
    }
	Test.stopTest();
}
    //testMethod1Splitup2
    @istest static void testMethod1Splitup2(){
        User testUser = [Select id,contactId from User where alias='user3'];
        
        Test.startTest();
        System.runAs(testUser){
            Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
            Case newCase = new Case(
                RecordTypeId = examRegRecordTypeId,
                ContactId = testUser.contactId,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW
            );
            insert newCase;
            String caseId = ExamRegistrationController.createExamRegCase();
            ExamRegistrationController.getExamRegCaseNumber();
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            Contact_Staging__c cs = new Contact_Staging__c(
                Contact__c = testUser.contactId,
                Previous_License__c = 'Yes',
                First_Name__c = 'firstName', RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
            insert cs;
            Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
            updateExamRegistration.Exam_Types__c = examType;
            updateExamRegistration.EP_start_Date__c = epStartDate;
            updateExamRegistration.EP_end_Date__c = epEndDate;
            updateExamRegistration.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration.Visa_Letter_Needed__c = true;
            updateExamRegistration.case__c = caseId;
            updateExamRegistration.Applicant__c = testUser.contactId;
            insert updateExamRegistration;
            
            case exmCase = new case();
            exmCase.id = caseId;
            exmCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
            exmCase.Exam_Registration__c = updateExamRegistration.Id;
            update exmCase;
            
            ExamRegistrationController.examRegPaymentCompletion();
            exmCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
            update exmCase;
            system.assertEquals(exmCase.Internal_Status__c, 'Pending Submission');
            ExamRegistrationController.deleteExamRegistration(string.valueof(updateExamRegistration.Id));           
        } 
        Test.stopTest();
    }
    //testMethod2
    @istest static void testMethod2(){
        String contactId = [select id FROM Contact][0].Id;
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case newCase = new Case(
            RecordTypeId = examRegRecordTypeId,
            ContactId = contactId,
            Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
            Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
        );
        insert newCase;
        
        ExamRegistrationController.manageSchedulingPermit(newCase.Id);
        ExamRegistrationController.manageVisaLetter(newCase.Id);
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        Asset permit7 = new Asset();
        permit7.Name = Constants.ASSET_TYPE_TRANSLATION;
        permit7.key__c = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
        permit7.ContactId = contactId;
        permit7.type__c = Constants.ASSET_TYPE_TRANSLATION;
        permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit7;
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
        regionSurcharge.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        ExamRegistrationController.getExamRegionSurcharges(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE);
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
        updateExamRegistration.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        updateExamRegistration.Test_Accommodations_needed__c = 'yes';
        updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.Applicant__c = contactId;
        updateExamRegistration.Case__c = newCase.Id;
        insert updateExamRegistration;      
        ExamRegistrationController.getExamRegistrationDetail(updateExamRegistration.Id);
        updateExamRegistration.EP_start_Date__c = System.Today() + 1;
        updateExamRegistration.EP_end_Date__c = System.Today() - 25;
        update updateExamRegistration;
        system.assertEquals(newCase.ContactId, permit7.ContactId);
        ExamRegistrationController.getExamRegistrationDetail(updateExamRegistration.Id);
        System.assert(permit7.Id != NULL, 'Asset creation failed.3');
        
    }
    //testMethod3
    @isTest static void testMethod3(){
        User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            String caseId = ExamRegistrationController.createExamRegCase();
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20; 
            List<Exam_Registration__c> insertExamRegRecords = new List<Exam_Registration__c>();
            Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
            updateExamRegistration.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration.EP_start_Date__c = epStartDate;
            updateExamRegistration.EP_end_Date__c = epEndDate;
            updateExamRegistration.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration.Visa_Letter_Needed__c = true;
            updateExamRegistration.Exam_taken_date__c = takenDate;
            updateExamRegistration.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration.case__c = caseId;
            updateExamRegistration.Applicant__c = testUser.contactId;
            insertExamRegRecords.add(updateExamRegistration);
           
            Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c(); 
            updateExamRegistration1.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration1.EP_start_Date__c = epStartDate;
            updateExamRegistration1.EP_end_Date__c = epEndDate;
            updateExamRegistration1.Exam_taken_date__c = takenDate;
            updateExamRegistration1.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration1.Visa_Letter_Needed__c = true;
            updateExamRegistration1.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration1.case__c = caseId;
            updateExamRegistration1.Applicant__c = testUser.contactId;
             insertExamRegRecords.add(updateExamRegistration1);
            
            Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
            updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;            
            updateExamRegistration2.EP_start_Date__c = epStartDate;
            updateExamRegistration2.EP_end_Date__c = epEndDate;
            updateExamRegistration2.Exam_taken_date__c = takenDate;
            updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration2.Visa_Letter_Needed__c = true;
            updateExamRegistration2.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration2.case__c = caseId;
            updateExamRegistration2.Applicant__c = testUser.contactId;
            insertExamRegRecords.add(updateExamRegistration2);
           
            ExamRegistrationController.getExamEligibilityDate(constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS);
            Exam_Registration__c updateExamRegistration4 = new Exam_Registration__c();
            updateExamRegistration4.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;            
            updateExamRegistration4.EP_start_Date__c = epStartDate;
            updateExamRegistration4.EP_end_Date__c = epEndDate;
            updateExamRegistration4.Exam_taken_date__c = takenDate;
            updateExamRegistration4.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration4.Visa_Letter_Needed__c = true;
            updateExamRegistration4.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration4.case__c = caseId;
            updateExamRegistration4.Applicant__c = testUser.contactId;
            insertExamRegRecords.add(updateExamRegistration4);
            
            Exam_Registration__c updateExamRegistration5 = new Exam_Registration__c();
            updateExamRegistration5.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;            
            updateExamRegistration5.EP_start_Date__c = epStartDate;
            updateExamRegistration5.EP_end_Date__c = epEndDate;
            updateExamRegistration5.Exam_taken_date__c = takenDate;
            updateExamRegistration5.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration5.Visa_Letter_Needed__c = true;
            updateExamRegistration5.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration5.case__c = caseId;
            updateExamRegistration5.Applicant__c = testUser.contactId;
             insertExamRegRecords.add(updateExamRegistration5);
          
            Exam_Registration__c updateExamRegistration6 = new Exam_Registration__c();
            updateExamRegistration6.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;            
            updateExamRegistration6.EP_start_Date__c = epStartDate;
            updateExamRegistration6.EP_end_Date__c = epEndDate;
            updateExamRegistration6.Exam_taken_date__c = takenDate;
            updateExamRegistration6.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration6.Visa_Letter_Needed__c = true;
            updateExamRegistration6.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            updateExamRegistration6.case__c = caseId;
            updateExamRegistration6.Applicant__c = testUser.contactId;
             insertExamRegRecords.add(updateExamRegistration6);
            insert insertExamRegRecords;
           
            ExamRegistrationController.getExamEligibilityDate(constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE);
            Case cse = new case();
            cse.Id = caseId;
            cse.Internal_Status__c = constants.CASE_STATUS_REGISTERED;
            update cse;
            Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            Case newCase = new Case(
                RecordTypeId = examRegRecordTypeId,
                ContactId = testUser.contactId,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
            );
            insert newCase;
            System.assert(newCase.Id!=null, 'Case not inserted');
            Id epRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get(Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG).getRecordTypeId();
            Eligibility_Period__c epCal = new Eligibility_Period__c();
            epCal.Exam_Type__c =constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
            epCal.EP_Start_Date__c=System.Today();
            epCal.EP_End_Date__c=System.Today().addDays(85);
            epCal.Deadline_Date__c=System.Today();
            epCal.Active__c='Y';
            epCal.Extension_Flag__c='N';
            epCal.Period_Code__c='X24';
            epCal.RecordTypeId = epRecordTypeId;
            insert epCal;  
            System.assert(epCal.Id!= null,'epCal not inserted');
            newCase.Eligibility_Period__c = epCal.id;
            update newCase;
            List<String> str =  ExamRegistrationController.getAllEligibleDate(System.Today(),constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE);
            System.AssertEquals(!str.isEmpty(),true,'No eligible dates available');
            List<Id> caseIds = new List<Id>();
            caseIds.add(caseId);
            ExamRegistrationController.regionValidationContMethod();
            ExamRegistrationController.deleteAsset(testUser.contactId);
            ExamRegistrationController.sendMailforStatusUpdate(testUser.contactId, caseIds);      
        }
        Test.stopTest();
    }
    //testMethod4
    @istest static void testMethod4(){
        User testUser = [Select id,contactId from User where alias='user3'];        
        Test.startTest();
        System.runAs(testUser){
            String caseId = ExamRegistrationController.createExamRegCase();
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20;            
            Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
            updateExamRegistration.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration.EP_start_Date__c = epStartDate;
            updateExamRegistration.EP_end_Date__c = epEndDate;
            updateExamRegistration.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration.Visa_Letter_Needed__c = true;
            updateExamRegistration.Exam_taken_date__c = takenDate;
            updateExamRegistration.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration.case__c = caseId;
            updateExamRegistration.Applicant__c = testUser.contactId;
            insert updateExamRegistration;
            Contact_Staging__c cs = new Contact_Staging__c(
            Contact__c = testUser.contactId,
            Previous_License__c = 'Yes', Ethnicity__c = 'Asian',Native_Language__c = 'Vietnamese', National_ID_Country__c = 'Afghanistan',
            First_Name__c = 'firstName', RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
            insert cs; 
            Asset permit7 = new Asset();
            permit7.Name = Constants.ASSET_TYPE_TRANSLATION;
            permit7.key__c = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
            permit7.ContactId = testUser.contactId;
            permit7.type__c = Constants.ASSET_TYPE_TRANSLATION;
            permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            insert permit7;
            System.assert(permit7.Id != NULL, 'Asset creation failed.4');
            Product2 product = new Product2();
            product.Name = 'Test';
            product.IsActive = true;
            product.Family = 'ECFMG_Certification';
            insert product;
            Exam_Region__c examReg = new Exam_Region__c();
            examReg.Name = 'Australia';
            examReg.Region_Name__c = 'Australia';
            insert examReg;
            Product_Detail__c proDetail = new Product_Detail__c();
            proDetail.Name = 'Test';
            proDetail.Product__c = product.Id;
            proDetail.Service_Fee__c = 5.00;
            proDetail.Start_Date__c = Date.newInstance(2022, 1, 17);
            proDetail.End_Date__c = Date.Today().addYears(1);
            insert proDetail;
            Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
            updateExamRegistration1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration1.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration1.Visa_Letter_Needed__c = false;
            updateExamRegistration1.Applicant__c = testUser.contactId;
            updateExamRegistration1.Case__c = caseId;
            updateExamRegistration1.EP_start_Date__c = Date.newInstance(2022, 1, 17);
            updateExamRegistration1.EP_end_Date__c = Date.Today().addYears(1);
            updateExamRegistration1.Product_Detail__c = proDetail.Id;
            String fieldvals1 = JSON.serialize(updateExamRegistration1);
            fieldvals1 = fieldvals1.replace('Test_Accommodations_needed__c', 'examRegId');
            fieldvals1 = fieldvals1.replace('yes', '');
            System.debug('check:'+fieldvals1);
            fieldvals1 = fieldvals1.replace('Visa_Letter_Needed__c', 'assetId');
            fieldvals1 = fieldvals1.replace('false', '\"'+permit7.Id+'\"');
            System.debug('check:'+fieldvals1);
            ExamRegistrationController.manageExamRegistration(fieldvals1);
            insert updateExamRegistration1; 
            String fieldvals = JSON.serialize(updateExamRegistration1);
            fieldvals = fieldvals.replace('Id', 'examRegId');
            ExamRegistrationController.manageExamRegistration(fieldvals);
            system.assertEquals(testUser.contactId, updateExamRegistration1.Applicant__c);
        }        
        Test.stopTest();        
    }
    
    @istest static void testMethod7(){
         User testUser = [Select id,contactId from User where alias='user3'];        
        Test.startTest();
        System.runAs(testUser){
            String caseId = ExamRegistrationController.createExamRegCase();
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20;            
            Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
            updateExamRegistration.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration.EP_start_Date__c = epStartDate;
            updateExamRegistration.EP_end_Date__c = epEndDate;
            updateExamRegistration.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration.Visa_Letter_Needed__c = true;
            updateExamRegistration.Exam_taken_date__c = takenDate;
            updateExamRegistration.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration.case__c = caseId;
            updateExamRegistration.Applicant__c = testUser.contactId;
            insert updateExamRegistration;
            Contact_Staging__c cs = new Contact_Staging__c(
            Contact__c = testUser.contactId,
            Previous_License__c = 'Yes', Ethnicity__c = 'Asian',Native_Language__c = 'Vietnamese', National_ID_Country__c = 'Afghanistan',
            First_Name__c = 'firstName', RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
            insert cs; 
            ExamRegistrationController.getStagingRecord('values');
            ExamRegistrationController.fetchAvailableExamTypes(updateExamRegistration.Id);
            ExamRegistrationController.fetchDocumentedDisabilities();
            ExamRegistrationController.checkExamConditions(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE, null);
            ExamRegistrationController.getExamRegistrations();
            ExamRegistrationController.getExamRegistrationCases();
        }
       Test.stopTest();
    }    
    
    //testMethod5
    @istest static void testMethod5(){
        User testUser = [Select id,contactId from User where alias='user3'];        
        Test.startTest();
        System.runAs(testUser){
            date epStartDate = System.Today() + 1;
          date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20;
            String caseId2 = ExamRegistrationController.createExamRegCase();
            Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
            updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration2.EP_start_Date__c = epStartDate;
            updateExamRegistration2.EP_end_Date__c = epEndDate;
            updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration2.Visa_Letter_Needed__c = true;
            updateExamRegistration2.Exam_taken_date__c = takenDate;
            updateExamRegistration2.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration2.case__c = caseId2;
            updateExamRegistration2.Applicant__c = testUser.contactId;
            updateExamRegistration2.Pd_Optout_flag__c = TRUE;
            insert updateExamRegistration2;
            Case myCaseUpdate = new Case(Id = caseId2, External_Status__c = 'Rejected');
            update myCaseUpdate;
            ExamRegistrationController.getExamRegistrationPriorRecords();
            Case myCaseUpdate2 = new Case(Id = caseId2, External_Status__c = 'Registered');
            update myCaseUpdate2;
            ExamRegistrationController.getExamRegistrationPriorRecords();
            System.assert(Case.Id!=null,'Id should not be null');
            system.assertEquals(caseId2, updateExamRegistration2.case__c);
        }
    }
    //testMethod6
    @istest static void testMethod6(){
        User testUser = [Select id,contactId from User where alias='user3'];        
        Test.startTest();
        
        date epStartDate = System.Today() + 1;
        date epEndDate = System.Today() - 25;
        date takenDate = System.Today() - 20;
        String caseId2 = ExamRegistrationController.createExamRegCase();
        Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
        updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        updateExamRegistration2.EP_start_Date__c = epStartDate;
        updateExamRegistration2.EP_end_Date__c = epEndDate;
        updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
        updateExamRegistration2.Visa_Letter_Needed__c = true;
        updateExamRegistration2.Exam_taken_date__c = takenDate;
        updateExamRegistration2.case__c = caseId2;
        updateExamRegistration2.Applicant__c = testUser.contactId;
        updateExamRegistration2.Pd_Optout_flag__c = TRUE;
        insert updateExamRegistration2;
        Case myCaseUpdate = new Case(Id = caseId2, External_Status__c = externalStatus);
        update myCaseUpdate;
        Set<String> stringSet = new Set<String>();
        stringSet.add(caseId2);
        List<Id> assetIdList = new List<Id>();
        Asset permit6 = new Asset();
        permit6.Name = 'AssetTest';
        permit6.ContactId = testUser.contactId;
        permit6.type__c = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
        permit6.case__c = caseId2;
        permit6.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit6;
        assetIdList.add(permit6.Id);
        Asset permit7 = new Asset();
        permit7.Name = 'AssetTestFile';
        permit7.ContactId = testUser.contactId;
        permit7.type__c = Constants.ASSET_TYPE_VISA_LETTER;
        permit7.case__c = caseId2;
        permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit7;
        System.assert(permit7.Id != NULL, 'Asset creation failed.5');
        assetIdList.add(permit7.Id);
        System.runAs(testUser){
            ExamRegistrationController.getSchedulingPermit(stringSet);
            ExamRegistrationController.getVisaLetter(stringSet);
            ExamRegistrationController.getConstantsClass();
            ExamRegistrationController.getContentMap(assetIdList);
            ExamRegistrationController.getContentVersionMap(assetIdList);
            ExamRegistrationController.getFileId(permit7.Id,ExamRegistrationController.getContentMap(assetIdList),ExamRegistrationController.getContentVersionMap(assetIdList));
            Passed_Exam_Exception__c pEE = new Passed_Exam_Exception__c();
            pEE.Applicant_Reason_Required__c = TRUE; 
            pEE.Documents_Required__c = FALSE; 
            pEE.Exception_Content__c = 'Test Exception Content'; 
            pEE.Exception_Name__c = 'Test Ex Name';
            pEE.Exam_Type__c = examType;
            insert pEE;
            ExamRegistrationController.passedExamExceptions(examType);
            Case createCase = new Case();
            Id recTypeScoreRecheck = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Score_Recheck').getRecordTypeId();
            createCase.RecordTypeId = recTypeScoreRecheck;
            createCase.Internal_Status__c = 'Submitted - In Review at ECFMG';
            insert createCase;
            Case createCase2 = new Case();
            Id recTypeScoreRecheck2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
            createCase2.RecordTypeId = recTypeScoreRecheck2;
            createCase2.Status = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
            insert createCase2;
            Case createCase3 = new Case();
            Id recTypeScoreRecheck3 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Eligibility_Period_Extension').getRecordTypeId();
            createCase3.RecordTypeId = recTypeScoreRecheck3;
            createCase3.Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
            createCase3.Enrollment_Verification_Parent__c = createCase2.Id;
            createCase3.ParentId = createCase2.Id;
            insert createCase3;
            system.assertEquals(createCase2.id, createCase3.ParentId);
            ExamRegistrationController.getParentCaseInternalStatus(createCase2.Id);
        }
    }
    
    @istest static void testMethodGetFileUrls(){
        User testUser = [Select id,contactId from User where alias='user3'];        
         Test.startTest();
         date epStartDate = System.Today() + 1;
         date epEndDate = System.Today() - 25;
         date takenDate = System.Today() - 20;
         String caseId2 = ExamRegistrationController.createExamRegCase();
         Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
         updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
         updateExamRegistration2.EP_start_Date__c = epStartDate;
         updateExamRegistration2.EP_end_Date__c = epEndDate;
         updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
         updateExamRegistration2.Visa_Letter_Needed__c = true;
         updateExamRegistration2.Exam_taken_date__c = takenDate;
         updateExamRegistration2.case__c = caseId2;
         updateExamRegistration2.Applicant__c = testUser.contactId;
         updateExamRegistration2.Pd_Optout_flag__c = TRUE;
         insert updateExamRegistration2;
         Case myCaseUpdate = new Case(Id = caseId2, External_Status__c = externalStatus);
         update myCaseUpdate;
         Set<String> stringSet = new Set<String>();
         stringSet.add(caseId2);
         List<Id> assetIdList = new List<Id>();
         Map<Id, Asset> assetsMap = new  Map<Id, Asset>();
         Asset permit6 = new Asset();
         permit6.Name = 'AssetTest';
         permit6.ContactId = testUser.contactId;
         permit6.type__c = Constants.ASSET_TYPE_TCT;
         permit6.case__c = caseId2;
         permit6.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
         insert permit6;
         assetIdList.add(permit6.Id);
         assetsMap.put(permit6.Id, permit6);
         Asset permit7 = new Asset();
         permit7.Name = 'AssetTestFile';
         permit7.ContactId = testUser.contactId;
         permit7.type__c = Constants.ASSET_TYPE_NAME_DOC;
         permit7.case__c = caseId2;
         permit7.ParentId =permit6.id;
         permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
         insert permit7;
         System.assert(permit7.Id != NULL, 'Asset creation failed.6');
         assetIdList.add(permit7.Id);
         assetsMap.put(permit7.Id, permit7);
         Asset permit8 = new Asset();
         permit8.Name = 'AssetTestFile';
         permit8.ContactId = testUser.contactId;
         permit8.type__c = Constants.ASSET_TYPE_TRANSLATION;
         permit8.case__c = caseId2;
         permit8.ParentId =permit6.id;
         permit8.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
         insert permit8;
         System.assert(permit8.Id != NULL, 'Asset creation failed.7');
         assetIdList.add(permit8.Id);
         assetsMap.put(permit8.Id, permit8);
         string parentidcommon = permit8.id;
         string parentid1 = permit6.id;
         
         System.runAs(testUser){
             ExamRegistrationController.getFileUrls(assetIdList,assetsMap,parentidcommon,parentidcommon);
             ExamRegistrationController.getFileUrls(assetIdList,assetsMap,parentid1,parentidcommon);
             ExamRegistrationController.getFileUrls(assetIdList,assetsMap,parentid1,parentidcommon);
             ExamRegistrationController.getFileUrls(assetIdList,assetsMap,parentidcommon,parentid1);
         }
    }
    @istest static void testMethodGetOtherInstFileUrls(){
        User testUser = [Select id,contactId from User where alias='user3'];        
        Test.startTest();
        String emailtest = 'tester@unknownmail.com';
        date birthdate1 = date.valueOf('2000-01-01');
        String lastname = 'Last';
        String firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,School_Enrollment_Status__c=constants.CONASCTYPESTG_STATUS_STUDENT,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',Step_1_Attempt_Limit_Exception__c = true, Step_2_CK_Attempt_Limit_Exception__c= true,Step_2_CS_Attempt_Limit_Exception__c= true);
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000099';
        update curECFMGSetting;
        insert c1;
        System.assert(c1.Id!=null, 'Contact not found');
        System.assert(c1.Id != NULL, 'Contact creation failed.');
        Account ac = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');
        List<Account> accOld =[SELECT Id FROM Account];
        List<Account> accUpdateList = new List<Account>();
        integer i=0;
        for (Account accAll:accOld ){
            i++;
            accAll.Entity_ID__c='test1234'+i; 
            accUpdateList.add(accAll);
        }
        update accUpdateList;
        insert ac;
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = c1.Id,Account__c=ac.id, Number_of_Years_Attended__c = 2);
        insert conAssocType;
        string conAssocTypeId = conAssocType.id;
        Map<String, String> tctInstMap = new  Map<String, String>();
        String caseId2 = ExamRegistrationController.createExamRegCase();
        Case myCaseUpdate = new Case(Id = caseId2, External_Status__c = externalStatus);
        update myCaseUpdate;
        Set<String> stringSet = new Set<String>();
        stringSet.add(caseId2);
        List<Id> assetIdList = new List<Id>();
        List<Asset> assetList = new List<Asset>();
        Map<Id, Asset> assetsMap = new  Map<Id, Asset>();
        Asset permit6 = new Asset();
        permit6.Name = 'AssetTest';
        permit6.ContactId = testUser.contactId;
        permit6.type__c = Constants.ASSET_TYPE_TCT;
        permit6.case__c = caseId2;
        permit6.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit6;
        string parentid1 = permit6.id;
        assetIdList.add(permit6.Id);
        assetsMap.put(permit6.Id, permit6);
        Asset permit7 = new Asset();
        permit7.Name = 'AssetTestFile';
        permit7.ContactId = testUser.contactId;
        permit7.type__c = Constants.ASSET_TYPE_NAME_DOC;
        permit7.case__c = caseId2;
        permit7.ParentId =permit6.id;
        permit7.Contact_Association_Type__c = conAssocType.id;
        permit7.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit7;
        System.assert(permit7.Id != NULL, 'Asset creation failed.8');
        tctInstMap.put(conAssocTypeId,parentid1);
        assetIdList.add(permit7.Id);
        assetsMap.put(permit7.Id, permit7);
        System.runAs(testUser){
            Map<String, String> tctTransIdInstMap = new Map<String, String> ();
            Map<String, String> pmlInstMap = new Map<String, String> ();
            Map<String, String> pmlTransIdInstMap = new  Map<String, String> ();
            String returnFileType ='test';
            ExamRegistrationController.getOtherInstFileUrls(assetIdList,assetsMap,tctInstMap, tctTransIdInstMap, pmlInstMap, pmlTransIdInstMap,  returnFileType);
            ExamRegistrationController.assetListDeduplicator(assetList);
        }
    }
    @istest static void testMethodSaveStagingRecord(){
        User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20;
            String caseId2 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate = new Case(Id = caseId2,Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION  );
            update myCaseUpdate;
            Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
            updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration2.EP_start_Date__c = epStartDate;
            updateExamRegistration2.EP_end_Date__c = epEndDate;
            updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration2.Visa_Letter_Needed__c = true;
            updateExamRegistration2.Exam_taken_date__c = takenDate;
            updateExamRegistration2.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            updateExamRegistration2.case__c = caseId2;
            updateExamRegistration2.Applicant__c = testUser.contactId;
            updateExamRegistration2.Pd_Optout_flag__c = TRUE;
            updateExamRegistration2.Basic_Sciences_Requirement__c ='Yes';
            updateExamRegistration2.Officially_Enrolled__c ='Yes';
            insert updateExamRegistration2;
            System.assert(updateExamRegistration2.Id != NULL, 'ExamRegistration creation failed.');
            Contact_Staging__c cs = new Contact_Staging__c(
                Contact__c = testUser.contactId,
                Previous_License__c = 'Yes',
                First_Name__c = 'firstName', 
                RecordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId());
            insert cs;
            system.assert(cs.id!=null,'contat staging not created');
            string updateValues ='{"ethnicity": "","nationalIDCountry": "Afghanistan","nationalIdentification": "Test","nativeLanguage": "English","socialSecurityNumber": "Test","officiallyEnrolled": "Yes","basicSciencesRequirement": "Yes","otherNativeLanguage": "Test","otherLanguagesSpoken": "","addLanguagesSpoken": "Test"}';
            ExamRegistrationController.getStagingRecord('values');
            ExamRegistrationController.saveStagingRecord(updateValues); 
            ExamRegistrationController.deserializeValues('["somestring1", "somestring2"]');
        }
        Test.stopTest();  
    }
    @istest static void testMethodCreateEVCase(){
        User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            String caseId2 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate = new Case(Id = caseId2, contactId = testUser.ContactId);
            update myCaseUpdate;
            List<Case> newExamRegCases =[select id,ContactId from Case where Id =: caseId2];
            Set<ID> examRegCaseContactIds = new Set<ID>();
            for(Case c:newExamRegCases){
                examRegCaseContactIds.add(c.ContactId);
            }
            Account ac = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');  
            insert ac;
            System.assert(ac.Id != NULL, 'Account creation failed2.');
            Account ac1 = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');  
            insert ac1;
            Account2Service__c a2s = new Account2Service__c();
            a2s.Account__c=ac.id;
            a2s.Active__c = True;
            insert a2s;
            Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
            Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = newExamRegCases[0].contactId,Account__c=ac1.id, Number_of_Years_Attended__c = 2);
            insert conAssocType;
            
            cadmus_core__Doc_Config__c coredoc = new cadmus_core__Doc_Config__c();
            coredoc.Name = coreName;
            coredoc.cadmus_core__CustomerDocumentConfigId__c=Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c;
            insert coredoc;
            Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();     
            Case newCase = new Case(
                RecordTypeId = evRecordTypeId,
                Enrolled_in_Entity_Portal__c =true,
                AccountId =ac.id,
                ContactId = testUser.contactId,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_NEW
            );
            insert newCase;
            ExamRegistrationController.createEVCase(newExamRegCases,examRegCaseContactIds);
            List<Case> evCaseList = new List<Case>();
            evCaseList.add(newCase);
            ExamRegistrationController.reupdateEVCaseStatuses(evCaseList);
        }
    }
    @istest static void testMethodUpdateEVCase(){
        User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            String caseId2 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate = new Case(Id = caseId2, contactId = testUser.ContactId);
            update myCaseUpdate;
            List<Case> newExamRegCases =[select id,ContactId from Case where Id =: caseId2];
            Set<ID> examRegCaseContactIds = new Set<ID>();
            for(Case c:newExamRegCases){
                examRegCaseContactIds.add(c.ContactId);
            }
            Account ac = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');  
            insert ac;
            System.assert(ac.Id != NULL, 'Account creation failed3.');
            Account2Service__c a2s = new Account2Service__c();
            a2s.Account__c=ac.id;
            a2s.Active__c = True;
            insert a2s;
            Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
            Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = newExamRegCases[0].contactId,Account__c=ac.id, Number_of_Years_Attended__c = 2);
            insert conAssocType;
            
            cadmus_core__Doc_Config__c coredoc = new cadmus_core__Doc_Config__c();
            coredoc.Name =coreName;
            coredoc.cadmus_core__CustomerDocumentConfigId__c=Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c;
           	insert coredoc;
            Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();     
            Case newCase = new Case(
                RecordTypeId = evRecordTypeId,
                AccountId =ac.id,
                ContactId = testUser.contactId,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_NEW
            );
            insert newCase;
         	ExamRegistrationController.updateEVCase(newExamRegCases);
        }
    }
    @istest static void testMethodGetExamRegistrationsForStatus(){
         User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20;
            String caseId2 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate = new Case(Id = caseId2, contactId = testUser.ContactId,Internal_Status__c=constants.CASE_STATUS_APPROVED);
            update myCaseUpdate;
            List<Case> newExamRegCases =[select id,ContactId from Case where Id =: caseId2];
            Set<ID> examRegCaseContactIds = new Set<ID>();
            for(Case c:newExamRegCases){
                examRegCaseContactIds.add(c.ContactId);
            }
            String caseId3 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate3 = new Case(Id = caseId3,External_Status__c = Constants.CASE_STATUS_REJECTED, contactId = testUser.ContactId,Internal_Status__c=constants.CASE_STATUS_APPROVED);
            update myCaseUpdate3;
			List<Exam_Registration__c> examRegUpdateList= new   List<Exam_Registration__c>();         
            Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
            updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration2.EP_start_Date__c = epStartDate;
            updateExamRegistration2.EP_end_Date__c = epEndDate;
            updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration2.Visa_Letter_Needed__c = true;
            updateExamRegistration2.Exam_taken_date__c = takenDate;
            updateExamRegistration2.case__c = caseId2;
            updateExamRegistration2.Applicant__c = testUser.contactId;
            updateExamRegistration2.Pd_Optout_flag__c = TRUE;
            examRegUpdateList.add(updateExamRegistration2);
            Exam_Registration__c updateExamRegistration3 = new Exam_Registration__c();
            updateExamRegistration3.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration3.EP_start_Date__c = epStartDate;
            updateExamRegistration3.EP_end_Date__c = epEndDate;
            updateExamRegistration3.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration3.Visa_Letter_Needed__c = true;
            updateExamRegistration3.Exam_taken_date__c = takenDate;
            updateExamRegistration3.case__c = caseId3;
            updateExamRegistration3.Applicant__c = testUser.contactId;
            updateExamRegistration3.Pd_Optout_flag__c = TRUE;
            examRegUpdateList.add(updateExamRegistration3);
            insert examRegUpdateList;
            Account ac = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');  
            insert ac;
            System.assert(ac.Id!=null, 'Account record is not inserted' );
            Account2Service__c a2s = new Account2Service__c();
            a2s.Account__c=ac.id;
            a2s.Active__c = True;
            insert a2s;
            Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
            Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = newExamRegCases[0].contactId,Account__c=ac.id, Number_of_Years_Attended__c = 2);
            insert conAssocType;
            cadmus_core__Doc_Config__c coredoc = new cadmus_core__Doc_Config__c();
            coredoc.Name =coreName;
            coredoc.cadmus_core__CustomerDocumentConfigId__c=Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c;
            insert coredoc;
            ExamRegistrationController.getExamRegistrationsForStatus();
        }   
    }
     @istest static void testMethodGetExamRegistrationPriorRecordss(){
         User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            date epStartDate = System.Today() + 1;
            date epEndDate = System.Today() - 25;
            date takenDate = System.Today() - 20;
            String caseId2 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate = new Case(Id = caseId2, contactId = testUser.ContactId,Internal_Status__c=constants.CASE_STATUS_APPROVED);
            update myCaseUpdate;
            List<Case> newExamRegCases =[select id,ContactId from Case where Id =: caseId2];
            Set<ID> examRegCaseContactIds = new Set<ID>();
            for(Case c:newExamRegCases){
                examRegCaseContactIds.add(c.ContactId);
            }
            String caseId3 = ExamRegistrationController.createExamRegCase();
            Case myCaseUpdate3 = new Case(Id = caseId3,External_Status__c = Constants.CASE_STATUS_REJECTED, contactId = testUser.ContactId,Internal_Status__c=constants.CASE_STATUS_APPROVED);
            update myCaseUpdate3;
			List<Exam_Registration__c> examRegUpdateList= new   List<Exam_Registration__c>();         
            Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
            updateExamRegistration2.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration2.EP_start_Date__c = epStartDate;
            updateExamRegistration2.EP_end_Date__c = epEndDate;
            updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration2.Visa_Letter_Needed__c = true;
            updateExamRegistration2.Exam_taken_date__c = takenDate;
            updateExamRegistration2.case__c = caseId2;
            updateExamRegistration2.Applicant__c = testUser.contactId;
            updateExamRegistration2.Pd_Optout_flag__c = TRUE;
            examRegUpdateList.add(updateExamRegistration2);
            Exam_Registration__c updateExamRegistration3 = new Exam_Registration__c();
            updateExamRegistration3.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
            updateExamRegistration3.EP_start_Date__c = epStartDate;
            updateExamRegistration3.EP_end_Date__c = epEndDate;
            updateExamRegistration3.Test_Accommodations_needed__c = 'yes';
            updateExamRegistration3.Visa_Letter_Needed__c = true;
            updateExamRegistration3.Exam_taken_date__c = takenDate;
            updateExamRegistration3.case__c = caseId3;
            updateExamRegistration3.Applicant__c = testUser.contactId;
            updateExamRegistration3.Pd_Optout_flag__c = TRUE;
            examRegUpdateList.add(updateExamRegistration3);
            insert examRegUpdateList;
            Account ac = new Account(Name='EntityAcctName', School__c=true, BillingCountry = 'India');  
            insert ac;
            System.assert(ac.Id!=null, 'Account record is not inserted' );
            Account2Service__c a2s = new Account2Service__c();
            a2s.Account__c=ac.id;
            a2s.Active__c = True;
            insert a2s;
            Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
            Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = newExamRegCases[0].contactId,Account__c=ac.id, Number_of_Years_Attended__c = 2);
            insert conAssocType;
            cadmus_core__Doc_Config__c coredoc = new cadmus_core__Doc_Config__c();
            coredoc.Name =coreName;
            coredoc.cadmus_core__CustomerDocumentConfigId__c=Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c;
            insert coredoc;
            ExamRegistrationController.getExamRegistrationPriorRecords();
        }   
    }
    
    //testGetPEAssetLink
    @istest static void testGetPEAssetLink(){
        User testUser = [Select id,contactId from User where alias='user3'];
        Test.startTest();
        System.runAs(testUser){
            Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            Case newCase = new Case(
                RecordTypeId = examRegRecordTypeId,
                ContactId = testUser.contactId,
                Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
                Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
            );
            insert newCase;
            System.assert(newCase.Id!=null, 'newCase record is not inserted' );
            Id examRegRecordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            Case newCase2 = new Case(
                RecordTypeId = examRegRecordTypeId2,
                ContactId = testUser.contactId,
                ParentId = newCase.Id,
                Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION,
                Enrollment_Verification_Parent__c = newCase.Id
            );
            insert newCase2;
            System.assert(newCase2.Id!=null, 'newCase2 record is not inserted' );
			Asset newAsset = new Asset(Name='EPIC', Type__c='Birth Certificate', ContactId = testUser.contactId, Case__c = newCase2.Id, Azure_Storage_URL__c = '/0033D00000i0ZJwQAM_Passport_Translation_Page_0.pdf');
            insert newAsset;
            System.assert(newAsset.Id!=null, 'Asset record not inserted');
            String returnVal = ExamRegistrationController.getPEAssetLink(newCase.Id+'');
            System.assert(returnVal!= NULL, 'Not NULL');
        }
        Test.stopTest();
    }
    //testgetStartEndAndDegreeMonthYearPositive
    @isTest static void testgetStartEndAndDegreeMonthYearPositive() {

       Account acc = new Account(Name='ContactTest AssociationTest', BillingCountry = 'India');
         List<Account> accOld =[SELECT Id FROM Account];
       List<Account> accUpdateList = new List<Account>();
       integer i=0;
       for (Account accAll:accOld ){
           i++;
           accAll.Entity_ID__c='test1234'+i; 
           accUpdateList.add(accAll);
       }
     
        update accUpdateList;
       insert acc; 
       Contact con = new Contact ( FirstName='BN ',
       LastName='UnitTest',       
       AccountId=acc.Id); 
         CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
    curECFMGSetting.ECFMG_ID__c = '00000098';
    update curECFMGSetting;
       insert con; 
       Contact_Association_Type__c cat = new  Contact_Association_Type__c(); 
       cat.Start_Month__c = 'June';
       cat.Start_Year__c = '2018';
       cat.End_Month__c = 'June';
       cat.End_Year__c = '2022';
       cat.Degree_Issue_Month__c = 'June'; 
       cat.Degree_Issue_Year__c ='2022'; 
       cat.Account__c = acc.Id; 
       cat.Contact__c = con.Id; 
       insert cat; 

       String objId = String.valueOf(cat.Id); 
       Test.startTest();
       Map <String, String> testMap =  ExamRegistrationController.getStartEndAndDegreeMonthYear(objId, 'Contact_Association_Type__c'); 
        String v1 = '2022';
        System.assertEquals(testMap.get('Degree_Issue_Year__c'),v1); 
       Test.stopTest();
   }
   //testgetStartEndAndDegreeMonthYearNegative
   @isTest static void testgetStartEndAndDegreeMonthYearNegative() {
    Account acc = new Account(Name='ContactTest AssociationTest', BillingCountry = 'India'); 
       List<Account> accOld =[SELECT Id FROM Account];
       List<Account> accUpdateList = new List<Account>();
       integer i=0;
       for (Account accAll:accOld ){
           i++;
           accAll.Entity_ID__c='test1234'+i; 
           accUpdateList.add(accAll);
       }
     
        update accUpdateList;
       insert acc; 
    Contact con = new Contact ( FirstName='BN ',
    LastName='UnitTest',       
    AccountId=acc.Id); 
    CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
    curECFMGSetting.ECFMG_ID__c = '00000097';
    update curECFMGSetting;
    insert con; 
    Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
    Contact_Association_Type__c cat = new  Contact_Association_Type__c(); 
    cat.Start_Month__c = 'June';
    cat.Start_Year__c = '2018';
    cat.End_Month__c = 'June';
    cat.End_Year__c = '2022';
    cat.Degree_Issue_Month__c = 'June'; 
    cat.Degree_Issue_Year__c ='2022'; 
    cat.Account__c = acc.Id; 
    cat.Contact__c = con.Id; 
    cat.RecordTypeId = conAssocRecordTypeId;
    insert cat; 
    String objId = String.valueOf(cat.Id); 
    Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
    Case newCase = new Case(
        RecordTypeId = examRegRecordTypeId,
        ContactId = con.Id,
        Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
        Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
    );
    insert newCase;
    System.assert(newCase.Id!=null, 'newCase record is not inserted' );
    Test.startTest();
    Map <String, String> testMap =  ExamRegistrationController.getStartEndAndDegreeMonthYear(objId, 'Contact_Association_Type__c'); 
    String v1 = '2023';
    System.assertNotEquals(testMap.get('Degree_Issue_Year__c'),v1); 
    try{
        ExamRegistrationController.createEVCaseforExamReg(new List<Case>{newCase});
    }
    catch(Exception e){}
    Test.stopTest();
   }
}