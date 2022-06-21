// Controller for My Requests Page in Entity Portal
public with sharing class EntityPortalMyRequestsController{
	public EntityPortalMyRequestsController(){ 
    }
	// @description: Method to retrieve contact Id of currently logged in Entity Contact, return type: String
	@AuraEnabled
	public static String getCurrentContactId(){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		return contactId;
	}
	//@description: Method to retrieve Cases of Request Type "Add User" or "Add Service", return type: list of MyRequestCaseWrapper records which contain the request cases and their corresponding services
	@AuraEnabled
	public static List<EntityPortalMyRequestHelper.MyRequestCaseWrapper> getActiveRequests(String currentEntityId){
		List<EntityPortalMyRequestHelper.MyRequestCaseWrapper> wrapperValuesToReturn = new List<EntityPortalMyRequestHelper.MyRequestCaseWrapper>();
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<Case> activeRequestCases = new List<Case>([SELECT Id, CaseNumber, Request_Type_Value__c, ContactId, Contact.FirstName, Contact.LastName, External_Status__c,
														Action_Required__c, CreatedDate, LastModifiedDate
														FROM Case
														WHERE AccountId =: currentEntityId AND
				  										Approver__c =: contactId AND
				  										(Request_Type_Value__c = 'Add User' OR
				   										Request_Type_Value__c = 'Add Service') AND
				  										(External_Status__c =: Constants.CASE_STATUS_SUBMITTED_IN_REVIEW OR
				   										External_Status__c =: Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL OR
				   										External_Status__c =: Constants.CASE_STATUS_PENDING_SIGNATURE_UPLOAD OR
				   										External_Status__c =: Constants.CASE_STATUS_REJECTED OR
				   										External_Status__c =: Constants.CASE_STATUS_ENROLLMENT_COMPLETED OR
				   										External_Status__c =: Constants.CASE_STATUS)
														ORDER BY Action_Required__c DESC NULLS LAST, CreatedDate ASC NULLS LAST]);
		Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap = CaseTriggerHelper.getMapOfCaseIdCase2Service(activeRequestCases);
		for(Case c: activeRequestCases){
			list<String> tempServiceNames = new list<String>();
			if(caseIdCase2ServiceMap.containsKey(c.Id)){
				List<Case2Service__c> tempCase2ServiceList = caseIdCase2ServiceMap.get(c.Id);
				for(Case2Service__c c2s: tempCase2ServiceList){
					tempServiceNames.add(c2s.Service__r.Name);
				}
			}
            else{
				tempServiceNames = null;
			}
			EntityPortalMyRequestHelper.MyRequestCaseWrapper tempWrapObj = new EntityPortalMyRequestHelper.MyRequestCaseWrapper(string.valueOf(c.Id), string.valueOf(c.ContactId), c.CaseNumber, c.Request_Type_Value__c, c.Contact.FirstName, c.Contact.LastName, c.External_Status__c, c.Action_Required__c, String.valueOf(c.CreatedDate), String.valueOf(c.LastModifiedDate), tempServiceNames);
			wrapperValuesToReturn.add(tempWrapObj);
		}
		if(wrapperValuesToReturn.size()>0){
			return wrapperValuesToReturn;
		}
		return null;
	}
	// Purpose : Method to retrieve list of requested Services, Return Type : EntityServiceRequestControllerHelper.ServicesRoleWrapper wrapper list.
	@AuraEnabled(cacheable = false)
	public static List<EntityServiceRequestControllerHelper.ServicesRoleWrapper> getRequestedServices(string caseId){
		List<Case> activeRequestCases = new List<Case>([SELECT Id, CaseNumber, Request_Type_Value__c, ContactId, Contact.FirstName, Contact.LastName, External_Status__c,
														Action_Required__c, CreatedDate, LastModifiedDate
														FROM Case
														WHERE Id =: caseId]);
		Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap = CaseTriggerHelper.getMapOfCaseIdCase2Service(activeRequestCases);
		List<EntityServiceRequestControllerHelper.ServicesRoleWrapper> wrap = new List<EntityServiceRequestControllerHelper.ServicesRoleWrapper>();
		EntityServiceRequestControllerHelper.ServicesRoleWrapper wrapSingle;
		for(Case c: activeRequestCases){
			list<String> tempServiceNames = new list<String>();
			if(caseIdCase2ServiceMap.containsKey(c.Id)){
				List<Case2Service__c> tempCase2ServiceList = caseIdCase2ServiceMap.get(c.Id);
				for(Case2Service__c c2s: tempCase2ServiceList){
					tempServiceNames.add(c2s.Service__r.Name);
					wrapSingle = new EntityServiceRequestControllerHelper.ServicesRoleWrapper(c2s.Service__r.Name, c2s.Service__r.Signature_Required__c, c2s.Service__c);
                	wrap.add(wrapSingle);
				}
			}
		}
		return wrap;
	}
    //Purpose : Method to get Document by Asset Type, Return Type : String
	@AuraEnabled(cacheable = false)
	public static String getSignedSignatureAsset(String contactId){
		String returnValue = '';
		List<Asset> assetList = new List<Asset>();
		String type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
		assetList = [SELECT Id,Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND type__c =: type AND status = 'In Progress' WITH SECURITY_ENFORCED];		
		if(!assetList.isEmpty()){			
			returnValue = assetList[0].Id;
		}
		return returnValue;
	}
	@AuraEnabled(cacheable = false)
	public static CloudStorageController.PayloadWrapper getIncompleteSignedSignatureAsset(String contactId){
		List<Asset> assetList = new List<Asset>(); 
		String type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
		try{
			assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND type__c =: type AND (Case__r.Request_Type_Value__c = 'Add User' OR
						Case__r.Request_Type_Value__c = 'Add Service') AND status = 'Incomplete' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		}catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
		String assetId = null;
        String caseId = null;
		String azureUrl = null;
        String createOrReplace = 'Replace';
		if(!assetList.isEmpty()){
			assetId = assetList[0].Id;
			azureUrl = assetList[0].Azure_Storage_URL__c;
		}
		CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, type, 'Entity Document', createOrReplace, caseId, null, 'true','Incomplete',assetId,type,'','','true',azureUrl);
        return payload;
	}
	//@description: Method to update previously existing Asset's status to Outdated, Case's statuses -Internal "Pending Review", External : "Submitted; In Review at ECFMG", @return type: String
	@AuraEnabled
	public static String updateCaseandAsset(String caseId, String assetAzureUrl, String contactId){
		String type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
		String accId;
		try{
			Case currentCase = [SELECT Id, Internal_Status__c, External_Status__c, AccountId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
			accId = currentCase.AccountId;
			List<Asset> assetList = new List<Asset>([SELECT Id, IsOrphan__c, status, Azure_Storage_URL__c FROM Asset WHERE (ContactId =: contactId OR AccountId =: accId) AND type__c =: type AND (status = :Constants.ASSET_STATUS_IN_PROGRESS OR status = :Constants.ASSET_STATUS_INCOMPLETE) WITH SECURITY_ENFORCED]);
			for(Asset a : assetList){
				if(a.Azure_Storage_URL__c==assetAzureUrl){
					a.IsOrphan__c = false;
					a.Case__c = currentCase.Id;
					a.ContactId = contactId;
					a.AccountId = null;
				}else{
					a.status = Constants.ASSET_STATUS_OUTDATED;
				}
			}
			currentCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
			currentCase.External_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
			if(Case.SObjectType.getDescribe().isUpdateable()){
				UPDATE currentCase;
			}
			if(Asset.SObjectType.getDescribe().isUpdateable()){
				UPDATE assetList;
			}
		}catch(Exception e){
			throw new ControllerException(e.getMessage());
		}
		return 'true';
	}
	//Function to mark the asset for deletion when cancel button is clicked
	@AuraEnabled
    public static String delAssetOnCancel(String assetUrl){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(String.isnotBlank(assetUrl) && Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT Id FROM Asset WHERE Azure_Storage_URL__c =: assetUrl AND Type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =:Constants.ASSET_STATUS_INPROGRESS AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND ContactId = null AND Case__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
				a.Case__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }
			try{
            	UPDATE assetsToUpdateList;
			}catch(Exception e){
				throw new ControllerException(e.getMessage());
			}
		}
		return 'true';
	}
	@AuraEnabled(cacheable = false)
	public static String checkServiceAndAcceptedSignForm(String contactId, String caseId){
		String showUpload = 'false';
		List<Asset> assetList = new List<Asset>(); 
		Case2Service__c serviceRcd = new Case2Service__c();
		try{
			assetList = [SELECT Id FROM Asset WHERE ContactId =: contactId AND type__c =: Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE  AND status = 'Accepted' WITH SECURITY_ENFORCED];	
			serviceRcd = [SELECT Id, Service__r.Signature_Required__c FROM Case2Service__c WHERE Case__c =: caseId WITH SECURITY_ENFORCED];	
			if(assetList.size() == 0 && serviceRcd.Service__r.Signature_Required__c){
				showUpload = 'true';
			}
		}catch(Exception e){
			throw new ControllerException(e.getMessage());
		}
		return showUpload;
	}
}