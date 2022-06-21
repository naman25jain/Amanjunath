public with sharing class AccountTriggerHandler {
    public static void afterInsert(List<Account> newAccounts) {
        AccountTriggerHelper.afterInsertHelper(newAccounts);
    }

    public static void afterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        AccountTriggerHelper.afterUpdateHelper(newAccounts, oldAccountsMap);
    } 

    public static void beforeInsert(List<Account> newAccounts) {
        AccountTriggerHelper.beforeInsertHelper(newAccounts);
    }

    public static void beforeUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        AccountTriggerHelper.beforeUpdateHelper(newAccounts, oldAccountsMap);
    } 
}