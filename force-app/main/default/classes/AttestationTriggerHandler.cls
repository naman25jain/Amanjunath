public with sharing class AttestationTriggerHandler implements CaseTriggerHandlerInterface{
    final String TYPE_ATTESTATION_CASE = Constant_Case__mdt.getInstance('TYPE_ATTESTATION_CASE').Value__c;
    public void beforeInsert(List<Case> newCases){
        try{
            system.debug('-------Attestation Before Insert Handler-------');
            // Stores the contact Id and the corresponding list of cases.
            Map<String,List<Case>> conCaseMap = (Map<String,List<Case>>)CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CONTACT_CASE').Value__c);
            // Stores the contact Id and the corresponding list of CAT records.
            Map<String,List<Contact_Association_Type__c>> conCATMap = (Map<String,List<Contact_Association_Type__c>>)CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CAT_CONTACT').Value__c);
            // Stores the parent records.
            Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            for(Case newCase : newCases){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
                if(String.isNotBlank(newCase.ContactId) && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NEW').Value__c 
                && newCase.Case_Type__c == TYPE_ATTESTATION_CASE && conCaseMap.containsKey(newCase.ContactId)
                && checkAppForCertCase(conCaseMap.get(newCase.ContactId))){
                    newCase.addError(Error_Message__mdt.getInstance('No_Application_for_certificate_case').Error_Message__c);
                }
                if(newCase.Case_Type__c == TYPE_ATTESTATION_CASE){
                    newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
                    newCase.External_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
                    newCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_SPECIAL_INVESTIGATIONS').Value__c);
                    newCase.Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c;
                    newCase.Origin = 'Web';
                    if(String.isNotBlank(newCase.ContactId) && conCATMap.containsKey(newCase.ContactId)){
                        // fetches the account Id from CAT based on Contact Id and record type as Degree medical school
                        newCase.Entity__c = CaseTriggerUtility.getAccount(conCATMap.get(newCase.ContactId));
                    }
                }else if(newCase.Case_Type__c == Constant_Case__mdt.getInstance('TYPE_ATTESTATION_SUB_CASE').Value__c && String.isNotBlank(newCase.ParentId)){
                    newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_PROGRESS').Value__c;
                    newCase.External_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_PROGRESS').Value__c;
                    newCase.Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c;
                    newCase.Entity__c = (((Case)parentCaseMap.get(newCase.parentId))).Entity__c;
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------Attestation Before Update Handler-------');
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
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------Attestation After Update Handler-------');
            // Gets the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Stores the internal status to be checked for sending email
            Set<String> statusSet = new Set<String>{Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c,Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c,Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c};
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template ECFMG Duplicate Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ATTEST_CASE_STATUS_UPDATE').Value__c);
            // Obtains the contact records
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Stores the parent records.
            Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            // Contact record map to be updated.
            Map<Id,Contact> updContactMap = new Map<Id,Contact>();
            // Case record map to be updated.
            Map<Id,Case> updCaseMap = new Map<Id,Case>();
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Case_Type__c == TYPE_ATTESTATION_CASE && statusSet.contains(newCase.Internal_Status__c) && oldCase.Internal_Status__c != newCase.Internal_Status__c){
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    ctDataWrap.sendEmail.add(message);
                }
                if(newCase.Case_Type__c == TYPE_ATTESTATION_CASE && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c 
                && oldCase.Internal_Status__c != newCase.Internal_Status__c && contactMap.containsKey(newCase.contactId)){
                    Contact con = (Contact)contactMap.get(newCase.contactId);
                    if(!con.Attestation_Prerequisite_met__c){
                        con.Attestation_Prerequisite_met__c = true;
                        CaseTriggerUtility.updateRec(updContactMap,new Contact(Id = con.Id,Attestation_Prerequisite_met__c = true));
                    }
                }
                if(newCase.Case_Type__c == Constant_Case__mdt.getInstance('TYPE_ATTESTATION_SUB_CASE').Value__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE_RESENT_TO_APPLICANT').Value__c
                && newCase.Internal_Status__c != oldCase.Internal_Status__c && String.isNotBlank(newCase.parentId) && parentCaseMap.containsKey(newCase.parentId)){
                    Case parentCase = (Case)parentCaseMap.get(newCase.parentId);
                    if(parentCase.Internal_Status__c != newCase.Internal_Status__c){
                        parentCase.Internal_Status__c = newCase.Internal_Status__c;
                        CaseTriggerUtility.updateRec(updCaseMap,new Case(Id = parentCase.Id,Internal_Status__c = newCase.Internal_Status__c));
                    }
                }
            }
            if(!updContactMap.isEmpty() && GenericUtilities.checkIsUpdatable('Contact')){
                CaseTriggerUtility.updateDMLMap(updContactMap.values());
            }
            if(!updCaseMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updCaseMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // checks if app for cert case exists for the contact with internal status except accepted,rejected,cancelled,expired
    Boolean checkAppForCertCase(List<Case> conCases){
        try{
            Set<string> intStatus = new Set<String>{Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c,Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c,Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c,Constant_Case__mdt.getInstance('STATUS_EXPIRED').Value__c};
            Boolean caseExist = false;
            for(Case conCase : conCases){
                if(conCase.RecordType.DeveloperName == Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c && intStatus.contains(conCase.Internal_Status__c)){
                    caseExist = true;
                    break;
                }
            }
            return caseExist;
        }catch(Exception ex){
            throw ex;
        }
    }
}