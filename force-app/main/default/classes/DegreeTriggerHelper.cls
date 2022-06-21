public with sharing class DegreeTriggerHelper {
    public static boolean firstRun = true; 

    public static void afterInsertHelper(List<Degree__c> newDegrees){
        string objectType = Constants.WDOMS_OBJ_MDT_PROGRAM_DEGREE_TYPE;
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST; 
        Id objectId;         
        for(Degree__c newDegree : newDegrees){            
            if (newDegree.Id !=null){
                objectId = newDegree.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }            
        }        
    } 

    public static void afterUpdateHelper(List<Degree__c> newDegrees, Map<Id, Degree__c> oldDegreesMap){
        string objectType = Constants.WDOMS_OBJ_MDT_PROGRAM_DEGREE_TYPE;
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;              
        for(Degree__c newDegree : newDegrees){
            if (newDegree.Id !=null){
                objectId = newDegree.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype ); 
            }
        }   
    }


    public static void beforeInsertHelper(List<Degree__c> newDegrees){        
        insertWDOMSId(newDegrees);        
    } 

    public static void beforeUpdateHelper(List<Degree__c> newDegrees, Map<Id, Degree__c> oldDegreesMap){
        insertWDOMSId(newDegrees); 
    }

    public static void insertWDOMSId(List<Degree__c> newDegrees){        
        List<WDOMS_ID_Sequence__c> wdomsIdSeqs = new List<WDOMS_ID_Sequence__c>(); 
        for(Degree__c newDegree : newDegrees){
            if (string.isBlank(newDegree.WDOMS_ID__c)){ 
                WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
                if (wdomsIdSeq.MDT_Degree_Type_ID__c != null){
                    Integer dgreeWDOMSId =Integer.valueOf(wdomsIdSeq.MDT_Degree_Type_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                    newDegree.WDOMS_ID__c = String.valueOf(dgreeWDOMSId); 
                    wdomsIdSeq.MDT_Degree_Type_ID__c = dgreeWDOMSId;
                    wdomsIdSeqs.add(wdomsIdSeq);  
                }               
            }
        }
        if (Schema.sObjectType.WDOMS_ID_Sequence__c.fields.MDT_Degree_Type_ID__c.isUpdateable() && wdomsIdSeqs.size()>0){
            update wdomsIdSeqs; 
        } 
    }
}