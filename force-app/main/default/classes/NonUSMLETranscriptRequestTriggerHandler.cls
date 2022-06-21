// Handler class for Non USMLE Request
public with sharing class NonUSMLETranscriptRequestTriggerHandler implements CaseTriggerHandlerInterface{
    final String CASE_STATUS_PENDING_PRINT = Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
    final String CASE_STATUS_SENT = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
    final String CASE_STATUS_REJECTED = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
    final String REC_TYPE_NON_USMLE_TRANSCRIPT = Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c;
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){
                // Updates the Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_NON_USMLE_TRANSCRIPT);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Before Update
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            for(Case newCase : newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                if(isInternalStatChanged){
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates External Status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // After insert
    public void afterInsert(Map<Id,Case> newCasesMap){}
    // After update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
            Id docConfigId = docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('NON_USMLE_TRANSCRIPT').Value__c).Id;
            // Stores already processed parentIds
            Set<Id> processedParentIds = new Set<Id>();
            // Stores the list of records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,SObject> parentChildRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            for(Case newCase: newCasesMap.values()){
                // Gets the old case.                
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                if(isInternalStatChanged && newCase.Internal_Status__c == CASE_STATUS_PENDING_PRINT){
                    if(String.isNotBlank(docConfigId)){
                        CaseTriggerUtility.generateDocHelper(docConfigId,newCase);
                    }                               
                }
                // Get Case's ParentId to update ParentCase NonUsmle
                // Checks if internal status is Accepted and changed to update the parent record
                if(isInternalStatChanged && (newCase.Internal_Status__c == CASE_STATUS_SENT || newCase.Internal_Status__c == CASE_STATUS_REJECTED)
                && String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId)){
                    Case parentRec = (Case)parentChildRecMap.get(newCase.ParentId);
                    if(!processedParentIds.contains(newCase.ParentId)){
                        processedParentIds.add(newCase.ParentId);
                        Case parentRecUpdated = CaseTriggerUtility.upTransReqdParCase(parentRec);
                        if(parentRecUpdated!=null){
                            CaseTriggerUtility.updateRec(updateCaseRecMap,parentRecUpdated);
                        }
                    }
                }
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}