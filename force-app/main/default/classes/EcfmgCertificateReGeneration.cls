public with sharing class EcfmgCertificateReGeneration{
    @AuraEnabled
    public static void createRegenAsset(String comments,String reason,String recordId){
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetListToUpdate = new List<Asset>();
        Id caseId;
        Id contactsId;
        cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel();
        assetList = [Select id,Case__r.Id,Case__r.Status,ContactId FROM Asset WHERE Id =:recordId WITH SECURITY_ENFORCED];
        caseId = assetList[0].Case__r.Id;
        contactsId = assetList[0].ContactId;
        assetListToUpdate = [Select id,Case__c,ContactId FROM Asset WHERE Status =:Constants.ASSET_STATUS_ACCEPTED AND (Type__c =:Constants.ASSET_TYPE_ECFMG_CERTIFICATE OR Type__c =:Constants.ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE OR Type__c =:Constants.ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE) AND contactId =:contactsId WITH SECURITY_ENFORCED];
        if(!assetListToUpdate.isEmpty()){
            for(Asset eachAsset:assetListToUpdate){
                eachAsset.Status = Constants.ASSET_STATUS_OUTDATED;
            }
            if(Asset.SObjectType.getDescribe().isUpdateable()){
                update assetListToUpdate;
            }
        }
        cdm.objectId = caseId;
        String assetRTid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Asset newAsset = new Asset();
        newAsset.Status = Constants.ASSET_STATUS_ACCEPTED;
        newAsset.contactId = contactsId;
        newAsset.Case__c = caseId;
        newAsset.RecordTypeId = assetRTid;
        newAsset.Comments_Reason_for_Regeneration__c = comments;
        newAsset.Reason_for_Regeneration__c	= reason;
        newAsset.Certificate_Reprint_Date__c = System.Today();
        Id docConfigId;
        String customerDocConfigId;
        if(reason=='Lost in Shipment' || reason=='Incorrect Dates' || reason=='Other' || reason=='Printer Problem' || reason=='Returned Mail'){
            newAsset.Name = Constants.ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE;
            newAsset.Type__c = Constants.ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE;
            customerDocConfigId = Constants.DOCCONFIG_ECFMGREPRINTEDCERT_ID;
            docConfigId  = EntityServiceRequestSharingDisabled.getDocConfigRecordId(customerDocConfigId);
        }
        else if(reason=='Name on Record Changed' || reason=='Destroyed' || reason=='Stolen' || reason=='Lost'){
            newAsset.Name = Constants.ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE;
            newAsset.Type__c = Constants.ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE;
            customerDocConfigId = Constants.DOCCONFIG_ECFMGDUPLICATECERT_ID;
            docConfigId  = EntityServiceRequestSharingDisabled.getDocConfigRecordId(customerDocConfigId);
        }
        if(Asset.SObjectType.getDescribe().isCreateable()){
            INSERT newAsset;
            PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId,caseId);
            System.enqueueJob(calloutClass);    
        }
    }
}