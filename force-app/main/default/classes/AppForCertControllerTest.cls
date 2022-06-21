/**
 * Test Class for AppForCertController class
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   24-DEC-2019
 */
@isTest
public class AppForCertControllerTest {

	public static final String ASSET_NAME = 'Test Asset';
	public static final String DIPLOMA_DOCUMENT = 'DIPLOMA DOCUMENT';
	public static final String TEST_ACOUNT = 'Test Account';
	public static final String CLIENT_PATH = 'Penguins.jpg';
	public static final String TEST_CONTENT = 'Test Content';
	public static final String TRANSFER_CREDIT_TRANSCRIPT = 'Transfer Credit Transcript';
	public static final String ASSERT_CASE_INSERT = 'Fail to insert Case Record';

	@testSetup static void setup() {
		AppforCertTestFactory.servicePageSetup();
	}

	@isTest static void testerrorMessageOFACSoftPositive() {
		//Tests when the Contact's MailingCountry is among the OFAC list. Should return true.	
		User testUser = [Select id, contactId, Contact.AccountId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			System.assert(testUser.contactId != null);
			Contact testContact = new Contact(id = testUser.contactId, AccountId = testUser.Contact.AccountId, MailingCountry = 'Albania');
			update testContact;

			Contact getId = [Select Id, AccountId from Contact where Id =: testContact.Id];

			System.assert(AppForCertController.errorMessageOFACSoft(getId.AccountId) == false);
		}
		Test.stopTest();
	}

	@isTest static void testerrorMessageOFACSoftNegative() {
		//Tests when the Contact's MailingCountry is among the OFAC list. Should return false.

		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {

			System.assert(testUser.contactId != null);

			Contact testContact = new Contact(id = testUser.contactId, MailingCountry = 'Mexico');
			update testContact;

			Contact getAccountId = [Select Id, AccountId from Contact where Id =: testContact.Id];

			System.assert(AppForCertController.errorMessageOFACSoft(getAccountId.AccountId) == false);
		}
		Test.stopTest();
	}

	@isTest static void testerrorMessageCurrentDatetPositive() {
		//Tests current date not between from and to date.Should return true
		Date frmdate = Date.today();
		Date todate = Date.today() - 1;
		Test.startTest();
		System.assert(AppForCertController.errorMessageCurrentDate('Student', frmdate, todate) == true);
		Test.stopTest();
	}

	@isTest static void testerrorMessageCurrentDatetNegative() {
		//Tests current date not between from and to date.Should return false
		Date frmdate = Date.today() - 1;
		Date todate = Date.today() + 1;
		Test.startTest();

		System.assert(AppForCertController.errorMessageCurrentDate('Student', frmdate, todate) == false);
		System.assert(AppForCertController.toAndFromDateValidation(frmdate, todate) == true);
		Test.stopTest();
	}

	@isTest static void testerrorMessageGraduationDatePositive() {
		//Tests Graduation date is greater than TO date.Should return true

		Date todate = Date.today() + 10;
		Test.startTest();

		System.assert(AppForCertController.errorMessageGraduationDate('2019', '12', todate) == true);

		Test.stopTest();
	}

	@isTest static void testerrorMessageGraduationDateNegative() {
		//Tests Graduation date is greater than TO date.Should return false

		Date todate = Date.today() - 1;
		Test.startTest();

		System.assert(AppForCertController.errorMessageGraduationDate('2029', '12', todate) == false);

		Test.stopTest();
	}

	@isTest static void testerrorMessageNewGraduationDatePositive() {
		//Tests Graduation date is less than End date.Should return true
		Test.startTest();
		System.assert(AppForCertController.errorMessageNewGraduationDate('June', '2019', 'June', '2020') == true,'Graduation date greater than End date');
		Test.stopTest();
	}

	@isTest static void testerrorMessageNewGraduationDateNegative() {
		//Tests Graduation date is less than End date.Should return false
		Test.startTest();
		System.assert(AppForCertController.errorMessageNewGraduationDate('June', '2019', 'June', '2018') == false,'Graduation date less than End date');
		Test.stopTest();
	}

	@isTest static void testerrorMessageNewCurrentDatePositive() {
		//Tests current date not between Start and End Month & Year.Should return true
		Date currentDate = Date.Today();
		Integer currentYear = currentDate.year();
		Integer startYear = currentYear - 1;
		Integer endYear = currentYear + 1;
		String strStartYear = String.valueof(startYear);
		String strEndYear = String.valueof(endYear);

		Test.startTest();

		System.assert(AppForCertController.errorMessageNewCurrentDate('Student', strStartYear, '06', strEndYear, '06') == true);

		Test.stopTest();
	}

	@isTest static void testerrorMessageNewCurrentDateNegative() {
		//Tests current date not between Start and End Month & Year.Should return false
		Date currentDate = Date.Today();
		Integer currentYear = currentDate.year();
		Integer startYear = currentYear - 1;
		Integer endYear = currentYear + 1;
		String strStartYear = String.valueof(startYear);
		String strEndYear = String.valueof(endYear);

		Test.startTest();

		System.assert(AppForCertController.errorMessageNewCurrentDate('Student', '06', strStartYear, '06', strEndYear) == false);

		Test.stopTest();
	}
	@isTest static void teststartAndEndDateValidationPositive() {
		//Tests current date not between Start and End Month & Year.Should return true
		Date currentDate = Date.Today();
		Integer currentYear = currentDate.year();
		Integer startYear = currentYear + 1;
		Integer endYear = currentYear + 1;
		String strStartYear = String.valueof(startYear);
		String strEndYear = String.valueof(endYear);
		Test.startTest();
		System.assert(AppForCertController.startAndEndDateValidation('June', strStartYear, 'June' , strEndYear) == true,'Current date lies between given Start and End Month & Year');
		Test.stopTest();
	}
	@isTest static void teststartAndEndDateValidationNegative() {
		//Tests current date not between Start and End Month & Year.Should return false
		Date currentDate = Date.Today();
		Integer currentYear = currentDate.year();
		Integer startYear = currentYear - 1;
		Integer endYear = currentYear - 1;
		String strStartYear = String.valueof(startYear);
		String strEndYear = String.valueof(endYear);

		Test.startTest();

		System.assert(AppForCertController.startAndEndDateValidation('June', strStartYear, 'June', strEndYear) == false);

		Test.stopTest();
	}

	@isTest static void testerrorMessageNewStartDateEndDatePositive() {
		//Tests Start Month & Year greater than End Month & Year.Should return true

		Test.startTest();

		System.assert(AppForCertController.errorMessageNewStartDateEndDate('June', '2020', 'June', '2019') == true);

		Test.stopTest();
	}

	@isTest static void testerrorMessageNewStartDateEndDateNegative() {
		//Tests Start Month & Year less than End Month & Year.Should return false

		Test.startTest();

		System.assert(AppForCertController.errorMessageNewStartDateEndDate('June', '2019', 'June', '2020') == false);

		Test.stopTest();
	}

	@isTest static void testerrorMessageDegreeIssueDatePositive() {
		//Tests Degree Issue date is less than End date.Should return true.
		Test.startTest();
		System.assert(AppForCertController.errorMessageDegreeIssueDate('June', '2020', 'June', '2018') == true,'Degree Issue date greater than End date');
		Test.stopTest();
	}
	@isTest static void testerrorMessageDegreeIssueDateNegative() {
		//Tests Degree Issue date is greater than End date.Should return false
		Test.startTest();
		System.assert(AppForCertController.errorMessageDegreeIssueDate('June', '2019', 'June', '2020') == false,'Degree Issue date less than End date');
		Test.stopTest();
	}

	@isTest static void testSchoolReviewPositiveWithCases() {
    //Tests the medical school page if there is an associated case. Should update the existing Contact Association type staging record.

    User testUser = [Select id, contactId from User where alias = 'user3'];

    Test.startTest();
    System.runAs(testUser) {

      Integer existingCount = [Select count() From Contact_Association_Type_Staging__c];
      Id idVerCaseRecordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
      List<Account> acctList = AppForCertController.getSchoolRecords();
      List<String> graduationYearList = AppForCertController.getGradYearValues(acctList[0].Id);
      AppForCertController.getDegreeRecords(acctList[0].Id, graduationYearList[0]);
      System.assert(graduationYearList.size() > 0);
      //Contact cs2 = [Select Id,AccountId from Contact where FirstName = 'First3' LIMIT 1];
      Contact cs2 = [Select Id,AccountId from Contact where Id =: testUser.ContactId];
      //List<case> newCases = [SELECT id, Internal_Status__c FROM Case WHERE ContactId = :cs2.Id];  
      Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
      Case caseobj = new Case();
      caseobj.RecordTypeId = appForCertRecordTypeId;
      caseobj.ContactId = cs2.Id;
      caseobj.AccountId = cs2.AccountId;
      caseobj.Internal_Status__c = 'Pending Review';
      insert caseObj;  
      List<case> newCases = new List<case>();
      newCases.add(caseObj);
      List<Contact_Association_Type_Staging__c> existingConAssoStagingObjList = new List<Contact_Association_Type_Staging__c>();
      Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
      Contact_Association_Type_Staging__c catsNew = new Contact_Association_Type_Staging__c(
        Case__c = caseObj.Id,
        Parent_Case__c = caseObj.Id,
        Contact__c = cs2.Id,
        RecordtypeId = catsRecordTypeId,
        Status__c = 'Student',
        Number_of_Years_Attended__c = 1, 
        Account__c = cs2.AccountId, 
        Degree_Title__c = 'Test Title', 
        Start_Date__c = Null, 
        End_Date__c = Null, 
        Graduation_Year__c = '2020', 
        Graduation_Month__c = 'January', 
        Degree_Issue_Date__c = Null, 
        School_Program__c = '', 
        Student_ID__c = 'Std8980', 
        Specialty__c = 'Special',
        Start_Month__c = 'January', 
        Start_Year__c = '2020', 
        End_Year__c = '2024', 
        End_Month__c = 'February', 
        Degree_Issue_Month__c = 'March', 
        Degree_Issue_Year__c = '2025'
      );
      insert catsNew;
      existingConAssoStagingObjList.add(catsNew);
      /*List<Contact_Association_Type__c> catList = [SELECT ID From Contact_Association_Type__c 
                            WHERE Contact__c =: cs2.Id AND 
                            recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];*/        
      String conStaging = AppForCertController.getContactAssociationOrStaging(false);
      List<String> conStagingArr;
      if(conStaging != NULL && conStaging.Contains(',')){
        conStagingArr = conStaging.split(',');
        AppForCertController.getStartDateAndEndDate(conStagingArr[0], conStagingArr[1]);
      }
      Map<string, string> selectedVal = AppForCertController.getSelectedValues(false);
      if (selectedVal.size() > 0) {
        String accountId = acctList[0].id;
        //String jsonStringFieldVal = '{"Start_Date__c":"2017-12-14","End_Date__c":"2021-12-22","School_Program__c":"test1","Graduation_Date__c":"2019-12-30","Degree_Issue_Date__c":"2022-12-21","Student_ID__c":"id147","Specialty__c":"nothing","Status__c":"Student","Account__c":"'+accountId+'","Degree_Title__c":"MD","gradYear":"2017","gradMonth":"December","gradDay":"14", "Number_of_Years_Attended__c":4, "showExamRegActionButton":false}';
        String jsonStringFieldVal = '{"Start_Month__c":"June","Start_Year__c":"2017","End_Month__c":"June","End_Year__c":"2021","Start_Date__c":"2017-12-14","End_Date__c":"2021-12-22","School_Program__c":"test1","Graduation_Date__c":"2019-12-30","Degree_Issue_Date__c":"2022-12-21","Degree_Issue_Month__c":"August","Degree_Issue_Year__c":"2022","Student_ID__c":"id147","Specialty__c":"nothing","Status__c":"Student","Account__c":"' + accountId + '","Degree_Title__c":"MD","gradYear":"2017","gradMonth":"December","gradDay":"14", "Number_of_Years_Attended__c":4, "showExamRegActionButton":false}';
        String caseId = AppForCertController.manageAppforCertCases(jsonStringFieldVal,false);

        if (caseId != NULL) {
          Integer newCount = [Select count() From Contact_Association_Type_Staging__c];
        }
      }
    }
    Test.stopTest();
  } 	
	@isTest static void testgetContactAssociationStagingExamReg() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();				
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			insert cats;

