public with sharing class CloudStorageController{
    //method to create request headers for azure blob create/update
    @AuraEnabled
    public static String getRequestHeaders(String documentAccessLevel,
        String fileName,
        String fileExt,
        String payLoad){
        try {
            if (fileName == ''){
                fileName = CloudStorageUtils.createGuidBasedFileName(fileExt);
            }
            DocumentEnums.DocumentAccessLevel accessLevel = accessLevels.get(documentAccessLevel);
            CloudStorageParameters requestHeaders = CloudStorageUtils.getRequestHeaders(accessLevel, fileName, payLoad);
            return JSON.serialize(requestHeaders);
        } catch (Exception e){
            throw e;
        }
    }
    //method to get the appropriate request url for azure
    @AuraEnabled
    public static String getRequestUrl(String documentAccessLevel,
        String fileName){
        try {
            DocumentEnums.DocumentAccessLevel accessLevel = accessLevels.get(documentAccessLevel);
            return CloudStorageUtils.getRequestUrl(accessLevel, fileName);
        } catch (Exception e) {
            throw e;
        }
    }
    //to create cloud document with payload corresponding to uploaded document 
    @AuraEnabled
    public static void processResponse(String payload,
        String url){
        try {
            switch on CloudStorageUtils.STORAGE_MODE {
                when 'LOCAL' {
                    createCloudDocument(payload, url);
                }
            }
        } catch (Exception e) {
            throw e;
        }
    }
    //method to create cloud document with payload corresponding to uploaded document
    @TestVisible
    private static void createCloudDocument(String payload,
        String url){
        try {

            Cloud_Document__c newDocument = new Cloud_Document__c();
            newDocument.payload__c = payload;
            newDocument.Url__c = url;
            insert newDocument;           
        } catch (Exception e) {
            throw e;
        }
    }
    //to get different access levels from enum DocumentAccessLevel
    @TestVisible
    private static Map<String, DocumentEnums.DocumentAccessLevel > accessLevels {
        get {
            if (accessLevels == null) {
                accessLevels = new Map<String, DocumentEnums.DocumentAccessLevel > ();
                for (DocumentEnums.DocumentAccessLevel accesslevel: DocumentEnums.DocumentAccessLevel.values()) {
                    accessLevels.put(accesslevel.name(), accesslevel);
                }
            }
            return accessLevels;
        }
        private set;
    }    
    //to generate filename for the document to be uploded
    @AuraEnabled
    public static String fileNameGenerator(String contactId,
        String documentType, String azureDocUrl, String createOrReplace, String assetId){
        String type = documentType.replace(' ', '_').replace('/', '_');
        List<Asset> inProgressAssetList = new List<Asset>();
        inProgressAssetList = [Select Id, Azure_Storage_URL__c From Asset where contactId =: contactId AND Name =: documentType AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED];
        String fileUniqueName = contactId + '_' + type + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
        String fileName = '';
        List<String> assetTypeList = new List<String>();
        assetTypeList.add(Constants.ASSET_TYPE_TCT);
        assetTypeList.add(Constants.ASSET_NAME_TCT_TRANSLATION);
        assetTypeList.add(Constants.ASSET_TYPE_NAME_DOC);
        assetTypeList.add(Constants.ASSET_TYPE_PRE_MED_LETTER);
        assetTypeList.add(Constants.ASSET_NAME_PML_TRANSLATION);
        assetTypeList.add(Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM);
        assetTypeList.add(Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION);
        if(assetTypeList.contains(documentType) && String.isNotBlank(assetId)){
            List<Asset> assetList = [Select Id, Azure_Storage_URL__c From Asset where contactId =: contactId AND Name =: documentType AND status =: Constants.ASSET_STATUS_IN_PROGRESS AND Id =:assetId WITH SECURITY_ENFORCED];
            if(!assetList.isEmpty()){
                String fileURL = assetList[0].Azure_Storage_URL__c;
                fileUniqueName = getNameFromUrl(fileURL);
            }
        }
        if(!inProgressAssetList.isEmpty()){
            String fileNameURL = inProgressAssetList[0].Azure_Storage_URL__c;
            fileName = getNameFromUrl(fileNameURL);
        }else{
            fileName = fileUniqueName;
        }
        if(createOrReplace == 'Replace'){
            fileUniqueName = fileName;
        }
        if(String.isNotBlank(azureDocUrl)){
            fileUniqueName = getNameFromUrl(azureDocUrl);
        }
        if(createOrReplace == 'ReplaceInternal'){
            fileUniqueName = getExistingFileName(fileUniqueName, documentType, assetId);
        }
        return fileUniqueName;
    }
    // Method to check if asset is of ERAS and Outdating old assets of the same type and name
    public static void checkErasAssetAndOutdateOld(List<asset> asstList){
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        List<Asset> erasAssets = new List<Asset>();
        Set<Id> asstCaseId = new Set<Id>();
        Set<Id> erasCaseIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        for(Asset asst : asstList) {
            asstCaseId.add(asst.case__c);
        }
        caseList = [Select Id FROM Case where Id in :asstCaseId AND RecordTypeId =: erasRecordTypeId WITH SECURITY_ENFORCED];
        for(Case cs : caseList) {
            erasCaseIds.add(cs.Id);
        }
        for(Asset asst : asstList) {
            if(erasCaseIds.contains(asst.Case__c)) {
                erasAssets.add(asst);
            }
        }
        outdateAssets(erasAssets);
    }
    // Method to take New Assets and Outdate old Assets of same Type and Name
    public static void outdateAssets(List<Asset> assetList){
        List<Asset> oldAssetsList = new List<Asset>();
        Set<Id> newAssetIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> assetType = new Set<String>();
        Set<String> assetName = new Set<String>();
        Set<Id> caseIds = new Set<Id>();
        for(Asset newAsst : assetList) {
            newAssetIds.add(newAsst.id);
            if(newAsst.parentId != null){
                newAssetIds.add(newAsst.parentId);
            }
            contactIds.add(newAsst.ContactId);
            assetName.add(newAsst.Name);
            assetType.add(newAsst.Type__c);
            caseIds.add(newAsst.Case__c);
        }
        oldAssetsList = [SELECT Id,Status FROM Asset WHERE ContactId in :contactIds AND Name in :assetName AND type__c in :assetType AND Id not in :newAssetIds AND case__c in :caseIds
                    AND ParentId NOT IN :newAssetIds AND status !=: Constants.ASSET_STATUS_OUTDATED  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
        for (Asset oldAsset : oldAssetsList) {
            oldAsset.Status = Constants.ASSET_STATUS_OUTDATED;
        }
        if(Asset.SObjectType.getDescribe().isUpdateable() && !oldAssetsList.isEmpty()){
            try{
                Update oldAssetsList;
            }catch(Exception ex){
                throw ex;
            }    
        }
    }
    //Method to get filename for the document to be uploded is ReplaceInternal
    public static String getExistingFileName(String fileUniqueName, String documentType, String assetId){
        List<Asset> assetList = new List<Asset>();
        if(documentType == 'Returned Verification Form' || documentType == 'Returned Credential' || documentType == 'Verification Form' || documentType == 'Verified Credential'|| documentType == 'Returned Envelope'){
            assetList = [Select Id, Azure_Storage_URL__c From Asset where Id =: assetId WITH SECURITY_ENFORCED];
        }else{
            assetList = [Select Id, Azure_Storage_URL__c From Asset where status =: Constants.ASSET_STATUS_IN_PROGRESS AND Id =: assetId WITH SECURITY_ENFORCED];
        }
        if(!assetList.isEmpty()){
            String fileURL = assetList[0].Azure_Storage_URL__c;
            fileUniqueName = getNameFromUrl(fileURL);
        }
        return fileUniqueName;
    }    
    //Method to create assets from process builder based on payload on creation of cloud document
    @InvocableMethod
    public static void createAssetsPBAction(List<Cloud_document__c> cloudDocs){
        List<PayloadWrapper> payloadWrapperList = new List<PayloadWrapper>();
        List<String> azureStorageUrlList = new List<String>();
        List<String> parentUrlList = new List<String>();
        List<Id> contactIdList = new List<Id>();
        Map<Id, Cloud_document__c> cloudDocMap = new Map<Id, Cloud_document__c>();
        Map<Id, PayloadWrapper> cloudDocPayloadMap = new Map<Id, PayloadWrapper>();
        Map<String, Id> azureUrlAssetIdMap = new Map<String, Id>();
        Map<String, Id> azureUrlParentAssetIdMap = new Map<String, Id>();
        Boolean isUpdateProductOrParentAssets = false;
        Boolean isAssetCreationWrapper = false;
        String azureStorageURL;
        PayloadWrapper payload;
        if(!cloudDocs.isEmpty()){
            for(Cloud_document__c cd:cloudDocs){
                cloudDocMap.put(cd.Id, cd);
                payloadWrapperList.add((PayloadWrapper)JSON.deserialize(cd.payload__c, PayloadWrapper.class));
                azureStorageUrlList.add(cd.url__c);
                cloudDocPayloadMap.put(cd.Id, (PayloadWrapper)JSON.deserialize(cd.payload__c, PayloadWrapper.class));
            }
        }
        for(PayloadWrapper pw:payloadWrapperList){
            if(pw.contactId !=null){
                contactIdList.add(pw.contactId);
            }
            if(pw.parentUrl !=null){
                parentUrlList.add(pw.parentUrl);
            }
        }
        if(!contactIdList.isEmpty()){
            List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN :azureStorageUrlList AND contactId IN :contactIdList WITH SECURITY_ENFORCED];
            for(Asset assetIter: assetList){
                azureUrlAssetIdMap.put(assetIter.Azure_Storage_URL__c, assetIter.Id);
            }     
        }
        if(!parentUrlList.isEmpty()){
            List<Asset> parentAssetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN :parentUrlList AND ContactId != null WITH SECURITY_ENFORCED];
            for(Asset asstIter: parentAssetList){
                azureUrlParentAssetIdMap.put(asstIter.Azure_Storage_URL__c, asstIter.Id);
            }
        }
        List<Asset> assetsToInsertList = new List<Asset>();
		List<Asset> assetSizesToUpdate = new List<Asset>();
        for(Cloud_document__c cdIter: cloudDocs){
            if(!azureUrlAssetIdMap.containsKey(cdIter.url__c) && cloudDocPayloadMap.get(cdIter.Id).assetCreationRequired == 'true' && cloudDocPayloadMap.get(cdIter.Id).isUploadLocation != Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB){
                Asset asst = new Asset();
                asst = assetCreatePBLogic(asst, cloudDocMap.get(cdIter.Id).Url__c, cloudDocPayloadMap.get(cdIter.Id), azureUrlParentAssetIdMap);
                assetsToInsertList.add(asst);
            }
            if(cloudDocPayloadMap.get(cdIter.Id).assetId != null && cloudDocPayloadMap.get(cdIter.Id).size != null){
                assetSizesToUpdate.add(new Asset(Id=cloudDocPayloadMap.get(cdIter.Id).assetId, File_Size__c=cloudDocPayloadMap.get(cdIter.Id).size));
            }
            if(cloudDocPayloadMap.get(cdIter.Id).isUploadLocation == Constants.ASSET_UPLOAD_LOCATION_DOCEDITTAB){
                isUpdateProductOrParentAssets = true;
            }
            if(cloudDocPayloadMap.get(cdIter.Id).isUploadLocation == Constants.ASSET_UPLOAD_LOCATION_RELATEDTAB){
                isAssetCreationWrapper = true;
            }
            payload = cloudDocPayloadMap.get(cdIter.Id);
            azureStorageURL = cloudDocMap.get(cdIter.Id).Url__c;
        } 
        Boolean updateAssetRequired = true;
        if(!assetsToInsertList.isEmpty() && Asset.SObjectType.getDescribe().isCreateable()){
            updateAssetRequired = false;
            INSERT assetsToInsertList;
        }
        if(!assetsToInsertList.isEmpty() && isUpdateProductOrParentAssets){
            updateParent(payload.documentType, assetsToInsertList[0].Id, payload.catId);
            updateProductFields(payload.documentType, assetsToInsertList[0].Id);            
        }
        if(isAssetCreationWrapper){
            updateAssetRequired = false;
            AssetCreationWrapperController.createAsset(azureStorageURL, payload);
        }
        if(!assetsToInsertList.isEmpty() && assetsToInsertList[0].Type__c == Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE){
            getNewServiceTemplate(assetsToInsertList);
        }
        if(updateAssetRequired && !assetSizesToUpdate.isEmpty() && assetSizesToUpdate.size() > 0){
            update assetSizesToUpdate;
        }
    }
    // Creating Asset List - refactored logic for createAssetsPBAction method
    public static asset assetCreatePBLogic(Asset asst, String url, PayloadWrapper payload, Map<String, Id> azureUrlParentAssetIdMap){
        asst.Name = payload.assetName != '' && payload.assetName != null ? payload.assetName : payload.documentType;
        asst.Azure_Storage_URL__c = url;
        createAsset2VerificationRecord(url, payload);
        String type = payload.type != '' && payload.type != null ? payload.type : payload.documentType;
        asst.type__c = type;
        asst.File_Size__c = payload.size;
        switch on payload.documentType{
            when 'Passport Translation Page','Passport Expiration Page'{
                asst.type__c = 'Passport';
            }
            when 'TCT Translation','Final Diploma Translation', 'Pre-Med Letter Translation','Final Transcript Translation','Letter from Dean Translation'{
                asst.type__c = 'Translation';
            }
            when 'Pre-Med Letter'{
                asst.Type__c = 'Pre-Med Letter';
            }
            when 'TCT Name Document','Final Diploma Name Document','Final Transcript Name Document', 'Pre-Med Letter Name Document','Letter from Dean Name Document'{
                asst.type__c = 'Name Document';
                asst.Name = 'Name Document';
            }
            when 'ID Form Notarized', 'Redacted ID Form'{
                asst.Type__c = 'ID Verification';
            }
            when 'Authorized Signature List'{
                asst.Type__c = 'Authorized Signature List';
            }
            when else{
                asst.type__c = type;
            }
        }
        if(payload.sourceDocument == 'true'){
            asst.Source_Document__c = true;
        }
        asst.Uploaded_by_applicant__c = checkUploadedByApplicantflag(payload);
        if(payload.caseId != Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST){
            asst.Contact_Association_Type_Staging__c = payload.catId;
        }       
        asst.Name_on_Document__c = payload.nameOnDocument;
        asst.InstallDate = System.Today();
        asst.status = payload.assetStatus;
        asst.ParentId = payload.parentAsset;  
        if(String.isNotBlank(payload.key)){
            asst.Key__c = payload.key;
        }
        if(String.isNotBlank(payload.parentKey)){
            asst.Parent_Key__c = payload.parentKey;
        }
        asst.Exam_Registration_Exam_Type__c = payload.selectedExamType != '' && payload.selectedExamType != null ? payload.selectedExamType : null;
        asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(payload.assetRecordType).getRecordTypeId();
        if(payload.caseId == 'Add a New User Request'){
            asst.accountId = payload.accountId;
        }else if(payload.caseId == Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST && payload.catId != null){
            asst.accountId = payload.accountId;
            asst.ASL_Language__c = payload.catId;
        }else if(payload.caseId == 'Add a New Service for User'){
            asst.contactId = payload.contactId;
		}else{
			if(String.isNotBlank(payload.parentCaseId)){
				asst.Parent_Case__c = payload.parentCaseId;
			}else{
				asst.Parent_Case__c = null;
			}
			asst.Case__c = payload.caseId;
			asst.contactId = payload.contactId;
			asst = updateAcctId(asst,payload);
		}
		if(String.isNotBlank(payload.parentUrl)){
            asst.parentId = azureUrlParentAssetIdMap.containsKey(payload.parentUrl) ? azureUrlParentAssetIdMap.get(payload.parentUrl) : null;
			asst.Parent_Azure_Storage_URL__c = payload.parentUrl;
		}
		if(String.isNotBlank(payload.rePrintDate)){
			asst.Certificate_Reprint_Date__c = Date.valueOf(payload.rePrintDate);
		}
		if(payload.catId == Null && payload.documentType == 'Translation'){
			List<Contact_Association_Type_Staging__c> catRcd = new List<Contact_Association_Type_Staging__c>();
			catRcd = [SELECT Id FROM Contact_Association_Type_Staging__c WHERE Contact__c =:payload.contactId AND Case__c =:payload.caseId WITH SECURITY_ENFORCED];
			if(catRcd.size() != 0){
				asst.Contact_Association_Type_Staging__c = catRcd[0].Id;                
			}
		}
        if(payload.uploadedByEntity == 'true'){
            asst.Uploaded_By_Entity__c = true;
        }else{
            asst.Uploaded_By_Entity__c = false;
        }
		return asst;
    }
    public static boolean checkUploadedByApplicantflag(CloudStorageController.PayloadWrapper payload){
        boolean flagValue = false;
        if(payload.uploadedByApplicant  == 'true'){
            flagValue = true;
        }
        return flagValue;
    }
    public static void getNewServiceTemplate(List<Asset> newServAsset){
        String piaAssetId = '';
        String newSerAssetId = '';
        List<Case2Service__c> case2Serv = [SELECT ID, Case__c, Service__c, Service__r.name FROM Case2Service__c WHERE Service__r.name =: Constants.SERVICE_NAME_PERFORMANCE_DATA AND Case__c =:newServAsset[0].Case__c WITH SECURITY_ENFORCED];
        if(!case2Serv.isEmpty()){
            for(Asset ast : [SELECT Id, Case__c, Type__c, Azure_Storage_URL__c, Contact.Email FROM Asset WHERE Case__c =:newServAsset[0].Case__c AND Status =:Constants.ASSET_STATUS_IN_PROGRESS AND (Type__c =:Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE OR Type__c =:Constants.ASSET_TYPE_PIA_TEMPLATE)]){
                if(ast.Type__c == Constants.ASSET_TYPE_PIA_TEMPLATE){
                    piaAssetId = ast.Id;
                }
                if(ast.Type__c == Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE){
                    newSerAssetId = ast.Id;
                }
            }
        }
        if(String.isNotBlank(newSerAssetId)){
            sendEmailWithAttachment(newSerAssetId, piaAssetId);
        }
    }
    //Send mail for generated PIA and new service template
    @future(callout=true)
    public static void sendEmailWithAttachment(String newSerAssetId, String piaAssetId){
        String subject = '';
        String mailId = '';
        Asset piaAsset = new Asset();
        Asset newSerAsset = new Asset();
        if(String.isNotBlank(piaAssetId)){
            piaAsset = [SELECT Id, Case__c, Type__c, Azure_Storage_URL__c, Contact.Email FROM Asset WHERE Id =:piaAssetId WITH SECURITY_ENFORCED];
        }
        if(String.isNotBlank(newSerAssetId)){
            newSerAsset = [SELECT Id, Case__c, Type__c, Azure_Storage_URL__c, Contact.Email FROM Asset WHERE Id =:newSerAssetId WITH SECURITY_ENFORCED];
        }
        List<OrgWideEmailAddress> addr  = [SELECT Id FROM OrgWideEmailAddress WHERE displayname =:Constants.ORG_WIDE_ADDRESS]; //Do not add WITH SECURITY_ENFORCED 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(addr[0].Id);
        email.setPlainTextBody('Please check the attached document.');
        List<Messaging.EmailFileAttachment> efa = new List<Messaging.EmailFileAttachment>();
        if(piaAsset != null && String.isNotBlank(piaAsset.Azure_Storage_URL__c)){
            Blob document = getUrlWithSasToken(piaAsset.Azure_Storage_URL__c);
            subject = Constants.ASSET_TYPE_PIA_TEMPLATE + ' And ';
            Messaging.EmailFileAttachment efaPIA = new Messaging.EmailFileAttachment();
            efaPIA.setFileName(Constants.ASSET_TYPE_PIA_TEMPLATE+'.pdf');
            efaPIA.setBody(document);
            efa.add(efaPIA);
            mailId = piaAsset.Contact.Email;
        }
        if(newSerAsset != null && String.isNotBlank(newSerAsset.Azure_Storage_URL__c)){
            Blob newServDocument = getUrlWithSasToken(newSerAsset.Azure_Storage_URL__c);
            subject = subject + Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE;
            Messaging.EmailFileAttachment efaServ = new Messaging.EmailFileAttachment();
            efaServ.setFileName(Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE+'.pdf');
            efaServ.setBody(newServDocument);
            efa.add(efaServ);
            mailId = newSerAsset.Contact.Email;
        }
        email.setToAddresses( new String[] {mailId});
        email.setSubject(subject);
        email.setFileAttachments(efa);
        if(!efa.isEmpty()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
    //Get url with sas token
    public static Blob getUrlWithSasToken(String azureUrl){
        //String fileName = azureUrl.split('/')[4];
        List<String> parts = azureUrl.split('/');
        String filename = parts[parts.size()-1];
        String url = CloudStorageUtils.getFileUrlWithSAS(fileName);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(url);        
        Http binding = new Http();
        HttpResponse res = binding.send(req);
        return res.getBodyAsBlob();
    }
    //method to insert assets
    @AuraEnabled
    public static String insertAsset(Asset asst){
        String assetId = null;
        if(Asset.SObjectType.getDescribe().isCreateable()){
            insert asst;
            assetId = asst.Id;
        }
        return assetId;
    }
    //method to update asset accout
    @AuraEnabled
    public static Asset updateAcctId(Asset asst,PayloadWrapper payload){
        if(String.isNotEmpty(payload.accountId)){
            asst.accountId = payload.accountId;
        }
        return asst;
    }
    //Method to mark asset for deletion
    @AuraEnabled
    public static Boolean markAssetsForDeletion(String azureUrl){
        List<Asset> assetList = [SELECT id from Asset where Azure_Storage_URL__c =: azureUrl AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
        List<RecordType> recordTypeList = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
        if (recordTypeList.size() == 0) {
            throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
        }
        RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if (!assetList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()) {
            Asset asst = new Asset();
            asst.Id = assetList[0].Id;
            asst.Parent_Case__c = null;
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
            asst.Contact_Association_Type_Staging__c = null;
            update asst;
        }
        return true;
    }
    //Method to retrieve the Azure Url for the given Asset Id
    @AuraEnabled
    public static String getAzureUrlFromAsset(String assetId){
        String azureUrlToBeReturned = '';
        List<Asset> assetList = [SELECT Azure_Storage_URL__c FROM Asset WHERE id =: assetId];
        if (assetList.size() > 0) {
            azureUrlToBeReturned = assetList[0].Azure_Storage_URL__c;
        }
        return azureUrlToBeReturned;
    }
    //Wrapper class for cloud document payload
    public class PayloadWrapper{
        @auraenabled public string contactId {get; set;}
        @auraenabled public string documentType {get; set;}
        @auraenabled public string assetRecordType {get; set;}
        @auraenabled public string createOrReplace {get; set;}
        @auraenabled public string parentCaseId {get; set;}
        @auraenabled public string caseId {get; set;}
        @auraenabled public string accountId {get; set;}
        @auraenabled public string assetCreationRequired {get; set;}
        @auraenabled public string assetStatus {get; set;}
        @auraenabled public string assetId {get; set;}
        @auraenabled public string sourceDocument {get; set;}
        @auraenabled public string nameOnDocument {get; set;}
        @auraenabled public string catId {get; set;}
        @auraenabled public string assetName {get; set;}
        @auraenabled public string parentUrl {get; set;}
        @auraenabled public string key {get; set;}
        @auraenabled public string parentKey {get; set;}
        @auraenabled public string type {get; set;}
        @auraenabled public string createFromPB {get; set;}
        @auraenabled public string selectedExamType {get; set;}
        @auraenabled public string rePrintDate {get; set;}
        @AuraEnabled public string createAsset2Ver {get; set;}
        @AuraEnabled public string parentAsset {get; set;}
        @AuraEnabled public string azureUrl {get; set;} 
        @AuraEnabled public string isUploadLocation {get; set;}
        @AuraEnabled public string caseNumber {get; set;}
        @AuraEnabled public date attendanceEndDate {get; set;}
        @AuraEnabled public date attendanceStartDate {get; set;}
        @AuraEnabled public date degreeIssueDate {get; set;}
        @AuraEnabled public string degreeTitle {get; set;}
        @AuraEnabled public string graduationYear {get; set;}
        @AuraEnabled public string degreeExpectedToBeIssuedMonth {get; set;}
        @AuraEnabled public string degreeExpectedToBeIssuedYear {get; set;}
        @AuraEnabled public date expirationDate {get; set;}
        @AuraEnabled public date issueDate {get; set;}
        @AuraEnabled public date programEndDate {get; set;}
        @AuraEnabled public date programStartDate {get; set;}
        @AuraEnabled public string title {get; set;}
        @AuraEnabled public date deansLetterDate {get; set;}
        @AuraEnabled public string startMonth {get; set;}
        @AuraEnabled public string endMonth {get; set;}
        @AuraEnabled public string startYear {get; set;}
        @AuraEnabled public string endYear {get; set;}
        @AuraEnabled public string uploadedByApplicant {get; set;}
        @AuraEnabled public Integer size {get; set;}
        @AuraEnabled public string uploadedByEntity {get; set;}
        public PayloadWrapper(String tcontactId, String tdocumentType, String tassetRecordType, String tcreateOrReplace, String tcaseId, String taccountId, String tassetCreationRequired, String tassetStatus, String tassetId){
            contactId = tcontactId;
            documentType = tdocumentType;
            assetRecordType = tassetRecordType;
            createOrReplace = tcreateOrReplace;
            caseId = tcaseId;
            accountId = taccountId;
            assetCreationRequired = tassetCreationRequired;
            assetStatus = tassetStatus;
            assetId = tassetId;
        }
        //azure url
        public PayloadWrapper(String tcontactId, String tdocumentType, String tassetRecordType, String tcreateOrReplace, String tcaseId, String taccountId, String tassetCreationRequired, String tassetStatus, String tassetId,String ttype, String tkey, String tparentKey, String tcreateFromPB, String tazureUrl){          
            contactId = tcontactId;
            documentType = tdocumentType;
            assetRecordType = tassetRecordType;
            createOrReplace = tcreateOrReplace;
            caseId = tcaseId;
            accountId = taccountId;
            assetCreationRequired = tassetCreationRequired;
            assetStatus = tassetStatus;
            assetId = tassetId;
            type = ttype;
            key = tkey;
            parentKey = tparentKey;
            createFromPB = tcreateFromPB;
            azureUrl = tazureUrl;
        }
        public PayloadWrapper(String tcontactId, String tdocumentType, String tassetRecordType, String tcreateOrReplace, String tcaseId, String taccountId, String tassetCreationRequired, String tassetStatus, String tassetId,String ttype, String tkey, String tparentKey, String tcreateFromPB, String tazureUrl,String isUploadLocation,String tcaseNumber){          
            contactId = tcontactId;
            documentType = tdocumentType;
            assetRecordType = tassetRecordType;
            createOrReplace = tcreateOrReplace;
            caseId = tcaseId;
            accountId = taccountId;
            assetCreationRequired = tassetCreationRequired;
            assetStatus = tassetStatus;
            assetId = tassetId;
            type = ttype;
            key = tkey;
            parentKey = tparentKey;
            createFromPB = tcreateFromPB;
            azureUrl = tazureUrl;
            isUploadLocation = isUploadLocation;
            caseNumber = tcaseNumber;
        }
        //asset name and attributes from CATS
        public PayloadWrapper(String tcontactId, String tdocumentType, String tassetRecordType, String tcreateOrReplace, String tcaseId,
                              String taccountId, String tassetCreationRequired, String tassetStatus, String tassetId, String tassetName,
                              Date tattendanceEndDate, Date  tattendanceStartDate, Date tdegreeIssueDate, String tdegreeTitle,
                              String tgraduationYear, String tdegreeExpectedToBeIssuedMonth, String tdegreeExpectedToBeIssuedYear,
                              Date texpirationDate, Date tissueDate, Date tprogramEndDate,  Date tprogramStartDate, String ttitle,
                              Date tdeansLetterDate, String tstartMonth, String tendMonth, String tstartYear, String tendYear){
            contactId = tcontactId;
            documentType = tdocumentType;
            assetRecordType = tassetRecordType;
            createOrReplace = tcreateOrReplace;
            caseId = tcaseId;
            accountId = taccountId;
            assetCreationRequired = tassetCreationRequired;
            assetStatus = tassetStatus;
            assetId = tassetId;
            assetName = tassetName;
            attendanceEndDate = tattendanceEndDate;
            attendanceStartDate = tattendanceStartDate;
            degreeIssueDate = tdegreeIssueDate;
            degreeTitle = tdegreeTitle;
            graduationYear = tgraduationYear;
            degreeExpectedToBeIssuedMonth = tdegreeExpectedToBeIssuedMonth;
            degreeExpectedToBeIssuedYear = tdegreeExpectedToBeIssuedYear;
            expirationDate = texpirationDate;
            issueDate = tissueDate;
            programEndDate = tprogramEndDate;  
            programStartDate = tprogramStartDate;  
            title = ttitle;
            deansLetterDate = tdeansLetterDate;
            startMonth = tstartMonth;
            endMonth = tendMonth;
            startYear = tstartYear;
            endYear = tendYear;
        }
    }
    //Method to fetch contactId from case   
    @AuraEnabled
    public static String getContactId(String caseId){
        String contactId;
        List<Case> caseList = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            caseList = [SELECT contactId,contact.School_Enrollment_Status__c FROM Case where id=:caseId];
        }
        if(!caseList.isEmpty()){
            contactId = caseList[0].contactId+':'+caseList[0].contact.School_Enrollment_Status__c;
        }
        return contactId;
    }
    //Method to fetch case status given case Id 
    @AuraEnabled
    public static String getCaseStatus(String caseId){
        String caseStatus;
        List<Case> caseList = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            caseList = [SELECT Internal_Status__c, Document_Type__c, CaseNumber, Service__c FROM Case where id=:caseId];
        }
        if(!caseList.isEmpty()){
            caseStatus = caseList[0].Internal_Status__c+':'+caseList[0].Document_Type__c+':'+caseList[0].CaseNumber+':'+caseList[0].Service__c;
        }
        return caseStatus;
    }
    //Method to fetch case document type given case Id. Added for bug 19515
    @AuraEnabled
    public static String getCaseDocType(String caseId){
        String caseDocType;
        List<Case> caseList = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            caseList = [SELECT Internal_Status__c, Document_Type__c FROM Case WHERE Id=:caseId];
        }
        if(!caseList.isEmpty()){
            caseDocType = caseList[0].Document_Type__c;
        }
        return caseDocType;
    }
    //Method to create payload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPayload(String caseId, String contactId, String type){
        List<String> typeList = new list<String> {'TCT Name Document','Final Diploma Name Document','Final Transcript Name Document', 'Pre-Med Letter Name Document','Letter from Dean Name Document'};
        CloudStorageController.PayloadWrapper payload;
        if(typeList.contains(type)) {
            type = 'Name Document';
        }
        String recordType = getRecordTypeMap().get(type);
        if(type == Constants.ASSET_TYPE_SIGNED_PIA || type == Constants.ASSET_TYPE_SIGNED_SERVICE_FORM){
            string accountId = [SELECT Id,Entity__c,contactId FROM case WHERE id =:caseId AND contactId =: contactId WITH SECURITY_ENFORCED LIMIT 1][0].Entity__c;
            payload= new CloudStorageController.PayloadWrapper(contactId, type, recordType, 'create', caseId, accountId,  'true', 'In Progress', null);
        }else{
            payload= new CloudStorageController.PayloadWrapper(contactId, type, recordType, 'create', caseId, null,  'true', 'In Progress', null);
        }
        return payload;
    }
    //method to get record type Mappings
    public static Map<String, String> getRecordTypeMap(){
        Map<String,String> recordTypeMap = new Map<String,String>();
        recordTypeMap.put(Constants.ASSET_TYPE_NAME_DOC, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_NAME_TCT_TRANSLATION, Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put(Constants.ASSET_TYPE_TCT, Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Final Medical Diploma', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Final Diploma Translation', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Final Medical School Transcript', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Final Transcript Translation', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Letter from Dean', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Letter from Dean Translation', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Pre-Med Letter', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put('Pre-Med Letter Translation', Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        recordTypeMap.put(Constants.ASSET_NAME_PHOTO, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_NAME_PASSPORT, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_NAME_PASSPORT_TRANSLATION, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_NAME_PASSPORT_EXPIRATION, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_BIRTH_CERTIFICATE, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_US_PASSPORT_CARD, Constants.ASSET_RECORD_TYPE_IDENTITY);
        recordTypeMap.put(Constants.ASSET_TYPE_RETURNED_ENROLLMENT_VERIFICATION, Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION);
        recordTypeMap.put(Constants.ASSET_TYPE_RETURNED_ENROLLMENT_REVERIFICATION, Constants.ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION);
        recordTypeMap.put(Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,Constants.ASSET_RECORD_TYPE_ENTITY_DOCUMENT_DEVNAME);
        recordTypeMap.put(Constants.ASSET_TYPE_SIGNED_SERVICE_FORM,Constants.ASSET_RECORD_TYPE_ENTITY_DOCUMENT_DEVNAME);
        recordTypeMap.put(Constants.ASSET_TYPE_SIGNED_PIA,Constants.ASSET_RECORD_TYPE_ENTITY_DOCUMENT_DEVNAME);     
        recordTypeMap.put(Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION, Constants.ASSET_RECORD_TYPE_EXAM_REG);
        recordTypeMap.put('Redacted ID Form', Constants.ASSET_RECORD_TYPE_IDENTITY);
        return recordTypeMap;
    }

    @AuraEnabled(cacheable=false)
    public static List<sObject> getRecordsList(String queryString){
        return Database.query(queryString);
    }

    @AuraEnabled(cacheable=false)
    public static Map<Integer, Map<string, string>> getRelatedEntities(List<String> assetIdsList){
        List<Asset> relatedAssets = new List<Asset>([SELECT Id, Contact_Association_Type_Staging__c FROM Asset WHERE Id IN: assetIdsList]);
        List<String> catsIdList = new List<String>();
        for(Asset a : relatedAssets){
            catsIdList.add(a.Contact_Association_Type_Staging__c);
        }
        List<Contact_Association_Type_Staging__c> relatedEntities = new List<Contact_Association_Type_Staging__c>([SELECT Id, Name, Account_Name__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c FROM Contact_Association_Type_Staging__c WHERE Id IN: catsIdList]);
        Map<Integer, Map<string, string>> entityIdNameMap = new Map<Integer, Map<string, string>>();
        Integer count = 0;
        for(Contact_Association_Type_Staging__c cats : relatedEntities){    
            Map<string, string> tempMap = new Map<string, string>();
            String period = cats.Start_Month__c+' '+cats.Start_Year__c+' - '+cats.End_Month__c+' '+cats.End_Year__c;
            tempMap.put(cats.Id, cats.Account_Name__c + ' : ' + period);
            entityIdNameMap.put(count, tempMap);
            count++;
        }
        return entityIdNameMap;
    }
    //@AuraEnabled(cacheable=false)
    public static void updateParent(String selectedType,String assetId, String catsId){
		String parentAssetName;
		List<Asset> asstList = new List<Asset>();
		switch on  selectedType{
			when  'Final Diploma Translation','Final Diploma Name Document'{
				parentAssetName = 'Final Medical Diploma';
			}
			when 'TCT Translation','TCT Name Document' {
				parentAssetName = 'Transfer Credit Transcript';
			}
			when 'Pre-Med Letter Translation', 'Pre-Med Letter Name Document'{
				parentAssetName = 'Pre-Med Letter';
			}
			when 'Final Transcript Name Document', 'Final Transcript Translation' {
				parentAssetName = 'Final Medical School Transcript';
			}
			when 'Letter from Dean Name Document','Letter from Dean Translation' {
				parentAssetName = 'Letter from Dean';
			}
			when 'Passport Expiration Page','Passport Translation Page' {
				parentAssetName = 'Passport';
			}
		}
		if(String.isNotEmpty(parentAssetName) && String.isNotEmpty(catsId)){
			asstList = [SELECT id, Azure_Storage_URL__c FROM Asset where name =:parentAssetName AND Contact_Association_Type_Staging__c =:catsId ORDER BY CreatedDate DESC];
		}
		if(!asstList.isEmpty()){
			Asset asst = new Asset();
			asst.Id = assetId;
			asst.parentId = asstList[0].Id;
			asst.Parent_Azure_Storage_URL__c = asstList[0].Azure_Storage_URL__c;
			update asst;
		}
	}
    //@AuraEnabled(cacheable=false)
    public static void updateProductFields(String selectedType, String assetId){
        List<Asset> assetList = [SELECT id, Case__r.RecordType.DeveloperName FROM Asset WHERE Id =:assetId WITH SECURITY_ENFORCED];
        String caseRecTypeName;
        if(!assetList.isEmpty()){
            caseRecTypeName = assetList[0].Case__r.RecordType.DeveloperName;
        }
        if(caseRecTypeName == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE){
            List<Product2> productsList = [SELECT id FROM Product2 where ProductCode = :selectedType WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
            if(!productsList.isEmpty()){
                Asset asst = new Asset();
                asst.Id = assetId;
                asst.Product2Id = productsList[0].Id;
                update asst;
            }
        }       
    }
    @AuraEnabled(cacheable=false)
    public static Boolean checkReadOnly(String caseId){
        List<Case> caseList = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            caseList = [SELECT id,ownerId,recordType.DeveloperName from Case where id=:caseId];
        }
        String recordType;
        String ownerId; 
        if(!caseList.isEmpty()){
            ownerId = caseList[0].ownerId;
             recordType = caseList[0].recordType.DeveloperName;
        }
        String currentUserId = UserInfo.getUserId();
        if(currentUserId == ownerId &&  recordType != Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION){
            return false;
        }
          if(recordType == Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION){
            return true;
        }
        return true;
    }
    @AuraEnabled(cacheable=false)
    public static Boolean checkEntityHasService(string recordId){
        List<Case> caseList = new List<Case>();
        caseList = [SELECT Id,Entity__c,Service_Name__c FROM Case WHERE ID = :recordId];
        List<Account2Service__c> act2ServiceList = new List<Account2Service__c>();
        act2ServiceList = [SELECT id,Account__c,Service__c,Active__c from Account2Service__c WHERE Account__c =:caseList[0].Entity__c AND Service__c =:caseList[0].Service_Name__c AND Active__c = true WITH SECURITY_ENFORCED];
        if(!act2ServiceList.isEmpty()){
            return true;
        }
        return false;
    }
    @AuraEnabled(cacheable=false)
    public static String checkAssetExists(string caseId, String catId, String type){
        List<Asset> inProgressAssetList = [SELECT Id, Azure_Storage_URL__c, Name, Recordtype.Name FROM Asset WHERE case__c =: caseId AND Name =: type AND Name NOT IN ('Photo','Passport') AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!inProgressAssetList.isEmpty()){
            return inProgressAssetList[0].Id;
        }
        return null;
    }
    public static String getNameFromUrl(String fileURL){
        String fileUniqueName;
        if(String.isNotBlank(fileURL)){
            List<String> nameParts = fileURL.split('/');
            String nameWithExt = nameParts[nameParts.size() - 1];
            List<String> nameWithExtParts = nameWithExt.split('\\.');
            String extensionName = nameWithExtParts[nameWithExtParts.size() - 1];
            String extensionNameDot = '.'+extensionName;
            fileUniqueName = nameWithExt.removeEndIgnoreCase(extensionNameDot);
        }
        return fileUniqueName;
    }
    public static String getParentId(String azureUrl){
        String assetId = null;
        if(String.isNotBlank(azureUrl)){
            List<Asset> assetList = [SELECT Id, Status FROM Asset WHERE Azure_Storage_URL__c =:azureUrl WITH SECURITY_ENFORCED];
            if(!assetList.isEmpty()){
                assetId = assetList[0].Id;
            }
        }
        return assetId;
    }
    // Method to create asset2verification packet to link asset to verification packet for Credential Verification cases
    @AuraEnabled
    public static CloudStorageController.ResultWrap linkAssetToVPMethod(String caseId, String assetId, String type, String azureURL){
        List<Asset2Verification__c> existingRecs = new List<Asset2Verification__c>();
        List<Verification_Packet__c> caseVerificationPacket = [SELECT Id FROM Verification_Packet__c WHERE Case__c =:caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];
        Asset2Verification__c newAsset2VPRecord = new Asset2Verification__c();  
        CloudStorageController.ResultWrap response = new CloudStorageController.ResultWrap();
        final string messageSuccess = 'The asset is created and linked with verification packet of the case.';      
        final string messageVPMissing = 'No verification packet associated with this case.';
        response.outcome = false;
        if(!caseVerificationPacket.isEmpty()){          
            if(type != 'Supporting Document' && type != 'Returned Supporting Document'){
                existingRecs=[SELECT id, Document_Type__c, Asset__c, Azure_Document_URL__c FROM Asset2Verification__c WHERE Document_Type__c =:type AND Verification_Packet__c =:caseVerificationPacket[0].Id WITH SECURITY_ENFORCED];
                if(!ExistingRecs.isEmpty()){    
                    newAsset2VPRecord.Id = existingRecs[0].Id;  
                }
                newAsset2VPRecord.Document_Type__c = type;
                newAsset2VPRecord.Asset__c = assetId;   
                newAsset2VPRecord.Azure_Document_URL__c = azureURL; 
                newAsset2VPRecord.Verification_Packet__c = caseVerificationPacket[0].Id;                
                if(assetId == null){
                    newAsset2VPRecord.Asset__c = getParentId(azureURL); 
                }
            }else{
                existingRecs=[SELECT id, Document_Type__c, Asset__c, Azure_Document_URL__c FROM Asset2Verification__c WHERE Document_Type__c =:type AND Verification_Packet__c =:caseVerificationPacket[0].Id AND Azure_Document_URL__c =:azureURL WITH SECURITY_ENFORCED];
                if(!ExistingRecs.isEmpty()){
                    response.outcome = true;
                    response.message = messageSuccess;
                    return response;
                }
                newAsset2VPRecord.Document_Type__c = type;
                newAsset2VPRecord.Asset__c = assetId;   
                newAsset2VPRecord.Azure_Document_URL__c = azureURL; 
                newAsset2VPRecord.Verification_Packet__c = caseVerificationPacket[0].Id;                
            }
            response = CloudStorageController.createAsset2VPRec(newAsset2VPRecord,assetId);
            return response;
        }
        response.outcome = false;
        response.message = messageVPMissing;
        return response;
    }
    public static CloudStorageController.ResultWrap createAsset2VPRec(Asset2Verification__c asset2VPRec,String assetId){
        CloudStorageController.ResultWrap response = new CloudStorageController.ResultWrap();
        final string messageSuccess = 'The asset is created and linked with verification packet of the case.';
        final string messageAccessIssue = 'Unable to complete the process as asset2verification is not creatable for the current profile';
        response.outcome = false;
        if(Asset2Verification__c.SObjectType.getDescribe().isCreateable() && Asset2Verification__c.SObjectType.getDescribe().isUpdateable()){
            try{
                UPSERT asset2VPRec;
                response.outcome = true;
                response.message = messageSuccess;
                if(assetId != null && Asset.SObjectType.getDescribe().isUpdateable()){
                    Asset ast = new Asset(Id = assetId);
                    UPDATE ast;
                }
                return response;
            }catch(Exception e){
                response.outcome = false;
                response.message = e.getMessage();
                return response;
            }
        }
        response.outcome = false;
        response.message = messageAccessIssue;
        return response;
    }
    Public class ResultWrap{
        @AuraEnabled public string message {get; set;}
        @AuraEnabled public boolean outcome {get; set;}
        public ResultWrap(){
            message='';
            outcome=false;
        }
    }
    //to create asset2verification records for assets
    public static void createAsset2VerificationRecord(String azureUrl, PayloadWrapper assetPayload){
        String caseId = assetPayload.caseId;
        Set<String> assetNameList = new Set<String>{Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM, Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM, Constants.ASSET_NAME_VERIFICATION_COVER_LETTER, Constants.ASSET_NAME_RETURNED_VERIFICATION_FORM};
        Map<String,String> assetDocumentTypeMap = new Map<String,String>{Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM => constants.ASSET2VER_DOCTYPE_ACC_VER_FORM,
                                                                         Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM => constants.ASSET2VER_DOCTYPE_NEW_VER_FORM,
                                                                         Constants.ASSET_NAME_VERIFICATION_COVER_LETTER => constants.ASSET2VER_DOCTYPE_COVER_LETTER,
                                                                         Constants.ASSET_NAME_RETURNED_VERIFICATION_FORM => Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM
                                                                        };                                                                        
        if(assetNameList.contains(assetPayload.assetName) && assetPayload.createAsset2Ver == 'true'){ 
            List<Verification_Packet__c> packetList = new List<Verification_Packet__c>();
            packetList = [SELECT Id FROM Verification_Packet__c WHERE case__c =: caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];            
            if(!packetList.isEmpty()){
                List<Asset2Verification__c> existingAsset2Ver = [SELECT Id FROM Asset2Verification__c WHERE Verification_Packet__c =: packetList[0].Id AND Document_Type__c =: assetDocumentTypeMap.get(assetPayload.assetName) WITH SECURITY_ENFORCED];
                Asset2Verification__c newAsset2Ver = new Asset2Verification__c();
                if(assetPayload.assetName != Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM && !existingAsset2Ver.isEmpty()){
                    newAsset2Ver.Id = existingAsset2Ver[0].Id;
                }
                newAsset2Ver.Asset__c = null;
                newAsset2Ver.Document_Type__c = assetDocumentTypeMap.get(assetPayload.assetName);
                newAsset2Ver.Verification_Packet__c = packetList[0].Id;
                newAsset2Ver.Azure_Document_URL__c = azureUrl;
                if(Asset2Verification__c.SObjectType.getDescribe().isCreateable()){
                    UPSERT newAsset2Ver;
                }
            }
        }
    }
}