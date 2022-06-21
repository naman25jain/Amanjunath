/**
 * @description AssetCreationWrapperController
 * Class for AssetCreationWrapperController
 *
 * @author        Enable Consulting
 * @version       1.0
 */
public with sharing class AssetCreationWrapperController{
    /**
     * Method Name: createAsset
     * @description : Method to create asset on azure upload.
     * @return: Boolean
     */
    @AuraEnabled
    public static Boolean createAsset(String link, CloudStorageController.PayloadWrapper payload){
        List<Asset> asstList = new List<Asset>();        
        Asset asst = new Asset();
        String type = payload.type != '' && payload.type != null ? payload.type : payload.documentType;
        asst.Name = type;
        asst.Azure_Storage_URL__c = link;
        asst.Type__c = type;
        asst.status = Constants.ASSET_STATUS_ACCEPTED;
        asst.File_Size__c = payload.size;
        if(type == constants.ASSET_TYPE_INTERIM_CERTIFICATE){
          asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        }else if(type == constants.ASSET_TYPE_INCOMING_CORRESPONDENCE){
            asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CORRESPONDENCE).getRecordTypeId();
        }else if(type == Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM){
            asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        }else if(type == Constants.ASSET_TYPE_CHARGE_LETTER || type == Constants.ASSET_TYPE_POLICY_LETTER || type == Constants.ASSET_TYPE_SUPPORTING_DOCUMENT || type == Constants.ASSET_NAME_IB_DECISION_LETTER || type == Constants.ASSET_NAME_NO_IB_DECISION_LETTER){
            asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
        }else if(type == Constants.ASSET_TYPE_DECISION_APPEAL_LETTER){
            asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_DECISION_APPEAL).getRecordTypeId();
        }else if(type == Constants.ASSET_TYPE_VERIFICATION_REPORT){
            asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        }else{
		    asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        }
        if(payload.accountId !='' && payload.accountId !=null){
            asstList = [SELECT Id, status FROM Asset WHERE AccountId=:payload.accountId AND Type__c=:type AND status !=: Constants.ASSET_STATUS_OUTDATED  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
            asst.AccountId = payload.accountId;
            insertAsset(asst);
        }
        if(payload.contactId !='' && payload.contactId != null && payload.caseId == ''){
            asstList = [SELECT id, status FROM Asset WHERE ContactId=:payload.contactId AND Type__c=:type AND status !=: Constants.ASSET_STATUS_OUTDATED  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
            asst.ContactId = payload.contactId;
            insertAsset(asst);
        }        
        if(payload.caseId != '' && payload.caseId != null){
            createAssetForCase(link, type, payload.caseId, asst);
        }
        updateAsstList(asstList);
        return true;
    }
    /**
     * Method Name: createAssetForCase
     * @description : Method to create asset on azure upload.
     * @return: none
     */
    public static void createAssetForCase(String link, String type, String parentId, Asset asst){
        if(type == Constants.ASSET_NAME_ID_FORM_NOTARIZED){
            createIDFormNotarizedAsset(parentId, link);
        }else{
            Case cse = [SELECT Id, Internal_Status__c, contactId, AccountId, Document_Type__c,RecordType.Developername FROM Case WHERE Id=: parentId WITH SECURITY_ENFORCED][0];
            asst.Case__c = parentId;
            asst.ContactId = cse.contactId;
            if(type == Constants.ASSET_TYPE_TRANSLATION){
                asst.Status = Constants.ASSET_STATUS_NEW; 
                asst.Name = 'Verification Translation';
            }else if(type == Constants.CASE_DOCUMENT_TYPE_ASSET_EVIDENCE && cse.RecordType.Developername == Constants.CASE_RECORD_TYPE_INVESTIGATION){
                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
                asst.AccountId = cse.AccountId;        
            }
            else if(type == Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE && cse.RecordType.Developername == Constants.CASE_RECORD_TYPE_INVESTIGATION){
                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
                asst.AccountId = cse.AccountId;
            }else if(type == Constants.ASSET_TYPE_DECISION_APPEAL_LETTER && cse.RecordType.Developername == Constants.CASE_RECORD_TYPE_DECISION_APPEAL){
                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_DECISION_APPEAL).getRecordTypeId();
                asst.AccountId = cse.AccountId;
                asst.Name = Constants.ASSET_NAME_APPEAL_LETTER;
                asst.Type__c = Constants.ASSET_TYPE_DECISION_APPEAL_LETTER;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET){
                asst.Name = Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET;
                asst.Type__c = Constants.ASSET_TYPE_VERIFICATION_PACKET;
                asst.Status = Constants.ASSET_STATUS_SUBMITTED;
                updateAssetMarkForDeletion(cse.Document_Type__c,parentId);               
            }else if(type == Constants.ASSET_NAME_DOB_DOCUMENT){
                asst.Name = Constants.ASSET_NAME_DOB_DOCUMENT;
                asst.Type__c = Constants.ASSET_TYPE_DOB_DOCUMENT;
                asst.Status = Constants.ASSET_STATUS_IN_PROGRESS;    
            }else if(type == Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE){
                asst.Name = Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE;
                asst.Type__c = Constants.ASSET_TYPE_INCOMING_CORRESPONDENCE;
                asst.Status = Constants.ASSET_STATUS_CANCELLED; 
            }else if(type == Constants.ASSET_NAME_RETURNED_EMAIL_RESPONSE){
                asst.Name = Constants.ASSET_NAME_RETURNED_EMAIL_RESPONSE;
                asst.Type__c = Constants.ASSET_TYPE_EMAIL;
                asst.Status = Constants.ASSET_STATUS_SUBMITTED;
            }else if(type == Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM){
                insertMedEduFormAsset(parentId, asst);
            }else if(type == Constants.ASSET_NAME_RETURNED_ATTESTATION_FORM){
                asst.Name = Constants.ASSET_NAME_RETURNED_ATTESTATION_FORM;
                asst.Type__c = Constants.ASSET_TYPE_ATTEST_FORM;
                asst.Status = Constants.ASSET_STATUS_SUBMITTED;
            }else if(type == Constants.ASSET_TYPE_CHARGE_LETTER){
                asst.Name = Constants.ASSET_TYPE_CHARGE_LETTER;
                asst.Azure_Storage_URL__c = link;
                asst.Type__c = Constants.ASSET_TYPE_CHARGE_LETTER;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_TYPE_POLICY_LETTER){
                asst.Name = Constants.ASSET_TYPE_POLICY_LETTER;
                asst.Azure_Storage_URL__c = link;
                asst.Type__c = Constants.ASSET_TYPE_POLICY_LETTER;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_TYPE_SUPPORTING_DOCUMENT){
                asst.Name = Constants.ASSET_TYPE_SUPPORTING_DOCUMENT;
                asst.Azure_Storage_URL__c = link;
                asst.Type__c = Constants.ASSET_TYPE_SUPPORTING_DOCUMENT;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_NAME_IB_DECISION_LETTER){
                asst.Name = Constants.ASSET_NAME_IB_DECISION_LETTER;
                asst.Type__c = Constants.ASSET_TYPE_DECISION_LETTER;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_NAME_NO_IB_DECISION_LETTER){
                asst.Name = Constants.ASSET_NAME_NO_IB_DECISION_LETTER;
                asst.Type__c = Constants.ASSET_TYPE_DECISION_LETTER;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(cse.RecordType.Developername == Constants.CASE_RECORD_TYPE_PETITION_FOR_RECONSN){
                asst = createPetitionForReconsnAsset(type,asst,cse);
            }else if(type == Constants.ASSET_TYPE_VERIFICATION_REPORT){
                asst.Name = Constants.ASSET_NAME_EPIC_VERIFICATION_REPORT;
                asst.Status = Constants.ASSET_STATUS_SENT;
            }else if(type == Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST){
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_TYPE_SIGNED_PIA || type == Constants.ASSET_TYPE_SIGNED_SERVICE_FORM){
                asst.AccountId = cse.AccountId;
                asst.Status = Constants.ASSET_STATUS_IN_PROGRESS;
            }else if(type == Constants.ASSET_TYPE_ONLINE_VERIFICATION){
                asst.AccountId = cse.AccountId;
                asst.Type__c = Constants.ASSET_TYPE_ONLINE_VERIFICATION;
                asst.Status = Constants.ASSET_STATUS_ACCEPTED;
            }else if(type == Constants.ASSET_TYPE_INCOMPLETE_ATTEST_LETTER || type == Constants.ASSET_TYPE_ATTEST_ACKNOWLEDGMENT_LETTER){
                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ATTESTATION).getRecordTypeId();
                asst.AccountId = cse.AccountId;
                asst.Type__c = Constants.ASSET_TYPE_INCOMPLETE_ATTEST_LETTER;
                asst.Status = Constants.ASSET_STATUS_SENT;
            }else if((type == Constants.ASSET_TYPE_PHOTO || type == 'Medical School Performance Evaluation' || type == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT) && cse.RecordType.Developername == Constants.CASE_RECORD_TYPE_ERAS){
                asst.Status = Constants.ASSET_STATUS_NEW;
                asst.Type__c = type;
                asst.AccountId = cse.AccountId;
                if(type == Constants.ASSET_TYPE_PHOTO || type == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT){
                    asst.Name = 'ERAS ' + type;
                }else if(type == 'Medical School Performance Evaluation'){
                    asst.Name = (String)type;
                }
            }else{                
                asst.Status = Constants.ASSET_STATUS_IN_PROGRESS;
            }
            asst.RecordTypeId = getAssetRecordType(type, asst.RecordTypeId);
            asst.ParentId = getAssociatedAssetId(asst);
            insertAsset(asst);
        }    
    }
    /**
     * Method Name: createPetitionForReconsnAsset
     * @description : Method to create asset.Function to set values for Petition For Reconsideration Form asset
     * @return: Asset
     */
    public static Asset createPetitionForReconsnAsset(String type, Asset asst, Case cse){
        if(type == Constants.ASSET_TYPE_EVIDENCE_DOCUMENT){
            asst.Name = Constants.ASSET_NAME_EVIDENCE_FROM_APPLICANT;
            asst.Type__c = Constants.ASSET_TYPE_EVIDENCE_DOCUMENT;    
        }else if(type == Constants.ASSET_NAME_COMMITTEE_CHAIR_DECISION){
            asst.Name = Constants.ASSET_NAME_COMMITTEE_CHAIR_DECISION ;
            asst.Type__c = Constants.ASSET_TYPE_DECISION_LETTER ;
        }else if(type == Constants.ASSET_NAME_COMMITTEE_DECISION_DENIED){
            asst.Name = Constants.ASSET_NAME_COMMITTEE_DECISION_DENIED;
            asst.Type__c = Constants.ASSET_TYPE_DECISION_LETTER ;
        }else if(type == Constants.ASSET_NAME_COMMITTEE_DECISION_GRANTED){
            asst.Name = Constants.ASSET_NAME_COMMITTEE_DECISION_GRANTED;
            asst.Type__c = Constants.ASSET_TYPE_DECISION_LETTER ;
        }else if(type == Constants.ASSET_NAME_COMMITTEE_DECISION_MODIFIED){
            asst.Name = Constants.ASSET_NAME_COMMITTEE_DECISION_MODIFIED;
            asst.Type__c = Constants.ASSET_TYPE_DECISION_LETTER ;
        }
        asst.AccountId = cse.AccountId;
        asst.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN).getRecordTypeId();
        return asst;
    }
    /**
     * Method Name: insertMedEduFormAsset
     * @description : Method to insert asset. Function to set values for Returned Medical Education Form asset
     * @return: Asset
     */
    public static Asset insertMedEduFormAsset(String parentId, Asset asst){
        Boolean acceptedAssetPresent = false;
        List<Asset> existingAssetsList = new List<Asset>();
        List<Asset> updateAssetList = new List<Asset>();
        existingAssetsList =[SELECT Id, Status, Case__c FROM Asset WHERE Case__c = :parentId AND Type__c = :Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM AND (status = :Constants.ASSET_STATUS_ACCEPTED OR status = :Constants.ASSET_STATUS_SUBMITTED OR status = :Constants.ASSET_STATUS_INCOMPLETE) WITH SECURITY_ENFORCED];
        if(existingAssetsList.size() == 0){
            asst.Status = Constants.ASSET_STATUS_SUBMITTED;
        }else{
            for(Asset ast :existingAssetsList ){
                if(ast.status == Constants.ASSET_STATUS_ACCEPTED || ast.status == Constants.ASSET_STATUS_SUBMITTED){
                    acceptedAssetPresent = true;
                }
                if(ast.status == Constants.ASSET_STATUS_INCOMPLETE){
                    ast.status = Constants.ASSET_STATUS_OUTDATED;
                    updateAssetList.add(ast);
                }
            }
            asst.Status = setAssetStatusForMedEduForm(acceptedAssetPresent, updateAssetList);
        }
        asst.Name = Constants.ASSET_NAME_RETURNED_MED_EDU_FORM;
        asst.Type__c = Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM;   
        return asst;
    }
    /**
     * Method Name: setAssetStatusForMedEduForm
     * @description : Function to set value for status of Returned Medical Education Form asset
     * @return: String
     */
    public static string setAssetStatusForMedEduForm(Boolean acceptedAssetPresent, List<Asset> updateAssetList){
        String assetStatus;
        if(acceptedAssetPresent == true){
            assetStatus = Constants.ASSET_STATUS_OUTDATED;
        }else{
            assetStatus = Constants.ASSET_STATUS_SUBMITTED;
        }
        if(Asset.SObjectType.getDescribe().isUpdateable() && updateAssetList.size() > 0){
            try{
                Update updateAssetList;
            }catch(Exception e){
                system.debug(LoggingLevel.ERROR, e);
            }    
        }
        return assetStatus;
    }
    /**
     * Method Name: updateAssetMarkForDeletion
     * @description : US 12215 - Methods to update the status of Asset as Marked for Deletion
     * @return: None
     */
    public static void updateAssetMarkForDeletion(String documentType,Id caseId){
        try{
            String returnedCredentialType = 'Returned '+documentType;
            List<String> assetNameList = new List<String>{Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET, Constants.ASSET_NAME_RETURNED_VERIFICATION_FORM, returnedCredentialType, Constants.ASSET_NAME_RETURNED_SUPPORTING_DOCUMENTS};
            List<Asset> assetsToUpdateList = new List<Asset>();
            List<RecordType> rts = new List<RecordType>();
            if(RecordType.SObjectType.getDescribe().isAccessible()){
                rts = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
            }
            if(rts.size() == 0){
                throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
            }
            RecordType assetMarkedForDeletionRT = rts[0];
            if(Asset.SObjectType.getDescribe().isUpdateable()){
                for(Asset a: [SELECT Id, Status, Case__c FROM Asset WHERE Name IN: assetNameList AND Case__c=: caseId WITH SECURITY_ENFORCED]){
                    a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                    a.Case__c = null;				
                    a.RecordTypeId = assetMarkedForDeletionRT.Id;
                    assetsToUpdateList.add(a);
                }
                UPDATE assetsToUpdateList;
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }        
    }
    /**
     * Method Name: updateTaskStatus
     * @description : Update the task Status as "Completed" and Send Notification to CV Case Owner
     * @return: None
     */
    @AuraEnabled
    public static void updateTaskStatus(String caseId){
        List<Case> cvCaseList = [SELECT Id, OwnerId, CaseNumber FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
        if(!cvCaseList.isEmpty()){
            Case cvCase = cvCaseList[0];
            List<Task> taskList = [SELECT Id, Status, Subject FROM Task WHERE WhatId =: caseId WITH SECURITY_ENFORCED];
            if(!taskList.isEmpty()){
                Task taskObj = taskList[0];
                taskObj.Status = Constants.TASK_STATUS_COMPLETED;
                if(Task.SObjectType.getDescribe().isUpdateable()){
                    update taskObj;
                    String notificationTitle = system.Label.CredVerCaseTaskCompletedNotificationTitle;
                    String notificationBody = system.Label.CredVerCaseTaskCompletedNotificationBody;
                    notificationBody = notificationBody.replace('{!Case.CaseNumber}',cvCase.CaseNumber);
                    notificationBody = notificationBody.replace('{!Task.Subject}',taskObj.Subject);
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName =: Constants.CUSTOM_NOTIFICATION_TYPE_CRED_VER_CASE_TASK_COMPLETED]; // Dont Use With Security Enforced
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle(notificationTitle);
                    notification.setBody(notificationBody);
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(cvCase.Id);
                    notification.send(new set<string>{cvCase.OwnerId});
                }
            }
        }
    }
    /**
     * Method Name: sendNotification
     * @description : Send notification for the given caseId
     * @return: None
     */
    @AuraEnabled
    public static void sendNotification(String caseId){
        List<Case> aCaseList = [SELECT Id, Parent.OwnerId , Parent.CaseNumber FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
        if(!aCaseList.isEmpty()){
            Case cvCase = aCaseList[0];
            String notificationTitle = system.Label.AttestationCaseCompletedNotificationTitle;
            String notificationBody = system.Label.AttestationCaseCompletedNotificationBody;
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName =: Constants.CUSTOM_NOTIFICATION_TYPE_ATTESTATION_CASE_COMPLETED]; 
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(notificationTitle);
            notification.setBody(notificationBody);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(cvCase.Id);
            notification.send(new set<string>{cvCase.Parent.OwnerId});
        }
    }
    /**
     * Method Name: getAssociatedAssetId
     * @description : Get Asset Id
     * @return: Id
     */
    public static Id getAssociatedAssetId(Asset newAsset){
        if(newAsset.Type__c == Constants.ASSET_TYPE_NAME_DOC){
            List<Asset> parentAssetList = [SELECT Id FROM Asset WHERE Name_Review_Case__c = :newAsset.Case__c WITH SECURITY_ENFORCED];
            if(parentAssetList.isEmpty()){
                return null;
            }else{
                return parentAssetList[0].Id;
            }
        }else if(newAsset.Type__c == Constants.ASSET_TYPE_DOB_DOCUMENT){
            Case asstCase = [SELECT parentId FROM Case where id= :newAsset.case__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Asset> parentAssetList = [SELECT Id FROM Asset WHERE (Case__c = :asstCase.parentId AND RecordType.DeveloperName = :Constants.ASSET_RECORD_TYPE_CREDENTIAL) WITH SECURITY_ENFORCED ];
            if(parentAssetList.isEmpty()){
                return null;
            }else{
                return parentAssetList[0].Id;
            }
        }
        return null;
    }
    /**
     * Method Name: getAssetRecordType
     * @description : Get Asset Record Type name
     * @return: String
     */
    public static String getAssetRecordType(String type, String originalRecordType){
        if(type == Constants.ASSET_TYPE_RETURNED_ENROLLMENT_VERIFICATION){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        }
        if(type == Constants.ASSET_TYPE_ONLINE_VERIFICATION || type == Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        }
        if(type == Constants.ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE || type == Constants.ASSET_TYPE_DEAN_LETTER || type == Constants.CREDENTIAL_TYPE_CGS || type == Constants.ASSET_NAME_DEAN_LETTER || type == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA 
                || type == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT || type == Constants.ASSET_TYPE_MED_REG_CERT_LIC_PRAC_MED || type == Constants.ASSET_TYPE_POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL || type == Constants.ASSET_TYPE_PREGRADUATE_INTERNSHIP_CREDENTIAL
                || type == Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION || type == 'Medical School Performance Evaluation'){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        }
        if(type == Constants.ASSET_TYPE_NON_USMLE_TRANSCRIPT || type == Constants.ASSET_TYPE_USMLE_TRANSCRIPT){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SCORE_REPORT).getRecordTypeId();
        }
        if(type == Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS ){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        }
        if(type==Constants.ASSET_TYPE_NAME_DOC || type == Constants.ASSET_NAME_DOB_DOCUMENT || type == Constants.ASSET_TYPE_EIF || type == Constants.ASSET_TYPE_NOTARIZED_IDFORM || type == Constants.ASSET_TYPE_RELEASE || type == Constants.ASSET_TYPE_PHOTO){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
        }
        if(type == 'Translation' || type == Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET || type == Constants.ASSET_NAME_RETURNED_EMAIL_RESPONSE){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        }
        if(type == Constants.ASSET_NAME_RETURNED_ATTESTATION_FORM || type == Constants.ASSET_TYPE_ATTEST){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ATTESTATION).getRecordTypeId();
        }
        if(type == Constants.ASSET_TYPE_CHARGE_LETTER || type == Constants.ASSET_TYPE_POLICY_LETTER || type == Constants.ASSET_TYPE_SUPPORTING_DOCUMENT || type == Constants.ASSET_NAME_IB_DECISION_LETTER || type == Constants.ASSET_NAME_NO_IB_DECISION_LETTER){
            return Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
        }
        return originalRecordType;
    }
    /**
     * Method Name: insertAsset
     * @description : Insert Asset
     * @return: None
     */
    public static void insertAsset(Asset asst){
        if(Asset.SObjectType.getDescribe().isCreateable()){
            insert asst;
            if(asst.Name == Constants.ASSET_NAME_RETURNED_VERIFICATION_PACKET && asst.Case__c != null){
                updateTaskStatus(asst.Case__c);
            }
            if(asst.Name == Constants.ASSET_NAME_RETURNED_ATTESTATION_FORM && asst.Case__c != null){
                sendNotification(asst.Case__c);
            }
            List<Asset> asstList = new list<Asset>();
            asstList.add(asst);
            CloudStorageController.checkErasAssetAndOutdateOld(asstList);
        }
    }
    /**
     * Method Name: updateAsstList
     * @description : Update Asset list
     * @return: None
     */
    public static void updateAsstList(List<Asset> asstList){
        if(!asstList.isEmpty()){
            for(Asset oldAsset:asstList){
                oldAsset.status = Constants.ASSET_STATUS_OUTDATED;
            }
            try{
                if(Asset.SObjectType.getDescribe().isUpdateable()){
                    update asstList;
                }
            }catch(exception e){
                system.debug('results: e' + e.getMessage());
            }
        }
    }
    /**
     * Method Name: getSobjectType
     * @description : Method to get sobject type using recordId.
     * @return: String
     */
    @AuraEnabled
    public static String getSobjectType(String recordId){
        Id currentId = recordId;
        Schema.SObjectType sobjectType = currentId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        return sobjectName;
    }
    /**
     * Method Name: getCaseDetail
     * @description : Get case details for given caseId
     * @return: Case
     */
    @AuraEnabled
    public static Case getCaseDetail(Id caseId){        
        Case caseDetail = CaseController.getCaseDetail(caseId);
        return caseDetail;   
    }
    /**
     * Method Name: createIDFormNotarizedAsset
     * @description : Create IDForm Notarozed Asset
     * @return: Boolean
     */
    @AuraEnabled(cacheable=true)
    public static Boolean createIDFormNotarizedAsset(Id caseId, String documentUrl){
        final String affirmation_YES = 'Yes';
        // Create a new Asset
        Case caseDetail = getCaseDetail(caseId);
        Id productId = [SELECT Id 
                            FROM Product2
                            WHERE ProductCode =: Constants.PRODUCT_CODE_ID_FORM
                            WITH SECURITY_ENFORCED
                            LIMIT 1].Id;
        List<Asset> assets = new List<Asset>();
        assets.add(new Asset(Name = Constants.ASSET_NAME_ID_FORM_NOTARIZED,
                            Azure_Storage_URL__c = documentUrl,
                            Type__C = Constants.ASSET_TYPE_IDENTITY_VERIFICATION,
                            Status = Constants.ASSET_STATUS_INPROGRESS,
                            Case__c = caseId,
                            ContactId = caseDetail.ContactId,
                            AccountId = caseDetail.AccountId,
                            Product2Id = productId,
                            RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId()));
        AssetsController.insertAsset(assets);
    // Create affirmation for this new asset
            Id assetId = [SELECT Id 
                        FROM Asset
                        WHERE Case__c =: caseId
                        AND Azure_Storage_URL__c =: documentUrl
                        WITH SECURITY_ENFORCED
                        LIMIT 1].Id; 
            List<Affirmation__c> affirmations = new List<Affirmation__c>();
            affirmations.add(new Affirmation__c(Asset__c = assetId, 
                                            Status__c = Constants.AFFIRMATION_STATUS_IN_PROGRESS, 
                                            Document_is_an_ID_Form_Picklist__c = affirmation_YES, 
                                            ID_Form_Acceptable_Picklist__c = affirmation_YES, 
                                            RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_ID_VERIFICATION).getRecordTypeId()));
        AffirmationController.insertAffirmation(affirmations);
        // Update case status to "Pending ID Verification Review"
        CaseController.updateCaseStatus(caseId, Constants.CASE_STATUS_PENDING_ID_VERIFICATION_REVIEW);
        return true;
    }
    /**
     * Method Name: getContactDetail
     * @description : Get contact detail fro teh given contact id.
     * @return: Contact
     */
    @AuraEnabled(cacheable=true)
    public static Contact getContactDetail(Id contactId){
        try{
            if(Contact.SObjectType.getDescribe().isAccessible()){
              List<Contact> contactDetails = [SELECT Id,RecordType.DeveloperName FROM Contact WHERE Id =: contactId];
              if(!contactDetails.isEmpty()){
                return contactDetails[0];
              } 
            }
        }
        catch(Exception e){
           if(Schema.sObjectType.Log_Message__c.isCreateable()){
            Log_Message__c logMsg = new Log_Message__c();
            logMsg.Exception__c	= 'Unhandled Exception from getContactDetail function of AssetCreationWrapperController :'+e.getMessage();
            logMsg.Date_Time_Logged__c = DateTime.now();
            INSERT logMsg;
           }   
        }
        return null;
    }
    /**
     * Method Name: createAsse2VerRecord
     * @description : Create assset2verification records.
     * @return: None
     */
    @AuraEnabled
    public static void createAsse2VerRecord(string url, string recordId, string selectedType){
        try{
            Verification_Packet__c verPack = [SELECT id FROM Verification_Packet__c WHERE case__c =:recordId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            Asset2Verification__c newAsset2Ver = new Asset2Verification__c();
            newAsset2Ver.Verification_Packet__c = verPack.Id;
            newAsset2Ver.Azure_Document_URL__c = url;
            if(selectedType == constants.ASSET_TYPE_ONLINE_VERIFICATION){
                newAsset2Ver.Document_Type__c = constants.ASSET2VER_DOCTYPE_ACC_VER_FORM;
            }
            else if(selectedType == constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER){
                newAsset2Ver.Document_Type__c = constants.ASSET2VER_DOCTYPE_COVER_LETTER;
            }
            else if(selectedType == constants.ASSET_TYPE_SUPPORTING_DOCUMENTS){
                newAsset2Ver.Document_Type__c = constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
            }
            if(Asset2Verification__c.SObjectType.getDescribe().isCreateable()){
                Insert newAsset2Ver;
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
}