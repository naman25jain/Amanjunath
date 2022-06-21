public with sharing class AdditionalInfoTriggerHelper {
    
    public static void afterInsertHelper(List<Additional_Info__c> newAddInfos){
        String objectType = ''; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_POST;  
        Id objectId;                 
        for(Additional_Info__c newInfo : newAddInfos){            
            if (newInfo.Account__c !=null){
                if (newInfo.Contact__c !=null){
                    objectType = Constants.WDOMS_OBJ_SCHOOL_CONT_CONT_INFO;
               }else{
                    if (newInfo.Type__c == Constants.ADDITIONAL_INFO_TYPE_URL && newInfo.Language__c != null){
                        objectType = Constants.WDOMS_OBJ_SCHOOL_URL;
                    }else{
                        if (newInfo.Type__c != Constants.ADDITIONAL_INFO_TYPE_URL ){
                            objectType = Constants.WDOMS_OBJ_SCHOOL_CONTACT_INFO;
                        }
                    }
               }
                if (!String.isBlank(objectType)){
                    objectId = newInfo.Id; 
                    WDOMSResponseService.raiseplatformEventforWDOMS(objectType,objectId, operationtype ); 
                }
            }            
        }        
    }  
    
    public static void afterUpdateHelper(List<Additional_Info__c> newAddInfos, Map<Id, Additional_Info__c> oldAddInfosMap){
        String objectType  =''; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH;  
        Id objectId;                 
        for(Additional_Info__c newInfo : newAddInfos){                       
            if (newInfo.Account__c !=null){
                if (newInfo.Contact__c !=null){
                     objectType = Constants.WDOMS_OBJ_SCHOOL_CONT_CONT_INFO;
                }else{                   
                    if (newInfo.Type__c == Constants.ADDITIONAL_INFO_TYPE_URL && newInfo.Language__c != null){
                        objectType = Constants.WDOMS_OBJ_SCHOOL_URL;
                    }else{
                        if (newInfo.Type__c != Constants.ADDITIONAL_INFO_TYPE_URL ){
                            objectType = Constants.WDOMS_OBJ_SCHOOL_CONTACT_INFO;
                        }
                    }
                }
                if (!String.isBlank(objectType)){
                    objectId = newInfo.Id; 
                    WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype ); 
                }
            }
        }   
    }

    public static void beforeInsertHelper(List<Additional_Info__c> newAddInfos){  
        insertWDOMSId(newAddInfos);
    }
    public static void beforeUpdateHelper(List<Additional_Info__c> newAddInfos,  Map<Id, Additional_Info__c> oldAddInfosMap){  
        insertWDOMSId(newAddInfos);
    }

    public static void insertWDOMSId(List<Additional_Info__c> newAddInfos){      
        List<WDOMS_ID_Sequence__c> wdomsIdSeqs = new List<WDOMS_ID_Sequence__c>();
        for(Additional_Info__c newInfo : newAddInfos){
            if (string.isBlank(newInfo.WDOMS_ID__c)){                 
                WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
                if (wdomsIdSeq.School_Url_ID__c != null){
                    Integer newInfoWDOMSID =Integer.valueOf(wdomsIdSeq.School_Url_ID__c) + Constants.WDOMS_SEQUENCE_INCREMENT_VALUE;  
                    newInfo.WDOMS_ID__c = String.valueOf(newInfoWDOMSID); 
                    wdomsIdSeq.School_Url_ID__c = newInfoWDOMSID;
                    wdomsIdSeqs.add(wdomsIdSeq); 
                }
            }
        }
        if (Schema.sObjectType.WDOMS_ID_Sequence__c.fields.School_Url_ID__c.isUpdateable() && wdomsIdSeqs.size()>0){
            update wdomsIdSeqs; 
        }
         
    }
}