/**
 * EVOutstandingReportCaseProcess used in Process builder 
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   25-AUG-2020
 */
public with sharing class EVOutstandingReportCaseProcess {
    // @InvocableMethod
    // public static void modifyExamCase(List<Case> caseIds){
    //     Set<Id> caseIdsList        =   new Set<Id>();
    //     for(Case ex : caseIds){
    //         caseIdsList.add(ex.Enrollment_Verification_Parent__c);
    //     }
        
    //     if(!caseIdsList.isEmpty()){
    //         List<Case> evList = new List<Case>();
    //         Map<String,Integer> evOutComeMap = new Map<String,Integer>();
            
    //         for(Exam_Registration__c examReg:[Select Id,Case__c,Exam_Types__c,Exam_Status__c,
    //             EP_start_Date__c,EP_end_Date__c,Case__r.Enrollment_Verification_Parent__c from Exam_Registration__c 
    //             where Case__r.Enrollment_Verification_Parent__c IN: caseIdsList and Exam_Status__c = null]){

    //                 if(evOutComeMap.containsKey(examReg.Case__r.Enrollment_Verification_Parent__c)){
    //                     Integer tempVal = 0;
    //                     tempVal = evOutComeMap.get(examReg.Case__r.Enrollment_Verification_Parent__c) + 1;
    //                     evOutComeMap.put(examReg.Case__r.Enrollment_Verification_Parent__c,tempVal);
    //                 }else{
    //                     evOutComeMap.put(examReg.Case__r.Enrollment_Verification_Parent__c,1);
    //                 }
    //         }
    //         if(!evOutComeMap.isEmpty()){
    //             for(Case evCas : [Select Id,Exam_Outcome_Report__c from Case where Id IN:evOutComeMap.keyset()]){
    //                 Case ev = new Case(Id = evCas.Id);
    //                 ev.Exam_Outcome_Report__c = evOutComeMap.get(evCas.Id);            
    //                 evList.add(ev);
    //             }
    //         }

    //         if(!evList.isEmpty())   {
    //             update evList;
    //             List<Case> examCaseOutComeList = new List<Case>();
    //             for(Case examCase : [Select Id,Exam_Outcome_Report__c,Enrollment_Verification_Parent__c 
    //                                 from Case Where Enrollment_Verification_Parent__c IN: evOutComeMap.keyset()]){
    //                 Case ex = new Case(Id = examCase.Id);
    //                 ex.Exam_Outcome_Report__c = evOutComeMap.get(examCase.Enrollment_Verification_Parent__c);
    //                 examCaseOutComeList.add(ex);
    //             }

    //             if(!examCaseOutComeList.isEmpty())   {
    //                 update examCaseOutComeList;
    //             }
    //         }
    //     }
    // }
}