public class EpicVerReportReqTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_EPIC_VER_REPORT_REQUEST  = Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c;
    public void beforeInsert(List<Case> newCases){
        try{
            System.debug('-------EPIC Before Insert Handler-------');
            for(Case caseIns:newCases){
                // Updates the Service
                CaseTriggerUtility.updateCaseService(caseIns,REC_TYPE_EPIC_VER_REPORT_REQUEST);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                // Updates External Status field for case record
                CaseTriggerUtility.updateCaseExtStatus(caseIns, new Case());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            System.debug('-------EPIC Before Update Handler-------');
            for(Case caseIns: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(caseIns.Id);
                if(caseIns.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                    // Updates External Status field for case record
                    CaseTriggerUtility.updateCaseExtStatus(caseIns, oldCase);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            System.debug('-------EPIC After Insert Handler-------');
            Id docConfigId;
            // Stores the records to be updated
            Map<Id,sObject> updRecMap = new Map<Id,sObject>();
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
            Map<String,sObject> epicCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CASE_EPIC_VER_REPORT').Value__c);
            if(!epicCaseMap.isEmpty()){
                for(Case caseRec: newCasesMap.values()){
                    if(String.isNotBlank(caseRec.Secondary_Parent_Case__c) && epicCaseMap.containsKey(caseRec.Secondary_Parent_Case__c)){
                        Case parentCaseIns = (Case)epicCaseMap.get(caseRec.Secondary_Parent_Case__c);
                        if(parentCaseIns.Do_Not_Know_Orgs_to_send_EPIC_Reports__c){
                            updRecMap.put(parentCaseIns.Id,new Case(Id = parentCaseIns.Id,Do_Not_Know_Orgs_to_send_EPIC_Reports__c = false));
                        }
                        if(parentCaseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c
                        && parentCaseIns.Service__c == Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c){
                            docConfigId = docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('EPIC_VER_REPORT_REQUEST').Value__c).Id;
                        }
                    }
                    if(String.isNotBlank(docConfigId)){
                        CaseTriggerUtility.generateDocHelper(docConfigId, caseRec);
                    }
                    if(!updRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                        CaseTriggerUtility.updateDMLMap(updRecMap.values());
                    }
                    if(caseRec.Entity__c != null){
                        CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{caseRec.Entity__c=>new Set<Id>{caseRec.Id}}, new Map<Id,Set<Id>>(),Constant_other__mdt.getInstance('SERVICE_NAME_VOLUME_REPORT_RECIPIENTS').Value__c);
                    }                    	
                    if(caseRec.Issuing_Entity__c != null){	
                        CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{caseRec.Issuing_Entity__c=>new Set<Id>{caseRec.Id}}, new Map<Id,Set<Id>>(), Constant_other__mdt.getInstance('SERVICE_NAME_CREDENTIAL_VERIFICATION').Value__c);
                    }
                }    
            }
                    
        }catch(Exception ex){
            throw ex;
        }
    }    
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            System.debug('-------EPIC After Update Handler-------');
            for(Case caseIns: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(caseIns.Id);
                if(caseIns.Entity__c != oldCase.Entity__c){
                   CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{caseIns.Entity__c=>new Set<Id>{caseIns.Id}}, new Map<Id,Set<Id>>{oldCase.Entity__c=>new Set<Id>{caseIns.Id}}, Constant_other__mdt.getInstance('SERVICE_NAME_VOLUME_REPORT_RECIPIENTS').Value__c);
                }
                if(caseIns.OwnerId != oldCase.OwnerId){
                    CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{caseIns.Issuing_Entity__c=>new Set<Id>{caseIns.Id}}, new Map<Id,Set<Id>>(), Constant_other__mdt.getInstance('SERVICE_NAME_VOLUME_REPORT_RECIPIENTS').Value__c);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}