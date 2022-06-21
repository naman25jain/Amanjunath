public with sharing class DuplicateCertificateTriggerHandler implements CaseTriggerHandlerInterface{
    public void beforeInsert(List<Case> newCases){
        for(Case newCase:newCases){
            // Updates Case Service
            CaseTriggerUtility.updateCaseService(newCase,Constant_Case__mdt.getInstance('REC_TYPE_DUPLICATE_CERTIFICATE').Value__c);
            // Updates the Applicant_Last_Submission_Date__c field
            CaseTriggerUtility.updateCaseRecordDate(newCase);
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            // Updates External Status
            CaseTriggerUtility.updateCaseExtStatus(newCase,null);
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        for(Case newCase:newCasesMap.values()){
            // Obtains oldcase
            Case oldCase = oldCasesMap.get(newCase.Id);
            // Checks if internal status is changed
            Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
            if(isInternalStatChanged){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
            }
        }
        
    }
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Getiing the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains the doc config Id for Duplicate Ceritificate
            String docConfigId = Constant_PDF_Butler__mdt.getInstance('DUPLICATE_CERTIFICATE').Value__c;
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template ECFMG Duplicate Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE').Value__c);
            // populates Doc Config
            Map<String, cadmus_core__Doc_Config__c> populateDocConfig = CaseTriggerUtility.populateDocConfig();
            for(Case newCase:newCasesMap.values()){
                // Obtains oldcase
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                // Checks if internal status is sent and changed to send email
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_SENT').Value__c){
                    ctDataWrap.sendEmail.add(CaseTriggerHelper.prepareEmail(newCase,addr,emailTempRec));
                }
                // Generates Document using PDF Butler
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c){
                    CaseTriggerUtility.generateDocHelper(populateDocConfig.get(docConfigId).Id,newCase);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
        
    }
}