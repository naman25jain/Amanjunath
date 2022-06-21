public with sharing class AccountLanguageTriggerHelper {

    public static void afterInsertHelper(List<Account_Language__c> newAccLangs){
        String objectType = Constants.WDOMS_OBJ_SCHOOL_LANGUAGE; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST; 
        Id objectId;                 
        for(Account_Language__c newAccLang : newAccLangs){            
            if (newAccLang.Account__c !=null){
                objectId = newAccLang.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }            
        }        
    }  
    
    public static void afterUpdateHelper(List<Account_Language__c> newAccLangs, Map<Id, Account_Language__c> oldAccLangsMap){
        String objectType = Constants.WDOMS_OBJ_SCHOOL_LANGUAGE; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;
        String oldAccount; 
        String oldLanguage;  
        for (Id key: oldAccLangsMap.keySet()){
            oldAccount = oldAccLangsMap.get(key).Account__c; 
            oldLanguage = oldAccLangsMap.get(key).Language__c; 
        }                  
        for(Account_Language__c newAccLang : newAccLangs){
            if (newAccLang.Account__c !=null){
                if (oldAccount != newAccLang.Account__c || oldLanguage != newAccLang.Language__c ){
                    objectId = newAccLang.Id; 
                    WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype );
                } 
            }
        }   
    }

    public static void beforeInsertHelper(List<Account_Language__c> newAccLangs){
        insertWDOMSId(newAccLangs);
    }

    public static void beforeUpdateHelper(List<Account_Language__c> newAccLangs, Map<Id, Account_Language__c> oldAccLangsMap){
        insertWDOMSId(newAccLangs);
    }

    public static void insertWDOMSId(List<Account_Language__c> newAccLangs){        
        List<WDOMS_ID_Sequence__c> wdomsIdSeqs = new List<WDOMS_ID_Sequence__c>();         
        for(Account_Language__c newAccLang : newAccLangs){
            if (string.isBlank(newAccLang.WDOMS_ID__c)){  
                WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
                if (wdomsIdSeq.School_Language_ID__c != null){
                    Integer accLangId =Integer.valueOf(wdomsIdSeq.School_Language_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                    newAccLang.WDOMS_ID__c = String.valueOf(accLangId); 
                    wdomsIdSeq.School_Language_ID__c = accLangId;
                    wdomsIdSeqs.add(wdomsIdSeq); 
                }
                               
            }
        }
        if (Schema.sObjectType.WDOMS_ID_Sequence__c.fields.School_Language_ID__c.isUpdateable() && wdomsIdSeqs.size()>0){
            update wdomsIdSeqs; 
        }
    }

}