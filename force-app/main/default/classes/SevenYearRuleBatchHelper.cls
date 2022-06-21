/**
    * @author: Femi
    * @name: SevenYearRuleBatchHelper
    * @description: Helper class for SevenYearRuleBatch
    * @createdDate: 05-May-2020
**/
public with sharing class SevenYearRuleBatchHelper {
    /* 05 May 2020
     * Created by Femi
     * Method Name: saveVoidedExams
     * Purpose : method to update voided exams as per 7 year rule
     * 
    */
    public static void saveVoidedExams(Map<String, Exam_Registration__c> firstExamMap, List<String> listToUpdate, List<Exam_Registration__c> examRegList, List<Exam_Registration__c> allExamRegList){
        List<Exam_Registration__c> examListToUpdate = new List<Exam_Registration__c>();
        List<String> checkPassedList = new List<String>();
        Map<String, List<Exam_Registration__c>> applicantExamsMap = new Map<String, List<Exam_Registration__c>>();
        for(Exam_Registration__c examReg : examRegList){
            List<Exam_Registration__c> examList = new List<Exam_Registration__c>();
            if(applicantExamsMap.get(examReg.applicant__c) == null){
                examList.add(examReg);
                applicantExamsMap.put(examReg.applicant__c, examList);
            }else{
                examList = applicantExamsMap.get(examReg.applicant__c);
                examList.add(examReg);
                applicantExamsMap.put(examReg.applicant__c, examList);
            }
        }
        for(String applicant : firstExamMap.keyset()){
            if(listToUpdate.contains(applicant)){
                examListToUpdate.add(firstExamMap.get(applicant));
            }
        }
        examListToUpdate = checkForExtraExams(examListToUpdate, allExamRegList, applicantExamsMap);
        for(Exam_Registration__c examReg : examListToUpdate){
            examReg.Voided__c = true;
        }
        for(Exam_Registration__c examReg : examRegList){
            if(!examListToUpdate.contains(examReg)){
                checkPassedList.add(examReg.applicant__c);
            }
        }
        saveVoidTestPassedFlag(checkPassedList);
        if(!examListToUpdate.isEmpty()){
            try{
                Update examListToUpdate;
            }
            catch(Exception e){
                System.debug('Exception caught.'+e.getMessage());
            } 
        }

    }
    /* 05 May 2020
     * Created by Femi
     * Method Name: saveVoidTestPassedFlag
     * Purpose : method to update flag for applicants who passed 7 year rule check
     * 
    */
    public static void saveVoidTestPassedFlag(List<String> checkPassedList){
        List<Contact> examCheckPassedList = [SELECT id FROM Contact WHERE id in:checkPassedList];
        for(Contact applicant : examCheckPassedList){
            applicant.Void_Check_Passed__c = true;
        }
        if(!examCheckPassedList.isEmpty()){
            try{
                Update examCheckPassedList;
            }
            catch(Exception e){
                System.debug('Exception caught.'+e.getMessage());
            } 
        }

    }
    /* 05 May 2020
     * Created by Femi
     * Method Name: checkForExtraExams
     * Purpose : method to check whether exam is voided
     * 
    */
    public static List<Exam_Registration__c>  checkForExtraExams(List<Exam_Registration__c> examListToUpdate, List<Exam_Registration__c> allExamRegList, Map<String, List<Exam_Registration__c>> applicantExamsMap){
        for(String applicant : applicantExamsMap.keyset()){
            if(applicantExamsMap.get(applicant).size()>1){
                for(Exam_Registration__c examReg : applicantExamsMap.get(applicant)){
                    if(!examListToUpdate.contains(examReg) && checkVoidedExams(examReg, allExamRegList, examListToUpdate)){
                        examListToUpdate.add(examReg);
                    }
                }
            }
        }
        return examListToUpdate;

    }
    /* 05 May 2020
     * Created by Femi
     * Method Name: checkVoidedExams
     * Purpose : method to check whether exam is voided
     * 
    */
    public static Boolean checkVoidedExams(Exam_Registration__c exam, List<Exam_Registration__c> allExamRegList,List<Exam_Registration__c> examListToUpdate){
        Map<String, List<String>> applicantExamMap = new Map<String, List<String>>();
        Boolean returnValue = false;
        for(Exam_Registration__c examReg : allExamRegList){
            List<String> examTypeList = new List<String>();
            Date firstExamDate = exam.Exam_taken_date__c;
            Date sevenYearDate = firstExamDate.addYears(+7);
            if(examReg.Exam_taken_date__c < sevenYearDate && !examListToUpdate.contains(examReg) && examReg.applicant__c == exam.applicant__c){
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
           if(!examTypeList.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE) || !examTypeList.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) || !examTypeList.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS)){
                returnValue = true;
           }
        }
        return returnValue;
    }
}