public with sharing class Object2DegreeTriggerHandler {
    public static void handleAfterInsert(boolean isInsert, boolean isUpdate, boolean firstRun, List<Object2Degree__c> object2Degrees, Map<Id, Object2Degree__c> oldObject2DegreesMap){
        if(isInsert && firstRun){  
            Object2DegreeTriggerHelper.firstRun = false;       
            afterInsert(object2Degrees);
        } 
        if(isUpdate && firstRun){
            Object2DegreeTriggerHelper.firstRun = false; 
            afterUpdate(object2Degrees, oldObject2DegreesMap);
        }
    }
    public static void handleBeforeInsert(boolean isInsert, boolean isUpdate, List<Object2Degree__c> object2Degrees, Map<Id, Object2Degree__c> oldObject2DegreesMap){
        if(isInsert){
            beforeInsert(object2Degrees);
        }
        if(isUpdate){
            beforeUpdate(object2Degrees, oldObject2DegreesMap);
        }
    }
    public static void afterInsert(List<Object2Degree__c> object2Degrees) {
        Object2DegreeTriggerHelper.afterInsertHelper(object2Degrees);
    }
    public static void afterUpdate(List<Object2Degree__c> object2Degrees, Map<Id, Object2Degree__c> oldObject2DegreesMap) {
        Object2DegreeTriggerHelper.afterUpdateHelper(object2Degrees, oldObject2DegreesMap);
    } 
    public static void beforeInsert(List<Object2Degree__c> object2Degrees) {
        Object2DegreeTriggerHelper.beforeInsertHelper(object2Degrees);
    }
    public static void beforeUpdate(List<Object2Degree__c> object2Degrees, Map<Id, Object2Degree__c> oldObject2DegreesMap) {
        Object2DegreeTriggerHelper.beforeUpdateHelper(object2Degrees, oldObject2DegreesMap);
    } 
}