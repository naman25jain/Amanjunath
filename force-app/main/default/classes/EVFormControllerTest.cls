/**
* Test Class for Enrollment Verification Form Controller
*
* @author        Enable Consulting : Chinmay Menon
* @version       1.0
* @createdDate   10-JUN-2020
*/
@isTest
public class EVFormControllerTest {

    @testSetup static void setup() {
        EVFormControllerTestFactory.dataSetup();
    }

    @isTest static void testDataFetch() {
        Id enrollmentVerificationRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
        Contact applicant = [SELECT Id FROM Contact WHERE firstname = 'First'];
        Case evCase = [SELECT Id FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];
        Test.startTest();

        System.assert(EnrollmentVerificationFormController.fetchApplicantDetails(applicant.Id, evCase.Id).size() > 0);
        System.assert(EnrollmentVerificationFormController.fetchApplicantPhotoId(applicant.Id) != null);
        Test.stopTest();
    }

    @isTest static void testDataSave1() {
        Id enrollmentVerificationRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
        Contact applicant = [SELECT Id FROM Contact WHERE firstname = 'First'];
        Case evCase = [SELECT Id FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];

        String jsonValues = '{"caseId": "' + evCase.Id +
                            '"  ,"attendanceStartDate":"2012-09-01"' +
                            ',"attendanceEndDate":"2016-09-01"' +
                            ',"gradMonth":"January"'+
                            ',"gradYear":"2019"' +
                            ',"degreeIssueDate":"2016-10-01"' +
                            ',"numOfYearsAttended":"4.0"' +
                            ',"verificationStatus":"Transferred"' +
                            ',"verificationStatusDate":"2020-09-01"' +
                            ',"verificationStatusDateMonth":"June"' +
                            ',"verificationStatusDateYear":"2020"' +
                            ',"passedBasicScience":"No"}';
        Test.startTest();
        EnrollmentVerificationFormController.saveApplicantDetails(jsonValues);
        evCase = [SELECT Id, Verification_Status_Date__c FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];
        System.assert(evCase.Verification_Status_Date__c == date.valueOf('2020-09-01'));
        Test.stopTest();
    }

    @isTest static void testDataSave2() {
        Id enrollmentVerificationRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
        Contact applicant = [SELECT Id FROM Contact WHERE firstname = 'First'];
        Case evCase = [SELECT Id FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];

        String jsonValues = '{"caseId":"' + evCase.Id +
                            '"  ,"attendanceStartDate":"2012-5-01"' +
                            ',"attendanceEndDate":"2016-08-01"' +
                            ',"gradMonth":"February"'+
                            ',"gradYear":"2017"' +
                            ',"degreeIssueDate":"2017-02-01"' +
                            ',"numOfYearsAttended":"5.0"' +
                            ',"verificationStatus":"Graduated"' +
                            ',"verificationStatusDate":"2021-07-01"' +
                            ',"verificationStatusDateMonth":"July"' +
                            ',"verificationStatusDateYear":"2021"' +
                            ',"passedBasicScience":"Yes"}';
        Test.startTest();
        EnrollmentVerificationFormController.saveApplicantDetails(jsonValues);
        evCase = [SELECT Id, Verification_Status_Month__c, Verification_Status_Year__c FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];
        System.assert(evCase.Verification_Status_Month__c == 'July');
        System.assert(evCase.Verification_Status_Year__c == '2021');
        Test.stopTest();
    }

    @isTest static void testDataSave3() {
        Id enrollmentVerificationRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
        Contact applicant = [SELECT Id FROM Contact WHERE firstname = 'First'];
        Case evCase = [SELECT Id FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];

        String jsonValues = '{"caseId":"' + evCase.Id +
                            '"  ,"attendanceStartDate":"2012-09-01"' +
                            ',"attendanceEndDate":"2016-09-01"' +
                            ',"gradMonth":"January"'+
                            ',"gradYear":"2019"' +
                            ',"degreeIssueDate":"2016-10-01"' +
                            ',"numOfYearsAttended":"4.0"' +
                            ',"verificationStatus":""' +
                            ',"verificationStatusDate":"2020-09-01"' +
                            ',"verificationStatusDateMonth":"June"' +
                            ',"verificationStatusDateYear":"2020"' +
                            ',"passedBasicScience":"Yes"}';
        Test.startTest();
        EnrollmentVerificationFormController.saveApplicantDetails(jsonValues);
        evCase = [SELECT Id, Verification_Status_Month__c, Verification_Status_Year__c FROM Case WHERE ContactId = :applicant.Id AND RecordTypeId = :enrollmentVerificationRTid];
        System.assert(evCase.Verification_Status_Month__c == null);
        System.assert(evCase.Verification_Status_Year__c == null);
        Test.stopTest();
    }

}