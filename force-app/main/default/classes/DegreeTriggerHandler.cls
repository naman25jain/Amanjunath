public with sharing class DegreeTriggerHandler {
    public static void afterInsert(List<Degree__c> newDegrees) {
        DegreeTriggerHelper.afterInsertHelper(newDegrees);
    }
    public static void afterUpdate(List<Degree__c> newDegrees, Map<Id, Degree__c> oldDegreesMap) {
        DegreeTriggerHelper.afterUpdateHelper(newDegrees, oldDegreesMap);
    } 

    public static void beforeInsert(List<Degree__c> newDegrees) {
        DegreeTriggerHelper.beforeInsertHelper(newDegrees);
    }
    public static void beforeUpdate(List<Degree__c> newDegrees, Map<Id, Degree__c> oldDegreesMap) {
        DegreeTriggerHelper.beforeUpdateHelper(newDegrees, oldDegreesMap);
    } 
}