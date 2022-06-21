public class AuthorizedSignListTriggerHandler implements CaseTriggerHandlerInterface{
    final String STATUS_NEW = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
    final String REC_TYPE_AUTH_SIGN_LIST  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_AUTHSIGNLIST').Value__c;
    public void beforeInsert(List<Case> newCases){
        try{
            //Fetch parent case details 
            Map<String, sObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            Id authSignQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_AUTH_SIGNATURE_LIST').Value__c);
            for(Case newCase: newCases){
                // Updates the Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_AUTH_SIGN_LIST);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                // Update case fields
                if(newCase.Internal_Status__c == STATUS_NEW && String.isNotBlank(newCase.ParentId) && parentCaseMap.containsKey(newCase.ParentId)){
                    Case parentCase = (Case)parentCaseMap.get(newCase.ParentId);
                    newCase.ContactId = parentCase.ContactId;                  
                    newCase.Case_Type__c = Constant_Case__mdt.getInstance('TYPE_NEW_AUTH_SIGN_LIST_REQ').Value__c;
                    newCase.Entity__c = parentCase.Entity__c;
                    newCase.Document_Type__c = parentCase.Document_Type__c;
                    newCase.Document_URL__c = parentCase.Document_URL__c;
                    newCase.OwnerId = authSignQueueId;
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
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
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){}
}