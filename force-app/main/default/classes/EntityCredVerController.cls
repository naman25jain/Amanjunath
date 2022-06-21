public with sharing class EntityCredVerController{
    //Method to get applicant's biographic information
    @AuraEnabled(cacheable=true)
    public static Contact_Association_Type_Staging__c getAppBioDetail(Id caseId){
        try{
            Contact_Association_Type_Staging__c catsRec = new Contact_Association_Type_Staging__c();
            catsRec = [SELECT Id, Name_on_Document__c, Contact__r.Name, Contact__r.Birthdate, Case__r.Unique_Medical_School_ID__c, Case__r.ECFMG_ID__c FROM Contact_Association_Type_Staging__c WHERE Case__c =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            return catsRec;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //method to get Credential Review documents
    @AuraEnabled(cacheable = false)
    public static Map<String,String> getCredUploaded(String caseId){        
        try{
            Map<String,String> returnVal = new Map<String,String>();
            String retName = '';
            List<Asset2Verification__c> asst2VerList = new List<Asset2Verification__c>();                
            asst2VerList = [SELECT Id,Verification_Packet__r.Case__r.Certify_the_Document__c,Verification_Packet__r.case__r.Id,Asset__r.Id,Asset_Type__c,Document_Type__c,
                                Asset__r.Parent.Document_is_not_in_English__c,Asset__r.Azure_Storage_URL__c,Asset__r.Type__c,
                                Asset__r.Key__c,Asset__r.Parent_Key__c,Asset__r.ParentId,Verification_Packet__r.Is_Active__c,
                                Verification_Packet__r.Entity_provide_the_credential__c,Verification_Packet__r.Translation_included__c,
                                Verification_Packet__r.Case__r.Reason_for_not_Certifying__c,Verification_Packet__r.Case__r.Comments_for_not_Certifying__c,Verification_Packet__r.Case__r.Document_Type__c,
                                Asset__r.ContactId
                                FROM Asset2Verification__c WHERE Verification_Packet__r.Case__r.Id =:caseId AND Verification_Packet__r.Is_Active__c =:TRUE WITH SECURITY_ENFORCED];               
            if(!asst2VerList.isEmpty()){
                for(Asset2Verification__c rec : asst2VerList){
                    returnVal.put('credTypeInserted',rec.Verification_Packet__r.Case__r.Document_Type__c);
                    if(rec.Document_Type__c == constants.ASSET2VER_DOCTYPE_SOURCE && rec.Verification_Packet__r.Entity_provide_the_credential__c == FALSE){
                        returnVal.put('asstVerIdSoc',rec.Id);
                        returnVal.put('docTypeSoc',rec.Document_Type__c);
                        returnVal.put('isSourceSoc','Yes');
                        returnVal.put('assIdSoc',rec.Asset__r.Id);
                        returnVal.put('azureUrlSoc',rec.Asset__r.Azure_Storage_URL__c);
                        returnVal.put('assTypeSoc',rec.Verification_Packet__r.Case__r.Document_Type__c);
                        returnVal.put('assDocCertifiedSoc',rec.Verification_Packet__r.Case__r.Certify_the_Document__c);
                        returnVal.put('assReasonNotCertSoc',rec.Verification_Packet__r.Case__r.Reason_for_not_Certifying__c);
                        returnVal.put('assComNotCertSoc',rec.Verification_Packet__r.Case__r.Comments_for_not_Certifying__c); 
                        returnVal.put('assContactSoc',rec.Asset__r.ContactId);  
                        retName = 'Returned '+ rec.Verification_Packet__r.Case__r.Document_Type__c;                                                             
                        returnVal.put('assReturnedExst','false');  
                    }
                    if(rec.Document_Type__c == constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT && rec.Asset_Type__c == 'Translation' && rec.Verification_Packet__r.Translation_included__c == TRUE){
                        returnVal.put('asstVerIdSup',rec.Id);
                        returnVal.put('docTypeSup',rec.Document_Type__c);
                        returnVal.put('isSupDoc','Yes');
                        returnVal.put('assIdSup',rec.Asset__r.Id);
                        returnVal.put('azureUrlSup',rec.Asset__r.Azure_Storage_URL__c);
                        returnVal.put('assTypeSup',rec.Asset_Type__c);
                    }                    
                }
                returnVal = getReturnedAsstExist(caseId,retName,returnVal);
            }                 
            return returnVal;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Fetches the assets (photo, redacted id form, MCC release form) related to contact's based on case's service. 
    @AuraEnabled
    public static List<CloudStorageController.PayloadWrapper> getAsset(string caseId){
        try{
            case caseRecord = [SELECT id, ContactId, Service__c FROM Case WHERE id =: caseId WITH SECURITY_ENFORCED];
            set<string> assetNames = new set<string>();
            List<CloudStorageController.PayloadWrapper> payLoadList = new List<CloudStorageController.PayloadWrapper>();
            if(label.redactedAssetServices.split(',').contains(caseRecord.service__c)){
                assetNames.add(Constants.ASSET_NAME_REDACTED_ID_FORM);
            }
            else if(label.photoReleaseAssetServices.split(',').contains(caseRecord.service__c)){
                assetNames.add(Constants.ASSET_NAME_PHOTO);
                assetNames.add(constants.ASSET_NAME_MCC_RELEASE_FORM);
            }
            if(!assetNames.isEmpty()){
                for(Asset contactAsset : [SELECT Id, Name from Asset WHERE ContactId =: caseRecord.contactId AND Name IN: assetNames AND status =: Constants.ASSET_STATUS_VERIFIED WITH SECURITY_ENFORCED]){
                    CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(caseRecord.ContactId, '', '', '', '', '', '', '', contactAsset.Id);
                    payload.assetName = contactAsset.Name;
                    payLoadList.add(payload);
                }
            }
            return payLoadList;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Method to get applicant's biographic information for Med Edu Form
    @AuraEnabled(cacheable=true)
    public static Case getAppBioDetailMEF(Id caseId){
        try{
            Case caseRec = new Case();
            caseRec = [SELECT Id, Contact.Name, Contact.Birthdate, Unique_Medical_School_ID__c, ECFMG_ID__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            return caseRec;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //Method to get Name on Document for Med Edu Form
    @AuraEnabled(cacheable=true)
    public static String getNameOnDocMEF(Id caseId){
        try{
            case caseRecord = [SELECT id, ContactId, Service__c FROM Case WHERE id =: caseId WITH SECURITY_ENFORCED];
            String assetType = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
            String nameonDoc = '';
            List<Asset> assetNameRec = [SELECT Id, Name_on_Document__c from Asset WHERE ContactId =: caseRecord.contactId AND Type__c =: assetType AND (status =: Constants.ASSET_STATUS_VERIFIED OR status =: Constants.ASSET_STATUS_ACCEPTED) WITH SECURITY_ENFORCED];
            if(!assetNameRec.isEmpty()){
                nameonDoc = assetNameRec[0].Name_on_Document__c;
            }
            return nameonDoc;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
//Fetches the Final Medical Diploma and School Transcript Assets telated to Contact
    @AuraEnabled
    public static List<CloudStorageController.PayloadWrapper> getFMDAsset(string caseId){
        try{
            case caseRecord = [SELECT id, ContactId, Service__c FROM Case WHERE id =: caseId WITH SECURITY_ENFORCED];
            List<CloudStorageController.PayloadWrapper> payLoadFMD = new List<CloudStorageController.PayloadWrapper>();
            String assetType = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
            for(Asset contactAsset : [SELECT Id, Name from Asset WHERE ContactId =: caseRecord.contactId AND Type__c =: assetType AND (status =: Constants.ASSET_STATUS_VERIFIED OR status =: Constants.ASSET_STATUS_ACCEPTED) WITH SECURITY_ENFORCED]){
                CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(caseRecord.ContactId, '', '', '', '', '', '', '', contactAsset.Id);
                payload.assetName = contactAsset.Name;
                payLoadFMD.add(payload);
            }
            return payLoadFMD;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<CloudStorageController.PayloadWrapper> getFSTAsset(string caseId){
        try{
            case caseRecord = [SELECT id, ContactId, Service__c FROM Case WHERE id =: caseId WITH SECURITY_ENFORCED];
            String assetType = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
            List<CloudStorageController.PayloadWrapper> payLoadFST = new List<CloudStorageController.PayloadWrapper>();
            for(Asset contactAsset : [SELECT Id, Name from Asset WHERE ContactId =: caseRecord.contactId AND Type__c =: assetType AND (status =: Constants.ASSET_STATUS_VERIFIED OR status =: Constants.ASSET_STATUS_ACCEPTED) WITH SECURITY_ENFORCED]){
                CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(caseRecord.ContactId, '', '', '', '', '', '', '', contactAsset.Id);
                payload.assetName = contactAsset.Name;
                payLoadFST.add(payload);
            }
            return payLoadFST;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Updates the case status     
    @AuraEnabled
    public static void updateCaseStatus(String caseId,String status){
        try{
            Case caseRecord = new Case();
            caseRecord.Id = caseId; 
            if(String.isNotBlank(status)){
                caseRecord.Internal_Status__c = status;
            }
            if(Case.SObjectType.getDescribe().isUpdateable()){
                update caseRecord;
            }                    
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Updates the Entity Reviewer of case 
    @AuraEnabled
    public static void updateEntityReviewer(String caseId){
        try{
            Case caseRecord = new Case();
            caseRecord.Id = caseId;
            Id conId = AppForCertHelper.retrieveCurrentContactId();
            if(String.isNotBlank(conId)){
                caseRecord.Entity_Reviewer__c = conId;
            }  
            if(Case.SObjectType.getDescribe().isUpdateable()){
                update caseRecord;
            }                    
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Updates the case's step number
    @AuraEnabled
    public static void updateStep(Integer stepNumber, String caseId){
        try{
            Case caseRecord = [SELECT Id,Internal_Status__c,Entity_Review_Step__c FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
            if(((caseRecord.Entity_Review_Step__c==null || caseRecord.Entity_Review_Step__c<stepNumber) && stepNumber!=null) && Case.SObjectType.getDescribe().isUpdateable()){
                caseRecord.Entity_Review_Step__c = stepNumber;
                update caseRecord;
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Updates the Asset2Ver object    
    @AuraEnabled
    public static Boolean updateAsset2VerDtl(string jsonString){
        Boolean retVal = false;
        try{
            EntityCredVerController.AssetVerWrapper assVerObject = (EntityCredVerController.AssetVerWrapper) JSON.Deserialize(jsonString, EntityCredVerController.AssetVerWrapper.class);
            Case verRecord = new Case(); 
            verRecord.Id = assVerObject.caseId;
            verRecord.Certify_the_Document__c = assVerObject.cert;
            verRecord.Reason_for_not_Certifying__c = assVerObject.reason;
            verRecord.Comments_for_not_Certifying__c = assVerObject.com;
            if(Case.SObjectType.getDescribe().isUpdateable()){
                update verRecord;
                retVal = true;
            }  
            if(assVerObject.cert == Constants.CANNOT_CERTIFY_ENTITY){
                markAssetsForDeletionCannotCert(assVerObject.caseId,assVerObject.retName,true);
            }
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
    }
    public static void markAssetsForDeletionCannotCert(string caseId,string ret,Boolean var){
        Boolean delAsst = markAssetsForDeletion(caseId,ret,var);
    }
    public class AssetVerWrapper{
        @auraenabled public String ass2VerId {get;set;}
        @auraenabled public String cert {get;set;}
        @auraenabled public String reason {get;set;}
        @auraenabled public String com {get;set;} 
        @auraenabled public String caseId {get;set;} 
        @auraenabled public String retName {get;set;}         
    }   
    @AuraEnabled(cacheable = false)
    public static Boolean showReviewScreen(String caseId){        
        Boolean returnVal = false;
		try{
			List<Verification_Packet__c> vp = new List<Verification_Packet__c>();                
			vp = [SELECT Id,Entity_provide_the_credential__c,Translation_included__c FROM Verification_Packet__c WHERE Case__r.Id =:caseId AND Is_Active__c =:TRUE WITH 		 SECURITY_ENFORCED];  
			if(!vp.isEmpty() && (!vp[0].Entity_provide_the_credential__c || vp[0].Translation_included__c)){
			    returnVal = true;
			}		            
		}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
		return returnVal;
	} 
    //get details of supporting documents from ECFMG
	@AuraEnabled(Cacheable = false)
	public static List<Asset> getAdditionalDocuments(String caseId){
        try{
            String verificationPackageId = null;
            List<Verification_Packet__c> packetList = new List<Verification_Packet__c>();
            List<Asset2Verification__c> asset2VerPacketList = new List<Asset2Verification__c>();
            packetList = [Select Id From Verification_Packet__c where case__c =: caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            if(!packetList.isEmpty()){
                verificationPackageId = packetList[0].Id;
            }
            asset2VerPacketList = [Select Id,Asset__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT AND Asset__r.Status !=: Constants.ASSET_STATUS_OUTDATED WITH SECURITY_ENFORCED];
            List<String> assetIds = new List<String>();
            for(Asset2Verification__c asst2Ver : asset2VerPacketList){
                assetIds.add(asst2Ver.Asset__c);
            }
            List<Asset> assetList = [Select Azure_Storage_URL__c From Asset where Id IN:assetIds AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND Name !=: Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS WITH SECURITY_ENFORCED];
            return assetList;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //get details of verification packet related to case
	@AuraEnabled(Cacheable = false)
	public static Verification_Packet__c getVerificationPacket(String caseId){
        try{
            List<Verification_Packet__c> verificationPackages = [Select Id, Request_Additional_Information__c, Case__r.Document_Type__c, Case__r.ContactId, Case__r.Credential_Available__c, Case__r.No_Credential_Reason__c, Case__r.No_Credential_Reason_Comment__c, Entity_Provide_The_Credential__c From Verification_Packet__c where case__c =: caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            if(!verificationPackages.isEmpty()){
                return verificationPackages[0];
            }
            return null;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //to update verification packet and create corresponding asset2verification records.
	@AuraEnabled(Cacheable = false)
	public static Boolean updateVerificationPacket(String caseId, String inputJSON){
        try{
            String verificationPackageId = null;
            List<String> supportDocUrls = new List<String>();
            List<String> allDocUrls = new List<String>();
            List<Asset2Verification__c> asset2VerPacketList = new List<Asset2Verification__c>();
            List<Verification_Packet__c> verificationPackages = [Select Id, Request_Additional_Information__c, Entity_Provide_The_Credential__c, case__r.Document_Type__c From Verification_Packet__c where case__c =: caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            if(!verificationPackages.isEmpty()){
                verificationPackageId = verificationPackages[0].Id;
            }
            AddDocWrapper wrapper = (AddDocWrapper) JSON.deserialize(inputJSON, AddDocWrapper.class);
            if(!String.isEmpty(wrapper.supportDocUrlList)){
                supportDocUrls = (List<String>) JSON.deserialize(wrapper.supportDocUrlList, List<String>.class);
            }
            Case credCase = new Case();
            credCase.Id = caseId;
            credCase.Credential_Available__c = wrapper.credAvailable;
            credCase.No_Credential_Reason__c = wrapper.reason;
            credCase.No_Credential_Reason_Comment__c = wrapper.reasonComment;
            credCase.Certify_the_document__c = null;
            if(!String.isBlank(wrapper.credUrl)){
                credCase.Certify_the_document__c = 'Certify';
                credCase.No_Credential_Reason_Comment__c = null;
                credCase.No_Credential_Reason__c = null;
            }
            if(Case.SObjectType.getDescribe().isUpdateable()){
                UPDATE credCase;
            }
            String credUrl = wrapper.credUrl;
            allDocUrls.add(credUrl);
            for(String sUrl: supportDocUrls){
                allDocUrls.add(sUrl);
            }
            asset2VerPacketList = [Select Id,Asset__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND ((Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT AND Asset__r.Name =: Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS AND Asset__r.Status =: Constants.ASSET_STATUS_NEW) OR (Document_Type__c =: Constants.ASSET2VER_DOCTYPE_VERIFIED AND Asset__r.Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST AND Asset__r.Status =: Constants.ASSET_STATUS_INPROGRESS)) AND Asset__r.Azure_Storage_URL__c NOT IN: allDocUrls WITH SECURITY_ENFORCED];
            List<String> assetIds = new List<String>();
            for(Asset2Verification__c asst2Ver : asset2VerPacketList){
                assetIds.add(asst2Ver.Asset__c);
            }
            List<Asset> assetsToUpdateList = new List<Asset>();
            List<RecordType> recTypeToDel = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
			RecordType assetMarkedForDeletionRT = recTypeToDel[0];
            if(Asset.SObjectType.getDescribe().isUpdateable() && Asset2Verification__c.SObjectType.getDescribe().isdeletable()){
                for(Asset a: [SELECT Id, Status FROM Asset WHERE Id IN: assetIds AND ((Name =: Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS AND Status =: Constants.ASSET_STATUS_NEW) OR (Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST AND Status =: Constants.ASSET_STATUS_INPROGRESS)) AND case__c =: caseId WITH SECURITY_ENFORCED]){
                    a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                    a.Case__c = null;
                    a.Contact_Association_Type_Staging__c = null;
                    a.Exam_Registration__c = null;
                    a.Exam_Registration_Exam_Type__c = null;
                    a.RecordTypeId = assetMarkedForDeletionRT.Id;
                    a.parentId = null;
                    a.Parent_Azure_Storage_URL__c = null;
                    assetsToUpdateList.add(a);
                }
                if(!assetsToUpdateList.isEmpty()){
                    UPDATE assetsToUpdateList;
                    DELETE asset2VerPacketList;
                }
            }
            if(!allDocUrls.isEmpty()){
                createAsset2VerRecords(credUrl, supportDocUrls, allDocUrls, verificationPackageId);
            }
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //wrapper for additionaldocReview
    public class AddDocWrapper{
		@auraenabled public string supportDocUrlList {get; set;}
		@auraenabled public string credUrl {get; set;}
		@auraenabled public string reason {get; set;}
		@auraenabled public string reasonComment {get; set;}
		@auraenabled public string credAvailable {get; set;}
    }
    //to create asset2 verification records for new assets
	public static Boolean createAsset2VerRecords(String credUrl, List<String> supportUrls, List<String> allDocUrl, String verificationPackageId){
        try{
            List<Asset2Verification__c> newCredAsset2VerPacketList = new List<Asset2Verification__c>();
            List<Asset2Verification__c> credAsset2VerPacketList = new List<Asset2Verification__c>();
            List<Asset2Verification__c> suppportAsset2VerPacketList = new List<Asset2Verification__c>();
            Map<String, String> id2UrlAssetMap = new Map<String, String>();
            Set<Id> vpAssetSet = new Set<Id>();
            List<Verification_Packet__c> verificationPackages = [Select Id, Request_Additional_Information__c, Entity_Provide_The_Credential__c, Case__c FROM Verification_Packet__c WHERE Id =: verificationPackageId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            List<Asset> assetList = new List<Asset>();
            for(Verification_Packet__c vp:verificationPackages){
                vpAssetSet.add(vp.Case__c);
            }
            credAsset2VerPacketList = [Select Id,Asset__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND Document_Type__c =: Constants.ASSET2VER_DOCTYPE_VERIFIED AND Asset__r.Azure_Storage_URL__c =: credUrl WITH SECURITY_ENFORCED];
            if(credAsset2VerPacketList.isEmpty() && credUrl != null){
                for(Asset assetLst : [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c =: credUrl AND Case__c IN: vpAssetSet AND Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST AND Status =: Constants.ASSET_STATUS_INPROGRESS WITH SECURITY_ENFORCED]){
                    Asset2Verification__c newAsset2Ver = new Asset2Verification__c();
                    newAsset2Ver.Verification_Packet__c = verificationPackageId;
                    newAsset2Ver.Azure_Document_URL__c = credUrl;
                    newAsset2Ver.Document_Type__c = constants.ASSET2VER_DOCTYPE_VERIFIED;
                    newAsset2Ver.Asset__c = assetLst.Id;
                    newCredAsset2VerPacketList.add(newAsset2Ver);
            	}
            }
            assetList = [SELECT id, Azure_Storage_URL__c FROM ASSET where Azure_Storage_URL__c IN:supportUrls WITH SECURITY_ENFORCED];
            for(Asset asst: assetList){
                id2UrlAssetMap.put(asst.Azure_Storage_URL__c, asst.Id);
            }
            Map<String, String> a2vToAssetUrlMap = new Map<String, String>();
            suppportAsset2VerPacketList = [Select Id, Asset__r.Azure_Storage_URL__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT AND Asset__r.Azure_Storage_URL__c IN: supportUrls WITH SECURITY_ENFORCED];
            for(Asset2Verification__c a2v : suppportAsset2VerPacketList){
                a2vToAssetUrlMap.put(a2v.Asset__r.Azure_Storage_URL__c, a2v.Id);
            }
            for(String url : supportUrls){
                if(a2vToAssetUrlMap.get(url) == null){
                    Asset2Verification__c newAsset2Ver = new Asset2Verification__c();
                    newAsset2Ver.Verification_Packet__c = verificationPackageId;
                    newAsset2Ver.Azure_Document_URL__c = url;
                    newAsset2Ver.Asset__c = id2UrlAssetMap.get(url);
                    newAsset2Ver.Document_Type__c = constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
                    newCredAsset2VerPacketList.add(newAsset2Ver);
                }
            }
            if(!newCredAsset2VerPacketList.isEmpty() && Asset2Verification__c..SObjectType.getDescribe().isCreateable()){
                INSERT newCredAsset2VerPacketList;
            }
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //to mark the asset for deletion.
    @AuraEnabled(Cacheable = false)
    public static Boolean deleteDocuments(String caseId){
        try{
            String verificationPackageId = null;
            List<Verification_Packet__c> packetList = new List<Verification_Packet__c>();
            List<Asset2Verification__c> asset2VerPacketList = new List<Asset2Verification__c>();
            packetList = [Select Id From Verification_Packet__c where case__c =: caseId AND Is_Active__c = true WITH SECURITY_ENFORCED];
            if(!packetList.isEmpty()){
                verificationPackageId = packetList[0].Id;
            }
            asset2VerPacketList = [Select Id,Asset__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND ((Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT AND Asset__r.Name =: Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS AND Asset__r.Status =: Constants.ASSET_STATUS_NEW) OR (Document_Type__c =: Constants.ASSET2VER_DOCTYPE_VERIFIED AND Asset__r.Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST AND Asset__r.Status =: Constants.ASSET_STATUS_INPROGRESS)) WITH SECURITY_ENFORCED];
            List<String> assetIds = new List<String>();
            for(Asset2Verification__c asst2Ver : asset2VerPacketList){
                assetIds.add(asst2Ver.Asset__c);
            }
            List<Asset> assetsToUpdateList = new List<Asset>();
            List<RecordType> recTypeToDel = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
			RecordType assetMarkedForDeletionRT = recTypeToDel[0];
            if(Asset.SObjectType.getDescribe().isUpdateable()){
                for(Asset a: [SELECT Id, Status FROM Asset WHERE Id NOT IN: assetIds AND ((Name =: Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS AND Status =: Constants.ASSET_STATUS_NEW) OR (Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST AND Status =: Constants.ASSET_STATUS_INPROGRESS)) AND case__c =: caseId WITH SECURITY_ENFORCED]){
                    a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                    a.Case__c = null;
                    a.Contact_Association_Type_Staging__c = null;
                    a.Exam_Registration__c = null;
                    a.Exam_Registration_Exam_Type__c = null;
                    a.RecordTypeId = assetMarkedForDeletionRT.Id;
                    a.parentId = null;
                    a.Parent_Azure_Storage_URL__c = null;
                    assetsToUpdateList.add(a);
                }
                if(!assetsToUpdateList.isEmpty()){
                    UPDATE assetsToUpdateList;
                }
            }
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //to get the credential asset Url.
    @AuraEnabled(Cacheable = false)
    public static String getCredentialUrl(String verificationPackageId){
        try{
            String credUrl = null;
            List<Asset2Verification__c> credAsset2VerPacketList = new List<Asset2Verification__c>();
            credAsset2VerPacketList = [Select Id,Asset__r.Azure_Storage_URL__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND Document_Type__c =: Constants.ASSET2VER_DOCTYPE_VERIFIED AND Asset__r.Status =: Constants.ASSET_STATUS_INPROGRESS WITH SECURITY_ENFORCED];
            if(!credAsset2VerPacketList.isEmpty()){
                credUrl = credAsset2VerPacketList[0].Asset__r.Azure_Storage_URL__c;
            }
            return credUrl;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //to get the support asset Url.
    @AuraEnabled(Cacheable = false)
    public static List<String> getSupportAssetUrl(String verificationPackageId){
        try{
            List<String> supportUrls = new List<String>();
            List<Asset2Verification__c> credAsset2VerPacketList = new List<Asset2Verification__c>();
            credAsset2VerPacketList = [Select Id,Asset__r.Azure_Storage_URL__c FROM Asset2Verification__c where Verification_Packet__c =: verificationPackageId AND Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT AND Asset__r.Status =: Constants.ASSET_STATUS_NEW AND Asset__r.Name =: Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS WITH SECURITY_ENFORCED];
            for(Asset2Verification__c a2v : credAsset2VerPacketList){
                supportUrls.add(a2v.Asset__r.Azure_Storage_URL__c);
            }
            return supportUrls;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //to check whether display additional document review screen or not.
    @AuraEnabled(Cacheable = false)
    public static Boolean checkDisplayCondition(String caseId){
        try{
            List<Asset> supportDocs = getAdditionalDocuments(caseId);
            Verification_Packet__c verPacket = getVerificationPacket(caseId);
            if(!supportDocs.isEmpty() || verPacket.Entity_Provide_The_Credential__c == true){
                return true;
            }
            return false;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }   
    @AuraEnabled
    public static string createEcfmgVerForm(String caseRecordId, string selectedEntityId, string certifiedValue){
        try{
            string entityUserId = string.valueOf(AppForCertHelper.retrieveCurrentContactId());
            List<Id> docConfigIds = new List<Id>();
            List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
            List<Asset> verFormAssetList = new List<Asset>();
            verFormAssetList = [SELECT Id FROM Asset WHERE case__c = :caseRecordId AND Type__c = :constants.ASSET_TYPE_VERIFICATION_FORM AND Status = :constants.ASSET_STATUS_NEW WITH SECURITY_ENFORCED];
            if(certifiedValue == Constants.NO_CREDENTIAL){
                docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_NO_CREDENTIAL_VERFORM WITH SECURITY_ENFORCED LIMIT 1];
            }
            else if(certifiedValue == Constants.CERTIFY_ENTITY){
                docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_CERTIFIED_ECFMG_VERFORM WITH SECURITY_ENFORCED LIMIT 1];
            }
            else{
                docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_NONCERT_ECFMG_VERFORM WITH SECURITY_ENFORCED LIMIT 1];
            }
            if(!docConfiList.isEmpty()){
                docConfigIds.add(docConfiList[0].Id);    
            }
            cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel();
            cdm.docConfigIds = docConfigIds;
            cdm.objectId = caseRecordId;
            cdm.pdfActionType = 'MERGE';
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
            List<Case> credVerCase = [SELECT Id, AccountId, ContactId, Contact.Email FROM Case WHERE Id = :caseRecordId WITH SECURITY_ENFORCED];
            Actionable_UploadDocumentToAzureBlob.PayloadWrapper payload = new Actionable_UploadDocumentToAzureBlob.PayloadWrapper();
            payload.contactId = String.valueOf(credVerCase[0].ContactId);
            payload.assetName = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM;
            payload.documentType = Constants.ASSET_TYPE_VERIFICATION_FORM;
            payload.assetRecordType = Constants.ASSET_RECORD_TYPE_VERIFICATION;
            payload.createOrReplace = 'replace';
            payload.caseId = caseRecordId;
            payload.assetCreationRequired = 'true';
            payload.assetStatus = Constants.ASSET_STATUS_NEW;
            payload.createFromPB = 'true';
            payload.createAsset2Ver = 'true';
            String fileName = String.valueOf(credVerCase[0].ContactId) + '_Returned_Verification_Form';
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
            if(!verFormAssetList.isEmpty()){
                deleteVerFormAssetList(verFormAssetList);
            }
            return returnVal;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        } 
    }   
    public static void deleteVerFormAssetList(List<Asset> verFormAssetList){
        List<RecordType> recordTypes = new List<RecordType> ();
        List<Asset> verFormAssetListToDelete = new List<Asset>();
        recordTypes = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
        For(Asset eachAsset:verFormAssetList){
            eachAsset.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
            eachAsset.case__c = null;
            eachAsset.RecordTypeId = recordTypes[0].Id;
            verFormAssetListToDelete.add(eachAsset);
        }
        if(Asset.SObjectType.getDescribe().isUpdateable()){
            update verFormAssetListToDelete;
        }
    }
    @AuraEnabled(Cacheable = false)
    public static String getVerifiedCredUrl(Id caseId, String retName){
        try{
            List<RecordType> credRecordType = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
            String credUrl = null;
            List<Asset> returnedAssetList = new List<Asset>();
            returnedAssetList = [Select Id, Azure_Storage_URL__c FROM Asset where Case__c =:caseId AND Name =: retName AND Type__c =:Constants.ASSET_TYPE_RETURNED_CREDENTIAL
                                 AND Status =: Constants.ASSET_STATUS_NEW AND recordTypeId =:credRecordType[0].Id WITH SECURITY_ENFORCED];
            if(!returnedAssetList.isEmpty()){
                credUrl = returnedAssetList[0].Azure_Storage_URL__c;
            }
            return credUrl;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean checkExistingReviewer(Id caseId){
        try{
            Case cse = [SELECT Id, Entity_Reviewer__c FROM Case WHERE Id =:caseId WITH SECURITY_ENFORCED];
            id conId = AppForCertHelper.retrieveCurrentContactId();
            if(conId == cse.Entity_Reviewer__c){
                return true;
            }else{
                return false;
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // method to update assets Status to mark for deletion
	@AuraEnabled
	public static Boolean markAssetsForDeletion(String caseId,String retName,Boolean notCertified){
        Boolean retVal = false;
        List<Asset2Verification__c> asst2VerList = new List<Asset2Verification__c>(); 
        Set<String> asVerList = new Set<String>();
        try{
            List<Asset> assetsToUpdateList = new List<Asset>();
            List<RecordType> rtsDel = new List<RecordType>();
            List<RecordType> rtsCred = new List<RecordType>();
            if(RecordType.SObjectType.getDescribe().isAccessible()){
                rtsDel = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
                rtsCred = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND SObjectType = 'Asset'];
            }
            if(rtsDel.isEmpty()){
                throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
            }
            RecordType assetMarkedForDeletionRT = rtsDel[0];
            if(Asset.SObjectType.getDescribe().isUpdateable()){
                for(Asset a: [SELECT Id,Azure_Storage_URL__c FROM Asset WHERE case__c =: caseId AND Name =: retName AND status =: 'New' AND recordTypeId =: rtsCred[0].Id WITH SECURITY_ENFORCED]){
                    a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                    a.Case__c = null;
                    a.Contact_Association_Type_Staging__c = null;
                    a.Exam_Registration__c = null;
                    a.Exam_Registration_Exam_Type__c = null;
                    a.RecordTypeId = assetMarkedForDeletionRT.Id;
                    a.parentId = null;
                    a.Parent_Azure_Storage_URL__c = null;
                    assetsToUpdateList.add(a);
                    if(notCertified){
                        asVerList.add(a.Azure_Storage_URL__c);
                    }
                }
                if(!assetsToUpdateList.isEmpty()){
                    UPDATE assetsToUpdateList;
                    asst2VerList = [SELECT Id,OwnerId,Azure_Document_URL__c FROM Asset2Verification__c WHERE Azure_Document_URL__c IN: asVerList];
                    if(!asst2VerList.isEmpty()){
                        asst2VerList[0].OwnerId = UserInfo.getUserId();
                        UPDATE asst2VerList;
                        DELETE asst2VerList;
                    }
                }
            }
            retVal = true;        
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
	}
    // method to update assets Status to mark for deletion
	@AuraEnabled
	public static Boolean checkReturnedAsstExist(String caseId,String retName,String azureURL){
        Boolean retVal = false;
        try{
            List<Asset> assetsList = new List<Asset>();            
            List<RecordType> rtsCred = new List<RecordType>();
            List<Asset2Verification__c> asstVerList = new List<Asset2Verification__c>();
            if(RecordType.SObjectType.getDescribe().isAccessible()){                
                rtsCred = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND SObjectType = 'Asset'];
            }
            if(rtsCred.isEmpty()){
                throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
            }            
            if(Asset.SObjectType.getDescribe().isAccessible()){
                assetsList = [SELECT Id FROM Asset WHERE case__c =: caseId AND Name =: retName AND status =: Constants.ASSET_STATUS_NEW AND recordTypeId =: rtsCred[0].Id WITH SECURITY_ENFORCED];
                if(!assetsList.isEmpty()){
                    retVal = true;            
                } 
                else if(azureURL !=  null && azureURL !=  '' && Asset2Verification__c.SObjectType.getDescribe().isAccessible()){
                    asstVerList = [SELECT Id FROM Asset2Verification__c WHERE Azure_Document_URL__c =: azureURL];
                    if(!asstVerList.isEmpty()){
                        retVal = true;            
                    }
                }  
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
	}
    @AuraEnabled
	public static Id checkAssetExist(String caseId, String assetUrl, String type){
        List<RecordType> rtsCred = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){                
            rtsCred = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND SObjectType = 'Asset'];
        }
        List<Asset> assetRec=[SELECT Id FROM Asset WHERE case__c =: caseId AND Name =: Constants.ASSET_TYPE_RETURNED_CREDENTIAL AND status =: Constants.ASSET_STATUS_NEW AND recordTypeId =: rtsCred[0].Id WITH SECURITY_ENFORCED];
        Case caseRec=[SELECT Id, ContactId FROM Case WHERE Id=: caseId WITH SECURITY_ENFORCED];
        Id retVal = null;
        try{
            if(Asset.SObjectType.getDescribe().isAccessible()){
               if(!assetRec.isEmpty()){
                   for(Asset asst:assetRec){
                    	retVal = asst.Id;    
                   }
                } 
                else{
                    Asset newAsset=new Asset();
                    newAsset.Name=Constants.ASSET_TYPE_RETURNED_CREDENTIAL;
                    newAsset.Type__c=type;
                    newAsset.Status='New';
                    newAsset.Azure_Storage_URL__c=assetUrl;
                    newAsset.Case__c=caseId;
                    newAsset.ContactId=caseRec.ContactId;
                    INSERT newAsset;
                    retval= newAsset.Id;
                } 
            }                  
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
	}
    @AuraEnabled
	public static Boolean checkAsstExist(String azureUrl){
        Boolean retVal = false;
        try{
            List<Asset> assetsList = new List<Asset>();                      
            if(Asset.SObjectType.getDescribe().isAccessible()){
                assetsList = [SELECT Id FROM Asset WHERE Azure_Storage_URL__c =:azureUrl WITH SECURITY_ENFORCED];
                if(!assetsList.isEmpty()){
                    retVal = true;            
                }  
            }                  
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
	}  
    // method to get Returned Asset	
	public static Map<string,string> getReturnedAsstExist(String caseId,String retName,Map<string,string> returnVal){
        Map<string,string> retVal = returnVal;
        try{
            List<Asset> assetsList = new List<Asset>();            
            List<RecordType> rtsCred = new List<RecordType>();
            if(RecordType.SObjectType.getDescribe().isAccessible()){                
                rtsCred = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND SObjectType = 'Asset'];
            }
            if(rtsCred.isEmpty()){
                throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
            }            
            if(Asset.SObjectType.getDescribe().isAccessible() && retName != ''){
                assetsList = [SELECT Id,Azure_Storage_URL__c FROM Asset WHERE case__c =: caseId AND Name =: retName AND status =: Constants.ASSET_STATUS_NEW AND recordTypeId =: rtsCred[0].Id WITH SECURITY_ENFORCED];
                if(!assetsList.isEmpty()){
                    retVal.put('azureUrlSoc',assetsList[0].Azure_Storage_URL__c); 
                    returnVal.put('assReturnedExst','true');             
                }  
            }                  
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
    }
    @AuraEnabled
    //Method to check whether the Verification Response can be Auto-Accepted or not - US 12201
    public static Boolean checkVerResAccOrNot(Id caseId){
        try{
            Boolean updatedOrNot = false;
            Case credCase = [SELECT Id, Entity__c, Certify_the_Document__c FROM Case WHERE Id =: caseId];
            Id entityId = credCase.Entity__c;
            Verification_Packet__c verPckts = [SELECT Id, Request_additional_information__c, Entity_provide_the_credential__c, Case__r.Document_Type__c,(SELECT Id FROM Send_Requests__r WHERE Is_Deleted__c = false ORDER BY createddate DESC LIMIT 1) FROM Verification_Packet__c WHERE Case__c =: caseId AND Is_Active__c = True WITH SECURITY_ENFORCED];
            List<Send_Request__c> sendReqList = new List<Send_Request__c>();
            for(Send_Request__c sendReqRec:verPckts.Send_Requests__r){
                sendReqRec.Received_Date__c = system.today();
                sendReqList.add(sendReqRec);
            }
            if(!sendReqList.isEmpty() && Send_Request__c.SObjectType.getDescribe().isUpdateable()){
                update sendReqList;
            }
            Account currentEntity = [SELECT Id, Entity_Restriction__c FROM Account WHERE Id =: entityId WITH SECURITY_ENFORCED];
            Boolean checkAcceptOrNot = false;
            //Conditions checked to see whether the Verification response is auto-acceptable
            if(verPckts.Entity_provide_the_credential__c == false && verPckts.Request_additional_information__c == null && verPckts.Case__r.Document_Type__c != 'Certificate of Good Standing' && credCase.Certify_the_Document__c == 'Certify' && currentEntity.Entity_Restriction__c == null){
                checkAcceptOrNot = true;
            }
            if(checkAcceptOrNot){
                updatedOrNot = updCaseVerPcktAssets(caseId, verPckts.Id);
            }
            else{
                updatedOrNot = updCaseVPForNotAccRes(caseId, entityId);
            }
            return updatedOrNot;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }   
    }
    public static Boolean updCaseVerPcktAssets(Id caseId, Id verpcktId){
        try{
            Case credVerCase = [SELECT Id, Internal_Status__c, External_Status__c, Document_Type__c, ContactEmail, Contact.name, CaseNumber FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
            credVerCase.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
            credVerCase.Entity_External_Status__c = Constants.CASE_ENTITY_EXTERNAL_STATUS_COMPLETE;
            credVerCase.Entity_Review_Step__c = 0;
            if(Case.SObjectType.getDescribe().isUpdateable() && credVerCase.Id != null){
                UPDATE credVerCase;
            }
            List<Asset2Verification__c> asst2VerList = new List<Asset2Verification__c>();
            asst2VerList = [SELECT Id, Asset__c FROM Asset2Verification__c WHERE Verification_Packet__c =: verpcktId AND (Document_Type__c =: Constants.ASSET2VER_DOCTYPE_VERIFIED OR Document_Type__c =: Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM OR Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT)];
            List<String> assetIds = new List<String>();
            for(Asset2Verification__c ass2ver : asst2VerList){
                assetIds.add(ass2ver.Asset__c);
            }
            List<Asset> verAsstList = new List<Asset>();
            verAsstList = [SELECT Id, Status, RecordTypeId, RecordType.DeveloperName, Type__c FROM Asset WHERE Id IN: assetIds AND Status != 'Outdated' AND Type__c !=: Constants.ASSET_TYPE_TRANSLATION];
            List<Asset> updAsstList = new List<Asset>();
            Id verifAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
            Id credAssRecTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
            for(Asset asst : verAsstList){
                if(asst.RecordTypeId == verifAssRecTypeId){
                    asst.Name = Constants.ASSET_TYPE_ACCEPTED_VERIFICATION_FORM;
                    asst.Status = Constants.ASSET_STATUS_ACCEPTED;
                }
                if(asst.RecordTypeId == credAssRecTypeId){
                    asst.Name = 'Verified '+ credVerCase.Document_Type__c;
                    asst.Type__c = credVerCase.Document_Type__c;
                    asst.Status = Constants.ASSET_STATUS_VERIFIED;
                }
                if(asst.RecordType.DeveloperName == Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT){
                    asst.Status = Constants.ASSET_STATUS_OUTDATED;
                }
                updAsstList.add(asst);
            }
            if(Asset.SObjectType.getDescribe().isUpdateable() && !updAsstList.isEmpty()){
                UPDATE updAsstList;
            }
            sendMailOnStatusCVAcc(credVerCase);
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        } 
    }
    public static void sendMailOnStatusCVAcc(Case credCase){
        try{
            EmailTemplate template = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =:Constants.EMAIL_CASE_STATUS_UPDATE_ON_CV_ACCEPTED]; //Donot add WITH SECURITY_ENFORCED
            List<OrgWideEmailAddress> addr = [Select Id from OrgWideEmailAddress where displayname =:Constants.ORG_WIDE_ADDRESS]; //Donot add WITH SECURITY_ENFORCED
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTemplateId(template.Id);
            message.setSubject(template.Subject);
            String htmlBody = template.HtmlValue;
            System.debug(template.HtmlValue);
            htmlBody = htmlBody.replace('{!Case.Contact}', credCase.Contact.name);
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', credCase.CaseNumber);
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');
            message.setHtmlBody(htmlBody);
            message.setOrgWideEmailAddressId(addr[0].Id);
            message.setToAddresses(new String[]{credCase.ContactEmail});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    public static Boolean updCaseVPForNotAccRes(Id caseId, Id entityId){
        Boolean updVPAsset = false;
        Map<string,Group> groupMap = new Map<string,Group>();
        Case credCase = [SELECT Id, Internal_Status__c, External_Status__c, Document_Type__c, Certify_the_Document__c, Reason_for_not_Certifying__c, Credential_Available__c, Received_Date__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
        Account currentEntity = [SELECT Id, Entity_Restriction__c FROM Account WHERE Id =: entityId WITH SECURITY_ENFORCED];
        Verification_Packet__c verPckts = [SELECT Id FROM Verification_Packet__c WHERE Case__c =: caseId AND Is_Active__c = True WITH SECURITY_ENFORCED];        
        for(Group rec:[SELECT Id,Name,DeveloperName FROM Group WHERE Type = 'Queue' AND (Group.DeveloperName =: Constants.CASE_QUEUE_NOT_AUTHENTIC_LIST OR Group.DeveloperName =: Constants.CASE_QUEUE_VERIFICATION_REVIEW OR Group.DeveloperName =: Constants.CASE_QUEUE_NOT_VERIFIED) WITH SECURITY_ENFORCED]){
            groupMap.put(rec.DeveloperName,rec);
        }
        credCase.Entity_Review_Step__c = 0;
        if(currentEntity.Entity_Restriction__c != null){
            credCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_RES_REVIEW;
            credCase.Entity_External_Status__c = Constants.CASE_ENTITY_EXTERNAL_STATUS_COMPLETE;
            credCase.OwnerId = groupMap.get(Constants.CASE_QUEUE_VERIFICATION_REVIEW).Id;
            credCase.Received_Date__c = System.today();
        }
        else{
            if(credCase.Certify_the_Document__c == Constants.CANNOT_CERTIFY_ENTITY || (credCase.Certify_the_Document__c == null && credCase.Credential_Available__c == 'No')){
                credCase = updateNotCertifyOwner(credCase,groupMap);
            }
            else if(credCase.Certify_the_Document__c == Constants.CERTIFY_ENTITY){
                credCase.Internal_Status__c =  Constants.CASE_STATUS_PENDING_VER_REVIEW;
                credCase.Entity_External_Status__c = Constants.CASE_ENTITY_EXTERNAL_STATUS_COMPLETE;
                credCase.OwnerId = groupMap.get(Constants.CASE_QUEUE_VERIFICATION_REVIEW).Id;
                credCase.Received_Date__c = System.today();
            }
        }
        if(Case.SObjectType.getDescribe().isUpdateable() && credCase.Id != null){
            UPDATE credCase;
        }
        updVPAsset = updVPAssetsforNoAcc(credCase, verPckts.Id);
        return updVPAsset;
    }
    // updates the case record to not verified for two conditions (1) Cannot certify the credential (2) Credential is not available 
    public static Case updateNotCertifyOwner(Case credCase,Map<string,Group> groupMap){
        credCase.Internal_Status__c = Constants.CASE_STATUS_NOT_VERIFIED;
        credCase.Entity_External_Status__c = Constants.CASE_ENTITY_EXTERNAL_STATUS_COMPLETE;
        if(credCase.Reason_for_not_Certifying__c == 'Credential is not authentic'){
            credCase.OwnerId = groupMap.get(Constants.CASE_QUEUE_NOT_AUTHENTIC_LIST).Id;
            credCase.Received_Date__c = System.today();
        }
        else{
            credCase.OwnerId = groupMap.get(Constants.CASE_QUEUE_NOT_VERIFIED).Id;
            credCase.Received_Date__c = System.today();
        }
        return credCase;
    }
    // Updates Asset status to submitted.
    public static Boolean updVPAssetsforNoAcc(Case credCase, Id verPckId){
        List<Asset2Verification__c> asst2VerList = new List<Asset2Verification__c>();
        asst2VerList = [SELECT Id, Asset__c FROM Asset2Verification__c WHERE Verification_Packet__c =: verPckId AND (Document_Type__c =: Constants.ASSET2VER_DOCTYPE_VERIFIED OR Document_Type__c =: Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM OR Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT )];
        List<String> assetIds = new List<String>();
        for(Asset2Verification__c ass2ver : asst2VerList){
            assetIds.add(ass2ver.Asset__c);
        }
        List<Asset> verAsstList = new List<Asset>();
        verAsstList = [SELECT Id, Name, Status, Type__c, RecordTypeId FROM Asset WHERE Id IN: assetIds AND Status != 'Outdated'];
        List<Asset> updAsstList = new List<Asset>();
        Id verifAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        Id credAssRecTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        for(Asset asst : verAsstList){
            if(asst.RecordTypeId == verifAssRecTypeId){
                asst.Status = Constants.ASSET_STATUS_SUBMITTED;
            }
            if(asst.RecordTypeId == credAssRecTypeId){
                if(asst.Type__c == 'Translation'){                    
                    asst.Status =  Constants.ASSET_STATUS_SUBMITTED;
                }else{
                    asst.Name = 'Returned '+ credCase.Document_Type__c;
                    asst.Type__c =  credCase.Document_Type__c;
                    asst.Status = Constants.ASSET_STATUS_SUBMITTED;
                }
            }
            if(asst.RecordTypeId == suppDocAssRecTypeId){
                asst.Status =  Constants.ASSET_STATUS_SUBMITTED;
                if(asst.Name != Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS){
                    asst.Status =  Constants.ASSET_STATUS_OUTDATED;
                }
                asst.Name = 'Returned Supporting Documents';
            }
            updAsstList.add(asst);
        }
        if(Asset.SObjectType.getDescribe().isUpdateable() && !updAsstList.isEmpty()){
            UPDATE updAsstList;
        }
        return true;
    }
    // This method returns the verification form url
    @AuraEnabled
    public static string getEcfmgVerFormURL(String caseId){
        string ecfmgVerFormURL = '';
        try{
            if(Asset2Verification__c.SObjectType.getDescribe().isAccessible()){
                ecfmgVerFormURL = [SELECT Id,Azure_Document_URL__c FROM Asset2Verification__c where Verification_Packet__r.Case__c =:caseId AND Document_Type__c =:Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM WITH SECURITY_ENFORCED limit 1].Azure_Document_URL__c;
            }
        }
        Catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return ecfmgVerFormURL;
    }
    //method to get the entity seal from entity id.
    @AuraEnabled
	public static String getEntitySeal(String entityId){
        try{
            List<Asset> entityAsset = new List<Asset>();
            entityAsset = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Type__c = :constants.ASSET_TYPE_ENTITY_SEAL AND AccountId = :entityId AND Status = :Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
            if(!entityAsset.isEmpty()){
                List<String> imageUrlList = entityAsset[0].Azure_Storage_URL__c.split('/');
                String url = CloudStorageUtils.getRequestUrl(DocumentEnums.DocumentAccessLevel.READ, imageUrlList[imageUrlList.size()-1]);
                HttpRequest req = new HttpRequest();
                req.setEndpoint(url);
                req.setMethod('GET');
                Http binding = new Http();
                HttpResponse res = binding.send(req);
                Blob image = res.getBodyAsBlob();
                return 'data:'+res.getHeader('Content-Type')+';base64,'+EncodingUtil.base64Encode(image);
            }
            return null;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    //to mark the asset for deletion.
    @AuraEnabled(Cacheable = false)
    public static Boolean deleteSupportDocuments(String assetUrl){
        try{
            if(String.isNotBlank(assetUrl)){
                List<Asset2Verification__c> asset2VerPacketList = new List<Asset2Verification__c>();
                asset2VerPacketList = [Select Id,Asset__c FROM Asset2Verification__c where Azure_Document_URL__c =: assetUrl WITH SECURITY_ENFORCED];
                List<Asset> assetsToUpdateList = new List<Asset>();
                List<RecordType> recTypeToDel = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
                RecordType assetMarkedForDeletionRT = recTypeToDel[0];
                if(Asset.SObjectType.getDescribe().isUpdateable()){
                    for(Asset a: [SELECT Id, Status FROM Asset WHERE Azure_Storage_URL__c =: assetUrl WITH SECURITY_ENFORCED]){
                        a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                        a.Case__c = null;
                        a.Contact_Association_Type_Staging__c = null;
                        a.Exam_Registration__c = null;
                        a.Exam_Registration_Exam_Type__c = null;
                        a.RecordTypeId = assetMarkedForDeletionRT.Id;
                        a.parentId = null;
                        a.Parent_Azure_Storage_URL__c = null;
                        assetsToUpdateList.add(a);
                    }
                    if(!assetsToUpdateList.isEmpty()){
                        UPDATE assetsToUpdateList;
                    }
                }
                if(Asset2Verification__c.SObjectType.getDescribe().isdeletable() && !asset2VerPacketList.isEmpty()){
                    delete asset2VerPacketList;
                }
            }
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = false)
    public static Boolean showReviewScreenForTrans(String caseId){        
        Boolean returnVal = false;
		try{
			List<Verification_Packet__c> vp = new List<Verification_Packet__c>();                
			vp = [SELECT Id,Entity_provide_the_credential__c,Translation_included__c FROM Verification_Packet__c WHERE Case__r.Id =:caseId AND Is_Active__c =:TRUE WITH 		 SECURITY_ENFORCED];  
			if(!vp.isEmpty() && (vp[0].Translation_included__c)){
			    returnVal = true;
			}		            
		}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
		return returnVal;
	}
    //@description: Method to get the prior case status after status update 
    @AuraEnabled
    public static CaseHistory getPriorCaseStatus(Id caseId){
        try{
            CaseHistory caseHist = [SELECT Id, CaseId, Field, NewValue, OldValue FROM CaseHistory WHERE CaseId =: caseId AND Field = 'Internal_Status__c' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            return caseHist;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //@description: Method to get the Verification Review Affirmation
    @AuraEnabled(cacheable = true)
    public static List<String> getVerRevAffirm(Id caseId){
        try{
            Id affirmVerRevId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
            List<String> incReasons = new List<String>();
            Affirmation__c verRevAff = [SELECT Id, Incomplete_Reason_Authorization__c, Incomplete_Reason_Completion_Med_Ed_form__c, Incomplete_Reason_Completion_Verform__c, Incomplete_Reason_Credential__c,
            Incomplete_Reason_Envelope__c, Incomplete_Reason_Grades__c, Incomplete_Reason_Name_Match__c, Incomplete_Reason_Name_Missing__c, Incomplete_Reason_OfficeSeal_Stamp_Miss__c, Incomplete_Reason_OfficeSeal_StampNotMat__c,
            Incomplete_Reason_Other__c, Incomplete_Reason_Response__c, Incomplete_Reason_Return__c, Incomplete_Reason_Signature_Match__c, Incomplete_Reason_Signature_Missing__c, Incomplete_Reason_Title_Match__c,
            Incomplete_Reason_Title_Missing__c, Incomplete_Reason_Transcript__c, Incomplete_Reason_Transcript_Seal__c, Incomplete_Reason_Verification__c, Status__c, Comments__c FROM Affirmation__c WHERE Case__c =: caseId AND RecordTypeId =: affirmVerRevId WITH SECURITY_ENFORCED LIMIT 1];
            incReasons = getIncReasonText(verRevAff);
            return incReasons;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //@description: Method to get the Incomplete Reason Text to be displayed to the Entity
    public static List<String> getIncReasonText(Affirmation__c verAffirm){
        try{
            List<String> returnVal = new List<String>();
            List<InComplete_Verification_Reasons__mdt> incResList = [SELECT Id, DeveloperName, Display_Reasons__c, InComplete_Reason__c FROM InComplete_Verification_Reasons__mdt WITH SECURITY_ENFORCED];
            Map<String,String> incReasonMap = new Map<String,String>();
            for(InComplete_Verification_Reasons__mdt rea: incResList){
                incReasonMap.put(rea.DeveloperName, rea.Display_Reasons__c);
            }
            if(verAffirm.Incomplete_Reason_Authorization__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Authorization'));
            }
            if(verAffirm.Incomplete_Reason_Completion_Med_Ed_form__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Completion_Med_Ed_form'));
            }
            if(verAffirm.Incomplete_Reason_Completion_Verform__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Completion_Verform'));
            }
            if(verAffirm.Incomplete_Reason_Credential__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Credential'));
            }
            if(verAffirm.Incomplete_Reason_Envelope__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Envelope'));
            }
            returnVal.addAll(refactgetIncReasonText1(verAffirm,incReasonMap));
            returnVal.addAll(refactgetIncReasonText2(verAffirm,incReasonMap)); 
            returnVal.addAll(refactgetIncReasonText3(verAffirm,incReasonMap));  
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //@description: Refactored method getIncReasonText part 1
    public static List<String> refactgetIncReasonText1(Affirmation__c verAffirm, Map<String,String> incReasonMap){
        try{
            List<String> returnVal = new List<String>();
            if(verAffirm.Incomplete_Reason_Grades__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Grades'));
            }
            if(verAffirm.Incomplete_Reason_Name_Match__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Name_Match'));
            }
            if(verAffirm.Incomplete_Reason_Name_Missing__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Name_Missing'));
            }
            if(verAffirm.Incomplete_Reason_OfficeSeal_Stamp_Miss__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_OfficeSeal_Stamp_Miss'));
            }
            if(verAffirm.Incomplete_Reason_OfficeSeal_StampNotMat__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_OfficeSeal_StampNotMat'));
            }
            if(verAffirm.Incomplete_Reason_Response__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Response'));
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //@description: Refactored method getIncReasonText part 2
    public static List<String> refactgetIncReasonText2(Affirmation__c verAffirm, Map<String,String> incReasonMap){
        try{
            List<String> returnVal = new List<String>();
            if(verAffirm.Incomplete_Reason_Return__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Return'));
            }
            if(verAffirm.Incomplete_Reason_Signature_Match__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Signature_Match'));
            }
            if(verAffirm.Incomplete_Reason_Signature_Missing__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Signature_Missing'));
            }
            if(verAffirm.Incomplete_Reason_Title_Match__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Title_Match'));
            }
            if(verAffirm.Incomplete_Reason_Title_Missing__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Title_Missing'));
            }
            if(verAffirm.Incomplete_Reason_Transcript__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Transcript'));
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //@description: Refactored method getIncReasonText part 3
    public static List<String> refactgetIncReasonText3(Affirmation__c verAffirm, Map<String,String> incReasonMap){
        try{
            List<String> returnVal = new List<String>();
            if(verAffirm.Incomplete_Reason_Transcript_Seal__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Transcript_Seal'));
            }
            if(verAffirm.Incomplete_Reason_Verification__c){
                returnVal.add(incReasonMap.get('Incomplete_Reason_Verification'));
            }
            if(verAffirm.Comments__c != null){
                returnVal.add('Additional Comments: ' + verAffirm.Comments__c);
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}