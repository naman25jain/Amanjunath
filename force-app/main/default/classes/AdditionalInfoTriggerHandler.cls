public with sharing class AdditionalInfoTriggerHandler{
    public static void handleAfterTrigger(boolean isInsert, boolean isUpdate, List<Additional_Info__c> newAddInfos, Map<Id, Additional_Info__c> oldNewAddInfosMap){
        if(isInsert){        
            afterInsert(newAddInfos);
        } 
        if(isUpdate){
            afterUpdate(newAddInfos, oldNewAddInfosMap);        
        }
    }
    public static void handleBeforeTrigger(boolean isInsert, boolean isUpdate, List<Additional_Info__c> newAddInfos, Map<Id, Additional_Info__c> oldNewAddInfosMap){
        if(isInsert){
            beforeInsert(newAddInfos);
        }
        if(isUpdate){            
            beforeUpdate(newAddInfos, oldNewAddInfosMap);
        }
    }
    public static void afterInsert(List<Additional_Info__c> newAddInfos){
        AdditionalInfoTriggerHelper.afterInsertHelper(newAddInfos);
    }
    
    public static void afterUpdate(List<Additional_Info__c> newAddInfos, Map<Id, Additional_Info__c> oldNewAddInfosMap){         
        AdditionalInfoTriggerHelper.afterUpdateHelper(newAddInfos, oldNewAddInfosMap);
    } 
    public static void beforeInsert(List<Additional_Info__c> newAddInfos){
        AdditionalInfoTriggerHelper.beforeInsertHelper(newAddInfos);
    }
    public static void beforeUpdate(List<Additional_Info__c> newAddInfos, Map<Id, Additional_Info__c> oldNewAddInfosMap){               
        AdditionalInfoTriggerHelper.beforeUpdateHelper(newAddInfos, oldNewAddInfosMap);
    }
}