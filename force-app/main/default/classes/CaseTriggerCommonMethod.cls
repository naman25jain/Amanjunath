// This class is used to holds the generic logic of irrespective of the case record type and it should not contain any direct DML update on Case.
// The logic present here should not contain any record type specific logic
public with sharing class CaseTriggerCommonMethod{
    // Common method is used to pass the new case record map 
    public static void afterInsert(Map<Id, Case> newCasesMap){
        try{
            // Fetches the contact records
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // gets the APP 360 URL
            String app360url = CaseTriggerUtility.getNetworkApp360();
            // Stores the list of case records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            // Stores the list of case records to be updated
            Map<Id,Contact> updateConRecMap = new Map<Id,Contact>();
            // Calls Finance method
            if(CaseTriggerHandler_Finance.isFirstInsert){
                CaseTriggerHandler_Finance.isFirstInsert = false;
                CaseTriggerHandler_Finance.OnAfterInsert(newCasesMap);
            }
            for(Case newCase : newCasesMap.values()){
                if(String.isBlank(newCase.ECFMG_Portal_Case_Url__c)){
                    CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = newCase.Id,ECFMG_Portal_Case_Url__c = app360url+newCase.Id));
                }
                CaseTriggerUtility.updateConOFAC(newCase,updateConRecMap,contactMap);
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
            if(!updateConRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Contact')){
                CaseTriggerUtility.updateDMLMap(updateConRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Common method is used to pass the new and old case record map 
    public static void afterUpdate(Map<Id, Case> newCasesMap, Map<Id, Case> oldCasesMap){
        try{
            // Stores the list of case records to be updated
            Map<Id,Contact> updateConRecMap = new Map<Id,Contact>();
            // Fetches the contact records
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Calls Finance method
            if(CaseTriggerHandler_Finance.isFirstUpdate){
                CaseTriggerHandler_Finance.isFirstUpdate = false;
                CaseTriggerHandler_Finance.OnAfterUpdate(newCasesMap, oldCasesMap);
            }
            for(Case newCase : newCasesMap.values()){
                CaseTriggerUtility.updateConOFAC(newCase,updateConRecMap,contactMap);
            }
            if(!updateConRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Contact')){
                CaseTriggerUtility.updateDMLMap(updateConRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}