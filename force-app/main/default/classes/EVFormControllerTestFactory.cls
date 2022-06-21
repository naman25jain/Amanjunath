/**
 * Factory Class for Enrollment Verification Form functionality
 *
 * @author        Enable Consulting : Chinmay Menon
 * @version       1.0
 * @createdDate   10-JUN-2020
 */
@isTest
public class EVFormControllerTestFactory {
	public static testMethod void dataSetup() {

		//create a new contact;
		date birthdate1 = date.valueOf('2000-01-01');
		string emailtest = 'tester@unknownmail.com';
		String userName = 'tester@unknownmail.com_' + System.now();
		userName = userName.replace(' ', '').replace(':', '-');
		string lastname = 'Last';
		string firstname = 'First';
		Contact c1 = new Contact(Firstname = firstname, Lastname = lastname, Birthdate = birthdate1, email = emailtest, MailingCountry = 'Mexico');
		insert c1;

		//create a new exam reg case ;
		String examType = 'USMLE Step 1';
		Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
		Case cs = new Case(ContactId = c1.Id, Service__c = 'EPIC', RecordTypeId = idExamRegTypeId, Internal_Status__c = 'Registered');
		insert cs;

		//create a new exam region;
		Exam_Region__c region = new Exam_Region__c();
		region.name = 'test_Region';
		region.Region_Name__c = 'test_Region';
		insert region;

		//create a new exam region surcharge;
		Exam_Region_Surcharge__c regionSurcharge = new Exam_Region_Surcharge__c();
		regionSurcharge.Exam_Region__c = region.Id;
		regionSurcharge.Exam_Types__c = examType;
		regionSurcharge.Surcharge__c = 100;
		insert regionSurcharge;

		date epStartDate = System.Today() + 1;
		date epEndDate = System.Today() + 90;
		date scheduledTestDate = System.Today() + 30;

		//create a new exam registration;
		Exam_Registration__c examReg = new Exam_Registration__c();
		examReg.Exam_Types__c = examType;
		examReg.Application_Id__c = 2000;
		examReg.USMLE_ID_CIBIS__c = '2000';
		examReg.Exam_Region_Surcharge__c = regionSurcharge.Id;
		examReg.Surcharge__c = regionSurcharge.Surcharge__c;
		examReg.case__c = cs.Id;
		examReg.Applicant__c = c1.Id;
		examReg.Score_report_Document_id__c = 'abcde';
		examReg.EP_start_Date__c = epStartDate;
		examReg.EP_end_Date__c = epEndDate;
		examReg.Scheduled_Test_Date__c = scheduledTestDate;
		insert examReg;

		//create a new enrollment verification case ;
		Id enrollmentVerificationRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
		Case evCs = new Case(ContactId = c1.Id, RecordTypeId = enrollmentVerificationRTid, Internal_Status__c = constants.CASE_STATUS_RECEIVED_IN_REVIEW);
		evCs.Unique_Medical_School__c = '6asda';
		evCs.Name_on_Diploma__c = 'reas';
		evCs.School_Program__c = 'testsp';
		evCs.Attendance_Start_Date__c = System.Today() - 700;
		evCs.Attendance_End_Date__c = System.Today() - 300;
		evCs.Graduation_Month__c = 'January';
		evCs.Graduation_Year__c = '2019';
		evCs.Degree_Date__c = System.Today() - 250;
		evCs.Number_of_Years_Attended__c = 4.0;
		evCs.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
		// evCs.Verification_Status_Date__c
		// evCs.Passed_basic_sciences_course__c
		// evCs.Enrollment_Verification_Form_Submitted__c
		// evCs.Verification_Status_Month__c
		// evCs.Verification_Status_Year__c

		insert evCs;

		// update exam reg case's enrollment verification parent case
		cs.Enrollment_Verification_Parent__c = evCs.Id;
		update cs;

        // insert applicant image
		ContentVersion contentVersion = new ContentVersion(
			Title = 'Photo',
			PathOnClient = 'TestImage.jpg',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true
		);
		insert contentVersion;

		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

		//create ContentDocumentLink  record 
		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = c1.id;
		cdl.ContentDocumentId = documents[0].Id;
		cdl.shareType = 'V';
		insert cdl;
	}
}