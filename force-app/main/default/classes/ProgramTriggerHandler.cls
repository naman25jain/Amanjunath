public with sharing class ProgramTriggerHandler {
    public static void handleAfterTrigger(boolean isInsert, boolean isUpdate, boolean firstRun, List<Program__c> newPrograms, Map<Id, Program__c> oldProgramsMap){
        if(isInsert && firstRun){  
            ProgramTriggerHelper.firstRun = false;       
            afterInsert(newPrograms);
        } 
        if(isUpdate && firstRun){
            ProgramTriggerHelper.firstRun = false; 
            afterUpdate(newPrograms, oldProgramsMap);
        }
    }
    public static void handleBeforeTrigger(boolean isInsert, boolean isUpdate, List<Program__c> newPrograms, Map<Id, Program__c> oldProgramsMap){
        if(isInsert){
            beforeInsert(newPrograms);
        }
        if(isUpdate){
            beforeUpdate(newPrograms, oldProgramsMap);
        }    
    }
    public static void afterInsert(List<Program__c> newPrograms) {
        ProgramTriggerHelper.afterInsertHelper(newPrograms);
    }
     public static void afterUpdate(List<Program__c> newPrograms, Map<Id, Program__c> oldProgramsMap) {
        ProgramTriggerHelper.afterUpdateHelper(newPrograms, oldProgramsMap);
    }
    public static void beforeInsert(List<Program__c> newPrograms) {
        ProgramTriggerHelper.beforeInsertHelper(newPrograms);
    }
    public static void beforeUpdate(List<Program__c> newPrograms, Map<Id, Program__c> oldProgramsMap) {
        ProgramTriggerHelper.beforeUpdateHelper(newPrograms, oldProgramsMap);
    }
}