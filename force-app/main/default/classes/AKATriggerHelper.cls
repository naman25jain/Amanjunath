public with sharing class AKATriggerHelper {

    public static boolean firstRun = true;  

    public static void afterInsertHelper(List<aka_Names__c> newAKAs){
        String objectType = Constants.WDOMS_OBJ_SCHOOL_AKA; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST; 
        Id objectId;                 
        for(aka_Names__c newAKA : newAKAs){            
            if (newAKA.Account__c !=null){
                if ((!String.isBlank(newAKA.Year_From__c)) && (!String.isBlank(newAKA.Year_To__c))
                || (String.isBlank(newAKA.Year_From__c)) && (String.isBlank(newAKA.Year_To__c))){
                    objectId = newAKA.Id; 
                    WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
                }
            }            
        }        
    }  
    
    public static void afterUpdateHelper(List<aka_Names__c> newAKAs, Map<Id, aka_Names__c> oldAKAsMap){
        String objectType = Constants.WDOMS_OBJ_SCHOOL_AKA; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId; 
        for(aka_Names__c newAKA : newAKAs){
            if ((!String.isBlank(newAKA.Year_From__c)) && (!String.isBlank(newAKA.Year_To__c))
                 || (String.isBlank(newAKA.Year_From__c)) && (String.isBlank(newAKA.Year_To__c))){
                objectId = newAKA.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }
        }   
    }

    public static void beforeInsertHelper(List<aka_Names__c> newAKAs){
        insertWDOMSId(newAKAs); 
    }

    public static void beforeUpdateHelper(List<aka_Names__c> newAKAs, Map<Id, aka_Names__c> oldAKAsMap){
        insertWDOMSId(newAKAs); 
    }

    public static void insertWDOMSId(List<aka_Names__c> newAKAs){        
        List<WDOMS_ID_Sequence__c> wdomsIdSeqs = new List<WDOMS_ID_Sequence__c>();
        for(aka_Names__c newAKA : newAKAs){
            if (string.isBlank(newAKA.WDOMS_ID__c)){   
                WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
                if (wdomsIdSeq.AKA_ID__c != null){                
                    Integer akaWDOMSId =Integer.valueOf(wdomsIdSeq.AKA_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                    newAKA.WDOMS_ID__c = String.valueOf(akaWDOMSId); 
                    wdomsIdSeq.AKA_ID__c = akaWDOMSId;
                    wdomsIdSeqs.add(wdomsIdSeq);
                }                
            }
        }
        if (Schema.sObjectType.WDOMS_ID_Sequence__c.fields.AKA_ID__c.isUpdateable() && wdomsIdSeqs.size()>0){
            update wdomsIdSeqs; 
        }
    }
}