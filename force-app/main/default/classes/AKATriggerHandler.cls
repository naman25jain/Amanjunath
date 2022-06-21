public with sharing class AKATriggerHandler {

    public static void afterInsert(List<aka_Names__c> newAKAs) {        
        AKATriggerHelper.afterInsertHelper(newAKAs);       
    }
    public static void afterUpdate(List<aka_Names__c> newAKAs, Map<Id, aka_Names__c> oldNewAKAsMap) {
        If( !AKATriggerHelper.firstRun){
            AKATriggerHelper.afterUpdateHelper(newAKAs, oldNewAKAsMap);            
        }
    }
    
    public static void beforeInsert(List<aka_Names__c> newAKAs) {        
        AKATriggerHelper.beforeInsertHelper(newAKAs);       
    }
    public static void beforeUpdate(List<aka_Names__c> newAKAs, Map<Id, aka_Names__c> oldNewAKAsMap) {        
            AKATriggerHelper.beforeUpdateHelper(newAKAs, oldNewAKAsMap);                    
    }     
}