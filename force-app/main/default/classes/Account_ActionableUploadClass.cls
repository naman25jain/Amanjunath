global with sharing class Account_ActionableUploadClass implements cadmus_core.AbstractAfterActionable{
    
    //Abstract method of cadmus_core.AbstractAfterActionable interface
    global void execute(cadmus_core__Actionable__c actionable, Id docConfig, Id objectId, Map<String,Object> inputMap, cadmus_core.ConvertController.ConvertDataModel cdm, cadmus_core.DocGenerationWrapper wrapper){
        String docConfigName;
        if(docConfig != NULL){
            cadmus_core__Doc_Config__c configRec = [Select Name from cadmus_core__Doc_Config__c 
                                                    where Id =: docConfig WITH SECURITY_ENFORCED];
            docConfigName = configRec.Name;
        }
        //Generate asset for ASL Template
        if(docConfigName == Constants.ASSET_NAME_ASL_TEMPLATE){
            uploadASLDocument(objectId, wrapper.response.base64);
        }
    }
    
    //Method to create asset and invoke api callout to azure blob to upload generated Authorized Signature List Document
    global void uploadASLDocument(Id objectId, Blob document){
        List<Account> aslAccount = [SELECT Id, ASL_Language__c FROM Account WHERE Id = :objectId 
                                    WITH SECURITY_ENFORCED];        
        
        if(aslAccount.size() > 0){
            PayloadWrapper payload = new PayloadWrapper();
            payload.assetName = Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST;
            payload.documentType = Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST ;
            payload.assetRecordType = Constants.ASSET_RECORD_TYPE_ENTITY_DOCUMENT_DEVNAME;
            payload.createOrReplace = 'create';
            payload.accountId = String.valueOf(aslAccount[0].Id);
            payload.assetCreationRequired = 'true';
            payload.assetStatus = Constants.ASSET_STATUS_SENT;
            payload.createFromPB = 'true';
            payload.caseId = Constants.ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST;
            payload.contactId = null;
            payload.catId = String.valueOf(aslAccount[0].ASL_Language__c);
            String fileName = String.valueOf(aslAccount[0].Id)+ '_Authorized_Signature_List';
            httpCalloutAzureBlob(fileName, JSON.serialize(payload), document);        
        }
    }

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

    //Pass account Id and make callout to PDF Butler
    @AuraEnabled
    global static Boolean generateASLDocumentForAccount(String recordId, String selectedLanguage){        
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        List<Account> currentAccount = new List<Account>();
        String docConfigId;
        Boolean returnVal = true;

        currentAccount = [Select Id, ASL_Language__c from Account where Id=:recordId WITH SECURITY_ENFORCED];
        if(currentAccount.size()>0){
            currentAccount[0].ASL_Language__c = selectedLanguage;
            if(Account.SObjectType.getDescribe().isUpdateable()){
                update currentAccount;
            }
        }
        
        docConfiList = [SELECT Id, cadmus_core__View_Customer_DocConfig_Id__c 
                        FROM cadmus_core__Doc_Config__c 
                        WHERE cadmus_core__View_Customer_DocConfig_Id__c=:Constants.DOCCONFIG_ASL_TEMPLATE 
                        WITH SECURITY_ENFORCED];
        if(!docConfiList.isEmpty()){
            docConfigId = docConfiList[0].Id; 
        }   
        
        if(currentAccount.size() > 0){
            if(currentAccount[0].Id != null){
                PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, currentAccount[0].Id);
                System.enqueueJob(calloutClass);
            }            
        } else{
            returnVal = false;
        }
        return returnVal;
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
        public string catId {get;set;}
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
            catId = '';
        }
    }

    @AuraEnabled(Cacheable = true)
    public static Constants getConstantsClass(){
        return new Constants();
    }

}