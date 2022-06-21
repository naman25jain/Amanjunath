// Handler class for Notification Cases
public with sharing class NotificationCaseTriggerHandler implements CaseTriggerHandlerInterface {
    final String REC_TYPE_NOTIFICATION  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_NOTIFICATION').Value__c;
    final Id notifiQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_NOTIFICATIONS').Value__c);
    final Id userId = UserInfo.getUserId();
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){                
                // Updates the Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_NOTIFICATION);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                // Updates Case Owner
                if(newCase.OwnerId != userId && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c){
                    newCase.OwnerId = userId;
                }
                else if(newCase.OwnerId != notifiQueueId && (newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c)){
                    newCase.OwnerId = notifiQueueId;
                }
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
                // Updates Case Owner
                if(newCase.OwnerId != userId && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c){
                    newCase.OwnerId = userId;
                }
                else if(newCase.OwnerId != notifiQueueId && (newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c)){
                    newCase.OwnerId = notifiQueueId;
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