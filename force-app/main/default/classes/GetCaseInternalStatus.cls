public with sharing class GetCaseInternalStatus{
    private static GetCaseInternalStatus instance = null;
    private map<string,map<string,Internal_Status_External_Status_Mapping__mdt>> recordTypeIntExtStatus = new map<string,map<string,Internal_Status_External_Status_Mapping__mdt>>();
    public GetCaseInternalStatus(){
        map<string,Schema.RecordTypeInfo> mapRecordTypeId = GenericUtilities.getAllrecordTypeDevName('Case');
        for(Internal_Status_External_Status_Mapping__mdt internalStatus:[SELECT Id,Internal_Status__c,External_Status__c,Entity_External_Status__c,Prior_Internal_Status__c,Record_Type_Developer_Name__c FROM Internal_Status_External_Status_Mapping__mdt]){
            map<string,Internal_Status_External_Status_Mapping__mdt> intExtStatus = new map<string,Internal_Status_External_Status_Mapping__mdt>();
            Id recTypeId =  mapRecordTypeId.get(internalStatus.Record_Type_Developer_Name__c).getRecordTypeId();
            if(recordTypeIntExtStatus.containsKey(recTypeId)){
                intExtStatus = recordTypeIntExtStatus.get(recTypeId);
            }
            if(internalStatus.Prior_Internal_Status__c == null){
                intExtStatus.put(internalStatus.Internal_Status__c,internalStatus);
            }else{
                intExtStatus.put(internalStatus.Internal_Status__c+Constants.STATUS_SEPARATOR+internalStatus.Prior_Internal_Status__c,internalStatus);
            }
            recordTypeIntExtStatus.put(recTypeId,intExtStatus);
        }
    }
    public static GetCaseInternalStatus getInstance(){
        if(instance == null){
            instance = new GetCaseInternalStatus();
        }
        return instance;
    }
    public map<string,map<string,Internal_Status_External_Status_Mapping__mdt>> getIntExtStatus(){
        return recordTypeIntExtStatus;
    }
}