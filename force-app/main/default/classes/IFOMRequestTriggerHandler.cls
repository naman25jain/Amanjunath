// Handler class for IFOM Request
public with sharing class IFOMRequestTriggerHandler implements CaseTriggerHandlerInterface{
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){
                // Updates the Service
                CaseTriggerUtility.updateCaseService(newCase,Constant_Case__mdt.getInstance('REC_TYPE_IFOM_REQUEST').Value__c);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Before Update
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            for(Case newCase: newCasesMap.values()){
                // Gets the old case.
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c){                    
                    // Updates Updated_in_NBME_system__c, Internal_Status__c, OwnerId if internal status is changed.
                    if(oldCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c
                    && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c){
                        newCase.Updated_in_NBME_system__c = false;
                        newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
                        newCase.OwnerId = ((Constants.QUEUE_DEV_ID_MAP).get(Constant_Case__mdt.getInstance('QUEUE_ENROLLMENT_VERIFICATION').Value__c));
                    }
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // After insert
    public void afterInsert(Map<Id,Case> newCasesMap){}
    // After update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){}
}