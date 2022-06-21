public with sharing class AccountLanguageTriggerHandler{
    public static void handleAfterTrigger(boolean isInsert, boolean isUpdate, List<Account_Language__c> newAccLanguages, Map<Id, Account_Language__c> oldNewAccLanguagesMap){
        if(isInsert){        
            afterInsert(newAccLanguages);
        } 
        if(isUpdate){
            afterUpdate(newAccLanguages, oldNewAccLanguagesMap);        
        }
    }
    public static void handleBeforeTrigger(boolean isInsert, boolean isUpdate, List<Account_Language__c> newAccLanguages, Map<Id, Account_Language__c> oldNewAccLanguagesMap){
        if(isInsert){
            beforeInsert(newAccLanguages);
        }
        if(isUpdate){            
            beforeUpdate(newAccLanguages, oldNewAccLanguagesMap);
        }
    }
    public static void afterInsert(List<Account_Language__c> newAccLanguages){
        AccountLanguageTriggerHelper.afterInsertHelper(NewAccLanguages);
    }
    public static void afterUpdate(List<Account_Language__c> newAccLanguages, Map<Id, Account_Language__c> oldNewAccLanguagesMap){         
        AccountLanguageTriggerHelper.afterUpdateHelper(newAccLanguages, oldNewAccLanguagesMap);
    } 
    public static void beforeInsert(List<Account_Language__c> newAccLanguages){
        AccountLanguageTriggerHelper.beforeInsertHelper(NewAccLanguages);
    }
    public static void beforeUpdate(List<Account_Language__c> newAccLanguages, Map<Id, Account_Language__c> oldNewAccLanguagesMap){         
        AccountLanguageTriggerHelper.beforeUpdateHelper(newAccLanguages, oldNewAccLanguagesMap);
    }
}