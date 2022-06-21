public with sharing class ProgramTriggerHelper {
    public static boolean firstRun = true; 
    
    public static void afterInsertHelper(List<Program__c> newPrograms){
        String objectType = Constants.WDOMS_OBJ_MDT_PROGRAM;
        String operationtype =  Constants.WDOMS_PLATFORM_OPERATION_POST; 
        Id objectId;    
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Program__c.getRecordTypeInfosById(); 
        List<Id> objectIds= new List<Id>();  
        List<Id> programLangObjectIds= new List<Id>(); 
        Map<Id, String> programLanguageMap = new Map<Id, String>();             
        for(Program__c newProgram : newPrograms){
            string recType = rtMap.get(newProgram.RecordTypeId).getName();            
            if (recType == Constants.PROGRAM_TYPE_EDUCATIONAL_PROGRAM){                
                objectIds.add(newProgram.Id);                 
                if (!string.isBlank(newProgram.Language_s_of_Instruction__c)){
                    programLangObjectIds.add(newProgram.Id);
                    programLanguageMap.put(newProgram.Id, newProgram.Language_s_of_Instruction__c); 
                }
            }            
        }
        if(objectIds.size() > 0 ){
            WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectIds, operationtype ); 
        }
        if  (!programLanguageMap.isEmpty()){        
            WDOMSResponseService.raisePEforProgramLanguage(objectType,programLanguageMap, operationtype ); 
        }

    }  
    
    public static void afterUpdateHelper(List<Program__c> newPrograms, Map<Id, Program__c> oldProgramsMap){
        String objectType = Constants.WDOMS_OBJ_MDT_PROGRAM; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;   
        String oldOperationStatus;
        String oldLanguages;  
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Program__c.getRecordTypeInfosById(); 
        for (Id key: oldProgramsMap.keySet()){
            oldOperationStatus = oldProgramsMap.get(key).Operational_Status__c; 
            oldLanguages = oldProgramsMap.get(key).Language_s_of_Instruction__c;             
        }                   
        for(Program__c newProgram : newPrograms){            
            string recType = rtMap.get(newProgram.RecordTypeId).getName();            
            if (recType == Constants.PROGRAM_TYPE_EDUCATIONAL_PROGRAM){
                objectId = newProgram.Id; 
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype ); 
                String newProgLangs = newProgram.Language_s_of_Instruction__c;                 
                if ((newProgram.Language_s_of_Instruction__c != oldLanguages) && (!string.isBlank(newProgram.Language_s_of_Instruction__c))){
                    objectType = Constants.WDOMS_OBJ_MDT_PROGRAM_LANGUAGE;                   
                }

            }
            if (oldOperationStatus != newProgram.Operational_Status__c && newProgram.Operational_Status__c == Constants.STATUS_NO){
                updateAccountAffiliationForActiveField(newProgram.Id); 
            }
        }
    }

    public static void beforeInsertHelper(List<Program__c> newPrograms){
        insertWDOMSId(newPrograms); 
    } 

    public static void beforeUpdateHelper(List<Program__c> newPrograms, Map<Id, Program__c> oldProgramsMap){
        insertWDOMSId(newPrograms); 
    }

    public static void insertWDOMSId(List<Program__c> newPrograms){
        Integer progId; 
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Program__c.getRecordTypeInfosById();  
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
        Boolean updateSeq = false; 
        for(Program__c newProgram : newPrograms){
            string recType = rtMap.get(newProgram.RecordTypeId).getName();            
            if (recType == Constants.PROGRAM_TYPE_EDUCATIONAL_PROGRAM){
                if (string.isBlank(newProgram.WDOMS_ID__c)){                   
                    Integer progWDOMSId =Integer.valueOf(wdomsIdSeq.MDT_Program_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                    newProgram.WDOMS_ID__c = String.valueOf(progWDOMSId); 
                    wdomsIdSeq.MDT_Program_ID__c = progWDOMSId; 
                    updateSeq = true;                 
                }
            }
        }              
        if  (WDOMS_ID_Sequence__c.SObjectType.getDescribe().isUpdateable() && updateSeq)  {                      
            update wdomsIdSeq;     
        } 
    }

    public static void updateAccountAffiliationForActiveField(Id progId){
        try {
            List<Account_Affiliation__c>  listAccAfftoUpdate = WDOMSService.getAccountAffiliationByProgramId(progId); 
            for(Account_Affiliation__c accAffUpdate : listAccAfftoUpdate ){
                accAffUpdate.Active__c = Constants.STATUS_NO; 
            }
             if(Account_Affiliation__c.SObjectType.getDescribe().isUpdateable()){
                update listAccAfftoUpdate; 
             }
        } catch (DmlException e) {
            WDOMSResponseService.logMessage('Account_Affiliation__c update failed with following error: ' + e.getMessage());
        }
    } 

}