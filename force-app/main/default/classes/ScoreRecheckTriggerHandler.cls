// Handler class for Score Recheck
public with sharing class ScoreRecheckTriggerHandler implements CaseTriggerHandlerInterface{
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
        for(Case newCase: newCases){                             
                // Updates the Service
                CaseTriggerUtility.updateCaseService(newCase,Constant_Case__mdt.getInstance('REC_TYPE_SCORE_RECHECK').Value__c);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
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
           // Getiing the instance of CaseTriggerDataInitialize                   
            for(Case newCase: newCasesMap.values()){
                // Gets the old case.                
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c &&
                 newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_RECEIVED').Value__c &&
                  newCase.Case_Outcome__c == Constant_Case__mdt.getInstance('CASE_OUTCOME_NO_CHANGE_IN_SCORE_RESULT').Value__c && newCase.Case_Outcome__c != oldCase.Case_Outcome__c){                    
                    // Update Case status
                    newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c;
                    newCase.External_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c;
                }
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // After insert
    public void afterInsert(Map<Id,Case> newCasesMap){}
    // After update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){ 
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
        cadmus_core__Doc_Config__c docConfig = docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('Score_Recheck').Value__c);      
        for(Case newCase: newCasesMap.values()){
            // Gets the old case.         
            Case oldCase = oldCasesMap.get(newCase.Id);
            if(newCase.Internal_Status__c != oldCase.Internal_Status__c 
                && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c &&
                newCase.Case_Outcome__c == Constant_Case__mdt.getInstance('CASE_OUTCOME_NO_CHANGE_IN_SCORE_RESULT').Value__c
                && String.isNotBlank(docConfig.Id)){                                                                                                 
                    CaseTriggerUtility.generateDocHelper(docConfig.Id,newCase);                                               
            }           
        }
    }
}