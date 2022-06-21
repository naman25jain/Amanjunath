public with sharing class EnrollmentReVerCaseTriggerHandler implements CaseTriggerHandlerInterface{
    public void beforeInsert(List<Case> newCases){
        try{
            system.debug('-------Enrollment Reverification Before Insert Handler-------');
            for(Case newCase : newCases){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                // Updates resend SLA date
                updateResendSLADate(newCase);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------Enrollment Reverification Before Update Handler-------');
            for(Case newCase : newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                if(isInternalStatChanged){
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates External Status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                    // Updates resend SLA date
                    updateResendSLADate(newCase);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            system.debug('-------Enrollment Reverification After Insert Handler-------');
            // populates Doc Config
            Map<String, cadmus_core__Doc_Config__c> populateDocConfig = CaseTriggerUtility.populateDocConfig();
            // Obtains the doc config Id for Def cover letter
            String defCovLetDocConfigId = Constant_PDF_Butler__mdt.getInstance('ERV_DEF_COV_LETTER').Value__c;
            // Obtains the doc config Id for Customer
            String customerDocConfigId = Constant_PDF_Butler__mdt.getInstance('ERV_CUSTOMER').Value__c;
            for(Case newCase : newCasesMap.values()){
                if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c){
                    CaseTriggerUtility.generateDocHelper(populateDocConfig.get(customerDocConfigId).Id,newCase);
                }else if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c){
                    CaseTriggerUtility.generateDocHelper(populateDocConfig.get(defCovLetDocConfigId).Id,newCase);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------Enrollment Reverification After Update Handler-------');
            List<Case> ervCaseListToUpdate = new List<Case>();
            Id queEnrolReVerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MR_ENROLLMENT_REVERIFICATION').Value__c);
            // populates Doc Config
            Map<String, cadmus_core__Doc_Config__c> populateDocConfig = CaseTriggerUtility.populateDocConfig();
            // Obtains the doc config Id for Def cover letter
            String defCovLetDocConfigId = Constant_PDF_Butler__mdt.getInstance('ERV_DEF_COV_LETTER').Value__c;
            for(Case newCase : newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c){
                    CaseTriggerUtility.generateDocHelper(populateDocConfig.get(defCovLetDocConfigId).Id,newCase);
                }
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c){
                        newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
                        newCase.OwnerId = queEnrolReVerId;
                        ervCaseListToUpdate.add(newCase);
                }
                if(!ervCaseListToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                    CaseTriggerUtility.updateDMLMap(ervCaseListToUpdate);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // updates resend SLA date
    void updateResendSLADate(Case newCase){
        try{
            if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_SENT').Value__c || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_RESENT').Value__c){
                newCase.Resend_SLA_Date__c = Date.today().addDays(90);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}