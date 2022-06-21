global with sharing class Actionable_UploadDocumentToAzureBlob implements cadmus_core.AbstractAfterActionable{
    //Abstract method of cadmus_core.AbstractAfterActionable interface
    global void execute(cadmus_core__Actionable__c actionable, Id docConfig, Id objectId, Map<String,Object> inputMap, cadmus_core.ConvertController.ConvertDataModel cdm, cadmus_core.DocGenerationWrapper wrapper){
        List<Case> caseRecord = [SELECT Id, RecordType.DeveloperName, Internal_Status__c FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];     
        if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION){
            uploadEVPaper(objectId, wrapper.response.base64);
        }
        else if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION || caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE){
            uploadECFMGIDFormTemplate(objectId, wrapper.response.base64); // EIF Doc Config
        }
        else if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST){
            handleEntityUserRequest(caseRecord, docConfig, objectId, wrapper); // Refactor method to solve sonarint issue              
        }        
        else if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_NON_USMLE_TRANSCRIPT){
            uploadNonUsmleTranscript(objectId, wrapper.response.base64);
        }
        else if((caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_AUTH_SIGN_LIST)){
            uploadASLGeneratedForm(objectId, wrapper.response.base64);
        }
        else if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION){
            String docConfigName;
            if(docConfig != NULL){
            	cadmus_core__Doc_Config__c configRec = [Select Name from cadmus_core__Doc_Config__c where Id =: docConfig WITH SECURITY_ENFORCED];
            	docConfigName = configRec.Name;
            }
            if(docConfigName == Constants.ASSET_NAME_ENROLLREV_COVER_LETTER){
                uploadEnRevCoverLetter(objectId, wrapper.response.base64);
            }
            else if(caseRecord[0].Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE){
                uploadEnRevDefCoverLet(objectId, wrapper.response.base64);
            }
            else if(caseRecord[0].Internal_Status__c == Constants.CASE_STATUS_NEW){
                uploadEnRevTranscript(objectId, wrapper.response.base64);
                Id docConfigIdCoverLetter = EntityServiceRequestSharingDisabled.getEnrollReverificationCoverLetter();
                PDFButlerCallout calloutClassCoverLetter = new PDFButlerCallout(docConfigIdCoverLetter, caseRecord[0].Id);
                System.enqueueJob(calloutClassCoverLetter);            	
            }
        }
        else if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_FOR_CERT && (caseRecord[0].Internal_Status__c != Constants.CASE_STATUS_EXPIRED && caseRecord[0].Internal_Status__c != Constants.CASE_STATUS_REJECTED)){
            uploadAppForCertSummary(objectId, wrapper.response.base64);
        }
        else if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION ){
            uploadExamApplicationSummary(objectId, wrapper.response.base64);
        }        
        executeRefactor(caseRecord[0], objectId, wrapper.response.base64, docConfig);
    }
    // Method created to resolve cognitive complexity
    global void executeRefactor(Case caseRecord, Id objectId, Blob document, Id docConfig){
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT){
            uploadUsmleTranscript(objectId, document);
        }
        else if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_SCORE_RECHECK){
            uploadScoreRecheckLetter(objectId, document);
        }
        else if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE){
            //Added as part of Bug 20205
            String templateDocConfigId = EntityServiceRequestSharingDisabled.getTemplateDocConfigId(docConfig);
            if(templateDocConfigId == Constants.DOCCONFIG_ECFMGDUPLICATECERT_ID){
                uploadDuplEcfmgCert(objectId, document);
            }
            else if(templateDocConfigId == Constants.DOCCONFIG_ECFMGREPRINTEDCERT_ID){
                uploadRegenRePrintEcfmgDoc(objectId, document);
            }
        }
        else if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION){
            String templateDocConfigId = EntityServiceRequestSharingDisabled.getTemplateDocConfigId(docConfig);
            if(templateDocConfigId == Constants.DOCCONFIG_ECFMGDUPLICATECERT_ID){
                uploadDuplEcfmgCert(objectId, document);
            }
            else if(templateDocConfigId == Constants.DOCCONFIG_ECFMGREPRINTEDCERT_ID){
                uploadRegenRePrintEcfmgDoc(objectId, document);
            }
            else{
                uploadEcfmgCertDoc(objectId, document);
            }
        }
        executeRefactor2(caseRecord, objectId, document, docConfig);
    }
    //method to refactor execute method
    global void executeRefactor2(Case caseRecord, Id objectId, Blob document, Id docConfig){
        String verFormDocConfigId = EntityServiceRequestSharingDisabled.getTemplateDocConfigId(docConfig);
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION){
            if(verFormDocConfigId == Constants.DOCCONFIG_CREDVERFORM_ID){
                uploadVerificationForm(objectId, document);
            }else{
                handleCredVerficationAsset(objectId, document, docConfig, verFormDocConfigId);                              
            }
        }
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE && verFormDocConfigId == Constants.DOCCONFIG_EPIC_EXTRACTION_VERIFICATION_FORM){
            uploadVerificationForm(objectId, document);
        }
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
            handleCredVerficationAsset(objectId, document, docConfig, verFormDocConfigId);
        }
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ATTESTATION){
            if(verFormDocConfigId == Constants.DOCCONFIG_ATTESTATION_FORM){
                uploadAttestationForm(objectId,document);
            }
            else if(verFormDocConfigId == Constants.DOCCONFIG_ATTESTATION_COVER_LETTER){
                uploadAttestationCVLetter(objectId,document);
            }
        } 
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST){
            uploadEpicReport(objectId, document);
        }    
    }
    // Method to create to resolve sonarint issue -- US 15508
    global void handleCredVerficationAsset(Id objectId, Blob document, Id docConfig, String verFormDocConfigId){
        List<Case> caseRecord = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];     
        SET<String> coverLetterConfigIdSet = new SET<String>();
        SET<String> verificationFormConfigIdSet = new SET<String>();
        for(CredentialLangConfigID__mdt credLangConfigId : [SELECT id, CV_ConfigId__c, Form_ConfigId__c FROM CredentialLangConfigID__mdt WHERE active__c = true WITH SECURITY_ENFORCED]){
            CoverLetterConfigIdSet.add(credLangConfigId.CV_ConfigId__c);
            VerificationFormConfigIdSet.add(credLangConfigId.Form_ConfigId__c);
        }
        try{
            if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION){
                if(CoverLetterConfigIdSet.contains(verFormDocConfigId)){
                    uploadVerificationCoverLetter(objectId, document);
                }
                if(VerificationFormConfigIdSet.contains(verFormDocConfigId)){
                    uploadUniversalVerificationForm(objectId, document);
                }
            }
            if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
                if(CoverLetterConfigIdSet.contains(verFormDocConfigId)){
                    uploadMedEduCoverLetter(objectId, document);
                }
                if(VerificationFormConfigIdSet.contains(verFormDocConfigId)){
                    uploadMedEduForm(objectId, document);
                }
            }
        }
        catch(exception e){
            throw new ControllerException(e.getMessage());
        } 
    }
    // Method to create to resolve sonarint issue
    global void handleEntityUserRequest(List<Case> newCases, Id docConfig, Id objectId, cadmus_core.DocGenerationWrapper wrapper) {
        String templateDocConfigId = EntityServiceRequestSharingDisabled.getTemplateDocConfigId(docConfig);
        if(templateDocConfigId == Constants.DOCCONFIGID_PIATEMPLATE) {
            uploadPIATemplate(objectId, wrapper.response.base64);
        } else if(templateDocConfigId == Constants.DOCCONFIGID_NEWSERVICETEMPLATE1 || templateDocConfigId == Constants.DOCCONFIGID_NEWSERVICETEMPLATE2) {
            uploadNewServiceTemplate(newCases, objectId, wrapper.response.base64);
        } 
    }
    //Method to create asset and invoke api callout to azure blob to upload generated EV Paper
    global void uploadEVPaper(Id objectId, Blob document){
        List<Case> evCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(evCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_ENROLLMENT_VERIFICATION;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(evCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', evCase[0].ContactId+'_'+evCase[0].Id+'_Enrollment_Verification_Form', evCase[0].Contact.Email, JSON.serialize(payload), document, 'Enrollment Verification Form');
    }
    //Method to create asset and invoke api callout to azure blob to upload generated ASL Form
    global void uploadASLGeneratedForm(Id objectId, Blob document){
        List<Case> aslCase = [SELECT Id, ContactId, Contact.Email, Entity__c,Entity__r.Id FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(aslCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENTITY_DOCUMENT_DEVNAME;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(aslCase[0].Entity__r.Id);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_SENT;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', aslCase[0].ContactId+'_'+aslCase[0].Id+'_Authorized_Signature_List_Form', aslCase[0].Contact.Email, JSON.serialize(payload), document, 'Enrollment Verification Form');
    }
    //Method to create asset and invoke api callout to azure blob to upload generated ID Form Template // EIF Doc Config
    global void uploadECFMGIDFormTemplate(Id objectId, Blob document){
        List<Case> idCase = [SELECT Id, ContactId, AccountId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(idCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_IDENTITY_VERIFICATION;
        payload.assetName = Constants.ASSET_NAME_ID_FORM_TEMPLATE;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_IDENTITY;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(idCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', idCase[0].ContactId+'_ECFMG_Identification_Form', idCase[0].Contact.Email, JSON.serialize(payload), document, 'ECFMG Identification Form');
    }
    /* @description : Method to create asset and invoke api callout to azure blob to upload Enrollment Verification form */
    global void uploadEnRevTranscript(Id objectId, Blob document){
        List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(userRequestCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_ENROLLMENT_REVERIFICATION ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(userRequestCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', userRequestCase[0].ContactId+'_Enrollment_Re-verification_Form', userRequestCase[0].Contact.Email, JSON.serialize(payload), document, 'Enrollment Re-verification Form');
    }
    /* @description : Method to create asset and invoke api callout to azure blob to upload Deficiency Cover Letter */
    global void uploadEnRevDefCoverLet(Id objectId, Blob document){
        List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(userRequestCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_COVER_LETTER;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(userRequestCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payLoad.assetName = Constants.ASSET_NAME_COVER_LETTER;
        payload.assetStatus = Constants.ASSET_STATUS_APPROVED;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', userRequestCase[0].ContactId+'_Enrollment_Re-verification_Deficiency_Cover_Letter', userRequestCase[0].Contact.Email, JSON.serialize(payload), document, Constants.ASSET_NAME_COVER_LETTER);
    }
    //Method to create asset and invoke api callout to azure blob to upload generated USMLE Transcript
    global void uploadUsmleTranscript(Id objectId, Blob document){
        List<Case> usmleCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(usmleCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_USMLE_TRANSCRIPT ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_SCORE_REPORT;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(usmleCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', usmleCase[0].ContactId+'_USMLE_Transcript', usmleCase[0].Contact.Email, JSON.serialize(payload), document, Constants.ASSET_TYPE_USMLE_TRANSCRIPT);
    }
    //Method to create asset and invoke api callout to azure blob to upload generated Score Recheck Letter
    global void uploadScoreRecheckLetter(Id objectId, Blob document){
        List<Case> srCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(srCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_SCORE_RECHECK_LETTER ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_EXAM_REG;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(srCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_VERIFIED;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', srCase[0].ContactId+'_Score_Recheck_Letter', srCase[0].Contact.Email, JSON.serialize(payload), document, Constants.ASSET_TYPE_SCORE_RECHECK_LETTER);
    }
    /* @description : Method to create asset and invoke api callout to azure blob to upload generated PIA Template */
    global void uploadPIATemplate(Id objectId, Blob document){
        List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];   
        // Payload for PIA Template
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(userRequestCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_PIA_TEMPLATE ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENTITY_DOC;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(userRequestCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
        payload.createFromPB = 'true';
        String fileNamePIA = userRequestCase[0].ContactId+'_PIA_Template';
        // PIA Template - send http request to AzureBlob
        httpCalloutAzureBlob(fileNamePIA, JSON.serialize(payload), document);
    }    
    //Method to create asset and invoke api callout to azure blob to upload generated Appforcert Summary
    global void uploadAppForCertSummary(Id objectId, Blob document){
        List<Case> appForCertCase = [SELECT Id, CaseNumber, ContactId, AccountId, Contact.Email FROM Case WHERE Id = :objectId];        
        String assetName = Constants.ASSET_NAME_APPLICATION_FOR_CERTIFICATION_SUMMARY;
        String assetType = Constants.ASSET_TYPE_APPLICATION_SUMMARY;
        String contactId = String.valueOf(appForCertCase[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevSummaryAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(appForCertCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_APPLICATION_SUMMARY;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_SUMMARY;
        payload.createOrReplace = 'Replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(appForCertCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        payload.assetName = Constants.ASSET_NAME_APPLICATION_FOR_CERTIFICATION_SUMMARY;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', appForCertCase[0].CaseNumber+'_'+'Application_For_Certification_Summary', appForCertCase[0].Contact.Email, JSON.serialize(payload), document, 'Application For Certification Summary');  
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList;
        }
    }
    //Method to create asset and invoke api callout to azure blob to upload generated Exam Application Summary
    global void uploadExamApplicationSummary(Id objectId, Blob document){
        List<Case> examRegCase = [SELECT Id, CaseNumber, ContactId, AccountId, Contact.Email FROM Case WHERE Id = :objectId];        
        String assetName = Constants.ASSET_NAME_EXAM_APPLICATION_SUMMARY;
        String assetType = Constants.ASSET_TYPE_APPLICATION_SUMMARY;
        String contactId = String.valueOf(examRegCase[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevSummaryAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(examRegCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_APPLICATION_SUMMARY;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_SUMMARY;
        payload.createOrReplace = 'Replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(examRegCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        payload.assetName = Constants.ASSET_NAME_EXAM_APPLICATION_SUMMARY;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', examRegCase[0].CaseNumber+'_'+'Exam_Application_Summary', examRegCase[0].Contact.Email, JSON.serialize(payload), document, 'Exam Application Summary');  
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList;
        }
    }
    /* @description : Method to invoke api callout to azure blob to upload generated PIA and New Service Template */
    global static void httpCalloutAzureBlob(String fileName, String payload, Blob document){
        Datetime dt = System.now();
        fileName = fileName + '_' + dt.year() + '-' + dt.month() + '-' + dt.day() + '_' + dt.hour() + '_' + dt.minute() + '_' + dt.second() +'.pdf';
        String jsonStrPIA = CloudStorageController.getRequestHeaders('CREATE_UPDATE', fileName, '', payload);
        Map<String, Object> header = (Map<String, Object>)JSON.deserializeUntyped(jsonStrPIA);
        Http ht = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('PUT');
        httpRequest.setHeader('Content-Length', '0');
        httpRequest.setHeader('x-ms-blob-type', 'BlockBlob');
        httpRequest.setHeader('Content-Type', 'application/pdf');
        httpRequest.setHeader('x-ms-version', '2019-02-02');
        httpRequest.setHeader('x-ms-meta-Payload', payLoad);
        httpRequest.setEndpoint(String.valueOf(header.get('FileUrlWithToken')));
        httpRequest.setBodyAsBlob(document);
        ht.send(httpRequest);
        // Update AzureFileUrl on Asset Object
        CloudStorageController.processResponse(payload, String.valueOf(header.get('FileUrl')));
    }
    /* @description : Method to create asset and invoke api callout to azure blob to upload generated New Service Template */
    global void uploadNewServiceTemplate(List<Case> newCases, Id objectId, Blob document){
        try{
            List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
            PayloadWrapper payload = new PayloadWrapper();
            payload.contactId = String.valueOf(userRequestCase[0].ContactId);
            payload.documentType = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE ;
            payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENTITY_DOC;
            payload.createOrReplace = 'replace';
            payload.caseId = String.valueOf(objectId);
            payload.accountId = String.valueOf(userRequestCase[0].AccountId);
            payload.assetCreationRequired = 'true';
            payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
            payload.createFromPB = 'true';      
            // If Case's Service is Performance Data, uploadPIANewServiceTemplateToAzure method is called.
            MAP<Id, Boolean> casePerformanceDataMap = new MAP<Id, Boolean>();
            casePerformanceDataMap = CaseTriggerHelper.casePerformanceDataMapCheck(newCases);
            if(!casePerformanceDataMap.isEmpty() && casePerformanceDataMap.containsKey(objectId) && casePerformanceDataMap.get(objectId)){            
                uploadPIANewServiceTemplateToAzure(userRequestCase[0].ContactId+'_New_Service_Template', JSON.serialize(payload), document, objectId, userRequestCase);
            }else{
                uploadGeneratedDocToAzure('', userRequestCase[0].ContactId+'_New_Service_Template', userRequestCase[0].Contact.Email, JSON.serialize(payload), document, 'New Service Template Form');
            } 
        }
        catch(exception e){
            throw new ControllerException(e.getMessage());
        }       
    }
    //Method to upload generated document to azure blob via callout and send email to applicant
    global void uploadPIANewServiceTemplateToAzure(String fileNameNewService, String payloadNewService,Blob documentNewService,Id objectId,List<Case> userRequestCase){        
        try{
            String caseId = userRequestCase[0].Id;
            String contactId = userRequestCase[0].ContactId;
            String accountId = userRequestCase[0].AccountId;
            // New Service Template - send http request to AzureBlob
            httpCalloutAzureBlob(fileNameNewService, payloadNewService, documentNewService);       
            // Update Case Status
            Case newCaseObj = new Case();
            newCaseObj.Id = caseId;
            newCaseObj.Internal_Status__c = Constants.CASE_STATUS_SENT;   
            if(String.isNotBlank(newCaseObj.Id) && Schema.sObjectType.Case.isUpdateable()){
                update newCaseObj;
            }
        }
        catch(exception e){
            throw new ControllerException(e.getMessage());
        } 
    }
    //Method to upload generated document to azure blob via callout and send email to applicant
    @future(callout=true)
    global static void uploadGeneratedDocToAzure(String assetId, String fileName, String mailId, String payload, Blob document, String subject){
        try{
            Datetime dt = System.now();
            fileName = fileName + '_' + dt.year() + '-' + dt.month() + '-' + dt.day() + '_' + dt.hour() + '_' + dt.minute() + '_' + dt.second() +'.pdf';
            String jsonStr = CloudStorageController.getRequestHeaders('CREATE_UPDATE', fileName, '', payload);
            Map<String, Object> header = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            Http h = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('PUT');
            httpRequest.setHeader('Content-Length', '0');
            httpRequest.setHeader('x-ms-blob-type', 'BlockBlob');
            httpRequest.setHeader('Content-Type', 'application/pdf');
            httpRequest.setHeader('x-ms-version', '2019-02-02');
            httpRequest.setHeader('x-ms-meta-Payload', payLoad);
            httpRequest.setEndpoint(String.valueOf(header.get('FileUrlWithToken')));
            httpRequest.setBodyAsBlob(document);
            h.send(httpRequest);
            Map<String, Object> toGetCaseIdMap = (Map<String, Object>) JSON.deserializeUntyped(payload);
            string caseId = String.valueOf(toGetCaseIdMap.get('caseId'));
            Case newCaseObj = new Case();
            if(subject == 'PIA Template Form' || subject == 'New Service Template Form'){
                newCaseObj.Id       =   caseId;
                newCaseObj.Internal_Status__c = Constants.CASE_STATUS_SENT;
            }
            else if(subject == 'Enrollment Re-verification Form' || subject == Constants.ASSET_NAME_COVER_LETTER){
                newCaseObj.Id       =   caseId;
                newCaseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT; 
            }
            else if(subject == Constants.ASSET_TYPE_SCORE_RECHECK_LETTER){
                newCaseObj.Id = caseId;
                newCaseObj.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED; 
            }
            if(String.isNotBlank(newCaseObj.Id) && Schema.sObjectType.Case.isUpdateable()){
                update newCaseObj;
            }
            Case caseStatus = [SELECT Id, Internal_Status__c FROM Case WHERE Id =: caseId];
            if(subject == 'ECFMG Identification Form' && caseStatus.Internal_Status__c == Constants.CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];//Donot add WITH SECURITY_ENFORCED 
                efa.setFileName(subject+'.pdf');
                efa.setBody(document);
                email.setOrgWideEmailAddressId(addr[0].Id);
                email.setSubject(subject);
                email.setToAddresses( new String[] {mailId});
                email.setPlainTextBody('Please check the attached document.');
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            if(subject != 'ECFMG Identification Form' && subject != Constants.ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE && subject != Constants.ASSET_TYPE_ECFMG_CERTIFICATE && subject != Constants.ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE && subject != Constants.ASSET_TYPE_COVER_LETTER && subject != Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];//Donot add WITH SECURITY_ENFORCED                 
                email.setOrgWideEmailAddressId(addr[0].Id);
                email.setSubject(subject);
                email.setToAddresses( new String[] {mailId});                
                if(subject != Constants.ASSET_NAME_APPLICATION_FOR_CERTIFICATION_SUMMARY && subject != Constants.ASSET_NAME_EXAM_APPLICATION_SUMMARY){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(subject+'.pdf');
                    efa.setBody(document);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    email.setPlainTextBody('Please check the attached document.');
                }
                else{
                    email.setPlainTextBody(subject +' Asset is created. Please check.');
                }                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            if(String.isNotBlank(assetId) && Schema.sObjectType.Asset.isUpdateable()){
                Asset asst = new Asset();
                asst.Id = assetId;
                asst.Azure_Storage_URL__c = String.valueOf(header.get('FileUrl'));
                Update asst;
            }
            else{
                CloudStorageController.processResponse(payload, String.valueOf(header.get('FileUrl')));
            }
        }
        catch(exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //Wrapper class for cloud document payload
    global class PayloadWrapper{
        public string contactId {get;set;}
        public string documentType {get;set;}
        public string assetRecordType {get;set;}
        public string createOrReplace {get;set;}
        public string caseId {get;set;}
        public string accountId {get;set;}
        public string assetCreationRequired {get;set;}
        public string assetStatus {get;set;}
        public string assetId {get;set;}
        public string assetName {get;set;}
        public string createFromPB {get;set;}
        public string rePrintDate {get;set;}
        public string createAsset2Ver {get;set;}
        public PayloadWrapper(){
            contactId = '';
            documentType = '';
            assetRecordType = '';
            createOrReplace = '';
            caseId = '';
            accountId = '';
            assetCreationRequired = '';
            assetStatus = '';
            assetId = '';
        }
    }
    //Method to create asset and invoke api callout to azure blob to upload generated non USMLE Transcript
    global void uploadNonUsmleTranscript(Id objectId, Blob document){
        List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(userRequestCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_NON_USMLE_TRANSCRIPT ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_SCORE_REPORT;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(userRequestCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', userRequestCase[0].ContactId+'_Non-USMLE_Transcript', userRequestCase[0].Contact.Email, JSON.serialize(payload), document, Constants.ASSET_TYPE_NON_USMLE_TRANSCRIPT);
    }
    /* @description : Method to create asset and invoke api callout to azure blob to upload Enrollment Verification Cover Letter */
    global void uploadEnRevCoverLetter(Id objectId, Blob document){
        List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(userRequestCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_COVER_LETTER;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(userRequestCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_APPROVED;
        payload.assetName = Constants.ASSET_NAME_ENREV_COVER_LETTER;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', userRequestCase[0].ContactId+'_Enrollment_Re-verification_Cover_Letter', userRequestCase[0].Contact.Email, JSON.serialize(payload), document, 'Enrollment Re-verification Cover Letter');
    }

    // @description : Method to create asset and invoke api callout to azure blob to upload Duplicate ECFMG Certificate
    global void uploadDuplEcfmgCert(Id objectId, Blob document){
        List<Case> duplEcfmgCertCase = [SELECT Id, AccountId, ContactId, Contact.Email,RecordType.DeveloperName FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(duplEcfmgCertCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(duplEcfmgCertCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        List<Asset> assetList = new List<Asset>();
        if(duplEcfmgCertCase[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION){
            assetList = [Select id FROM Asset WHERE Case__c =:objectId AND Type__c =:Constants.ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE AND Status =:Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
            payload.assetId = String.valueOf(assetList[0].Id);
            uploadGeneratedDocToAzure(assetList[0].Id, duplEcfmgCertCase[0].ContactId+'_Duplicate_ECFMG_Certificate', duplEcfmgCertCase[0].Contact.Email, JSON.serialize(payload), document, 'Duplicate ECFMG Certificate');
        }
        else{
            payload.rePrintDate = String.valueOf(Date.Today());
            payload.createFromPB = 'true';
            uploadGeneratedDocToAzure('', duplEcfmgCertCase[0].ContactId+'_Duplicate_ECFMG_Certificate', duplEcfmgCertCase[0].Contact.Email, JSON.serialize(payload), document, 'Duplicate ECFMG Certificate');
        }
    }
    global void uploadRegenRePrintEcfmgDoc(Id objectId, Blob document){
        List<Case> duplEcfmgCertCase = [SELECT Id, AccountId, ContactId, Contact.Email, RecordType.DeveloperName FROM Case WHERE Id =:objectId WITH SECURITY_ENFORCED];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(duplEcfmgCertCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(duplEcfmgCertCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        List<Asset> assetList = new List<Asset>();
        assetList = [Select id FROM Asset WHERE Case__c =:objectId AND Type__c =:Constants.ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE AND Status =:Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
        payload.assetId = String.valueOf(assetList[0].Id);
        uploadGeneratedDocToAzure(assetList[0].Id, duplEcfmgCertCase[0].ContactId+'_'+assetList[0].Id+'.pdf', duplEcfmgCertCase[0].Contact.Email, JSON.serialize(payload), document, 'Reprinted ECFMG Certificate');
    }
    // @description : Method to create asset and invoke api callout to azure blob to upload ECFMG Certificate
    global void uploadEcfmgCertDoc(Id objectId, Blob document){
        List<Case> certCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
        PayloadWrapper payload = new PayloadWrapper();
        payload.contactId = String.valueOf(certCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_ECFMG_CERTIFICATE;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(certCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        payload.createFromPB = 'true';
        uploadGeneratedDocToAzure('', certCase[0].ContactId+'_ECFMG_Certificate', certCase[0].Contact.Email, JSON.serialize(payload), document, 'ECFMG Certificate');
    }
    //Method to create asset and invoke api callout to azure blob to upload generated verification form
    //Changed Asset Status to Verified from Accepted as per the US 18833
    global void uploadVerificationForm(Id objectId, Blob document){
        List<Case> cVCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.assetName = Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM;
        payload.contactId = String.valueOf(cVCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_VERIFICATION_FORM;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_VERIFICATION;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_VERIFIED;
        payload.createFromPB = 'true';
        payload.createAsset2Ver = 'true';
        uploadGeneratedDocToAzure('', cVCase[0].ContactId+'_'+cVCase[0].Id+'_Accepted_Verification_Form', cVCase[0].Contact.Email, JSON.serialize(payload), document, Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM);
    }
    //US 12708 - Method to invoke api callout to Azure blob to upload the generated EPIC Report 
    global void uploadEpicReport(Id objectId, Blob document){
        List<Case> epicCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.assetName = Constants.ASSET_NAME_EPIC_REPORT_PAGE;
        payload.contactId = String.valueOf(epicCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_VERIFICATION_REPORT;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_VERIFICATION;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_SENT;
        payload.createFromPB = 'true';
        payload.createAsset2Ver = 'true';
        uploadGeneratedDocToAzure('', epicCase[0].ContactId+'_'+epicCase[0].Id+'_EPIC_Report_Page', epicCase[0].Contact.Email, JSON.serialize(payload), document, Constants.ASSET_NAME_EPIC_REPORT_PAGE);
    }
    // US 15508 - Method to create asset and invoke api callout to azure blob to upload Verification_Cover_Letter
    global void uploadVerificationCoverLetter(Id objectId, Blob document){
        List<Case> cvCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        String assetName = Constants.ASSET_NAME_VERIFICATION_COVER_LETTER;
        String assetType = Constants.ASSET_TYPE_COVER_LETTER;
        String contactId = String.valueOf(cvCase[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();       
        payload.assetName = Constants.ASSET_NAME_VERIFICATION_COVER_LETTER;
        payload.contactId = contactId;
        payload.documentType = Constants.ASSET_TYPE_COVER_LETTER;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_VERIFICATION;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(cvCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_NEW;
        payload.createFromPB = 'true';
        payload.createAsset2Ver = 'true';
        httpCalloutAzureBlob(contactId+'_'+cvCase[0].Id+'_Verification_Cover_Letter', JSON.serialize(payload), document);
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList; 
        }
    }
    // US 15508 - Method to create asset and invoke api callout to azure blob to upload Universal_Verification_Form
    global void uploadUniversalVerificationForm(Id objectId, Blob document){
        List<Case> cvCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];           
        String assetName = Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM;
        String assetType = Constants.ASSET_TYPE_VERIFICATION_FORM;
        String contactId = String.valueOf(cvCase[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();
        payload.assetName = Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM;
        payload.contactId = contactId;
        payload.documentType = Constants.ASSET_TYPE_VERIFICATION_FORM;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_VERIFICATION;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_NEW;
        payload.createFromPB = 'true';
        payload.createAsset2Ver = 'true';
        httpCalloutAzureBlob(contactId+'_'+cvCase[0].Id+'_Universal_Verification_Form', JSON.serialize(payload), document);
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList; 
        }
    }
    // Delete the previously available asset before creating new assets (Verification_Cover_Letter or Universal_Verification_Form)
    global List<Asset> markForDeletionPrevAssets(String assetName, String assetType, String contactId, String caseId){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(string.isnotBlank(assetName)){
			for(Asset a : [SELECT Id FROM Asset WHERE ContactId =: contactId AND Case__r.id =: caseId AND Name =: assetName AND Type__c =: assetType AND status =: Constants.ASSET_STATUS_NEW WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }         
        }
        return assetsToUpdateList;
    }
    // Delete the previously accepted Summary assets before creating new ones - US 15088
    global List<Asset> markForDeletionPrevSummaryAssets(String assetName, String assetType, String contactId, String caseId){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(string.isnotBlank(assetName)){
			for(Asset a : [SELECT Id FROM Asset WHERE ContactId =: contactId AND Case__r.id =: caseId AND Name =: assetName AND Type__c =: assetType AND status =: Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }         
        }
        return assetsToUpdateList;
    }
    // US 16936 - Method to create asset and invoke api callout to azure blob to upload Medical Education Form Cover Letter
    global void uploadMedEduCoverLetter(Id objectId, Blob document){
        List<Case> caseRec = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        String assetName = Constants.ASSET_NAME_MED_EDU_COVER;
        String assetType = Constants.ASSET_TYPE_COVER_LETTER;
        String contactId = String.valueOf(caseRec[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();       
        payload.assetName = Constants.ASSET_NAME_MED_EDU_COVER;
        payload.contactId = contactId;
        payload.documentType = Constants.ASSET_TYPE_COVER_LETTER;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_MED_EDU_FORM;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(caseRec[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_NEW;
        payload.createFromPB = 'true';
        httpCalloutAzureBlob(contactId+'_'+caseRec[0].Id+'_Medical_Education_Cover_Letter', JSON.serialize(payload), document);
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList; 
        }
    }
    // US 15508 - Method to create asset and invoke api callout to azure blob to upload Medical Education Form
    global void uploadMedEduForm(Id objectId, Blob document){
        List<Case> caseRec = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];           
        String assetName = Constants.CASE_QUEUE_MED_EDU_FORM;
        String assetType = Constants.CASE_QUEUE_MED_EDU_FORM;
        String contactId = String.valueOf(caseRec[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();
        payload.assetName = Constants.CASE_QUEUE_MED_EDU_FORM;
        payload.contactId = contactId;
        payload.documentType = Constants.CASE_QUEUE_MED_EDU_FORM;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_MED_EDU_FORM;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(caseRec[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_NEW;
        payload.createFromPB = 'true';
        httpCalloutAzureBlob(contactId+'_'+caseRec[0].Id+'_Medical_Education_Form', JSON.serialize(payload), document);
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList; 
        }
    }
    /* US 12343 : Method to create asset and invoke api callout to azure blob to upload generated Attestation Form*/
    global void uploadAttestationForm(Id objectId, Blob document){
        List<Case> attestationCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id =: objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.assetName = Constants.ASSET_NAME_ATTESTATION_FORM;
        payload.contactId = String.valueOf(attestationCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_ATTEST_FORM ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ATTESTATION;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(attestationCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
        payload.createFromPB = 'true';
        String fileName = attestationCase[0].ContactId+'_Attestation_Form';
        httpCalloutAzureBlob(fileName, JSON.serialize(payload), document);
    }
    global void uploadAttestationCVLetter(Id objectId, Blob document){
        List<Case> attestationCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id =: objectId];
        PayloadWrapper payload = new PayloadWrapper();
        payload.assetName = Constants.ASSET_NAME_ATTESTATION_COVER_LETTER;
        payload.contactId = String.valueOf(attestationCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_COVER_LETTER ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ATTESTATION;
        payload.createOrReplace = 'create';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(attestationCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_IN_PROGRESS;
        payload.createFromPB = 'true';
        String fileName = attestationCase[0].ContactId+'_Attestation_Cover_Letter';
        httpCalloutAzureBlob(fileName, JSON.serialize(payload), document);
    }
}