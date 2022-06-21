public with sharing class AccountAffiliationTriggerHandler{
    public static void handleAfterTrigger(boolean isInsert, boolean isUpdate, List<Account_Affiliation__c> newAccAffliations, Map<Id, Account_Affiliation__c> oldAccAffliationsMap){
        if(isInsert && AccountAffiliationTriggerHelper.firstRun){  
            AccountAffiliationTriggerHelper.firstRun = false;       
            afterInsert(newAccAffliations);
        } 
        if(isUpdate && AccountAffiliationTriggerHelper.firstRun){
            AccountAffiliationTriggerHelper.firstRun = false; 
            afterUpdate(newAccAffliations, oldAccAffliationsMap);
        }
    }
    public static void handleBeforeTrigger(boolean isInsert, boolean isUpdate, List<Account_Affiliation__c> newAccAffliations, Map<Id, Account_Affiliation__c> oldAccAffliationsMap){
        if(isInsert){
            beforeInsert(newAccAffliations);
        }
        if(isUpdate){
            beforeUpdate(newAccAffliations, oldAccAffliationsMap);
        }
    }
    public static void afterInsert(List<Account_Affiliation__c> newAccAffliations) {
        AccountAffiliationTriggerHelper.afterInsertHelper(newAccAffliations);
    }
    public static void afterUpdate(List<Account_Affiliation__c> newAccAffliations, Map<Id, Account_Affiliation__c> oldAccAffliationsMap) {
        AccountAffiliationTriggerHelper.afterUpdateHelper(newAccAffliations, oldAccAffliationsMap);
    } 
    public static void beforeInsert(List<Account_Affiliation__c> newAccAffliations) {
        AccountAffiliationTriggerHelper.beforeInsertHelper(newAccAffliations);
    }
    public static void beforeUpdate(List<Account_Affiliation__c> newAccAffliations, Map<Id, Account_Affiliation__c> oldAccAffliationsMap) {
        AccountAffiliationTriggerHelper.beforeUpdateHelper(newAccAffliations, oldAccAffliationsMap);
    } 
}