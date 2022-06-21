public with sharing class EntityAddUser {
    @AuraEnabled(cacheable = true)
    public static List < FetchValueWrapper > fetchPickListValue(sObject objInfo, string picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();

        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();

        // Create a list of wrapper to store picklist value/lable
        list < FetchValueWrapper > objWrapper = new list < FetchValueWrapper > ();

        for (Schema.PicklistEntry a: values) {
            FetchValueWrapper oFetchValueWrapper = new FetchValueWrapper();
            oFetchValueWrapper.slabel = a.getLabel();
            oFetchValueWrapper.svalue = a.getValue();
            objWrapper.add(oFetchValueWrapper);
        }
        return objWrapper;
    }

    
    public class FetchValueWrapper {
        @auraenabled public string slabel {get;set;}
        @auraenabled public string svalue {get;set;}
 
    }

    @AuraEnabled(cacheable = true)
    public static List<ServiceWrapper> getServices(string currentEntityId){
        Id currentUser = AppForCertHelper.retrieveCurrentContactId();
        List<ServiceWrapper> listToReturn = new List<ServiceWrapper>();        
        Id loggedInAccountId = currentEntityId;
        List<CONTACT2ACCTSERVICE__c> coordsRecList = new List<CONTACT2ACCTSERVICE__c>([Select Id, Account_Service__r.Service_Name__c, Account_Service__r.Service__c from CONTACT2ACCTSERVICE__c where Account_Service__r.Account__c =: loggedInAccountId AND Service_Contact__c =: currentUser AND Active__c = TRUE and Role__c = 'Coordinator' WITH SECURITY_ENFORCED]);    
        Set<Id> serviceListId = new Set<Id>();
        for(integer count = 0; count < coordsRecList.size() ; count++){
            serviceListId.add(coordsRecList[count].Account_Service__r.Service__c);
        }
        List<Service__c> serviceList = new List<Service__c>();
        serviceList = [Select Id, Name, Signature_Required__c from Service__c where Id =: serviceListId WITH SECURITY_ENFORCED];
        for(Service__c loopVar : serviceList){
            listToReturn.add(new ServiceWrapper(loopVar.Id, loopVar.Name, loopVar.Signature_Required__c));
        }
        return listToReturn;
    }

    public class ServiceWrapper{
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public Boolean signReqd {get; set;}

        public ServiceWrapper(String id, String name, Boolean signReqd){
            this.id = id;
            this.name = name;
            this.signReqd = signReqd;
        }
    }

    @AuraEnabled
    public static string createContactCase(string arg1, string arg2, string arg3, string arg4, List<String> arg5, String arg6, String arg7){
        String lastName = arg1.substringBefore('&&&');
        String restOfName = arg1.substringBetween('&&&','&&&');
        String oneNameOnly = arg1.substringAfterLast('&&&');
        String dateOfBirth = arg2.substringBefore('&&&');
        String suffix = arg2.substringBetween('&&&','&&&');
        String email = arg2.substringAfterLast('&&&');
        String phone = arg3.substringBefore('&&&');
        String department = arg3.substringBetween('&&&','&&&');
        String title = arg3.substringAfterLast('&&&');
        String country = arg4;
        Id currentUser = AppForCertHelper.retrieveCurrentContactId();
        List<User> ownerUser = new List<User>([Select Id from User where Profile.Name = 'System Administrator' AND IsActive = TRUE]);
        Id loggedInAccountId = arg6;
        Contact toInsert = new Contact();
        toInsert.LastName = lastName;
        toInsert.FirstName = restOfName;
        if(oneNameOnly == 'false'){
            toInsert.legal_name_consists_of_one_name_only__c = false;
        }else{
            toInsert.legal_name_consists_of_one_name_only__c = true;
        }    
        Date x = Date.valueOf(dateOfBirth);
        toInsert.Birthdate = x;
        if(suffix != 'NO VALUE'){
            toInsert.Generational_Suffix__c = suffix;
        }
        toInsert.Email = email;
        toInsert.Phone = phone;
        toInsert.Department = department;
        toInsert.Title = title;
        if(country != 'NO VALUE'){
            toInsert.MailingCountry = country;
        }
        Id recId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('New_Entity_User').getRecordTypeId();
        toInsert.recordTypeId = recId;
        toInsert.ownerId = ownerUser[0].Id;
        toInsert.AccountId = loggedInAccountId;
        try{
            dupcheck.dc3TriggerProcessGlobal.setTriggerSource('DISABLE');
            if(Schema.sObjectType.Contact.isCreateable()){
                insert toInsert;
            }
        }
        catch(exception e){
            system.debug('results: e' + e.getMessage());
        }
        // Entity User Request Queue
        Group grp = [SELECT Id, Name FROM Group WHERE Type = 'Queue' and Name =: Constants.CASE_QUEUE_ENTITY_USER_REQUESTS WITH SECURITY_ENFORCED];
        Case newCase = new Case();
        newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Entity_User_Request').getRecordTypeId();
        newCase.Internal_Status__c = 'New';
        newCase.ContactId = toInsert.Id;
        newCase.Source__c = 'Coordinator';
        newCase.Request_Type_Value__c = 'Add User';        
        newCase.Approver__c = currentUser;
        newCase.Entity__c = null;
        if(Case.SObjectType.getDescribe().isCreateable()){
            insert newCase;
        }
        List<Case> createdCase = new List<Case>();
        string caseNum='';    
        if(newCase.Id != null){
            createdCase = [Select id,CaseNumber,OwnerId from Case where id =: newCase.Id WITH SECURITY_ENFORCED];
            caseNum = createdCase[0].CaseNumber;
        }
        List<Case2Service__c> listToInsert = new List<Case2Service__c>();
        if(!createdCase.isEmpty()){
            for(integer loopCount = 0; loopCount < arg5.size(); loopCount++){
                Case2Service__c newRec = new Case2Service__c();
                newRec.Case__c = newCase.Id;
                newRec.Service__c = arg5[loopCount];
                listToInsert.add(newRec);
            }
        }
        insertCase2Service(listToInsert);
        if(String.isNotBlank(arg7)){
            List<Asset> createdAsset = new List<Asset>([Select id,IsOrphan__c from Asset where Azure_Storage_URL__c =: arg7  AND Status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED Limit 1]);
            updateCreatedAsset(createdAsset,toInsert,newCase);
        }
        createdCase[0].ownerId = grp.Id;
        createdCase[0].contactId = toInsert.Id;
        createdCase[0].AccountId = loggedInAccountId;
        createdCase[0].Entity__c = loggedInAccountId;
        updateCase(createdCase);
        return 'true';
    }

    public static void insertCase2Service(List<Case2Service__c> listToInsert){
        if(!listToInsert.isEmpty() && Case2Service__c.SObjectType.getDescribe().isCreateable()){
            insert listToInsert;
        }
    }

    public static void updateCreatedAsset(List<Asset> createdAsset,Contact toInsert,Case newCase){
        if(!createdAsset.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            createdAsset[0].IsOrphan__c = false;
            createdAsset[0].Case__c = newCase.Id;
            createdAsset[0].ContactId = toInsert.Id;
            createdAsset[0].AccountId = null;
            update createdAsset;
        }
    }

    public static void updateCase(List<Case> createdCase){
        if(Case.SObjectType.getDescribe().isUpdateable()){
            update createdCase;
        }
    }
    /* Description : To delete the asset unassociated to contact and case with status = In Progress */
    @AuraEnabled
    public static void deleteAssetList(string accountId){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(string.isnotBlank(accountId) && Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT id FROM Asset where AccountId =: accountId AND Type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =:Constants.ASSET_STATUS_INPROGRESS AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND ContactId = null AND Case__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
				a.Case__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }
            update assetsToUpdateList;
        }
    }
    /* Description : To delete the asset unassociated to contact and case with status = In Progress */
    @AuraEnabled
    public static void delAssetOnCancel(string assetUrl){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(string.isnotBlank(assetUrl) && Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT id FROM Asset where Azure_Storage_URL__c =: assetUrl AND Type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =:Constants.ASSET_STATUS_INPROGRESS AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND ContactId = null AND Case__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
				a.Case__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }
            update assetsToUpdateList;
        }
    }
}