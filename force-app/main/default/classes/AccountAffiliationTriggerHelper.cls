public with sharing class AccountAffiliationTriggerHelper {
    public static boolean firstRun = true; 
    
    public static void afterInsertHelper(List<Account_Affiliation__c> newAccAffliations){
        String objectType; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST; 
        Id objectId; 
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosById();                   
        for(Account_Affiliation__c newAccAffliation : newAccAffliations){                       
            String recType = rtMap.get(newAccAffliation.RecordTypeId).getName(); 
            if (newAccAffliation.Account1__c !=null && newAccAffliation.Program__c !=null && recType == Constants.ACCOUNT_AFFILIATION_TYPE_EDUCATIONAL_PROGRAM){
                objectType = Constants.WDOMS_OBJ_SCHOOL_PROGRAM;                            
                objectId = newAccAffliation.Id;                
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }else if (newAccAffliation.Account1__c !=null && newAccAffliation.Account2__c !=null && recType == Constants.ACCOUNT_AFFILIATION_TYPE_ACADEMIC_AFFILIATION){  
                objectType = Constants.WDOMS_OBJ_SCHOOL_AFFILIATION;                            
                objectId = newAccAffliation.Id;                
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }        
        }        
    }
    
    public static void afterUpdateHelper(List<Account_Affiliation__c> newAccAffliations, Map<Id, Account_Affiliation__c> oldAccAffiliationsMap){
        String objectType; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;  
        String oldAccountId;  
        String oldProgramId;          
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosById(); 
        for (Id key: oldAccAffiliationsMap.keySet()){
            oldAccountId = oldAccAffiliationsMap.get(key).Account1__c; 
            oldProgramId = oldAccAffiliationsMap.get(key).Program__c;            
        }         
        for(Account_Affiliation__c newAccAffliation : newAccAffliations){            
            String recType = rtMap.get(newAccAffliation.RecordTypeId).getName();            
            if (newAccAffliation.Account1__c !=null && newAccAffliation.Program__c !=null && recType == Constants.ACCOUNT_AFFILIATION_TYPE_EDUCATIONAL_PROGRAM){
                if (oldAccountId !=newAccAffliation.Account1__c  || oldProgramId != newAccAffliation.Program__c ){                    
                    objectType = Constants.WDOMS_OBJ_SCHOOL_PROGRAM;                            
                    objectId = newAccAffliation.Id;                
                    WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
                }
            }else if (newAccAffliation.Account1__c !=null && newAccAffliation.Account2__c !=null && recType == Constants.ACCOUNT_AFFILIATION_TYPE_ACADEMIC_AFFILIATION){  
                objectType = Constants.WDOMS_OBJ_SCHOOL_AFFILIATION;         
                objectId = newAccAffliation.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype ); 
            }
        }   
    }   
    
    public static void beforeInsertHelper(List<Account_Affiliation__c> newAccAffliations){
        insertWDOMSId(newAccAffliations); 
    }  
    public static void beforeUpdateHelper(List<Account_Affiliation__c> newAccAffliations, Map<Id, Account_Affiliation__c> oldAccAffiliationsMap){
        insertWDOMSId(newAccAffliations); 
    } 

    public static void insertWDOMSId(List<Account_Affiliation__c> newAccAffliations){              
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosById();
        List<WDOMS_ID_Sequence__c> wdomsIdSeqs = new List<WDOMS_ID_Sequence__c>();     
        for(Account_Affiliation__c newAccAffliation : newAccAffliations){
            string recType = rtMap.get(newAccAffliation.RecordTypeId).getName(); 
            if ( recType == Constants.ACCOUNT_AFFILIATION_TYPE_ACADEMIC_AFFILIATION ||  recType == Constants.ACCOUNT_AFFILIATION_TYPE_EDUCATIONAL_PROGRAM){
                if (string.isBlank(newAccAffliation.WDOMS_ID__c)){  
                    WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
                    if (wdomsIdSeq.School_Affiliation_ID__c != null){
                        Integer accAffiliationId =Integer.valueOf(wdomsIdSeq.School_Affiliation_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                        newAccAffliation.WDOMS_ID__c = String.valueOf(accAffiliationId); 
                        wdomsIdSeq.School_Affiliation_ID__c = accAffiliationId;
                        wdomsIdSeqs.add(wdomsIdSeq); 
                    }
                }
            }
        }
        if (Schema.sObjectType.WDOMS_ID_Sequence__c.fields.School_Affiliation_ID__c.isUpdateable() && wdomsIdSeqs.size()>0){
            update wdomsIdSeqs; 
        }
    }    
}