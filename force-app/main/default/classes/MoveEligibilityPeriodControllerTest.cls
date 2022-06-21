//Test Class for MoveEligibilityPeriodController class
@isTest
public with sharing class MoveEligibilityPeriodControllerTest{
	public static testMethod void testMoveEP(){
        String examType = 'USMLE Step 1';
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
		Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',School_Enrollment_Status__c=Constants.CONASCTYPESTG_STATUS_GRADUATE);
        insert c1;
        //get the Household Account
        string accountname = lastname + ' Household';
        Account a = [Select Id from Account where name= :accountname LIMIT 1];
        Case csEr = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId,Internal_Status__c=Constants.CASE_STATUS_IN_REVIEW);
        insert csEr;
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        Exam_Region_Surcharge__c regionSurcharge = new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        date epStartDate = System.Today()+1;
        date epEndDate = System.Today()-25;
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = csEr.Id;
        updateExamRegistration.Applicant__c = c1.Id;
		insert updateExamRegistration;
        date epStartDate1 = System.Today()+30;
        date epEndDate1 = System.Today()+90;
        Id epRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get(Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG).getRecordTypeId();
        Eligibility_period__c ep = new Eligibility_period__c();
        ep.EP_Start_Date__c = epStartDate1;
        ep.EP_End_Date__c = epEndDate1;
        ep.Exam_Type__c = examType;
        ep.Active__c = 'Y';
        ep.Extension_Flag__c = 'N';
        ep.Period_Code__c = 'X17';
        ep.RecordTypeId = epRecordTypeId;
        insert ep;
        String selectedEP = ep.Id;
        String reason = 'test class reason';
        System.assertNotEquals(MoveEligibilityPeriodController.getCurrentEligibilityPeriod(updateExamRegistration.Id), '', 'Eligibility period should return');
        System.assertEquals(MoveEligibilityPeriodController.checkOnOutcome(updateExamRegistration.Id), 'You cannot move the EP of this exam because the exam has not yet been registered.', 'Outcome returned is not correct');
        System.assert(MoveEligibilityPeriodController.getEligibilityPeriods(updateExamRegistration.Id) != null, 'Eligibility period should not be null');
        System.assert(MoveEligibilityPeriodController.submitMoveEP(updateExamRegistration.Id, selectedEP, reason) == true, 'Returned value is false');
    }
}