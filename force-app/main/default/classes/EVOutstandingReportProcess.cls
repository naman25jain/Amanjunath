/**
 * EVOutstandingReportProcess used in Process builder 
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   25-AUG-2020
 */
public with sharing class EVOutstandingReportProcess {
    @InvocableMethod
    public static void modifyExamCase(List<Exam_Registration__c> examIds) {
        
        List<Id> examIdsList        =   new List<Id>();
        for(Exam_Registration__c ex : examIds){
            examIdsList.add(ex.Id);
        }
            
        List<Case> evList = new List<Case>();
        Set<Id> evId = new Set<Id>();
        Set<Id> evIdDec = new Set<Id>();
        for(Exam_Registration__c examList : [Select Id,Case__r.Enrollment_Verification_Parent__c,Exam_Status__c
                    from Exam_Registration__c 
                    where Id IN: examIdsList and Case__r.Enrollment_Verification_Parent__c != null]){
                        if(examList.Exam_Status__c != null){
                            evId.add(examList.Case__r.Enrollment_Verification_Parent__c);
                        }
                        else{
                            evIdDec.add(examList.Case__r.Enrollment_Verification_Parent__c);
                        }
                
        }
        List<Case> tempEVList = new List<Case>();
        tempEVList = modifyExamCaseRefactorTwo(evId);
        if(!tempEVList.isEmpty()){
            evList.addAll(tempEVList);
        }

        List<Case> tempEVCaseList = new List<Case>();
        tempEVCaseList = modifyExamCaseRefactorOne(evIdDec);
        if(!tempEVCaseList.isEmpty())  {
            evList.addAll(tempEVCaseList);
        }

        if(!evList.isEmpty())   {
            update evList;
            List<Case> examCaseOutComeList = new List<Case>();
            Map<Id,Decimal> exmId = new Map<Id,Decimal>();
            for(Case exCase :evList){
                exmId.put(exCase.Id,exCase.Exam_Outcome_Report__c);
            }
            for(Case examCase : [Select Id,Exam_Outcome_Report__c,Enrollment_Verification_Parent__c 
                                 from Case Where Enrollment_Verification_Parent__c IN: exmId.keyset()]){
                Case ex = new Case(Id = examCase.Id);
                ex.Exam_Outcome_Report__c = exmId.get(examCase.Enrollment_Verification_Parent__c);
                examCaseOutComeList.add(ex);
            }

            if(!examCaseOutComeList.isEmpty())   {
                update examCaseOutComeList;
            }
        }
   }
  
   public static List<Case> modifyExamCaseRefactorOne(Set<Id> evIdDec){
        List<Case> evCasList = new List<Case>();
        if(!evIdDec.isEmpty()){
            for(Case evCas : [Select Id,Exam_Outcome_Report__c from Case where Id IN:evIdDec]){
                Case ev = new Case(Id = evCas.Id);
                if(evCas.Exam_Outcome_Report__c == null){
                    ev.Exam_Outcome_Report__c = 1; 
                }else{
                    ev.Exam_Outcome_Report__c = evCas.Exam_Outcome_Report__c + 1;
                }
                evCasList.add(ev);
            }
         
         
        }
        return evCasList; 
   }

   public static List<Case> modifyExamCaseRefactorTwo(Set<Id> evId){
        List<Case> evList = new List<Case>();
        if(!evId.isEmpty()){
            for(Case evCas : [Select Id,Exam_Outcome_Report__c from Case where Id IN:evId]){
                Case ev = new Case(Id = evCas.Id);
                if(evCas.Exam_Outcome_Report__c == null){
                    ev.Exam_Outcome_Report__c = 1; 
                }else{
                    ev.Exam_Outcome_Report__c = evCas.Exam_Outcome_Report__c - 1;
                }
                evList.add(ev);
            }

        }
        return evList;
   }
}