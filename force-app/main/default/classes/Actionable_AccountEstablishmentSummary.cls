global with sharing class Actionable_AccountEstablishmentSummary implements cadmus_core.AbstractAfterActionable{
    //Abstract method of cadmus_core.AbstractAfterActionable interface
    global void execute(cadmus_core__Actionable__c actionable, Id docConfig, Id objectId, Map<String,Object> inputMap, cadmus_core.ConvertController.ConvertDataModel cdm, cadmus_core.DocGenerationWrapper wrapper){
        List<Case> caseRecord = [SELECT Id, RecordType.DeveloperName, Internal_Status__c FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
        if(caseRecord[0].RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION && (caseRecord[0].Internal_Status__c == Constants.CASE_STATUS_PENDING_ID_REVIEW || caseRecord[0].Internal_Status__c == Constants.CASE_STATUS_NEW)){
            uploadAccountEstablishmentSummary(objectId, wrapper.response.base64);
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
    /* Method to create asset and invoke api callout to azure blob to upload generated Account Establishment */
    global void uploadAccountEstablishmentSummary(Id objectId, Blob document){
        List<Case> userRequestCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :objectId];
        String assetName = Constants.ASSET_NAME_ACCOUNT_ESTABLISHMENT_APPLICATION_SUMMARY;
        String assetType = Constants.ASSET_TYPE_APPLICATION_SUMMARY;
        String contactId = String.valueOf(userRequestCase[0].ContactId);
        List<Asset> assetsToUpdateList = markForDeletionPrevSummaryAssets(assetName, assetType, contactId, objectId);
        PayloadWrapper payload = new PayloadWrapper();
	    payload.assetName = Constants.ASSET_NAME_ACCOUNT_ESTABLISHMENT_APPLICATION_SUMMARY;
        payload.contactId = String.valueOf(userRequestCase[0].ContactId);
        payload.documentType = Constants.ASSET_TYPE_APPLICATION_SUMMARY ;
        payload.assetRecordType = Constants.ASSET_RECORD_TYPE_SUMMARY;
        payload.createOrReplace = 'replace';
        payload.caseId = String.valueOf(objectId);
        payload.accountId = String.valueOf(userRequestCase[0].AccountId);
        payload.assetCreationRequired = 'true';
        payload.assetStatus = Constants.ASSET_STATUS_ACCEPTED;
        payload.createFromPB = 'true';
        payload.rePrintDate = '';
        payload.createAsset2Ver = '';
        uploadGeneratedDocToAzure(userRequestCase[0].ContactId+'_Account_Establishment_Application_Summary', userRequestCase[0].Contact.Email, JSON.serialize(payload), document, 'Account Establishment Application Summary');
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update assetsToUpdateList; 
        }
    }
    //Method to upload generated document to azure blob via callout and send email to applicant
    @future(callout=true)
    global static void uploadGeneratedDocToAzure(String fileName, String mailId, String payload, Blob document, String subject){
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
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
        List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];//Donot add WITH SECURITY_ENFORCED 
        email.setOrgWideEmailAddressId(addr[0].Id);
        email.setSubject(subject);
        email.setToAddresses( new String[] {mailId});
        email.setPlainTextBody('An Account Establishment Summary asset is created. Please check.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
        CloudStorageController.processResponse(payload, String.valueOf(header.get('FileUrl')));
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
}