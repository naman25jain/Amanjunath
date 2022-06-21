public with sharing class EntityServiceRequestTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_ENTSERVREQ = Constant_Case__mdt.getInstance('REC_TYPE_ENTSERVREQ').Value__c;
    // Before Insert
    public void beforeInsert(List<Case> newCases){
        try{
            // Fetches parent child case records
            Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            for(Case newCase: newCases){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates Case Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_ENTSERVREQ);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                //Updates Owner,Contact,Account,Entity fields
                updateEntityServiceReqCase(newCase, parentCaseMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Before Update
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates External Status field for case record
                    CaseTriggerUtility.updateCaseExtStatus(newCase, oldCase);
                    //Updates Owner,Contact,Account,Entity fields
                    updateEntityServiceReqCase(newCase, parentCaseMap);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // After Insert
    public void afterInsert(Map<Id,Case> newCasesMap){}
    // After Update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){}
    // Updates Owner based on Internal Status. Updates Contact Id, Account Id, Entity based on parent.
    void updateEntityServiceReqCase(Case newCase, Map<String,SObject> parentCaseMap){
        try{
            if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c){
                if(newCase.OwnerId != Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_SERVICE_REQUEST').Value__c) && newCase.Type != Constant_Case__mdt.getInstance('TYPE_ENTITY_DETAILS_CHANGE').Value__c){
                    newCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_SERVICE_REQUEST').Value__c);
                }else if(newCase.OwnerId != Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_UPDATE_REQUEST').Value__c) && newCase.Type == Constant_Case__mdt.getInstance('TYPE_ENTITY_DETAILS_CHANGE').Value__c){
                    newCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_UPDATE_REQUEST').Value__c);
                }
                if(String.isNotBlank(newCase.ParentId) && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c && parentCaseMap.containsKey(newCase.ParentId)){
                    Case parentCase = (Case)parentCaseMap.get(newCase.ParentId);
                    newCase.ContactId = parentCase.ContactId;
                    newCase.AccountId = parentCase.AccountId;
                    newCase.Type = Constant_Case__mdt.getInstance('TYPE_NEW_ENTITY_REQUEST').Value__c;
                    if(String.isBlank(newCase.Entity__c)){
                        newCase.Entity__c = parentCase.Entity__c;
                    }
                }
            }else if(newCase.OwnerId != UserInfo.getUserId() && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c){
                newCase.OwnerId = UserInfo.getUserId();
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}