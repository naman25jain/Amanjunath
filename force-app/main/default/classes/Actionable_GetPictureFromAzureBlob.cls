global with sharing class Actionable_GetPictureFromAzureBlob implements cadmus_core.AbstractBeforeWithDataSourcesActionable{   
    //Abstract method of cadmus_core.AbstractBeforeWithDataSourcesActionable interface
    global void execute(cadmus_core__Actionable__c actionable, Id docConfig, Id objectId, Map<String,Object> inputMap, Map<String,Object> dsMap, cadmus_core.ConvertController.ConvertDataModel cdm){
        try{
            Case caseRecord = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :objectId];
            if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION || caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION || caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST){
                cadmus_core.ListWrapper dsPictures = new cadmus_core.ListWrapper();
                List<Map<String,object>> imageData = dsPictures.data;
                List<Asset> photoAsset = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Type__c = 'Photo' AND Status = :Constants.ASSET_STATUS_VERIFIED AND ContactId IN (SELECT ContactId FROM Case WHERE Id =:objectId)];
                Map<String,String> imageDataSourceLine = getImageFromAzureBlob(photoAsset[0]);
                if(!imageDataSourceLine.isEmpty()){
                    imageData.add(imageDataSourceLine);
                    List<cadmus_core__Data_Source__c> photoDataSource = [Select Id,cadmus_core__CustomerDataSourceId__c From cadmus_core__Data_Source__c Where Name = 'Applicant Photo Data Source'];
                    dsMap.put(photoDataSource[0].cadmus_core__CustomerDataSourceId__c, dsPictures);
                }
            }
            else if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION || caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE){
                cadmus_core.ListWrapper dsPicturesphoto = new cadmus_core.ListWrapper();
                List<Map<String,object>> imageDataPhoto = dsPicturesphoto.data;
                List<Asset> photoAsset = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Type__c = 'Photo' AND Case__c =:objectId AND (Status = :Constants.ASSET_STATUS_VERIFIED OR Status = :Constants.ASSET_STATUS_IN_PROGRESS)];
                Map<String,String> imageDataSourceLine = getImageFromAzureBlob(photoAsset[0]);
                if(!imageDataSourceLine.isEmpty()){
                    imageDataPhoto.add(imageDataSourceLine);
                    List<cadmus_core__Data_Source__c> photoDataSource = [Select Id,cadmus_core__CustomerDataSourceId__c From cadmus_core__Data_Source__c Where Name = 'Applicant Photo Data Source'];
                    dsMap.put(photoDataSource[0].cadmus_core__CustomerDataSourceId__c, dsPicturesphoto);
                }
                cadmus_core.ListWrapper dsPicturespassport = new cadmus_core.ListWrapper();
                List<Map<String,object>> imageDatapassport = dsPicturespassport.data;
                List<Asset> passportAsset = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Type__c = 'Passport' AND Case__c =:objectId AND (Status = :Constants.ASSET_STATUS_VERIFIED OR Status = :Constants.ASSET_STATUS_IN_PROGRESS)];
                imageDataSourceLine = new Map<String,String>();
                imageDataSourceLine = getImageFromAzureBlob(passportAsset[0]);
                if(!imageDataSourceLine.isEmpty()){
                    imageDatapassport.add(imageDataSourceLine);
                    List<cadmus_core__Data_Source__c> passportAssetDataSource = [Select Id,cadmus_core__CustomerDataSourceId__c From cadmus_core__Data_Source__c Where Name = 'Applicant Passport Data Source'];
                    dsMap.put(passportAssetDataSource[0].cadmus_core__CustomerDataSourceId__c, dsPicturespassport);
                }
            }
            else if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION || caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
                credVerECFMGFormGeneration(cdm,dsMap);
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Method to get image from azure blob via callout
    global Map<String,String> getImageFromAzureBlob(Asset assetRec){
        try {
            List<String> imageUrlList = assetRec.Azure_Storage_URL__c.split('/');
            String url = CloudStorageUtils.getRequestUrl(DocumentEnums.DocumentAccessLevel.READ, imageUrlList[imageUrlList.size()-1]);
            
            Http h = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setEndpoint(url);
            HttpResponse response = h.send(httpRequest);
            System.debug('response '+response.getStatusCode()+'  '+response.getBodyAsBlob());
            Map<String,String> imageDataSourceLine = new Map<String,String>();
            if (response.getStatusCode() == 200) {
                String b64 = EncodingUtil.base64Encode(response.getBodyAsBlob());

                imageDataSourceLine.put('parentId', assetRec.Id);
                imageDataSourceLine.put('base64', b64);
                imageDataSourceLine.put('name', assetRec.Name);
            }
            return imageDataSourceLine;
            
        } catch(Exception ex) {
            system.debug('Exception occured ' + ex);
        }
        return new Map<String,String>();
    }
    public void credVerECFMGFormGeneration(cadmus_core.ConvertController.ConvertDataModel cdm,Map<String,Object> dsMap){
        cadmus_core.ListWrapper dsPictureEntitySeal = new cadmus_core.ListWrapper();
        List<Map<String,object>> imageDataPhoto = dsPictureEntitySeal.data;
        string entityId;
        string loggedInUserEntityId;
        for(cadmus_core.CadmusKeyValue eachParaVal:cdm.parameters.values){
            if(eachParaVal.key == 'entityId'){
                entityId = eachParaVal.valueString;
            }
            if(eachParaVal.key == 'entityUserId'){
                loggedInUserEntityId = eachParaVal.valueString;
            }
        }
        List<Asset> entitySealAsset = new List<Asset>();
        Map<String,String> imageDataSourceLine = new Map<String,String>();
        entitySealAsset = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Type__c = :constants.ASSET_TYPE_ENTITY_SEAL AND AccountId = :entityId AND Status = :Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
        if(!entitySealAsset.isEmpty()){
            imageDataSourceLine = getImageFromAzureBlob(entitySealAsset[0]);
        }        
        if(!imageDataSourceLine.isEmpty()){
            imageDataPhoto.add(imageDataSourceLine);
            List<cadmus_core__Data_Source__c> entitySealDataSource = [Select Id,cadmus_core__CustomerDataSourceId__c From cadmus_core__Data_Source__c Where Name = 'Entity Seal Image' WITH SECURITY_ENFORCED];
            dsMap.put(entitySealDataSource[0].cadmus_core__CustomerDataSourceId__c, dsPictureEntitySeal);
        }
        cadmus_core.ListWrapper dsPictureUserSignature = new cadmus_core.ListWrapper();
        List<Map<String,object>> imageDataUserSign = dsPictureUserSignature.data;
        List<Asset> userSignAsset = new List<Asset>();
        userSignAsset = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Type__c = :constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE AND contactId = :loggedInUserEntityId AND Status = :Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
        imageDataSourceLine = new Map<String,String>();
        if(!userSignAsset.isEmpty()){
            imageDataSourceLine = getImageFromAzureBlob(userSignAsset[0]);
        }
        if(!imageDataSourceLine.isEmpty()){
            imageDataUserSign.add(imageDataSourceLine);
            List<cadmus_core__Data_Source__c> userSignAssetDataSource = [Select Id,cadmus_core__CustomerDataSourceId__c From cadmus_core__Data_Source__c Where Name = 'User Signature Image' WITH SECURITY_ENFORCED];
            dsMap.put(userSignAssetDataSource[0].cadmus_core__CustomerDataSourceId__c, dsPictureUserSignature);
        }
    }
}