public with sharing class Object2DegreeTriggerHelper {
    /**
     * Created by Femi
     * Method Name: update ecfmg acceptable field
     * Purpose : Method to check and update ecfmg acceptable field.
     * Return Type : 
     */

    public static boolean firstRun = true; 

    public static void updateEcfmgAcceptableFlag(List<Object2Degree__c> newObjList, Map<Id,Object2Degree__c> oldMap, Boolean isUpdate){
        Set<String> listToUpdate = new Set<String>();
        for(Object2Degree__c obj: newObjList){
            if(obj.Account__c !=null){
                listToUpdate.add(obj.Account__c);
            }
            if(isUpdate && oldMap.get(obj.Id).Account__c !=null && oldMap.get(obj.Id).Account__c !=obj.Account__c)
            {
                listToUpdate.add(oldMap.get(obj.Id).Account__c);
            }
        }
        List<Account> accountList = [SELECT Id 
                                    FROM Account 
                                    WHERE id IN: listToUpdate 
                                    AND (Medschool_Code__c != null OR Medschool_Code__c != '')  
                                    AND BillingCountry != 'Canada' AND BillingCountry  != 'United States' 
                                    AND Deleted__c = false 
                                    AND School__c = true 
                                    AND RecordType.Name =: Constants.ACCOUNT_RECORD_TYPE_ENTITY
                                    WITH SECURITY_ENFORCED
                                    ];
        EntityServiceRequestController.updateEcfmgAcceptableFlag(accountList);
    }

    public static Boolean isEligibleForProgramDegree(Id degreeId, Id progId, Id accId){
        Boolean bReturn = false; 
        if((!String.isBlank(WDOMSService.getDegreeWDOMSIdByDegreeId(degreeId)))
        && (!String.isBlank(WDOMSService.getProgramWDOMSIdByProgId(progId)))
        && (!String.isBlank(WDOMSService.getWDOMSIdByAccountId(accId))))
        {
            bReturn = true; 
        }
        return bReturn; 
    }

    public static Boolean isEligibleForGradYear(Id degreeId,  Id accId){
        Boolean bReturn = false; 
        if((!String.isBlank(WDOMSService.getDegreeWDOMSIdByDegreeId(degreeId)))        
        && (!String.isBlank(WDOMSService.getWDOMSIdByAccountId(accId))))
        {
            bReturn = true; 
        }
        return bReturn; 
    }

    public static void afterInsertHelper(List<Object2Degree__c> newObject2Degrees){
        String objectType = ''; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST; 
        Id objectId;     
        boolean raisePEForProgramDegree; 
        boolean raisePEForGradYear;       
        for(Object2Degree__c newObject2Degree : newObject2Degrees){   
            raisePEForProgramDegree =  isEligibleForProgramDegree(newObject2Degree.Degree__c, newObject2Degree.Program__c, newObject2Degree.Account__c);         
            raisePEForGradYear=  isEligibleForGradYear(newObject2Degree.Degree__c, newObject2Degree.Account__c);
            if (raisePEForProgramDegree){
                objectType = Constants.WDOMS_OBJ_MDT_PROGRAM_DEGREE;
                objectId = newObject2Degree.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }                   
            if (raisePEForGradYear && (!String.isBlank(newObject2Degree.Graduation_Year__c))){                
                objectType = Constants.WDOMS_OBJ_MDT_GRAD_YEAR;
                objectId = newObject2Degree.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }            
        }        
    }
    
    public static void afterUpdateHelper(List<Object2Degree__c> newObject2Degrees, Map<Id, Object2Degree__c> oldnewObject2DegreeMap){
        String objectType = Constants.WDOMS_OBJ_MDT_PROGRAM_DEGREE; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;    
        boolean raisePEForProgramDegree; 
        boolean raisePEForGradYear;                       
        for(Object2Degree__c newObject2Degree : newObject2Degrees){
            raisePEForProgramDegree =  isEligibleForProgramDegree(newObject2Degree.Degree__c, newObject2Degree.Program__c, newObject2Degree.Account__c);         
            raisePEForGradYear=  isEligibleForGradYear(newObject2Degree.Degree__c, newObject2Degree.Account__c);           
            if (newObject2Degree.Degree__c !=null && newObject2Degree.Program__c !=null && newObject2Degree.Account__c != null){                
                if (raisePEForProgramDegree){
                    objectType = Constants.WDOMS_OBJ_MDT_PROGRAM_DEGREE; 
                    objectId = newObject2Degree.Id; 
                    WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
                }
            }            
            if (raisePEForGradYear && (!String.isBlank(newObject2Degree.Graduation_Year__c))){                
                objectType = Constants.WDOMS_OBJ_MDT_GRAD_YEAR; 
                objectId = newObject2Degree.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
            }
        }   
    }
    
    public static void beforeInsertHelper(List<Object2Degree__c> newObject2Degrees){        
        insertWDOMSId(newObject2Degrees);        
    } 

    public static void beforeUpdateHelper(List<Object2Degree__c> newObject2Degrees, Map<Id, Object2Degree__c> oldnewObject2DegreeMap){
        insertWDOMSId(newObject2Degrees); 
    }

    public static void insertWDOMSId(List<Object2Degree__c> newObject2Degrees){        
        List<WDOMS_ID_Sequence__c> wdomsIdSeqs = new List<WDOMS_ID_Sequence__c>();
        for(Object2Degree__c newObject2Degree : newObject2Degrees){
            if (string.isBlank(newObject2Degree.WDOMS_ID__c)){ 
                WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
                if(wdomsIdSeq.MDT_Program_Degree_ID__c != null){
                    Integer progDegWDOMSId =Integer.valueOf(wdomsIdSeq.MDT_Program_Degree_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                    newObject2Degree.WDOMS_ID__c = String.valueOf(progDegWDOMSId); 
                    wdomsIdSeq.MDT_Program_Degree_ID__c = progDegWDOMSId;
                    wdomsIdSeqs.add(wdomsIdSeq);                    
                }
            }
        }
        if (Schema.sObjectType.WDOMS_ID_Sequence__c.fields.MDT_Program_Degree_ID__c.isUpdateable() && wdomsIdSeqs.size()>0){
            update wdomsIdSeqs; 
        }

    }    
}