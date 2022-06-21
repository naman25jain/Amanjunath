public with sharing class AccountTriggerHelper {
    
    public static boolean firstRun = true; 
    
    public static void afterInsertHelper(List<Account> newAccounts){
        String objectType = Constants.WDOMS_OBJ_SCHOOL; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST;  
        List<Id> objectIds= new List<Id>();         
        Map<ID, Schema.RecordTypeInfo> rectypeMap = Schema.SObjectType.Account.getRecordTypeInfosById();         
        for(Account newAccount : newAccounts){
            String recType = rectypeMap.get(newAccount.RecordTypeId).getName();
            if (recType == Constants.ACCOUNT_RECORD_TYPE_ENTITY && newAccount.School__c ==true && newAccount.BillingCountry !=null){
                objectIds.add(newAccount.Id); 
            }            
        }        
        if(objectIds.size()>0){
            WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectIds, operationtype );
        }

    }  
    
    public static void afterUpdateHelper(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        String objectType = Constants.WDOMS_OBJ_SCHOOL; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;
        List<Id> objectIds = new List<Id>();     
        boolean oldEntityTypeSchool = false; 
        Map<ID, Schema.RecordTypeInfo> rectypeMap = Schema.SObjectType.Account.getRecordTypeInfosById();         
        for (Id key: oldAccountsMap.keySet()){
            oldEntityTypeSchool = oldAccountsMap.get(key).School__c; 
        }                   
        for(Account newAccount : newAccounts){
            string recType = rectypeMap.get(newAccount.RecordTypeId).getName();            
            if (recType == Constants.ACCOUNT_RECORD_TYPE_ENTITY && newAccount.School__c ==true && newAccount.BillingCountry !=null){                
                objectId = newAccount.Id; 
                objectIds.add(objectId);                 
            }
        }

        if(objectIds.size()>0){
            WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectIds, operationtype );
        } 
        if ((!oldEntityTypeSchool) && (!string.isBlank(objectId))){
            raiseAdditionalWDOMSPlatformEvents(objectId);
        }  
    } 
    
    public static void beforeInsertHelper(List<Account> newAccounts){
        Map<ID, Schema.RecordTypeInfo> rectypeMap = Schema.SObjectType.Account.getRecordTypeInfosById();
        //query the custom setting and get the entity id value stored
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        CurrentEntityIDSequence__c settingsValue = CurrentEntityIDSequence__c.getOrgDefaults();
        CurrentEntityIDSequence__c settingsInstance = new CurrentEntityIDSequence__c();
        String newSequence; 
        for(Account newAccount : newAccounts){
            String recType = rectypeMap.get(newAccount.RecordTypeId).getName();
            if(recType == 'Entity' && newAccount.Entity_ID__c == null){
                String entityId = String.valueOf(curEntitySetting.get('Entity_ID__c'));
                //build the entity id in the format ENT-0000001                
                String tempValue = 'ENT-'+entityId;
                //set teh value for Entity id
                newAccount.Entity_ID__c = tempValue;
                if(entityId!=null){
                    Integer newValue = Integer.valueOf(entityId.trim())+1;
                    newSequence = (String.valueOf(newValue)).leftpad(7,'0');
                    //update the custom setting with increase by 1
                    curEntitySetting.Entity_ID__c = newSequence;                    
                }
            }            
        }
        if( !String.isBlank(newSequence) && Schema.sObjectType.CurrentEntityIDSequence__c.fields.Entity_ID__c.isUpdateable()){
            update curEntitySetting;
        }
    }
    
    public static void beforeUpdateHelper(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        insertWDOMSId(newAccounts);  
    }
    
    public static void insertWDOMSId(List<Account> newAccounts){
        Integer accId; 
        Map<ID, Schema.RecordTypeInfo> rectypeMap = Schema.SObjectType.Account.getRecordTypeInfosById();
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults(); 
        Map<Id, WDOMS_ID_Sequence__c> wdomsIdSeqMap = new Map<Id, WDOMS_ID_Sequence__c>();
        Integer tempWdomsIdSeq = Integer.valueOf(wdomsIdSeq.School_ID__c); 
        for(Account newAcc : newAccounts){
            if (string.isBlank(newAcc.WDOMS_ID__c)){
                string recType = rectypeMap.get(newAcc.RecordTypeId).getName(); 
                if (recType == Constants.ACCOUNT_RECORD_TYPE_ENTITY && newAcc.School__c ==true && newAcc.BillingCountry !=null){      
                    if(wdomsIdSeq.School_ID__c!=null){
                        Integer accWdomsId =tempWdomsIdSeq + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                        newAcc.WDOMS_ID__c = String.valueOf(accWdomsId); 
                        wdomsIdSeq.School_ID__c = accWdomsId;
                        wdomsIdSeqMap.put(wdomsIdSeq.Id, wdomsIdSeq);
                        tempWdomsIdSeq = tempWdomsIdSeq+1;
                    }
                }
            }
        }
        if(!wdomsIdSeqMap.isEmpty()){
            update wdomsIdSeqMap.values();
        }
    }
    
    public static void raiseAdditionalWDOMSPlatformEvents(Id accId){
        WDOMSResponseService.logMessage('Additional Platform event is required for Account '+accId);
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH;
        String objectType=''; 
        List<Account_Language__c> accLanguages = WDOMSService.getAccountLanguageByAccountId(accId);
        List<aka_Names__c> akas = WDOMSService.getAKAIdByAccountId(accId); 
        List<Additional_Info__c> addInfos = WDOMSService.getAdditionalInfoByAccountId(accId); 
        List<Account_Affiliation__c> accAffiliations = WDOMSService.getAccountAffiliationAccountId(accId); 
        List<Id> accLanguageIds = new List<Id>(); 
        List<Id> akaIds = new List<Id>();
        List<Id> additinalInfoIds =  new List<Id>();
        String accAffiliationObjectType='';
        List<Id> accAffiliationIds =  new List<Id>();
        
        //Raise PE for Account Language        
        for (Account_Language__c accLanguage : accLanguages){                        
            accLanguageIds.add(accLanguage.Id); 
        }
        
        //Raise PE for AKA
        for (aka_Names__c aka : akas){                   
            akaIds.add(aka.Id); 
        }
        
        //Raise PE for additional Info        
        for (Additional_Info__c addInfo : addInfos){
            if (addInfo.Contact__c !=null){
                objectType = Constants.WDOMS_OBJ_SCHOOL_CONT_CONT_INFO;
            }else{
                if (addInfo.Type__c == Constants.ADDITIONAL_INFO_TYPE_URL && addInfo.Language__c != null){
                    objectType = Constants.WDOMS_OBJ_SCHOOL_URL;
                }else{
                    if (addInfo.Type__c != Constants.ADDITIONAL_INFO_TYPE_URL ){
                        objectType = Constants.WDOMS_OBJ_SCHOOL_CONTACT_INFO;
                    }
                }
            }
            if (!String.isBlank(objectType)){                            
                additinalInfoIds.add(addInfo.Id);
            }
        }

        If (accLanguageIds.size() >0 ){
            WDOMSResponseService.raiseplatformEventforWDOMS(Constants.WDOMS_OBJ_SCHOOL_LANGUAGE, accLanguageIds, operationtype );
        }
        if(akaIds.size()>0){
            WDOMSResponseService.raiseplatformEventforWDOMS(Constants.WDOMS_OBJ_SCHOOL_AKA, akaIds, operationtype );
        }
        if  (additinalInfoIds.size()> 0 ){
            WDOMSResponseService.raiseplatformEventforWDOMS(objectType,additinalInfoIds, operationtype );
        }
        //Raise PE for Acccount Affiliation         
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosById();  
        for(Account_Affiliation__c accAff : accAffiliations){
            string recType = rtMap.get(accAff.RecordTypeId).getName();            
            if (accAff.Account1__c !=null && accAff.Program__c !=null && recType == Constants.ACCOUNT_AFFILIATION_TYPE_EDUCATIONAL_PROGRAM){
                 objectType = Constants.WDOMS_OBJ_SCHOOL_PROGRAM;                                                            
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType, accAff.Id, operationtype );  
            }else if (accAff.Account1__c !=null && accAff.Account2__c !=null && recType == Constants.ACCOUNT_AFFILIATION_TYPE_ACADEMIC_AFFILIATION){  
                 objectType = Constants.WDOMS_OBJ_SCHOOL_AFFILIATION;                             
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType, accAff.Id, operationtype );                  
            }
        } 
    }
}