public with sharing class EPICExtractionTriggerHandler implements CaseTriggerHandlerInterface{
    public void beforeInsert(List<Case> newCases){
        try{
            System.debug('-------EPIC Extraction Before Insert Handler-------');
            for(Case caseIns:newCases){
                // Updates the Service
                CaseTriggerUtility.updateCaseService(caseIns,Constant_Case__mdt.getInstance('REC_TYPE_EPIC_EXTRACTION').Value__c);
                 // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                // Updates External Status field for case record
                CaseTriggerUtility.updateCaseExtStatus(caseIns, new Case());
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(caseIns);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            System.debug('-------EPIC Extraction Before Update Handler-------');
            for(Case caseIns: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(caseIns.Id);
                if(caseIns.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                    // Updates External Status field for case record
                    CaseTriggerUtility.updateCaseExtStatus(caseIns, oldCase);
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(caseIns);
                }
        }
    }catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){}
}