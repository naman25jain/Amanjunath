/**
* Test Class for Score Report functionality
*
* @author        Nayana
* @version       1.0
* @createdDate   12-MAY-2020
*/
@isTest
public with sharing class ScoreReportControllerTest{
    @testSetup static void setup(){
        ScoreReportTestFactory.servicePageSetup();
    }
    @isTest static void testScoreReport(){
        User testUser = [SELECT Id, contactId from User where alias='second'];
        System.runAs(testUser){
            List<Id> examIdList = new List<Id>();
            Test.startTest();
            ScoreReportController.getScoreReportInfo();
            ScoreReportController.conditionForScoreRecheck();
            List<Exam_Registration__c> examList = ScoreReportController.getScoreRecheckExams();
            examIdList.add(examList[0].Id);
            ScoreReportController.manageScoreRecheck(examIdList);
            ScoreReportController.getTermsandConditionsData();
            String caseCreate = ScoreReportController.createSRCase();
            System.assert(caseCreate != null, 'Case not created');
            String caseIds = ScoreReportController.getScoreRecheckCases();
            System.assert(caseIds != null, 'Case not created');
            List<String> caseNumbers = ScoreReportController.paymentCompletion();
            System.assert(!caseNumbers.isEmpty(), 'Case list is empty');
            List< ScoreReportHelper.ExamWithholdWrapper > returnValue = ScoreReportController.checkValidationForWithholdExams();
            List<String> examsSelected = new List<String>();
            examsSelected.add(returnValue[0].examId);
            ScoreReportController.updateOptoutFlag(examsSelected);
            Test.stopTest();
        }
    }   
    @isTest static void testScoreReportCancel(){
        User testUser = [SELECT Id, contactId from User where alias='second'];
        System.runAs(testUser){
            List<Id> examIdList = new List<Id>();
            Test.startTest();
            List<Exam_Registration__c> examList = ScoreReportController.getScoreRecheckExams();
            examIdList.add(examList[0].Id);
            String sr = '';
            sr = ScoreReportController.manageScoreRecheck(examIdList);
            System.assert(sr == 'true', 'update failed');
            Test.stopTest();
        }
    }   
}