public with sharing class ComplieVerificationPacketController{
    @AuraEnabled
    public static Boolean checkTheFinalDoc(string caseRecordId){
        try{
            Boolean acceptedVer = false;
            Boolean coverLetter = false;
            List<String> docTypeList = new List<String>();
            docTypeList.add(constants.ASSET2VER_DOCTYPE_COVER_LETTER);
            docTypeList.add(constants.ASSET2VER_DOCTYPE_ACC_VER_FORM);
            List<Verification_Packet__c> verPackExist = new List<Verification_Packet__c>();
            verPackExist = [SELECT Id FROM Verification_Packet__c WHERE Case__c =:caseRecordId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            List<Asset2Verification__c> asset2VerList = [SELECT Id,Document_Type__c,Verification_Packet__c FROM Asset2Verification__c WHERE Document_Type__c in :docTypeList AND Verification_Packet__c=:verPackExist[0].Id WITH SECURITY_ENFORCED];
            For(Asset2Verification__c eachAsset2Ver: asset2VerList){
                if(eachAsset2Ver.Document_Type__c == constants.ASSET2VER_DOCTYPE_ACC_VER_FORM){
                    acceptedVer = true;
                }
                if(eachAsset2Ver.Document_Type__c == constants.ASSET2VER_DOCTYPE_COVER_LETTER){
                    coverLetter= true;
                }
            }
            if(coverLetter && acceptedVer){
                Case newCase = [SELECT Id FROM case WHERE id =:caseRecordId WITH SECURITY_ENFORCED];
                Group verReviewQueue = [SELECT Id FROM Group WHERE Type =:Constants.GROUP_TYPE_QUEUE AND DeveloperName =:Constants.CASE_QUEUE_VERIFICATION_REVIEW_QUEUE WITH SECURITY_ENFORCED];
                newCase.Internal_Status__c = constants.CASE_STATUS_PENDING_VER_REVIEW;
                newCase.OwnerId = verReviewQueue.Id;
                if(Case.SObjectType.getDescribe().isUpdateable()){
                    Update newCase;
                    return true;
                }
            }
        }Catch(Exception e){
            throw e;
        }
            return false;
    }
    @AuraEnabled
    public static void createVpandAsset2VerRecords(string caseRecordId){
        try{
            Case newCase = [select id,ContactId FROM case WHERE id =:caseRecordId WITH SECURITY_ENFORCED];
            List<Verification_Packet__c> verPackExist = new List<Verification_Packet__c>();
            verPackExist = [SELECT Id FROM Verification_Packet__c WHERE Case__c =:caseRecordId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            Verification_Packet__c verPack = new Verification_Packet__c();
            List<Asset2Verification__c> asset2VerList = new List<Asset2Verification__c>();
            if(verPackExist.isEmpty() && Verification_Packet__c.SObjectType.getDescribe().isCreateable()){
                verPack.Case__c = newCase.Id;
                verPack.Contact__c = newCase.ContactId;
                verPack.Is_Active__c = true;
                Insert verPack;
                List<Asset> sourceAsset = new List<Asset>([SELECT id FROM asset WHERE Case__c =:caseRecordId AND uploaded_by_applicant__c = true AND parentId = null  WITH SECURITY_ENFORCED]);
                if(!sourceAsset.isEmpty()){
                    Asset2Verification__c newAsset2Ver = new Asset2Verification__c();
                    newAsset2Ver.Verification_Packet__c = verPack.Id;
                    newAsset2Ver.Asset__c= sourceAsset[0].Id;
                    newAsset2Ver.Document_Type__c = 'Source';
                    asset2VerList.add(newAsset2Ver);
                    Asset2Verification__c newAsset2VerVerified = new Asset2Verification__c();
                    newAsset2VerVerified.Verification_Packet__c = verPack.Id;
                    newAsset2VerVerified.Asset__c= sourceAsset[0].Id;
                    newAsset2VerVerified.Document_Type__c = 'Verified';
                    asset2VerList.add(newAsset2VerVerified);
                    if(Asset2Verification__c.SObjectType.getDescribe().isCreateable()){
                        INSERT asset2VerList;
                    }
                }
            }
        }catch(Exception e){
            throw e;
        }
    }
    //Method to get send method of current cv case
    @AuraEnabled
    public static String getCaseEntity(Id caseId, String caseRecordTypeDevName){
        try{
            String affirRecTypeDevName;
            if(caseRecordTypeDevName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
                affirRecTypeDevName = Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
            }else{
                affirRecTypeDevName = Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION;
            }
            Affirmation__c affirmation = [SELECT Verify_with_Alternate_Entity__c,Case__r.Alternate_Entity__r.Name,Case__r.Entity__r.Name FROM Affirmation__c WHERE Case__c =:caseId AND recordType.DeveloperName =: affirRecTypeDevName WITH SECURITY_ENFORCED];
            if(affirmation.Verify_with_Alternate_Entity__c && String.isNotBlank(affirmation.Case__r.Alternate_Entity__r.Name)){
                return affirmation.Case__r.Alternate_Entity__r.Name;
            }
            else if(String.isNotBlank(affirmation.Case__r.Entity__r.Name)){
                return affirmation.Case__r.Entity__r.Name;
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
        return '';
    }
    //Method to create verification packet and asset2verification records
    @AuraEnabled
    public static Boolean createVerificationPacket(Id caseId, String vpJson){
        try{
            Map<String, Object> vpJsonMap = (Map<String, Object>) JSON.deserializeUntyped(vpJson);
            Case caseRec = [SELECT Id, ContactId, Is_Reopened_Exam_Reg__c, recordType.DeveloperName, (SELECT Id FROM Verification_Packets__r WHERE Is_Active__c = true) FROM Case WHERE Id =:caseId WITH SECURITY_ENFORCED];
            Verification_Packet__c vp = new Verification_Packet__c();
            String verPacketId = markVerPacketInactive(caseRec);
            if(String.isNotBlank(verPacketId)){
                vp.Id = verPacketId;
            }
            vp.Case__c = caseId;
            vp.Contact__c = caseRec.ContactId;
            vp.Send_Language__c = String.valueOf(vpJsonMap.get('sendLang'));
            vp.Entity_provide_the_credential__c = Boolean.valueOf(vpJsonMap.get('reqEntity'));
            vp.Translation_included__c = Boolean.valueOf(vpJsonMap.get('inclTrans'));
            vp.Request_additional_information__c = String.valueOf(vpJsonMap.get('addInfo'));
            vp.Is_Active__c = true;
            if(Schema.sObjectType.Verification_Packet__c.isCreateable() && Schema.sObjectType.Verification_Packet__c.isUpdateable()){
                UPSERT vp;
            }
            if(caseRec.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
                createAsset2VerMedEduForm(caseId, vp);
            }else{
                createAsset2Ver(caseId, vp);
            }            
            return true;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    //Method to get Contact Id using Case Id
    public static String getContactIdByCaseId(Id caseId){
        try{
            Case caseRec = [SELECT Id, ContactId FROM Case WHERE Id =: caseId];
            return caseRec.ContactId;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    // US 16935 - Create Records for Final Medical Diploma and Final Medical School Transcript
    public static void createAsset2VerMedEduForm(Id caseId, Verification_Packet__c vp){
        try{
            String contactId = getContactIdByCaseId(caseId);
            List<Asset2Verification__c> asset2verDelete = new List<Asset2Verification__c>();
            List<Asset2Verification__c> asset2verList = new List<Asset2Verification__c>();
            for(Asset assetRec : [SELECT Id, Name, Type__c, recordType.DeveloperName, Status, (SELECT Id FROM Asset2Verifications__r WHERE Verification_Packet__c =: vp.Id) FROM asset WHERE ContactId =: contactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND (Type__c =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA OR Type__c =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT) WITH SECURITY_ENFORCED]){
                Asset2Verification__c asset2VerObj = new Asset2Verification__c();
                if(!assetRec.Asset2Verifications__r.isEmpty()){
                    asset2VerObj.Id = assetRec.Asset2Verifications__r[0].Id;
                }
                asset2VerObj.Asset__c = assetRec.Id;
                asset2VerObj.Verification_Packet__c = vp.Id;
                asset2VerObj.Document_type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
                asset2verList.add(asset2VerObj);
            }
            createDeleteAsset2Ver(asset2verList, asset2verDelete);
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }        
    }
    public static void createAsset2Ver(Id caseId, Verification_Packet__c vp){
        try{
            List<Asset2Verification__c> a2vDelete = new List<Asset2Verification__c>();
            List<Asset2Verification__c> a2vList = new List<Asset2Verification__c>();
            for(Asset assetRec : [SELECT Id, Name, Type__c, recordType.DeveloperName, status, (SELECT Id FROM Asset2Verifications__r WHERE Verification_Packet__c =:vp.Id) FROM asset WHERE Case__c =:caseId AND 
            (Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST OR Name =: Constants.ASSET_TYPE_TCT OR Name =: Constants.ASSET_NAME_DEAN_LETTER OR 
            Name =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA OR Name =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT OR 
            Type__c =:Constants.ASSET_TYPE_TRANSLATION OR (Type__c =:Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS AND Status =: Constants.ASSET_STATUS_NEW AND Name =: Constants.ASSET_NAME_SUPPORTING_DOCUMENTS AND recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT)) WITH SECURITY_ENFORCED]){
                Asset2Verification__c credAV = new Asset2Verification__c();
                Set<String> keySet = new Set<String>{
                    Constants.ASSET_NAME_CREDENTIAL_REQUEST,
                    Constants.ASSET_TYPE_TCT,
                    Constants.ASSET_NAME_DEAN_LETTER,
                    Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
                    Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
                };
                if(keySet.contains(assetRec.Name)){
                    if(!vp.Entity_provide_the_credential__c){
                        if(!assetRec.Asset2Verifications__r.isEmpty()){
                            credAV.Id = assetRec.Asset2Verifications__r[0].Id;
                        }
                        credAV.Asset__c = assetRec.Id;
                        credAV.Verification_Packet__c = vp.Id;
                        credAV.Document_type__c = 'Source';
                        a2vList.add(credAV);
                    }else if(vp.Entity_provide_the_credential__c && !assetRec.Asset2Verifications__r.isEmpty()){
                        a2vDelete.add(assetRec.Asset2Verifications__r);
                    }
                }
                else if(assetRec.Type__c == Constants.ASSET_TYPE_TRANSLATION){
                    if(vp.Translation_included__c){
                        if(!assetRec.Asset2Verifications__r.isEmpty()){
                            credAV.Id = assetRec.Asset2Verifications__r[0].Id;
                        }
                        credAV.Asset__c = assetRec.Id;                   
                        credAV.Verification_Packet__c = vp.Id;
                        credAV.Document_type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
                        a2vList.add(credAV);
                    }
                    else if(!vp.Translation_included__c && !assetRec.Asset2Verifications__r.isEmpty()){
                        a2vDelete.add(assetRec.Asset2Verifications__r);
                    }
                }
                else if(assetRec.Type__c == Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS && assetRec.Status == Constants.ASSET_STATUS_NEW && assetRec.Name == Constants.ASSET_NAME_SUPPORTING_DOCUMENTS && assetRec.recordType.DeveloperName == Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT){
                    if(!assetRec.Asset2Verifications__r.isEmpty()){
                        credAV.Id = assetRec.Asset2Verifications__r[0].Id;
                    }
                    credAV.Asset__c = assetRec.Id;
                    credAV.Verification_Packet__c = vp.Id;
                    credAV.Document_type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
                    a2vList.add(credAV);
                }
            }
            createDeleteAsset2Ver(a2vList, a2vDelete);
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static void createDeleteAsset2Ver(List<Asset2Verification__c> a2v, List<Asset2Verification__c> a2vDelete){
        if(Schema.sObjectType.Asset2Verification__c.isCreateable() && Schema.sObjectType.Asset2Verification__c.isUpdateable() && !a2v.isEmpty()){
            UPSERT a2v;
        }
        if(Schema.sObjectType.Asset2Verification__c.isDeletable() && !a2vDelete.isEmpty()){
            DELETE a2vDelete;
        }
    }
    public static String markVerPacketInactive(Case caseRec){
        try{
            String verPacketId;
            if(!caseRec.Verification_Packets__r.isEmpty()){
                if(caseRec.Is_Reopened_Exam_Reg__c){
                    Verification_Packet__c existingVp = new Verification_Packet__c();
                    existingVp.Id = caseRec.Verification_Packets__r[0].Id;
                    existingVp.Is_Active__c = false;
                    if(Schema.sObjectType.Verification_Packet__c.isUpdateable()){
                        UPDATE existingVp;
                    }
                    caseRec.Is_Reopened_Exam_Reg__c = false;
                    if(Schema.sObjectType.Case.isUpdateable()){
                        UPDATE caseRec;
                    }
                    updateAssets(caseRec);
                }
                else{
                    verPacketId = caseRec.Verification_Packets__r[0].Id;
                }
            }
            return verPacketId;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static void updateAssets(Case caseRec){
        try{
            Id assetRecTypeVerification = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
            List<Asset> assetList = [SELECT id FROM Asset WHERE Case__c =:caseRec.Id AND RecordTypeId =:assetRecTypeVerification AND (Type__c =:Constants.ASSET_TYPE_ONLINE_VERIFICATION OR Type__c =:Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER) WITH SECURITY_ENFORCED];
            for(Asset asst : assetList){
                Asst.Status = Constants.ASSET_STATUS_INVALIDATED;
            }
            if(Schema.sObjectType.Asset.isUpdateable() && !assetList.isEmpty()){
                UPDATE assetList;
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean getCourierSelectedByApplicant(Id caseId){
        try{
            Contact_Association_Type_Staging__c cats = [select id, Courier_service_for_an_additional_fee__c from Contact_Association_Type_Staging__c where case__c =:caseId WITH SECURITY_ENFORCED];
            return cats.Courier_service_for_an_additional_fee__c;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<String> getCourierFeePicklistValues(){
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Send_Request__c.Courier_fee_payable_by__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    @AuraEnabled
    public static Verification_Packet__c getVerificationPacket(Id caseId){
        try{
            List<Verification_Packet__c> vp = [SELECT Id, Send_Language__c, Entity_provide_the_credential__c, Translation_included__c, Request_additional_information__c
                                               FROM Verification_Packet__c WHERE case__c =:caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            if(!vp.isEmpty()){
                return vp[0];
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
        return null;
    }
    // Get CATS Record by Case ID and CATS's Record Type is CredentialIntake
    @AuraEnabled
    public static Contact_Association_Type_Staging__c getCATSCredentialIntake(Id caseId){
        try{
            Id catsRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();        
            List<Contact_Association_Type_Staging__c> catsList = [SELECT Id, Credential_Type__c, Requested_to_be_sent_to_ECFMG__c
                                                FROM Contact_Association_Type_Staging__c 
                                                WHERE Case__c =: caseId 
                                                AND RecordTypeId =: catsRecTypeId
                                                WITH SECURITY_ENFORCED];
            if(!catsList.isEmpty()){
                return catsList[0];
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
        return null;
    }
    @AuraEnabled
    public static Boolean updateCredVerCase(Id caseId, String sendReqJson){
        try{
            Case cse = [SELECT Id,Send_Method__c,Send_Request__c,Service__c,ContactEmail,Contact.name,CaseNumber,Entity__r.External_Instructions__c,Entity__c,Alternate_Entity__c,Document_Type__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];            
            createSendRequest(cse, sendReqJson);
            if(String.isNotBlank(cse.Entity__r.External_Instructions__c) && (cse.Service__c == Constants.CASE_SERVICE_EPIC || cse.Service__c == Constants.CASE_SERVICE_ECFMG_CERTIFICATION)){
                sendEmailSpecInstructions(cse);
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
        return true;
    }
    public static void updateCredVerCaseStatus(Case cse, Send_Request__c sendReq){
        try{
            if(cse.Send_Method__c == Constants.CASE_SEND_METHOD_EMAIL){
                cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_EMAIL_CREATION;
            }else if(cse.Send_Method__c == Constants.CASE_SEND_METHOD_ENTITY_PORTAL){
                cse.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
            }
            else if(cse.Send_Method__c == Constants.CASE_SEND_METHOD_PAPER && sendReq.Request_sent_via_courier__c == TRUE){
                cse.Send_Request__c = sendReq.Id;
            }
            if(Case.SObjectType.getDescribe().isUpdateable()){
                Update cse;
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static void sendEmailSpecInstructions(case cse){
        try{
            EmailTemplate template = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =:Constants.EMAIL_TEMPLATE_VP_SPEC_INSTR]; //Donot add WITH SECURITY_ENFORCED
            List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =:Constants.ORG_WIDE_ADDRESS]; //Donot add WITH SECURITY_ENFORCED
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTemplateId(template.Id);
            message.setSubject(template.Subject);
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Contact}', cse.Contact.name);
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', cse.CaseNumber);
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');
            message.setHtmlBody(htmlBody);
            message.setOrgWideEmailAddressId(addr[0].Id);
            message.setToAddresses(new String[]{cse.ContactEmail});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean uploadInCompleteCoverLetter(Id caserecId){
        try{
            List<Case> cvCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :caserecId];           
            String assetName = Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM;
            String contactId = String.valueOf(cvCase[0].ContactId);
            Actionable_UploadDocumentToAzureBlob.PayloadWrapper payload = new Actionable_UploadDocumentToAzureBlob.PayloadWrapper();
            payload.assetName = 'In Complete Cover Letter';
            payload.contactId = contactId;
            payload.documentType = Constants.ASSET_TYPE_VERIFICATION_FORM;
            payload.assetRecordType = Constants.ASSET_RECORD_TYPE_VERIFICATION;
            payload.createOrReplace = 'create';
            payload.caseId = String.valueOf(caserecId);
            payload.assetCreationRequired = 'true';
            payload.assetStatus = Constants.ASSET_STATUS_NEW;
            payload.createFromPB = 'true';
        }catch(Exception e){
                throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
        return true;
    }
    
    // Delete the previously available asset before creating new assets (Verification_Cover_Letter or Universal_Verification_Form)
    public static LIST<Asset> markForDeletionPrevAssets(String assetName, String assetType, String contactId){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(string.isnotBlank(assetName)){
			for(Asset a : [SELECT id FROM Asset WHERE ContactId =: contactId AND Name =: assetName AND Type__c =: assetType AND status =: Constants.ASSET_STATUS_NEW WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }         
        }
        return assetsToUpdateList;
    }

    public static void httpCalloutAzureBlob(String fileName, String payload, Blob document){
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

    public static void createSendRequest(Case cse, String sendReqJson){
        try{
            Map<String, Object> sendReqJsonMap = (Map<String, Object>) JSON.deserializeUntyped(sendReqJson);
            Verification_Packet__c verPack = [SELECT Id FROM Verification_Packet__c WHERE Case__c =: cse.Id AND Is_Active__c = true WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            Send_Request__c sendReq = new Send_Request__c();
            String courierType = Constants.COURIER_TYPE_FEDEX;
            if(cse.Service__c == Constants.CASE_SERVICE_FCVS || cse.Service__c == Constants.CASE_SERVICE_EICS){
                courierType = String.valueOf(sendReqJsonMap.get('courierType'));
                sendReq.Third_Party_Courier__c = String.valueOf(sendReqJsonMap.get('courAccount'));
            }
            sendReq.Verification_Packet__c = verPack.Id;
            sendReq.Send_Method__c = cse.Send_Method__c;
            sendReq.Request_sent_via_courier__c = Boolean.valueOf(sendReqJsonMap.get('reqSentViaCour'));
            sendReq.Courier_fee_payable_by__c = String.valueOf(sendReqJsonMap.get('courFeePayableBy'));
            sendReq.Courier_Account__c = String.valueOf(sendReqJsonMap.get('courAccount'));
            sendReq.ZK_Account__c = courierType;
            if(cse.Send_Method__c == Constants.CASE_SEND_METHOD_ENTITY_PORTAL){
                sendReq.Current_Send_Date__c = System.today();
                sendReq.Send_By__c = UserInfo.getUserId();
            }
            if(cse.Send_Method__c == Constants.CASE_SEND_METHOD_PAPER){
                Map<String,String> addressMap = getEntityDetail(cse);
                sendReq.City__c = addressMap.containsKey('city') ? addressMap.get('city') : '';
                sendReq.Street__c = addressMap.containsKey('street') ? addressMap.get('street') : '';
                sendReq.State__c = addressMap.containsKey('state') ? addressMap.get('state') : '';
                sendReq.Country__c = addressMap.containsKey('country') ? addressMap.get('country') : '';
                sendReq.Postal_Code__c = addressMap.containsKey('zip') ? addressMap.get('zip') : '';
                sendReq.Email__c = addressMap.containsKey('email') ? addressMap.get('email') : '';
                sendReq.Account_Name__c = addressMap.containsKey('name') ? addressMap.get('name') : '';
                sendReq.Phone__c = addressMap.containsKey('name') ? addressMap.get('phone') : '';
            }
            if(Schema.sObjectType.Send_Request__c.isCreateable()){
                INSERT sendReq;
                updateCredVerCaseStatus(cse, sendReq);
            }
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static Map<String,String> getEntityDetail(Case cse){
        String entityId = '';
        String affirmRT = '';
        String mefRT = Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        String cvRT = Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION;
        Map<String,String> addressMap = new Map<String,String>();
        Affirmation__c affirm = [SELECT Id, Verify_with_Alternate_Entity__c,Case__r.Alternate_Entity__c,Case__r.Entity__c,RecordType.Name FROM Affirmation__c WHERE (RecordType.DeveloperName=:mefRT OR RecordType.DeveloperName=:cvRT) AND Case__c=:cse.Id WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
        if(affirm.Verify_with_Alternate_Entity__c && affirm.Case__r.Alternate_Entity__c != null){
            entityId = affirm.Case__r.Alternate_Entity__c;
        }else if(affirm.Case__r.Entity__c != null){
            entityId = affirm.Case__r.Entity__c;
        }
        affirmRT = affirm.RecordType.Name;
        LIST<Account2Service__c> acc2serList = [SELECT Id,Name,Account__c,Service__r.Name FROM Account2Service__c WHERE Account__c=:entityId AND Service__r.Name=:affirmRT WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
        if(!acc2serList.isEmpty()){
            addressMap = getCont2AcctService(acc2serList[0].Id, cse);
        }
        Account acc = [SELECT Id,Name,Phone,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry FROM Account WHERE Id=:entityId WITH SECURITY_ENFORCED];
        if(addressMap.isEmpty()){
            addressMap.put('city',acc.BillingCity);
            addressMap.put('street',acc.BillingStreet);
            addressMap.put('state',acc.BillingState);
            addressMap.put('country',acc.BillingCountry);
            addressMap.put('zip',acc.BillingPostalCode);
        }
        List<Additional_Info__c> addInfo = [SELECT Id,Value__c,Account__c,Type__c FROM Additional_Info__c WHERE Account__c=:entityId AND Type__c=:Constants.CASE_SEND_METHOD_EMAIL WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
        if(!addInfo.isEmpty()){
            addressMap.put('email',addInfo[0].Value__c);
        }
        addressMap.put('name',acc.Name);
        addressMap.put('phone',acc.Phone);
        return addressMap;
    }
    public static Map<String,String> getCont2AcctService(String accServId, Case cse){
        Map<String,String> addressMap = new Map<String,String>();
        LIST<CONTACT2ACCTSERVICE__c> con2accserList = [SELECT Id,Account_Service__c,City__c,Street__c,Country__c,State__c,Postal_Code__c 
                                                        FROM CONTACT2ACCTSERVICE__c 
                                                        WHERE Account_Service__c=:accServId 
                                                            AND Credential_Type__c=:cse.Document_Type__c 
                                                            AND Preferred_mode_of_communication__c=:cse.Send_Method__c
                                                            WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
        if(!con2accserList.isEmpty()){
            if(con2accserList[0].City__c != null){
                addressMap.put('city',con2accserList[0].City__c);
            }
            if(con2accserList[0].Street__c != null){
                addressMap.put('street',con2accserList[0].Street__c);
            }
            if(con2accserList[0].State__c != null){
                addressMap.put('state',con2accserList[0].State__c);
            }
            if(con2accserList[0].Country__c != null){
                addressMap.put('country',con2accserList[0].Country__c);
            }
            if(con2accserList[0].Postal_Code__c != null){
                addressMap.put('zip',con2accserList[0].Postal_Code__c);
            }
        }
        return addressMap;
    }
    //Method to get RecordType Developer Name from Case Id;
    @AuraEnabled
    public static String getCaseRecTypeDevName(Id caseId){
        try{
            Case caseRec = [SELECT Id, recordType.DeveloperName FROM Case WHERE Id =: caseId];
            return caseRec.recordType.DeveloperName;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<String> getCourierTypePicklistValues(){
        try{
            List<String> pickListValuesList = new List<String>();
            Schema.DescribeFieldResult fieldResult = Send_Request__c.ZK_Account__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<AssetMergeWrapper> getAssetsForMerge(String recordId){
        try{
            List<Asset> asstList = new List<Asset>();
            List<AssetMergeWrapper> wrapList = new List<AssetMergeWrapper>();
            Case cse = [SELECT Id, ContactId, Service__c, CaseNumber, RecordTypeId FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
            if(cse.RecordTypeId == Constants.MEDEDUFORMID){
                asstList = getMedEduFormAssets(cse);
            }else if(cse.RecordTypeId == Constants.CVRECORDTYPEID){
                asstList = getCvAssets(cse);
            }
            for(Asset asst : asstList){
                wrapList.add(new AssetMergeWrapper(asst, cse.CaseNumber));
            }
            Return wrapList;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static List<Asset> getCvAssets(Case cvCase){
        try{
            List<Asset> asstList = new List<Asset>();
            Set<Id> vpAssetIds = new Set<Id>();
            List <Verification_Packet__c> verPack = [SELECT Id, (SELECT Asset__c FROM Asset2VerificationsVP__r WHERE Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SOURCE OR (Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT AND Asset_Type__c =: Constants.ASSET_TYPE_TRANSLATION) 
                                                     OR Document_Type__c =: Constants.ASSET2VER_DOCTYPE_NEW_VER_FORM) FROM Verification_Packet__c WHERE Case__c =: cvCase.Id AND Is_Active__c = true WITH SECURITY_ENFORCED];
            For(Asset2Verification__c a2v: verPack[0].Asset2VerificationsVP__r){
                vpAssetIds.add(a2v.Asset__c);
            }
            List<Asset> vpAssets = [SELECT Id, Azure_Storage_URL__c, Name, Type__c FROM Asset WHERE Id IN: vpAssetIds WITH SECURITY_ENFORCED];
            List<Asset> vpAssetsCred = new List<Asset>();
            List<Asset> vpAssetsTrans = new List<Asset>();
            List<Asset> vpAssetsVer = new List<Asset>();
            List<Asset> photoAssets = new List<Asset>();
            List<Asset> otherAssets = new List<Asset>();
            for(Asset vpAsset: vpAssets){
                if(vpAsset.Type__c == Constants.ASSET_TYPE_VERIFICATION_FORM){
                    vpAssetsVer.add(vpAsset);
                }else if(vpAsset.Type__c == Constants.ASSET_TYPE_TRANSLATION){
                    vpAssetsTrans.add(vpAsset);
                }else{
                    vpAssetsCred.add(vpAsset);
                }
            }
            Set<String> contactAssetNames = new Set<String>();
            if(label.redactedAssetServices.split(',').contains(cvCase.service__c)){
                contactAssetNames.add(Constants.ASSET_NAME_REDACTED_ID_FORM);
            }else if(label.photoReleaseAssetServices.split(',').contains(cvCase.service__c)){
                contactAssetNames.add(Constants.ASSET_NAME_PHOTO);
                contactAssetNames.add(constants.ASSET_NAME_MCC_RELEASE_FORM);
            }
            List<Asset> contactAssets = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE ContactId =: cvCase.contactId AND Name IN: contactAssetNames AND status =: Constants.ASSET_STATUS_VERIFIED WITH SECURITY_ENFORCED];
            for(Asset contactAsset : contactAssets){
                if(contactAsset.Name ==Constants.ASSET_NAME_PHOTO){
                    photoAssets.add(contactAsset);
                }else{
                    otherAssets.add(contactAsset);
                }
            }
            asstList.addAll(photoAssets);  
            asstList.addAll(otherAssets);
            asstList.addAll(vpAssetsTrans);
            asstList.addAll(vpAssetsCred);
            asstList.addAll(vpAssetsVer);
            return asstList;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static List<Asset> getMedEduFormAssets(Case medEduCase){
        try{
            List<Asset> assetList = new List<Asset>();
            Id medEduAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
            List<Asset> medEduFormAsset = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE Type__c =: Constants.ASSET_TYPE_MED_EDU_FORM AND Name =: Constants.ASSET_TYPE_MED_EDU_FORM AND RecordTypeId =: medEduAsstRecTypeId AND Case__c =: medEduCase.Id WITH SECURITY_ENFORCED];
            List<Asset> fmdAssets = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE ContactId =: medEduCase.contactId AND Type__c =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA  AND (status =: Constants.ASSET_STATUS_VERIFIED OR status =: Constants.ASSET_STATUS_ACCEPTED) WITH SECURITY_ENFORCED];
            List<Asset> fmstAssets = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE ContactId =: medEduCase.contactId AND Type__c =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT  AND (status =: Constants.ASSET_STATUS_VERIFIED OR status =: Constants.ASSET_STATUS_ACCEPTED) WITH SECURITY_ENFORCED];
            Set<String> contactAssetNames = new Set<String>();
            if(label.redactedAssetServices.split(',').contains(medEduCase.service__c)){
                contactAssetNames.add(Constants.ASSET_NAME_REDACTED_ID_FORM);
            }else if(label.photoReleaseAssetServices.split(',').contains(medEduCase.service__c)){
                contactAssetNames.add(constants.ASSET_NAME_MCC_RELEASE_FORM);
            }
            List<Asset> contactAssets = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE ContactId =: medEduCase.contactId AND Name IN: contactAssetNames AND Status =: Constants.ASSET_STATUS_VERIFIED WITH SECURITY_ENFORCED];
            assetList.addAll(contactAssets);
            assetList.addAll(fmstAssets);
            assetList.addAll(fmdAssets);
            assetList.addAll(medEduFormAsset);
            Return assetList;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public class AssetMergeWrapper{
        @AuraEnabled public String id {get; set;}     
        @AuraEnabled public String fileName {get; set;}      
        @AuraEnabled public String base64 {get; set;}
        @AuraEnabled public String fileExtension {get; set;}
        @AuraEnabled public String caseNumber {get; set;}
        public AssetMergeWrapper(Asset asst, String caseNum){           
            this.id = asst.Id;
            this.caseNumber = caseNum;
            if(String.isNotBlank(asst.Azure_Storage_URL__c)){
                String ext = asst.Azure_Storage_URL__c.split('/')[4].split('\\.')[1];
                this.fileName = asst.name + '.' + ext;
                this.fileExtension = ext;
                String file = asst.Azure_Storage_URL__c.split('/')[4];
                this.base64 = CloudStorageUtils.getFileUrlWithSAS(file);
            }
        }
    }    
}