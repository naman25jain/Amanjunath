//Process builder actions migrated to this class
public with sharing class CasePBActionsHandler{
    public CasePBActionsHandler(){}
    /*public static void beforeTriggerHandler(List<Case> newCases, Map<Id, Case> oldCasesMap){
        try{
            Group entSerQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENTITY_SERVICE_REQUESTS);
            Group entUpdQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENTITY_UPDATE_REQUESTS);
            Group notifiQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_NOTIFICATION);
            Group splInvQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_SPECIAL_INVESTIGATIONS_QUEUE);
            Group cvQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION_NAME);
            Group authSignQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_AUTH_SIGN_LIST);
            Group medEduResQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MED_EDU_RES);
            Id userId = UserInfo.getUserId();
            Set<Id> conIds = new Set<Id>();
            Set<Id> parentIds = new Set<Id>();
            for(Case newCase : newCases){
                conIds.add(newCase.ContactId);
                parentIds.add(newCase.ParentId);
            }
            Map<Id, Contact> caseContactMap = new Map<Id, Contact>([SELECT Id, School_Enrollment_Status__c FROM Contact WHERE Id IN :conIds]);
            Map<Id, Case> caseParentMap = new Map<Id, Case>([SELECT Id, AccountId, ContactId, Entity__c, Document_Type__c, Document_URL__c FROM Case WHERE Id IN :parentIds]);
            for(Case newCase : newCases){
                if(newCase.RecordTypeId == Constants.CVRECORDTYPEID && newCase.Send_Method__c != 'Email' && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && newCase.Send_Method__c != oldCasesMap.get(newCase.Id).Send_Method__c))){
                    newCase.List_of_emails__c = '';
                }else if(newCase.RecordTypeId == Constants.NEW_ENTITY_REQUEST_RDTYPEID && newCase.ParentId != null && (newCase.Internal_Status__c == Constants.CASE_STATUS_ADDED || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED)){
                    newCase.OwnerId = entSerQueue.Id;
                }else if(newCase.RecordTypeId == Constants.ENUSRREQRECORDTYPEID && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c))){
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_INCOMPLETE){
                        newCase.Action_Required__c = True;
                    }else{
                        newCase.Action_Required__c = False;
                    }
                }else if(newCase.RecordTypeId == Constants.SCORERECHECKRDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_RECEIVED && newCase.Case_Outcome__c == 'No Change in Score Result' && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && newCase.Case_Outcome__c != oldCasesMap.get(newCase.Id).Case_Outcome__c))){
                    newCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
                    newCase.External_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
                }else if(newCase.RecordTypeId == Constants.ERVCASERECORDTYPEID && (newCase.Internal_Status__c == Constants.CASE_STATUS_SENT || newCase.Internal_Status__c == Constants.CASE_STATUS_RESENT)){
                    newCase.Resend_SLA_Date__c = Date.today().addDays(90);
                }else if(newCase.OwnerId != userId && newCase.Internal_Status__c == Constants.CASE_STATUS_IN_REVIEW && (newCase.RecordTypeId == Constants.NOTIFICATION_RDTYPEID || newCase.RecordTypeId == Constants.ENTITY_SERVICE_REQUEST_RDTYPEID || newCase.RecordTypeId == Constants.NEW_ENTITY_REQUEST_RDTYPEID)){
                    newCase.OwnerId = userId;
                }else if(newCase.Internal_Status__c == Constants.CASE_STATUS_NEW || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_COMPLETED){
                    if(newCase.RecordTypeId == Constants.ENTITY_SERVICE_REQUEST_RDTYPEID && newCase.OwnerId != entSerQueue.Id && newCase.Type != 'Entity Details Change'){
                        newCase.OwnerId = entSerQueue.Id;
                    }else if(newCase.RecordTypeId == Constants.ENTITY_SERVICE_REQUEST_RDTYPEID && newCase.OwnerId != entUpdQueue.Id && newCase.Type == 'Entity Details Change'){
                        newCase.OwnerId = entUpdQueue.Id;
                    }else if(newCase.RecordTypeId == Constants.NOTIFICATION_RDTYPEID && newCase.OwnerId != notifiQueue.Id){
                        newCase.OwnerId = notifiQueue.Id;
                    }
                }else if(newCase.RecordTypeId == Constants.NEW_ENTITY_REQUEST_RDTYPEID && newCase.OwnerId != entSerQueue.Id && (newCase.Internal_Status__c == Constants.CASE_STATUS_NEW || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED || newCase.Internal_Status__c == Constants.CASE_STATUS_ADDED)){
                    newCase.OwnerId = entSerQueue.Id;
                }else if(newCase.RecordTypeId == Constants.EXAMREGRTID){
                    if(newCase.OwnerId != splInvQueue.Id && (newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL) && (newCase.Verification_Status__c == Constants.CASE_VERIFICATION_WITHDRAWN || newCase.Verification_Status__c == Constants.CASE_VERIFICATION_TRANSFERRED || newCase.Verification_Status__c == Constants.CASE_VERIFICATION_DISMISSED || newCase.Verification_Status__c == Constants.CASE_VERIFICATION_NEVER_ATT_NOT_STUDENT)){
                        newCase.OwnerId = splInvQueue.Id;
                    }else if(String.valueOf(newCase.OwnerId).startsWith('005')){
                        if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_REVIEW){
                            newCase.Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW;
                        }else if(newCase.Internal_Status__c == Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED){
                            newCase.Internal_Status__c = Constants.CASE_STATUS_MANUAL_REV_EV;
                        }
                    }else if(newCase.Internal_Status__c == Constants.CASE_STATUS_APPROVED && caseContactMap.containsKey(newCase.ContactId)){
                        if(caseContactMap.get(newCase.ContactId).School_Enrollment_Status__c == Constants.CONASCTYPESTG_STATUS_STUDENT){
                            newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
                        }else if(caseContactMap.get(newCase.ContactId).School_Enrollment_Status__c == Constants.CONASCTYPESTG_STATUS_GRADUATE){
                            newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
                        }
                    }
                }else if(newCase.RecordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID && String.valueOf(newCase.OwnerId).startsWith('005') && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && newCase.OwnerId != oldCasesMap.get(newCase.Id).OwnerId && String.valueOf(oldCasesMap.get(newCase.Id).OwnerId).startsWith('00G')))){
                    newCase.Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW;
                }if(newCase.RecordTypeId == Constants.ENTITY_SERVICE_REQUEST_RDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_NEW && newCase.ParentId != null && caseParentMap.containsKey(newCase.ParentId)){
                    newCase.ContactId = caseParentMap.get(newCase.ParentId).ContactId;
                    newCase.AccountId = caseParentMap.get(newCase.ParentId).AccountId;
                    newCase.Type = Constants.CASE_TYPE_NEW_ENTITY_REQUEST;
                    if(newCase.Entity__c == null){
                        newCase.Entity__c = caseParentMap.get(newCase.ParentId).Entity__c;
                    }
                }else if(newCase.RecordTypeId == Constants.PAPERFILEREQRTID && newCase.Internal_Status__c == Constants.CASE_STATUS_NEW && newCase.ParentId != null && caseParentMap.containsKey(newCase.ParentId)){
                    newCase.ContactId = caseParentMap.get(newCase.ParentId).ContactId;
                    newCase.AccountId = caseParentMap.get(newCase.ParentId).AccountId;
                    newCase.Case_Type__c = Constants.CASE_TYPE_NEW_PAPER_FILE_REQUEST;
                    newCase.Entity__c = caseParentMap.get(newCase.ParentId).Entity__c;
                    newCase.OwnerId = cvQueue.Id;
                }else if(newCase.RecordTypeId == Constants.AUTHSIGNLISTRTID && newCase.Internal_Status__c == Constants.CASE_STATUS_NEW && newCase.ParentId != null && caseParentMap.containsKey(newCase.ParentId)){
                    newCase.ContactId = caseParentMap.get(newCase.ParentId).ContactId;
                    newCase.Case_Type__c = Constants.CASE_TYPE_NEW_AUTH_SIGN_LIST_REQ;
                    newCase.Entity__c = caseParentMap.get(newCase.ParentId).Entity__c;
                    newCase.Document_Type__c = caseParentMap.get(newCase.ParentId).Document_Type__c;
                    newCase.Document_URL__c = caseParentMap.get(newCase.ParentId).Document_URL__c;
                    newCase.OwnerId = authSignQueue.Id;
                }else if(newCase.RecordTypeId == Constants.MEDEDURESRTID && newCase.Internal_Status__c == Constants.CASE_STATUS_NEW && newCase.ParentId != null && caseParentMap.containsKey(newCase.ParentId)){
                    newCase.ContactId = caseParentMap.get(newCase.ParentId).ContactId;
                    newCase.Entity__c = caseParentMap.get(newCase.ParentId).Entity__c;
                    newCase.Document_Type__c = caseParentMap.get(newCase.ParentId).Document_Type__c;
                    newCase.OwnerId = medEduResQueue.Id;
                }else if(newCase.RecordTypeId == Constants.ATTESTRECORDTYPEID && oldCasesMap.isEmpty()){
                    updateNewAttestationCaseFields(newCase, splInvQueue, caseParentMap);
                }else if(newCase.RecordTypeId == Constants.PETITIONFORRECONSRDTYPEID && oldCasesMap.isEmpty()){
                    newCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED;    
                }
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void afterTriggerHandler(List<Case> newCases, Map<Id, Case> oldCasesMap){
        try{
            Set<Id> conIds = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            List<Case> newCaseList = new List<Case>();
            Map<Id, String> idStatusMap = new Map<Id, String>();
            List<Contact> contacts = new List<Contact>();
            for(Case newCase : newCases){
                conIds.add(newCase.ContactId);
                if(newCase.RecordTypeId == Constants.CVRECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_SUBMITTED_IN_REVIEW){
                    caseIds.add(newCase.Id);
                }else if(newCase.RecordTypeId == Constants.NEW_ENTITY_REQUEST_RDTYPEID && newCase.ParentId != null){
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_ADDED){
                        idStatusMap.put(newCase.ParentId, Constants.CASE_STATUS_INST_ADD_COMPLETE);
                    }else if(newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
                        idStatusMap.put(newCase.ParentId, Constants.CASE_STATUS_INST_ADD_REJECTED);
                    }
                }else if((newCase.RecordTypeId == Constants.ID_VER_RDTYPEID || newCase.RecordTypeId == Constants.APP_BIO_CHANGE_RDTYPEID) && newCase.Internal_Status__c == Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_REINITIATED && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c))){
                    NotaryTransactionRequestEventHandler.publishEvent(newCase.Id);
                }else if(newCase.RecordTypeId == Constants.EXAMREGRTID && newCase.Enrollment_Verification_Parent__c != null && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && newCase.Enrollment_Verification_Parent__c != oldCasesMap.get(newCase.Id).Enrollment_Verification_Parent__c))){
                    newCaseList.add(newCase);
                }
            }
            if(!conIds.isEmpty()){
                for(Contact con :[SELECT Id, OFAC_Scan_Required__c FROM Contact WHERE Id IN :conIds AND OFAC_Scan_Required__c = False]){
                    con.OFAC_Scan_Required__c = True;
                    contacts.add(con);
                }
                if(!contacts.isEmpty() && Contact.SObjectType.getDescribe().isUpdateable()){
                    UPDATE contacts;
                }
            }
            invalidateVerificationPackets(caseIds);
            updateParentCase(idStatusMap);
            EVOutstandingReportCaseProcess.modifyExamCase(newCaseList);
            updateSharingRule(newCases, oldCasesMap);
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //Update fields of new Attestation case and sub case
    public static void updateNewAttestationCaseFields(Case newCase, Group splInvQueue, Map<Id, Case> caseParentMap){
        if(newCase.Case_Type__c == Constants.CASE_TYPE_ATTESTATION_CASE){
            newCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
            newCase.External_Status__c = Constants.CASE_STATUS_NEW;
            newCase.OwnerId = splInvQueue.Id;
            newCase.Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION;
            if(newCase.ContactId != null){
                newCase.Entity__c = CaseTriggerUtility.catMap.get(newCase.ContactId).Account__c;
            }
            newCase.Origin = 'Web';
        }
        if(newCase.Case_Type__c == Constants.CASE_TYPE_ATTESTATION_SUB_CASE && newCase.ParentId != null){
            newCase.Internal_Status__c = Constants.CASE_STATUS_IN_PROGRESS;
            newCase.External_Status__c = Constants.CASE_STATUS_IN_PROGRESS;
            newCase.Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION;
            newCase.Entity__c = caseParentMap.get(newCase.ParentId).Entity__c;
        }
    }
    public static void invalidateVerificationPackets(Set<Id> caseIds){
        try{
            List<Verification_Packet__c> vps = new List<Verification_Packet__c>();
            if(!caseIds.isEmpty()){
                for(Verification_Packet__c vp : [SELECT Id, Is_Active__c FROM Verification_Packet__c WHERE Case__c IN :caseIds AND Is_Active__c = True]){
                    vp.Is_Active__c = False;
                    vps.add(vp);
                }
                if(!vps.isEmpty() && Verification_Packet__c.SObjectType.getDescribe().isUpdateable()){
                    UPDATE vps;
                }
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void updateParentCase(Map<Id, String> idStatusMap){
        try{
            List<Case> cases = new List<Case>();
            if(!idStatusMap.isEmpty()){
                for(Case parent : [SELECT Id, Internal_Status__c FROM Case WHERE Id IN :idStatusMap.keySet()]){
                    parent.Internal_Status__c = idStatusMap.get(parent.Id);
                    cases.add(parent);
                }
                if(!cases.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                    UPDATE cases;
                }
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void invokePDFButlerDocGen(List<Case> newCases, Map<Id, Case> oldCasesMap){
        List<Case> newCasesList = new List<Case>();
        for(Case cse : newCases){
            if(((cse.RecordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID || cse.RecordTypeId == Constants.NONUSMLETRANSCCASERDTYPEID) && oldCasesMap.get(cse.Id).Internal_Status__c != cse.Internal_Status__c && cse.Internal_Status__c == Constants.CASE_STATUS_PENDING_PRINT) ||
                (cse.RecordTypeId == Constants.EVCASERECORDTYPEID && cse.Enrolled_in_Entity_Portal__c == False && cse.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c) ||
                ((cse.RecordTypeId == Constants.APP_BIO_CHANGE_RDTYPEID || cse.RecordTypeId == Constants.ID_VER_RDTYPEID) && cse.Internal_Status__c == Constants.CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c) ||
                (cse.RecordTypeId == Constants.ERVCASERECORDTYPEID && cse.Internal_Status__c == Constants.CASE_STATUS_NEW && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c) ||
                (cse.RecordTypeId == Constants.SCORERECHECKRDTYPEID && cse.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_COMPLETED && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c && cse.Case_Outcome__c == 'No Change in Score Result') ||
                (cse.RecordTypeId == Constants.ERVCASERECORDTYPEID && cse.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c) ||
                ((cse.RecordTypeId == Constants.DUPCERTRTID || cse.RecordTypeId == Constants.ECFMG_CERTIFICATE_RDTYPEID) && cse.Internal_Status__c == Constants.CASE_STATUS_PENDING_PRINT && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c)){
                newCasesList.add(cse);
            }
        }
        if(!newCasesList.isEmpty()){
            generateDocHelper(newCasesList, oldCasesMap);
        }     
    }
    //US-12708 - Added method to invoke the generateDocHelper to make callout to PDF Butler by passing the epic report cases with secondary parent case status as 'CV Accepted'
    public static void generateEpicReport(List<Case> caseList, Set<Id> epicCaseId){
        List<Case> caseWithCvCaseAccespted = new List<Case>();
        for(Case caseRec:[SELECT id,Secondary_Parent_Case__c, RecordTypeId FROM Case WHERE Id =: epicCaseId AND Secondary_Parent_Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_ACCEPTED AND Secondary_Parent_Case__r.Service__c =: Constants.CASE_SERVICE_EPIC]){
            caseWithCvCaseAccespted.add(caseRec);
        }
        if(!caseWithCvCaseAccespted.isEmpty()){
            generateDocHelper(caseWithCvCaseAccespted, new Map<Id,Case>());
        }
    }
    public static void generateDocHelper(List<Case> newCasesList, Map<Id, Case> oldCasesMap){
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        for(cadmus_core__Doc_Config__c config :[SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WITH SECURITY_ENFORCED]){
            docConfigMap.put(config.cadmus_core__View_Customer_DocConfig_Id__c, config);
        }
        for(Case newCase : newCasesList){
            Id docConfigId;
            if(newCase.RecordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_USMLE_TRANSCRIPT).Id;
            }else if(newCase.RecordTypeId == Constants.NONUSMLETRANSCCASERDTYPEID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_NON_USMLE_TRANSCRIPT).Id;
            }else if(newCase.RecordTypeId == Constants.EVCASERECORDTYPEID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_EV_FORM).Id;
            }else if(newCase.RecordTypeId == Constants.APP_BIO_CHANGE_RDTYPEID || newCase.RecordTypeId == Constants.ID_VER_RDTYPEID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_ID_FORM_TEMPLATE).Id;
            }else if(newCase.RecordTypeId == Constants.ERVCASERECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_NEW){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_CUSTOMERDOCCONFIG_ID).Id;
            }else if(newCase.RecordTypeId == Constants.ERVCASERECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_DEF_COV_LETTER).Id;
            }else if(newCase.RecordTypeId == Constants.SCORERECHECKRDTYPEID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_SCORE_RECHECK).Id;
            }else if(newCase.RecordTypeId == Constants.DUPCERTRTID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_ECFMGDUPLICATECERT_ID).Id;
            }else if(newCase.RecordTypeId == Constants.ECFMG_CERTIFICATE_RDTYPEID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_ECFMG_CERT).Id;
            }else if(newCase.RecordTypeId == Constants.EPICVERREPORTREQRTID){
                docConfigId = docConfigMap.get(Constants.DOCCONFIG_EPIC_VERIFICATION_REPORT).Id;
            }
            if(String.isNotBlank(docConfigId)){
                PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, newCase.Id);
                System.enqueueJob(calloutClass);
            }
        }
    }
    public static void updateSharingRule(List<Case> newCases, Map<Id, Case> oldCasesMap){
        List<Id> evCaseIds = new List<Id>();
        List<Id> epexCaseIds = new List<Id>();
        for(Case newCase : newCases){
            if(newCase.RecordTypeId == Constants.EXAMREGRTID && newCase.Enrollment_Verification_Parent__c != null && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && (newCase.Enrollment_Verification_Parent__c != oldCasesMap.get(newCase.Id).Enrollment_Verification_Parent__c || newCase.OwnerId != oldCasesMap.get(newCase.Id).OwnerId)))){
                evCaseIds.add(newCase.Enrollment_Verification_Parent__c);
            }else if(newCase.RecordTypeId == Constants.EVCASERECORDTYPEID && (oldCasesMap.isEmpty() || newCase.OwnerId != oldCasesMap.get(newCase.Id).OwnerId)){
                evCaseIds.add(newCase.Id);
            }else if(newCase.RecordTypeId == Constants.EPEXRTID && (oldCasesMap.isEmpty() || newCase.OwnerId != oldCasesMap.get(newCase.Id).OwnerId)){
                epexCaseIds.add(newCase.Id);
            }
        }
        SharingRuleEVCase.updateSharingRules(evCaseIds);
        SharingRuleEPEXCase.updateSharingRules(epexCaseIds);
    }*/
}