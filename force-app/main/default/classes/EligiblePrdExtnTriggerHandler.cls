public with sharing class EligiblePrdExtnTriggerHandler implements CaseTriggerHandlerInterface {
    //Map to holds contact records from generic methods
    Map<String,sObject> conMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
    //Map of exam reg case id, exam reg case with child epex cases
    Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
    //Map of exam reg case id, exam reg case with child exam reg records
    List<Case> epexCasesList = new List<Case>();
    public void beforeInsert(List<Case> newCases){
        try{
            System.debug('-------EPExtn Before Insert Handler-------');
            for(Case caseIns:newCases){
                // Updates the Service
                CaseTriggerUtility.updateCaseService(caseIns,Constant_Case__mdt.getInstance('REC_TYPE_ELIGIBILITY_PERIOD').Value__c);
                 // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                // Updates External Status field for case record
                CaseTriggerUtility.updateCaseExtStatus(caseIns, new Case());
                if(String.isNotBlank(caseIns.ContactId) && conMap.containsKey(caseIns.ContactId) && caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c){
                    Contact con = (Contact)conMap.get(caseIns.ContactId);
                    updatePendingCIBISCase(con.School_Enrollment_Status__c, caseIns);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            System.debug('-------EPExtn Before Update Handler-------');            
            List<Case> epexCasesRemoveEV = new List<Case>();
            for(Case caseIns: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(caseIns.Id);
                if(caseIns.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                    // Updates External Status field for case record
                    CaseTriggerUtility.updateCaseExtStatus(caseIns, oldCase);
                }
                if(String.isNotBlank(caseIns.ContactId) && conMap.containsKey(caseIns.ContactId) && caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c){
                    Contact con = (Contact)conMap.get(caseIns.ContactId);
                    updatePendingCIBISCase(con.School_Enrollment_Status__c, caseIns);
                }                
                if(caseIns.Internal_Status__c != oldCase.Internal_Status__c && (caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c || caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c)){
                    epexCasesRemoveEV.add(caseIns);
                }
            }                                
            if(!epexCasesRemoveEV.isEmpty()){
                removeEPEXFromEV(epexCasesRemoveEV);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            List<Case> newCibisCases = new List<Case>();                
            for(Case newCase : newCasesMap.values()){
                epexCasesList.add(newCase);
                if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c){
                    newCibisCases.add(newCase);
                }
            }
            // invoke Cibis platform event publish logic
            if(RecursiveTriggerHandler.isFirstTimeCibis && !newCibisCases.isEmpty()){
                RecursiveTriggerHandler.isFirstTimeCibis = false; 
                CibisUtility.invokeCibisPlatformEventLogic(newCibisCases, null); //Just pass values into this class
            }
            if(!epexCasesList.isEmpty() && !parentCaseMap.isEmpty()){
                sharingRuleOnEpexCase(epexCasesList, parentCaseMap);
            }  
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{            
            Set<Id> examRegCaseIds = new Set<Id>();
            // Stores the list of Asset records to be inserted.
            List<Asset> assetRecIns = new List<Asset>();
            // Stores the list of Asset records that has to be updated.
            List<Asset> assetRecUpd = new List<Asset>();
            // Getiing the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Fetches the stored SOQL for Contact
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Fetches the static resource email permit for attaching file.
            Map<String,sObject> staticResourceMap = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('STATICRESOURCE').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template ECFMG Duplicate Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE').Value__c);
            // Obtains the Static resource record.
            StaticResource staticResRec = (StaticResource)staticResourceMap.get(Constant_other__mdt.getInstance('STATIC_RESOURCE_EXAM_PERMIT').Value__c);
            // Fetches the Asset records
            Map<String,List<sObject>> assetMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c);
            Boolean isEvParenCaseChanged = false;
            Boolean isOwnerChanged = false;
            if(RecursiveTriggerHandler.isFirstTimeCibis){
                // Invoke CIBIS platform event publish method from utility
                CibisUtility.invokeCibisPlatformEventLogic(newCasesMap.values(),oldCasesMap);
            }
            for(Case newCase : newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                Boolean isIntStatusChanged = (newCase.Internal_Status__c != oldCase.Internal_Status__c);
                if(isIntStatusChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c){ 
                    examRegCaseIds.add(newCase.ParentId);
                    epexCasesList.add(newCase);
                }
                if(newCase.Enrollment_Verification_Parent__c != oldCase.Enrollment_Verification_Parent__c){
                    isEvParenCaseChanged = true; 
                }
                if(newCase.OwnerId != oldCase.OwnerId){
                    isOwnerChanged = true; 
                }
                if(isIntStatusChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c){
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    CaseTriggerUtility.attachFiletoEmail(message,(staticResRec).Body,Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c);
                    ctDataWrap.sendEmail.add(message);                   
                    if(assetMap.containsKey(newCase.Id)){
                        assetRecUpd.addAll(CaseTriggerUtility.updateAsset(assetMap.get(newCase.Id)));
                    }
                    assetRecIns.add(CaseTriggerUtility.createAsset(newCase,newCase.Id,Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c));
                }
            }
            if(!examRegCaseIds.isEmpty()){
                updateSLADate(epexCasesList, examRegCaseIds);
            }
            if(!assetRecIns.isEmpty() && GenericUtilities.checkIsCreatable('Asset')){
                CaseTriggerUtility.insertDML(assetRecIns);
            }
            if(!assetRecUpd.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.updateDMLMap(assetRecUpd);
            }
            if(!newCasesMap.isEmpty() && !parentCaseMap.isEmpty() && (isEvParenCaseChanged || isOwnerChanged)){
                sharingRuleOnEpexCase(newCasesMap.values(), parentCaseMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void updatePendingCIBISCase(String enrolStatus, Case caseRec){
        try{
            if(string.isNotBlank(enrolStatus)){
                if(enrolStatus == Constant_Contact__mdt.getInstance('SCHOOL_ENROL_STATUS_STUDENT').Value__c){
                    caseRec.External_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFIED').Value__c; 
                }
                else if(enrolStatus == Constant_Contact__mdt.getInstance('SCHOOL_ENROL_STATUS_GRADUATE').Value__c){
                    caseRec.External_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c; 
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    void updateSLADate(List<Case> epexCasesList, Set<Id> examRegCaseIds){
        try{            
            Map<String,SObject> childExamRegMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c);
            // Stores the list of case records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            // Stores the list of exam reg records to be updated
            Map<Id,Exam_Registration__c> updateExamRegRecMap = new Map<Id,Exam_Registration__c>();
            for(Case epexCase :epexCasesList){
                //Exam reg case with child epex cases
                Case parentCase = (Case)parentCaseMap.get(epexCase.parentId);
                //Exam reg case with child exam reg records
                Case parentExamCase = (Case)childExamRegMap.get(epexCase.parentId);
                if(!parentCase.Cases.isEmpty() && !parentExamCase.Exam_Registrations__r.isEmpty() && parentCase.Enrollment_Verification_Parent__c != null){
                    Exam_Registration__c examReg = CaseTriggerUtility.calculateSLADate(parentCase, parentExamCase.Exam_Registrations__r[0]);
                    Integer day = examReg.SLA_Date__c.day();
                    Integer month = examReg.SLA_Date__c.month();
                    Integer year = examReg.SLA_Date__c.year();
                    CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = parentCase.Cases[0].Id,SLA_Date__c = DateTime.newInstance(year, month, day, 23, 00, 00)));
                    CaseTriggerUtility.updateRec(updateExamRegRecMap, new Exam_Registration__c(Id = examReg.Id, SLA_Date__c = examReg.SLA_Date__c));
                }
            }
            if(!updateExamRegRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Exam_Registration__c')){
                CaseTriggerUtility.updateDMLMap(updateExamRegRecMap.values());
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    void removeEPEXFromEV(List<Case> epexCasesRemoveEV){
        try{
            //Map of exam reg case id, exam reg case with child epex cases
            Map<String,SObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            // Stores the list of case records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            for(Case epexCase :epexCasesRemoveEV){
                //Exam reg case with child epex cases
                Case parentCase = (Case)parentCaseMap.get(epexCase.parentId);
                if(parentCase.Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c){
                    epexCase.Is_Removed_From_EV__c = TRUE;
                }
            } 
        }catch(Exception ex){
            throw ex;
        }
    }   
    public void sharingRuleOnEpexCase(List<Case> epexCaseList, Map<String, SObject> parentCaseMap){
        try{
            //Collects the EPEX Case id, Parent Exam Reg Case Id, EV CaseId 
            Set<Id> caseIdsToShareSet = new Set<Id>();
            //Map collectes the AccountId from EV Case and set of caseIds
            Map<Id, Set<Id>> accCaseIdMap = new Map<Id, Set<Id>>();
            for(Case epexCase :epexCaseList){
                //Exam reg case with child epex cases
                Case parentCase = (Case)parentCaseMap.get(epexCase.parentId);
                caseIdsToShareSet.add(epexCase.Id);
                caseIdsToShareSet.add(epexCase.ParentId);
                if(String.isNotBlank(epexCase.Enrollment_Verification_Parent__c)){
                    caseIdsToShareSet.add(epexCase.Enrollment_Verification_Parent__c);
                }
                if(accCaseIdMap.containsKey(parentCase.Enrollment_Verification_Parent__r.AccountId)){
                    accCaseIdMap.get(parentCase.Enrollment_Verification_Parent__r.AccountId).addAll(caseIdsToShareSet);
                }else{
                    accCaseIdMap.put(parentCase.Enrollment_Verification_Parent__r.AccountId, caseIdsToShareSet);
                }
            }
            if(!accCaseIdMap.isEmpty()){
                CaseTriggerUtility.collectCaseShareAcc(accCaseIdMap,new Map<Id,Set<Id>>(),Constant_other__mdt.getInstance('SERVICE_NAME_ENROLLMENT_VERIFICATION').Value__c);
            }
        }
        catch(Exception ex){
            throw ex;
        }        
    }
}