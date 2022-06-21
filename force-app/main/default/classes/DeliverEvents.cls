public class DeliverEvents {
    
    private static String mapRecordTypeEventName(String key){
        Map<String, String> mapRecordTypeAndEvent = new Map<String, String>{
            'CASE_RECORD_TYPE_EXAM_REGISTRATION'=>'CIBIS_REGISTRATION_EVENT',
            'USMLE_Transcript'=>'CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT',
            'Region_Change'=>'CIBIS_EXAM_EVENT',
            'Eligibility_Period_Extension'=>'CIBIS_ELIGIBILITY_EVALUATION_EVENT',
            'Application_For_Certification'=>'CIBIS_CANDIDATE_EVENT'
        };
            return mapRecordTypeAndEvent.containsKey(key) ? mapRecordTypeAndEvent.get(key) : null;
    }
	
    @AuraEnabled
    public static void publishEvents(Id recordId, String recordTypeId, String status){
        Map<String, Set<Id>> cibisIdMap = new Map<String, Set<Id>>();
        Map<ID, Schema.RecordTypeInfo> developerNameMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        String recordTypeName = developerNameMap.get(recordTypeId).getDeveloperName();
        if(recordTypeName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION){
            CibisDupCheckRequestEventHandler.buildDupCheck(new List<Id>{recordId});
        } else if(recordTypeName == Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT){
            Case caseContactRec = [SELECT Id, ContactId FROM Case WHERE Id=:recordId];
            if(caseContactRec.ContactId != null)
                cibisIdMap.put(mapRecordTypeEventName(recordTypeName), new Set<Id> {caseContactRec.ContactId});
        } else {
            cibisIdMap.put(mapRecordTypeEventName(recordTypeName), new Set<Id> {recordId});
        }
      
        Case statusUpdate = new Case(Id=recordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS);
        update statusUpdate;
          if(cibisIdMap != null && !cibisIdMap.isEmpty()){
            CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);
        }
    }
}