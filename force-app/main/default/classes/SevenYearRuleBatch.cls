/**
 * Batch class for Enrollment Re-verification
 *
 * @author        Femi
 * @version       1.0
 * @createdDate   04-MAY-2020
 */
global with sharing class SevenYearRuleBatch implements Database.Batchable<sObject>{

    global Iterable<sObject> start(Database.BatchableContext bc) {
        Date today = System.today();
        Date date7YearBack = today.addYears(-7);
        List<Exam_Registration__c> examRegList = [SELECT id, Exam_taken_date__c, Exam_Types__c, Applicant__c FROM Exam_Registration__c WHERE Exam_taken_date__c != null AND Exam_taken_date__c <=:date7YearBack AND Exam_Status__c != NULL AND Exam_Status__c =:Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED AND Applicant__r.Void_Check_Passed__c = false AND Voided__c = false ORDER BY Exam_taken_date__c ASC];
        return examRegList;
    }

    global void execute(Database.BatchableContext bc, List<Exam_Registration__c> examRegList) {
        List<String> applicantList = new List<String>();
        List<String> listToUpdate = new List<String>();
        List<String> checkPassedList = new List<String>();
        Map<String, List<String>> applicantExamMap = new Map<String, List<String>>();
        Map<String, Exam_Registration__c> firstExamMap = new Map<String, Exam_Registration__c>();
        Date today = System.today();
        for(Exam_Registration__c examReg : examRegList){
            applicantList.add(examReg.Applicant__c);
            if(firstExamMap.get(examReg.applicant__c) == null){
                firstExamMap.put(examReg.applicant__c, examReg);
            }
        }
        List<Exam_Registration__c> allExamRegList = [SELECT id, Exam_taken_date__c, Exam_Types__c, Applicant__c FROM Exam_Registration__c WHERE Exam_taken_date__c != null AND Voided__c = false AND Exam_taken_date__c <today AND Exam_Status__c =:Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED AND Applicant__c in:applicantList ORDER BY Exam_taken_date__c ASC];
        
        for(Exam_Registration__c examReg : allExamRegList){
            List<String> examTypeList = new List<String>();
            Date firstExamDate = firstExamMap.get(examReg.applicant__c).Exam_taken_date__c;
            Date sevenYearDate = firstExamDate.addYears(+7);
            if(examReg.Exam_taken_date__c < sevenYearDate){
                if(applicantExamMap.get(examReg.applicant__c) == null){
                    examTypeList.add(examReg.Exam_Types__c);
                    applicantExamMap.put(examReg.applicant__c, examTypeList);
                }else{
                    examTypeList = applicantExamMap.get(examReg.applicant__c);
                    examTypeList.add(examReg.Exam_Types__c);
                    applicantExamMap.put(examReg.applicant__c, examTypeList);
                }
            }
            
        }
        for(String applicant : applicantExamMap.keySet()){
           List<String> examTypeList = applicantExamMap.get(applicant);
           if(examTypeList.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE) && examTypeList.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) && examTypeList.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS)){
                checkPassedList.add(applicant);
           }else{
                listToUpdate.add(applicant);
           }
        }
        SevenYearRuleBatchHelper.saveVoidedExams(firstExamMap, listToUpdate, examRegList, allExamRegList);
        
    }
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    } 
}