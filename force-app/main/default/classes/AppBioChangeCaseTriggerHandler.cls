// Handler class for Applicant Biographic Change
public with sharing class AppBioChangeCaseTriggerHandler implements CaseTriggerHandlerInterface {
    final String REC_TYPE_APP_BIO_CHANGE  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPLICANT_BIOGRAPHIC_CHANGE').Value__c;
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates Case Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_APP_BIO_CHANGE);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Before Update
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates External Status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // After insert
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            // Stores the list of case records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            // gets the APP 360 URL
            String app360url = CaseTriggerUtility.getNetworkApp360();
            for(Case newCase: newCasesMap.values()){
                if(String.isBlank(newCase.ECFMG_Portal_Case_Url__c)){
                    newCase.ECFMG_Portal_Case_Url__c = app360url;
                    CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = newCase.Id,ECFMG_Portal_Case_Url__c = app360url));
                }
                notaryTransactionPublishEvent(newCase);
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
        }
        catch(Exception ex){
            throw ex;
        } 
    }
    // After update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
            Id docConfigId = docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c).Id;
            for(Case newCase: newCasesMap.values()){
                // Gets the old case.                
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_APPLICANT_ACTION_NOTARIZE').Value__c){
                    if(String.isNotBlank(docConfigId)){
                        CaseTriggerUtility.generateDocHelper(docConfigId,newCase);
                    }
                }
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c){
                    notaryTransactionPublishEvent(newCase);
                }          
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Publishes Event NotaryTransactionRequestEventHandler
    void notaryTransactionPublishEvent(Case newCase){
        if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ONLINE_NOTARY_SESSION_REINITIATED').Value__c){
            NotaryTransactionRequestEventHandler.publishEvent(newCase.Id);
        }
    }
}