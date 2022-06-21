//handler for the record type Medical Education Form
public with sharing class MedEduFormCaseTriggerHandler implements CaseTriggerHandlerInterface{
    //Record Types
    static final String CASE_RECORD_TYPE_MED_EDU_FORM  = Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c;
    static final String AFFIRMATION_RECORD_TYPE_MED_EDU_FORM  = Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_FORM').Value__c;
    static final String SERVICE_NAME_MEDICAL_EDU_FORM  = Constant_other__mdt.getInstance('SERVICE_NAME_MEDICAL_EDU_FORM').Value__c;
    //before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){                
                String serviceRecName = newCase.Service__c + '_' + CASE_RECORD_TYPE_MED_EDU_FORM;
                CaseTriggerUtility.updateCaseService(newCase,serviceRecName);   
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates external status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //before update
    public void beforeUpdate(Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap){
        Set<String> verPendingStatus = new Set<String>{Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c, Constant_Case__mdt.getInstance('STATUS_INCOMPLETE_RESENT_FOR_VERIFICATIO').Value__c, Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c};
        Set<String> verCompleteStatus = new Set<String>{Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c, Constant_Case__mdt.getInstance('STATUS_CV_REJECTED').Value__c, Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c, Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_APPLICANT').Value__c, 
                                                        Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_ECFMG').Value__c, Constant_Case__mdt.getInstance('STATUS_UNABLE_TO_VERIFY_CRED').Value__c, Constant_Case__mdt.getInstance('STATUS_PREV_VERIFIED_ACCEPTED').Value__c, Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c};        
        try{
            //Updates the owner of the case based on the Internal Status
            for(Case newCase: newCasesMap.values()){
                // Obtains oldcase
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                if(isInternalStatChanged){
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_VER_REVIEW && newCase.Service__c == Constants.CASE_SERVICE_ECFMG_CERT){
                        newCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MED_EDU_FORM').Value__c);
                    }
                    if(verPendingStatus.contains(newCase.Internal_Status__c)){
                        newCase.ownerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VERIFICATION_PENDING').Value__c);
                    }else if(verCompleteStatus.contains(newCase.Internal_Status__c)){
                        newCase.ownerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VER_PROCESS_COMPLETE').Value__c);
                    } 
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates external status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //after insert
    public void afterInsert(Map<Id,Case> newCasesMap){
        //Map of Account Ids and Case Ids
        Map<Id,Set<Id>> accCaseMap = new Map<Id,Set<Id>>();
        // Map of Id and sObject to store the records to be updated
        Map<Id,sObject> recordsToUpdate = new Map<Id,sObject>();           
        try{
            for(Case newCase: newCasesMap.values()){
                // populates Account Id and Case Ids to be used for Case sharing
                if(!String.isBlank(newCase.Entity__c)){
                    accCaseMap.putAll(populateAccCaseMap(accCaseMap,newCase.Entity__c, newCase.Id));
                }
                if(!accCaseMap.isEmpty()){
                    CaseTriggerUtility.collectCaseShareAcc(accCaseMap,new Map<Id,Set<Id>>(),SERVICE_NAME_MEDICAL_EDU_FORM);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }    
    //after update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,sObject> parentChildRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            // Stores the list of case records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            //Map of Account Id and Case Ids
            Map<Id,Set<Id>> accCaseIdMap = new Map<Id,Set<Id>>();
            //Map<Id,set<Id>> newAccCaseMap = new Map<Id,set<Id>>();
            Map<Id,set<Id>> oldAccCaseIdMap = new Map<Id,set<Id>>();
            Set<Id> accountIdSet = new Set<Id>();                     
            // collects Medical Education Form caseIds from the Affirmations
            Set<Id> medEduFormCaseId = new Set<Id>();
            // Map of Id and sObject to store the records to be updated
            Map<Id,sObject> recordsToUpdate = new Map<Id,sObject>();                        
            // Fetches the affirmations related to Med Edu Form Cases
            Map<String,List<Affirmation__c>> medEduFormAffirmationsMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CASE_AFFIRMATION').Value__c);                        
            // loop over Affirmations to collect the case Id
            if(!medEduFormAffirmationsMap.isEmpty()){
                for(String caseId : medEduFormAffirmationsMap.keyset()){
                    for(Affirmation__c affirmationRecord : medEduFormAffirmationsMap.get(caseId)){
                        if(affirmationRecord.RecordType.DeveloperName == AFFIRMATION_RECORD_TYPE_MED_EDU_FORM && affirmationRecord.Verify_with_Alternate_Entity__c == true){
                            medEduFormCaseId.add(affirmationRecord.Case__c);
                        }
                    }
                }
            }
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id); 
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                //checks if affirmation is present and Alternate Entity is changed
                if(medEduFormCaseId.contains(newCase.Id) && newCase.Alternate_Entity__c != oldCase.Alternate_Entity__c){
                    //process for insert and delete
                    accCaseIdMap.putAll(populateAccCaseMap(accCaseIdMap,newCase.Alternate_Entity__c,newCase.Id));
                    accountIdSet.add(newCase.Alternate_Entity__c);
                    oldAccCaseIdMap.putAll(populateAccCaseMap(oldAccCaseIdMap,oldCase.Alternate_Entity__c,oldCase.Id));
                }
                //checks if affirmation is not present and Entity is changed
                else if(!medEduFormCaseId.contains(newCase.Id) && newCase.Entity__c != oldCase.Entity__c){
                    //process for insert and delete
                    accCaseIdMap.putAll(populateAccCaseMap(accCaseIdMap,newCase.Entity__c,newCase.Id));
                    accountIdSet.add(newCase.Entity__c);
                    oldAccCaseIdMap.putAll(populateAccCaseMap(oldAccCaseIdMap,oldCase.Entity__c,oldCase.Id));
                } 
                if(isInternalStatChanged && String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId)){
                    Case parentRec = (Case)parentChildRecMap.get(newCase.ParentId);
                    Boolean isFCVS = parentRec.RecordType.DeveloperName == Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c;
                    if(isFCVS){
                        CaseTriggerUtility.updChildCaseFCVS(newCase,parentRec,updateCaseRecMap);
                    }
                }
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
            if(!accCaseIdMap.isEmpty()){
                CaseTriggerUtility.collectCaseShareAcc(accCaseIdMap,new Map<Id,Set<Id>>(oldAccCaseIdMap),SERVICE_NAME_MEDICAL_EDU_FORM);
            }                 
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Populates Account, Case Map
    public static map<Id,set<Id>> populateAccCaseMap(map<Id,set<Id>> accCaseMap,Id entityId,Id caseId){
        if(accCaseMap.containsKey(entityId)){
            accCaseMap.get(entityId).add(caseId);
        }else{
            accCaseMap.put(entityId,new set<Id>{caseId});
        }
        return accCaseMap;
    }    
}