			AppForCertController.getContactAssociationStagingExamReg(false, false);
		}
		Test.stopTest();
	}

	@isTest static void testdeleteOtherInstitutions() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			Transfer_Credit__c tc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert tc;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst1;
			AppForCertController.deleteOtherInstitutions(con.Id, caseObj.Id, caseObj.Id);
		}
		Test.stopTest();
	}
	@isTest static void testdeleteUncheckedTransferCreditAndAsset() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			Transfer_Credit__c tc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert tc;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst1;

			AppForCertController.deleteUncheckedTransferCreditAndAsset(con.Id, caseObj.Id, caseObj.Id);
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherMedSchoolRecords() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;

			AppForCertController.getOtherMedSchoolRecords(false);
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherMedSchoolRecordsElse() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1;

			//Create and Insert Asset
			Asset asst2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1.Id
			);
			insert asst2;

			AppForCertController.getOtherMedSchoolRecords(false);
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherSchoolRecords() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst1;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;

			AppForCertController.getOtherInstitutionRecords(false);
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherSchoolRecordsElse() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			insert cats;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst1;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;

			AppForCertController.getOtherInstitutionRecords(false);
		}
		Test.stopTest();
	}
	@isTest static void testgetTermsandConditionsData() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {

			Product2 prod = new Product2(Name = 'End User Legal Terms - AppForCert',
				Family = 'Hardware');
			insert prod;

			Terms_and_Conditions__c tc = new Terms_and_Conditions__c(
				Name = 'Test',
				Copy__c = 'Test',
				Short_Copy__c = 'Test',
				Status__c = 'Active',
				Product__c = prod.Id,
				ExpirationDate__c = System.today() + 20
			);
			insert tc;

			AppForCertController.getTermsandConditionsData();
		}
		Test.stopTest();
	}
	@isTest static void testSchoolReviewPositivewithNoCases() {
		//Tests the medical school page if there is no associated case. Should create a new Contact Association type staging record.

		User testUser = [Select id, contactId from User where alias = 'second'];

		Test.startTest();
		System.runAs(testUser) {
			Integer existingCount = [Select count() From Contact_Association_Type_Staging__c];

			List<Account> acctList = [Select Id from Account where name =: 'EntityAcctNameNoCase'];
			List<String> graduationYearList = AppForCertController.getGradYearValues(acctList[0].Id);
			AppForCertController.getDegreeRecords(acctList[0].Id, graduationYearList[0]);
			System.assert(graduationYearList.size() > 0);

			String conStaging = AppForCertController.getContactAssociationOrStaging(true);
			System.assert(conStaging != '');

			Map<string, string> selectedVal = AppForCertController.getSelectedValues(false);			

			if (selectedVal.size() > 0) {
				String accountId = acctList[0].id;
				//String jsonStringFieldVal = '{"Start_Date__c":"2017-12-14","End_Date__c":"2021-12-22","School_Program__c":"test1","Graduation_Date__c":"2019-12-30","Degree_Issue_Date__c":"2022-12-21","Student_ID__c":"id147","Specialty__c":"nothing","Status__c":"Student","Account__c":"'+accountId+'","Degree_Title__c":"MD","gradYear":"2017","gradMonth":"December","gradDay":"14", "Number_of_Years_Attended__c":4, "showExamRegActionButton":false}';
				//added start month, start year, end month, end year, degree issue month, degree issue year in json.
				String jsonStringFieldVal = '{"Start_Month__c":"June","Start_Year__c":"2017","End_Month__c":"June","End_Year__c":"2021","Start_Date__c":"2017-12-14","End_Date__c":"2021-12-22","School_Program__c":"test1","Graduation_Date__c":"2019-12-30","Degree_Issue_Date__c":"2022-12-21","Degree_Issue_Month__c":"August","Degree_Issue_Year__c":"2022","Student_ID__c":"id147","Specialty__c":"nothing","Status__c":"Student","Account__c":"' + accountId + '","Degree_Title__c":"MD","gradYear":"2017","gradMonth":"December","gradDay":"14", "Number_of_Years_Attended__c":4, "showExamRegActionButton":false}';
				String caseId = AppForCertController.manageAppforCertCases(jsonStringFieldVal,false);

				if (caseId != NULL) {
					Integer newCount = [Select count() From Contact_Association_Type_Staging__c];
					System.assertEquals(existingCount + 1, newCount);
				}
			}
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherMedicalSchoolRecords() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getOtherMedicalSchoolRecords();
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherMedicalSchoolRecordsElse() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getOtherMedicalSchoolRecords();
		}
		Test.stopTest();
	}
	@isTest static void testgetSchoolRecordsOthers() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getSchoolRecordsOthers();
		}
		Test.stopTest();
	}
	@isTest static void testdeleteOrphanedAssets() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			//Create and Insert Asset
			Id recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Application_for_Certification').getRecordTypeId();
			Asset asst1 = new Asset(
				recordTypeId = recordTypeId,
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation'
			);
			insert asst1;

			AppForCertController.deleteOrphanedAssets();
		}
		Test.stopTest();
	}
	@isTest static void testdeleteOrphanedAssets1() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.deleteOrphanedAssets();
		}
		Test.stopTest();
	}

	@isTest static void testsaveOtherMedicalSchools() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			/*Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
			Account acc = new Account();
			acc.Name = TEST_ACOUNT;
			acc.recordTypeId = recordTypeIdAcc;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;*/
			Account acc = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name =: TEST_ACOUNT LIMIT 1];
			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;
			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass;
			String assetId = ass.Id;
			List<String> assetIds = new List<String> ();
			assetIds.add(ass.id);
			String caseId = caseObj.Id;
			String parentCaseId = caseObj.Id;
			List<String> tcIds = new List<String> ();
			String jsonValues = '[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + cats.Id + '","otherSchool":"School 2","otherSchoolId":"' + acc.Id + '","schoolProgram":"","studentId":"","Specialty":"","fromDate":"2012-09-01","endDate":"2020-01-23","transferCreditsCheckbox":true,"tcWrapperList":[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"","fromSchool":"' + acc.Id + '","transferCreditCourse":"","transferCreditGrade":"","courseOutcome":"","creditsEarnedMonth":"","creditsEarnedYear":""}],"assets":[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + assetId + '","docNotInEnglish":true,"nameOnDoc":"Name on Document - 1","nameOnDocIsDifferent":true,"type":"Transfer Credit Transcript","parentAssetId":""}]}]]';
			AppForCertController.saveOtherMedicalSchools(jsonValues, assetIds, parentCaseId, caseId, tcIds, false);
		}
		Test.stopTest();
	}
	@isTest static void testsaveOtherMedicalSchoolsRecordvalEmpty() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			//Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
			Account acc = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name =: TEST_ACOUNT LIMIT 1];
			/*new Account();
			acc.Name = TEST_ACOUNT;
			acc.recordTypeId = recordTypeIdAcc;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;*/
			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass;
			String assetId = ass.Id;
			List<String> assetIds = new List<String> ();
			assetIds.add(ass.id);
			String caseId = caseObj.Id;
			String parentCaseId = caseObj.Id;
			List<String> tcIds = new List<String> ();

			String jsonValues = '[{"recordIdVal":"","otherSchool":"School 2","otherSchoolId":"' + acc.Id + '","schoolProgram":"","studentId":"","Specialty":"","fromDate":"2012-09-01","endDate":"2020-01-23","transferCreditsCheckbox":true,"tcWrapperList":[{"recordIdVal":"","fromSchool":"' + acc.Id + '","transferCreditCourse":"","transferCreditGrade":"","courseOutcome":"","creditsEarnedMonth":"","creditsEarnedYear":""}],"assets":[{"recordIdVal":"' + assetId + '","docNotInEnglish":true,"nameOnDoc":"Name on Document - 1","nameOnDocIsDifferent":true,"type":"Transfer Credit Transcript","parentAssetId":""}]}]]';
			AppForCertController.saveOtherMedicalSchools(jsonValues, assetIds, parentCaseId, caseId, tcIds, false);
		}
		Test.stopTest();
	}
	@isTest static void testsaveOtherInstitutionRecords() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			/*Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
			Account acc = new Account();
			acc.Name = TEST_ACOUNT;
			acc.recordTypeId = recordTypeIdAcc;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;*/
			Account acc = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name =: TEST_ACOUNT LIMIT 1];
			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Month__c = 'January';
			cats.Start_Year__c = '2020'; 
			cats.End_Month__c = 'March';
			cats.End_Year__c = '2021'; 
			cats.Degree_Issue_Month__c = 'April';
			cats.Degree_Issue_Year__c = '2021';
			insert cats;
			// Contact_Association_Type__c
            Id recordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
            Contact_Association_Type__c cat = new Contact_Association_Type__c();
            cat.recordTypeId 	= 	recordTypeIdCat;
            cat.Account__c 		= 	getContactId.AccountId;
            cat.Case__c 		=	caseObj.Id;
            cat.Contact__c		=	getContactId.Id;
			cat.Start_Month__c = 'January';
			cat.Start_Year__c = '2020'; 
			cat.End_Month__c = 'March';
			cat.End_Year__c = '2021'; 
			cat.Degree_Issue_Month__c = 'April';
			cat.Degree_Issue_Year__c = '2021';
            insert cat;
            system.assertEquals(cat.Case__c,caseObj.Id,'Case id is different than the assigned one');
			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass;
			String assetId = ass.Id;
			List<String> assetIds = new List<String> ();
			assetIds.add(ass.Id);
			String caseId = caseObj.Id;
			String parentCaseId = caseObj.Id;
			List<String> tcIds = new List<String> ();

			String jsonValues = '[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + cats.Id + '","otherSchool":"Other Institution","otherSchoolId":"' + acc.ID + '","schoolProgram":"","studentId":"","Specialty":"","fromDate":"2016-12-01","endDate":"2018-02-14","transferCreditsCheckbox":true,"tcWrapperList":[{"recordAppForCertController.IdVal":"","fromSchool":"' + acc.ID + '","transferCreditCourse":"asd","transferCreditGrade":"50","courseOutcome":"Pass","creditsEarnedMonth":"January","creditsEarnedYear":"2020"}],"assets":[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + assetId + '","docNotInEnglish":false,"nameOnDoc":"undefined","nameOnDocIsDifferent":false,"type":"Transfer Credit Transcript","parentAssetId":""}]}]';
            String jsonValues1 = '[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + cat.Id + '","otherSchool":"Other Institution","otherSchoolId":"' + acc.ID + '","schoolProgram":"","studentId":"","Specialty":"","fromDate":"2016-12-01","endDate":"2018-02-14","transferCreditsCheckbox":true,"tcWrapperList":[{"recordAppForCertController.IdVal":"","fromSchool":"' + acc.ID + '","transferCreditCourse":"asd","transferCreditGrade":"50","courseOutcome":"Pass","creditsEarnedMonth":"January","creditsEarnedYear":"2020"}],"assets":[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + assetId + '","docNotInEnglish":false,"nameOnDoc":"undefined","nameOnDocIsDifferent":false,"type":"Transfer Credit Transcript","parentAssetId":""}]}]';
			AppForCertController.saveOtherInstitutionRecords(jsonValues, assetIds, parentCaseId, caseId, tcIds, false);
            system.assertEquals('true',AppForCertController.saveOtherInstitutionRecords(jsonValues1, assetIds, parentCaseId, caseId, tcIds, false),'returned false and no output');
			AppForCertController.getStartEndAndDegreeMonthYear(String.valueOf(cats.Id),'Contact_Association_Type_Staging__c');
			AppForCertController.getStartEndAndDegreeMonthYear(String.valueOf(cat.Id),'Contact_Association_Type__c');
		}
		Test.stopTest();
	}
	@isTest static void testsaveOtherInstitutionRecordsRecordvalEmpty() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			/*Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();

			Account acc = new Account();
			acc.Name = TEST_ACOUNT;
			acc.recordTypeId = recordTypeIdAcc;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;*/
			Account acc = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name =: TEST_ACOUNT LIMIT 1];
			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass;
			String assetId = ass.Id;
			List<String> assetIds = new List<String> ();
			assetIds.add(ass.Id);
			String caseId = caseObj.Id;
			String parentCaseId = caseObj.Id;
			List<String> tcIds = new List<String> ();

			String jsonValues = '[{"recordIdVal":"","otherSchool":"Other Institution","otherSchoolId":"' + acc.ID + '","schoolProgram":"","studentId":"","Specialty":"","fromDate":"2016-12-01","endDate":"2018-02-14","transferCreditsCheckbox":true,"tcWrapperList":[{"recordIdVal":"","fromSchool":"' + acc.ID + '","transferCreditCourse":"asd","transferCreditGrade":"50","courseOutcome":"Pass","creditsEarnedMonth":"January","creditsEarnedYear":"2020"}],"assets":[{"recordIdVal":"' + assetId + '","docNotInEnglish":false,"nameOnDoc":"undefined","nameOnDocIsDifferent":false,"type":"Transfer Credit Transcript","parentAssetId":""}]}]';
			AppForCertController.saveOtherInstitutionRecords(jsonValues, assetIds, parentCaseId, caseId, tcIds, false);
		}
		Test.stopTest();
	}

	//--------------------------------------------------------//
	@isTest static void testgetContactId() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getContactId();
		}
		Test.stopTest();
	}
	@isTest static void testgetCaseId() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getCaseId();
		}
		Test.stopTest();
	}
	@isTest static void testgetContactAssociationTypeStaging() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		Boolean inputValue = true;
		System.runAs(testUser) {
			AppForCertController.getContactAssociationTypeStaging(inputValue);
		}
		Test.stopTest();
	}
	@isTest static void testcheckFinalTranscript() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		Boolean inputValue = true;
		System.runAs(testUser) {
			AppForCertController.checkFinalTranscript(inputValue);
		}
		Test.stopTest();
	}
	@isTest static void testcreateAssetIf() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();

		Contact testContact = new Contact(id = testUser.contactId, MailingCountry = 'Albania');
		update testContact;
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testContact.Id];

		// Content Version
		ContentVersion contentVersion_1 = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = CLIENT_PATH,
			VersionData = Blob.valueOf(TEST_CONTENT),
			IsMajorVersion = true
		);
		insert contentVersion_1;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

		String contentDocId = documents[0].Id;

		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;

		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		String caseId = caseObj.Id;
		String type = TRANSFER_CREDIT_TRANSCRIPT;
		String contactId = getContactId.Id;
		String contactAssociationType = cats.Id;
		String keyval = DIPLOMA_DOCUMENT;
		String parentkeyval = 'DIPLOMA NAME DOCUMENT';
		String val = keyval + '++' + parentkeyval;
		String examType = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;

		AppForCertController.createAsset(contentDocId, caseId, type, contactId, contactAssociationType, val, examType);

		Test.stopTest();
	}
	@isTest static void testcreateAssetElse() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();

		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

		// Content Version
		ContentVersion contentVersion_1 = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = CLIENT_PATH,
			VersionData = Blob.valueOf(TEST_CONTENT),
			IsMajorVersion = true
		);
		insert contentVersion_1;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

		String contentDocId = documents[0].Id;

		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;

		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		String caseId = caseObj.Id;
		String type = TRANSFER_CREDIT_TRANSCRIPT;
		String contactId = getContactId.Id;
		String contactAssociationType = '';
		String keyval = DIPLOMA_DOCUMENT;
		String parentkeyval = 'DIPLOMA NAME DOCUMENT';
		String val = keyval + '++' + parentkeyval;
		String examType = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;

		AppForCertController.createAsset(contentDocId, caseId, type, contactId, contactAssociationType, val, examType);

		Test.stopTest();
	}
	@isTest static void testupdateParentAssetIf() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, Name,AccountId from Contact where Id =: testUser.contactId];
			String contactId = getContactId.Id;
			Boolean isDeanLetter = true;
			String nameonDiplomaDocument = '';
			Boolean isDiplomaNameDifferent = false;
			Boolean isDiplomaNameinEnglish = true;

			String nameonDeanLetterDocument = '';
			Boolean isDeanLetterDifferent = false;
			Boolean isDeanLetterNameinEnglish = true;

			Boolean isFinalTranscriptRequired = true;
			String nameonFinalTranscriptDocument = getContactId.Name;
			Boolean isFinalMedicalTranscriptDifferent = false;
			Boolean isFinalMedicalTranscriptinEnglish = true;

			Date dateonDeanLetterDocument = null;
			Boolean showExamRegActionButtonToUpdate = true;
			AppForCertHelper.UpdateParentAssetWrapper wrpr = new AppForCertHelper.UpdateParentAssetWrapper(contactId, isDeanLetter, nameonDiplomaDocument, isDiplomaNameDifferent, isDiplomaNameinEnglish, nameonDeanLetterDocument, isDeanLetterDifferent, isDeanLetterNameinEnglish, isFinalTranscriptRequired, nameonFinalTranscriptDocument, isFinalMedicalTranscriptDifferent, isFinalMedicalTranscriptinEnglish, dateonDeanLetterDocument, showExamRegActionButtonToUpdate, False);
			String inputString = JSON.serialize(wrpr);
			Boolean couriercheckbox;
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst1;

			Asset asst2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				ParentId = asst1.Id,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst2;
			Asset asst4 = new Asset(
				Name = Constants.ASSET_TYPE_NAME_DOC,
				Status = Constants.ASSET_STATUS_INPROGRESS,
				Case__c = caseObj.Id,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
				Type__c = Constants.ASSET_TYPE_NAME_DOC,
				Azure_Storage_URL__c = 'https://testurl'
			);
			insert asst4;
			System.assert(asst4.Id != null, 'Failed to insert asset');
			List<String> azureUrlList = new List<String>();
			azureUrlList.add(asst4.Azure_Storage_URL__c);
			AppForCertController.updateParentAsset(inputString,couriercheckbox,false);
			String idRec = '' + asst2.Id;
			String notInEnglish = 'False';
			String nameOnTheDoc = 'UserName';
			String nameOnDocDifferent = 'No';
			String assetType = 'Diploma Document';
			String keyValue = 'Diploma Document';
			String parentKeyValue = '' + asst1.Id;
			String parentId = '' + asst1.Id;
			string deanLetterDate = 'TodayDate';
			AppForCertHelper.IncompleteAssetObjWrapper recVal = new AppForCertHelper.IncompleteAssetObjWrapper(idRec, notInEnglish, nameOnTheDoc, nameOnDocDifferent, assetType, keyValue, parentKeyValue, parentId, deanLetterDate);
			System.assertNotEquals(NULL, recVal);
		}
		Test.stopTest();
	}
	@isTest static void testupdateParentAssetElse() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Contact getContactId = [Select Id, Name, AccountId from Contact where Id =: testUser.contactId];
		Test.startTest();
		Case caseobj = new Case();
        caseobj.ContactId = getContactId.Id;
        caseobj.AccountId = getContactId.AccountId;
        caseobj.Internal_Status__c = 'Pending Review';
        caseobj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
        insert caseObj;
        
        Contact_Association_Type_Staging__c conAssType = new Contact_Association_Type_Staging__c();
        conAssType.Contact__c = getContactId.Id; 
		conAssType.IsDeanLetter__c = True; 
		conAssType.Courier_service_for_an_additional_fee__c = True;
        conAssType.Case__c = caseObj.Id;
		conAssType.Parent_Case__c = caseObj.Id;
        conAssType.Account__c = getContactId.AccountId;
        conAssType.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG).getRecordTypeId();
        insert conAssType;
		Id intakeCatsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
		Contact_Association_Type_Staging__c conIntake = new Contact_Association_Type_Staging__c();
        conIntake.Contact__c = getContactId.Id; 
		conIntake.IsDeanLetter__c = True; 
		conIntake.Courier_service_for_an_additional_fee__c = True;
        conIntake.Case__c = caseObj.Id;
		conIntake.Parent_Case__c = caseObj.Id;
        conIntake.Account__c = getContactId.AccountId;
        conIntake.RecordTypeId = intakeCatsRecordTypeId;
        insert conIntake;
		System.runAs(testUser) {
			String contactId = getContactId.Id;
			Boolean isDeanLetter = true;
			String nameonDiplomaDocument = '';
			Boolean isDiplomaNameDifferent = false;
			Boolean isDiplomaNameinEnglish = true;

			String nameonDeanLetterDocument = '';
			Boolean isDeanLetterDifferent = false;
			Boolean isDeanLetterNameinEnglish = true;

			Boolean isFinalTranscriptRequired = true;
			String nameonFinalTranscriptDocument = getContactId.Name;
			Boolean isFinalMedicalTranscriptDifferent = false;
			Boolean isFinalMedicalTranscriptinEnglish = true;

			Date dateonDeanLetterDocument = Date.newInstance(2020, 01, 10);
			Boolean showExamRegActionButtonToUpdate = true;
			AppForCertHelper.UpdateParentAssetWrapper wrpr = new AppForCertHelper.UpdateParentAssetWrapper(contactId, isDeanLetter, nameonDiplomaDocument, isDiplomaNameDifferent, isDiplomaNameinEnglish, nameonDeanLetterDocument, isDeanLetterDifferent, isDeanLetterNameinEnglish, isFinalTranscriptRequired, nameonFinalTranscriptDocument, isFinalMedicalTranscriptDifferent, isFinalMedicalTranscriptinEnglish, dateonDeanLetterDocument, showExamRegActionButtonToUpdate, False);
			String inputString = JSON.serialize(wrpr);
			Boolean couriercheckbox = false;			
			Asset asst4 = new Asset(
				Name = Constants.ASSET_TYPE_NAME_DOC,
				Status = Constants.ASSET_STATUS_INPROGRESS,
				Case__c = caseObj.Id,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				Type__c = Constants.ASSET_TYPE_NAME_DOC,
				Azure_Storage_URL__c = 'https://testurl'
			);
			insert asst4;
			System.assert(asst4.Id != null, 'Failed to insert asset');
			List<String> azureUrlList = new List<String>();
			azureUrlList.add(asst4.Azure_Storage_URL__c);
			System.assertEquals(AppForCertController.updateParentAsset(inputString,couriercheckbox,false), false, 'Assert Success!');
            AppForCertController.updtOrDltParentAsset(conAssType.Id, true, new Map<String, String>(), wrpr, true);
            AppForCertController.updtOrDltParentAsset(conAssType.Id, false, new Map<String, String>(), wrpr, false);
		}
		Test.stopTest();
	}
	@isTest static void testupdateParentAssetElse1() {
		//User testUser = [Select id, contactId from User where alias = 'flastt'];
		//Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
		Account accNew2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
		Contact connt = new Contact(AccountId = accNew2.Id, is_CIBIS_Origin__c = true, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
		upsert connt;
		User userParentNewOne = new User(alias='user145',email='test1235@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=connt.Id, timezonesidkey='America/Los_Angeles',username='tester523@unknownmail.com');
		insert userParentNewOne; 
		Test.startTest();
		System.runAs(userParentNewOne) {
			Case caseobj = new Case();
			caseobj.ContactId = connt.Id;
			caseobj.AccountId = connt.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			caseobj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
			insert caseObj;
			List <Contact_Association_Type_Staging__c> conAssTypeList = new List <Contact_Association_Type_Staging__c>();
			Contact_Association_Type_Staging__c conAssType = new Contact_Association_Type_Staging__c();
			conAssType.Contact__c = connt.Id; 
			conAssType.IsDeanLetter__c = True; 
			conAssType.Courier_service_for_an_additional_fee__c = True;
			conAssType.Case__c = caseObj.Id;
			conAssType.Parent_Case__c = caseObj.Id;
			conAssType.Account__c = connt.AccountId;
			conAssType.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG).getRecordTypeId();
			insert conAssType;
			conAssTypeList.add(conAssType);
			Id intakeCatsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
			Contact_Association_Type_Staging__c conIntake = new Contact_Association_Type_Staging__c();
			conIntake.Contact__c = connt.Id; 
			conIntake.IsDeanLetter__c = True; 
			conIntake.Courier_service_for_an_additional_fee__c = True;
			conIntake.Case__c = caseObj.Id;
			conIntake.Parent_Case__c = caseObj.Id;
			conIntake.Account__c = connt.AccountId;
			conIntake.RecordTypeId = intakeCatsRecordTypeId;
			insert conIntake;
			conAssTypeList.add(conIntake);
			String contactId = connt.Id;
			Boolean isDeanLetter = false;
			String nameonDiplomaDocument = '';
			Boolean isDiplomaNameDifferent = false;
			Boolean isDiplomaNameinEnglish = true;
			Boolean isFinalTranscriptRequired = false;
			String nameonDeanLetterDocument = '';
			Boolean isDeanLetterDifferent = false;
			Boolean isDeanLetterNameinEnglish = true;
			String nameonFinalTranscriptDocument = connt.Name;
			Boolean isFinalMedicalTranscriptDifferent = false;
			Boolean isFinalMedicalTranscriptinEnglish = true;
			Date dateonDeanLetterDocument = Date.newInstance(2020, 01, 10);
			Boolean showExamRegActionButtonToUpdate = true;
			AppForCertHelper.UpdateParentAssetWrapper wrpr = new AppForCertHelper.UpdateParentAssetWrapper(contactId, isDeanLetter, nameonDiplomaDocument, isDiplomaNameDifferent, isDiplomaNameinEnglish, nameonDeanLetterDocument, isDeanLetterDifferent, isDeanLetterNameinEnglish, isFinalTranscriptRequired, nameonFinalTranscriptDocument, isFinalMedicalTranscriptDifferent, isFinalMedicalTranscriptinEnglish, dateonDeanLetterDocument, showExamRegActionButtonToUpdate, False);
			String inputString = JSON.serialize(wrpr);
			Boolean couriercheckbox = false;
			Asset asst4 = new Asset(
				Name = Constants.ASSET_TYPE_NAME_DOC,
				Status = Constants.ASSET_STATUS_IN_PROGRESS,
				Case__c = caseObj.Id,
				Parent_Case__c = caseObj.Id,
				ContactId = connt.Id,
				Name_on_Document__c = connt.Name,
				Name_on_Document_is_Different__c  = false,
				InstallDate = System.Today(),
				Key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
				Type__c = Constants.ASSET_TYPE_NAME_DOC,
				Azure_Storage_URL__c = 'https://testurl'
			);
			insert asst4;
			System.assert(asst4.Id != null, 'Failed to insert asset');
			List<String> azureUrlList = new List<String>();
			azureUrlList.add(asst4.Azure_Storage_URL__c);
			AppForCertController.updateParentAsset(inputString,couriercheckbox,false);
			AppForCertController.updateFMSTParentAssetList(asst4,wrpr,String.valueOf(conIntake.Id));
		}
		Test.stopTest();
	}
	@isTest static void testdeleteAssetAndRelatedDocument() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();

		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

		// Content Version
		ContentVersion contentVersion_1 = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = CLIENT_PATH,
			VersionData = Blob.valueOf(TEST_CONTENT),
			IsMajorVersion = true
		);
		insert contentVersion_1;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;

		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		//Create and Insert Asset
		Asset ass = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = getContactId.AccountId,
			ContactId = getContactId.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert ass;

		ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.ShareType = 'V';
		contentlink.LinkedEntityId = ass.id;
		contentlink.ContentDocumentId = documents[0].Id;
		insert contentlink;

		AppForCertController.deleteAssetAndRelatedDocument(ass.ContactId, ass.key__c, ass.Contact_Association_Type_Staging__c);
		Test.stopTest();
	}
	@isTest static void testgetDocument() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();

		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

		// Content Version
		ContentVersion contentVersion_1 = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = CLIENT_PATH,
			VersionData = Blob.valueOf(TEST_CONTENT),
			IsMajorVersion = true
		);
		insert contentVersion_1;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;

		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		//Create and Insert Asset
		Asset ass = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = getContactId.AccountId,
			ContactId = getContactId.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert ass;

		ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.ShareType = 'V';
		contentlink.LinkedEntityId = ass.id;
		contentlink.ContentDocumentId = documents[0].Id;
		insert contentlink;

		String contactId = ass.ContactId;
		String keyval = ass.key__c;
		String contactAssociationType = cats.Id;
		String parentId = cats.Case__c;
		AppForCertController.getDocument(contactId, keyval, contactAssociationType, parentId);

		Test.stopTest();
	}
	@isTest static void testgetContactName() {
		Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		User testUser = [Select id, contactId from User where alias = 'flastt'];		
		Test.startTest();
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		Account acc5 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew' LIMIT 1];		
		String contactId = getContactId.Id;
		AppForCertController.getContactName(contactId);
		AppForCertController.searchOtherInstitutions('EntityAcctNameNew'); 
		Test.stopTest();
	}
	@isTest static void testcheckIsDeanLetter() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();

		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;

		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		String contactAssociationStagingId = cats.id;

		AppForCertController.checkIsDeanLetter(contactAssociationStagingId);

		Test.stopTest();
	}
	@isTest static void testgetPrimaryAssets() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass;

			String contactId = ass.ContactId;
			String keyVal = ass.key__c;

			AppForCertController.getPrimaryAssets(contactId, keyVal);
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocument1() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass;

			String contactId = ass.ContactId;
			String keyVal = ass.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
			AppForCertController.getAssetStatus(String.valueOf(ass.Id));
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocumentElse1() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;
			//Create and Insert Asset
			Asset ass = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id,
				Name_on_Document__c = 'Test'
			);
			insert ass;
			String contactId = ass.ContactId;
			String keyVal = ass.key__c;
			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocument2() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass2;

			String contactId = ass2.ContactId;
			String keyVal = ass2.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocumentElse2() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id,
				Name_on_Document__c = 'Test'
			);
			insert ass2;

			String contactId = ass2.ContactId;
			String keyVal = ass2.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocument3() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocumentElse3() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id,
				Name_on_Document__c = 'Test'
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocument4() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocumentElse4() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id,
				Name_on_Document__c = 'Test'
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocument5() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocumentElse5() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id,
				Name_on_Document__c = 'Test'
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocument6() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetNameonDocumentElse6() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;

			//Create and Insert Asset
			Asset ass3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = getContactId.AccountId,
				ContactId = getContactId.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
				Contact_Association_Type_Staging__c = cats.Id,
				Name_on_Document__c = 'Test'
			);
			insert ass3;

			String contactId = ass3.ContactId;
			String keyVal = ass3.key__c;

			AppForCertController.getAssetNameonDocument(contactId, keyVal, '');
		}
		Test.stopTest();
	}

	@isTest static void testyearsAttended() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {

			Account acc = new Account();
			acc.Name = TEST_ACOUNT;
			acc.Basic_Sciences_Duration__c = 24;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;

			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.RecordTypeId = recordTypeId;
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = false;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 1;
			cats.Number_of_Years_Attended__c = 2;
			insert cats;

			List<Contact_Association_Type_Staging__c > conAssocDegreeMedicalSchoolLists = new List<Contact_Association_Type_Staging__c > ();
			conAssocDegreeMedicalSchoolLists.add(cats);

			String caseId = caseObj.Id;

			AppForCertController.yearsAttended(caseId, false);
			AppForCertController.yearsAttendedRefactorContDMSCurriYears(conAssocDegreeMedicalSchoolLists);
			AppForCertController.yearsAttendedRefactorCont(caseId, conAssocDegreeMedicalSchoolLists);
		}
		Test.stopTest();
	}
	@isTest static void testyearsAttendedMedicalSchool() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {

			Account acc = new Account();
			acc.Name = TEST_ACOUNT;
			acc.Curriculum_Duration__c = 4;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;

			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			String caseId = caseObj.Id;
			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.RecordTypeId = recordTypeId;
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseId;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 1;
			cats.Number_of_Years_Attended__c = 2;
			insert cats;

			AppForCertController.yearsAttended(caseId, false);
		}
		Test.stopTest();
	}
	@isTest static void testyearsAttendedOtherInstitution() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			Account acc = new Account();
			acc.Name = TEST_ACOUNT;
			acc.Curriculum_Duration__c = 4;
			acc.BillingCountry = 'India';
			acc.BillingState='Kerala';
			acc.billingpostalcode = '123456';
			insert acc;

			Contact getContactId = new Contact();
			getContactId.FirstName = 'Test';
			getContactId.LastName = 'Test';
			getContactId.Accountid = acc.id;
			insert getContactId;

			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = getContactId.Id;
			caseobj.AccountId = getContactId.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			String caseId = caseObj.Id;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.RecordTypeId = recordTypeId;
			cats.Account__c = getContactId.AccountId;
			cats.Case__c = caseId;
			cats.Contact__c = getContactId.Id;
			cats.Transfer_Credit_to_Degree_School__c = true;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 1;
			cats.Number_of_Years_Attended__c = 4;
			insert cats;

			AppForCertController.yearsAttended(caseId, false);
		}
		Test.stopTest();
	}
	@isTest static void testmanageReporterQuestionValue() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {
			String fieldvals = '{"ECFMG_Reporter__c":true}';
			AppForCertController.manageReporterQuestionValue(fieldvals);
			AppForCertController.getReporterQuestionValue();
		}
		Test.stopTest();
	}

	@isTest static void testcreateTermsRecord() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {

			Product2 prod = new Product2();
			prod.Name = 'End User Legal Terms - AppForCert';
			insert prod;

			Terms_and_Conditions__c termsCond = new Terms_and_Conditions__c();
			termsCond.Copy__c = '';
			termsCond.Name = '';
			termsCond.Status__c = 'Active';
			termsCond.Product__c = prod.Id;
			termsCond.ExpirationDate__c = Date.newInstance(2020, 01, 10);
			insert termsCond;

			AppForCertController.createTermsRecord(constants.PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS);
		}
		Test.stopTest();
	}
	@isTest static void testgetOtherMedicalSchoolsWithTransferCredits() {
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
		Account accNew2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
		Contact conn = new Contact(AccountId = accNew2.Id, is_CIBIS_Origin__c = true, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
		upsert conn;
		User userNewOne = new User(alias='user145',email='test12@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=conn.Id, timezonesidkey='America/Los_Angeles',username='tester52@unknownmail.com');
		insert userNewOne;  
		List<Case> caseList = new List<Case>();  
		Test.startTest();
		System.runAs(userNewOne) {
			Case caseobj = new Case();
			caseobj.ContactId = userNewOne.ContactId;
			caseobj.Graduate_affirmation_required__c = False;
			caseobj.Transfer_credit_affirmation_required__c = False;
			caseobj.recordTypeId = idAppForCertCaseRecordTypeId;
			caseobj.AccountId = userNewOne.Contact.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			caseList.add(caseObj);
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.contact__c = conn.Id;
			cats.Account__c = conn.AccountId;
			cats.Parent_Case__c  = caseobj.Id;
			cats.Case__c = caseobj.Id;
			cats.Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE;
			cats.RecordTypeId = catsRecordTypeId; 
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;
			//Create and Insert Asset
			Asset assetCats = new Asset(
				Name = 'Test CAT Asset',
				Status = 'Verified',
				AccountId = conn.AccountId,
				ContactId = conn.Id,
				RecordTypeId = assetRecordTypeId,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert assetCats;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = conn.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = conn.AccountId,
				From_School__c = conn.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;
			AppForCertController.getOtherMedicalSchoolsWithTransferCredits(false, true, String.valueOf(caseobj.Id));
		}
		Test.stopTest();
	}
	@isTest static void testisApplicantGraduate() {
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
		Account accNew2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
		Contact conn = new Contact(AccountId = accNew2.Id, is_CIBIS_Origin__c = true, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
		upsert conn;
		User userNewOne = new User(alias='user145',email='test12@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=conn.Id, timezonesidkey='America/Los_Angeles',username='tester52@unknownmail.com');
		insert userNewOne;  
		List<Case> caseList = new List<Case>();  
		Test.startTest();
		System.runAs(userNewOne) {
			Case caseobj = new Case();
			caseobj.ContactId = userNewOne.ContactId;
			caseobj.Graduate_affirmation_required__c = False;
			caseobj.Transfer_credit_affirmation_required__c = False;
			caseobj.recordTypeId = idAppForCertCaseRecordTypeId;
			caseobj.AccountId = userNewOne.Contact.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			caseList.add(caseObj);
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.contact__c = conn.Id;
			cats.Account__c = conn.AccountId;
			cats.Parent_Case__c  = caseobj.Id;
			cats.Case__c = caseobj.Id;
			cats.Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE;
			cats.RecordTypeId = catsRecordTypeId; 
			cats.Transfer_Credit_to_Degree_School__c = false;
			insert cats;
			AppForCertController.isApplicantGraduate(false, true);
		}
		Test.stopTest();		
	}
	@isTest static void testgetAssetsAndDocuments() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;
		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Parent_Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		String recId = cats.Id;
		//Create and Insert Asset
		Asset ass1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = getContactId.AccountId,
			ContactId = getContactId.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert ass1;
		Asset ass = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = getContactId.AccountId,
			ContactId = getContactId.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			ParentId = ass1.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert ass;
		// Content Version
		ContentVersion contentVersion_1 = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = CLIENT_PATH,
			VersionData = Blob.valueOf(TEST_CONTENT),
			IsMajorVersion = true
		);
		insert contentVersion_1;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.ShareType = 'V';
		contentlink.LinkedEntityId = ass.id;
		contentlink.ContentDocumentId = documents[0].Id;
		insert contentlink;
		AppForCertController.getAssetsAndDocuments(recId);
		Test.stopTest();
	}	
	@isTest static void testgetOtherMedicalSchool() {
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
		Account accNew2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
		Contact connt = new Contact(AccountId = accNew2.Id, is_CIBIS_Origin__c = true, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
		upsert connt;
		User userParentNewTestOne = new User(alias='user1456',email='test1235@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=connt.Id, timezonesidkey='America/Los_Angeles',username='tester523@unknownmail.com');
		insert userParentNewTestOne; 
		Test.startTest();
		System.runAs(userParentNewTestOne) {
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = connt.Id;
		caseobj.AccountId = connt.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
		List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = connt.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Parent_Case__c = caseObj.Id;
		cats.Contact__c = connt.Id;
		cats.Status__c = 'Graduate';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		catsList.add(cats);		
		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = connt.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		//Create and Insert Asset
		Asset asstRdx1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Parent_key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx1;
		Asset asstRdx2 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
			Parent_key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx2;
		Asset asstRdx3 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
			Parent_key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx3;
		Asset asstRdx4 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT,
			Parent_key__c = 'FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT',
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx4;
		Asset asstRdx5 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
			Parent_key__c = 'DEAN LETTER DOCUMENT',
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx5;

		Asset asstRdx6 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
			Parent_key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx6;
		Asset asstRdx7 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
			Parent_key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx7;
		Asset asstRdx8 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT,
			Parent_key__c = 'FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT',
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx8;
		Asset asstRdx9 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			AccountId = connt.AccountId,
			Case__c = caseObj.Id,
			Parent_Case__c = caseObj.Id,
			ContactId = connt.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
			Parent_key__c = 'DEAN LETTER DOCUMENT',
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRdx9;
			AppForCertController.getOtherMedicalSchool();
			AppForCertController.updateCatIDinAssetFMD(String.valueOf(cats.Id),asstRdx2.key__c,asstRdx2.Parent_key__c,asstRdx2.Azure_Storage_URL__c);
			AppForCertController.updateCatIDinAssetFMD(String.valueOf(cats.Id),asstRdx3.key__c,asstRdx3.Parent_key__c,asstRdx3.Azure_Storage_URL__c);
			AppForCertController.updateCatIDinAssetFMD(String.valueOf(cats.Id),asstRdx4.key__c,asstRdx4.Parent_key__c,asstRdx4.Azure_Storage_URL__c);
			AppForCertController.updateCatIDinAssetFMD(String.valueOf(cats.Id),asstRdx5.key__c,asstRdx5.Parent_key__c,asstRdx5.Azure_Storage_URL__c);
			AppForCertController.updateCatIDinAsset(String.valueOf(cats.Id),String.valueOf(connt.Id),asstRdx6.key__c,asstRdx6.Parent_key__c);
			AppForCertController.updateCatIDinAsset(String.valueOf(cats.Id),String.valueOf(connt.Id),asstRdx7.key__c,asstRdx7.Parent_key__c);
			AppForCertController.updateCatIDinAsset(String.valueOf(cats.Id),String.valueOf(connt.Id),asstRdx8.key__c,asstRdx8.Parent_key__c);
			AppForCertController.updateCatIDinAsset(String.valueOf(cats.Id),String.valueOf(connt.Id),asstRdx9.key__c,asstRdx9.Parent_key__c);
			AppForCertController.createGradNameOrTransDocPayloadFMD(String.valueOf(connt.Id),asstRdx2.key__c,asstRdx2.Parent_key__c);
			AppForCertController.createGradNameOrTransDocPayloadFMD(String.valueOf(connt.Id),asstRdx3.key__c,asstRdx3.Parent_key__c);
			AppForCertController.createGradNameOrTransDocPayloadFMD(String.valueOf(connt.Id),asstRdx4.key__c,asstRdx4.Parent_key__c);
			AppForCertController.createGradNameOrTransDocPayloadFMD(String.valueOf(connt.Id),asstRdx5.key__c,asstRdx5.Parent_key__c);
			AppForCertController.createGradNameOrTransDocPayload(String.valueOf(connt.Id),asstRdx2.key__c);
			AppForCertController.createGradNameOrTransDocPayload(String.valueOf(connt.Id),asstRdx3.key__c);
			AppForCertController.createGradNameOrTransDocPayload(String.valueOf(connt.Id),asstRdx4.key__c);
			AppForCertController.createGradNameOrTransDocPayload(String.valueOf(connt.Id),asstRdx5.key__c);
		}
		Test.stopTest();
	}
	@isTest static void testgetAssetsAndDocumentsForOtherMedical() {
		User testUser = [Select id, contactId from User where alias = 'user4'];
		Test.startTest();
		System.runAs(testUser) {
			Map<String, Map<String, String>> result = new Map<String, Map<String, String>> ();
			result = AppForCertController.getAssetsAndDocumentsForOtherMedical();
			//AppForCertController.paymentCompletion();
		}
		Test.stopTest();
		
	}
	@isTest static void testgetAssetsAndDocumentsForOtherMedical1() {		
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
		Account accNew2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
		Contact connt = new Contact(AccountId = accNew2.Id, is_CIBIS_Origin__c = true, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
		upsert connt;
		User userParentNewTwo = new User(alias='user105',email='test12035@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=connt.Id, timezonesidkey='America/Los_Angeles',username='tester5233@unknownmail.com');
		insert userParentNewTwo; 
		Test.startTest();
		System.runAs(userParentNewTwo) {
			Case caseobj = new Case();
			caseobj.ContactId = connt.Id;
			caseobj.AccountId = connt.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			caseobj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
			insert caseObj;
			List <Contact_Association_Type_Staging__c> conAssTypeList = new List <Contact_Association_Type_Staging__c>();
			Contact_Association_Type_Staging__c conAssType = new Contact_Association_Type_Staging__c();
			conAssType.Contact__c = connt.Id; 
			conAssType.IsDeanLetter__c = True; 
			conAssType.Courier_service_for_an_additional_fee__c = True;
			conAssType.Case__c = caseObj.Id;
			conAssType.Parent_Case__c = caseObj.Id;
			conAssType.Account__c = connt.AccountId;
			conAssType.Is_Reopened_Exam_Reg__c = FALSE;
			conAssType.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
			insert conAssType;
			Asset asst4 = new Asset(
				Name = Constants.ASSET_TYPE_NAME_DOC,
				Status = Constants.ASSET_STATUS_IN_PROGRESS,
				Case__c = caseObj.Id,
				Parent_Case__c = caseObj.Id,
				ContactId = connt.Id,
				InstallDate = System.Today(),
				Key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
				Type__c = Constants.ASSET_TYPE_NAME_DOC,
				Azure_Storage_URL__c = 'https://testurl',
				IsOrphan__c = False,
				Is_Expired_Exam_Reg__c = False,
				Contact_Association_Type_Staging__c = conAssType.Id
			);
			insert asst4;
			System.assert(asst4.Id != null, 'Failed to insert asset');
			Affirmation__c affm = new Affirmation__c ();
			affm.Asset__c = asst4.Id;
			affm.Credential_Verification_Status__c = Constants.CASE_STATUS;
			affm.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId(); 
			affm.Contact_Association_Type_Staging__c = conAssType.Id;
			insert affm;        
			Map<String, Map<String, String>> result = new Map<String, Map<String, String>> ();
			result = AppForCertController.getAssetsAndDocumentsForOtherMedical();
		}
		Test.stopTest();
	}
	@isTest static void testCreateAssetforIncompleteCase() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;
		System.assert(caseObj != null,'Case Inserted');
		// Contact_Association_Type_Staging__c
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.Account__c = getContactId.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = getContactId.Id;
		cats.Transfer_Credit_to_Degree_School__c = true;
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		System.assert(cats != null,'Cats Inserted');
		//Create and Insert Asset
		Asset ass1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = getContactId.AccountId,
			ContactId = getContactId.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert ass1;
		Asset ass = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = getContactId.AccountId,
			ContactId = getContactId.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			ParentId = ass1.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert ass;

		// Content Version
		ContentVersion contentVersion_1 = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = CLIENT_PATH,
			VersionData = Blob.valueOf(TEST_CONTENT),
			IsMajorVersion = true
		);
		insert contentVersion_1;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.ShareType = 'V';
		contentlink.LinkedEntityId = ass.id;
		contentlink.ContentDocumentId = documents[0].Id;
		insert contentlink;
		AppForCertController.createAssetForIncompleteCaseProcessing(documents[0].Id, ass.Id, 'Final Medical Diploma', cats.Id, DIPLOMA_DOCUMENT);
		AppForCertHelper.createAssetForInc(ass.Id, DIPLOMA_DOCUMENT);
		string val = '[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + cats.Id + '","tcWrapperList":[],"assets":[{"' + Constants.APPFORCERT_TESTCLS_RECORDIDVAL + '":"' + ass.Id + '","docNotInEnglish":true,"nameOnDoc":"uhuk","nameOnDocIsDifferent":true,"type":"Letter from Dean","deanDate":"2020-02-07","parentAssetId":""}]}]';
		AppForCertController.saveIncompleteRecords(val, caseObj.Id);
		Test.stopTest();
	}
	@isTest static void testpaymentCompletion() {
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
		//User testUser = [Select id, contactId,Contact.AccountId from User where alias = 'user3'];
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
		Account accNew2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
		Contact conn = new Contact(AccountId = accNew2.Id, is_CIBIS_Origin__c = true, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
		upsert conn;
		User userNewOne = new User(alias='user145',email='test12@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=conn.Id, timezonesidkey='America/Los_Angeles',username='tester52@unknownmail.com');
		insert userNewOne;  
		List<Case> caseList = new List<Case>();  
		Test.startTest();
		System.runAs(userNewOne) {
			Case caseobj = new Case();
			caseobj.ContactId = userNewOne.ContactId;
			caseobj.Graduate_affirmation_required__c = False;
			caseobj.Transfer_credit_affirmation_required__c = False;
			caseobj.recordTypeId = idAppForCertCaseRecordTypeId;
			caseobj.AccountId = userNewOne.Contact.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			caseList.add(caseObj);
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.contact__c = conn.Id;
			cats.Account__c = conn.AccountId;
			cats.Case__c = caseobj.Id;
			cats.Status__c = 'Student';//Constants.CONASCTYPESTG_STATUS_GRADUATE;
			cats.RecordTypeId = catsRecordTypeId; 
			cats.Transfer_Credit_to_Degree_School__c = false;
			insert cats;
		    cadmus_core__Data_Source__c dataSource = new cadmus_core__Data_Source__c();
			dataSource.Name = 'AppForCert Data Source';
			dataSource.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('KEYVALUE').getRecordTypeId();
			dataSource.cadmus_core__Type__c = 'Single sObject';
			insert dataSource;
			cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
			docConfig.Name = 'AppForCert Summary';
			docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
			docConfig.cadmus_core__Delivery_option__c = 'BASE64';
			insert docConfig;      
			System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record!');    
			List<cadmus_core__Doc_Config__c> docConfigList = new List<cadmus_core__Doc_Config__c>();
			docConfigList.add(docConfig);
		  AppForCertController.paymentCompletion();
		}
		Test.stopTest();
	}
	@isTest static void testgetMetadataId() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getMetadataId();
		}
		Test.stopTest();
	}
	@isTest static void testgetCaseNumber() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getCaseNumber();
		}
		Test.stopTest();
	}
	@isTest static void testdeleteExamRegDegMedSchool() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			//AppForCertController.deleteExamRegRecordTypeRecords();
		}
		Test.stopTest();
	}
	@isTest static void testdeleteExamRegDegMedSchoolGraduate() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE;
			insert cats;

			AppForCertController.deleteExamRegRecordTypeRecords();
		}
		Test.stopTest();
	}

	@isTest static void testdeleteGraduateAssets() {

		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			string contctId = string.valueof(con.id);
			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			insert cats;

			Transfer_Credit__c tc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert tc;

			//Create and Insert Asset
			List<Asset> assetList = new List<Asset> ();
			Id recordTypeIdAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Application_for_Certification').getRecordTypeId();
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				RecordTypeId = recordTypeIdAsset,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Letter from Dean',
				Contact_Association_Type_Staging__c = cats.Id
			);
			assetList.add(asst1);

			Asset asst2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Dean_s_Letter_Date__c = Date.today() + 50,
				Contact_Association_Type_Staging__c = cats.Id
			);
			assetList.add(asst2);
			Asset asst3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Alternate Graduation Document',
				Dean_s_Letter_Date__c = Date.today() + 50,
				Contact_Association_Type_Staging__c = cats.Id
			);
			assetList.add(asst3);

			insert assetList;
			AppForCertController.getDlDate();
			AppForCertController.deleteGraduateAssets(contctId, cats.Id);
		}
		Test.stopTest();
	}

	@isTest static void testcontactAssTypeMigration() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		System.runAs(testUser) {
			List<case >caseList = new List<case >();
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			caseList.add(caseObj);
			List<String> checkCases = new List<String>();
			Case caseobj3 = new Case();
			caseobj3.RecordTypeId = appForCertRecordTypeId;
			caseobj3.ContactId = con.Id;
			caseobj3.AccountId = con.AccountId;
			caseobj3.Internal_Status__c = 'Pending Review';
			insert caseObj3;
			Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Eligibility_Period_Extension').getRecordTypeId();
			Case caseobj2 = new Case();
			caseobj2.ContactId = con.Id;
			caseobj2.AccountId = con.AccountId;
			caseobj2.ParentId = caseobj.Id;
			caseobj2.Internal_Status__c = 'Pending Submission';
			caseobj2.Enrollment_Verification_Parent__c = caseobj3.Id;
			caseobj2.RecordTypeId = recTypeId;
			insert caseObj2;
			checkCases.add(caseObj.Id);
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Status__c = 'Student';
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cats;
			Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = recordTypeIdCat;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cat;
			Transfer_Credit__c tc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert tc;
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				Case__c = caseObj.Id,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id
			);
			insert asst1;
			AppForCertController.contactAssTypeMigration(caseList);
			System.assertNotEquals(checkCases, NULL, 'Not NULL');
			AppForCertController.refactorEpexExamCase(checkCases);
        }

		Test.stopTest();
	}

	@isTest static void testsendMailForAcceptedStatus() {
		Test.startTest();
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		insert caseObj;
		System.assert(caseObj.id!=null,'case not inserted');
		AppForCertController.sendMailForAcceptedStatus(con.id, caseObj.Id);
		Test.stopTest();
	}

	@isTest static void testpreviousLicenseUpdate() {

		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

		Id recordTypeId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
		string selectedOption = 'Option2';

		//contact Staging
		Contact_Staging__c csRecords = new Contact_Staging__c(
			contact__c = con.Id,
			recordTypeId = recordTypeId);
		insert csRecords;

		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.previousLicenseUpdate(selectedOption);
			selectedOption = 'Option1';
			AppForCertController.previousLicenseUpdate(selectedOption);
		}
		Test.stopTest();
	}

	@isTest static void testpreviousLicenseUpdateNoContactStaging() {

		User testUser = [Select id, contactId from User where alias = 'user3'];

		string selectedOption = 'Option2';

		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.previousLicenseUpdate(selectedOption);
		}
		Test.stopTest();
	}

	@isTest static void testerrorMessageOFACContact() {
		User testUser = [Select Id, ContactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.errorMessageOFACContact();
		}
		Test.stopTest();
	}

	@isTest static void testgetAllConstants() {
		Test.startTest();
		AppForCertController.getAllConstants();
		Test.stopTest();
	}

	@isTest static void testgetIncompleteCase() {
    Test.startTest();
    Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
    Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
    //Account accNew1 = new Account(Name='TestNameNew12',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123469');
    //upsert accNew1;  
    Account accNew1 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
    Contact con4 = new Contact(AccountId = accNew1.Id, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
    upsert con4;
    User userNew = new User(alias='user15',email='test51@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=con4.Id, timezonesidkey='America/Los_Angeles',username='tester5@unknownmail.com_');
        insert userNew;
    System.assert(userNew.id != null,'User does not exist');
    System.runAs(userNew) {
      Contact con = [Select id, AccountId from Contact where ID =: userNew.contactId];
      // Case
      Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
      Case caseobj = new Case();
      caseobj.RecordTypeId = appForCertRecordTypeId;
      caseobj.ContactId = con.Id;
      caseobj.AccountId = con.AccountId;
      caseobj.Internal_Status__c = 'Incomplete';
      insert caseObj;
      AppForCertController.getIncompleteCase();
    }
    Test.stopTest();
  }

	@isTest static void testisApplicantStudentOrGraduate() {
    Test.startTest();
    Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
    Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
    Account accNew = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
    Contact con5 = new Contact(AccountId = accNew.Id, Firstname='firstname55', Lastname='lastname55', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
    upsert con5;
    User userNew2 = new User(alias='user5',email='test@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=con5.Id, timezonesidkey='America/Los_Angeles',username='tester5@unknownmail.com');
        insert userNew2;
    System.assert(userNew2.id != null,'User does not exist');
    System.runAs(userNew2) {
      AppForCertController.isApplicantStudentOrGraduate();
    }
    Test.stopTest();
  }

	@isTest static void testreSubmitAppforCert() {
		User testUser = [Select id, contactId from User where alias = 'second'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();

			// Case
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Accepted';
			caseobj.RecordTypeId = idAppForCertCaseRecordTypeId;
			insert caseObj;
			//Case caseobj = [Select Id from Case WHERE Internal_Status__c='Accepted' AND RecordTypeId =: idAppForCertCaseRecordTypeId];
			Id conAssocStagingDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
			Id conAssocStagingExamRegDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
			Id conAssocStagingExamRegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Medical_School').getRecordTypeId();
			Id conAssocStagingExamRegOtherInst = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Other_Institution').getRecordTypeId();

			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats1 = new Contact_Association_Type_Staging__c();
			cats1.recordTypeId = conAssocStagingDegMedSch;
			cats1.Account__c = con.AccountId;
			cats1.Case__c = caseObj.Id;
			cats1.Contact__c = con.Id;
			insert cats1;

			Contact_Association_Type_Staging__c cats2 = new Contact_Association_Type_Staging__c();
			cats2.recordTypeId = conAssocStagingExamRegDegMedSch;
			cats2.Account__c = con.AccountId;
			cats2.Case__c = caseObj.Id;
			cats2.Parent_Case__c = caseObj.Id;
			cats2.Contact__c = con.Id;
			cats2.Status__c = 'Graduate';
			cats2.IsDeanLetter__c = true;
			insert cats2;
			Contact_Association_Type_Staging__c cats3 = new Contact_Association_Type_Staging__c();
			cats3.recordTypeId = conAssocStagingExamRegMedSch;
			cats3.Account__c = con.AccountId;
			cats3.Case__c = caseObj.Id;
			cats3.Contact__c = con.Id;
			cats3.Transfer_Credit_to_Degree_School__c = true;
			insert cats3;
			Contact_Association_Type_Staging__c cats4 = new Contact_Association_Type_Staging__c();
			cats4.recordTypeId = conAssocStagingExamRegOtherInst;
			cats4.Account__c = con.AccountId;
			cats4.Case__c = caseObj.Id;
			cats4.Parent_Case__c = caseObj.Id;
			cats4.Contact__c = con.Id;
			insert cats4;
			Id assetrecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Application_for_Certification').getRecordTypeId();
			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				Type__c = 'Pre-Med Letter',
				Contact_Association_Type_Staging__c = cats4.Id,
				RecordTypeId = assetrecordTypeId
			);
			insert asst1;

			Asset asst2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats4.Id,
				ParentId = asst1.Id,
				RecordTypeId = assetrecordTypeId
			);
			insert asst2;

			Asset asst3 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				Type__c = TRANSFER_CREDIT_TRANSCRIPT,
				Contact_Association_Type_Staging__c = cats4.Id,
				RecordTypeId = assetrecordTypeId
			);
			insert asst3;

			Asset asst4 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats4.Id,
				ParentId = asst3.Id,
				RecordTypeId = assetrecordTypeId
			);
			insert asst4;

			Asset asst5 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				Type__c = 'Alternate Graduation Document',
				Contact_Association_Type_Staging__c = cats2.Id,
				RecordTypeId = assetrecordTypeId
			);
			insert asst5;
			/*List<cadmus_core__Doc_Config__c> docConfigList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c 
													FROM cadmus_core__Doc_Config__c 
													WHERE Name = 'AppForCert Summary'];*/
			cadmus_core__Data_Source__c dataSource = new cadmus_core__Data_Source__c();
			dataSource.Name = 'AppForCert Data Source';
			dataSource.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('KEYVALUE').getRecordTypeId();
			dataSource.cadmus_core__Type__c = 'Single sObject';
			insert dataSource;
			cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
			docConfig.Name = 'AppForCert Summary';
			docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
			docConfig.cadmus_core__Delivery_option__c = 'BASE64';
			insert docConfig;			
			System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record!');		
			List<cadmus_core__Doc_Config__c> docConfigList = new List<cadmus_core__Doc_Config__c>();
			docConfigList.add(docConfig);											
			AppForCertController.getInstAssetsAndDocumentsRecBased(cats4.Id);
			AppForCertController.getInstAssetsAndDocuments(true, false);
			AppForCertController.getGraduateOnlyRecords(true, false, false);
			AppForCertController.getSelectedValues(true);
			AppForCertHelper.getSelectedValuesPart();
			System.assert(AppForCertHelper.getSelectedValuesPart().size() > 0,'Degree school values');
			//AppForCertController.reSubmitAppforCert();
			AppForCertController.getOtherMedicalSchoolsWithTransferCredits(true, false,caseObj.Id);
			AppForCertController.getOtherInstitutionsWithTransferCredits(true, false,caseObj.Id);			
		}
		Test.stopTest();
	}
	@isTest static void testreSubmitAppforCertStudent() {
		User testUser = [Select id, contactId from User where alias = 'second'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
			// Case
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Accepted';
			caseobj.RecordTypeId = idAppForCertCaseRecordTypeId;
			insert caseObj;
			//Case caseobj = [Select Id from Case WHERE Internal_Status__c='Accepted' AND RecordTypeId =: idAppForCertCaseRecordTypeId];
			Id conAssocStagingExamRegDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
			Id conAssocStagingExamRegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Medical_School').getRecordTypeId();
			// Contact_Association_Type_Staging__c
			Contact_Association_Type_Staging__c cats2 = new Contact_Association_Type_Staging__c();
			cats2.recordTypeId = conAssocStagingExamRegDegMedSch;
			cats2.Account__c = con.AccountId;
			cats2.Case__c = caseObj.Id;
			cats2.Contact__c = con.Id;
			insert cats2;
			Contact_Association_Type_Staging__c cats3 = new Contact_Association_Type_Staging__c();
			cats3.recordTypeId = conAssocStagingExamRegMedSch;
			cats3.Account__c = con.AccountId;
			cats3.Case__c = caseObj.Id;
			cats3.Contact__c = con.Id;
			insert cats3;
			cadmus_core__Data_Source__c dataSource = new cadmus_core__Data_Source__c();
			dataSource.Name = 'AppForCert Data Source';
			dataSource.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('KEYVALUE').getRecordTypeId();
			dataSource.cadmus_core__Type__c = 'Single sObject';
			insert dataSource;
			cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
			docConfig.Name = 'AppForCert Summary';
			docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
			docConfig.cadmus_core__Delivery_option__c = 'BASE64';
			insert docConfig;			
			System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record!');		
			List<cadmus_core__Doc_Config__c> docConfigList = new List<cadmus_core__Doc_Config__c>();
			docConfigList.add(docConfig);	
			AppForCertController.reSubmitAppforCert();
		}
		Test.stopTest();
	}
	@isTest static void testgetContactAssociationForCaseDetail() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			// Case
			Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.RecordTypeId = appForCertRecordTypeId;
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = recordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Start_Date__c = System.today();
			cat.End_Date__c = System.today() + 20;
			insert cat;
			ID caseId = [SELECT id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
			AND ContactId =: con.Id order by CreatedDate Desc LIMIT 1].Id;
			AppForCertController.getContactAssociationForCaseDetail();
			AppForCertController.getCaseIdAllStatus(true, con.Id);
			System.assertEquals(AppForCertController.getCaseIdAllStatus(false, con.Id),caseId,'Case id is different');
			AppForCertController.getContactDetails();
		}
		Test.stopTest();
	}
	@isTest static void testOtherMedSchoolFalse() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = recordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Number_of_Years_Attended__c = 3.0;
			cats.School_Program__c = 'MBBS';
			cats.Student_ID__c = 'MBBS0001';
			cats.Specialty__c = 'MBBSMASTER';
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1;

			//Create and Insert Asset
			Asset asst2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1.Id
			);
			insert asst2;

			Transfer_Credit__c tcredit = new Transfer_Credit__c();
			tcredit.Applicant__c = con.Id;
			tcredit.Case__c = caseObj.Id;
			tcredit.Contact_Association_Type_Staging__c = cats.Id;
			tcredit.From_School__c = con.AccountId;
			tcredit.To_School__c = con.AccountId;
			tcredit.Transfer_Credit_Course__c = 'TEST';
			tcredit.Transfer_Credit_Grade__c = 'A';
			tcredit.Credits_Earned_Year__c = '2020';
			tcredit.Credits_Earned_Month__c = 'MAY';
			insert tcredit;

			string tempOtherSchoolId = cats.Account__c;
			string tempTransferCreditsCheckbox = String.valueOf(cats.Transfer_Credit_to_Degree_School__c);

			Contact_Association_Type_Staging__c catsObject = [SELECT Id, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r)
				FROM Contact_Association_Type_Staging__c WHERE ID =: cats.Id
			];

			AppForCertController.getOtherMedSchoolConAssocTypeStaging(false);
			AppForCertController.getOtherMedSchoolConAssocTypeStagingRefactorMethod(catsObject, tempOtherSchoolId, tempTransferCreditsCheckbox);
		}
		Test.stopTest();
	}
	@isTest static void testOtherMedSchoolTrue() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG).getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = catsRecordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Number_of_Years_Attended__c = 3.0;
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;

			Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;

			//Create and Insert Asset
			Asset asst1 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1;

			//Create and Insert Asset
			Asset asst2 = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1.Id
			);
			insert asst2;

			Transfer_Credit__c tcredit = new Transfer_Credit__c();
			tcredit.Applicant__c = con.Id;
			tcredit.Case__c = caseObj.Id;
			tcredit.Contact_Association_Type_Staging__c = cats.Id;
			tcredit.From_School__c = con.AccountId;
			tcredit.To_School__c = con.AccountId;
			tcredit.Transfer_Credit_Course__c = 'TEST';
			tcredit.Transfer_Credit_Grade__c = 'A';
			tcredit.Credits_Earned_Year__c = '2020';
			tcredit.Credits_Earned_Month__c = 'MAY';
			insert tcredit;

			AppForCertController.getOtherMedSchoolConAssocTypeStaging(true);

			/********************************************************************************/

			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Start_Date__c = System.today();
			cat.End_Date__c = System.today() + 20;
			cat.Number_of_Years_Attended__c = 3.0;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;

			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;

			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;

			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1.Id
			);
			insert asst2Cat;

			string tempOtherSchoolId = cat.Account__c;
			string tempTransferCreditsCheckbox = String.valueOf(cat.Transfer_Credit_to_Degree_School__c);

			Contact_Association_Type__c catObject = [SELECT Id, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r)
				FROM Contact_Association_Type__c WHERE ID =: cat.Id
			];

			AppForCertController.getOtherMedSchoolConAssocType();
			AppForCertController.getOtherMedSchoolConAssocTypeRefactorMethod(catObject, tempOtherSchoolId, tempTransferCreditsCheckbox);
			AppForCertController.tcGradeMethod(tccCat);
			AppForCertController.tcCourseMethod(tccCat);
		}
		Test.stopTest();
	}
	@isTest static void testOtherMedSchoolTrueEmptyValues() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;

			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;

			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;

			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst2Cat;

			AppForCertController.getOtherMedSchoolConAssocType();
		}
		Test.stopTest();
	}
	@isTest static void testOtherInstitutionFalse() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = catsRecordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Number_of_Years_Attended__c = 3.0;
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;

			Transfer_Credit__c tccCats = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCats;

			//Create and Insert Asset
			Asset asst1Cats = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cats;

			//Create and Insert Asset
			Asset asst2Cats = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cats.Id
			);
			insert asst2Cats;

			AppForCertController.getOtherInstitutionConAssocTypeStaging(false);
		}
		Test.stopTest();
	}
	@isTest static void testOtherInstitutionTrue() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type_Staging__c
			Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG).getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = catsRecordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Number_of_Years_Attended__c = 3.0;
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;

			Transfer_Credit__c tccCats = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type_Staging__c = cats.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCats;

			//Create and Insert Asset
			Asset asst1Cats = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cats;

			//Create and Insert Asset
			Asset asst2Cats = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type_Staging__c = cats.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cats.Id
			);
			insert asst2Cats;

			string tempOtherSchoolId = cats.Account__c;

			AppForCertController.getOtherInstitutionConAssocTypeStaging(true);

			Contact_Association_Type_Staging__c catsObject = [SELECT Id, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId, Azure_Storage_URL__c FROM Assets__r)
				FROM Contact_Association_Type_Staging__c WHERE ID =: cats.Id
			];

			AppForCertController.getOtherInstitutionConAssocTypeStagingRefactorMethod(catsObject, tempOtherSchoolId);
			AppForCertController.getOtherInstitutionConAssocTypeStagingRefactorAssetList(catsObject);

			/*******************************************************************************/
			/*******************************************************************************/

			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Start_Date__c = System.today();
			cat.End_Date__c = System.today() + 20;
			cat.Number_of_Years_Attended__c = 3.0;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;

			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;

			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;

			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst2Cat;

			AppForCertController.getOtherInstitutionConAssocType();
		}
		Test.stopTest();
	}
	@isTest static void testOtherInstitutionTrueEmptyValues() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;

			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;

			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;

			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst2Cat;

			AppForCertController.getOtherInstitutionConAssocType();
		}
		Test.stopTest();
	}

	@isTest static void testExamRegistrationCheckOnStatus() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseRec = new Case();
			caseRec.ContactId = con.Id;
			caseRec.recordTypeId = caseRecordTypeId;
			caseRec.AccountId = con.AccountId;
			caseRec.Internal_Status__c = 'Pending Review';
			insert caseRec;

			// Contact_Association_Type_Staging__c
			Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG).getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = catsRecordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseRec.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cats.Start_Date__c = System.today();
			cats.End_Date__c = System.today() + 20;
			cats.Number_of_Years_Attended__c = 3.0;
			cats.Transfer_Credit_to_Degree_School__c = true;
			insert cats;

			// Contact_Association_Type__c
			Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = recordTypeIdCat;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseRec.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			insert cat;

			Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
			Case newCase = new Case(
				RecordTypeId = examRegRecordTypeId,
				ContactId = con.Id,
				Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
				Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
			);
			insert newCase;

			Case newCase2 = new Case(
				RecordTypeId = examRegRecordTypeId,
				ContactId = con.Id,
				Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
				Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS
			);
			insert newCase2;

			Exam_Registration__c updateExamRegistration5 = new Exam_Registration__c();
			updateExamRegistration5.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
			updateExamRegistration5.Test_Accommodations_needed__c = 'yes';
			updateExamRegistration5.Visa_Letter_Needed__c = true;
			updateExamRegistration5.case__c = newCase2.Id;
			updateExamRegistration5.Applicant__c = con.Id;
			insert updateExamRegistration5;

			newCase2.Exam_Registration__c = updateExamRegistration5.Id;
			update newCase2;

			caseRec.Internal_Status__c = 'Rejected';
			update caseRec;
		}
		Test.stopTest();
	}
	@isTest static void testGetApplicationStatusRec() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			AppForCertController.getApplicationStatus();
		}
		Test.stopTest();
	}

	@isTest static void testCheckIfCertified(){
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser){
			system.assertNotEquals(AppForCertController.checkIfCertified(), true, 'An ECFMG Certified Case exists erroneously');
		}
		Test.stopTest();
	}
	@isTest static void testUpdateIncompleteAssetsRfctr() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;

			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;

			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;

			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = Constants.ASSET_STATUS_INCOMPLETE,
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst2Cat;
			List<Asset> assetList = new List<Asset> ();
			assetList.add(asst1Cat);
			assetList.add(asst2Cat);
			AppForCertController.updateIncompleteAssetsRfctr(assetList);
		}
		Test.stopTest();
	}

	@isTest static void testUpdateParAssetList() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			System.assertNotEquals(con.Id, NULL, 'Not NULL');
			Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
			String contactId = getContactId.Id;
			Boolean isDeanLetter = true;
			String nameonDiplomaDocument = '';
			Boolean isDiplomaNameDifferent = false;
			Boolean isDiplomaNameinEnglish = true;
			String nameonDeanLetterDocument = '';
			Boolean isDeanLetterDifferent = false;
			Boolean isDeanLetterNameinEnglish = true;
			Boolean isFinalTranscriptRequired = true;
			String nameonFinalTranscriptDocument = '';
			Boolean isFinalMedicalTranscriptDifferent = false;
			Boolean isFinalMedicalTranscriptinEnglish = true;
			Date dateonDeanLetterDocument = null;
			Boolean showExamRegActionButtonToUpdate = true;
			AppForCertHelper.UpdateParentAssetWrapper wrpr = new AppForCertHelper.UpdateParentAssetWrapper(contactId, isDeanLetter, nameonDiplomaDocument, isDiplomaNameDifferent, isDiplomaNameinEnglish, nameonDeanLetterDocument, isDeanLetterDifferent, isDeanLetterNameinEnglish, isFinalTranscriptRequired, nameonFinalTranscriptDocument, isFinalMedicalTranscriptDifferent, isFinalMedicalTranscriptinEnglish, dateonDeanLetterDocument, showExamRegActionButtonToUpdate, False);
			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;
			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;
			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;
			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;
			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = Constants.ASSET_STATUS_INCOMPLETE,
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = 'DEAN LETTER DOCUMENT',
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst2Cat;
			//Create and Insert Asset
			Asset asst3Cat = new Asset(
				Name = ASSET_NAME,
				Status = Constants.ASSET_STATUS_INCOMPLETE,
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = 'Final Medical School Transcript',
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst3Cat;
			// Contact_Association_Type_Staging__c
			List <Contact_Association_Type_Staging__c> conAssType = new List <Contact_Association_Type_Staging__c>();
			Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG).getRecordTypeId();
			Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
			cats.recordTypeId = catsRecordTypeId;
			cats.Account__c = con.AccountId;
			cats.Case__c = caseObj.Id;
			cats.Contact__c = con.Id;
			cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			conAssType.add(cats);
			insert conAssType;
			System.assert(!conAssType.isEmpty(), 'Records Inserted');
			Map<String, String> checkMap = new Map<String, String> ();
			checkMap.put(asst1Cat.Key__c, asst1Cat.Id);
			checkMap.put(asst2Cat.Key__c, asst2Cat.Id);
			checkMap.put(asst3Cat.Key__c, asst3Cat.Id);
			List<asset> asst1CatList1 = AppForCertController.updateParentAssetList(asst1Cat, wrpr,conAssType);
			List<asset> asst1CatList2 = AppForCertController.updateParentAssetList(asst2Cat, wrpr,conAssType);
			List<asset> asst1CatList3 = AppForCertController.updateParentAssetList(asst3Cat, wrpr,conAssType);
			system.assertEquals(asst1CatList1[0].Id,asst1Cat.Id,'Asset is not the same');
			system.assertEquals(asst1CatList2[0].Id,asst2Cat.Id,'Asset is not the same here');
			system.assertEquals(asst1CatList3[0].Id,asst3Cat.Id,'Asset is not the same here too');
			
		}
		Test.stopTest();
	}

	@isTest static void testcreateTermsRecordCheck() {
		User testUser = [Select id, contactId from User where alias = 'flastt'];
		Test.startTest();
		System.runAs(testUser) {

			Product2 prod = new Product2();
			prod.Name = 'End User Legal Terms - RegionChange';
			insert prod;

			Terms_and_Conditions__c termsCond = new Terms_and_Conditions__c();
			termsCond.Copy__c = '';
			termsCond.Name = '';
			termsCond.Status__c = 'Active';
			termsCond.Product__c = prod.Id;
			termsCond.ExpirationDate__c = Date.newInstance(2020, 01, 10);
			insert termsCond;

			Product2 prod2 = new Product2();
			prod2.Name = 'End User Legal Terms - EPeX';
			insert prod2;

			Terms_and_Conditions__c termsCond2 = new Terms_and_Conditions__c();
			termsCond2.Copy__c = '';
			termsCond2.Name = '';
			termsCond2.Status__c = 'Active';
			termsCond2.Product__c = prod2.Id;
			termsCond2.ExpirationDate__c = Date.newInstance(2020, 01, 10);
			insert termsCond2;

			Product2 prod3 = new Product2();
			prod3.Name = 'End User Legal Terms - ExamReg';
			insert prod3;

			Terms_and_Conditions__c termsCond3 = new Terms_and_Conditions__c();
			termsCond3.Copy__c = '';
			termsCond3.Name = '';
			termsCond3.Status__c = 'Active';
			termsCond3.Product__c = prod3.Id;
			termsCond3.ExpirationDate__c = Date.newInstance(2020, 01, 10);
			insert termsCond3;

			Product2 prod4 = new Product2();
			prod4.Name = 'End User Legal Terms - TranscriptRequest';
			insert prod4;

			Terms_and_Conditions__c termsCond4 = new Terms_and_Conditions__c();
			termsCond4.Copy__c = '';
			termsCond4.Name = '';
			termsCond4.Status__c = 'Active';
			termsCond4.Product__c = prod4.Id;
			termsCond4.ExpirationDate__c = Date.newInstance(2020, 01, 10);
			insert termsCond4;

			Product2 prod5 = new Product2();
			prod5.Name = 'End User Legal Terms - ScoreRecheck';
			insert prod5;

			Terms_and_Conditions__c termsCond5 = new Terms_and_Conditions__c();
			termsCond5.Copy__c = '';
			termsCond5.Name = '';
			termsCond5.Status__c = 'Active';
			termsCond5.Product__c = prod5.Id;
			termsCond5.ExpirationDate__c = Date.newInstance(2020, 01, 10);
			insert termsCond5;

			AppForCertController.createTermsRecord(constants.PRODUCT_NAME_EXAM_REGISTRATION_LEGAL_TERMS);
			AppForCertController.createTermsRecord(constants.PRODUCT_NAME_EPEX_LEGAL_TERMS);
			AppForCertController.createTermsRecord(constants.PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS);

			AppForCertController.createTermsRecord(constants.PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS);
			AppForCertController.createTermsRecord(constants.PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS);
		}
		Test.stopTest();
	}

	@isTest static void testGetGraduateOnlyRecordsRefactorMedDiploma() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Test.startTest();
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

			// Case
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.recordTypeId = caseRecordTypeId;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Pending Review';
			insert caseObj;

			// Contact_Association_Type__c
			Id catRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
			Contact_Association_Type__c cat = new Contact_Association_Type__c();
			cat.recordTypeId = catRecordTypeId;
			cat.Account__c = con.AccountId;
			cat.Case__c = caseObj.Id;
			cat.Contact__c = con.Id;
			cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
			cat.Transfer_Credit_to_Degree_School__c = true;
			insert cat;

			Transfer_Credit__c tccCat = new Transfer_Credit__c(
				Applicant__c = con.Id,
				Case__c = caseObj.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con.AccountId,
				From_School__c = con.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tccCat;

			//Create and Insert Asset
			Asset asst1Cat = new Asset(
				Name = ASSET_NAME,
				Status = 'Installed',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst1Cat;

			//Create and Insert Asset
			Asset asst2Cat = new Asset(
				Name = ASSET_NAME,
				Status = Constants.ASSET_STATUS_INCOMPLETE,
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Contact_Association_Type__c = cat.Id,
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test',
				ParentId = asst1Cat.Id
			);
			insert asst2Cat;
			List<Asset> assetList = new List<Asset> ();
			assetList.add(asst1Cat);
			assetList.add(asst2Cat);
			AppForCertController.getGradMedDiploma(assetList, '' + asst1Cat.Id);
			Map<String, String> output = AppForCertController.getGradTranscript(assetList, '' + asst1Cat.Id);
			System.assertNotEquals(NULL, output);
		}
		Test.stopTest();
	}

	@isTest static void testGetAssetStatusAndType() {
    Test.startTest();
    Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
    Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
    Account accNew11 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];     
    Contact con41 = new Contact(AccountId = accNew11.Id, Firstname='firstname6', Lastname='lastname6', Birthdate=date.valueOf('2000-01-02'), email='emailtest5@gmail.com', MailingCountry='India',School_Enrollment_Status__c='Graduate');
    upsert con41;
    User userNew1 = new User(alias='user15',email='test1@gmail.com',emailencodingkey='UTF-8',lastname='lastname5', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=con41.Id, timezonesidkey='America/Los_Angeles',username='tester51@unknownmail.com');
        insert userNew1;
    System.assert(userNew1.id != null,'User does not exist');    
    //User testUser = [Select id, contactId from User where alias = 'userApp'];
    String keyVal = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
    System.runAs(userNew1) {
      Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
      Case csAppForCert = new Case(AccountId=accNew11.Id,ContactId=con41.Id,Service__c='EPIC',Internal_Status__c='Accepted',RecordTypeId=idAppForCertCaseRecordTypeId,Graduate_affirmation_required__c = false,Transfer_credit_affirmation_required__c = false);
      insert csAppForCert;
      Id conAssocStagingDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
      Contact_Association_Type_Staging__c catsRecord = new Contact_Association_Type_Staging__c(RecordTypeId=conAssocStagingDegMedSch,contact__c = con41.Id, Account__c=accNew11.id,case__c=csAppForCert.Id, IsDeanLetter__c = true, Status__c = 'Graduate',Transfer_Credit_to_Degree_School__c = false, Is_Reopened_Exam_Reg__c = false);
      insert catsRecord;
      List<Contact_Association_Type_Staging__c > catsToUpdate = new List<Contact_Association_Type_Staging__c > ();
      catsToUpdate.add(catsRecord);
      Id conAssocDegMedSch = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
      Contact_Association_Type__c catRecord =  new Contact_Association_Type__c(RecordTypeId = conAssocDegMedSch, Account__c = accNew11.Id, contact__c = con41.Id);
      Insert catRecord;
      List<Contact_Association_Type__c > catDegMedSchoolRecord = new List<Contact_Association_Type__c>();
      catDegMedSchoolRecord.add(catRecord);
      System.assert(catRecord.id!=null, 'Failed to get the record ');
      String assetName = 'Letter from Dean';
      cadmus_core__Data_Source__c dataSource = new cadmus_core__Data_Source__c();
      dataSource.Name = 'AppForCert Data Source';
      dataSource.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('KEYVALUE').getRecordTypeId();
      dataSource.cadmus_core__Type__c = 'Single sObject';
      insert dataSource;
      cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
      docConfig.Name = 'AppForCert Summary';
      docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
      docConfig.cadmus_core__Delivery_option__c = 'BASE64';
      insert docConfig;      
      System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record!');    
      List<cadmus_core__Doc_Config__c> docConfigList = new List<cadmus_core__Doc_Config__c>();
      docConfigList.add(docConfig);
      AppForCertController.getAssetStatusAndType(string.valueof(userNew1.contactId), string.valueOf(catRecord.Id), assetName);
      AppForCertController.getAssetNameonDocument(string.valueof(userNew1.contactId), keyVal, string.valueOf(catRecord.Id));
      AppForCertController.reSubmitAppforCert();
    }
    Test.stopTest();
  }

	@isTest static void testupdateExpiredAssets() {
		Test.startTest();
		//AppforCertTestFactory.servicePageSetup2();
		//User testUser = [Select id, contactId from User where alias = 'userApp'];
		User testUser = [Select id, contactId from User where alias = 'user3'];	
		System.runAs(testUser) {
			Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
			Asset assts = new Asset(
				Name = ASSET_NAME,
				Status = 'Expired',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert assts;
			system.assert(assts.id!=null, 'Asset not inserted');
			Asset asst2 = new Asset(
				Name = 'Asset Name here',
				Status = 'Expired',
				AccountId = con.AccountId,
				ContactId = con.Id,
				InstallDate = System.Today(),
				UsageEndDate = System.Today(),
				key__c = DIPLOMA_DOCUMENT,
				Type__c = 'Translation',
				Document_is_not_in_English__c = true,
				Name_on_Document__c = 'Test',
				Name_on_Document_is_Different__c = true,
				Parent_Key__c = 'Test'
			);
			insert asst2;
			List<Asset> myAssetList = new List<Asset> ();
			myAssetList.add(assts);
			myAssetList.add(asst2);
			AppForCertController.updateExpiredAssets(myAssetList);
		}
		Test.stopTest();
	}

	@isTest static void testrefactorExamRegn() {

		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

		Test.startTest();

		List<String> caseList = new List<String> ();
		// Case
		Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Case caseobj2 = new Case();
		caseobj2.RecordTypeId = appForCertRecordTypeId;
		caseobj2.ContactId = con.Id;
		caseobj2.AccountId = con.AccountId;
		caseobj2.Internal_Status__c = 'Pending Review';
		insert caseObj2;
		Case caseobj = new Case();
		caseobj.RecordTypeId = appForCertRecordTypeId;
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Pending Review';
		caseobj.Enrollment_Re_Verification_Parent__c = caseObj2.Id;
		insert caseObj;
		caseList.add(caseObj.Id + '');

		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Student';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;

		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;

		//Create and Insert Asset
		Asset asst9 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asst9;
		System.runAs(testUser) {
			AppForCertController.refactorExamRegn(caseList);
		}

		Test.stopTest();
	}
	@isTest static void testStudentNotPendingCibis() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		//Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		//Account act1 = new Account(Name = 'EntityTestAcctName', RecordTypeId = identityAccountRecordTypeId, School__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		//insert act1;
		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		caseList.add(caseObj);
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Student';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		System.assert(cat.Id != null, 'Fail to insert cat Record!');
		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		//Create and Insert Asset
		Asset asset1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asset1;
		AppForCertController.contactAssTypeMigration(caseList);
		Test.stopTest();
	}

	@isTest static void teststudentExamRegNotRegistered() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		// EV Case  - INSERT
		Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
		Case evCase = new Case();
		evCase.ContactId = con.Id;
		evCase.AccountId = con.AccountId;
		evCase.Internal_Status__c = 'New';
		evCase.RecordTypeId = evRecordTypeId;
		insert evCase;
		System.assert(evCase.Id != null, ASSERT_CASE_INSERT);
		// Exam Reg Case - INSERT
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		Case examRegCase = new Case();
		examRegCase.ContactId = con.Id;
		examRegCase.AccountId = con.AccountId;
		examRegCase.Internal_Status__c = 'Pending Enrollment Verification';
		examRegCase.RecordTypeId = examRegRecordTypeId;
		examRegCase.Enrollment_Verification_Parent__c = evCase.Id;
		insert examRegCase;
		System.assert(examRegCase.Id != null, ASSERT_CASE_INSERT);
		List<Case> examRegCaseList = new List<Case> ();
		examRegCaseList.add(examRegCase);
		AppForCertController.studentExamRegNotRegistered(con.Id, new Contact_Association_Type_Staging__c(), examRegCaseList);
		Test.stopTest();
	}

	@isTest static void testOtherMedicalSchoolPdftronUploads() {

		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];

		test.startTest();

		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		System.assert(caseObj.Id != null, ASSERT_CASE_INSERT);

		caseList.add(caseObj);

		// Exam Reg Case - INSERT
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		Case examRegCase = new Case();
		examRegCase.ContactId = con.Id;
		examRegCase.AccountId = con.AccountId;
		examRegCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
		examRegCase.RecordTypeId = examRegRecordTypeId;
		insert examRegCase;

		cadmus_core__Doc_Config__c docConfig1 = new cadmus_core__Doc_Config__c();
		docConfig1.Name = 'EnrollReverification Case Template';
		docConfig1.cadmus_core__CustomerDocumentConfigId__c = '46b34380-9e1a-4401-a102-07ec5d4d66ad';
		insert docConfig1;

		// EV Case  - INSERT
		Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
		Case evCase = new Case();
		evCase.ContactId = con.Id;
		evCase.AccountId = con.AccountId;
		evCase.Internal_Status__c = 'New';
		evCase.RecordTypeId = evRecordTypeId;
		insert evCase;

		// Exam Reg Case - UPDATE 1
		Case examRegCase1 = new Case();
		examRegCase1.Id = examRegCase.Id;
		examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
		update examRegCase1;

		// Enrollment Reverification Case  - INSERT
		Id ervRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
		Case ervCase = new Case();
		ervCase.ContactId = con.Id;
		ervCase.AccountId = con.AccountId;
		ervCase.Internal_Status__c = 'New';
		ervCase.RecordTypeId = ervRecordTypeId;
		insert ervCase;

		// Exam Reg Case - UPDATE 2
		Case examRegCase2 = new Case();
		examRegCase2.Id = examRegCase.Id;
		examRegCase2.Enrollment_Re_Verification_Parent__c = ervCase.Id;
		update examRegCase2;

		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Graduate';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;

		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;

		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		List<Asset> assetList = new List<Asset> ();
		//Create and Insert Asset
		Asset asstR1 = new Asset(
			Name = 'TCT Translation',
			Status = Constants.ASSET_STATUS_IN_PROGRESS,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			Type__c = 'Translation'
		);

		Asset asstR3 = new Asset(
			Name = Constants.ASSET_TYPE_NAME_DOC,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			Type__c = Constants.ASSET_TYPE_NAME_DOC
		);
		asstR3.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		assetList.add(asstR1);
		assetList.add(asstR3);
		insert assetList;
		AppForCertController.retrieveTctTranslationId(con.Id, caseObj.Id);
		AppForCertController.retrieveNameDocId(con.Id, caseObj.Id);
		AppForCertController.markAssetsForDeletion(asstR3.id);
		test.stopTest();

	}
	@isTest static void testMarkAssetsForDeletionFromUrls(){
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		test.startTest();
			Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
			// Case
			Case caseobj = new Case();
			caseobj.ContactId = con.Id;
			caseobj.AccountId = con.AccountId;
			caseobj.Internal_Status__c = 'Accepted';
			caseobj.RecordTypeId = appCertRecordTypeId;
			insert caseObj;
			System.assert(caseObj.Id != null, ASSERT_CASE_INSERT);
			Asset asst8 = new Asset(
				Name = Constants.ASSET_TYPE_NAME_DOC,
				Status = Constants.ASSET_STATUS_INPROGRESS,
				Case__c = caseObj.Id,
				ContactId = con.Id,
				InstallDate = System.Today(),
				Type__c = Constants.ASSET_TYPE_NAME_DOC,
				Azure_Storage_URL__c = 'https://testurl'
			);
			insert asst8;
			System.assert(asst8.Id != null, 'Failed to insert asset');
			List<String> azureUrlList = new List<String>();
			azureUrlList.add(asst8.Azure_Storage_URL__c);
			AppForCertController.markAssetsForDeletionFromUrls(String.valueOf(azureUrlList));
			System.assert([SELECT Status FROM Asset WHERE Id = :asst8.Id].Status == Constants.ASSET_STATUS_MARKED_FOR_DELETION, 'asset not updated');
		test.stopTest();
	}
	@isTest static void testStudentPendingCibis() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		//Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		//Account act = new Account(Name = 'testEntityAcctName', RecordTypeId = identityAccountRecordTypeId, School__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		//insert act;
		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		caseList.add(caseObj);
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Student';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		System.assert(cats.Id != null, 'Fail to insert Cats Record!');
		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		//Create and Insert Asset
		Asset asstRc1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRc1;
		AppForCertController.contactAssTypeMigration(caseList);
		Test.stopTest();
	}
	@isTest static void testStudentExamRegRegistered(){
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		// Exam Reg Case - INSERT
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		Case examRegCase = new Case();
		examRegCase.ContactId = con.Id;
		examRegCase.AccountId = con.AccountId;
		examRegCase.Internal_Status__c = 'Registered';
		examRegCase.RecordTypeId = examRegRecordTypeId;
		insert examRegCase;
		System.assert(examRegCase.Id != null, ASSERT_CASE_INSERT);
		// EV Case  - INSERT
		Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
		Case evCase = new Case();
		evCase.ContactId = con.Id;
		evCase.AccountId = con.AccountId;
		evCase.Internal_Status__c = 'New';
		evCase.RecordTypeId = evRecordTypeId;
		insert evCase;
		System.assert(evCase.Id != null, ASSERT_CASE_INSERT);
		// Exam Reg Case - UPDATE 1
		Case examRegCase1 = new Case();
		examRegCase1.Id = examRegCase.Id;
		examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
		update examRegCase1;
		System.assert(examRegCase1.Id != null, ASSERT_CASE_INSERT);
		List<Case> examRegCaseList = new List<Case> ();
		examRegCaseList.add(examRegCase1);
		// Exam Registration Object (Exam_Registration__c)
		Map<Id, Exam_Registration__c > examRegCaseMap = new Map<Id, Exam_Registration__c > ();
		Exam_Registration__c examRegObject = new Exam_Registration__c();
		examRegObject.Applicant__c = con.Id;
		examRegObject.Case__c = examRegCase.Id;
		examRegObject.Exam_taken_date__c = null;
		examRegObject.Exam_Status__c = null;
		examRegObject.Exam_Types__c = 'USMLE Step 1';
		insert examRegObject;
		System.assert(examRegObject.Id != null, 'Fail to insert exam reg Record!');
		examRegCaseMap.put(examRegObject.Case__c, examRegObject);
		AppForCertController.studentExamRegRegistered(con.Id, new Contact_Association_Type_Staging__c(), examRegCaseList, examRegCaseMap);
		Test.stopTest();
	}
	@isTest static void testGraduateNotPendingCibis() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		System.assert(caseObj.Id != null, 'Fail to insert Case Record here!');
		caseList.add(caseObj);
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Graduate';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Graduation_Year__c = '2021';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		List<Asset> assetList = new List<Asset> ();
		//Create and Insert Asset
		Asset asstRcr1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		INSERT asstRcr1;
		AppForCertController.contactAssTypeMigration(caseList);
		String catDegMedSchoolAccountId = cat.Account__c;
		String catSchoolEnrlmentStatus = cat.Status__c;
		String catsSchoolEnrlmentStatus = cats.Status__c;
		AppForCertController.appForCertAccepted(caseList, catDegMedSchoolAccountId, catSchoolEnrlmentStatus, cats);
		AppForCertController.appForCertAcceptedGraduate(con.Id, catSchoolEnrlmentStatus, catsSchoolEnrlmentStatus);
		Test.stopTest();
	}
	@isTest static void testGraduatePendingCibis() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		caseList.add(caseObj);
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Graduate';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		//Create and Insert Asset
		Asset assts1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert assts1;
		AppForCertController.contactAssTypeMigration(caseList);
		String catDegMedSchoolAccountId = cat.Account__c;
		String catSchoolEnrlmentStatus = cat.Status__c;
		String catsSchoolEnrlmentStatus = cats.Status__c;
		AppForCertController.appForCertAccepted(caseList, catDegMedSchoolAccountId, catSchoolEnrlmentStatus, cats);
		AppForCertController.appForCertAcceptedGraduate(con.Id, catSchoolEnrlmentStatus, catsSchoolEnrlmentStatus);
		Test.stopTest();
	}

	@isTest static void testCheckValidationSummary() {
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-02');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p = [Select id from profile where name = '4-Customer Community Plus Login'
			LIMIT 1
		].id;
		string firstname5 = 'First5';
		string lastname5 = 'Last5';
		string emailtest5 = 'tester5@unknownmail1.com';
		String username5 = 'tester5@unknownmail.com_' + System.now();
		username5 = username5.replace(' ', '').replace(':', '-');
		//Account acc5 = new Account(Name = 'EntityAcctNameNew', RecordTypeId = identityAccountRecordTypeId, School__c = false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		Account acc5 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew'];
		//upsert acc5;
		//System.assert(acc5.Id != null, 'Account ID is null');

		Contact con5 = new Contact(AccountId = acc5.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
		insert con5;

		User user5 = new User(alias = 'user5', email = emailtest5, emailencodingkey = 'UTF-8', lastname = lastname5, languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true, ContactId = con5.Id, timezonesidkey = 'America/Los_Angeles', username = username5);
		insert user5;

		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = acc5.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Accepted', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;
		List<Contact_Association_Type_Staging__c > catList = new List<Contact_Association_Type_Staging__c > ();

		Id conAssocStagingDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocTypeStaging = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocStagingDegMedSch, contact__c = con5.Id, Account__c = acc5.id, case__c = csAppForCert.Id, IsDeanLetter__c = true, Status__c = 'Graduate');
		catList.add(conAssocTypeStaging);

		Id conAssocExamRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocType1 = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocExamRecordTypeId, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id, IsDeanLetter__c = true, Status__c = 'Graduate');
		catList.add(conAssocType1);

		Id conAssocExamRecordTypeId1 = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG).getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocType2 = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocExamRecordTypeId1, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id, Transfer_Credit_to_Degree_School__c = true);
		catList.add(conAssocType2);

		Id conAssocExamRecordTypeId2 = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG).getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocType3 = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocExamRecordTypeId2, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id);
		catList.add(conAssocType3);

		Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId = conAssocRecordTypeId, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id);
		insert conAssocType;
		insert catList;

		List<Asset> assetList = new List<Asset> ();
		Asset assets1 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = acc5.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Contact_Association_Type_Staging__c = conAssocTypeStaging.Id
		);
		assetList.add(assets1);

		Asset assets2 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = acc5.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Contact_Association_Type_Staging__c = conAssocType1.Id
		);
		assetList.add(assets2);
		insert assetList;

		System.runAs(user5) {
			AppForCertController.checkGradValOnSummary();
			AppForCertController.checkStudValOnSummary();
			delete assets2;
			conAssocType2.Transfer_Credit_to_Degree_School__c = False;
			update conAssocType2;
			AppForCertController.checkGradValOnSummary();
			delete conAssocType3;
			AppForCertController.checkGradValOnSummary();
			conAssocType1.Status__c = 'Student';
			update conAssocType1;
			AppForCertController.checkStudValOnSummary();
		}
		Test.stopTest();
	}

	@isTest static void testCheckValPrimValScenario() {
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-12');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p = [Select id from profile where name = '4-Customer Community Plus Login'
			LIMIT 1
		].id;
		string firstname5 = 'First51';
		string lastname5 = 'Last51';
		string emailtest5 = 'testasdaer5@unknownmail1.com';
		String username5 = 'testersdf5@unknownmail.com_' + System.now();
		username5 = username5.replace(' ', '').replace(':', '-');
		//Account acc5 = new Account(Name = 'EntityAcctNameNew', RecordTypeId = identityAccountRecordTypeId, School__c = false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		Account acc5 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew'];
		//upsert acc5;
		//System.assert(acc5.Id != null, 'Account ID is null');

		Contact con5 = new Contact(AccountId = acc5.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
		insert con5;

		User user5 = new User(alias = 'user5', email = emailtest5, emailencodingkey = 'UTF-8', lastname = lastname5, languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true, ContactId = con5.Id, timezonesidkey = 'America/Los_Angeles', username = username5);
		insert user5;

		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = acc5.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Accepted', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;

		List<Contact_Association_Type_Staging__c > catList = new List<Contact_Association_Type_Staging__c > ();
		Id conAssocStagingDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocTypeStaging = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocStagingDegMedSch, contact__c = con5.Id, Account__c = acc5.id, case__c = csAppForCert.Id, IsDeanLetter__c = true, Status__c = 'Graduate');
		catList.add(conAssocTypeStaging);
		Id conAssocExamRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocType1 = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocExamRecordTypeId, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id, IsDeanLetter__c = true, Status__c = 'Student');
		catList.add(conAssocType1);
		Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId = conAssocRecordTypeId, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id);
		insert conAssocType;
		insert catList;

		List<Asset> assetList = new List<Asset> ();
		Asset asstNm1 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = acc5.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Contact_Association_Type_Staging__c = conAssocTypeStaging.Id
		);
		assetList.add(asstNm1);
		insert assetList;
		System.runAs(user5) {
			String returnVal = AppForCertController.checkGradValOnSummary();
			System.assertEquals('PrimaryValidation', returnVal, 'Else condition is not satisfied');
		}
		Test.stopTest();
	}

	@isTest static void testCheckValidationSummaryScenario2() {
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-02');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Id p = [Select id from profile where name = '4-Customer Community Plus Login'
			LIMIT 1
		].id;
		string firstname5 = 'First5';
		string lastname5 = 'Last5';
		string emailtest5 = 'tester5@unknownmail1.com';
		String username5 = 'tester5@unknownmail.com_' + System.now();
		username5 = username5.replace(' ', '').replace(':', '-');

		//Account acc5 = new Account(Name = 'EntityAcctNameNew', RecordTypeId = identityAccountRecordTypeId, School__c = false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		Account acc5 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew'];
		//upsert acc5;
		//System.assert(acc5.Id != null, 'Account ID is null');

		Contact con5 = new Contact(AccountId = acc5.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
		insert con5;

		User user5 = new User(alias = 'user5', email = emailtest5, emailencodingkey = 'UTF-8', lastname = lastname5, languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true, ContactId = con5.Id, timezonesidkey = 'America/Los_Angeles', username = username5);
		insert user5;

		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = acc5.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Accepted', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;
		List<Contact_Association_Type_Staging__c > catList = new List<Contact_Association_Type_Staging__c > ();

		Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId = conAssocRecordTypeId, contact__c = con5.Id, case__c = csAppForCert.Id, Account__c = acc5.id,
			Status__c = 'Student');
		insert conAssocType;

		Id conAssocExamRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c conAssocType1 = new Contact_Association_Type_Staging__c(RecordTypeId = conAssocExamRecordTypeId, contact__c = con5.Id,
			case__c = csAppForCert.Id, Account__c = acc5.id, IsDeanLetter__c = true, Status__c = 'Student'
		);
		catList.add(conAssocType1);

		insert catList;

		System.runAs(user5) {
			Boolean returnVal = AppForCertController.checkStudValOnSummary();
			System.assertEquals(True, returnVal, 'Existing and new records are not same');
		}

		Test.StopTest();
	}
	@isTest static void testGraduateEpexCaseUpdate() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		Test.startTest();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		caseList.add(caseObj);
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Graduate';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		Transfer_Credit__c tc = new Transfer_Credit__c(
			Applicant__c = con.Id,
			Case__c = caseObj.Id,
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert tc;
		//Create and Insert Asset
		Asset asstRd1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		insert asstRd1;
		AppForCertController.contactAssTypeMigration(caseList);
		Test.stopTest();
	}
	
	@isTest static void testGraduateEpexUpdate() {
		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		SET<Id> examRegCaseIdSet = new SET<Id> ();
		Test.startTest();
		// Exam Reg Case - INSERT
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		Case examRegCase = new Case();
		examRegCase.ContactId = con.Id;
		examRegCase.AccountId = con.AccountId;
		examRegCase.Internal_Status__c = 'Registered';
		examRegCase.RecordTypeId = examRegRecordTypeId;
		insert examRegCase;
		System.assert(examRegCase.Id != null, 'Fail to insert Exam Reg Case Record!');
		// EV Case  - INSERT
		Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
		Case evCase = new Case();
		evCase.ContactId = con.Id;
		evCase.AccountId = con.AccountId;
		evCase.Internal_Status__c = 'New';
		evCase.RecordTypeId = evRecordTypeId;
		insert evCase;
		System.assert(evCase.Id != null, ASSERT_CASE_INSERT);
		// Exam Reg Case - UPDATE 1
		Case examRegCase1 = new Case();
		examRegCase1.Id = examRegCase.Id;
		examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
		update examRegCase1;
		examRegCaseIdSet.add(examRegCase1.Id);
		// Epex Case  - INSERT
		Id epexRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
		Case epexCase = new Case();
		epexCase.ContactId = con.Id;
		epexCase.AccountId = con.AccountId;
		epexCase.Internal_Status__c = 'Pending Submission';
		epexCase.RecordTypeId = epexRecordTypeId;
		epexCase.ParentId = examRegCase.Id;
		insert epexCase;
		System.assert(evCase.Id != null, ASSERT_CASE_INSERT);
		AppForCertController.graduateUpdateEpexCaseRefactor(examRegCaseIdSet);
		Test.stopTest();
	}
    @isTest static void testGraduateFMDPDFButler() {  
        User testUser = [Select id,contactId from User where alias='user3'];      
        Contact con = [Select id,AccountId from Contact where ID=:testUser.contactId];  
        Test.startTest();
            
            Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();        
            // Case
            Case caseobj = new Case();
            caseobj.ContactId = con.Id;
            caseobj.AccountId = con.AccountId;
            caseobj.Internal_Status__c = 'Accepted';
            caseobj.RecordTypeId = appCertRecordTypeId;
            insert caseObj;
            System.assert(caseObj.Id != null, 'Fail to insert Case Record here too!');
            
            // Contact_Association_Type_Staging__c
            Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
            Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
            cats.recordTypeId 	= 	recordTypeId;
            cats.Account__c 	= 	con.AccountId;
            cats.Case__c 		=	caseObj.Id;
            cats.Contact__c		=	con.Id;
            cats.Status__c		=   'Graduate';
            cats.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
            insert cats;           

            // Contact_Association_Type__c
            Id recordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
            Contact_Association_Type__c cat = new Contact_Association_Type__c();
            cat.recordTypeId 	= 	recordTypeIdCat;
            cat.Account__c 		= 	con.AccountId;
            cat.Case__c 		=	caseObj.Id;
            cat.Contact__c		=	con.Id;
            cat.Status__c		=   'Student';
            cat.Type__c			=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
            insert cat;

            List<Asset> assetList = new List<Asset>();
            Asset asstRd5 = new Asset(
                Name = Constants.ASSET_TYPE_NAME_DOC,
                Status = Constants.ASSET_STATUS_INPROGRESS,
                Case__c = caseObj.Id,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Key__c = System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
                Type__c	=	Constants.ASSET_TYPE_NAME_DOC
            );
            asstRd5.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
            
            assetList.add(asstRd5);
        
         Asset asstd1 = new Asset(
                Name = Constants.ASSET_TYPE_NAME_DOC,
                Status = Constants.ASSET_STATUS_INPROGRESS,
                Case__c = caseObj.Id,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
                Type__c	=	Constants.ASSET_TYPE_NAME_DOC,
             	Contact_Association_Type_Staging__c = cats.Id
            );
            asstd1.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId(); 
            assetList.add(asstd1);

        Asset asstd2 = new Asset(
                Name = 'Final Diploma Translation',
                Status = Constants.ASSET_STATUS_INPROGRESS,
				Parent_Case__c = caseObj.Id,
                Case__c = caseObj.Id,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Key__c = System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
                Type__c	=	Constants.ASSET_TYPE_TRANSLATION,
             	Contact_Association_Type_Staging__c = cats.Id
            );
            asstd2.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();            
            assetList.add(asstd2);
        
            insert assetList;	
            
            //AppForCertController.updateCatIDinAsset(cats.Id, String.valueof(con.Id), System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,null );
        	//AppForCertController.updateCatIDinAsset(cats.Id, String.valueof(con.Id), System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,null );
            AppForCertController.createGradNameOrTransDocPayload(con.Id,System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT);
        	system.assertEquals(AppForCertController.createGradNameOrTransDocPayload(con.Id,System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT).documentType,Constants.ASSET_TYPE_NAME_DOC,'Document type is not Name Document');
            List<Asset> updateListAsset = new List<Asset>();
            asstRd5.Status =  Constants.ASSET_STATUS_ACCEPTED;
        	asstd2.Status =  Constants.ASSET_STATUS_ACCEPTED;
        	updateListAsset.add(asstRd5);
            updateListAsset.add(asstd2);
        	update updateListAsset;
            AppForCertController.createGradAcceptedPayload(con.Id,System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT);
        	AppForCertController.createGradAcceptedPayload(con.Id,System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT);
        	system.assertEquals(AppForCertController.createGradAcceptedPayload(con.Id,System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT).documentType,Constants.ASSET_TYPE_NAME_DOC,'Document type is not Name Document here too');
        	system.assertEquals(AppForCertController.createGradAcceptedPayload(con.Id,System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT).documentType,Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION,'Document type is not Translation Document');	
        	system.assertEquals(AppForCertController.createGradNameOrTransDocPayload(con.Id,System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT).documentType,Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION,'Document type is not Translation Document here too');	
        	AppForCertHelper.delDeanLetOrDipDocs(con.Id, caseObj.Id);
        Test.StopTest();
    }
    @isTest static void testCheckUpdateAssetId() {
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-02');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		string firstname5 = 'First5';
		string lastname5 = 'Last5';
		string emailtest5 = 'teste22r5@unknownmail1.com';
		String username5 = 'tester5@unknownmail.com_' + System.now();
		//Account acc5 = new Account(Name = 'EntityAcctNameNew', RecordTypeId = identityAccountRecordTypeId, School__c = false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		Account acc5 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew'];
		//upsert acc5;
		//System.assert(acc5.Id != null, 'Account ID is null here too');
		Contact con5 = new Contact(AccountId = acc5.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
		insert con5;
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = acc5.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Accepted', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;
		List<Asset> assetList = new List<Asset> ();
		Asset asst51 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = acc5.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA
		);
		assetList.add(asst51);
		Asset asst52 = new Asset(
			Name = ASSET_NAME,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = acc5.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA
		); 
		assetList.add(asst52);
		insert assetList;
        AppForCertHelper.updateParentId(asst51.Id, asst52.Id);
        Id parentId =[SELECT id,parentId FROM Asset where id=:asst52.Id][0].parentId;
		System.assertEquals(asst51.Id, ParentId, 'Parent id is not updated');		
		Test.stopTest();
	}

	@isTest static void testgetDlDateForExistingCAT(){
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-04');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		string firstname5 = 'First5';
		string lastname5 = 'Last5';
		string emailtest5 = 'teste11r5@unknownmail1.com';
		Id p = [Select id from profile where name = '4-Customer Community Plus Login' LIMIT 1].id;
		String username5 = 'tester51@unknownmail.com_' + System.now();
		username5 = username5.replace(' ', '').replace(':', '-');
		//Account acc5 = new Account(Name = 'EntityAcctNameNew', RecordTypeId = identityAccountRecordTypeId, School__c = false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');
		Account acc5 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew' LIMIT 1];
		//upsert acc5;
		//System.assert(acc5.Id != null, 'Account ID is null here');
		Contact con5 = new Contact(AccountId = acc5.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
		insert con5;
		User user5 = new User(alias = 'user5', email = emailtest5, emailencodingkey = 'UTF-8', lastname = lastname5, languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = AppforCertTestFactory.UNITED_STATES, IsActive = true, ContactId = con5.Id, timezonesidkey = AppforCertTestFactory.AMERICA_LA, username = username5);
		insert user5;
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = acc5.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Accepted', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;
		Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId 	= 	recordTypeId;
		cat.Account__c 		= 	con5.AccountId;
		cat.Case__c 		=	csAppForCert.Id;
		cat.Contact__c		=	con5.Id;
		cat.Status__c		=   'Graduate';
		cat.Type__c			=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		Id assetrecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		List<Asset> assetList = new List<Asset> ();
		Asset asst41 = new Asset(
			Name =  Constants.ASSET_NAME_DEAN_LETTER,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = acc5.id,
			ContactId = user5.ContactId,
			Contact_Association_Type__c = cat.Id,
			Type__c = Constants.ASSET_NAME_DEAN_LETTER,
			RecordTypeId = assetrecordTypeId,
			Dean_s_Letter_Date__c = Constants.TODAY_DATE
		);
		assetList.add(asst41);
		insert assetList;
		system.runas(user5){
			Date dlDate = AppForCertController.getDlDateForExistingCAT(string.valueof(cat.Id));
			System.assertEquals(asst41.Dean_s_Letter_Date__c, dlDate, 'Dean letter date is different');		
		}
        
		Test.stopTest();
	}

	@isTest static void testPDFTronRelatedMethods() {

		User testUser = [Select id, contactId from User where alias = 'user3'];
		Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
		Test.startTest();
		List<case >caseList = new List<case >();
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = con.Id;
		caseobj.AccountId = con.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
		caseobj.RecordTypeId = appCertRecordTypeId;
		insert caseObj;
		System.assert(caseObj.Id != null, ASSERT_CASE_INSERT);
		caseList.add(caseObj);
		// Exam Reg Case - INSERT
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		Case examRegCase = new Case();
		examRegCase.ContactId = con.Id;
		examRegCase.AccountId = con.AccountId;
		examRegCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
		examRegCase.RecordTypeId = examRegRecordTypeId;
		insert examRegCase;
		cadmus_core__Doc_Config__c docConfig1 = new cadmus_core__Doc_Config__c();
		docConfig1.Name = Constants.DOCCONFIG_EVCASE_TEMPLATE_NAME;
		docConfig1.cadmus_core__CustomerDocumentConfigId__c = Constants.DOCCONFIG_CUSTOMERDOCCONFIG_ID;
		insert docConfig1;
		// Contact_Association_Type_Staging__c
		Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
		cats.recordTypeId = recordTypeId;
		cats.Account__c = con.AccountId;
		cats.Case__c = caseObj.Id;
		cats.Contact__c = con.Id;
		cats.Status__c = 'Graduate';
		cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cats;
		// Contact_Association_Type__c
		Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId = recordTypeIdCat;
		cat.Account__c = con.AccountId;
		cat.Case__c = caseObj.Id;
		cat.Contact__c = con.Id;
		cat.Status__c = 'Student';
		cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
		insert cat;
		List<Asset> assetList = new List<Asset> ();
		//Create and Insert Asset
		Asset asstC1 = new Asset(
			Name = ASSET_NAME,
			Status = 'Installed',
			AccountId = con.AccountId,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			UsageEndDate = System.Today(),
			key__c = DIPLOMA_DOCUMENT,
			Type__c = 'Translation',
			Contact_Association_Type_Staging__c = cats.Id
		);
		Asset asstC2 = new Asset(
			Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Contact_Association_Type_Staging__c = cats.Id
		);
		Asset asstC4 = new Asset(
			Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Status = Constants.ASSET_STATUS_ACCEPTED,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Contact_Association_Type_Staging__c = cats.Id
		);
		Asset asstC3 = new Asset(
			Name = Constants.ASSET_TYPE_TCT,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			Type__c = Constants.ASSET_TYPE_TCT
		);
		asstC3.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		Asset asstC5 = new Asset(
			Name = Constants.ASSET_NAME_DEAN_LETTER,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			Case__c = caseObj.Id,
			ContactId = con.Id,
			InstallDate = System.Today(),
			Type__c = Constants.ASSET_NAME_DEAN_LETTER
		);
		asstC5.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		assetList.add(asstC1);
		assetList.add(asstC2);
		assetList.add(asstC3);
		assetList.add(asstC4);
		assetList.add(asstC5);
		insert assetList;
		//System.assertNotEquals(AppForCertController.updateCatIDinAsset(cats.Id, String.valueof(con.Id), DIPLOMA_DOCUMENT, null), NULL, 'Success');
		AppForCertController.createFMDTranscriptDeanPayload(String.valueof(con.Id), Constants.ASSET_TYPE_FINAL_MED_DIPLOMA);
		AppForCertController.createFMDAcceptedPayload(String.valueof(con.Id), Constants.ASSET_TYPE_FINAL_MED_DIPLOMA);
		AppForCertController.retrieveTCTId(con.Id, caseObj.Id);
		AppForCertController.markTctAssetsForDeletion(con.Id, caseObj.Id);
		//AppForCertController.updateCatIDinAsset(cats.Id, String.valueof(con.Id), System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT, null);
        System.assertEquals(AppForCertController.updateCatIDinAsset(cats.Id, String.valueof(con.Id), System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT, System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT),'','No asset created');
		AppForCertController.createFMDAcceptedPayload(String.valueof(con.Id), Constants.ASSET_NAME_DEAN_LETTER);
        System.assertNotEquals(AppForCertController.updateCatIDinAsset(cats.Id, String.valueof(con.Id), System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT), NULL, 'Success');
		Test.stopTest();
	}
}