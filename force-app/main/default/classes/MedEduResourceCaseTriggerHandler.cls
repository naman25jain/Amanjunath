// Handler class for Medical Education Resources 
public with sharing class MedEduResourceCaseTriggerHandler implements CaseTriggerHandlerInterface {
    final String REC_TYPE_MED_EDU_RES  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c;
    final Id medEduResQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MEDICAL_EDUCATION_RESOURCES').Value__c);
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,sObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            for(Case newCase: newCases){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates Case Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_MED_EDU_RES);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                // Updates Contact, Entity, Owner and Document Type from Parent
                updateEntityServiceReqCase(newCase, parentCaseMap);
            }
        }
            catch(Exception ex){
                throw ex;
            }
    }
    // Before Update
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,sObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
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
                // Updates Contact, Entity, Owner and Document Type from Parent
                updateEntityServiceReqCase(newCase, parentCaseMap);
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
    // Updates Contact, Entity, Owner and Document Type from Parent
    public void updateEntityServiceReqCase(Case newCase, Map<String,SObject> parentCaseMap){
        try{
            if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c && String.isNotBlank(newCase.ParentId) && parentCaseMap.containsKey(newCase.ParentId)){
                Case parentCase = (Case)parentCaseMap.get(newCase.parentId);
                newCase.ContactId = parentCase.ContactId;
                newCase.Entity__c = parentCase.Entity__c;
                newCase.Document_Type__c = parentCase.Document_Type__c;
                newCase.OwnerId = medEduResQueueId;
            }    
        }catch(Exception ex){
            throw ex;
        }
    }
}