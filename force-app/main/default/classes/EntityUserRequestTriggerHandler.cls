public class EntityUserRequestTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_ENTITY_USER_REQUEST  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENTITY_USER_REQUEST').Value__c;
    final Id ENTIUSERREQQUEID = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_USER_REQUEST').Value__c);
    Map<String,List<sObject>> case2ServiceMap = CaseTriggerDataInitialize.fetchRTDataSObjectList(REC_TYPE_ENTITY_USER_REQUEST,Constant_Data_Key__mdt.getInstance('CASE_TO_SERVICE').Value__c);
    // Fetches the Asset records
    Map<String,List<sObject>> assetMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CONTACT').Value__c);
    Id userId = UserInfo.getUserId();
    public Boolean ecfmgAcceptableEntities = false;
    public Boolean isCaseWithPerformanceService = false;
    Set<Id> entityUserReqCaseContactIds = new Set<Id>();
    public void beforeInsert(List<Case> newCases){
        System.debug('-------Entity User Request Handler Before Insert-------');
        for(Case caseIns: newCases){
            //Updates the Case service, Service Line, Service Family fields on case object
            CaseTriggerUtility.updateCaseService(caseIns, REC_TYPE_ENTITY_USER_REQUEST);
             // Updates the Applicant_Last_Submission_Date__c field
             CaseTriggerUtility.updateCaseRecordDate(caseIns);
             // Updates standard case status field to closed/not applicable based on internal status
             CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
             // Updates External Status field for case record
             CaseTriggerUtility.updateCaseExtStatus(caseIns, new Case());
             if(caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
                caseIns.Action_Required__c = True;
                }else{
                    caseIns.Action_Required__c = False;
                }
                assignCaseOwner(caseIns);
            }
    }
    
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        System.debug('-------Entity User Request Handler Before Update-------');
        Map<String,List<sObject>> acc2servicesMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ACCOUNT2SERVICE').Value__c);
        Map<String, sObject> allServiceMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ALLSERVICE').Value__c);
        Map<Id, Set<Id>> entityIdWithServiceIdsMap;
        for(Case caseIns: newCasesMap.values()){ 
            Case oldCase = oldCasesMap.get(caseIns.id);
            if(caseIns.Internal_Status__c != oldCase.Internal_Status__c){                
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(caseIns);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                // Updates External Status field for case record
                CaseTriggerUtility.updateCaseExtStatus(caseIns, oldCase);
                if(caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
                    caseIns.Action_Required__c = True;
                }else{
                    caseIns.Action_Required__c = False;
                }
                assignCaseOwner(caseIns);
            }
            entityIdWithServiceIdsMap = getActiveEntityServiceIds(caseIns, acc2servicesMap);
            if(caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_DUPLICATE_REVIEW_COMPLETE').Value__c && caseIns.Source__c == Constant_Case__mdt.getInstance('CASE_SOURCE_PORTAL_USER').Value__c){
                if(checkExistingService(caseIns, acc2servicesMap)){
                    caseIns.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_COORDINATOR_APPROVAL').Value__c;
                }else{
                     checkNonExistingService(caseIns, oldCase, allServiceMap, entityIdWithServiceIdsMap, case2ServiceMap, ecfmgAcceptableEntities);
                }
            }
            if(caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_DUPLICATE_REVIEW_COMPLETE').Value__c && caseIns.Source__c == Constant_Case__mdt.getInstance('CASE_SOURCE_COORDINATOR').Value__c){
                Map<Id, Asset> conIdWithAssetMap = getAssetIfUserSig(assetMap);
                updateStatusIfCoordinator(caseIns, allServiceMap, case2ServiceMap, conIdWithAssetMap);
            }
         }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            System.debug('-------Entity User Request Handler After Insert-------');
            for(Case caseIns: newCasesMap.values()){
                    if(case2ServiceMap.containsKey(caseIns.Id)){                   
                        popAccCaseService(case2ServiceMap.get(caseIns.Id), caseIns, new Case());                           
                    }
            }
        }
        catch(Exception ex){
            throw ex;
        }   
    }
    
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            System.debug('-------Entity User Request Handler After Update-------');
            Map<String,List<sObject>> case2ServiceMap = CaseTriggerDataInitialize.fetchRTDataSObjectList(REC_TYPE_ENTITY_USER_REQUEST,Constant_Data_Key__mdt.getInstance('CASE_TO_SERVICE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Obtains email template ECFMG Duplicate Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('ENTITY_USER_REQUEST_REJECTED').Value__c);
            // Map of Id and sObject to store the records to be updated
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches the stored SOQL for Contact
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            for(Case caseIns: newCasesMap.values()){
                    Case oldIns = oldCasesMap.get(caseIns.Id);
                    // Checks if internal status is changed
                    Boolean isInternalStatChanged = caseIns.Internal_Status__c != oldIns.Internal_Status__c;
                    if(case2ServiceMap.containsKey(caseIns.Id)){
                        if(caseIns.Entity__c != oldIns.Entity__c){
                            popAccCaseService(case2ServiceMap.get(caseIns.Id), caseIns, oldIns);   
                        }                      
                    }
                    if(isInternalStatChanged && caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c){
                        CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                        sendMailWrap.caseRec = caseIns;
                        sendMailWrap.addr = addr;
                        sendMailWrap.emailTemplate = emailTempRec;
                        sendMailWrap.con = (Contact)contactMap.get(caseIns.contactId);
                        //sendMailWrap.con = caseIns.Contact;
                        Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                        ctDataWrap.sendEmail.add(message);
                    }
                    if(isInternalStatChanged && caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
                        getAssetAttachments(caseIns.Id);
                    }
            }
        }
        catch(Exception ex){
            throw ex;
        }   
    }
    class PopAccCaseServiceWrapper{
        string serviceName{get;set;}        
        Id entityId {get;set;}
        Id oldEntityId {get;set;}
        Id caseId {get;set;}
    }
    //Populate the service from case2service records
    void popAccCaseService(List<case2service__c> casServiceList, Case newCase, Case oldCase){ 
        try{
            if(!casServiceList.isEmpty()){
                for(case2service__c entUserCs : casServiceList){
                    PopAccCaseServiceWrapper accCaseServiceWrapIns = new PopAccCaseServiceWrapper();
                        if(entUserCs.Service__r.Name != null){
                            accCaseServiceWrapIns.serviceName = entUserCs.Service__r.Name;
                        }
                        if(entUserCs.Case__c != null ){
                            accCaseServiceWrapIns.caseId = entUserCs.Case__c;
                        } 
                        if(newCase.Entity__c <> null){
                            accCaseServiceWrapIns.entityId = newCase.Entity__c;
                        }   
                        if(oldCase.Entity__c <> null){
                            accCaseServiceWrapIns.oldEntityId = oldCase.Entity__c;
                        }
                        if(oldCase == null){
                            CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{accCaseServiceWrapIns.entityId=>new Set<Id>{accCaseServiceWrapIns.caseId}}, new Map<Id,Set<Id>>(), accCaseServiceWrapIns.serviceName);                               
                        }else{
                            CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{accCaseServiceWrapIns.entityId=>new Set<Id>{accCaseServiceWrapIns.caseId}}, new Map<Id,Set<Id>>{accCaseServiceWrapIns.oldEntityId=>new Set<Id>{accCaseServiceWrapIns.caseId}}, accCaseServiceWrapIns.serviceName);                               
                        }   
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }  
    }
    void assignCaseOwner(Case caseIns){
        try{            
            if(caseIns.OwnerId != userId && caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c){
                caseIns.OwnerId = userId;
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    Boolean checkExistingService(Case entityUserRequestCase, Map<String,List<sObject>> acc2SerListMap){
        try{
            List<Account2Service__c> existingServicesForEntityList = new List<Account2Service__c>();
            for(Id accId : acc2SerListMap.keySet()){
                for(sObject acc2SerRec : acc2SerListMap.get(accId)){
                    Account2Service__c acc2ServiceVal = (Account2Service__c)acc2SerRec;
                    if(String.isNotBlank(entityUserRequestCase.Service_Name__c) && acc2ServiceVal.Service__c == entityUserRequestCase.Service_Name__c){
                        existingServicesForEntityList.add(acc2ServiceVal);
                        return existingServicesForEntityList.size() > 0;
                    }
                }
            }
            return false;
        }
        catch(Exception ex){
            throw ex;
        }        
    }
    public void checkNonExistingService(Case entityUserRequestCase, Case oldCase , Map<String, sObject> serviceIdServiceMap, Map<Id, Set<Id>> activeEntityServicesMap, Map<String,List<sObject>> caseIdCase2ServiceMap, Boolean ecfmgAcceptableEntities){
        try{
            Id performanceDataServiceId = null,
            enrollmentVerificationServiceId = null,
            credentialReviewServiceId = null;
        
            // loop to get ids of services to be compared later
            for(String serviceId : serviceIdServiceMap.keySet()){
                sObject serviceObj = serviceIdServiceMap.get(serviceId);
                    Service__c s = (Service__c)serviceObj;
                    if(s.Name == Constants.SERVICE_NAME_PERFORMANCE_DATA){
                        performanceDataServiceId = s.id;
                    }
                    if(s.Name == Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION){
                        enrollmentVerificationServiceId = s.id;
                    }
                    if(s.Name == Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION){
                        credentialReviewServiceId = s.id;
                    }
            }
            for(Id caseId : caseIdCase2ServiceMap.keySet()){
                for(sObject case2ServiceRec : caseIdCase2ServiceMap.get(caseId)){
                    Case2Service__c case2serRec = (Case2Service__c)case2ServiceRec;
                    if(performanceDataServiceId != null && caseId == entityUserRequestCase.Id && String.isNotBlank(case2serRec.Service__c) &&  case2serRec.Service__c != performanceDataServiceId){
                        entityUserRequestCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_NEW_SERVICE').Value__c;
                    }
                    if(caseId == entityUserRequestCase.Id && case2serRec.Service__c == performanceDataServiceId){
                        isCaseWithPerformanceService = true;
                        entityUserRequestCase.Deficiency_Reason_RTF__c = '';
                        checkEvAndCrService(entityUserRequestCase, activeEntityServicesMap, enrollmentVerificationServiceId, credentialReviewServiceId, ecfmgAcceptableEntities);
                    }
                    invokePDFButlerIfPerformDataService(entityUserRequestCase , oldCase, serviceIdServiceMap, isCaseWithPerformanceService);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    Map<Id, Set<Id>> getActiveEntityServiceIds(Case entityUserRequestCase, Map<String,List<sObject>> acc2SerListMap){
        try{
            Map<Id, Set<Id>> accIdWithServiceIdsMap = new Map<Id, Set<Id>>();
            for(Id accId : acc2SerListMap.keySet()){
                for(sObject acc2SerRec : acc2SerListMap.get(accId)){
                    Account2Service__c acc2ServiceVal = (Account2Service__c)acc2SerRec;
                    if(String.isNotBlank(entityUserRequestCase.Entity__c) && acc2ServiceVal.Account__c == entityUserRequestCase.Entity__c){
                        if(acc2ServiceVal.Account__r.ECFMG_Acceptable__c){
                            ecfmgAcceptableEntities = true;
                        }
                        if(accIdWithServiceIdsMap.containsKey(entityUserRequestCase.Entity__c)){
                            accIdWithServiceIdsMap.get(entityUserRequestCase.Entity__c).add(acc2ServiceVal.Service__c);
                        }else{
                        accIdWithServiceIdsMap.put(entityUserRequestCase.Entity__c, new Set<Id>{acc2ServiceVal.Service__c});
                        }
                    }
                }
            }
            return accIdWithServiceIdsMap;
        }
        catch(Exception ex){
            throw ex;
        }        
    }
    void checkEvAndCrService(Case entityUserRequestCase, Map<Id, Set<Id>> activeEntityServicesMap, Id enrollmentVerificationServiceId, Id credentialReviewServiceId, Boolean isEcfmgAcceptableEntities){
        try{
            Boolean hasEVService, hasCRService;        
            // check if entity has active enrollment verification service
            if(activeEntityServicesMap.containsKey(entityUserRequestCase.Entity__c) && activeEntityServicesMap.get(entityUserRequestCase.Entity__c).contains(enrollmentVerificationServiceId)){
                hasEVService = true;
            } 
            else{
                hasEVService = false;
                entityUserRequestCase.Deficiency_Reason_RTF__c += Constant_Case__mdt.getInstance('CASE_EV_SERVICE_DEF_REASON').Value__c;
            }
            // check if entity has active Credential Verification service
            if(activeEntityServicesMap.containsKey(entityUserRequestCase.Entity__c) && activeEntityServicesMap.get(entityUserRequestCase.Entity__c).contains(credentialReviewServiceId)){
                hasCRService = true;
            } 
            else{
                hasCRService = false;
                entityUserRequestCase.Deficiency_Reason_RTF__c += Constant_Case__mdt.getInstance('CASE_CR_SERVICE_DEF_REASON').Value__c;
            }
            if(!isEcfmgAcceptableEntities){
                entityUserRequestCase.Deficiency_Reason_RTF__c += Constant_Case__mdt.getInstance('CASE_NON_ECFMG_ACC_DEF_REASON').Value__c;
            }    
            if(hasEVService && hasCRService && isEcfmgAcceptableEntities){
                entityUserRequestCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_NEW_SERVICE').Value__c;
            } 
            else{
                entityUserRequestCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    void invokePDFButlerIfPerformDataService(Case newCase, Case oldCase, Map<String, sObject> serviceIdServiceMap, Boolean isPerformanceDataSer){
        try{
            Integer serviceCount = serviceIdServiceMap.values().Size();
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
            Id docConfigIdPIATemplate;
            Id docConfigIdNewServiceTemplate;
            for(cadmus_core__Doc_Config__c docConfigRec : docConfigMap.values()){
                if(docConfigRec.Name == Constant_PDF_Butler__mdt.getInstance('ASSET_TYPE_PIA_TEMPLATE').Value__c){
                    docConfigIdPIATemplate = docConfigRec.Id;
                }
                if(docConfigRec.Name == Constant_PDF_Butler__mdt.getInstance('PDFBUTLER_NEW_SERVICE_TEMPLATE_1').Value__c && serviceCount <= Integer.valueOf(Constant_PDF_Butler__mdt.getInstance('PDF_BUTTLER_NEW_SERVICE_TEMP_FLAG').Value__c)){
                    docConfigIdNewServiceTemplate = docConfigRec.Id;
                }
                else if(docConfigRec.Name == Constant_PDF_Butler__mdt.getInstance('PDFBUTLER_NEW_SERVICE_TEMPLATE_2').Value__c){
                    docConfigIdNewServiceTemplate = docConfigRec.Id;
                }
            }
            if(newCase.Internal_Status__c != oldCase.Internal_Status__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_NEW_SERVICE').Value__c){                
                if(isPerformanceDataSer){
                    CaseTriggerUtility.generateDocHelper(docConfigIdPIATemplate, newCase);
                    CaseTriggerUtility.generateDocHelper(docConfigIdNewServiceTemplate, newCase);
                
                } 
                else{
                    CaseTriggerUtility.generateDocHelper(docConfigIdNewServiceTemplate, newCase);
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    Map<Id, Asset> getAssetIfUserSig(Map<String,List<sObject>> assetMap){
        Map<Id, Asset> conIdWithAssetMap = new Map<Id, Asset>();
        for(String caseId : assetMap.keySet()){
            for(sObject assRec : assetMap.get(caseId)){
                Asset assIns = (Asset)assRec;
                if(assIns.Type__C == Constant_Asset__mdt.getInstance('ASSET_TYPE_USER_SIGNATURE').Value__c && assIns.Status != Constant_Asset__mdt.getInstance('STATUS_MARKED_FOR_DELETION').Value__c){
                    conIdWithAssetMap.put(assIns.ContactId, assIns);
                }
            }
        }
        return conIdWithAssetMap;
    }
    void updateStatusIfCoordinator(Case entityUserRequestCase, Map<String, sObject> serviceIdServiceMap, Map<String, List<sObject>> caseIdCase2ServiceMap, Map<Id, Asset> entityContactSignatureAssetMap){
        Set<Id> requestedCase2ServiceIds = new Set<Id>();
        Boolean signatureRequired = false;
        for(Id caseId : caseIdCase2ServiceMap.keySet()){
            for(sObject case2ServiceRec : caseIdCase2ServiceMap.get(caseId)){
                Case2Service__c case2serRec = (Case2Service__c)case2ServiceRec;
                if(String.isNotBlank(case2serRec.Service__c)){
                    requestedCase2ServiceIds.add(case2serRec.Service__c);
                }
            }
        }
        if(!requestedCase2ServiceIds.isEmpty()){
            for(Id serviceId : requestedCase2ServiceIds){
                sObject serviceObj = serviceIdServiceMap.get(serviceId);
                Service__c servIns = (Service__c)serviceObj;
                if(servIns.Signature_Required__c){
                    signatureRequired = true;
                    break;
                }
            }
        }
        if(signatureRequired){
            if(entityContactSignatureAssetMap.containsKey(entityUserRequestCase.ContactId)){
                entityUserRequestCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_USER_ACCESS').Value__c;
            } 
            else{
                entityUserRequestCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
            }
        } 
        else{
            entityUserRequestCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_USER_ACCESS').Value__c;
        }
    }
    @future(Callout=True)
    public static void getAssetAttachments(Id enUsrReqCaseId){
        GetCommonQueries instance = GetCommonQueries.getInstance();
        // Fetches the stored SOQL for Org wide email address
        Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
        // Fetches the stored SOQL for Email Template
        Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);        
        // Obtains org wide email address
        OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
        // Obtains email template 
        EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('CASE_EMAIL_DEFICIENCY_TEMPLATE').Value__c);
        // Fetches the stored SOQL for Contact
        Map<String, Asset> typeWithAssetMap = new Map<String, Asset>();
        Map<Id,Case> updateCaseAsSentMap = new Map<Id,Case>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        // Map of Id and sObject to store the records to be updated
        CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
        // Fetches the stored wrapper data
        CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
        Case enUsrReqCase = [SELECT Id,ContactId, CaseNumber,Contact.Email, Contact.Name,ContactEmail,Deficiency_Reason_RTF__c,Internal_Status__c,ECFMG_Portal_Case_Url__c FROM Case WHERE Id =: enUsrReqCaseId WITH SECURITY_ENFORCED];
        Contact conRec = [SELECT Id, Name, Email FROM Contact WHERE Id =: enUsrReqCase.ContactId With SECURITY_ENFORCED];
        List<Asset> assetList = [SELECT Id, Type__c, Status, Azure_Storage_URL__c 
                                FROM Asset 
                                WHERE Case__c = :enUsrReqCase.Id 
                                AND Status !=:Constant_Asset__mdt.getInstance('STATUS_OUTDATED').Value__c 
                                AND status != :Constant_Asset__mdt.getInstance('STATUS_MARKED_FOR_DELETION').Value__c 
                                AND (Status = :Constant_Asset__mdt.getInstance('ASSET_STATUS_INCOMPLETE').Value__c OR 
                                Type__c = :Constant_Asset__mdt.getInstance('ASSET_NEW_SERVICE_TEMPLATE').Value__c OR 
                                Type__c = :Constant_Asset__mdt.getInstance('ASSET_PIA_TEMPLATE').Value__c)
                                WITH SECURITY_ENFORCED];
        for(Asset assIns : assetList){
            typeWithAssetMap.put(assIns.Type__c, assIns);
        }
        if(typeWithAssetMap.containsKey(Constant_Asset__mdt.getInstance('ASSET_SIGNED_SERVICE_FORM').Value__c) && typeWithAssetMap.containsKey(Constant_Asset__mdt.getInstance('ASSET_NEW_SERVICE_TEMPLATE').Value__c) 
        && typeWithAssetMap.get(Constant_Asset__mdt.getInstance('ASSET_SIGNED_SERVICE_FORM').Value__c).Status == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
            Asset newSerAsset = typeWithAssetMap.get(Constant_Asset__mdt.getInstance('ASSET_NEW_SERVICE_TEMPLATE').Value__c);
                if(String.isNotBlank(newSerAsset.Azure_Storage_URL__c)){
                    String fileName = newSerAsset.Azure_Storage_URL__c.split('/')[4];
                    attachments.add(CaseTriggerUtility.getAttachment(fileName));
                }
        }
        if(typeWithAssetMap.containsKey(Constant_Asset__mdt.getInstance('ASSET_SIGNED_PIA').Value__c) && typeWithAssetMap.containsKey(Constant_Asset__mdt.getInstance('ASSET_PIA_TEMPLATE').Value__c) 
        && typeWithAssetMap.get(Constant_Asset__mdt.getInstance('ASSET_SIGNED_PIA').Value__c).Status == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
            Asset newPiaAsset = typeWithAssetMap.get(Constant_Asset__mdt.getInstance('ASSET_NEW_SERVICE_TEMPLATE').Value__c);
                if(String.isNotBlank(newPiaAsset.Azure_Storage_URL__c)){
                    String fileName = newPiaAsset.Azure_Storage_URL__c.split('/')[4];
                    attachments.add(CaseTriggerUtility.getAttachment(fileName));
                }
        }
        if(!attachments.isEmpty()){
            CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
            sendMailWrap.caseRec = enUsrReqCase;
            sendMailWrap.addr = addr;
            sendMailWrap.emailTemplate = emailTempRec;
            sendMailWrap.con = conRec;
            Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
            sendEmailForDeficiency(message, attachments, ctDataWrap);
            setInternalStaAsSent(updateCaseAsSentMap, enUsrReqCase);
        }
    }
    static void sendEmailForDeficiency(Messaging.SingleEmailMessage message, List<Messaging.EmailFileAttachment> attachments, CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap){
        message.setFileAttachments(attachments);
        ctDataWrap.sendEmail.add(message);
        Messaging.sendEmail(ctDataWrap.sendEmail);
    }
    static void setInternalStaAsSent(Map<Id,Case> updateCaseAsSentMap, Case enUsrReqCase){
        updateCaseAsSentMap.put(enUsrReqCase.Id, new Case(Id=enUsrReqCase.Id, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c)); 
        if(GenericUtilities.checkIsUpdatable('Case') && !updateCaseAsSentMap.isEmpty()){
            update updateCaseAsSentMap.values();
        }
    }
}