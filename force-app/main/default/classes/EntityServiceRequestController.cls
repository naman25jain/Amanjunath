public with sharing class EntityServiceRequestController {

    @AuraEnabled(cacheable = true)
    public static List<Account> findRecords(String searchKey){
        
        List<Account> accountListReturned = new List<Account>();
        if(String.isnotBlank(searchKey)){
            String keyValue = '%' + searchKey + '%';
            List<Account> accountList = new List<Account>([Select Id,RecordType.DeveloperName,Name,IsCustomerPortal From Account Where Name LIKE :keyValue]);
            
            
            for(account acct: accountList){
                if(acct.recordType.DeveloperName==Constants.ACCOUNT_RECORD_TYPE_ENTITY){
                    accountListReturned.add(acct);
                }
            }
        }
        return accountListReturned;
    }

      /**
     * Created by Jofrin
     * Method Name: getEntityMetadataId
     * Purpose : Method to get metadata Id of confirmation message
     * Return Type : String
     */
    @AuraEnabled(Cacheable = true)
    public static String getEntityMetadataId() {
        String returnVal = '';
        List < Confirmation_Message__mdt > confMsgs = new List < Confirmation_Message__mdt > ();
        confMsgs = [SELECT Id FROM Confirmation_Message__mdt where DeveloperName =: Constants.CONFIRMATION_MESSAGE_ENTITY_SERVICE_REQUEST];
        if (!confMsgs.isEmpty()){
            returnVal = confMsgs[0].Id;
        } 

        return returnVal;
    }

     /**
     * Created by Jofrin
     * Method Name: getEntityServices
     * Purpose : Method to get servcies of interest to show in service of interest in entity web form.
     * Return Type : Map<string, string>
     */
    @AuraEnabled(Cacheable = true)
    public static Map<string, string> getEntityServices(string finalSelectedRecordId) {
        
        Map<string, string> entityServices = new  Map<string, string>();
        Account entityAccount = new Account();
        entityAccount = [Select id,Account_Type__c  from Account where Id= :finalSelectedRecordId limit 1];
        List<String>  accountTypeIndi = entityAccount.Account_Type__c.split(',');
        List<String> newString =  new   List<String>();
        
         for(integer i=0;i <accountTypeIndi.size();i++){
            newString.add(accountTypeIndi[i].trim());
         }
         
        List<EntityType2Service__c> entityType2ServiceList = new List<EntityType2Service__c> ([Select id,Service__r.Name,Service__r.Id,Entity_Type__r.Name,Entity_Type__r.Id from EntityType2Service__c where Entity_Type__r.Entity_Type__c in :newString]);
        
        if(!entityType2ServiceList.isEmpty()){
            for(EntityType2Service__c serviceRec: entityType2ServiceList){
                entityServices.put(serviceRec.Service__r.Name,serviceRec.Service__r.Id);
            }
        }

        return entityServices;
    
    }
    /**
     * Created by Ajoydhas
     * Method Name: getCaseManageRequestDetail
     * Purpose : Method to get the record detail of Case
     * Parameter : Case ID
     * Return Type : MAP<String, String>
     */    
    @AuraEnabled(Cacheable = false)
	public static Map<String, String> getCaseManageRequestDetail(String caseId) {
        Map<String, String> valuesToReturn = new Map<String, String> ();
        Case caseRecord = [SELECT Id, ContactId, Entity__r.Name, Entity_Service_Request__c, 
                            Deficiency_Reason_RTF__c,
                            Contact.Name,                            
                            Contact.LastName,
                            Contact.FirstName,
                            Contact.legal_name_consists_of_one_name_only__c,
                            Contact.Generational_Suffix__c,
                            Contact.Email,
                            Contact.Phone,
                            Contact.Department,
                            Contact.Title,
                            Internal_Status__c                         
                            FROM Case WHERE Id =: caseId][0];
        
        List<String> serviceNameList = new List<String>();
        Boolean signatureRequired = false;
        for(Case2Service__c case2serviceObj : [SELECT Id, Case__c, Service__c, Service__r.Name, Service__r.Signature_Required__c
                                                    FROM Case2Service__c 
                                                WHERE Case__c = :caseId]) {
            serviceNameList.add(case2serviceObj.Service__r.Name);
            if(case2serviceObj.Service__r.Signature_Required__c == true){
                signatureRequired = true;
            }
        }

        String serviceNames = String.join(serviceNameList,',');
                            
        valuesToReturn.put('Case__c', caseRecord.Id);
        valuesToReturn.put('ContactId', caseRecord.ContactId);
        valuesToReturn.put('Entity__c', caseRecord.Entity__r.Name);
        valuesToReturn.put('LastName', caseRecord.Contact.LastName);
        valuesToReturn.put('FirstName', caseRecord.Contact.FirstName);
        valuesToReturn.put('legal_name_consists_of_one_name_only__c', String.valueOf(caseRecord.Contact.legal_name_consists_of_one_name_only__c));
        valuesToReturn.put('Generational_Suffix__c', caseRecord.Contact.Generational_Suffix__c);
        valuesToReturn.put('Email', caseRecord.Contact.Email);
        valuesToReturn.put('Phone', caseRecord.Contact.Phone);       
        valuesToReturn.put('Department', caseRecord.Contact.Department);
        valuesToReturn.put('JobTitle', caseRecord.Contact.Title);
        valuesToReturn.put('ServiceName', serviceNames);
        valuesToReturn.put('Signature_Required__c', String.valueOf(signatureRequired));
        valuesToReturn.put('Status', caseRecord.Internal_Status__c);
        valuesToReturn.put('DeficiencyReason', caseRecord.Deficiency_Reason_RTF__c);
		return valuesToReturn;
    }
    /**
	 * Created by Ajoydhas
	 * Method Name: manageServiceRequestsSignature
	 * Purpose : Method to update the Case for Service Requests
	 * Return Type : String containing validation error or blank if no errors are hit
	 */
	@AuraEnabled(Cacheable = false)
	public static Boolean manageServiceRequestsSignature(String fieldvals) {
		Map<String, String> fieldvalmap = new Map<String, String> ();
		String tempKey,
		tempValue;
		JSONParser parsedMap = JSON.createParser(fieldvals);
		while (parsedMap.nextToken() != null) {
			if (parsedMap.getCurrentToken() == JSONToken.FIELD_NAME) {
				tempKey = parsedMap.getText();
				JSONToken tok = parsedMap.nextToken();
				fieldvalmap.put(tempKey, '');
				if (tok != JSONToken.VALUE_NULL) {
					tempValue = parsedMap.getText();
					fieldvalmap.put(tempKey, tempValue);
				}
			}
        }

        String caseStatus = '';
        String caseId = fieldvalmap.get('caseId');
        String signatureUploadStatus = fieldvalmap.get('signatureUploadStatus'); 
        String caseSignStatus = fieldvalmap.get('caseStatus');
        String contentDocId = fieldvalmap.get('contentDocumentId');
        String type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        String contactId = fieldvalmap.get('contactId');
        String approver = AppForCertHelper.retrieveCurrentContactId();

        if(signatureUploadStatus == Constants.STATUS_NO) {
            caseStatus      =   Constants.CASE_STATUS_REJECTED;            
        } else {
            caseStatus      =   caseSignStatus;
            // Create Asset for Signature
            if(contentDocId != '') {
                createAsset(contentDocId, caseId, type, contactId);
            }            
                
        }
        // Entity User Request Queue
        Group grp = [SELECT Id, Name FROM Group WHERE Type = 'Queue'
            and Name =: Constants.CASE_QUEUE_ENTITY_USER_REQUESTS];
        
        Case caseUpdate                 =   new Case();
        caseUpdate.Id                   =   caseId;
        caseUpdate.Internal_Status__c   =   caseStatus;
        caseUpdate.Approver__c          =   approver;
        caseUpdate.OwnerId              =   grp.Id;
        Update caseUpdate;

        if(caseStatus == Constants.CASE_STATUS_REJECTED) {
            sendMailEntityContact(caseId);
        }

		return true;
    }
    /**
	 * Created by Ajoydhas
	 * Method Name: checkSignatureAssetExist
	 * Description : Method to check as Asset exist for Signature Contact
	 * Return Type : Boolean
	 */
	@AuraEnabled(Cacheable = false)
	public static Boolean checkSignatureAssetExist(String contactId) { 
        Boolean signatureAssetFlag = false;
        List <Asset> assetList = new List <Asset> ();
        String typeval = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE;
        assetList = [SELECT ID FROM Asset 
                        WHERE ContactId =: contactId
                            AND type__c =: typeval
                            AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        if (!assetList.isEmpty()) {
            signatureAssetFlag = true;
        }
        return signatureAssetFlag;
    }
    /**
     * @author: Ajoydhas
     * @methodname: sendMailEntityContact
     * @description: Method to send mail when the Case Status is Accepted or Rejected
     * @Parameters: caseList
     * @return type: no
     */
    public static void sendMailEntityContact(String caseId) {
        Case caseRecord = [SELECT Id, ContactId, ECFMG_Portal_Case_Url__c, Internal_Status__c                       
                            FROM Case WHERE Id =: caseId][0];
        Id currentContactId = caseRecord.ContactId;
        Contact contactEmail = [Select Id, Email, Name from Contact where Id =: currentContactId];
        if(contactEmail.email != null) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(caseRecord.ContactId);
            EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
            List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
            message.setOrgWideEmailAddressId(addr[0].Id);   
            message.setTemplateID(emailTemplate.Id);

            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', caseRecord.Internal_Status__c);
            htmlBody = htmlBody.replace('{!Case.Contact}', contactEmail.Name);
            htmlBody = htmlBody.replace('[Link]', '<a href="' + caseRecord.ECFMG_Portal_Case_Url__c + '">Case Status</a>');
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');

            message.setHtmlBody(htmlBody);
            message.toAddresses = new String[] {
                contactEmail.email
            };

            try {
                Messaging.SingleEmailMessage[] messages = new List <Messaging.SingleEmailMessage> {message};
                Messaging.sendEmail(messages);
            }
            catch(exception e) {
                system.debug('results:' + e.getMessage());
            }
        }
    }
    /**
     * @author: Ajoydhas
     * @methodname: createAsset
     * @description: Method to create Asset for signature upload. US 4968, 5861
     * @Parameters: caseList
     * @return type: no
     */
    @AuraEnabled(cacheable = false)
    public static String createAsset(String contentDocId, String caseId, String type, String contactId) {
        // the resubmission should create a new asset, preserving the prior incomplete asset & affirmations
        updateStatusSignedSignatureFormAsset(contactId);

        ID assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();

        Asset a = new Asset(
            Name = type, 
            type__c = type, 
            Status = Constants.ASSET_STATUS_IN_PROGRESS, 
            ContactId = contactId,
            Case__c = caseId, 
            RecordTypeId = assetRecordTypeId);        
        insert a;

        if (a != null) {
            List <ContentDocumentLink> cdlList = new List <ContentDocumentLink> ();
            ContentDocumentLink cdlAsset = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = a.Id, ShareType = 'I', Visibility = 'AllUsers');
            cdlList.add(cdlAsset);
            insert cdlList;
        }
        String returnDet = getDocumentbyId(contentDocId);
        returnDet = returnDet + ':`:' + a.id;
        return returnDet;

    }
    /**
     * Created by Ajoydhas
     * Method Name: getDocumentbyId
     * Purpose : Method used in create Asset method to return content document's file namd and type
     * Return Type : String
     */
    @AuraEnabled(cacheable = false)
    public static String getDocumentbyId(String contentDocId) {
        String returnValue = '';
        List < ContentDocument > cdList = new List < ContentDocument > ();

        if (contentDocId != null) {
            cdList = [Select Id, Title, FileType from ContentDocument where Id =: contentDocId];
            if (!cdList.isEmpty()) {
                String fileURL = Constants.ENTITY_COMMUNITY_URL + Constants.FILE_DOWNLOAD_URL + cdList[0].Id;
                returnValue = cdList[0].Title + ':`:' + cdList[0].FileType + ':`:' + fileURL;
            }
        }

        return returnValue;
    }
    /**
     * Created by Ajoydhas
     * Method Name: getDocumentByAssetType
     * Purpose : Method to get Document by Asset Type
     * Return Type : String
     */
    @AuraEnabled(cacheable = false)
    public static String getDocumentByAssetType(String contactId, String assetStatus) {
        String returnValue  = '';
        List < Asset > assetList = new List < Asset > ();
        String type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        assetList = [SELECT Id 
                        FROM Asset 
                    WHERE ContactId =: contactId 
                        AND type__c =: type
                        AND status =: assetStatus];
                        
        List < ContentDocumentLink > cdlList = new List < ContentDocumentLink > ();
        List < ContentDocument > cdList = new List < ContentDocument > ();
        if (!assetList.isEmpty()) {
            cdlList = [Select Id, ContentDocumentId from ContentDocumentLink
                Where LinkedEntityId =: assetList[0].Id
            ];
            if (!cdlList.isEmpty()) {
                cdList = [Select Id from ContentDocument where Id =: cdlList[0].ContentDocumentId];

                if (!cdList.isEmpty()) {
                    returnValue = getDocumentbyId(cdList[0].Id);
                }
            }            
        }
        
        return returnValue;
    }
    /**
     * Created by Ajoydhas
     * Method Name: deleteAssetAndRelatedDocument
     * Purpose : Method to delete Asset and related content document
     * Return Type : no return type
     */
    @AuraEnabled(cacheable = false)
    public static Boolean deleteSignatureContentDocument(String contentDocumentId) {
        List < ContentDocument > cdList = new List < ContentDocument > ();
        cdList = [Select Id from ContentDocument where Id =: contentDocumentId];

        if (!cdList.isEmpty()) {
            delete cdList;
        }

        return true;
    }
    /**
     * Created by Ajoydhas
     * Method Name: updateStatusSignedSignatureFormAsset
     * Purpose : Method to update the existing Asset Status as Incomplete
     * Return Type : no return type
     */
    @AuraEnabled(cacheable = false)
    public static Boolean updateStatusSignedSignatureFormAsset(String contactId) {
        List < Asset > assetList = new List < Asset > ();
        String type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        for(Asset assetRecord : [SELECT Id, Status
                        FROM Asset 
                    WHERE ContactId =: contactId
                        AND type__c =: type
                        AND Status =: Constants.ASSET_STATUS_IN_PROGRESS]) {
            Asset assetObj = assetRecord;
            assetObj.Status = Constants.ASSET_STATUS_INCOMPLETE;
            assetList.add(assetObj);
        }   
        if(!assetList.isEmpty()) {
            try {
                update assetList;
            }            
            catch(exception e){
                system.debug('results: e' + e.getMessage());
            }           
        }        

        return true;
    }

     /**
     * Created by Jofrin
     * Method Name: insertContactandCaseEntityRqeuest
     * Purpose : Method to get servcies of interest to show in service of interest in entity web form.
     * Return Type : string
     */
    @AuraEnabled
    public static string insertContactandCaseEntityRqeuest(string jsonString) {

        string newCase = EntityServiceRequestSharingDisabled.insertContactandCaseEntityRqeuestWithoutShar(jsonString);
        return newCase;
    }
    /**
     * Created by Nayana
     * Method Name: getAvailableServicesForEntity
     * Purpose : Method to retrieve the list of services available to the entity
     * Return Type : List
     */
    @AuraEnabled(cacheable = false)
    public static List< EntityServiceRequestControllerHelper.ServiceAccessWrapper > getAvailableServicesForEntity(String currentEntityId) {
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();       
        
        Set<Id> atsIdSet = new Set<Id>();
        Set<Id> atsServiceSet =  new Set<Id>();
        Set<Id> ctasServiceSet = new Set<Id>();
        Set<Id> caseServiceSet = new Set<Id>();
        Map<Id, EntityType2Service__c> serviceMap = new Map<Id, EntityType2Service__c>();

        List< EntityServiceRequestControllerHelper.ServiceAccessWrapper > returnValue = new List< EntityServiceRequestControllerHelper.ServiceAccessWrapper >();

  
        List<Account> accountList = new List<Account>();
        accountList =  [SELECT ID, Account_Type__c, ECFMG_Acceptable__c
                        FROM Account
                        WHERE Id =: currentEntityId];

        List<String> tempEntityTypeList = new List<String>();
        List<String> entityTypeList = new List<String>();

        if(!accountList.isEmpty()) {
            if(accountList[0].Account_Type__c.contains(',')) {
                tempEntityTypeList = accountList[0].Account_Type__c.split(',');
                for(String tmpEntityType : tempEntityTypeList) {
                    tmpEntityType = tmpEntityType.trim();
                    entityTypeList.add(tmpEntityType);
                }
            }  

            for(EntityType2Service__c ets : [SELECT Id, Service__c, Service__r.Name, Service__r.Id
                                            FROM EntityType2Service__c
                                            WHERE Entity_Type__r.Entity_Type__c IN : entityTypeList]) {
                serviceMap.put(ets.Service__r.Id, ets);

            }
    
            for(Account2Service__c ats : [SELECT Id, Service__c, Service__r.Id 
                                         FROM Account2Service__c 
                                         WHERE Account__c =: accountList[0].Id AND Active__c = true]) {
                atsServiceSet.add(ats.Service__r.Id );
                atsIdSet.add(ats.Id);
            }

    
            for(Contact2AcctService__c ctas : [SELECT Id, Account_Service__c, Account_Service__r.Service__c
                                              FROM Contact2AcctService__c 
                                              WHERE Service_Contact__c =: currentContactId AND Active__c = true
                                              AND Account_Service__c IN :atsIdSet ]) {
                ctasServiceSet.add(ctas.Account_Service__r.Service__c);
            }
            ID eurCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId(); 
            for(Case2Service__c eurCase : [SELECT Id, Case__c,  Service__c
                               FROM Case2Service__c
                               WHERE Case__r.RecordTypeId =: eurCaseRecordTypeId AND Case__r.Request_Type_Value__c =: Constants.CASE_REQUEST_TYPE_ADD_SERVICE
                               AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_REJECTED AND Case__r.ContactId =: currentContactId]) {
                caseServiceSet.add(eurCase.Service__c);
            }
            returnValue = getServiceAccessValues(serviceMap, atsServiceSet, ctasServiceSet, caseServiceSet, accountList[0].ECFMG_Acceptable__c);
        }
        
        return returnValue;
    }
    /**
     * Created by Nayana
     * Method Name: getServiceAccessValues
     * Purpose : Method to build the list of ServiceAccessWrapper
     * Return Type : List of ServiceAccessWrapper
     */
    public static List< EntityServiceRequestControllerHelper.ServiceAccessWrapper > getServiceAccessValues(Map<Id, EntityType2Service__c> serviceMap, Set<Id> atsServiceSet, Set<Id> ctasServiceSet, Set<Id> caseServiceSet, Boolean ecfmgAccepted) {
        List< EntityServiceRequestControllerHelper.ServiceAccessWrapper > returnValue = new List< EntityServiceRequestControllerHelper.ServiceAccessWrapper >();
        Map<String, Boolean> enrolledServiceMap = checkEnrolledServices(serviceMap, atsServiceSet);
        for(Id servId : serviceMap.keySet()) {
            String tempisEnrolled = 'No';
            String temphasAccess = 'No';
            Boolean hideRequestAccess = false;
            Boolean disableRequestAccess = false;

            if(atsServiceSet.contains(servId)) {
                tempisEnrolled = 'Yes';
            }
            
            if(ctasServiceSet.contains(servId)) {
                temphasAccess = 'Yes';
                hideRequestAccess = true;
            }
            else if(caseServiceSet.contains(servId)){
                disableRequestAccess = true;
            }
            
            if(serviceMap.get(servId).Service__r.Name == Constants.SERVICE_NAME_PERFORMANCE_DATA && tempisEnrolled =='No' && (!enrolledServiceMap.get(Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION) || !enrolledServiceMap.get(Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION) || ecfmgAccepted == false)){
                disableRequestAccess = true;
            }

            EntityServiceRequestControllerHelper.ServiceAccessWrapper servAccessObj = new EntityServiceRequestControllerHelper.ServiceAccessWrapper (serviceMap.get(servId).Service__r.Name, tempisEnrolled, temphasAccess, hideRequestAccess, disableRequestAccess);
            returnValue.add(servAccessObj);
        }  
        return returnValue;      
    }
    /**
     * Created by Nayana
     * Method Name: createEntityUserRequest
     * Purpose : Method to create Entity User Request Case
     * Return Type : void
     */
    @AuraEnabled(cacheable = false)
    public static Boolean createEntityUserRequest(String selServiceName, String currentEntityId) {
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        List < Service__c > servList = new List < Service__c > ();
        List< Contact > contactList =  new List< Contact >();
        List< Account2Service__c > atsList = new List< Account2Service__c >();
        
        servList = [Select Id from Service__c where Name =: selServiceName];

        if(!servList.isEmpty()) {
            ID eurCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId(); 
            
            Case eurCase = new Case();
            eurCase.RecordTypeId = eurCaseRecordTypeId;
            eurCase.Share_Information_with_Coordinator__c = 'Yes';
            eurCase.ContactId = currentContactId;
            eurCase.Request_Type_Value__c = Constants.CASE_REQUEST_TYPE_ADD_SERVICE;
            eurCase.Role__c = Constants.CASE_ROLE_USER;
            eurCase.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
            eurCase.Entity__c = currentEntityId;

            contactList = [SELECT ID, AccountId
                          FROM Contact
                          WHERE ID =: currentContactId];     

            atsList = [SELECT Id FROM Account2Service__c
                       WHERE Account__c =: contactList[0].AccountId 
                       AND Service__c =: servList[0].Id AND Active__c = true];
            if(!atsList.isEmpty()) {
                eurCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL;
            }
            else {
                eurCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
            }

            Group eurQueue = [SELECT Id, Group.DeveloperName FROM Group WHERE Type = 'Queue'
			          AND Name =: Constants.CASE_QUEUE_ENTITY_USER_REQUESTS LIMIT 1];
            eurCase.OwnerId = eurQueue.Id;

            insert eurCase;
            if(eurCase.Id != null){
                Case2Service__c newCreated2Service = new Case2Service__c();
                newCreated2Service.Case__c = eurCase.Id;
                newCreated2Service.Service__c = servList[0].Id;
                try{
                    insert newCreated2Service;
                }
                catch(exception e){
                    system.debug('error e Message:'+ e.getMessage());
                }
            }
        }

        return true;
    }

     /**
     * Created by Jofrin
     * Method Name: getListOfContactsInEntity
     * Purpose : Method to get servcies of interest to show in service of interest in entity web form.
     * Return Type : Map<Id,string>
     */
    @AuraEnabled(cacheable=true)
    public static Map<Id,string> getListOfContactsInEntity(String currentEntityId) {

        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id entityContactRTid = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();

        List<Contact> contactListFromEntity = new List<Contact>();
        contactListFromEntity =  [Select id,Name,Account.name,Account.Id from Contact where Account.Id = :currentEntityId and RecordTypeId = :entityContactRTid];

        List<CONTACT2ACCTSERVICE__c> listOfContacts = new List<CONTACT2ACCTSERVICE__c>();
        listOfContacts = [Select Id,Service_Contact__r.Id,Service_Contact__r.Name from CONTACT2ACCTSERVICE__c where Account_Service__r.Account__r.Id = :currentEntityId and Service_Contact__r.RecordTypeId = :entityContactRTid and Service_Contact__c != NULL];
       
        Map<Id,string> contactsList = new Map<Id,string>();
        if(!listOfContacts.isEmpty()){
            for(CONTACT2ACCTSERVICE__c tempContact:listOfContacts){
                contactsList.put(tempContact.Service_Contact__r.Id, tempContact.Service_Contact__r.Name);
            }
        }
        if(!contactListFromEntity.isEmpty()){
            for(Contact tempCont:contactListFromEntity){
                if(!contactsList.containsKey(tempCont.Id)){
                    contactsList.put(tempCont.Id, tempCont.Name);
                }
                
            }
        }
        if(contactsList.containsKey(contactId)){
            contactsList.remove(contactId);
        }
        
        return contactsList;
    }

     /**
     * Created by Jofrin
     * Method Name: getContactDetail
     * Purpose : Method to get contact details to request for more service.
     * Return Type : WrapperClass
     */
    @AuraEnabled(cacheable=true)
    public static EntityServiceRequestControllerHelper.ContactDetailsRecordWrapper getContactDetail(string contactId) {

        Contact contactDetails = new Contact();
        contactDetails = [Select id,LastName,FirstName,legal_name_consists_of_one_name_only__c,Generational_Suffix__c,Email,Department,Title,Phone from contact where id = :contactId];
        EntityServiceRequestControllerHelper.ContactDetailsRecordWrapper cdrWrapper;
        if(string.isnotBlank(contactDetails.LastName)){
            cdrWrapper = new EntityServiceRequestControllerHelper.ContactDetailsRecordWrapper(contactDetails.LastName,contactDetails.Generational_Suffix__c,contactDetails.Email,contactDetails.Phone,contactDetails.Department,contactDetails.Title,contactDetails.FirstName,contactDetails.legal_name_consists_of_one_name_only__c);
        }
        
        return cdrWrapper;
    }

         /**
     * Created by Jofrin
     * Method Name: getServicesAndRole
     * Purpose : Method to get contact details to request for more service.
     * Return Type : WrapperClass
     */
    @AuraEnabled(cacheable=true)
    public static  List<EntityServiceRequestControllerHelper.ServicesRoleWrapper> getServicesAndRole(string contactId, String currentEntityId) {

        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        
        List<CONTACT2ACCTSERVICE__c> listOfContacts2AcctServiceCord = new List<CONTACT2ACCTSERVICE__c>();
        listOfContacts2AcctServiceCord = [Select id,Account_Service__r.Service_Name__c,Account_Service__r.Service__r.Signature_Required__c,Account_Service__r.Service__r.Name,Service_Contact__r.Id,Role__c from CONTACT2ACCTSERVICE__c where (Service_Contact__r.Id = :currentContactId and Account_Service__r.Account__r.Id = :currentEntityId and Role__c = 'Coordinator' and Active__c = true)];

        List<CONTACT2ACCTSERVICE__c> listOfC2AcctServiceSelectdUser = new List<CONTACT2ACCTSERVICE__c>();
        listOfC2AcctServiceSelectdUser = [Select id,Account_Service__r.Service_Name__c,Account_Service__r.Service__r.Signature_Required__c,Account_Service__r.Service__r.Name,Service_Contact__r.Id from CONTACT2ACCTSERVICE__c where (Service_Contact__r.Id =: contactId and Account_Service__r.Account__r.Id =: currentEntityId and Active__c = true)]; 

        Boolean removedVal = false;
        Integer cont2AccService = listOfContacts2AcctServiceCord.size();
        for(integer i=0;i < cont2AccService;i++){
            if(removedVal){
                i = i-1;
                cont2AccService = cont2AccService +1;
                removedVal = false;
            }
 
            for(CONTACT2ACCTSERVICE__c serviceSelectdUser: listOfC2AcctServiceSelectdUser){
                if(!listOfContacts2AcctServiceCord.isEmpty() && i< listOfContacts2AcctServiceCord.size() && listOfContacts2AcctServiceCord[i].Account_Service__r.Service_Name__c == serviceSelectdUser.Account_Service__r.Service_Name__c){
                    listOfContacts2AcctServiceCord.remove(i);
                    removedVal = true;                      
                    break; 
                }
            }
        }
        List<EntityServiceRequestControllerHelper.ServicesRoleWrapper> wrap = new List<EntityServiceRequestControllerHelper.ServicesRoleWrapper>();
        EntityServiceRequestControllerHelper.ServicesRoleWrapper wrapSingle;
        if(!listOfContacts2AcctServiceCord.isEmpty()){
            for(CONTACT2ACCTSERVICE__c availedService: listOfContacts2AcctServiceCord){
               
                string serviceName = availedService.Account_Service__r.Service__r.Name;
                string serviceId = availedService.Account_Service__r.Service__r.Id;
                Boolean signatureRequired = availedService.Account_Service__r.Service__r.Signature_Required__c;
                wrapSingle = new EntityServiceRequestControllerHelper.ServicesRoleWrapper(serviceName,signatureRequired,serviceId);
                wrap.add(wrapSingle);
            }
        }
        return wrap;
    }
    /**
     * Created by Jofrin
     * Method Name: checkAssetSignatureInContact
     * Purpose : Method to check whether the signed signature form already present in the contact's asset.
     * Return Type : string
     */
    @AuraEnabled(cacheable=false)
    public static string checkAssetSignatureInContact(String contactId) {

        ID assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();

        List<Asset> existingAsset = new List<Asset>([Select id,ContactId,Name,type__c,RecordTypeId from Asset where (type__c =:Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE and RecordTypeId =:assetRecordTypeId and ContactId=:contactId  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION )]);
        if(!existingAsset.isEmpty()){
            return 'True';
        }
        else {
            return 'False';
        }
    }    
    // Method to create case and case2Services to add service for user
    @AuraEnabled
    public static string createCaseandCase2Services(List<String> servicesSelected, string contactId, string caseStatus, string assetUrl, String currentEntityId){    
        Id currentUser = AppForCertHelper.retrieveCurrentContactId();
        Group grp = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' AND Group.name =: Constants.CASE_QUEUE_ENTITY_USER_REQUESTS WITH SECURITY_ENFORCED];
        if(Case.SObjectType.getDescribe().isCreateable()){
            Case newCase = new Case();
            newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            newCase.ContactId = contactId;
            newCase.Source__c = Constants.CASE_SOURCE_COORDINATOR;
            newCase.Request_Type_Value__c = Constants.CASE_REQUEST_TYPE_ADD_SERVICE;
            newCase.Approver__c = currentUser;
            newCase.Internal_Status__c = caseStatus;
            newCase.Entity__c = currentEntityId;
            insert newCase;        
            List<Case2Service__c> listCase2ServiceInsert = new List<Case2Service__c>();
            for(integer i = 0; i<servicesSelected.size(); i++){
                Case2Service__c newRec = new Case2Service__c();
                newRec.Case__c = newCase.Id;
                newRec.Service__c = servicesSelected[i];
                listCase2ServiceInsert.add(newRec);
            }
            try{
                if(Case2Service__c.SObjectType.getDescribe().isCreateable()){
                    insert listCase2ServiceInsert;
                }
                //To update Contacts's asset isOrphan as False upon submit form.
                String newCaseId = newCase.Id;
                updatedCaseAsset(assetUrl, newCaseId);           
                if(Case.SObjectType.getDescribe().isUpdateable()){
                    newCase.ownerId = grp.Id;
                    newCase.AccountId = currentEntityId;
                    update newCase;
                }
            }catch(exception e){
                saveLogMessage(e.getMessage());
            }
        }
        return 'success';
    }
    @AuraEnabled
    public static void updatedCaseAsset(String assetUrl, String newCaseId){
        if(assetUrl != null || assetUrl != ''){
            List<Asset> createdAsset = new List<Asset>([SELECT id, IsOrphan__c FROM Asset WHERE Azure_Storage_URL__c =: assetUrl AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION LIMIT 1]);
            if(!createdAsset.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
                createdAsset[0].IsOrphan__c = false;
                createdAsset[0].Case__c = newCaseId;
                update createdAsset;
            }
        }
    }
    //Method to delete orphaned assets for the uploaded signature in contact.
    @AuraEnabled(cacheable=false)
    public static void deleteOrpahnedAssetInContact(String contactId) {
        ID assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        List<Asset> existingAssettoDelete = new List<Asset>([Select id,ContactId,Name,type__c,RecordTypeId from Asset where (Name =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM and type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM and RecordTypeId =:assetRecordTypeId and ContactId=:contactId)]);
        if(!existingAssettoDelete.isEmpty() && Asset.SObjectType.getDescribe().isDeletable()){
                delete existingAssettoDelete;
        }
    }
     /**
     * Created by Femi
     * Method Name: checkEnrolledServices
     * Purpose : Method to check whether Credential Review and Enrollment Verification are enrolled.
     * Return Type : Boolean
     */
    public static Map<String, Boolean> checkEnrolledServices(Map<Id, EntityType2Service__c> serviceMap,Set<Id> atsServiceSet) {
        Map<String, Boolean> enrolledServiceMap = new Map<String, Boolean>();
        enrolledServiceMap.put(Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION, false);
        enrolledServiceMap.put(Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION, false);
        for(Id servId : serviceMap.keySet()) {
            if(atsServiceSet.contains(servId)) {
                enrolledServiceMap.put(serviceMap.get(servId).Service__r.Name, true);     
            }else{
                enrolledServiceMap.put(serviceMap.get(servId).Service__r.Name, false);
            }
        }
        return enrolledServiceMap;
    }

    /**
     * Created by Femi
     * Method Name: update ecfmg acceptable field
     * Purpose : Method to check and update ecfmg acceptable field.
     * Return Type : 
     */
    @InvocableMethod
    public static void updateEcfmgAcceptableFlag(List<Account> actList) {
        Map<String,String> accntToObjectMap = new Map<String,String>();
        List<Account> listToUpdate = new List<Account>();
        List<String> acctId = new List<String>();
        for(Account act:actList){
            acctId.add(act.Id);
        }
        List<Object2Degree__c> objList = [SELECT Id,Account__c FROM Object2Degree__c where Account__c IN:acctId AND Degree__c != null AND Graduation_Year__c!=null AND RecordType.DeveloperName =:Constants.OBJECT2DEGREE_RECORD_TYPE_SCHOOL];
        for(Object2Degree__c obj:objList){
            accntToObjectMap.put(obj.Account__c,obj.Id);
        }
        for(Account act:actList){
            Account newAcnt = new Account();
            newAcnt.Id = act.Id;
            if(accntToObjectMap.get(act.Id) != null){
                newAcnt.ECFMG_Acceptable__c = true;
            }else{
                newAcnt.ECFMG_Acceptable__c = false;
            }
            listToUpdate.add(newAcnt);
        }
        try {
            Update listToUpdate;
        }
        catch(exception e) {
            saveLogMessage(e.getMessage());
        }
    }
    //To mark the signed signa form asset for deletion
    @AuraEnabled(cacheable=false)
    public static void deleteSignedSignForm(String caseId,String status) {
        List<Asset> assetList = new List<Asset>();
        if((status == Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL || status == Constants.CASE_STATUS_INCOMPLETE) && Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT Id 
                        FROM Asset 
                    WHERE case__c =: caseId 
                        AND type__c =: Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM
                        AND status =: Constants.ASSET_STATUS_IN_PROGRESS];
            String assetIds = '';
            for(Asset asst: assetList){
                assetIds = assetIds+asst.Id;
            }
            if(String.isNotBlank(assetIds)){
                AppForCertController.markAssetsForDeletion(assetIds);
            }
        }
    }
    //To mark the signed signa form asset for deletion
    @AuraEnabled(cacheable=false)
    public static String getSignedSignFormId(String caseId){
        String assetUrl;
        List<Asset> assetList = new List<Asset>();
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT Id, Azure_Storage_URL__c 
                        FROM Asset 
                    WHERE case__c =: caseId 
                        AND type__c =: Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM
                        AND status =: Constants.ASSET_STATUS_IN_PROGRESS];
            if(!assetList.isEmpty()){
                assetUrl = assetList[0].Azure_Storage_URL__c;
            }
        }
        return assetUrl;
    }
    //To mark the signed signa form asset for deletion
    @AuraEnabled(cacheable=false)
    public static String getIncompleteSignFormId(String caseId){
        String assetUrl;
        List<Asset> assetList = new List<Asset>();
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT Id, Azure_Storage_URL__c 
                        FROM Asset 
                    WHERE case__c =: caseId 
                        AND type__c =: Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM
                        AND status =: Constants.ASSET_STATUS_INCOMPLETE ORDER BY CreatedDate DESC];
            if(!assetList.isEmpty()){
                assetUrl = assetList[0].Azure_Storage_URL__c;
            }
        }
        return assetUrl;
    }
    // To avoiding cognitive complexity issues  - calling as seperate method
    public static void saveLogMessage(String getMessage){
		if(Schema.sObjectType.Log_Message__c.isCreateable()){
			Log_Message__c logMsg = new Log_Message__c();
			logMsg.Source__c = 'EntityServiceRequestController';
			logMsg.Exception__c	= 'Unhandled Exception : '+getMessage;
			logMsg.Date_Time_Logged__c = DateTime.now();
			INSERT logMsg;
		}
	}
    /* Description : To delete the asset unassociated to contact and case with status = In Progress */
    @AuraEnabled
    public static void delAssetOnCancel(string assetUrl){
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
        if(string.isnotBlank(assetUrl) && Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a : [SELECT id FROM Asset WHERE Azure_Storage_URL__c =: assetUrl AND Type__c =: Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =: Constants.ASSET_STATUS_INPROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
            }
            try{
                update assetsToUpdateList;
            }            
            catch(exception e){
                saveLogMessage(e.getMessage());
            }            
        }
    }
    public static void updateCreatedAsset(List<Asset> createdAsset,String contactId,Case newCase){
        if(!createdAsset.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            createdAsset[0].IsOrphan__c = false;
            createdAsset[0].Case__c = newCase.Id;
            createdAsset[0].ContactId = contactId;
            createdAsset[0].AccountId = null;
            update createdAsset;
        }
    }

    public static void updateCase(Case createdCase){
        if(Case.SObjectType.getDescribe().isUpdateable()){
            update createdCase;
        }
    }
}