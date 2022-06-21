/**
* Test Class for ExamRegistrationTriggerHepler
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   15-MAY-2020
*/
@isTest
public class ExamRegistrationTriggerHeplerTest {
    public static testMethod void examRegistrationTriggerTest() {
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico');
        insert c1;
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias='second',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user1;
        
        String examType = 'USMLE Step 1';
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Case cs = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered');
        insert cs;
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        Id scoreReportTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_REPORT).getRecordTypeId();
        
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
        updateExamRegistration.Application_Id__c = 2000;
        updateExamRegistration.USMLE_ID_CIBIS__c ='2000';
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Applicant__c = c1.Id;
        updateExamRegistration.Score_report_Document_id__c = 'abcde';
        updateExamRegistration.Withheld_Score__c = true;
        updateExamRegistration.Withheld_Reason__c = 'WH by NBME';
		insert updateExamRegistration;
        Case sRCase = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=scoreReportTypeId, Internal_Status__c='New', Exam_Registration__c = updateExamRegistration.Id);
        insert sRCase;
        Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
		updateExamRegistration1.Exam_Types__c = examType;
        updateExamRegistration1.Application_Id__c = 2000;
        updateExamRegistration1.USMLE_ID_CIBIS__c ='2000';
		updateExamRegistration1.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration1.Surcharge__c = regionSurcharge.Surcharge__c;
        updateExamRegistration1.case__c = cs.Id;
        updateExamRegistration1.Applicant__c = c1.Id;
        updateExamRegistration1.Withheld_Score__c = false;
		insert updateExamRegistration1;
        
        updateExamRegistration.Withheld_Score__c= false;
        update updateExamRegistration;
        updateExamRegistration1.Withheld_Score__c= true;
        updateExamRegistration1.Score_report_Document_id__c = 'abcde';
        updateExamRegistration1.Withheld_Reason__c = 'WH by NBME';
        update updateExamRegistration1;
        updateExamRegistration.Withheld_Score__c= true;
        updateExamRegistration.Withheld_Reason__c = 'Pending Id Verification';
        update updateExamRegistration;
    }
    public static testMethod void scheduledJobsClass() {
        ScheduledJobsClass.initiateJobs();
    }
    
}