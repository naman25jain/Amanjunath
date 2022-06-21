// Handler class for Biographic Review
public with sharing class BiographicReviewCaseTriggerHandler implements CaseTriggerHandlerInterface {
    final String REC_TYPE_BIO_REVIEW  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_BIOGRAPHIC_REVIEW').Value__c;
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates Case Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_BIO_REVIEW);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
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
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates External Status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
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
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Stores already processed parentIds
            Set<Id> processedParentIds = new Set<Id>();
            // Stores the list of records to be updated
            Map<Id,Case> updateRecMap = new Map<Id,Case>();
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,sObject> childRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            for(Case newCase:newCasesMap.values()){
                // Obtains oldcase
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                // Checks if internal status is Accepted and changed to update the parent record
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c 
                && String.isNotBlank(newCase.ParentId) && childRecMap.containsKey(newCase.ParentId) && !processedParentIds.contains(newCase.ParentId)){
                    processedParentIds.add(newCase.ParentId);
                    Case parentRec = CaseTriggerUtility.updParCaseIntStat(newCase,(Case)childRecMap.get(newCase.ParentId));
                    if(parentRec!=null){
                        updateRecMap.put(parentRec.Id,parentRec);
                    }
                }
            }
            if(!updateRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}