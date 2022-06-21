public with sharing class CredentialVerificationTriggerHandler implements CaseTriggerHandlerInterface{
    final String STATUS_PENDING_CIBIS = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
    final String STATUS_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
    final String STATUS_IN_PROGRESS = Constant_Case__mdt.getInstance('STATUS_IN_PROGRESS').Value__c;
    final String STATUS_CV_REJECTED = Constant_Case__mdt.getInstance('STATUS_CV_REJECTED').Value__c;
    final String STATUS_CV_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c;
    final String STATUS_CANCELLED = Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c;
    final String STATUS_PREV_VERIFIED_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_PREV_VERIFIED_ACCEPTED').Value__c;
    final String STATUS_PARTIAL_PREVIOUSLY_VERIFIED = Constant_Case__mdt.getInstance('STATUS_PARTIAL_PREVIOUSLY_VERIFIED').Value__c;
    final String STATUS_SENT_FOR_VERIFICATION = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c;
    final String STATUS_RESENT_FOR_VERIFICATION = Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c;
    final String STATUS_ENROLLMENT_COMPLETED = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c;
    Map<String,List<sObject>> caseVpMap = CaseTriggerDataInitialize.fetchRTDataSObjectList(Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c,Constant_Data_Key__mdt.getInstance('VERIFICATION_PACKET').Value__c);
    public void beforeInsert(List<Case> newCases){
        system.debug('-------CREDENTIAL VERIFICATION Before Insert Handler-------');
        for(Case newCase:newCases){
            // Updates Case Service
            CaseTriggerUtility.updateCaseService(newCase,CaseTriggerUtility.getServRecName(newCase.Service__c,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c));
            // Update the record available date field
            if(newCase.Internal_Status__c == STATUS_SENT_FOR_VERIFICATION){
                newCase.Record_Available_Date__c = Date.today();
            }
            // Checks if the status is rejected and updates external status to null
            if(newCase.Internal_Status__c == STATUS_CV_REJECTED && (newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c || newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_EICS').Value__c)){
                newCase.External_Status__c = null;
            }else{
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
            }
            // Updates the list of email field to blank;
            if(newCase.Send_Method__c != Constant_Case__mdt.getInstance('SEND_METHOD_EMAIL').Value__c){
                newCase.List_of_emails__c = '';
            }
            // Updates the Applicant_Last_Submission_Date__c field
            CaseTriggerUtility.updateCaseRecordDate(newCase);
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);            
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        system.debug('-------CREDENTIAL VERIFICATION Before Update Handler-------');
        // Fetches the affirmations related
        Map<String,List<Affirmation__c>> affirmationsMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CASE_AFFIRMATION').Value__c);
        // Stores active entity Ids from account2service
        Set<Id> actEntityIds = getEntityIdServ(Constant_other__mdt.getInstance('SERVICE_NAME_CREDENTIAL_VERIFICATION').Value__c);
        for(Case newCase:newCasesMap.values()){
            // Obtains oldcase
            Case oldCase = oldCasesMap.get(newCase.Id);
            // Checks if internal status is changed
            Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
            if(isInternalStatChanged){
                // Update the record available date field
                if(newCase.Internal_Status__c == STATUS_SENT_FOR_VERIFICATION){
                    newCase.Record_Available_Date__c = Date.today();
                }
                // Checks if the status is rejected and updates external status to null
                if(newCase.Internal_Status__c == STATUS_CV_REJECTED && (newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c || newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_EICS').Value__c)){
                    newCase.External_Status__c = null;
                }else{
                    // Updates External Status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                }
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                if(newCase.Internal_Status__c == STATUS_RESENT_FOR_VERIFICATION
                 || newCase.Internal_Status__c == STATUS_SENT_FOR_VERIFICATION){
                    newCase.Certify_the_document__c = null;
                    newCase.Comments_for_not_Certifying__c = null;
                    newCase.Reason_for_not_Certifying__c = null;
                }
            }
            Boolean isAltEntity = checkVerAltEntity(affirmationsMap.containsKey(newCase.Id)?affirmationsMap.get(newCase.Id):new List<Affirmation__c>(),Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c);
            if(Constants.isnotUpdatedbySendMethodFlow && newCase.Entity__c == oldCase.Entity__c
            && newCase.Alternate_Entity__c == oldCase.Alternate_Entity__c
            && newCase.Send_Method__c != oldCase.Send_Method__c && (String.isBlank(newCase.Send_Method_Override_Comments__c)
            || (newCase.Send_Method_Override_Comments__c == oldCase.Send_Method_Override_Comments__c))){
                newCase.addError(Error_Message__mdt.getInstance('Send_Method_Comments').Error_Message__c);
            }
            else if(newCase.Entity__c == oldCase.Entity__c && newCase.Alternate_Entity__c == oldCase.Alternate_Entity__c
            && newCase.Send_Method__c != oldCase.Send_Method__c && newCase.Send_Method__c == Constant_Case__mdt.getInstance('SEND_METHOD_ENTITY_PORTAL').Value__c
            && ((isAltEntity && !actEntityIds.contains(newCase.Alternate_Entity__c)) || (!isAltEntity && !actEntityIds.contains(newCase.Entity__c)))){
                newCase.addError(Error_Message__mdt.getInstance('Send_Method_Entity').Error_Message__c);
            }
            if(newCase.Send_Method__c != Constant_Case__mdt.getInstance('SEND_METHOD_EMAIL').Value__c && newCase.Send_Method__c != oldCase.Send_Method__c){
                newCase.List_of_emails__c = '';
            }
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        system.debug('-------CREDENTIAL VERIFICATION After Insert Handler-------');
        // Collects entity Ids and case Ids to be inserted
        Map<Id,Set<Id>> entityCaseIds = new Map<Id,Set<Id>>();
        // Fetches the affirmations related
        Map<String,List<Affirmation__c>> affirmationsMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CASE_AFFIRMATION').Value__c);
        // Fetches the stored SOQL for child records obtained using parentId field
        Map<String,sObject> parentChildRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
        // Fetches the application for certification records
        String appForcertRec = Constant_Case__mdt.getInstance('REC_TYPE_APPLICATION_FOR_CERTIFICATION').Value__c;
        // Stores the list of Vp records to be updated
        Map<Id,Verification_Packet__c> updateVpRecMap = new Map<Id,Verification_Packet__c>();
        for(Case newCase : newCasesMap.values()){
            Boolean isAltEntity = checkVerAltEntity(affirmationsMap.containsKey(newCase.Id)?affirmationsMap.get(newCase.Id):new List<Affirmation__c>(),Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c);
            Id entityId;
            if(isAltEntity){
                entityId = newCase.Alternate_Entity__c;
            }else{
                entityId = newCase.Entity__c;
            }
            updateAccCaseId(entityCaseIds,entityId,newCase.Id);
            if(String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId) && ((Case)(parentChildRecMap.get(newCase.ParentId))).RecordType.DeveloperName == appForcertRec){
                updateAccCaseId(entityCaseIds,entityId,newCase.parentId);
            }
            if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c){
                invalidateVp(newCase, updateVpRecMap);
            }
        }
        if(!entityCaseIds.isEmpty()){
            CaseTriggerUtility.collectCaseShareAcc(entityCaseIds,new Map<Id,Set<Id>>(),Constant_other__mdt.getInstance('SERVICE_NAME_CREDENTIAL_VERIFICATION').Value__c);
        }
        if(!updateVpRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Verification_Packet__c')){
            CaseTriggerUtility.updateDMLMap(updateVpRecMap.values());
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        system.debug('-------CREDENTIAL VERIFICATION After Update Handler-------');
        try{
            // Getiing the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches the asset records
            Map<String,List<sObject>> assetRecList = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c);
            // Fetches the EPIC Verification report records
            Map<String,sObject> epicVerRepRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CASE_EPIC_VER_REPORT').Value__c);
            // Fetches the contact records
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Fetches the asset2verification packets
            Map<String,List<sObject>> asset2VerPacketList = CaseTriggerDataInitialize.fetchRTDataSObjectList(Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c,Constant_Data_Key__mdt.getInstance('ASSET2VERPACKET').Value__c);
            // Fetches the affirmations related
            Map<String,List<Affirmation__c>> affirmationsMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CASE_AFFIRMATION').Value__c);
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,sObject> parentChildRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template ECFMG Duplicate Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_CASE_STATUS_UPDATE_ON_CV_ACCEPTED').Value__c);
            // Collects entity Ids and case Ids to be inserted
            Map<Id,Set<Id>> entityCaseIds = new Map<Id,Set<Id>>();
            // Collects entity Ids and case Ids to be removed
            Map<Id,Set<Id>> oldEntityCaseIds = new Map<Id,Set<Id>>();
            // Stores already processed parentIds
            Set<Id> processedParentIds = new Set<Id>();
            // Stores the list of case records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            // Stores the asset records to be updated
            Map<Id,Asset> updateAssetRecMap = new Map<Id,Asset>();
            // Stores the map of records that will be processed for updating the asset records
            Map<Id,Case> updCaseAsset = new Map<Id,Case>();
            // Stores the map of records that has to be updated
            Map<Id,Affirmation__c> updateAffirmRecMap = new Map<Id,Affirmation__c>();
            Set<String> verPendingStatus = new Set<String>{STATUS_SENT_FOR_VERIFICATION, Constant_Case__mdt.getInstance('STATUS_INCOMPLETE_RESENT_FOR_VERIFICATIO').Value__c, STATUS_RESENT_FOR_VERIFICATION};
            Set<String> verCompleteStatus = new Set<String>{STATUS_CV_ACCEPTED, STATUS_CV_REJECTED, STATUS_CANCELLED, Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_APPLICANT').Value__c, 
            STATUS_CANCELLED, Constant_Case__mdt.getInstance('STATUS_UNABLE_TO_VERIFY_CRED').Value__c, STATUS_PREV_VERIFIED_ACCEPTED, STATUS_ACCEPTED};
            // Stores the set of Statuses that is checked for FCVS
            Set<String> statProg = new Set<String>{Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_CV_INCOMPLETE').Value__c,Constant_Case__mdt.getInstance('STATUS_COMPILE_VF_PACKET').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c,Constant_Case__mdt.getInstance('STATUS_PENDING_ADDRESS_REVIEW').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_PENDING_EMAIL_CREATION').Value__c};
            String appForcertRec = Constant_Case__mdt.getInstance('REC_TYPE_APPLICATION_FOR_CERTIFICATION').Value__c;
            // Stores the list of Vp records to be updated
            Map<Id,Verification_Packet__c> updateVpRecMap = new Map<Id,Verification_Packet__c>();
            for(Case newCase:newCasesMap.values()){
                // Obtains oldcase
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                // Checks if internal status is accepted and changed
                if(isInternalStatChanged && verPendingStatus.contains(newCase.Internal_Status__c)){
                    CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = newCase.Id,ownerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VERIFICATION_PENDING').Value__c)));
                }
                if(isInternalStatChanged && verCompleteStatus.contains(newCase.Internal_Status__c)){
                    CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = newCase.Id,ownerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VER_PROCESS_COMPLETE').Value__c)));
                }
                if(isInternalStatChanged && String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId) && RecursiveTriggerHandler.isFirstTimeCV==true){
                    RecursiveTriggerHandler.isFirstTimeCV=false;
                    Case parentRec = (Case)parentChildRecMap.get(newCase.ParentId);
                    if(!processedParentIds.contains(newCase.ParentId)){
                        processedParentIds.add(newCase.ParentId);
                        if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c){
                            // processes the child records and checks if all the child records are accepted
                            // and parent's internal status is incomplete, received review to update parent record's internal status
                            // and owner as ECFMG Certification
                            Case parentRecUpdated = CaseTriggerUtility.updParCaseIntStat(newCase,parentRec);
                            if(parentRecUpdated!=null){
                                CaseTriggerUtility.updateRec(updateCaseRecMap,parentRecUpdated);
                            }
                        }
                    }
                    WrapperUpdECFMG wrapUpdEcfmg = new WrapperUpdECFMG();
                    wrapUpdEcfmg.newCase = newCase;
                    wrapUpdEcfmg.parentRec = parentRec;
                    wrapUpdEcfmg.updCaseMap = updateCaseRecMap;
                    wrapUpdEcfmg.conRec = (Contact)contactMap.get(newCase.ContactId);
                    // processes the records to parent record based on internal status and collect case Ids 
                    // that has to be used to update the corresponding Asset record status to rejected/cacelled
                    updCaseAsset.putAll(updParentRecECFMG(wrapUpdEcfmg));
                }
                // if internal status is changed, internal status is not verified, owner id is not verified, owner Id is changed
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_NOT_VERIFIED').Value__c
                && newCase.OwnerId == Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_NOT_VERIFIED').Value__c) 
                && newCase.OwnerId != oldCase.OwnerId && affirmationsMap.containsKey(newCase.Id)){
                    updateNotVerAffirm(updateAffirmRecMap,affirmationsMap.get(newCase.Id));
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_UNABLE_TO_VERIFY_CRED').Value__c
                && asset2VerPacketList.containsKey(newCase.Id)){
                    updateAssets(asset2VerPacketList.get(newCase.Id),updateAssetRecMap);
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == STATUS_CV_ACCEPTED && newCase.Send_Method__c == Constant_Case__mdt.getInstance('SEND_METHOD_WEBSITE').Value__c
                && asset2VerPacketList.containsKey(newCase.Id)){
                    updateAssetsVP(asset2VerPacketList.get(newCase.Id),updateAssetRecMap);
                }
                if(isInternalStatChanged && newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c 
                && newCase.Internal_Status__c == STATUS_CV_ACCEPTED && epicVerRepRecMap.containsKey(newCase.Id)){
                    updEpicVerReport(((Case)(epicVerRepRecMap.get(newCase.Id))).Secondary_Child_Cases__r,updateCaseRecMap);
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE_RESENT_FOR_VERIFICATIO').Value__c 
                && String.isNotBlank(newCase.ContactEmail) && (newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c
                || newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c)){
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    ctDataWrap.sendEmail.add(message);
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == STATUS_SENT_FOR_VERIFICATION 
                && newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c && epicVerRepRecMap.containsKey(newCase.Id)){
                    updEpicVerReportSendDate(((Case)(epicVerRepRecMap.get(newCase.Id))).Secondary_Child_Cases__r,updateCaseRecMap);
                }
                if(newCase.Entity__c != oldCase.Entity__c || newCase.alternate_Entity__c != oldCase.alternate_Entity__c || newCase.OwnerId != oldCase.OwnerId){
                    Boolean isAltEntity = checkVerAltEntity(affirmationsMap.containsKey(newCase.Id)?affirmationsMap.get(newCase.Id):new List<Affirmation__c>(),Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c);
                    Id entityId;
                    Id oldEntityId;
                    if(isAltEntity){
                        entityId = newCase.Alternate_Entity__c;
                        if(newCase.Alternate_Entity__c != oldCase.Alternate_Entity__c && !String.isEmpty(oldCase.Alternate_Entity__c)){
                            oldEntityId = oldCase.Alternate_Entity__c;
                        }
                    }else{
                        entityId = newCase.Entity__c;
                        if(newCase.Entity__c != oldCase.Entity__c && !String.isEmpty(oldCase.Entity__c)){
                            oldEntityId = oldCase.Entity__c;
                        }
                    }
                    updateAccCaseId(entityCaseIds,entityId,newCase.Id);
                    if(String.isNotBlank(oldEntityId)){
                        updateAccCaseId(oldEntityCaseIds,oldEntityId,newCase.Id);
                    }
                    if(String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId) && ((Case)parentChildRecMap.get(newCase.ParentId)).RecordType.DeveloperName == appForcertRec){
                        updateAccCaseId(entityCaseIds,entityId,newCase.parentId);
                        if(String.isNotBlank(oldEntityId)){
                            updateAccCaseId(oldEntityCaseIds,oldEntityId,newCase.parentId);
                        }
                    }
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_CLOSED_NOT_AUTHENTIC').Value__c){
                    if(assetRecList.containsKey(newCase.Id)){
                        updateAssetNotAuth(assetRecList.get(newCase.Id),updateAssetRecMap);
                    }
                    if(affirmationsMap.containsKey(newCase.Id)){
                        updateAffirmNotAuth(updateAffirmRecMap,affirmationsMap.get(newCase.Id));
                    }
                }
                if(isInternalStatChanged && String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId)){
                    Case parentRec = (Case)parentChildRecMap.get(newCase.ParentId);
                    Boolean isFCVS = parentRec.RecordType.DeveloperName == Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c;
                    // If the internal status is submitted in review, CV incomplete, compile VF packet, etc
                    // and record type is FCVS Request, update the parent Record's status as In progress
                    if(statProg.contains(newCase.Internal_Status__c) && isFCVS && parentRec.Internal_Status__c != STATUS_IN_PROGRESS){
                        parentRec.Internal_Status__c = STATUS_IN_PROGRESS;
                        CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_IN_PROGRESS));
                    }
                    else if(isFCVS){
                        CaseTriggerUtility.updChildCaseFCVS(newCase,parentRec,updateCaseRecMap);
                    }
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c){
                    invalidateVp(newCase, updateVpRecMap);
                }
            }
            if(!entityCaseIds.isEmpty() || !oldEntityCaseIds.isEmpty()){
                CaseTriggerUtility.collectCaseShareAcc(entityCaseIds,oldEntityCaseIds,Constant_other__mdt.getInstance('SERVICE_NAME_CREDENTIAL_VERIFICATION').Value__c);
            }
            if(!updCaseAsset.isEmpty()){
                updateAssetRej(updCaseAsset.values(),assetRecList,updateAssetRecMap);
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
            if(!updateAssetRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.updateDMLMap(updateAssetRecMap.values());
            }
            if(!updateAffirmRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Affirmation__c')){
                CaseTriggerUtility.updateDMLMap(updateAffirmRecMap.values());
            }
            if(!updateVpRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Verification_Packet__c')){
                CaseTriggerUtility.updateDMLMap(updateVpRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates the child epic verification report reocords with send and request sent dates as today.
    void updEpicVerReportSendDate(List<Case> epicVerReportList,Map<Id,Case> updateCaseRecMap){
        try{
            for(Case caseRec : epicVerReportList){            
                if(caseRec.First_Verification_Request_Sent_Date__c == null){
                    caseRec.Verification_Request_Send_Date__c = Date.today();
                    caseRec.First_Verification_Request_Sent_Date__c = Date.today();
                    CaseTriggerUtility.updateRec(updateCaseRecMap, new Case(Id = caseRec.Id,First_Verification_Request_Sent_Date__c = Date.today(),Verification_Request_Send_Date__c = Date.today()));
                }else{
                    caseRec.Verification_Request_Send_Date__c = Date.today();
                    CaseTriggerUtility.updateRec(updateCaseRecMap, new Case(Id = caseRec.Id,Verification_Request_Send_Date__c = Date.today()));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates the child epic verification report reocords with status as sent for volume report when the case status is changed to CV accepted
    void updEpicVerReport(List<Case> epicVerReportList,Map<Id,Case> updateCaseRecMap){
        try{
            for(Case caseRec : epicVerReportList){
                if(caseRec.Report_Type__c == Constant_Case__mdt.getInstance('REPORT_TYPE_VOLUME_ENTITY').Value__c){
                    caseRec.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
                    caseRec.EPIC_Report_Status__c = Constant_Case__mdt.getInstance('EPIC_REPORT_STATUS_REPORT_SENT').Value__c;
                    caseRec.EPIC_Report_Received_Date__c = System.Today();
                    CaseTriggerUtility.updateRec(updateCaseRecMap, new Case(Id = caseRec.Id,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c,EPIC_Report_Status__c = Constant_Case__mdt.getInstance('EPIC_REPORT_STATUS_REPORT_SENT').Value__c,EPIC_Report_Received_Date__c = System.Today()));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // process the records if the internal status is cancelled/rejected/accepted and service is ECFMG Certification
    Map<Id,Case> updParentRecECFMG(WrapperUpdECFMG wrapUpdEcfmg){
        try{
            Case newCase = wrapUpdEcfmg.newCase;
            Case parentRec = wrapUpdEcfmg.parentRec;
            List<Case> childRecList = wrapUpdEcfmg.parentRec.Cases;
            Map<Id,Case> updCaseMap = wrapUpdEcfmg.updCaseMap;
            Contact conRec = wrapUpdEcfmg.conRec;
            // Stores the map of records that will be used to update asset
            Map<Id,Case> updCaseAsset = new Map<Id,Case>();
            // Stores the set of statuses that is checked to assign the same internal status as child
            Set<String> rejStatus = new Set<String>{STATUS_CV_REJECTED,Constant_Case__mdt.getInstance('STATUS_EXPIRED').Value__c};
            // Stores the set of Statuses that is used to check if the status is available to assign the child cases internal status as Rejected
            Set<String> statusNotEqRej = new Set<String>{STATUS_CV_ACCEPTED,STATUS_CV_REJECTED,STATUS_CANCELLED,STATUS_SENT_FOR_VERIFICATION
            ,STATUS_PREV_VERIFIED_ACCEPTED};
            Set<String> statusEqRej = new Set<String>{Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_CV_INCOMPLETE').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_RESUBMITTED_PENDING_REVIEW').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_COMPILE_VF_PACKET').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_PENDING_EMAIL_CREATION').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_PENDING_ADDRESS_REVIEW').Value__c};
            // Stores the set of statuses that is used to check if the status available to assign the child cases internal status as Cancelled
            Set<String> statusNotEqCan = new Set<String>{STATUS_CV_ACCEPTED
                ,STATUS_CV_REJECTED
                ,STATUS_CANCELLED
                ,STATUS_PREV_VERIFIED_ACCEPTED};
            Set<String> statusEqCan = new Set<String>{STATUS_SENT_FOR_VERIFICATION
                ,STATUS_RESENT_FOR_VERIFICATION
                ,Constant_Case__mdt.getInstance('STATUS_PENDING_VER_REVIEW').Value__c
                ,Constant_Case__mdt.getInstance('STATUS_VERIFICATION_IN_REVIEW').Value__c};
            if(newCase.Service__c == Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c){
                if(newCase.Internal_Status__c == STATUS_SENT_FOR_VERIFICATION || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_POSTED_TO_ENTITY_PORTAL').Value__c){
                    parentRec.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_CV').Value__c;
                    updCaseMap.put(newCase.ParentId,new Case(Id = newCase.ParentId,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_CV').Value__c));
                }
                if(rejStatus.contains(newCase.Internal_Status__c) || newCase.Internal_Status__c.contains(STATUS_CANCELLED)){
                    String parentStatus = newCase.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED ? Constants.CASE_STATUS_REJECTED : newCase.Internal_Status__c.contains(Constants.CASE_STATUS_CANCELLED) ? Constants.CASE_STATUS_CANCELLED : newCase.Internal_Status__c;
                    updCaseMap.put(newCase.ParentId,new Case(Id = newCase.ParentId,Internal_Status__c = parentStatus));
                    updCaseAsset.put(newCase.ParentId,new Case(Id = newCase.ParentId,Internal_Status__c = parentStatus));
                    updCaseAsset.put(newCase.Id,new Case(Id = newCase.Id,Internal_Status__c = newCase.Internal_Status__c));
                    for(Case caseRec : childRecList){
                        if(caseRec.Service__c == Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c){
                            String status = '';
                            if(!statusNotEqRej.contains(caseRec.Internal_Status__c) && statusEqRej.contains(caseRec.Internal_Status__c)){
                                caseRec.Internal_Status__c = STATUS_CV_REJECTED;
                                status = caseRec.Internal_Status__c;
                            }else if(!statusNotEqCan.contains(caseRec.Internal_Status__c) && statusEqCan.contains(caseRec.Internal_Status__c)){
                                caseRec.Internal_Status__c = STATUS_CANCELLED;
                                status = caseRec.Internal_Status__c;
                            }
                            if(String.isNotBlank(status)){
                                updCaseMap.put(caseRec.Id,new Case(Id = caseRec.Id,Internal_Status__c = status));
                                updCaseAsset.put(caseRec.Id,new Case(Id = caseRec.Id,Internal_Status__c = status));
                            }
                        }
                    }
                }
                if(newCase.Internal_Status__c == STATUS_CV_ACCEPTED || newCase.Internal_Status__c == STATUS_PREV_VERIFIED_ACCEPTED){
                    Boolean updAccFlag = true;
                    for(Case caseRec : childRecList){
                        if(caseRec.Internal_Status__c != STATUS_CV_ACCEPTED && caseRec.Internal_Status__c != STATUS_PREV_VERIFIED_ACCEPTED){
                            updAccFlag = false;
                            break;
                        }
                    }
                    if(updAccFlag && conRec != null){
                        if(conRec.is_CIBIS_Origin__c && parentRec.Internal_Status__c != STATUS_ACCEPTED){
                            parentRec.Internal_Status__c = STATUS_ACCEPTED;
                            updCaseMap.put(newCase.ParentId,new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_ACCEPTED));
                        }else if(parentRec.Internal_Status__c != STATUS_PENDING_CIBIS){
                            parentRec.Internal_Status__c = STATUS_PENDING_CIBIS;
                            updCaseMap.put(newCase.ParentId,new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_PENDING_CIBIS));
                        }
                    }
                }
            }
            return updCaseAsset;
        }catch(Exception ex){
            throw ex;
        }
    }
    // checks whether verify with alternate entity is checked for the correspondigetEntityIdServng affirmation
    // There will be only one affirmation per affirmation record type
    Boolean checkVerAltEntity(List<Affirmation__c> affirmationList, String recType){
        try{
            for(Affirmation__c affRec:affirmationList){
                if(affRec.RecordType.DeveloperName == recType && affRec.Verify_with_Alternate_Entity__c){
                    return true;
                }
            }
            return false;
        }catch(Exception ex){
            throw ex;
        }
    }
    // fetches the list of Entity Ids which are active based on service passed
    Set<Id> getEntityIdServ(String service){
        try{
            // Fetches the stored SOQL for Account2Service obtained using entity/alternate Ids
            Map<String,List<sObject>> acc2SerMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ACCOUNT2SERVICE').Value__c);
            // Collects active account Ids
            Set<Id> activeEntityIds = new Set<Id>();
            for(String accId:acc2SerMap.keySet()){
                for(sObject acc2ser:acc2SerMap.get(accId)){
                    Account2Service__c acc2serRec = (Account2Service__c)acc2ser;
                    if(acc2serRec.Service__r.Name == service && acc2serRec.Active__c){
                        activeEntityIds.add(acc2serRec.Account__r.Id);
                    }
                }
            }
            return activeEntityIds;
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates affirmation records whose cases are not verified
    void updateNotVerAffirm(Map<Id,sObject> updateRecMap,List<Affirmation__c> affirmationRecs){
        try{
            for(Affirmation__c affirmRec:affirmationRecs){
                if(affirmRec.RecordType.DeveloperName == Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_NOT_VERIFIED').Value__c 
                && String.isNotBlank(affirmRec.Not_Verified_Next_Step__c)){
                    affirmRec.Not_Verified_Next_Step__c = null;
                    affirmRec.Comments__c = null;
                    affirmRec.Status__c = STATUS_IN_PROGRESS;
                    CaseTriggerUtility.updateRec(updateRecMap,(new Affirmation__c(Id = affirmRec.Id,Not_Verified_Next_Step__c = null,Comments__c = null,Status__c = STATUS_IN_PROGRESS)));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates affirmation records whose cases are not authentic
    void updateAffirmNotAuth(Map<Id,sObject> updateRecMap,List<Affirmation__c> affirmationRecs){
        try{
            for(Affirmation__c affirmRec:affirmationRecs){
                if((affirmRec.RecordType.DeveloperName == Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_VERIFICATION_REVIEW').Value__c 
                    || affirmRec.RecordType.DeveloperName == Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c)
                   && affirmRec.Status__c != Constant_Affirmation__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c){
                    affirmRec.Status__c = Constant_Affirmation__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c;
                    CaseTriggerUtility.updateRec(updateRecMap,(new Affirmation__c(Id = affirmRec.Id,Status__c = Constant_Affirmation__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c)));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates asset based on asset2verification records
    void updateAssets(List<asset2Verification__c> asset2VerList, Map<Id,Asset> updateAssetRecMap){
        try{
            for(asset2Verification__c asset2Ver:asset2VerList){
                if(asset2Ver.Verification_Packet__r.Is_Active__c && (asset2Ver.Document_Type__c == Constant_other__mdt.getInstance('ASSET2VER_DOCTYPE_SOURCE').Value__c 
                || (asset2Ver.Document_Type__c).startsWith('Returned')) && asset2Ver.Asset__r.Status != Constant_Asset__mdt.getInstance('STATUS_UNVERIFIED').Value__c){
                    CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = asset2Ver.Asset__c,Status = Constant_Asset__mdt.getInstance('STATUS_UNVERIFIED').Value__c));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates the asset records based on asset2verification packets for Send method as website
    void updateAssetsVP(List<asset2Verification__c> asset2VerList, Map<Id,Asset> updateAssetRecMap){
        try{
            final String assetTypeOnlVerCovLet = 'Online Verification Cover Letter';
            final String assetTypeVerForm = 'Verification Form';
            final String assetNameOnlVer = 'Online Verification';
            final String assetNameAccOnlVer = 'Accepted Online Verification';
            Set<Id> assetProcessed = new Set<Id>();
            for(asset2Verification__c asset2Ver:asset2VerList){
                if(!assetProcessed.contains(asset2Ver.Asset__c)){
                    if(asset2Ver.Asset__r.RecordType.DeveloperName == Constant_Asset__mdt.getInstance('RECORD_TYPE_VERIFICATION').Value__c 
                    && asset2Ver.Asset__r.Name == assetTypeOnlVerCovLet && asset2Ver.Asset__r.Type__c == assetTypeOnlVerCovLet){
                        assetProcessed.add(asset2Ver.Asset__c);
                        CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = asset2Ver.Asset__c,Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c));
                    }else if(asset2Ver.Asset__r.RecordType.DeveloperName == Constant_Asset__mdt.getInstance('RECORD_TYPE_VERIFICATION').Value__c 
                    && asset2Ver.Asset__r.Name == assetNameOnlVer && asset2Ver.Asset__r.Type__c == assetNameOnlVer){
                        assetProcessed.add(asset2Ver.Asset__c);
                        CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = asset2Ver.Asset__c,Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c,Name = assetNameAccOnlVer,Type__c = assetNameAccOnlVer));
                    }else if(asset2Ver.Asset__r.RecordType.DeveloperName == Constant_Asset__mdt.getInstance('RECORD_TYPE_CREDENTIAL').Value__c){
                        assetProcessed.add(asset2Ver.Asset__c);
                        CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = asset2Ver.Asset__c,Status = Constant_Asset__mdt.getInstance('STATUS_VERIFIED').Value__c
                        ,Name = Constant_Asset__mdt.getInstance('STATUS_VERIFIED').Value__c+' '+asset2Ver.Asset__r.Case__r.Document_Type__c, Type__c = asset2Ver.Asset__r.Case__r.Document_Type__c));
                    }
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates asset status for CV closed - Not Authentic
    void updateAssetNotAuth(List<Asset> assetList,Map<Id,Asset> updateAssetRecMap){
        try{
            Set<String> nameAsset = new Set<String>{Constant_Asset__mdt.getInstance('NAME_RETURNED_VERIFICATION_FORM').Value__c
            ,Constant_Asset__mdt.getInstance('NAME_CREDENTIAL_REQUEST').Value__c,Constant_Asset__mdt.getInstance('NAME_SUPPORTING_DOCUMENTS').Value__c
            ,Constant_Asset__mdt.getInstance('NAME_RETURNED_SUPPORTING_DOCUMENTS').Value__c};
            for(Asset assetRec:assetList){
                if(String.isNotBlank(assetRec.Name) && assetRec.status != Constant_Asset__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c && (nameAsset.contains(assetRec.Name) || (assetRec.Name).startsWith('Returned'))){
                    assetRec.status = Constant_Asset__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c;
                    CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = assetRec.Id,Status = Constant_Asset__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c));
                }else if(String.isNotBlank(assetRec.Name) && (assetRec.Name == Constant_Asset__mdt.getInstance('NAME_DOCUMENT').Value__c
                || assetRec.Name == Constant_Asset__mdt.getInstance('NAME_DOB_DOCUMENT').Value__c) && assetRec.status != Constant_Asset__mdt.getInstance('STATUS_INACTIVE').Value__c){
                    assetRec.status = Constant_Asset__mdt.getInstance('STATUS_INACTIVE').Value__c;
                    CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = assetRec.Id,Status = Constant_Asset__mdt.getInstance('STATUS_INACTIVE').Value__c));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates the account Ids and Case Ids for sharing
    void updateAccCaseId(Map<Id,Set<Id>> entityCaseIds,Id entityId,Id caseId){
        try{
            if(String.isNotBlank(entityId) && String.isNotBlank(caseId)){
                if(entityCaseIds.containsKey(entityId)){
                    entityCaseIds.get(entityId).add(caseId);
                }else{
                    entityCaseIds.put(entityId,new Set<Id>{caseId});
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates the Asset records based on internal status (rejected/cancelled/expired)
    void updateAssetRej(List<Case> caseRecList,Map<String,List<Asset>> assetRecList,Map<Id,Asset> updateAssetRecMap){
        try{
            for(Case caseRec:caseRecList){
                String assetStatus = getAssetStatus(caseRec);
                if(assetRecList.containsKey(caseRec.Id) && String.isNotBlank(assetStatus)){
                    for(Asset assetRec:assetRecList.get(caseRec.Id)){
                        if(assetRec.Status != assetStatus){
                            assetRec.Status = assetStatus;
                            CaseTriggerUtility.updateRec(updateAssetRecMap,new Asset(Id = assetRec.Id,Status = assetStatus));
                        }
                    }
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // get status value that has to be assigned to asset's status based on case's internal status
    String getAssetStatus(Case caseRec){
        try{
            String assetStatus = '';
            if(caseRec.Internal_Status__c == STATUS_CV_REJECTED || caseRec.Internal_Status__c == STATUS_CANCELLED){
                assetStatus = Constant_Asset__mdt.getInstance('STATUS_REJECTED').value__c;
            }else if(caseRec.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_APPLICANT').Value__c || caseRec.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_ECFMG').Value__c){
                assetStatus = STATUS_CANCELLED;
            }else if(caseRec.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_EXPIRED').Value__c){
                assetStatus = Constant_Case__mdt.getInstance('STATUS_EXPIRED').Value__c;
            }
            return assetStatus;
        }catch(Exception ex){
            throw ex;
        }
    }
    private void invalidateVp(Case newCase, Map<Id,Verification_Packet__c> updateVpRecMap){
        try{
            if(caseVpMap.containsKey(newCase.Id)){
                List<Verification_Packet__c> vps = (List<Verification_Packet__c>)caseVpMap.get(newCase.Id);
                for(Verification_Packet__c vp : vps){
                    if(vp.Is_Active__c = true){
                        vp.Is_Active__c = false;
                        CaseTriggerUtility.updateRec(updateVpRecMap, new Verification_Packet__c(Id = vp.Id, Is_Active__c = false));
                    }
                }
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    class WrapperUpdECFMG{
        Case newCase;
        Case parentRec;
        Map<Id,Case> updCaseMap;
        Contact conRec;
    }
}