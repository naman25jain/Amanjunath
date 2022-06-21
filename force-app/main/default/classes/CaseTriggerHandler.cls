public with sharing class CaseTriggerHandler{
    public CaseTriggerHandler(){}
    /*public static Boolean isFirstTimeFCVS = true;
    public static void beforeInsert(List<Case> newCases){
        set<Id> contactIds = new set<Id>();
        List<Case> epexCaseCIBISPendingList = new List<Case>();
        Map<Id,List<Case>> enrollmentVerCaseMap = new Map<Id,List<Case>>();
        Map<Id, String> recordTypeIdDevNameMap = GenericUtilities.retriveRecordTypeIdWithDevNames('Case');
        for(Case newCase:newCases){
            updateCaseService(newCase,recordTypeIdDevNameMap.get(newCase.recordTypeId));
            CaseTriggerHelper.updateCaseRecordDate(newCase,new Case());
            CaseTriggerHelper.updateCaseRecordStatus(newCase,new Case());
            //if(newCase.recordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
            if(newCase.recordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID && newCase.Internal_Status__c == 'Rejected'){
                    newCase.Deficiency_Reason_RTF__c = 'We were unable to process your request.';
            }
            //User story 3965 EV29: Scenarios for taking a child case(Exam Reg/EPEx) off the enrollment verification case.)
            else if(newCase.RecordTypeId == Constants.EPEXRTID && (newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED) && !newCase.Is_Removed_From_EV__c){
                if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && string.isnotblank(newCase.ContactId)){
                    contactIds.add(newCase.ContactId);
                    epexCaseCIBISPendingList.add(newCase);
                }
                List<Case> newEpexCaseList = new List<Case>();
                if(enrollmentVerCaseMap.containsKey(newCase.Enrollment_Verification_Parent__c)){
                    newEpexCaseList.addAll(enrollmentVerCaseMap.get(newCase.Enrollment_Verification_Parent__c));
                }
                newEpexCaseList.add(newCase);
                enrollmentVerCaseMap.put(newCase.Enrollment_Verification_Parent__c,newEpexCaseList);
            }
        }
        CaseTriggerHelper.checkAppForCertCaseForAttestation(newCases);
        CasePBActionsHandler.beforeTriggerHandler(newCases, new Map<Id,Case>());
        if(!epexCaseCIBISPendingList.isEmpty()){
            updatePendingCIBISCase(contactIds,epexCaseCIBISPendingList);
        }
        if(!enrollmentVerCaseMap.isEmpty()){
            CaseTriggerHelper.updateEpexCaseRecords(enrollmentVerCaseMap);
        }
    }
    public static void beforeUpdate(Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap){
        set<Id> contactIds = new set<Id>();
        set<Id> cvNotVerifiedCaseId = new set<Id>();
        set<Id> cvUnverified = new set<Id>();
        List<Case> epexCaseCIBISPendingList = new List<Case>();        
        for(Case newCase:newCasesMap.values()){
            CaseTriggerHelper.updateCaseRecordDate(newCase,oldCasesMap.get(newCase.Id));
            CaseTriggerHelper.updateCaseRecordStatus(newCase,oldCasesMap.get(newCase.Id));
            if(newCase.RecordTypeId == Constants.EPEXRTID && newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && string.isnotblank(newCase.ContactId)){
                    contactIds.add(newCase.ContactId);
                    epexCaseCIBISPendingList.add(newCase);
                }
        }
        if(!epexCaseCIBISPendingList.isEmpty()){
            updatePendingCIBISCase(contactIds,epexCaseCIBISPendingList);
        }
        // Purpose : To update case deficiency reason on rejection of USMLE Transcript case
        if(RecursiveTriggerHandler.isFirstTimeBeforeUpdate){
            RecursiveTriggerHandler.isFirstTimeBeforeUpdate = false;
            List<Id> rejectedCaseList = new List<Id>();
            List<Case> newCVList = new List<Case>();
            string errorMsg = [SELECT Error_Message__c FROM Error_Message__mdt WHERE DeveloperName=:Constants.ERROR_SEND_METHOD_COMMENTS LIMIT 1].Error_Message__c;
            Set<String> verPendingStatus = new Set<String>{Constants.CASE_STATUS_SENT_FOR_VERIFICATION, Constants.CASE_STATUS_INCOMPLETE_RESENT_FOR_VERIFICATION, Constants.CASE_STATUS_RESENT_FOR_VERIFICATION};
            Set<String> verCompleteStatus = new Set<String>{Constants.CASE_STATUS_CV_ACCEPTED, Constants.CASE_STATUS_CV_REJECTED, Constants.CASE_STATUS_CANCELLED, Constants.CASE_STATUS_CANCELLED_BY_APPLICANT, 
                                                            Constants.CASE_STATUS_CANCELLED_BY_ECFMG, Constants.CASE_STATUS_UNABLE_TO_VERIFY_CRED, Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED, Constants.CASE_STATUS_ACCEPTED};
            Group verPendingQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_VERIFICATION_PENDING);
            Group verCompleteQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_VER_PROCESS_COMPLETE);                                                                   
            for(Case newCase:newCasesMap.values()){
                if(newCase.recordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED && oldCasesMap.get(newCase.Id).Internal_Status__c != Constants.CASE_STATUS_REJECTED){
                    newCase.Deficiency_Reason_RTF__c = 'We were unable to process your request.';
                }
                else if(newCase.RecordTypeId == Constants.APPFORCERTRECORDTYPEID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c
                        && (newCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED ||
                            newCase.Internal_Status__c == Constants.CASE_STATUS || newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CV)){
                                newCase.OwnerId = Constants.APPFORCERTQUEUE.Id;
                                if(newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
                                    rejectedCaseList.add(newCase.Id);
                                }
                            }
                else if(newCase.RecordTypeId == Constants.EVCASERECORDTYPEID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c
                        && (newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE)){
                            newCase.OwnerId = Constants.EVQUEUE.Id;
                        }
                else if(newCase.RecordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c
                        &&(newCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED || 
                           newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_PRINT ||newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ADDRESS_REVIEW)){
                               newCase.OwnerId = Constants.USMLTRANSCRIPTQUEUE.Id;
                           }
                else if(newCase.recordTypeId == Constants.CVRECORDTYPEID){
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION || newCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION){
                        newCase.Certify_the_document__c = null;
                        newCase.Comments_for_not_Certifying__c = null;
                        newCase.Reason_for_not_Certifying__c = null;
                    }
                    if(Constants.isnotUpdatedbySendMethodFlow && newCase.Entity__c == (oldCasesMap.get(newCase.Id)).Entity__c
                       && newCase.Alternate_Entity__c == (oldCasesMap.get(newCase.Id)).Alternate_Entity__c
                       && newCase.Send_Method__c != (oldCasesMap.get(newCase.Id)).Send_Method__c
                       && (String.isBlank(newCase.Send_Method_Override_Comments__c)
                           || (newCase.Send_Method_Override_Comments__c == (oldCasesMap.get(newCase.Id)).Send_Method_Override_Comments__c))){
                               newCase.addError(errorMsg);
                           }
                    else{
                        newCVList.add(newCase);
                    }
                    // US 11951- Collects Case Id to update Affirmation Next Step to null
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_NOT_VERIFIED && newCase.OwnerId == CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_NOT_VERIFIED_NAME).Id && ((oldCasesMap.get(newCase.Id)).Internal_Status__c != Constants.CASE_STATUS_NOT_VERIFIED || (oldCasesMap.get(newCase.Id)).OwnerId != CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_NOT_VERIFIED_NAME).Id)){
                        cvNotVerifiedCaseId.add(newCase.Id);
                    }
                    // US 11952- Collects Case Id to update Asset status to unverified
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_UNABLE_TO_VERIFY_CRED && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                        cvUnverified.add(newCase.Id);
                    }
                    if(verPendingStatus.contains(newCase.Internal_Status__c) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                        newCase.ownerId = verPendingQueue.Id;
                    }else if(verCompleteStatus.contains(newCase.Internal_Status__c) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                        newCase.ownerId = verCompleteQueue.Id;
                    }                                          
                }
                else if(newCase.RecordTypeId == Constants.EXAMREGRTID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c
                && (newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED || newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS ||
                    newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT ||newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL)){
                        newCase.OwnerId = Constants.EXAMREGQUEUE.Id;
                    }
                else if(newCase.RecordTypeId == Constants.MEDEDUFORMRTID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_VER_REVIEW && newCase.Service__c == Constants.CASE_SERVICE_ECFMG_CERT){
                        newCase.OwnerId = Constants.MEDEDUFORMQUEUE.Id;
                    }
                    if(verPendingStatus.contains(newCase.Internal_Status__c)){
                        newCase.ownerId = verPendingQueue.Id;
                    }else if(verCompleteStatus.contains(newCase.Internal_Status__c)){
                        newCase.ownerId = verCompleteQueue.Id;
                    } 
                }
            }
            if(!rejectedCaseList.isEmpty()){
                CaseTriggerHelper.updateAppforcertAssets(rejectedCaseList, Constants.ASSET_STATUS_REJECTED);
            }
            if(!newCVList.isEmpty()){
                CaseTriggerHelper.caseCheckEntity(newCVList, oldCasesMap);
            }
            if(!cvNotVerifiedCaseId.isEmpty()){
                CaseTriggerHelper.updateAffirmation(cvNotVerifiedCaseId);
            }
            if(!cvUnverified.isEmpty()){
                CaseTriggerHelper.updateAssetUnverified(cvUnverified);
            }
            CasePBActionsHandler.beforeTriggerHandler(newCasesMap.values(), oldCasesMap);
        }
    }
    public static void afterInsert(Map<Id,Case> newCasesMap){
        
        // ==================================================================================================
        // This secction was added by Raul Roque of Coastal Cloud
        // ==================================================================================================
        // This method is in charge of creating the corresponding Case_Line__c records when a Case_Service__c
        // is selected.
        // ==================================================================================================
        if (CaseTriggerHandler_Finance.isFirstInsert) {
            CaseTriggerHandler_Finance.isFirstInsert = false;
            CaseTriggerHandler_Finance.OnAfterInsert(newCasesMap);
        }
        // ==================================================================================================

        Id entityUserRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST);
        Id credVerRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
        Id medFormRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_MED_EDU_FORM);
        Id epicRepReqRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
        if(RecursiveTriggerHandler.isFirstTime){
            RecursiveTriggerHandler.isFirstTime = false;
            CaseTriggerHelper.afterInsertHelper(newCasesMap.values());
        }
        List<CaseTriggerHelper.SharingRecWrapper> sharingRecWrapperList = new List<CaseTriggerHelper.SharingRecWrapper>();
        List<Case> newCases = new List<Case>();
        List<Case> newEVSharingCases = new List<Case>();
        List<Case> newEntityUserCases = new List<Case>();
        List<Case> shareCredVerCases = new List<Case>();
        List<Case> shareMedFormCases = new List<Case>();
        List<Case> newCibisCases = new List<Case>();
        Set<Id> serviceIdset = new Set<Id>();
        Set<Id> cvParentCaseIds = new Set<Id>();
        Set<Id> epicReportIdSet = new Set<Id>();
        List<Case> epicReportCases = new List<Case>();        
        for(Case newCase : newCasesMap.values()){
            if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS){
                newCibisCases.add(newCase);
            }
            if(newCase.RecordTypeId == Constants.ERVCASERECORDTYPEID && (newCase.Internal_Status__c == Constants.CASE_STATUS_NEW || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE)){
                newCases.add(newCase);
            }
            if(newCase.RecordTypeId == Constants.EPICVERREPORTREQRTID && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT){
                epicReportCases.add(newCase);
                epicReportIdSet.add(newCase.Id);
            }
            else if(newCase.RecordTypeId == Constants.EVCASERECORDTYPEID){
                newEVSharingCases.add(newCase);
            }
            else if(newCase.RecordTypeId == entityUserRecTypeId || newCase.RecordTypeId == epicRepReqRecTypeId){
                if(newCase.RecordTypeId == epicRepReqRecTypeId){
                    serviceIdset.add(newCase.Service_Name__c);
                    CaseTriggerHelper.CredVerCasesToUpdate(newCase.Id); 
                }
                if((newCase.RecordTypeId == entityUserRecTypeId || newCase.RecordTypeId == epicRepReqRecTypeId) && newCase.Entity__c != null){
                    newEntityUserCases.add(newCase); 
                }               
                               
            }
            else if(newCase.RecordTypeId == credVerRecTypeId && newCase.Entity__c != null){
                shareCredVerCases.add(newCase);
                if(String.isNotBlank(newCase.ParentId)){
                    cvParentCaseIds.add(newCase.ParentId);
                }
            }
            else if(newCase.RecordTypeId == medFormRecTypeId && newCase.Entity__c != null){
                shareMedFormCases.add(newCase);
            }
        }        
        for(case2service__c entUserCs : [SELECT Id,Service__c,case__c,case__r.RecordTypeId,role__c 
                                FROM case2service__c WHERE case__c IN:newEntityUserCases]){
            if(entUserCs.case__r.RecordTypeId == entityUserRecTypeId){
                serviceIdset.add(entUserCs.Service__c);
            }            
        }
        if(!newCases.isEmpty()){
            CasePBActionsHandler.generateDocHelper(newCases, new Map<Id,Case>());
        }
        if(!epicReportCases.isEmpty()){
            CasePBActionsHandler.generateEpicReport(epicReportCases, epicReportIdSet);
        }
        if(!newEVSharingCases.isEmpty()){
            CasePBActionsHandler.afterTriggerHandler(newEVSharingCases, new Map<Id, Case>());           
        }
        if(!newEntityUserCases.isEmpty() && !serviceIdset.isEmpty()){
            sharingRecWrapperList.add(CaseTriggerHelper.entityUserUpdateSharingRules(serviceIdset,newEntityUserCases,new Map<Id,Case>()));
        }
        if(!shareCredVerCases.isEmpty()){
            sharingRecWrapperList.add(CaseTriggerHelper.credVerUpdateSharingRules(shareCredVerCases,new Map<Id,Case>(),CaseTriggerHelper.getParentCaseChildCaseEntity(GenericUtilities.getIdsFromList(shareCredVerCases),cvParentCaseIds)));
        }
        if(!shareMedFormCases.isEmpty()){
            sharingRecWrapperList.add(CaseTriggerHelper.medFormUpdateSharingRules(shareMedFormCases,new Map<Id,Case>()));
        }
        if(!sharingRecWrapperList.isEmpty()){
            CaseTriggerHelper.updateCaseSharingRules(sharingRecWrapperList);
        }
           // invoke Cibis platform event publish logic
        if(RecursiveTriggerHandler.isFirstTimeCibis && !newCibisCases.isEmpty()){ 
            CibisUtility.invokeCibisPlatformEventLogic(newCibisCases, null);
        }

    }
    //To optimise after update context code
    public static void afterUpdate(Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap){
        
        // ==================================================================================================
        // This secction was added by Raul Roque of Coastal Cloud
        // ==================================================================================================
        // This method is in charge of creating the corresponding Case_Line__c records when a Service_List__c
        // is selected.
        // ==================================================================================================
        if (CaseTriggerHandler_Finance.isFirstUpdate) {
            CaseTriggerHandler_Finance.isFirstUpdate = false;
            CaseTriggerHandler_Finance.OnAfterUpdate(newCasesMap, oldCasesMap);
        } 
            if(RecursiveTriggerHandler.isFirstTimeCibis){
            // Invoke CIBIS platform event publish method from utility
            CibisUtility.invokeCibisPlatformEventLogic(newCasesMap.values(),oldCasesMap);
            }
        // ==================================================================================================
        Set<Id> epicReportIdSet = new Set<Id>();
        List<Case> epicReportCases = new List<Case>();
        Id entityUserRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST);
        Id epicRepReqRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
        Id credVerRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
        List<Id> caseIds = new List<Id>();
        List<Case> newEntityUserCases = new List<Case>();
        Set<Id> serviceIdset = new Set<Id>();
        List<Case> newCaseList = new List<Case>();
        List<Case> medEduFormcases = new List<Case>();
        List<Case> examNewCases = new List<Case>();
        List<Case> credVerNewCases = new List<Case>();
        List<Case> credVerCasesNew = new List<Case>();
        Map<Id,Case> credVerCasesOld = new Map<Id,Case>();
        List<Case> shareCredVerCases = new List<Case>();
        List<Case> shareMedFormCases = new List<Case>();
        List<Case> attestationCases = new List<Case>();
        List<Case> epicCasesToUpdate = new List<Case>();
        List<Case> fcvsCases = new List<Case>();
        Set<Id> usmleCaseIds = new Set<Id>();
        Set<Id> usmleNonUsmleParentIds = new Set<Id>();
        Set<Id> cvParentCaseIds = new Set<Id>();
        List<Case> investigationCases = new List<Case>();
        Map<Id,Case> investigationCasesOld = new Map<Id,Case>();
        Set<Id> conIds = new Set<Id>();
        List<CaseTriggerHelper.SharingRecWrapper> sharingRecWrapperList = new List<CaseTriggerHelper.SharingRecWrapper>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<string> emailTempNames = new Set<string>{Constants.CASE_EMAIL_TEMPLATE_NAME,Constants.EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE,Constants.CASE_EMAIL_TEMPLATE_NAME,Constants.EMAIL_CASE_STATUS_UPDATE_ON_CV_ACCEPTED,Constants.EMAIL_TEMPLATE_ATTEST_CASE_STATUS_UPDATE};
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> emailTemplateList = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName in:emailTempNames]; //Donot add WITH SECURITY_ENFORCED
        List<OrgWideEmailAddress> addrList = [SELECT Id,displayname FROM OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];//Donot add WITH SECURITY_ENFORCED        
        Group medEduFormQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MED_EDU_FORM);
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        //changing the normal query to a dynamic query as per the regression bug 19663
        List<Contact_Association_Type__c> catDegreeMedSchoolRecord = new List<Contact_Association_Type__c>();
        String catQuery = 'SELECT Id, Account__c, Contact__c FROM Contact_Association_Type__c WHERE RecordTypeId =: degMedSchRecordTypeId';               
        if(UserInfo.getName() != Constants.ENTITY360_SITE_GUEST_USER){
            catQuery +=  ' WITH SECURITY_ENFORCED';
        }
        catDegreeMedSchoolRecord = Database.Query(catQuery);
        String strEntity = '';                
        List<Case> examRegCaseList = new List<Case>();
        Map<String,OrgWideEmailAddress> orgWideAddressMap= new Map<String,OrgWideEmailAddress>();
        Map<String,EmailTemplate> emailTemplateMap= new Map<String,EmailTemplate>();
        for(OrgWideEmailAddress addr:addrList){
            orgWideAddressMap.put(addr.displayname,addr);
        }
        for(EmailTemplate emailTemplate:emailTemplateList){
            emailTemplateMap.put(emailTemplate.DeveloperName,emailTemplate);
        }
        Boolean nonAppforcertCase = true;
        for(Case newCase : newCasesMap.values()){
            System.debug('*****newCaseMap310'+newCase.Internal_Status__c);
            System.debug('*****oldCaseMap311'+oldCasesMap.get(newCase.Id).Internal_Status__c);
            if(newCase.RecordTypeId == Constants.EXAMREGRTID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                if(newCase.Internal_Status__c == Constants.CASE_STATUS_REGISTERED && oldCasesMap.get(newCase.Id).Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS){
                    newCaseList.add(newCase);
                    contactIdSet.add(newCase.ContactId);
                }
                else if(newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE){
                    examNewCases.add(newCase);
                    contactIdSet.add(newCase.contactId);
                }
                else if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS){
                    examRegCaseList.add(newCase);
                }
            }
            else if(newCase.RecordTypeId == Constants.DUPCERTRTID && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT
                   && orgWideAddressMap.containsKey(Constants.ORG_WIDE_ADDRESS) && emailTemplateMap.containsKey(Constants.EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE)){
                messages.add(CaseTriggerHelper.prepareEmail(newCase,orgWideAddressMap.get(Constants.ORG_WIDE_ADDRESS),emailTemplateMap.get(Constants.EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE)));
            }
            else if(newCase.RecordTypeId == Constants.APPFORCERTRECORDTYPEID && (newCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && string.isNotBlank(newCase.ContactEmail)){
                newCaseList.add(newCase);
                contactIdSet.add(newCase.ContactId);
            }
            else if(newCase.RecordTypeId == Constants.CVRECORDTYPEID){
                credVerCasesNew.add(newCase);
                credVerCasesOld.put(newCase.Id, oldCasesMap.get(newCase.Id));
                fcvsCases.add(newCase);
                if(newCase.Internal_Status__c == Constants.CASE_STATUS_INCOMPLETE_RESENT_FOR_VERIFICATION && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && string.isNotBlank(newCase.ContactEmail) && (newCase.Service__c == Constants.CASE_SERVICE_EPIC || newCase.Service__c == Constants.CASE_SERVICE_ECFMG_CERTIFICATION)){
                    credVerNewCases.add(newCase);
                    contactIdSet.add(newCase.ContactId);
                }
                if(newCase.Entity__c != oldCasesMap.get(newCase.Id).Entity__c || newCase.alternate_Entity__c != oldCasesMap.get(newCase.Id).alternate_Entity__c || newCase.OwnerId != oldCasesMap.get(newcase.Id).OwnerId){
                    shareCredVerCases.add(newCase);
                    if(String.isNotBlank(newCase.ParentId)){
                        cvParentCaseIds.add(newCase.ParentId);
                    }
                }
                if(newCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION && oldCasesMap.get(newCase.Id).Internal_Status__c != Constants.CASE_STATUS_SENT_FOR_VERIFICATION && newCase.Service__c == Constants.CASE_SERVICE_EPIC){
                    epicCasesToUpdate.addAll(CaseTriggerHelper.updateEpicReportVerifReqSendDate(newCase.Id));
                }
            }
            else if(newCase.RecordTypeId == Constants.MEDEDUFORMID){
                if(newCase.Entity__c != oldCasesMap.get(newCase.Id).Entity__c || newCase.alternate_Entity__c != oldCasesMap.get(newCase.Id).alternate_Entity__c || newCase.OwnerId != oldCasesMap.get(newcase.Id).OwnerId){
                    shareMedFormCases.add(newCase);
                }
                fcvsCases.add(newCase);
            }
            else if(newCase.RecordTypeId == Constants.ECFMG_CERTIFICATE_RDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c ){
                //Create a new case - New Case Record Type: “Medical Education Form”, Internal Status: New & Ownerid=Medical Education Form queue
                Case medEduFormCase = new Case();
                medEduFormCase.ParentId = newCase.Id;
                medEduFormCase.RecordTypeId = Constants.MEDEDUFORMRTID;
                medEduFormCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
                medEduFormCase.OwnerId = medEduFormQueue.Id;
                medEduFormCase.Document_Type__c = Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM;
                medEduFormCase.Received_Date__c = Date.today();
                medEduFormCase.ContactId = newCase.ContactId;
                medEduFormCase.Service__c = Constants.CASE_SERVICE_ECFMG_CERT;
                //Entity name from Contact Association Type record record type degree medical school of the applicant
                for(Contact_Association_Type__c medCatRec : catDegreeMedSchoolRecord){
                    if(medCatRec.Contact__c == newCase.ContactId){
                        strEntity = medCatRec.Account__c;
                    }
                }
                medEduFormCase.Entity__c = strEntity;
                medEduFormcases.add(medEduFormCase);
            }
            else if((newCase.RecordTypeId == entityUserRecTypeId || newCase.RecordTypeId == epicRepReqRecTypeId) && (newCase.Entity__c != oldCasesMap.get(newcase.Id).Entity__c || newCase.OwnerId != oldCasesMap.get(newcase.Id).OwnerId)){
                newEntityUserCases.add(newCase);
                if(newCase.RecordTypeId == epicRepReqRecTypeId){
                    serviceIdset.add(newCase.Service_Name__c);
                }
            }else if(newCase.RecordTypeId == Constants.ATTESTRECORDTYPEID && newCase.Case_Type__c == Constants.CASE_TYPE_ATTESTATION_CASE){
                set<string> statusSet = new set<string>{Constants.CASE_STATUS_ACCEPTED,Constants.CASE_STATUS_CANCELLED,Constants.CASE_STATUS_REJECTED};
                if(statusSet.contains(newCase.Internal_Status__c) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                    attestationCases.add(newCase);
                    contactIdSet.add(newCase.ContactId);
                }
            }
            else if(newCase.RecordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_PRINT && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                usmleCaseIds.add(newCase.Id);
            }
            else if((newCase.RecordTypeId == Constants.USMLETRANSCRIPTCASERECORDTYPEID || newCase.RecordTypeId == Constants.NONUSMLETRANSCCASERDTYPEID) && 
                     (newCase.Internal_Status__c == Constants.CASE_STATUS_SENT || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED) && 
                    newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && newCase.parentId != NULL){
                    usmleNonUsmleParentIds.add(newCase.parentId);
            }
            else if(newCase.RecordTypeId == Constants.INVESTIGATIONRTID){
                investigationCases.add(newCase);
                investigationCasesOld.put(newCase.Id, oldCasesMap.get(newCase.Id));
                if(newCase.Annotation__c != null){
                    conIds.add(newCase.ContactId);
                }
            }else if(newCase.RecordTypeId == Constants.EPICVERREPORTREQRTID && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c){
                epicReportCases.add(newCase);
                epicReportIdSet.add(newCase.Id);
            }
            // Added for US 18841
            if(newCase.RecordTypeId == credVerRecTypeId && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_CLOSED_NOT_AUTHENTIC){
                caseIds.add(newCase.Id);
            }
            // Added for Bug 21111 - temporary solution
            if(newCase.RecordTypeId == Constants.APPFORCERTRECORDTYPEID && (newCase.Internal_Status__c == Constants.CASE_STATUS_SUBMITTED || newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_REVIEW || newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                nonAppforcertCase = false;
            }
        }
        if(RecursiveTriggerHandler.isFirstTime){
            RecursiveTriggerHandler.isFirstTime = false;
            System.debug('Inside After Update');
            CaseTriggerHelper.afterUpdateHelper(newCasesMap.values(), oldCasesMap);
            CaseTriggerHelper.updateAssetOfVP(newCasesMap.values(), oldCasesMap);
        }
        if(nonAppforcertCase == true){
            if(caseIds.size() > 0){
                updateRelatedAssetsAndAffr(caseIds);
            }
            if (!fcvsCases.isEmpty()) {
                if (isParentFCVSCaseType(fcvsCases[0].ParentId)){
                    updateParentCaseForFCVS(fcvsCases);    
                }
            }       
            if(!contactIdSet.isEmpty() && (!newCaseList.isEmpty() || !examNewCases.isEmpty() || !credVerNewCases.isEmpty() || !attestationCases.isEmpty())){
                List<CaseTriggerHelper.SendMailWrapper> sendMailWrapperList = new List<CaseTriggerHelper.SendMailWrapper>();
                Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE Id in:contactIdSet]);
                if(!newCaseList.isEmpty()){
                    CaseTriggerHelper.sendMailWrapper sendMailWrap = new CaseTriggerHelper.sendMailWrapper();
                    sendMailWrap.caseList.addAll(newCaseList);
                    sendMailWrap.addr = orgWideAddressMap.get(Constants.ORG_WIDE_ADDRESS);
                    sendMailWrap.emailTemplate = emailTemplateMap.get(Constants.CASE_EMAIL_TEMPLATE_NAME);
                    sendMailWrapperList.add(sendMailWrap);
                }
                if(!examNewCases.isEmpty()){
                    CaseTriggerHelper.sendMailWrapper sendMailWrap = new CaseTriggerHelper.sendMailWrapper();
                    sendMailWrap.caseList.addAll(examNewCases);
                    sendMailWrap.addr = orgWideAddressMap.get(Constants.ORG_WIDE_ADDRESS);
                    sendMailWrap.emailTemplate = emailTemplateMap.get(Constants.CASE_EMAIL_TEMPLATE_NAME);
                    sendMailWrapperList.add(sendMailWrap);
                }
                if(!credVerNewCases.isEmpty()){
                    CaseTriggerHelper.sendMailWrapper sendMailWrap = new CaseTriggerHelper.sendMailWrapper();
                    sendMailWrap.caseList.addAll(credVerNewCases);
                    sendMailWrap.addr = orgWideAddressMap.get(Constants.ORG_WIDE_ADDRESS);
                    sendMailWrap.emailTemplate = emailTemplateMap.get(Constants.EMAIL_CASE_STATUS_UPDATE_ON_CV_ACCEPTED);
                    sendMailWrapperList.add(sendMailWrap);
                }
                if(!attestationCases.isEmpty()){
                    CaseTriggerHelper.sendMailWrapper sendMailWrap = new CaseTriggerHelper.sendMailWrapper();
                    sendMailWrap.caseList.addAll(attestationCases);
                    sendMailWrap.addr = orgWideAddressMap.get(Constants.ORG_WIDE_ADDRESS);
                    sendMailWrap.emailTemplate = emailTemplateMap.get(Constants.EMAIL_TEMPLATE_ATTEST_CASE_STATUS_UPDATE);
                    sendMailWrapperList.add(sendMailWrap);
                }
                if(!sendMailWrapperList.isEmpty()){
                    messages.addAll(CaseTriggerHelper.sendCaseStatusMail(sendMailWrapperList,contactMap));
                }
            }
            if(!messages.isEmpty()){
                Messaging.sendEmail(messages);
            }
            if(!newEntityUserCases.isEmpty()){
                //changing the normal query to a dynamic query as per the regression bug 19663
                List<case2service__c> case2serviceList;
                String c2sQuery = 'SELECT Id,Service__c,case__c,case__r.RecordTypeId,role__c FROM case2service__c WHERE case__c IN:newEntityUserCases';
                if(UserInfo.getName() != Constants.ENTITY360_SITE_GUEST_USER){
                    c2sQuery += ' WITH SECURITY_ENFORCED';
                }
                case2serviceList = Database.Query(c2sQuery);
                for(case2service__c entUserCs : case2serviceList){
                    if(entUserCs.case__r.RecordTypeId == entityUserRecTypeId){
                        serviceIdset.add(entUserCs.Service__c);
                    }
                }
                if(!serviceIdset.isEmpty()){
                    sharingRecWrapperList.add(CaseTriggerHelper.entityUserUpdateSharingRules(serviceIdset,newEntityUserCases,oldCasesMap));
                }
            }
            
            if(!epicReportCases.isEmpty()){
                CasePBActionsHandler.generateEpicReport(epicReportCases, epicReportIdSet);
            }
            if(!shareCredVerCases.isEmpty()){
                sharingRecWrapperList.add(CaseTriggerHelper.credVerUpdateSharingRules(shareCredVerCases, oldCasesMap,CaseTriggerHelper.getParentCaseChildCaseEntity(GenericUtilities.getIdsFromList(shareCredVerCases),cvParentCaseIds)));
            }
            if(!shareMedFormCases.isEmpty()){
                sharingRecWrapperList.add(CaseTriggerHelper.medFormUpdateSharingRules(shareMedFormCases,oldCasesMap));
            }
            if(!sharingRecWrapperList.isEmpty()){
                CaseTriggerHelper.updateCaseSharingRules(sharingRecWrapperList);
            }
            if(!epicCasesToUpdate.isEmpty()){
                CaseTriggerHelper.updateEpicCases(epicCasesToUpdate);
            }
          
            //afterUpdateHelperRecursive method is created for allowing recursive to update the Case Status and also avoiding SonarCloud Issue
            CaseTriggerHelper.afterUpdateHelperRecursive(newCasesMap.values(), oldCasesMap);*/
            /*Clone transcript annotations from related transcript case after transcript evaluation info received from CIBIS*/
            //CibisUtility.processRelatedCaseTranscriptAnnots(newCasesMap, oldCasesMap, null);   
            /*if(RecursiveTriggerHandler.isFirstTime){
                RecursiveTriggerHandler.isFirstTime = false;
                System.debug('Inside After Update');
                CaseTriggerHelper.afterUpdateHelper(newCasesMap.values(), oldCasesMap);
                CaseTriggerHelper.updateAssetOfVP(newCasesMap.values(), oldCasesMap);
            }*/
            /*CaseTriggerHelper.updateParentCertCase(newCasesMap.values(), oldCasesMap);
            if(!usmleCaseIds.isEmpty()){
                populateTransComment(usmleCaseIds);
            }
            if(!usmleNonUsmleParentIds.isEmpty()){
                updateParentCaseUsmleNonUsmle(usmleNonUsmleParentIds);
            }
            CasePBActionsHandler.invokePDFButlerDocGen(newCasesMap.values(), oldCasesMap);
            if(!medEduFormcases.isEmpty() && Case.SObjectType.getDescribe().isCreateable()){
                INSERT medEduFormcases;
            }
            if(!credVerCasesNew.isEmpty()){
                updateParentAppforCert(credVerCasesNew, credVerCasesOld);
                validateEPICReportGeneration(credVerCasesNew, credVerCasesOld);
            }
            if(!conIds.isEmpty()){
                checkOffIBFlag(conIds);
            }
            createTransAnnotation(investigationCases, investigationCasesOld);
        }
    }
    //Method to update IB notification flag on EPIC Verification Report case
    public static void checkOffIBFlag(Set<Id> conIds){
        List<Case> epicCases = new List<Case>();
        Id epicRepReqTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        for(Case epicCase : [SELECT Id, Internal_Status__c, Irregular_Behavior_Annotated__c FROM Case WHERE ContactId IN:conIds AND Internal_Status__c !=:Constants.CASE_STATUS_SENT AND RecordTypeId =:epicRepReqTypeId WITH SECURITY_ENFORCED]){
            epicCase.Irregular_Behavior_Annotated__c = True;
            epicCases.add(epicCase);
        }
        if(!epicCases.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
            UPDATE epicCases;
        }
    }
    //Added for US 18841. Update related Assets and Affirmations Status for CV - Closed - Not Authentic
    public static void updateRelatedAssetsAndAffr(List<Id> caseIds){
        List<Asset> asst = new List<Asset>();
        List<Asset> asstDOB = new List<Asset>();
        List<Affirmation__c> affr = new List<Affirmation__c>();
        for(Asset a : [SELECT Id, RecordTypeId, Name, Status, Case__c  FROM ASSET WHERE Case__c =: caseIds AND 
                        (Name =: Constants.ASSET_NAME_RETURNED_VERIFICATION_FORM OR
                        Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST OR
                        Name =: Constants.ASSET_NAME_SUPPORTING_DOCUMENTS OR
                        Name =: Constants.ASSET_NAME_RETURNED_SUPPORTING_DOCUMENTS OR
                        Name like 'Returned%')]){
            a.Status = Constants.ASSET_NOT_AUTHENTIC;
            asst.add(a);
        }
        if(asst.size()>0){
            UPDATE asst;
        }
        for(Asset a : [SELECT Id, RecordTypeId, Name, Status, Case__c, Type__c  FROM ASSET WHERE Case__c =: caseIds AND 
                        (Name =: Constants.ASSET_NAME_DOCUMENT OR
                        Name =: Constants.ASSET_DOB_DOCUMENT)]){
            a.Status = Constants.ASSET_INACTIVE;
            asstDOB.add(a);
        }
        if(asstDOB.size()>0){
            UPDATE asstDOB;
        }
        for(Affirmation__c a : [SELECT Id, Name, RecordType.Name, Status__c, Case__c FROM Affirmation__c WHERE Case__c =: caseIds AND 
                                (RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION OR 
                                RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW)]){
            a.Status__c = Constants.AFFIRMATION_NOT_AUTHENTIC;
            affr.add(a);
        }
        if(affr.size()>0){
            UPDATE affr;  
        }
    }
    // Updates external status if internal status is Pending CIBIS for Eligibility period extension
    static void updatePendingCIBISCase(set<Id> contactIds,List<case> epexCaseCIBISPendingList){
        map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,School_Enrollment_Status__c FROM Contact WHERE Id in: contactIds]);
        for(Case newCase:epexCaseCIBISPendingList){
            if(contactMap.containsKey(newCase.ContactId)){
                string schoolEnrollmentStatus = contactMap.get(newCase.ContactId).School_Enrollment_Status__c;
                if(string.isNotBlank(schoolEnrollmentStatus)){
                    if(schoolEnrollmentStatus == Constants.CONASCTYPESTG_STATUS_STUDENT){
                        newCase.External_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFIED;
                    }
                    else if(schoolEnrollmentStatus == Constants.CONASCTYPESTG_STATUS_GRADUATE){
                        newCase.External_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
                    }
                }
            }            
        }
    }
    public static void updateParentAppforCert(List<Case> credVerCasesNew, Map<Id,Case> credVerCasesOld){
        try{
            List<Case> caseToUpdate = new List<Case>();
            List<Case> caseOrgUpdate = new List<Case>();            
            List<Case> acceptedCVs = new List<Case>();
            Set<Id> parentIds = new Set<Id>();
            if(RecursiveTriggerHandler.isFirstTimeCV){
                RecursiveTriggerHandler.isFirstTimeCV = false;
                for(Case newCase : credVerCasesNew){
                    if(newCase.Service__c == Constants.CASE_SERVICE_ECFMG_CERTIFICATION){
                        parentIds.add(newCase.ParentId);
                        caseOrgUpdate.add(new Case(Id = newCase.Id, Internal_Status__c = newCase.Internal_Status__c));
                    }
                }
                List<Case> cvCases = new List<Case>();
                if(!parentIds.isEmpty()){
                    cvCases = [SELECT Id, Internal_Status__c, contact.is_CIBIS_Origin__c FROM Case WHERE ParentId IN :parentIds AND Service__c =: Constants.CASE_SERVICE_ECFMG_CERTIFICATION AND RecordTypeId =:Constants.CVRECORDTYPEID];
                }
                for(Case newCase : credVerCasesNew){
                    if(newCase.Internal_Status__c != credVerCasesOld.get(newCase.Id).Internal_Status__c && newCase.Service__c == Constants.CASE_SERVICE_ECFMG_CERTIFICATION){
                        if(newCase.ParentId != null && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION || newCase.Internal_Status__c == Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL){
                            caseToUpdate.add(new Case(Id = newCase.ParentId, Internal_Status__c = Constants.CASE_STATUS_PENDING_CV));
                        }
                        if(newCase.ParentId != null && newCase.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED || newCase.Internal_Status__c.contains(Constants.CASE_STATUS_CANCELLED) || newCase.Internal_Status__c == Constants.CASE_STATUS_EXPIRED){
                            String status = newCase.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED ? Constants.CASE_STATUS_REJECTED : newCase.Internal_Status__c.contains(Constants.CASE_STATUS_CANCELLED) ? Constants.CASE_STATUS_CANCELLED : newCase.Internal_Status__c;
                            caseToUpdate.add(new Case(Id = newCase.ParentId, Internal_Status__c = status));
                            for(Case cvCase : cvCases){
                                if(cvCase.Internal_Status__c != Constants.CASE_STATUS_CV_ACCEPTED && 
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_CV_REJECTED && 
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_CANCELLED && 
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_SENT_FOR_VERIFICATION && 
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED &&
                                        (cvCase.Internal_Status__c == Constants.CASE_STATUS_NEW || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_SUBMITTED_IN_REVIEW || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_CV_INCOMPLETE || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_RESUBMITTED_PENDING_REVIEW || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_COMPILE_VF_PACKET || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_PRINT || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_EMAIL_CREATION || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ADDRESS_REVIEW)){
                                    cvCase.Internal_Status__c = Constants.CASE_STATUS_CV_REJECTED;
                                    caseToUpdate.add(cvCase);
                                }
                                else if(cvCase.Internal_Status__c != Constants.CASE_STATUS_CV_ACCEPTED && 
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_CV_REJECTED && 
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_CANCELLED &&  
                                        cvCase.Internal_Status__c != Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED &&
                                        (cvCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_VER_REVIEW || 
                                        cvCase.Internal_Status__c == Constants.CASE_STATUS_VERIFICATION_IN_REVIEW)){
                                    cvCase.Internal_Status__c = Constants.CASE_STATUS_CANCELLED;
                                    caseToUpdate.add(cvCase);
                                }
                            }
                        }
                        if(newCase.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED || newCase.Internal_Status__c == Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED){
                            for(Case cvCase : cvCases){
                                if(cvCase.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED || cvCase.Internal_Status__c == Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED){
                                    acceptedCVs.add(cvCase);
                                }
                            }
                        }
                    }
                    if(!acceptedCVs.isEmpty() && acceptedCVs.size() == cvCases.size()){
                        if(acceptedCVs[0].contact.is_CIBIS_Origin__c){
                        caseToUpdate.add(new Case(Id = newCase.ParentId, Internal_Status__c = Constants.CASE_STATUS_ACCEPTED));     
                        }else{
                            system.debug('===updateParentAppforCert===> ' +caseToUpdate);
                            caseToUpdate.add(new Case(Id = newCase.ParentId,External_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW, Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS));   
                        }
                    }
                }               
                if(!caseToUpdate.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                    UPDATE caseToUpdate;
                    List<Case> mergeCaseList = new List<Case>();
                    mergeCaseList.addAll(caseToUpdate);
                    mergeCaseList.addAll(caseOrgUpdate);
                    rejectCVRejectedAssets(mergeCaseList);                   
                }               
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Rejecting CV Case's (Internal Status - CV Rejected) Assets
    public static void rejectCVRejectedAssets(List<Case> caseToUpdate){
        List<Id> rejectedCVCaseList = new List<Id>();
        List<Id> cancelledCVCaseList = new List<Id>();
        List<Id> expiredCVCaseList = new List<Id>();
        for(Case cseRec : caseToUpdate){
            if(cseRec.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED || cseRec.Internal_Status__c == Constants.CASE_STATUS_CANCELLED){
                rejectedCVCaseList.add(cseRec.Id);
            }
            if(cseRec.Internal_Status__c == Constants.CASE_STATUS_CANCELLED_BY_APPLICANT || cseRec.Internal_Status__c == Constants.CASE_STATUS_CANCELLED_BY_ECFMG){
                cancelledCVCaseList.add(cseRec.Id);
            }
            //Expired CV Cases
            if(cseRec.Internal_Status__c == Constants.CASE_STATUS_EXPIRED){
                expiredCVCaseList.add(cseRec.Id);
            }
        }
        if(!rejectedCVCaseList.isEmpty()){
            CaseTriggerHelper.updateAppforcertAssets(rejectedCVCaseList, Constants.ASSET_STATUS_REJECTED);
        }
        if(!cancelledCVCaseList.isEmpty()){
            CaseTriggerHelper.updateAppforcertAssets(cancelledCVCaseList, Constants.ASSET_STATUS_CANCELLED);
        }
        if(!expiredCVCaseList.isEmpty()){
            CaseTriggerHelper.updateAppforcertAssets(expiredCVCaseList, Constants.ASSET_STATUS_EXPIRED);
        }
    }
    // US 12716 - Validation to process the EPIC Verification Report
    public static void validateEPICReportGeneration(List<Case> credVerCasesNew, Map<Id,Case> credVerCasesOld){
        try{
            Set<Id> parentCVIds = new Set<Id>();
            if(RecursiveTriggerHandler.isFirstTimeCreVer){
                RecursiveTriggerHandler.isFirstTimeCreVer = false;
                for(Case newCase : credVerCasesNew){
                    if(newCase.Service__c == Constants.CASE_SERVICE_EPIC && newCase.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED && newCase.Internal_Status__c != credVerCasesOld.get(newCase.Id).Internal_Status__c){
                        parentCVIds.add(newCase.Id);
                    }
                }
                if(!parentCVIds.isEmpty()){
                    List<Case> epicVerfReportCases = [SELECT Id, Internal_Status__c, Report_Type__c, EPIC_Report_Status__c, EPIC_Report_Received_Date__c FROM Case WHERE Secondary_Parent_Case__c IN: parentCVIds AND RecordTypeId =: Constants.EPICVERREPORTREQRTID AND Report_Type__c =: Constants.CASE_REPORT_TYPE_VOLUME_ENTITY];
                    if(!epicVerfReportCases.isEmpty()){
                        List<Case> caseToUpdate = new List<Case>();
                        for(Case caseRecord : epicVerfReportCases){
                            caseRecord.Internal_Status__c = Constants.CASE_STATUS_SENT;
                            caseRecord.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_SENT;
                            caseRecord.EPIC_Report_Received_Date__c = System.Today();
                            caseToUpdate.add(caseRecord);
                        }
                        if(!caseToUpdate.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                            update caseToUpdate;
                        }
                    }
                }
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // US 15983 - Creating Transcript Annotation when updating Annotation in Investigation Case
    public static void createTransAnnotation(List<Case> investigationCasesNew, Map<Id,Case> investigationCasesOld){
        try{
            Map<Id, Case> investigationCaseMap = new Map<Id, Case>();
            Set<Id> caseIdSet = new Set<Id>();
            if(RecursiveTriggerHandler.isFirstTimeInvestigation){
                RecursiveTriggerHandler.isFirstTimeInvestigation = false;
                for(Case newCase : investigationCasesNew){
                    if(newCase.Annotation__c != null && newCase.Annotation__c != investigationCasesOld.get(newCase.Id).Annotation__c){
                        investigationCaseMap.put(newCase.Id, newCase);                        
                    }else if(newCase.Annotation__c == null){
                        caseIdSet.add(newCase.Id);
                    }
                }                
                System.debug('investigationCaseMap --- '+investigationCaseMap);
                if(!investigationCaseMap.isEmpty()){
                    List<Transcript_Anotation__c> annotList = new List<Transcript_Anotation__c>();
                    List<Transcript_Anotation__c> transAnnotList = [SELECT Id, Cibis_Transcript_Status__c, Contact__c, Transcript_Case__c, ANNOTATION_TEXT__c FROM Transcript_Anotation__c WHERE Transcript_Case__c =: investigationCaseMap.keySet() WITH SECURITY_ENFORCED];
                    if(!transAnnotList.isEmpty()){          
                        for(Transcript_Anotation__c transAnnotRec : transAnnotList){
                            if(investigationCaseMap.containsKey(transAnnotRec.Transcript_Case__c)){
                                transAnnotRec.Name = investigationCaseMap.get(transAnnotRec.Transcript_Case__c).Annotation__c;
                                transAnnotRec.Cibis_Transcript_Status__c = investigationCaseMap.get(transAnnotRec.Transcript_Case__c).Annotation__c;
                                transAnnotRec.Contact__c = investigationCaseMap.get(transAnnotRec.Transcript_Case__c).ContactId;
                                transAnnotRec.ANNOTATION_TEXT__c = getAnnoationsMdt(transAnnotRec.Transcript_Case__c, investigationCaseMap);
                                transAnnotRec.ACTIVE__c = 'Y';
                                annotList.add(transAnnotRec);
                            }
                        }                        
                    }else{
                        for(Case investigCase : investigationCaseMap.values()){
                            Transcript_Anotation__c transAnnotObj = new Transcript_Anotation__c();
                            transAnnotObj.Name = investigCase.Annotation__c;
                            transAnnotObj.Cibis_Transcript_Status__c = investigCase.Annotation__c;
                            transAnnotObj.Contact__c = investigCase.ContactId;
                            transAnnotObj.Transcript_Case__c = investigCase.Id;
                            transAnnotObj.ANNOTATION_TEXT__c = getAnnoationsMdt(investigCase.Id, investigationCaseMap);
                            transAnnotObj.ACTIVE__c = 'Y';
                            annotList.add(transAnnotObj);
                        }
                    }
                    if(!annotList.isEmpty() && (Transcript_Anotation__c.SObjectType.getDescribe().isCreateable() || Transcript_Anotation__c.SObjectType.getDescribe().isUpdateable())){
                        upsert annotList;
                    }
                }
                if(!caseIdSet.isEmpty()){
                    List<Transcript_Anotation__c> delAnnotList = new List<Transcript_Anotation__c>();
                    List<Transcript_Anotation__c> delTransAnnotList = [SELECT Id, Transcript_Case__c FROM Transcript_Anotation__c WHERE Transcript_Case__c =: caseIdSet WITH SECURITY_ENFORCED];
                    for(Transcript_Anotation__c delTransAnnotRec : delTransAnnotList){
                        delAnnotList.add(delTransAnnotRec);
                    }
                    if(!delAnnotList.isEmpty() && Transcript_Anotation__c.SObjectType.getDescribe().isDeletable()){
                        delete delAnnotList;
                    }
                }
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // US 15983 - Get Annotation Text from Cibis_Annoatation__mdt
    public static String getAnnoationsMdt(String caseId, Map<Id, Case> investigationCaseMap){        
        String annotationText = '';
        String annotation = investigationCaseMap.get(caseId).Annotation__c;
        if(annotation == 'Specialized'){
            annotationText = investigationCaseMap.get(caseId).Annotation_Text_for_Specialized__c;
        }else{
            Map<String, Cibis_Annoatation__mdt> cibisAnnotationMap = CibisUtility.getCibisAnnoations();
            if(cibisAnnotationMap.containsKey(annotation)){
                annotationText = cibisAnnotationMap.get(annotation).ANNOTATION_TEXT__c;
            }
        }
        return annotationText;
    }
    //Update transcript comments on exam registration for PDFButler doc generation
    public static void populateTransComment(Set<Id> usmleCaseIds){
        try{
            Case caseRec = [SELECT Id,ContactId,Transcript_Notes__c,(SELECT Id,ANNOTATION_TEXT__c,SHORT_TEXT__c,SORT_ORDER__c,USMLE_Transcripts_Notes__c FROM Transcript_Anotations__r ORDER BY SORT_ORDER__c ASC) FROM Case WHERE Id IN:usmleCaseIds];
            List<Exam_Registration__c> exams = new List<Exam_Registration__c>();
            for(Exam_Registration__c exam : [SELECT Id, Exam_Status__c, Test_Accommodations__c, Transcript_Comments__c FROM Exam_Registration__c WHERE Exam_Types__c != null AND Exam_Status__c != null AND Exam_Status__c != : Constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW AND Exam_taken_date__c != null AND Applicant__c =:caseRec.ContactId WITH SECURITY_ENFORCED]){
                String comment = '<p>';
                for(Transcript_Anotation__c trans : caseRec.Transcript_Anotations__r){
                    if(trans.USMLE_Transcripts_Notes__c == exam.Id){
                        comment = comment.contains('IRREGULAR BEHAVIOR') ? comment : comment + '<b>IRREGULAR BEHAVIOR</b></p>';
                        comment = trans.SHORT_TEXT__c == null ? comment : comment + '<p>'+trans.SHORT_TEXT__c + '</p>';
                    }
                }
                comment = exam.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INCOMPLETE ? comment + '<p>'+Constants.EXAM_REGISTRATION_EXAM_STATUS_INCOMPLETE + '</p>' : comment;
                comment = exam.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_WITHHELD ? comment + '<p>Score Not Available</p>' : comment;
                comment = exam.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE ? comment + '<p><b>'+Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE+'</b></p>' : comment;
                comment = exam.Test_Accommodations__c == 'Y' ? comment + '<p>'+Constants.REMARKS_TA + '</p>' : comment;
                exam.Transcript_Comments__c = comment;
                exams.add(exam);
            }
            if(!exams.isEmpty() && Exam_Registration__c.SObjectType.getDescribe().isUpdateable()){
                Update exams; 
            }
            String note = '<p><b>';
            for(Transcript_Anotation__c trans : caseRec.Transcript_Anotations__r){
                if(trans.USMLE_Transcripts_Notes__c == null){
                    note = note + 'Note: </b>';
                    note = note + trans.ANNOTATION_TEXT__c + '</p><p><b>';
                }
            }
            if(Case.SObjectType.getDescribe().isUpdateable()){
                caseRec.Transcript_Notes__c = note;
                Update caseRec; 
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // updates case service
    private static void updateCaseService(Case newCase,string recordTypeDevName){
        //String recordtypeDevName = GenericUtilities.getRecordTypeDevNameById(‘Case’,newCase.recordTypeId);    
        string serviceRecName = recordtypeDevName;
        if(recordtypeDevName == Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION || recordtypeDevName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
            serviceRecName = newCase.Service__c + '_' +  recordtypeDevName;
        }
        for(Case_Service_Mapping__mdt serviceRec : [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:serviceRecName LIMIT 1]){
            newCase.Case_Service__c = serviceRec.Case_Service__c;
            newCase.Case_Service_Family__c = serviceRec.Case_Service_Family__c;
            newCase.Case_Service_Line__c = serviceRec.Case_Service_Line__c;
        }
    }
    public static void revocationChanges(List<Case> newCases){
        List<Asset> assetList = new List<Asset>();
        List<Asset> duplicateAssetList = new List<Asset>();
        Map<Id, List<Asset>> assetsOfContact = new Map<Id, List<Asset>>();
        Map<Id, List<case>>casesOfContact = new Map<Id, List<case>>();
        Id applicantContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id investigationCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Investigation Case').getRecordTypeId(); 
        Id ECFMGCerticateAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('ECFMG Certification').getRecordTypeId();          
        set<Id> contactIds = new set<Id>();
        for (case caseRecord: newCases) {
            contactIds.add(caseRecord.contactId);
        }
        List<Contact> contactList = [SELECT Id, 
                                     (SELECT Id, Revocation_Date__c, status, Reinstatement_Date__c,Type__c, RecordtypeId 
                                    FROM Assets WHERE RecordTypeId =: ECFMGCerticateAssetRecordTypeId) 
                                    FROM Contact WHERE Id IN: contactIds AND RecordTypeId =: applicantContactRecordTypeId];            
        if(!contactList.isEmpty()){
            for(contact contact: contactList){
                assetsOfContact.put(contact.Id, contact.assets);
            }
        }
        for(case newcase: newCases){
            if(!assetsOfContact.isEmpty()){
                for(Id contactId: assetsOfContact.keyset()){
                    List<Asset> newAssetList = assetsOfContact.get(contactId);
                    for(asset assetRecord: newAssetList){
                        if(contactId == newcase.contactId && newcase.recordtypeId == investigationCaseRecordTypeId){
                            if(newcase.Committee_Action__c == 'Revocation of ECFMG Certificate' && 
                                newcase.Timeline__c == 'Permanent' && newCase.Revocation_Date__c != NULL && 
                                assetRecord.Type__c == 'ECFMG Certificate' && assetRecord.status == 'Accepted'){                            
                                assetRecord.status = 'Revoked';
                                assetRecord.Revocation_Date__c = newCase.Revocation_Date__c;
                                assetList.add(assetRecord);                                                                                                       
                            }else if(newcase.Committee_Action__c == 'Revocation of ECFMG Certificate' && 
                                newcase.Timeline__c == 'Permanent' && newCase.Revocation_Date__c != NULL && 
                                assetRecord.Type__c == 'Duplicate ECFMG Certificate' && assetRecord.status == 'Accepted'){                            
                                assetRecord.status = 'Revoked';
                                assetRecord.Revocation_Date__c = newCase.Revocation_Date__c;
                                duplicateAssetList.add(assetRecord);                                                                                                       
                            }else if(newcase.Committee_Action__c == 'Revocation of ECFMG Certificate' && 
                                    newcase.Timeline__c != 'Permanent' && newCase.Revocation_Date__c != NULL && 
                                    newCase.Reinstatement_Date__c != NULL && assetRecord.Type__c == 'ECFMG Certificate' && 
                                    assetRecord.status == 'Accepted'){                                
                                assetRecord.status = 'Revoked';
                                assetRecord.Revocation_Date__c = newCase.Revocation_Date__c;
                                assetRecord.Reinstatement_Date__c = newCase.Reinstatement_Date__c;
                                assetList.add(assetRecord);                                                                                   
                            }else if(newcase.Committee_Action__c == 'Revocation of ECFMG Certificate' && 
                                    newcase.Timeline__c != 'Permanent' && newCase.Revocation_Date__c != NULL && 
                                    newCase.Reinstatement_Date__c != NULL && assetRecord.Type__c == 'Duplicate ECFMG Certificate' && 
                                    assetRecord.status == 'Accepted'){                                
                                assetRecord.status = 'Revoked';
                                assetRecord.Revocation_Date__c = newCase.Revocation_Date__c;
                                assetRecord.Reinstatement_Date__c = newCase.Reinstatement_Date__c;
                                duplicateAssetList.add(assetRecord);                                                                                   
                            }
                            
                        }
                    }
                }
            }                                                           
        }
        if(duplicateAssetList.isEmpty()){
            update assetList; 
        }      
        else{
            update duplicateAssetList;
        } 
    }

    public static void updateParentCaseForFCVS(List<Case> credVerCasesNew){        
        if (isFirstTimeFCVS){
            final Integer PREV_VER_ACCEPTED = 2; 
            isFirstTimeFCVS = false;  
            List<Case> lstCases = CaseService.getChildCases(credVerCasesNew[0].ParentId); 
            Case parentCase = new Case(id=credVerCasesNew[0].ParentId); 
            Integer statusCount = 0;  
            String parentCaseStatus;
            String caseStatus = credVerCasesNew[0].Internal_Status__c;                       
            if ((caseStatus == Constants.CASE_STATUS_SUBMITTED_IN_REVIEW)||(caseStatus == Constants.CASE_STATUS_CV_INCOMPLETE)||(caseStatus == Constants.CASE_STATUS_COMPILE_VF_PACKET)||
            (caseStatus == Constants.CASE_STATUS_PENDING_PRINT)||(caseStatus == Constants.CASE_STATUS_PENDING_ADDRESS_REVIEW)||(caseStatus == Constants.CASE_STATUS_PENDING_EMAIL_CREATION)){
                parentCaseStatus = Constants.CASE_STATUS_IN_PROGRESS; 
            }else if(caseStatus == Constants.CASE_STATUS_CV_REJECTED){
                for (Case lstCase:lstCases){
                    if ( !(lstCase.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED)||(lstCase.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED)||(lstCase.Internal_Status__c == Constants.CASE_STATUS_CANCELLED)){
                        lstCase.Internal_Status__c = Constants.CASE_STATUS_CV_REJECTED;                         
                    }
                }           
            }else if((caseStatus == Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED)||(caseStatus == Constants.CASE_STATUS_PARTIAL_PREVIOUSLY_VERIFIED)){
                statusCount = 0;  
                for (Case lstCase:lstCases){                    
                if(lstCase.Internal_Status__c == Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED ){
                        statusCount++; 
                    }                    
                    if (statusCount == lstCases.size()){
                        parentCaseStatus = Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED; 
                    }
                }
            }else if (caseStatus == Constants.CASE_STATUS_SENT_FOR_VERIFICATION){
                statusCount = 0;  
                for (Case lstCase:lstCases){
                if(lstCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION ){
                        statusCount++; 
                    }
                    if (statusCount == lstCases.size()){
                        parentCaseStatus = Constants.CASE_STATUS_SENT_FOR_VERIFICATION; 
                    }
                }
            }else if (caseStatus == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION){
                statusCount = 0;   
                for (Case lstCase:lstCases){
                if(lstCase.Internal_Status__c == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION ){
                        statusCount++; 
                    }
                    if (statusCount == lstCases.size()){
                        parentCaseStatus = Constants.CASE_STATUS_RESENT_FOR_VERIFICATION; 
                    }
                }
            }else if(caseStatus == Constants.CASE_STATUS_CANCELLED){
                for (Case lstCase:lstCases){
                    if ( !(lstCase.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED)||(lstCase.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED)||(lstCase.Internal_Status__c == Constants.CASE_STATUS_CANCELLED)){
                        lstCase.Internal_Status__c = Constants.CASE_STATUS_CANCELLED;                         
                    }
                }           
            }
            else if(caseStatus == Constants.CASE_STATUS_CV_ACCEPTED){                
                statusCount = 0; 
                integer prvAccepted= 0;
                 
                for (Case lstCase:lstCases){
                    if ( (lstCase.Internal_Status__c == Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED)){                        
                        prvAccepted++;  
                    }
                    if(lstCase.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED ){
                        statusCount++; 
                    }
                    if ((statusCount == lstCases.size())|| (prvAccepted == PREV_VER_ACCEPTED)){
                        parentCaseStatus = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;  
                    }
                }           
            }

            if (!String.isBlank(parentCaseStatus)){
                parentCase.Internal_Status__c = parentCaseStatus;                 
                lstCases.Add(parentCase);
            }            
            update lstCases; 
        }
    }

    public static Boolean isParentFCVSCaseType(Id parentCaseId){
        boolean bFCVSCase = false; 
        List<Case> pCase = [select id, recordtype.DeveloperName  from Case where id =: parentCaseId];         
        if (pCase.size() >0){
            String parentRecordTypeName = pCase[0].recordtype.DeveloperName;             
            if (parentRecordTypeName ==  Constants.CASE_RECORD_TYPE_FCVS_REQUEST){
                bFCVSCase = true; 
            }
        }        
        return bFCVSCase; 
    }
    public static void updateParentCaseUsmleNonUsmle(Set<Id> usmleNonUsmleParentIds){
        try{
            List<Case> parentCases = [SELECT Id , Internal_Status__c, ParentId FROM Case WHERE Id IN : usmleNonUsmleParentIds WITH SECURITY_ENFORCED];
            Map<Id, List<Case>> mapParentAllChildCases = new Map<Id, List<Case>>();
            List<Case> parentCasesToUpdate = new List<Case>();
            List<Case> allChildCases = [SELECT Id, Internal_Status__c, ParentId FROM Case WHERE ParentId IN : usmleNonUsmleParentIds WITH SECURITY_ENFORCED];
            for(Case cs : allChildCases){
                if(mapParentAllChildCases.containsKey(cs.ParentId)){
                    mapParentAllChildCases.get(cs.ParentId).add(cs);
                }else{
                    mapParentAllChildCases.put(cs.ParentId, new List<Case>{cs});
                }
            }
            for(Case parentCase : parentCases){
                Integer rejCount = 0;
                for(Case childCase : mapParentAllChildCases.get(parentCase.Id)){
                    if(childCase.Internal_Status__c == Constants.CASE_STATUS_SENT){
                        if(parentCase.Internal_Status__c != Constants.CASE_STATUS_SENT){
                            parentCase.Internal_Status__c = Constants.CASE_STATUS_SENT;
                            parentCasesToUpdate.add(parentCase);
                            break;
                        }
                    }else if(childCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
                        rejCount += 1;
                    }
                }
                if(rejCount > 0 && rejCount == mapParentAllChildCases.get(parentCase.Id).size()){
                    parentCase.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
                    parentCasesToUpdate.add(parentCase);
                }            
            }
            if(!parentCasesToUpdate.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                UPDATE parentCasesToUpdate;
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        } 
    }*/
}