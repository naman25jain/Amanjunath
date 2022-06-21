public with sharing class PaperFileRequestTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_Paper_File_Request = Constant_Case__mdt.getInstance('REC_TYPE_PAPER_FILE_REQUEST').Value__c;
    final String STATUS_SENT_FOR_VERIFICATION = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c;
    final String STATUS_RESENT_FOR_VERIFICATION = Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c;
    public void beforeInsert(List<Case> newCases){
         // Stores the parent records.
         Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
        for(Case newCase : newCases){
             // Updates standard case status field to closed/not applicable based on internal status
             CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
             // Updates the Applicant_Last_Submission_Date__c field
             CaseTriggerUtility.updateCaseRecordDate(newcase);
             if(String.isNotBlank(newCase.ParentId) && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c && parentCaseMap.containsKey(newCase.parentId)){
                 populateCaseFields(newCase,(Case)parentCaseMap.get(newCase.ParentId));
                }
            }
        }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        // Stores the parent records.
        Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
        //Stores the status for which the case is assigned to verification queue
        Set<String> verPendingStatus = new Set<String>{STATUS_SENT_FOR_VERIFICATION, Constant_Case__mdt.getInstance('STATUS_INCOMPLETE_RESENT_FOR_VERIFICATIO').Value__c, STATUS_RESENT_FOR_VERIFICATION};
        for(Case newcase: newCasesMap.values()){
            Case oldCase = oldCasesMap.get(newCase.Id);
            Boolean isIntStatusChanged = (newCase.Internal_Status__c != oldCase.Internal_Status__c);
            if(isIntStatusChanged){
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newcase);
                // Updates the owner to Verification pending
                if(verPendingStatus.contains(newCase.Internal_Status__c)){
                    newCase.ownerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VERIFICATION_PENDING').Value__c);
                }
                if(String.isNotBlank(newCase.ParentId) && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c && parentCaseMap.containsKey(newCase.parentId)){
                    populateCaseFields(newCase,(Case)parentCaseMap.get(newCase.ParentId));
                }
            }
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){}
    //To populate the case fields with respect to parent fields
    public void populateCaseFields(Case newCase,Case parentCase){
        //Store the Medical Education QueueId
        Id cvQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_CREDENTIAL_VERIFICATION').Value__c);
        newCase.ContactId = parentCase.ContactId;
        newCase.AccountId = parentCase.AccountId;
        newCase.Case_Type__c = Constant_Case__mdt.getInstance('SERVICE_NEW_PAPER_FILE_REQ').Value__c;
        newCase.Entity__c = parentCase.Entity__c;
        newCase.OwnerId = cvQueueId;
    }
}