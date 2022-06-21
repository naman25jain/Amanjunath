public with sharing class MedEduController{
    @AuraEnabled
    public static string createMedEduForm(String caseRecordId){
        try{
            List<Case> medEduCase = [SELECT Id, AccountId, ContactId, Contact.Email, Alternate_Entity__c, Entity__c FROM Case WHERE Id =: caseRecordId WITH SECURITY_ENFORCED];
            String entityUserId = string.valueOf(AppForCertHelper.retrieveCurrentContactId());
            String selectedEntityId = getSelectedEntityId(medEduCase[0]);
            List<Id> docConfigIds = new List<Id>();
            List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
            List<Asset> medEduFormAssetList = new List<Asset>();
            medEduFormAssetList = [SELECT Id FROM Asset WHERE Case__c =: caseRecordId AND Type__c =: constants.ASSET_TYPE_MED_EDU_FORM AND Status =: constants.ASSET_STATUS_NEW WITH SECURITY_ENFORCED];
            docConfiList = [SELECT Id, cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c =: Constants.DOCCONFIG_MED_EDU_FORM WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigIds.add(docConfiList[0].Id);    
            }
            cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel();
            cdm.docConfigIds = docConfigIds;
            cdm.objectId = caseRecordId;
            cdm.pdfActionType = 'NONE';
            cdm.parameters = new cadmus_core.CadmusParameters();
            cadmus_core.CadmusKeyValue cadmusKeyValue = new cadmus_core.CadmusKeyValue();
            cadmusKeyValue.key = 'entityUserId';
            cadmusKeyValue.valueString = entityUserId;
            cdm.parameters.values.add(cadmusKeyValue);
            cadmus_core.CadmusKeyValue cadmusKeyValue1 = new cadmus_core.CadmusKeyValue();
            cadmusKeyValue1.key = 'entityId';
            cadmusKeyValue1.valueString = selectedEntityId;
            cdm.parameters.values.add(cadmusKeyValue1);
            string returnVal = '';
            Actionable_UploadDocumentToAzureBlob.PayloadWrapper payload = new Actionable_UploadDocumentToAzureBlob.PayloadWrapper();
            payload.contactId = String.valueOf(medEduCase[0].ContactId);
            payload.assetName = Constants.ASSET_NAME_RETURNED_MED_EDU_FORM;
            payload.documentType = Constants.ASSET_TYPE_MED_EDU_FORM;
            payload.assetRecordType = Constants.ASSET_RECORD_TYPE_MED_EDU_FORM;
            payload.createOrReplace = 'replace';
            payload.caseId = caseRecordId;
            payload.accountId = String.valueOf(medEduCase[0].AccountId);
            payload.assetCreationRequired = 'true';
            payload.assetStatus = Constants.ASSET_STATUS_NEW;
            payload.createFromPB = 'true';
            String fileName = String.valueOf(medEduCase[0].ContactId) + '_Returned_Medical_Education_Form';
            Datetime dt = System.now();
            fileName = fileName + '_' + dt.year() + '-' + dt.month() + '-' + dt.day() + '_' + dt.hour() + '_' + dt.minute() + '_' + dt.second() + '.pdf';
            String jsonStrPIA = CloudStorageController.getRequestHeaders('CREATE_UPDATE', fileName, '', JSON.serialize(payload));
            Map<String, Object> header = (Map<String, Object>)JSON.deserializeUntyped(jsonStrPIA);
            if(!test.isRunningTest()){
                cadmus_core.DocGenerationWrapper result = cadmus_core.ConvertController.convertWithWrapper(cdm);
                Blob document = result.response.base64;
                Http ht = new Http();
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod('PUT');
                httpRequest.setHeader('Content-Length', '0');
                httpRequest.setHeader('x-ms-blob-type', 'BlockBlob');
                httpRequest.setHeader('Content-Type', 'application/pdf');
                httpRequest.setHeader('x-ms-version', '2019-02-02');
                httpRequest.setHeader('x-ms-meta-Payload', JSON.serialize(payload));
                httpRequest.setEndpoint(String.valueOf(header.get('FileUrlWithToken')));
                httpRequest.setBodyAsBlob(document);
                ht.send(httpRequest);
            }
            CloudStorageController.processResponse(JSON.serialize(payload), String.valueOf(header.get('FileUrl')));
            returnVal = String.valueOf(header.get('FileUrl'));
            linkAssetToVP(caseRecordId, returnVal);
            if(!medEduFormAssetList.isEmpty()){
                deletemedEduFormAssetList(medEduFormAssetList);
            }
            return returnVal;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void deleteMedEduFormAssetList(List<Asset> medEduFormAssetList){
        try{
            List<RecordType> recordTypes = new List<RecordType> ();
            List<Asset> medEduFormAssetListToDelete = new List<Asset>();
            recordTypes = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
            For(Asset eachAsset : medEduFormAssetList){
                eachAsset.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                eachAsset.case__c = null;
                eachAsset.RecordTypeId = recordTypes[0].Id;
                medEduFormAssetListToDelete.add(eachAsset);
            }
            if(Asset.SObjectType.getDescribe().isUpdateable() && !medEduFormAssetListToDelete.isEmpty()){
                UPDATE medEduFormAssetListToDelete;
            }
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void linkAssetToVP(String caseRecordId, String returnVal){
        try{
            List<Verification_Packet__c> packetList = new List<Verification_Packet__c>();
            List<Asset2Verification__c> asset2VerPacketList = new List<Asset2Verification__c>();
            packetList = [Select Id From Verification_Packet__c where case__c =: caseRecordId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            String verificationPackageId = '';
            if(!packetList.isEmpty()){
                verificationPackageId = packetList[0].Id;
            }
            asset2VerPacketList = [Select Id FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND Document_Type__c =: Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM WITH SECURITY_ENFORCED];
            Asset2Verification__c a2v = new Asset2Verification__c();
            if(!asset2VerPacketList.isEmpty()){
                a2v.Id = asset2VerPacketList[0].Id;
            }
            a2v.Verification_Packet__c = verificationPackageId;
            List<Asset> ass = new List<Asset>();
            ass = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c =: returnVal ORDER BY CREATEDDATE DESC LIMIT 1];
            if(!ass.isEmpty()){
                a2v.Asset__c = ass[0].Id;
            }
            a2v.Azure_Document_URL__c = returnVal;
            a2v.Document_Type__c = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM;
            if(Schema.sObjectType.Asset2Verification__c.isCreateable() && Schema.sObjectType.Asset2Verification__c.isUpdateable()){
                UPSERT a2v;
            }
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static Id getSelectedEntityId(Case medEduCase){
        try{
            Id recTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
            List<Affirmation__c> aff = [SELECT Verify_with_Alternate_Entity__c FROM Affirmation__c WHERE Case__c =: medEduCase.Id AND RecordTypeId =: recTypeId  WITH SECURITY_ENFORCED];
            if(!aff.isEmpty() && aff[0].Verify_with_Alternate_Entity__c){
                return medEduCase.Alternate_Entity__c;
            }
            return medEduCase.Entity__c;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean updateCaseStatus(String caseRecordId){
        try{
            List<Case> caseToUpdate =  [SELECT Internal_Status__c FROM Case WHERE Id =: caseRecordId WITH SECURITY_ENFORCED];
            List<Asset> medEduForm = [SELECT Id FROM Asset WHERE Case__c =: caseRecordId AND Type__c =: constants.ASSET_TYPE_MED_EDU_FORM AND Status =: constants.ASSET_STATUS_NEW WITH SECURITY_ENFORCED];
            if(!caseToUpdate.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                caseToUpdate[0].Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
                UPDATE caseToUpdate[0];
            }
            if(!medEduForm.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
                medEduForm[0].Status = Constants.ASSET_STATUS_ACCEPTED;
                medEduForm[0].Name = Constants.ASSET_NAME_ACCEPTED_MED_EDU_FORM;
                UPDATE medEduForm[0];
            }
            Verification_Packet__c verPckts = [SELECT Id, (SELECT Id FROM Send_Requests__r WHERE Is_Deleted__c = false ORDER BY createddate DESC LIMIT 1) FROM Verification_Packet__c WHERE Case__c =: caseRecordId AND Is_Active__c = True WITH SECURITY_ENFORCED];
            List<Send_Request__c> sendReqList = new List<Send_Request__c>();
            for(Send_Request__c sendReqRec:verPckts.Send_Requests__r){
                sendReqRec.Received_Date__c = System.today();
                sendReqList.add(sendReqRec);
            }
            if(!sendReqList.isEmpty() && Send_Request__c.SObjectType.getDescribe().isUpdateable()){
                update sendReqList;
            }
            return true;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Fetches the contact association type record if one exists in the case record. 
    @AuraEnabled(cacheable = true)
    public static Contact_Association_Type__c getMedEduCAT(string caseId){
        try{
            List<Contact_Association_Type__c> catRecList = [SELECT Id,Individual_was_conferred_issued_degree__c,Degree_Title__c,Degree_Issue_Date__c,Reason_for_not_conferred_issued_degree__c
            ,Years_of_education_required__c,Credential_degree_presented_by_applicant__c,Total_weeks_of_medical_education__c,Attendance_Start_Date__c,Attendance_End_Date__c
            ,Transfer_Credit_to_Degree_School__c,Institution_s_credits_transferred_from__c,Interruptions_extensions__c,Personal_Family__c,Personal_Family_from_month__c
            ,Personal_Family_from_year__c,Personal_Family_to_month__c,Personal_Family_to_year__c,Personal_Family_Reason_Approved__c,Academic_remediation__c,Academic_remediation_from_month__c
            ,Academic_remediation_from_year__c,Academic_remediation_to_month__c,Academic_remediation_to_year__c,Academic_remediation_reason_approved__c
            ,Health__c,Health_from_month__c,Health_from_year__c,Health_to_month__c,Health_to_year__c,Health_reason_approved__c,Financial__c,Financial_from_month__c
            ,Financial_from_year__c,Financial_to_month__c,Financial_to_year__c,Financial_reason_approved__c,Joint_degree_program__c,Joint_degree_program_from_month__c,Joint_degree_program_from_year__c
            ,Joint_degree_program_to_month__c,Joint_degree_program_to_year__c,Joint_degree_program_approved__c,Non_research_special_study__c,Non_research_special_study_from_month__c
            ,Non_research_special_study_from_year__c,Non_research_special_study_to_month__c,Non_research_special_study_to_year__c,Non_research_special_study_approved__c
            ,Non_degree_research__c,Non_degree_research_from_month__c,Non_degree_research_from_year__c,Non_degree_research_to_month__c,Non_degree_research_to_year__c 
            ,Non_degree_research_reason_approved__c,Other_from_month__c,Other_from_year__c,Other_to_month__c,Other_to_year__c,Other_reason_approved__c
            ,Other__c,Other_Details__c,On_academic_or_disciplinary_probation__c,Academic_probation__c,Academic_probation_from_month__c,Academic_probation_from_year__c,Academic_probation_to_month__c
            ,Academic_probation_to_year__c,Probation_for_unprofessional_conduct__c,Unprofessional_conduct_from_month__c,Unprofessional_conduct_from_year__c,Unprofessional_conduct_to_month__c
            ,Unprofessional_conduct_to_year__c,Probation_for_other_reason__c,Probation_for_other_reason_from_month__c,Probation_for_other_reason_from_year__c,Probation_for_other_reason_to_month__c
            ,Probation_for_other_reason_to_year__c,Probation_for_other_reason_details__c,Disciplined_for_unprofessional_conduct__c,Detail_of_unprofessional_conduct__c,Negative_reports_or_an_investigation__c
            ,Detail_of_negative_report_investigation__c,Limitations_special_requirements_imposed__c,Detail_of_limitation_special_requirement__c FROM Contact_Association_Type__c WHERE Case__c =: caseId AND recordType.DeveloperName =: system.label.CAT_Medical_Education_Questionnaire_Record_Type WITH SECURITY_ENFORCED ORDER BY createdDate DESC LIMIT 1];
            if(!catRecList.isEmpty()){
                return catRecList[0];
            }else{
                return null;
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
}