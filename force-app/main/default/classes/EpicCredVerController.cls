public with sharing class EpicCredVerController{
    // Method to check account establishment status
    @AuraEnabled(Cacheable = true)
    public static Boolean checkAccountEstablishment(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        List<Case> identityVerCase = [Select Id,External_Status__c from Case where ContactId =:contactId AND RecordTypeId =:recTypeId AND External_Status__c =:Constants.CASE_STATUS_ACCOUNT_ESTABLISHED WITH SECURITY_ENFORCED];
        if(!identityVerCase.isEmpty()){
            Return true;
        }else{
            Return false;
        }
    }
    //Method to fetch the summary for the EPIC Verification Report cases. 
    //Added as part of US 17396
    // Created by Bismitha
    @AuraEnabled(Cacheable = true)
    public static Case getEpicSummaryDetails(Id caseId){
        Id epicCaseId = caseId;
        Case caseDetail1;
        if(Case.SObjectType.getDescribe().isAccessible()){
            caseDetail1 =[SELECT Id, Report_Type__c, Entity__c, Entity__r.Name, Entity__r.BillingAddress, Entity__r.BillingCountry, Entity__r.BillingState, ContactId, Contact.Name,
                            Contact.MailingCountry, Contact.MailingState, Contact.MailingAddress, EPIC_Report_Entity__c, EPIC_Report_Entity_Address__c, Case_Status__c,
                            EPIC_Report_Entity_Country__c, Reference_Number__c, Rejection_Reason__c, Secondary_Parent_Case__c FROM Case WHERE Id =: epicCaseId];
        }
        return caseDetail1;
    }

    // US 17396 - Method to return the files/Documents uploaded by applicant for the Epic Verification Report Request
	@AuraEnabled(Cacheable = false)
	public static String getEpicAssetsAndDocuments(String recId){
        List<Asset> assetList;
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT Id, Name, RecordType.DeveloperName, Case__c, Status, Azure_Storage_URL__c FROM Asset WHERE 
								(Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST OR Name like '%Verified%') AND RecordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL 
                                AND Status !=: Constants.ASSET_STATUS_OUTDATED AND Case__c =: recId];
        }
		if(assetList[0].Azure_Storage_URL__c != null){
			return assetList[0].Azure_Storage_URL__c;
        }else{
			return null;
		}
	}

    //Method to get status of Epic Extraction case
    @AuraEnabled
    public static String getEpicExtrCaseStatus(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        List<Case> epicExtrCase = [Select Id,Internal_Status__c from Case where contactId =: contactId AND RecordTypeId =: recTypeId AND Internal_Status__c =: Constants.CASE_STATUS_NEW WITH SECURITY_ENFORCED];
        List<Case> epicExtrCaseComplete = [Select Id,Internal_Status__c from Case where contactId =:contactId AND RecordTypeId =:recTypeId AND Internal_Status__c =:Constants.CASE_STATUS_VERIFICATION_EXTRACTION_COMPLETE WITH SECURITY_ENFORCED];
        if(!epicExtrCaseComplete.isEmpty()){
            Return Constants.CASE_STATUS_VERIFICATION_EXTRACTION_COMPLETE;
        }else if(!epicExtrCase.isEmpty()){
            Return 'Not Complete';
        }else{
            Return 'Case not created';
        }
    }
    @AuraEnabled(Cacheable = false)
    public static List<Account> searchRegOrg(String searchKey){
        List<Id> accountIdList = new List<Id>();
        List<Account> accountListReturned = new List<Account>();
        if(String.isnotBlank(searchKey)){
            String keyValue = '%' + searchKey + '%';
            List<Account> accountList = new List<Account>([Select Id From Account Where Name LIKE :keyValue AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY WITH SECURITY_ENFORCED]);
            List<Account2Service__c> acc2SerList =  new List<Account2Service__c>([Select id, Account__c from Account2Service__c where Active__c = True AND Service__r.Name = :Constants.EPIC_SERVICENAME AND Account__c in :accountList WITH SECURITY_ENFORCED]);
            for(Account2Service__c acct: acc2SerList){
                accountIdList.add(acct.Account__c);
            }
            if(!accountIdList.isEmpty()){
                accountListReturned = [Select Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                BillingCountry, Parent_Authority__c, EPIC_Client_Special_Instructions_Languag__c, Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c,Parent_Authority__r.Use_same_instruction_for_child_entities__c From Account Where Id in :accountIdList WITH SECURITY_ENFORCED];
            }
        }
        return accountListReturned;
    }
    @AuraEnabled(Cacheable = false)
    public static Boolean insertNewCatsRecord(String selectedRecId){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id recTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
        Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c();
        newCats.RecordTypeId = recTypeId;
        newCats.Account__c = selectedRecId;
        newCats.Contact__c = contactId;
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isCreateable()){
            Insert newCats;
        }
        return true;
    }    
    @AuraEnabled
    public static List<ContactAssociationTypeViewModel> getRegOrgCatsRecord(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        List<Contact_Association_Type_Staging__c> schools = [SELECT Id,Account__r.Name,Account__r.Alternative_Name__c,Account__r.BillingStreet,Account__r.BillingCity,
                Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry FROM
                Contact_Association_Type_Staging__c WHERE
                RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG AND Contact__c = :contactId WITH SECURITY_ENFORCED];
        List<ContactAssociationTypeViewModel> viewModel = new List<ContactAssociationTypeViewModel>();
        for(Contact_Association_Type_Staging__c school : schools){
            ContactAssociationTypeViewModel model = new ContactAssociationTypeViewModel();
            model.Id = school.Id;
            model.Name = school.Account__r.Name;
            model.AlternativeName = school.Account__r.Alternative_Name__c;
            model.Address1 = school.Account__r.BillingStreet;
            model.Address2 = school.Account__r.BillingCity;
            model.Address3 = school.Account__r.BillingState;
            model.Address4 = school.Account__r.BillingPostalCode;
            model.Country = school.Account__r.BillingCountry;
            model.AccountId = school.Account__r.Id;
            viewModel.add(model);
        }
        return viewModel;
    }
    @AuraEnabled(Cacheable = false)
    public static Boolean insertAlreadyEstOrgInCat(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id recTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
        List<Contact_Association_Type_Staging__c> newCatsList = new List<Contact_Association_Type_Staging__c>();
        List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
        catList = [SELECT Id,Account__c FROM Contact_Association_Type__c WHERE Deleted_On_Resubmission__c = false AND Contact__c=:contactId AND RecordType.DeveloperName = :Constants.CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION WITH SECURITY_ENFORCED];
        List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>();
        catsList = [SELECT Id,Account__c FROM Contact_Association_Type_Staging__c WHERE Contact__c=:contactId AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG WITH SECURITY_ENFORCED];
        if(catsList.isEmpty()){
            MAP<String, String> catAccountMap = new MAP<String, String>();
            for(Contact_Association_Type__c eachCat : catList){
                Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c();
                newCats.RecordTypeId = recTypeId;
                newCats.Account__c = eachCat.Account__c;
                newCats.Contact__c = contactId;
                newCatsList.add(newCats);
                catAccountMap.put(eachCat.Account__c, eachCat.Id);
            }
            if(Schema.sObjectType.Contact_Association_Type_Staging__c.isCreateable() && !newCatsList.isEmpty()){
                Insert newCatsList;
                List<Contact_Association_Type__c> updateCatRecordList = new List<Contact_Association_Type__c>();
                for(Contact_Association_Type_Staging__c catsRec : newCatsList){
                    Contact_Association_Type__c updateCatObj = new Contact_Association_Type__c();
                    updateCatObj.Id = catAccountMap.get(catsRec.Account__c);
                    updateCatObj.CatIdentifier__c = catsRec.Id;
                    updateCatRecordList.add(updateCatObj);
                }
                if(!updateCatRecordList.isEmpty() && Schema.sObjectType.Contact_Association_Type__c.isUpdateable()){
                    update updateCatRecordList;
                }
            }
        }else{
            List<Contact_Association_Type__c> updateCatList = new List<Contact_Association_Type__c>();
            for(Contact_Association_Type__c catRec : catList){
                Contact_Association_Type__c catObj = new Contact_Association_Type__c();
                catObj.Id = catRec.Id;
                catObj.Deleted_On_Resubmission__c = true;
                updateCatList.add(catObj);
            }
            if(!updateCatList.isEmpty() && Schema.sObjectType.Contact_Association_Type__c.isUpdateable()){
                update updateCatList;
            }
        }
        return true;
    }
    @AuraEnabled(Cacheable = false)
    public static Boolean deleteSelectedOrg(String catsRecordId){
        Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c(Id = catsRecordId);
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isDeletable() && newCats.Id != null){
            Delete newCats;
            Id contactId = AppforCertHelper.retrieveCurrentContactId();
            List<Contact_Association_Type__c> catList = [SELECT Id, Account__c FROM Contact_Association_Type__c WHERE Contact__c = :contactId AND CatIdentifier__c =: catsRecordId WITH SECURITY_ENFORCED];
            List<Contact_Association_Type__c> updateCatList = new List<Contact_Association_Type__c>();
            for(Contact_Association_Type__c catRec : catList){
                Contact_Association_Type__c catObj = new Contact_Association_Type__c();
                catObj.Id = catRec.Id;
                catObj.Deleted_On_Resubmission__c = true;
                updateCatList.add(catObj);
            }
            if(!updateCatList.isEmpty() && Schema.sObjectType.Contact_Association_Type__c.isUpdateable()){
                update updateCatList;
            }
        }
        return true;
    }  
    @AuraEnabled(Cacheable = false)
    public static void deleteAllSelectedOrg(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>();
        catsList = [SELECT Id,Account__c FROM Contact_Association_Type_Staging__c WHERE Contact__c = :contactId AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG WITH SECURITY_ENFORCED];
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isDeletable() && !catsList.isEmpty()){
            Delete catsList;
            List<Contact_Association_Type__c> catList = [SELECT Id, Account__c FROM Contact_Association_Type__c WHERE Contact__c = :contactId AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG WITH SECURITY_ENFORCED];
            List<Contact_Association_Type__c> updateCatList = new List<Contact_Association_Type__c>();
            for(Contact_Association_Type__c catRec : catList){
                Contact_Association_Type__c catObj = new Contact_Association_Type__c();
                catObj.Id = catRec.Id;
                catObj.Deleted_On_Resubmission__c = true;
                updateCatList.add(catObj);
            }
            if(!updateCatList.isEmpty() && Schema.sObjectType.Contact_Association_Type__c.isUpdateable()){
                update updateCatList;
            }
        }
    }
    @AuraEnabled(Cacheable = false)
    public static Account insertNewRegOrg(String jsonString){
        EpicCredVerController.RegOrgCreationWrapper regOrgObject = (EpicCredVerController.RegOrgCreationWrapper) JSON.Deserialize(jsonString, EpicCredVerController.RegOrgCreationWrapper.class);
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_UNAPPROVED_ENTITY).getRecordTypeId();
        Account regOrg = new Account();
        Account newAccountRec = new Account();
        regOrg.Name = regOrgObject.regOrgName;
        regOrg.BillingCountryCode = regOrgObject.countryName;
        regOrg.BillingStreet = regOrgObject.streetName;
        regOrg.BillingCity = regOrgObject.cityName;
        regOrg.BillingStateCode = regOrgObject.stateName;
        regOrg.BillingPostalCode = regOrgObject.postalCode;
        regOrg.RecordTypeId = recTypeId;
        if(Schema.sObjectType.Account.isCreateable()){
            Insert regOrg;
        }
        if(regOrg.Id!= null){
            newAccountRec = [Select Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                            BillingCountry From Account Where Id = :regOrg.Id WITH SECURITY_ENFORCED];
        }
        return newAccountRec;
    }
    public class RegOrgCreationWrapper{
        @auraenabled public String regOrgName {get;set;}
		@auraenabled public String countryName {get;set;}
		@auraenabled public String streetName {get;set;}
		@auraenabled public String cityName {get;set;}
		@auraenabled public String stateName {get;set;}
		@auraenabled public String postalCode {get;set;}
    }
   //method to get Credential Attributes from custom metadata
   @AuraEnabled(cacheable = true)
   public static List<String> getCredentialAttributes(String programName){
       List<String> returnVal = new List<String>();           
       List<Program_Document_type_Mapping__mdt> docList = [SELECT Id,DeveloperName,Program__c,Credential_Type__c,Label,MasterLabel 
                                                          FROM Program_Document_type_Mapping__mdt WHERE Program__c =: programName WITH SECURITY_ENFORCED];        
       for(Program_Document_type_Mapping__mdt doc : docList){
           returnVal.add(doc.Credential_Type__c);
       }
       return returnVal;
   }
   @AuraEnabled
   public static Boolean checkEpicFMDExist(){
       Id contactId = AppforCertHelper.retrieveCurrentContactId();       
       List<Asset> epicAsset = [select id,type__c,status from Asset where contactId =:contactId AND
                                status !=: constants.ASSET_STATUS_REJECTED AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
                                AND status !=: constants.ASSET_STATUS_INCOMPLETE AND type__c =: constants.ASSET_TYPE_FINAL_MED_DIPLOMA WITH SECURITY_ENFORCED];
       if(!epicAsset.isEmpty()){
           Return true;
       }else{
           Return false;
       }
    }
    //Method to get listof cat staging records for the uploaded credentials
    @AuraEnabled
    public static List<AsstCatStagWrapper> getAssetCatStagList(string program){
        List<AsstCatStagWrapper> wrapperList = new List<AsstCatStagWrapper>();
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Map<String,String> issueDateMap = getIssueDateMap(program);
        Map<String,String> titleMap = getTitleMap(program);
        Map<Id,Case> reportRecipientMap = new Map<Id,Case>();
        String title;
        Date issueDate;
        String dateFieldName;
        String titleFieldName;
        Case reportRecipientFieldName;
        String reportRecipient;
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Case> evrList = [SELECT Id, Entity__r.Name, Do_Not_Know_Orgs_to_send_EPIC_Reports__c, Secondary_Parent_Case__c FROM Case WHERE RecordTypeId =: Constants.EPICVERREPORTREQRTID AND ContactId = :ContactId AND  Secondary_Parent_Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED];
        if(!evrList.isEmpty()){
            for(Case evr : evrList){
                reportRecipientMap.put(evr.Secondary_Parent_Case__c, evr);
            }
        }
        List<Contact_Association_Type_Staging__c> catStagList = [Select Id, Case__c,  Credential_Type__c, Account__r.name, Degree_Issue_Date__c, Issue_Date__c, Degree_Title__c,
                                                                 Title__c from Contact_Association_Type_Staging__c where Case__r.RecordTypeId = :caseRecTypeId  AND Case__r.Internal_Status__c = :Constants.CASE_STATUS_PENDING_SUBMISSION AND
                                                                 RecordTypeId = :catRecTypeId AND Contact__c = :ContactId WITH SECURITY_ENFORCED];
        if(!catStagList.isEmpty()){
            for(Contact_Association_Type_Staging__c catStag : catStagList){
                dateFieldName = issueDateMap.get(catStag.Credential_Type__c);
                if(String.isNotBlank(dateFieldName)){
                    issueDate = getIssueDate(dateFieldName,catStag);
                }else{
                    issueDate = NULL;
                }
                titleFieldName = titleMap.get(catStag.Credential_Type__c);
                if(String.isNotBlank(titleFieldName)){
                    title = getTitle(titleFieldName,catStag);
                }else{
                    title = '';
                }
                if(!reportRecipientMap.isEmpty()){
                    reportRecipientFieldName = reportRecipientMap.get(catStag.Case__c);
                }
                if(reportRecipientFieldName!=null){
                    if(reportRecipientFieldName.Do_Not_Know_Orgs_to_send_EPIC_Reports__c){
                        reportRecipient= 'No Report Requested';
                    }else{
                        reportRecipient= reportRecipientFieldName.Entity__r.Name;
                    }
                }
                if(!reportRecipientMap.isEmpty() && reportRecipientFieldName != null){
                    wrapperList.add(new AsstCatStagWrapper(catStag, issueDate, title, reportRecipient, reportRecipientFieldName.Id));
                }else{
                    wrapperList.add(new AsstCatStagWrapper(catStag, issueDate, title, null, null));
                }
            }
        }
        Return wrapperList;
    }
    //Method to delete credential verification case, Cat staging record and mark Asset for deletion
    @AuraEnabled
    public static void deleteCredVerCase(Id catStagId){
        Id recTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION).getRecordTypeId();
        List<Case> casesToDelete = new List<Case>();
        List<Asset> asstList = [Select Id,status,case__c from Asset where Contact_Association_Type_Staging__c = :catStagId WITH SECURITY_ENFORCED];
        Id usrId = UserInfo.getUserId();
        for(Asset asst : asstList){
            asst.status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = recTypeId;
        }
        if(Schema.sObjectType.Asset.isUpdateable() && !asstList.isEmpty()){
            Update asstList;
        }
        Contact_Association_Type_Staging__c catStag = [Select Id, Case__c from Contact_Association_Type_Staging__c where Id = :catStagId WITH SECURITY_ENFORCED];
        Case credVerCase = [Select Id from case where Id= :catStag.Case__c WITH SECURITY_ENFORCED];
        if(credVerCase.Id != null){
            credVerCase.OwnerId = usrId;
            casesToDelete.add(credVerCase);
            
        }
        List<Case> evReport = [SELECT Id FROM Case WHERE Secondary_Parent_Case__c =:credVerCase.Id WITH SECURITY_ENFORCED];
        for(case evCase : evReport){
            evCase.OwnerId = usrId;
            casesToDelete.add(evCase);
        }
        if(Schema.sObjectType.Case.isUpdateable() && !casesToDelete.isEmpty()){
            Update casesToDelete;
            Delete casesToDelete; //CRUD check not done as delete permission for case object cannot be given to the community user
        }
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isDeletable() && catStag.Id != null){
           Delete catStag;
        }
    }
    //Method to get Special instruction details
    @AuraEnabled(Cacheable = true)
    public static List<Account> getSpecInstrDetails(){
        Set<Id> accIds = new Set<Id>();
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id regOrgCatRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION).getRecordTypeId();
        List<Contact_Association_Type__c> catList = [Select account__c from Contact_Association_Type__c where recordTypeId = :regOrgCatRecTypeId and Contact__c = :contactid WITH SECURITY_ENFORCED];
        For(Contact_Association_Type__c cat : catList){
            accIds.add(cat.account__c);
        }
        List<Account> accList = [Select Id, name, EPIC_Client_Special_Instructions_Languag__c, EPIC_Client_Special_Instructions_url__c from Account where Id IN : accIds WITH SECURITY_ENFORCED];
        List<Account> specInstrAccList = new List<Account>();
        for(Account acc: accList){
            if(String.isNotBlank(acc.EPIC_Client_Special_Instructions_Languag__c) && String.isNotBlank(acc.EPIC_Client_Special_Instructions_url__c)){
                specInstrAccList.add(acc);
            }
        }
        Return specInstrAccList;
    }
    public class AsstCatStagWrapper{
        @auraenabled public string recordIdVal {get; set;}
        @auraenabled public Id caseIdVal {get; set;}
        @auraenabled public string documentType {get; set;}
        @auraenabled public string issuingEntity {get; set;}
        @auraenabled public Date issueDate {get; set;}
        @auraenabled public string title {get; set;}
        @auraenabled public string reportRecipient {get; set;}
        @auraenabled public string cvId {get; set;}
        public AsstCatStagWrapper(Contact_Association_Type_Staging__c catStag, date issueDate, string title, String reportRecipient, Id evrId){
            this.recordIdVal = catStag.Id;
            this.caseIdVal = evrId;
            this.documentType = catStag.Credential_Type__c;
            this.issuingEntity = catStag.Account__r.name;
            this.issueDate = issueDate;
            this.title = title;
            this.reportRecipient = reportRecipient;
            this.cvId =catStag.Case__c;
        }
    }
    public static Map<String,String> getIssueDateMap(string program){
        Map<String,String> issueDateMap = new Map<String,String>();
        list<string> issueDateFields = new list<string>();
        issueDateFields.add(Constants.DOCTYPFIELDMAP_DEGREE_ISSUE_DATE);
        issueDateFields.add(Constants.DOCTYPFIELDMAP_ISSUE_DATE);
        List<Program_Document_Type_Mapping__mdt> prgDocTypMapping = [Select Credential_Type__c, (Select Field_API_Name__c from Document_Type_Field_Mappings__r where Field_API_Name__c IN :issueDateFields) 
                                                                     From Program_Document_Type_Mapping__mdt WHERE Program__c = :program WITH SECURITY_ENFORCED];
        for(Program_Document_Type_Mapping__mdt prgDoc : prgDocTypMapping){
            if(!prgDoc.Document_Type_Field_Mappings__r.isEmpty()){
                issueDateMap.put(prgDoc.Credential_Type__c, prgDoc.Document_Type_Field_Mappings__r[0].Field_API_Name__c);
            }
        }
        Return issueDateMap;
    }
    public static date getIssueDate(string dateFieldName, Contact_Association_Type_Staging__c cat){
        if(dateFieldName == Constants.DOCTYPFIELDMAP_DEGREE_ISSUE_DATE){
            Return cat.Degree_Issue_Date__c;
        }else if(dateFieldName == Constants.DOCTYPFIELDMAP_ISSUE_DATE){
            Return cat.Issue_Date__c;
        }
        Return null;
    }
    public static Map<String,String> getTitleMap(string program){
        Map<String,String> titleMap = new Map<String,String>();
        list<string> titleFields = new list<string>();
        titleFields.add(Constants.DOCTYPFIELDMAP_DEGREE_TITLE);
        titleFields.add(Constants.DOCTYPFIELDMAP_TITLE);
        List<Program_Document_Type_Mapping__mdt> prgDocTypMapping = [Select Credential_Type__c, (Select Field_API_Name__c from Document_Type_Field_Mappings__r where Field_API_Name__c IN :titleFields) 
                                                                     From Program_Document_Type_Mapping__mdt WHERE Program__c = :program WITH SECURITY_ENFORCED];
        for(Program_Document_Type_Mapping__mdt prgDoc : prgDocTypMapping){
            if(!prgDoc.Document_Type_Field_Mappings__r.isEmpty()){
                titleMap.put(prgDoc.Credential_Type__c, prgDoc.Document_Type_Field_Mappings__r[0].Field_API_Name__c);
            }
        }
        Return titleMap;
    }
    public static string getTitle(string titleFieldName, Contact_Association_Type_Staging__c cat){
        if(titleFieldName == Constants.DOCTYPFIELDMAP_DEGREE_TITLE){
            Return cat.Degree_Title__c;
        }else if(titleFieldName == Constants.DOCTYPFIELDMAP_TITLE){
            Return cat.Title__c;
        }
        Return null;
    }
   // method to update assets Status to mark for deletion
	@AuraEnabled
	public static Boolean markAssetsForDeletion(String azureUrl){
		List<Asset> assetsToUpdateList = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if(rts.isEmpty()){
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(Asset.SObjectType.getDescribe().isUpdateable() && azureUrl != null){
			for(Asset a: [SELECT Id, Status FROM Asset WHERE Azure_Storage_URL__c =:azureUrl WITH SECURITY_ENFORCED]){
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
			UPDATE assetsToUpdateList;
		}
		return true;
	}
    @AuraEnabled
	public static Boolean createTermsRecord(string epicLegalVar){
        List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
        termsList = [SELECT Id, Copy__c, Name From Terms_and_Conditions__c WHERE Product__r.Name =: Constants.PRODUCT_NAME_EPIC_LEGAL_TERMS AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE WITH SECURITY_ENFORCED];
        if(!termsList.isEmpty()){
            createTermsConditionsAgreement(termsList);
        }
        return true;
    }
    @AuraEnabled
	public static void createTermsConditionsAgreement(List<Terms_and_Conditions__c> termsList){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Id> termsId = new List<Id>();
        for(Terms_and_Conditions__c terms : termsList){
            termsId.add(terms.Id);
        }
        List<Terms_and_Conditions_Agreement__c> deactList = new List<Terms_and_Conditions_Agreement__c>();
        deactList = [SELECT Id, Status__c From Terms_and_Conditions_Agreement__c WHERE Contact__c =: contactId AND TermsandConditions__c IN: termsId WITH SECURITY_ENFORCED];
        if(!deactList.isEmpty()){
            for(Terms_and_Conditions_Agreement__c deactRec : deactList){
                deactRec.Status__c = Constants.TERMS_AND_COND_AGR_STATUS_INACTIVE;
            }
            if(Schema.sObjectType.Terms_and_Conditions_Agreement__c.isUpdateable()){
                UPDATE deactList;
            }
        }
        List<Terms_and_Conditions_Agreement__c> termsInsert = new List<Terms_and_Conditions_Agreement__c>();
        for(Terms_and_Conditions__c term : termsList){
            Terms_and_Conditions_Agreement__c tcAgrObj = new Terms_and_Conditions_Agreement__c();
            tcAgrObj.Contact__c = contactId;
            tcAgrObj.TermsandConditions__c = term.Id;
            tcAgrObj.Name = term.Name + contactId;
            tcAgrObj.Status__c = Constants.TERMS_AND_COND_AGR_STATUS_ACTIVE;
            tcAgrObj.Copy__c = term.Copy__c;
            termsInsert.add(tcAgrObj);
        }        
        if(Schema.sObjectType.Terms_and_Conditions_Agreement__c.isCreateable()){
            INSERT termsInsert;
        }
    }
    @AuraEnabled(Cacheable=true)
    public static List <AppForCertHelper.TermsObjWrapper> getTermsandConditionsEPIC(){
        List<AppForCertHelper.TermsObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper>();
        List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
        if(Terms_and_Conditions__c.SObjectType.getDescribe().isAccessible()){
            termsList = [SELECT Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c 
                        WHERE Product__r.Name =: Constants.PRODUCT_NAME_EPIC_LEGAL_TERMS
                        AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
                        ORDER BY CreatedDate ASC];
        }
        if(!termsList.isEmpty()){
            for(Terms_and_Conditions__c terms : termsList){
                string termsId = terms.Id;
                string termsContent = terms.Copy__c;
                string termsCheckBox = terms.Short_Copy__c;
                AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);
                fetchedValuesToReturn.add(tempTermsObj);
            }
        }
        return fetchedValuesToReturn;
    }
    @AuraEnabled
	public static String createEpicExtractionCase(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id epicExtractionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();                
        List<Case> existEpicExtractCase = [Select Id from Case WHERE ContactId =: contactId AND RecordTypeId =: epicExtractionRecordTypeId AND Internal_Status__c =:Constants.CASE_STATUS_PENDING_SUBMISSION];
        String epicExtractionCaseId = '';
        if(existEpicExtractCase.isEmpty()){
            Case caseObj = new case();
            caseObj.ContactId = contactId;
            caseObj.OwnerId = UserInfo.getUserId();
            caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
            caseObj.Service__c = Constants.CASE_SERVICE_EPIC;
            caseObj.RecordTypeId = epicExtractionRecordTypeId;
            if(Schema.sObjectType.Case.isCreateable()){
                insert caseObj;
                epicExtractionCaseId = caseObj.Id;
            }
        }else{
            epicExtractionCaseId = existEpicExtractCase[0].Id;
        }
        return epicExtractionCaseId;
    }
    //Changes the internal status of Epic Extraction case from Pending Submission To New on payment
    @AuraEnabled
    public static List<string> statusChangeEpicExtract(){
        String currConId = AppForCertController.getContactId();
        Id epicExtractionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.QUEUE_EPIC_EXTRACTIONS WITH SECURITY_ENFORCED];
        List<Case> epicExtractList = [SELECT Id, Entity__c, CaseNumber, Internal_Status__c FROM Case WHERE RecordTypeId =: epicExtractionRecordTypeId AND ContactId = :currConId AND Internal_Status__c=:Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED];
        List<Case> upEpicExtractCases = new List<Case>();
        List<String> epicExtractCaseNums = new List<String>();
        for(Case evr: epicExtractList ){
            evr.Internal_Status__c= Constants.CASE_STATUS_NEW;
            evr.OwnerId = g.Id;
            upEpicExtractCases.add(evr);
            epicExtractCaseNums.add(evr.CaseNumber);
        }
        if(Schema.sObjectType.Case.isUpdateable() && !upEpicExtractCases.isEmpty()){
            Update upEpicExtractCases;
            migrateCATSRegulatoryOrganization();
        }
        return epicExtractCaseNums;
    }
    @AuraEnabled
    public static Boolean migrateCATSRegulatoryOrganization(){
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();		
		string fieldNames = '';
		Contact_Association_Type__c catRecord = new Contact_Association_Type__c();
        List<Contact_Association_Type_Staging__c> recordsList = new List<Contact_Association_Type_Staging__c>();
        List<Contact_Association_Type__c> recordsListCat = new List<Contact_Association_Type__c>();        
        // Coping records from CATS to CAT
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION).getRecordTypeId();
        Map<String, Schema.SObjectField> fieldMapCatStaging = Schema.getglobaldescribe().get('Contact_Association_Type_Staging__c').getdescribe().fields.getmap();
		fieldNames = getCATSFieldNames(fieldMapCatStaging);       
		String soqlQuery = 'SELECT RecordType.DeveloperName, '+fieldNames+' FROM Contact_Association_Type_Staging__c WHERE Contact__c = \'' + String.escapeSingleQuotes(currentContactId) + '\'' + ' AND RecordType.DeveloperName = \'' + String.escapeSingleQuotes(Constants.CONASCTYPESTG_RECORD_TYPE_REGULATORY_ORGANIZATION) + '\'';        
		recordsList = Database.query(soqlQuery);
        if(!recordsList.isEmpty()){
            // Delete existing Regulatory Organization records on CAT
            deleteExistCATRegulatoryOrg(currentContactId);
            for(Contact_Association_Type_Staging__c record : recordsList){
                catRecord = getCATSRegulOrgRecords(record);
                catRecord.put('Contact__c', currentContactId);
                catRecord.put('CatIdentifier__c', record.Id);
                catRecord.put('RecordTypeId', catRecTypeId);
                recordsListCat.add(catRecord);
            }
        }       
        // Coping CATS records to CAT Object
        copingRecordToCAT(recordsListCat, currentContactId);
        return true;
	}
    // Get CATS object Field Names
    public static string getCATSFieldNames(Map<String, Schema.SObjectField> fieldMapCatStaging){
		string fieldNames = '';
		for(Schema.SObjectField field1 : fieldMapCatStaging.values()){
			fieldNames = fieldNames + field1.getDescribe().getName()+ ',';
		}
		fieldNames = fieldNames.removeEnd(',');
		return fieldNames;
	}
    @AuraEnabled
	public static Contact_Association_Type__c getCATSRegulOrgRecords(Contact_Association_Type_Staging__c record){
		Map<String, Schema.SObjectField > fieldMapCatStaging = Schema.getglobaldescribe().get('Contact_Association_Type_Staging__c').getdescribe().fields.getmap();
		Map<String, Schema.SObjectField > fieldMapCat = Schema.getglobaldescribe().get('Contact_Association_Type__c').getdescribe().fields.getmap();
		Contact_Association_Type__c catRecord = new Contact_Association_Type__c();
		for(Schema.SObjectField field: fieldMapCatStaging.values()){
			string fieldName = field.getDescribe().getName();
			if(fieldMapCat.containsKey(fieldName) && field.getDescribe().isUpdateable() && field.getDescribe().isAccessible() && fieldName != 'RecordTypeId'){
				catRecord.put(fieldName, record.get(fieldName));
			}
		}
		return catRecord;
	}
    // Coping CATS records to CAT Object
    public static void copingRecordToCAT(List<Contact_Association_Type__c> recordsListCat, Id currentContactId){
		if(!recordsListCat.isEmpty() && Schema.sObjectType.Contact_Association_Type__c.isCreateable()){
			insert recordsListCat;
            // After coping record from CATS to CAT, delete the records on CAT
            deleteExistCATSRegulatoryOrg(currentContactId);
		}
	}
    // Delete Regulatory_Organization records on CAT object
    public static void deleteExistCATRegulatoryOrg(Id currentContactId){
        List<Contact_Association_Type__c> catRecordsList = [SELECT ID, RecordType.DeveloperName FROM Contact_Association_Type__c WHERE Contact__c =: currentContactId AND RecordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION WITH SECURITY_ENFORCED];
        if(!catRecordsList.isEmpty() && Contact_Association_Type__c.SObjectType.getDescribe().isDeletable()){          
            DELETE catRecordsList;
        }
    }
    // Delete Regulatory_Organization records on CATS object
    public static void deleteExistCATSRegulatoryOrg(Id currentContactId){
        List<Contact_Association_Type_Staging__c> catsRecordsList = [SELECT ID FROM Contact_Association_Type_Staging__c WHERE Contact__c =: currentContactId AND RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_REGULATORY_ORGANIZATION WITH SECURITY_ENFORCED];
        if(!catsRecordsList.isEmpty() && Contact_Association_Type_Staging__c.SObjectType.getDescribe().isDeletable()){
            DELETE catsRecordsList;
        }
    }
    @AuraEnabled(Cacheable=true)
    public static String getCaseNumber(){
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        String returnVal = '';
        List<case> newCases = new List<case>();
        if(currentContactId != null){
            newCases = [SELECT id, CaseNumber FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION
                            AND ContactId =: currentContactId 
                            AND Case_Status__c != :Constants.CASE_STATUS_REJECTED];
            if(!newCases.isEmpty()){
                returnVal = newCases[0].CaseNumber;
            }
        }
        return returnVal;
    }
    @AuraEnabled(Cacheable=true)
    public static String getMetadataId(){
        String returnVal = '';
        List <Confirmation_Message__mdt> confMsgs = new List <Confirmation_Message__mdt>();
        confMsgs = [SELECT Id FROM Confirmation_Message__mdt WHERE DeveloperName =: Constants.CONFIRMATION_MESSAGE_EPIC_CRE_VERI WITH SECURITY_ENFORCED];
        if(!confMsgs.isEmpty()){
            returnVal = confMsgs[0].Id;
        }
        return returnVal;
    }
    @AuraEnabled(cacheable = false)
    public static Map<String,String> getProgDocTypeMap(String docName,String programName){
        Map<String,String> returnVal = new Map<String,String>();
        List<Program_Document_type_Mapping__mdt> docList = [SELECT Id,DeveloperName,Program__c,Credential_Type__c,Label,MasterLabel 
                        FROM Program_Document_type_Mapping__mdt WHERE Credential_Type__c =: docName AND Program__c =: programName WITH SECURITY_ENFORCED];
        if(!docList.isEmpty()){
            List<Document_Type_Field_Mapping__mdt> proDocMapList = [SELECT Id,DeveloperName,Field_API_Name__c,Field_Label__c,Field_Order__c,Program_Document_Type_Mapping__c,Label,MasterLabel 
                        FROM Document_Type_Field_Mapping__mdt WHERE Program_Document_Type_Mapping__c =: docList[0].Id WITH SECURITY_ENFORCED ORDER BY Field_Order__c ASC];
            if(!proDocMapList.isEmpty()){
                for(Document_Type_Field_Mapping__mdt proDoc : proDocMapList){
                    returnVal.put(proDoc.Field_API_Name__c,proDoc.Field_Label__c);
                }
            }
        }
        return returnVal;
    }
    // method to update assets Status to mark for deletion
	@AuraEnabled
	public static Boolean assetsDeletionOnPageLoad(String contactId){
		List<Asset> assetsToUpdateList = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if(rts.isEmpty()){
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT Id, Status FROM Asset WHERE contactId =: contactId AND case__c =: null AND (Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST OR Parent.Name =: Constants.ASSET_NAME_CREDENTIAL_REQUEST) AND Status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED]){
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
			UPDATE assetsToUpdateList;
		}
		return true;
	}    
    // method to check Portal and non-portal accounts
	@AuraEnabled
	public static String checkVerifictn(String accId,String credType){	
        String returnValue = '';
        List<Account2Service__c> acc2ServPortalList = new List<Account2Service__c>();
        List<Account2Service__c> acc2ServNonPortalList = new List<Account2Service__c>();
        List<CONTACT2ACCTSERVICE__c> con2AccList = new List<CONTACT2ACCTSERVICE__c>();
        if(Account2Service__c.SObjectType.getDescribe().isAccessible()){
            acc2ServPortalList = [Select id,name from Account2Service__c where Account__c =: accId and Service__r.Name=: constants.SERVICE_NAME_CREDENTIAL_VERIFICATION and Active__c = True WITH SECURITY_ENFORCED];
            acc2ServNonPortalList = [Select id,name from Account2Service__c where Account__c =: accId and Service__r.Name=: constants.SERVICE_NAME_CREDENTIAL_VERIFICATION and Active__c = False WITH SECURITY_ENFORCED];
            if(!acc2ServPortalList.isEmpty()){
                returnValue = 'PORTAL';
            }else if(!acc2ServNonPortalList.isEmpty()){
                con2AccList = [Select id,name,Preferred_Mode_of_Communication__c from CONTACT2ACCTSERVICE__c Where Credential_Type__c =: credType And Account_Service__c =: acc2ServNonPortalList[0].Id And Active__c = True WITH SECURITY_ENFORCED];
                if(!con2AccList.isEmpty()){
                    returnValue = checkVerPerMode(con2AccList);
                }
            }
        }		
		return returnValue;
	}
    public static string checkVerPerMode(List<CONTACT2ACCTSERVICE__c> con2AccList){
        String returnValue = '';
        if(con2AccList[0].Preferred_Mode_of_Communication__c == 'Email' || con2AccList[0].Preferred_Mode_of_Communication__c == 'Website'){
            returnValue = 'NONPORTAL_EM_Web';
        }else if(con2AccList[0].Preferred_Mode_of_Communication__c == 'Paper'){
            returnValue = 'NONPORTAL_PAPER';
        }
        return returnValue;
    }

    @AuraEnabled
    public static Boolean getRegOrgDontKnow(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Contact existContact = [SELECT id,Regulatory_Org_Do_Not_Know__c FROM CONTACT WHERE id =:contactId WITH SECURITY_ENFORCED];
        return existContact.Regulatory_Org_Do_Not_Know__c;
    }
    @AuraEnabled
    public static void updateContactRegOrgField(Boolean regOrgChecked){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Contact existContact = [SELECT id,Regulatory_Org_Do_Not_Know__c FROM CONTACT WHERE id =:contactId WITH SECURITY_ENFORCED];
        if(existContact.Id != null && Contact.SObjectType.getDescribe().isUpdateable()){
            existContact.Regulatory_Org_Do_Not_Know__c = regOrgChecked;
            update existContact;
        }
    }
    //Method to return entities which are mapped with school type for each credential 
    @AuraEnabled(Cacheable = false)
    public static List<Account> searchEntities(String searchKey, String credType, String programName){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        List<Account> entityList = new List<Account>();
        Map<Id, Account> entityMap = new Map<Id, Account>();
        Set<String> schoolTypes = new Set<String>();
        Set<String> accountTypes = new Set<String>();
        String keyValue = '%' + searchKey + '%';
        List<Program_Document_type_Mapping__mdt> pgmDocType = [SELECT Id, Credential_Type__c, Program__c 
                                                                FROM Program_Document_type_Mapping__mdt 
                                                                WHERE Credential_Type__c =:credType AND Program__c =:programName 
                                                                WITH SECURITY_ENFORCED];
        List<Document_Type_Role_Mapping__mdt> docSchoolTypes = [SELECT Program_Document_Type_Mapping__c, School_Type__c, Account_Type__c 
                                                                FROM Document_Type_Role_Mapping__mdt
                                                                WHERE Program_Document_Type_Mapping__c =:pgmDocType[0].Id 
                                                                WITH SECURITY_ENFORCED];
        for(Document_Type_Role_Mapping__mdt docType : docSchoolTypes){
            if(String.isNotBlank(docType.School_Type__c)){
                schoolTypes.add(docType.School_Type__c);
            }
            if(docType.Account_Type__c != 'school'){
                accountTypes.add(docType.Account_Type__c);
            }
        }
        entityList = [SELECT Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, sch_School_Type__c, Account_Type__c, University_Name__c  
                    FROM Account 
                    WHERE Name LIKE :keyValue AND RecordTypeId =:recTypeId 
                    WITH SECURITY_ENFORCED];
        for(Account acc : entityList){
            if(String.isNotBlank(acc.sch_School_Type__c) && acc.Account_Type__c.contains('School') && checkSchoolType(acc, schoolTypes)){
                entityMap.put(acc.Id, acc);
            }
            if(String.isNotBlank(acc.Account_Type__c) && checkAccountType(acc, accountTypes)){
                entityMap.put(acc.Id, acc);
            }
        }
        return entityMap.values();
    }
    public static boolean checkSchoolType(Account acc, Set<String> schoolTypes){
        List<String> selectedSchTypes = new List<String>();
        selectedSchTypes = acc.sch_School_Type__c.split(';');
        for(String schType : selectedSchTypes){
            if(schoolTypes.contains(schType)){
                return true;
            }
        }
        return false;
    }
    public static boolean checkAccountType(Account acc, Set<String> accountTypes){
        for(String accType : accountTypes){
            if(acc.Account_Type__c.contains(accType)){
                return true;
            }
        }
        return false;
    }
    // method to get azure urls of assets related to a case which are in inprogress status
	@AuraEnabled
	public static Map<String, String> getAssetUrls(String caseId){
        Map<String, String> assetUrlMap = new Map<String, String>();
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c, Type__c, Name_on_Document_is_Different__c, Document_is_not_in_English__c, Name_on_Document__c, Name FROM Asset where case__c =:caseId AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED];
        for(Asset asst: assetList){
            assetUrlMap.put(asst.Type__c, asst.Azure_Storage_URL__c);
            if(asst.Name == Constants.ASSET_NAME_CREDENTIAL_REQUEST){
                assetUrlMap.put('Name is different', String.valueOf(asst.Name_on_Document_is_Different__c));
                assetUrlMap.put('Translation required', String.valueOf(asst.Document_is_not_in_English__c));
                assetUrlMap.put('Name on document', String.valueOf(asst.Name_on_Document__c));
                assetUrlMap.put(asst.Name, asst.Azure_Storage_URL__c);
                assetUrlMap.put('Credential type', asst.type__c);
            }
        }
        return assetUrlMap;
    }
    // method to update Status of assets which are not linked to a case to mark for deletion
	@AuraEnabled
	public static Boolean deleteAssetsWithoutCase(String azureUrl){
		List<Asset> assetsToUpdateList = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT Id, Status FROM Asset WHERE Azure_Storage_URL__c =:azureUrl AND Case__c = null WITH SECURITY_ENFORCED]){
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
	}
    // method to get certificate of good standing related checkbox values
	@AuraEnabled
	public static Contact_Association_Type_Staging__c getCatCheckboxValues(String catsId){
        List<Contact_Association_Type_Staging__c> catsList = [SELECT Id, Name_on_Document__c, Credential_Type__c, Issued_in_the_last_90_days__c, Case__c, Requested_to_be_sent_to_ECFMG__c, account__c, account__r.Name, account__r.BillingStreet, account__r.BillingCity, account__r.BillingState, account__r.BillingCountry, account__r.BillingcountryCode, Degree_Issue_Date__c, Degree_Title__c, Graduation_Year__c, Degree_expected_to_be_issued_Year__c, Degree_expected_to_be_issued_Month__c, Attendance_Start_Date__c, Attendance_End_Date__c, Program_Start_Date__c, Program_End_Date__c, Title__c, Issue_Date__c, Expiration_Date__c, Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c where Id =:catsId ];
        if(!catsList.isEmpty()){
            return catsList[0];
        }
        return null;
    }
    // method to update existing credential
	@AuraEnabled
	public static Boolean updateCredential(String inputJSON){
        CredUploadWrapper wrapper = (CredUploadWrapper)JSON.deserialize(inputJSON, CredUploadWrapper.class);
        List<String> assetUrls = new List<String>();
        assetUrls.add(wrapper.credUrl);
        assetUrls.add(wrapper.nameUrl);
        assetUrls.add(wrapper.transUrl);
        List<String> assetUrlsToDelete = new List<String>();
        List<Asset> assetsToUpdate = new List<Asset>();
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c NOT IN:assetUrls AND case__c =:wrapper.caseId AND Azure_Storage_URL__c !=null WITH SECURITY_ENFORCED];
        List<Asset> currentAssets = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN:assetUrls AND Azure_Storage_URL__c != null WITH SECURITY_ENFORCED];
        for(Asset ast:currentAssets){
            ast.Uploaded_by_applicant__c = true;
            if(ast.Azure_Storage_URL__c == wrapper.credUrl){
                ast.Name_on_Document__c = wrapper.nameOnDoc;
                ast.Name_on_Document_is_Different__c = wrapper.nameDifferent;
                ast.Document_is_not_in_English__c = wrapper.translationRequired;
                ast.case__c = wrapper.caseId;
                ast.Contact_Association_Type_Staging__c = wrapper.catsId;
                assetsToUpdate.add(ast);
            }
            if(ast.Azure_Storage_URL__c == wrapper.transUrl){
                ast.case__c = wrapper.caseId;
                ast.Contact_Association_Type_Staging__c = wrapper.catsId;
                assetsToUpdate.add(ast);
            }
            if(ast.Azure_Storage_URL__c == wrapper.nameUrl){
                ast.case__c = wrapper.caseId;
                ast.Contact_Association_Type_Staging__c = wrapper.catsId;
                assetsToUpdate.add(ast);
            }
        }
        Contact_Association_Type_Staging__c catsRecord = new Contact_Association_Type_Staging__c();
        catsRecord.Id = wrapper.catsId;
        catsRecord.Name_on_Document__c = wrapper.nameOnDoc;
        catsRecord.Issued_in_the_last_90_days__c = wrapper.haveCertificate;
        catsRecord.Requested_to_be_sent_to_ECFMG__c = wrapper.requestedToSend;
        catsRecord.account__c = wrapper.entityId;
        updateEvr(wrapper.evrWrap,wrapper.evrId,wrapper.caseId);//User story#20936
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
            UPDATE catsRecord;
        }
        for(Asset asst: assetList){
            assetUrlsToDelete.add(asst.Azure_Storage_URL__c);
        }
        if(!assetsToUpdate.isEmpty()){
            UPDATE assetsToUpdate;
        }
        if(!assetUrlsToDelete.isEmpty()){
            deleteAssets(JSON.serialize(assetUrlsToDelete));
        }
        return true;
    }
    //Wrapper class for 
	public class CredUploadWrapper{
        @auraenabled public string credUrl {get; set;}
		@auraenabled public string transUrl {get; set;}
		@auraenabled public string nameUrl {get; set;}
        @auraenabled public string nameOnDoc {get; set;}
        @auraenabled public Boolean nameDifferent {get; set;}
        @auraenabled public Boolean translationRequired {get; set;}
		@auraenabled public Boolean requestedToSend {get; set;}
		@auraenabled public Boolean haveCertificate {get; set;}
        @auraenabled public string caseId {get; set;}
        @auraenabled public string catsId {get; set;}
        @auraenabled public string entityId {get; set;}
        @auraenabled public string evrWrap {get; set;}
        @auraenabled public string evrId {get; set;}
    }

    //Method to deleteEpicVerfRepRequestCase if user selects the I do not know Orgs checkbox. 
    @AuraEnabled
    public static Boolean deleteEpicVerfRepRequestCase(String evrcsId, String secParentCaseId, Boolean regOrgDNK){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        List<Case> csList = new List<Case>();

        if(contactId!= null && evrcsId!=null && secParentCaseId!=null){
            csList = [SELECT Id,Secondary_Parent_Case__c,ContactId,Report_Type__c FROM Case 
                  WHERE ContactId =:contactId AND RecordTypeId =:Constants.EPICVERREPORTREQRTID 
                  AND Secondary_Parent_Case__c =:secParentCaseId AND Id =:evrcsId 
                  WITH SECURITY_ENFORCED];
        }                
        // Update the CV case
        if(csList.size()>0 && !csList.isEmpty() && regOrgDNK==true){ 
            //Update the Do not know orgs to send reports field in parent CV case 
            Case evcvCase = new Case();          
            evcvCase.Id = csList[0].Secondary_Parent_Case__c;
            evcvCase.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = true;
            //Update the status of already created Epic verification report request case to expired
            csList[0].Internal_Status__c = Constants.CASE_STATUS_EXPIRED;
            csList[0].Secondary_Parent_Case__c = null;
            if(Schema.sObjectType.Case.isUpdateable()){
                Update evcvCase;
                Update csList;
            }
        }
        return true;        
    }

    // method to update Status of assets which are not linked to a case to mark for deletion
	@AuraEnabled
	public static Boolean deleteAssets(String assetUrls){
        List<String> assetUrlList = (List<String>)JSON.deserialize(assetUrls, List<String>.class);
		List<Asset> assetsToUpdateList = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT Id, Status FROM Asset WHERE Azure_Storage_URL__c IN:assetUrlList WITH SECURITY_ENFORCED]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
				a.Case__c = null;
				a.Contact_Association_Type_Staging__c = null;
				a.Exam_Registration__c = null;
				a.Exam_Registration_Exam_Type__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
			}
            if(!assetsToUpdateList.isEmpty()){
                UPDATE assetsToUpdateList;
            }
		}
		return true;
	}
    // method to update CATS record on credential edit
	@AuraEnabled
	public static Boolean updateCatsRecord(String fieldvals, String catsId){
        Contact_Association_Type_Staging__c catsRecord = (Contact_Association_Type_Staging__c) JSON.deserialize(fieldvals, Contact_Association_Type_Staging__c.class);
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
            UPDATE catsRecord;
            List<Contact_Association_Type_Staging__c> catsRecordLst = [SELECT Id,Credential_Type__c, Case__c,account__c,Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c where Id =:catsRecord.Id WITH SECURITY_ENFORCED];
            Case caseObj = new Case(Id = catsRecordLst[0].Case__c);
            caseObj.Entity__c = catsRecordLst[0].account__c;
            caseObj.Document_Type__c = catsRecordLst[0].Credential_Type__c;
            caseObj.Document_type_selected_by_applicant__c = catsRecordLst[0].Credential_Type__c;
            caseObj.Courier_Required__c = catsRecordLst[0].Courier_service_for_an_additional_fee__c;
		    if(Schema.sObjectType.Case.isUpdateable()){
                update caseObj;
            }  
        }
        return true;
    }
    @AuraEnabled(Cacheable = false)
    public static Account insertEntityOnSubmit(String jsonString){
        EpicCredVerController.EntityCreationWrapper entityRec = (EpicCredVerController.EntityCreationWrapper) JSON.Deserialize(jsonString, EpicCredVerController.EntityCreationWrapper.class);
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_UNAPPROVED_ENTITY).getRecordTypeId();
        Account entity = new Account();
        Account newAccountRec = new Account();
        entity.Name = entityRec.regOrgName;
        entity.University_Name__c = entityRec.universityName;
        entity.BillingCountryCode = entityRec.countryName;
        entity.BillingStreet = entityRec.streetName;
        entity.BillingCity = entityRec.cityName;
        entity.BillingStateCode = entityRec.stateName;
        entity.BillingPostalCode = entityRec.postalCode;
        entity.RecordTypeId = recTypeId;
        if(Schema.sObjectType.Account.isCreateable()){
            Insert entity;
        }
        if(entity.Id != null){
            newAccountRec = [SELECT Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, University_Name__c 
                            FROM Account 
                            WHERE Id =:entity.Id WITH SECURITY_ENFORCED];
        }
        return newAccountRec;
    }
    public class EntityCreationWrapper{
        @auraenabled public String regOrgName {get;set;}
        @auraenabled public String universityName {get;set;}
        @auraenabled public String countryName {get;set;}
        @auraenabled public String streetName {get;set;}
        @auraenabled public String cityName {get;set;}
        @auraenabled public String stateName {get;set;}
        @auraenabled public String postalCode {get;set;}
    }
    //method to create Terms record for Credential Intake
    @AuraEnabled
    public static Boolean createCredTermsRec(string credLegalVar){
        List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
        termsList = [SELECT Id, Copy__c, Name From Terms_and_Conditions__c WHERE Product__r.Name =: Constants.PRODUCT_NAME_CRED_INTAKE_LEGAL_TERMS AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE WITH SECURITY_ENFORCED];
        if(!termsList.isEmpty()){
            createTermsConditionsAgreement(termsList);
        }
         return true;
    }
     //method to get Terms and Conditions for Credential Intake
    @AuraEnabled(Cacheable=true)
    public static List <AppForCertHelper.TermsObjWrapper> getCredAllTC(){
        List<AppForCertHelper.TermsObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper>();
        List<Terms_and_Conditions__c> termsList = new List<Terms_and_Conditions__c>();
        termsList = [SELECT Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c 
                         WHERE Product__r.Name =: Constants.PRODUCT_NAME_CRED_INTAKE_LEGAL_TERMS
                         AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
                         ORDER BY CreatedDate ASC];
        if(!termsList.isEmpty()){
            for(Terms_and_Conditions__c terms : termsList){
                 string termsId = terms.Id;
                 string termsContent = terms.Copy__c;
                 string termsCheckBox = terms.Short_Copy__c;
                 AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);
                 fetchedValuesToReturn.add(tempTermsObj);
            }
        }
         return fetchedValuesToReturn;
    }
    @AuraEnabled
    public static List<string> payCompletion(){
        String currConId = AppForCertController.getContactId();
        Id qId = [Select Id from Group where type = 'Queue' and Name =: Constants.CASE_QUEUE_CREDENTIAL_REVIEW limit 1].Id;
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        List<Case> credCases = [Select id, Internal_Status__c, CaseNumber from Case where ContactId=:currConId and Internal_Status__c=:Constants.CASE_STATUS_PENDING_SUBMISSION and RecordTypeId=:credVerRecTypeId];
        List<Case> evrList = [SELECT Id, Entity__c, CaseNumber, Internal_Status__c FROM Case WHERE RecordTypeId =: Constants.EPICVERREPORTREQRTID AND ContactId = :currConId AND Internal_Status__c=:Constants.CASE_STATUS_NEW WITH SECURITY_ENFORCED];
        List<Case> upCredCases = new List<Case>();
        List<String> credCaseNums = new List<String>();
        Map<Id,Boolean> credCGS = checkCGSReqSentToECFMG(credCases);
        for(Case cs:credCases){
            cs.Internal_Status__c = Constants.CASE_STATUS_NEW;//Update External Status from the process builder
            if(credCGS.containskey(cs.Id) && credCGS.get(cs.Id)){
                cs.Internal_Status__c = Constants.CASE_STATUS_PENDING_CREDENTIAL_FROM_ENTITY;
            }
            cs.OwnerId = qId;
            upCredCases.add(cs);
            credCaseNums.add(cs.CaseNumber);
        }
        for(Case evr: evrList ){
            evr.Internal_Status__c= Constants.CASE_EPIC_REPORT_STATUS_REQUESTED;
            evr.Entity_External_Status__c = 'Not Reviewed';
            evr.OwnerId = qId;
            upCredCases.add(evr);
        }
        if(Schema.sObjectType.Case.isUpdateable() && !upCredCases.isEmpty()){
            Update upCredCases;
        }
        return credCaseNums;
    }
    public static Map<Id,Boolean> checkCGSReqSentToECFMG(List<Case> credCases){
        Map<Id,Boolean> returnMap = new Map<Id,Boolean>();
        Id credIntRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        for(Contact_Association_Type_Staging__c cs:[SELECT Id,Case__c,Requested_to_be_sent_to_ECFMG__c 
            FROM Contact_Association_Type_Staging__c WHERE Case__c IN:credCases AND RecordTypeId =: credIntRecTypeId AND
            Credential_Type__c = 'Certificate of Good Standing']){
                returnMap.put(cs.Case__c,cs.Requested_to_be_sent_to_ECFMG__c);
        }
        return returnMap;
    }
    //METHOD TO GET THE CREDENTIAL INTAKE CONFIRMATION MESSAGE
    @AuraEnabled(Cacheable=true)
    public static String getCredMetaData(){
        String returnVal = '';
        List <Confirmation_Message__mdt> confMsgs = new List <Confirmation_Message__mdt>();
        confMsgs = [SELECT Id FROM Confirmation_Message__mdt WHERE DeveloperName =: Constants.CONFIRMATION_MESSAGE_CRED_INTAKE WITH SECURITY_ENFORCED];
        if(!confMsgs.isEmpty()){
            returnVal = confMsgs[0].Id;
        }
        return returnVal;
    }  

    @AuraEnabled
    public static Boolean createCredential(String inputJSON,String fieldvals,String evrValues){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();       
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type_Staging__c catsRecord = (Contact_Association_Type_Staging__c) JSON.deserialize(fieldvals, Contact_Association_Type_Staging__c.class);
        catsRecord.Contact__c = contactId;
        catsRecord.RecordtypeId = catRecTypeId;
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isCreateable()){
            INSERT catsRecord;
        }
        CredUploadWrapper wrapper = (CredUploadWrapper)JSON.deserialize(inputJSON, CredUploadWrapper.class);
        EVRWrapper evrWrap = (EVRWrapper)JSON.deserialize(evrValues, EVRWrapper.class); 
        List<String> assetUrls = new List<String>();
        assetUrls.add(wrapper.credUrl);
        assetUrls.add(wrapper.nameUrl);
        assetUrls.add(wrapper.transUrl);
        List<Asset> assetsToUpdate = new List<Asset>();
        List<Asset> currentAssets = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN:assetUrls AND Azure_Storage_URL__c != null WITH SECURITY_ENFORCED];       
        for(Asset ast:currentAssets){
            ast.Uploaded_by_applicant__c = true;
            if(ast.Azure_Storage_URL__c == wrapper.credUrl){
                ast.Name_on_Document__c = wrapper.nameOnDoc;
                ast.Name_on_Document_is_Different__c = wrapper.nameDifferent;
                ast.Document_is_not_in_English__c = wrapper.translationRequired;
                ast.Contact_Association_Type_Staging__c = catsRecord.Id;
                assetsToUpdate.add(ast);
            }
            if(ast.Azure_Storage_URL__c == wrapper.transUrl){
                ast.Contact_Association_Type_Staging__c = catsRecord.Id;
                assetsToUpdate.add(ast);
            }
            if(ast.Azure_Storage_URL__c == wrapper.nameUrl){
                ast.Contact_Association_Type_Staging__c = catsRecord.Id;
                assetsToUpdate.add(ast);
            }
        }
        if(!assetsToUpdate.isEmpty()){
            UPDATE assetsToUpdate;
        }
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();                
        Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_VERIFICATION WITH SECURITY_ENFORCED];
        Case caseObj = new case();
        caseObj.ContactId = contactId;
        caseObj.OwnerId = g.Id;
        caseObj.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
        caseObj.RecordTypeId = cvRecordTypeId;
		caseObj.Service__c = evrWrap.program;
        caseObj.Entity__c = wrapper.entityId;
        caseObj.Document_Type__c = catsRecord.Credential_Type__c;
        caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrap.regOrgDNK;
        caseObj.Document_type_selected_by_applicant__c = catsRecord.Credential_Type__c;
        caseObj.Courier_Required__c = catsRecord.Courier_service_for_an_additional_fee__c;
        if(Schema.sObjectType.Case.isCreateable()){
            insert caseObj;
        }         
        createCredentialHlpr(caseObj,catsRecord,currentAssets);                   
        createCredentialEVRHlpr(evrValues,caseObj);     
        return true;
    }

    public static void createCredentialHlpr(Case caseObj,Contact_Association_Type_Staging__c catsRecord,List<Asset> currentAssets){
        catsRecord.Case__c = caseObj.Id;        
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
            UPDATE catsRecord;
        }
        List<Asset> assUpdateList = new List<Asset>();
        for(Asset astToUpd:currentAssets){
            astToUpd.case__c = caseObj.Id;
            assUpdateList.add(astToUpd);
        }
        if(!assUpdateList.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
            UPDATE assUpdateList;
        }            
    }

    public static void createCredentialEVRHlpr(String evrValues, Case cse){   
        EVRWrapper evrWrap = (EVRWrapper)JSON.deserialize(evrValues, EVRWrapper.class);
        List<Account> entityList = new List<Account>();
        if(evrWrap.program == 'EPIC'){
            Id contactId = AppforCertHelper.retrieveCurrentContactId();           
            Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
            Id accountId = [Select AccountId from Contact where Id =: contactId WITH SECURITY_ENFORCED].AccountId;
            
            if(evrWrap.authId != null){
                entityList = [SELECT Id, Name, BillingAddress FROM Account 
                              WHERE Id=:evrWrap.authId WITH SECURITY_ENFORCED];
            }            
            Case evr = new Case();
            evr.RecordTypeId = Constants.EPICVERREPORTREQRTID;
            evr.ContactId = contactId;
            evr.AccountId = accountId;
            evr.Internal_Status__c = Constants.CASE_STATUS_NEW;
            evr.Secondary_Parent_Case__c = cse.Id;
            evr.Reference_Number__c = evrWrap.ref;
            evr.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrap.regOrgDNK;
            evr.Service_Name__c = serviceId;
            evr.Document_Type__c = cse.Document_Type__c;
            if(evrWrap.regOrgDNK){
                evr.Entity__c = null;
                evr.Reference_Number__c = null;
            }else{
                evr.Entity__c = evrWrap.authId;
                evr.Reference_Number__c = evrWrap.ref;
                evr.Payment_History__c = Constants.CASE_PAYMENT_HISTORY_FREE_REPORT;
                evr.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_REQUESTED ;
                evr.Report_Type__c = Constants.CASE_REPORT_TYPE_VOLUME_ENTITY;
                if(entityList.size() > 0){
                    evr.EPIC_Report_Entity__c = entityList[0].Name;
                    if(entityList[0].BillingAddress != null){
                        evr.EPIC_Report_Entity_Address__c = getAddressValue(entityList[0].BillingAddress);
                    }
                    evr.Issuing_Entity__c = cse.Entity__c;
                }                
            }
            if(Schema.sObjectType.Case.isCreateable() && !evrWrap.regOrgDNK){
                INSERT evr;
            }
        }
    }

    public static String getAddressValue(Address inputAddress){
        String[] addr = new String[]{
            inputAddress.getStreet(), inputAddress.getCity(), inputAddress.getState(), inputAddress.getPostalCode(), inputAddress.getCountry()
          };                  
        for(Integer i = 4; i >= 0; i--){
           if(addr[i] == null){
            addr.remove(i);
           }
        }                  
        String addressValue = String.join(addr, ', ');
        return addressValue;
    }

    public class EVRWrapper{
        @auraenabled public string program {get; set;}
		@auraenabled public string authId {get; set;}
		@auraenabled public string ref {get; set;}
        @auraenabled public Boolean regOrgDNK {get; set;}        
    }
    @AuraEnabled(Cacheable = false)
    public static List<Account> searchRegOrgEpicReport(String searchKey, String issuedEntity){
        List<Id> accountIdList = new List<Id>();
        List<Id> accountsList = new List<Id>();
        List<Account> accountListReturned = new List<Account>();
        if(String.isnotBlank(searchKey)){
            String keyValue = '%' + searchKey + '%';
            List<Account> accountList = new List<Account>([Select Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Parent_Authority__c, EPIC_Client_Special_Instructions_Languag__c, Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c, Parent_Authority__r.Use_same_instruction_for_child_entities__c From Account Where Name LIKE :keyValue AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY AND Id !=: issuedEntity WITH SECURITY_ENFORCED]);
            for(Account acc:accountList){
                accountsList.add(acc.Id);
                if(String.isNotBlank(acc.Parent_Authority__c)){
                    accountsList.add(acc.Parent_Authority__c);
                }
            }
            List<Account2Service__c> acc2SerList =  new List<Account2Service__c>([Select id, Account__c from Account2Service__c where Active__c = True AND Service__r.Name = :Constants.EPIC_SERVICENAME AND Account__c in :accountsList AND Account__c != null WITH SECURITY_ENFORCED]);
            for(Account2Service__c acct: acc2SerList){
                accountIdList.add(acct.Account__c);
            }
            for(Account acc:accountList){
                if(accountIdList.contains(acc.Id) || accountIdList.contains(acc.Parent_Authority__c)){
                    accountListReturned.add(acc);
                }
            }
        }
        return accountListReturned;
    }
    public class DateCheckWrapper{
        @auraenabled public Date degIssueDt {get; set;}
        @auraenabled public String gradYrDt {get; set;}
        @auraenabled public String degExpYrDt {get; set;}
        @auraenabled public Date attStDt {get; set;}
        @auraenabled public Date attEndDt {get; set;}
        @auraenabled public Date prStDt {get; set;}
        @auraenabled public Date prEndDt {get; set;}
        @auraenabled public Date issDt {get; set;}
        @auraenabled public Date expDt {get; set;}        
    }
    @AuraEnabled(Cacheable = true)
    public static Map<String,String> dtChecker(String dtValues){
        Map<String,String> returnVal = new Map<String,String>();
        DateCheckWrapper valCheckWrap = (DateCheckWrapper)JSON.deserialize(dtValues, DateCheckWrapper.class);
        if(valCheckWrap.attStDt != null && valCheckWrap.attEndDt != null && (valCheckWrap.attStDt > valCheckWrap.attEndDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_ATTENDANCE_END_DATE,Constants.EPIC_ATT_ST_END_DATE);
        }
        if(valCheckWrap.attStDt != null && valCheckWrap.degIssueDt != null && (valCheckWrap.attStDt > valCheckWrap.degIssueDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_DEGREE_ISSUE_DATE,Constants.EPIC_ATT_ST_DEG_ISS_DATE);
        }
        if(valCheckWrap.degIssueDt != null && valCheckWrap.attEndDt != null && (valCheckWrap.attEndDt > valCheckWrap.degIssueDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_DEGREE_ISSUE_DATE,Constants.EPIC_ATT_END_DEG_ISS_DATE);
        }
        if(valCheckWrap.prStDt != null && valCheckWrap.prEndDt != null && (valCheckWrap.prStDt > valCheckWrap.prEndDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_PROGRAM_END_DATE,Constants.EPIC_PRG_ST_END_DATE);
        }
        if(valCheckWrap.prStDt != null && valCheckWrap.issDt != null && (valCheckWrap.prStDt > valCheckWrap.issDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_ISSUE_DATE,Constants.EPIC_PRG_ST_ISS_DATE);
        }
        if(valCheckWrap.prEndDt != null && valCheckWrap.issDt != null && (valCheckWrap.prEndDt > valCheckWrap.issDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_ISSUE_DATE,Constants.EPIC_PRG_END_ISS_DATE);
        }    
        returnVal = dtCheckerCogIssue(dtValues,returnVal);
        returnVal = dtCheckerCogIssueSec(dtValues,returnVal);
        returnVal = dtCheckerCogAttDate(dtValues,returnVal);        
        return returnVal;
    }
    public static Map<String,String> dtCheckerCogIssue(String dtValues,Map<String,String> returnVal){
        DateCheckWrapper valCheckWrap = (DateCheckWrapper)JSON.deserialize(dtValues, DateCheckWrapper.class);
        if(valCheckWrap.issDt != null){
            returnVal = dtCheckerCogIssueDate(dtValues,returnVal);
		}
        if(valCheckWrap.degExpYrDt != null){
            String degExpYrDtLen  = String.valueOf(valCheckWrap.degExpYrDt);
            if(degExpYrDtLen.length() < 4){
                returnVal.put(Constants.DOCTYPFIELDMAP_DEG_EXP_YEAR,Constants.EPIC_GRD_FRMT);
            }     
            else if(valCheckWrap.gradYrDt != null && valCheckWrap.degExpYrDt != null){
                Integer deg = Integer.valueOf(valCheckWrap.degExpYrDt);
                Integer grd = Integer.valueOf(valCheckWrap.gradYrDt);
                if(deg < grd){
                    returnVal.put(Constants.DOCTYPFIELDMAP_DEG_EXP_YEAR,Constants.EPIC_EXP_DEG_GRD_DATE);
                }
            }
        }	
        return returnVal;
    }
    public static Map<String,String> dtCheckerCogIssueSec(String dtValues,Map<String,String> returnVal){
        DateCheckWrapper valCheckWrap = (DateCheckWrapper)JSON.deserialize(dtValues, DateCheckWrapper.class);        
        if(valCheckWrap.gradYrDt != null){
            String grdLen  = String.valueOf(valCheckWrap.gradYrDt);
            if(grdLen.length() < 4){
                returnVal.put(Constants.DOCTYPFIELDMAP_GRADUATION_YEAR,Constants.EPIC_GRD_FRMT);
            }     
            else if(valCheckWrap.gradYrDt != null && valCheckWrap.attStDt != null){
                Integer attYr = valCheckWrap.attStDt.year();
                Integer grd = Integer.valueOf(valCheckWrap.gradYrDt);
                if(grd < attYr){
                    returnVal.put(Constants.DOCTYPFIELDMAP_GRADUATION_YEAR,Constants.EPIC_GRD_ATT_ST_DATE);
                }
            }
            else if(valCheckWrap.gradYrDt != null && valCheckWrap.attEndDt != null){
                Integer attYr = valCheckWrap.attEndDt.year();
                Integer grd = Integer.valueOf(valCheckWrap.gradYrDt);
                returnVal = dtCheckerCogIssueGrYr(attYr,grd,returnVal);
            }
        }
        return returnVal;
    }
    public static Map<String,String> dtCheckerCogIssueGrYr(Integer attYr,Integer grd,Map<String,String> returnVal){
        if(grd < attYr){
            returnVal.put(Constants.DOCTYPFIELDMAP_GRADUATION_YEAR,Constants.EPIC_GRD_ATT_END_DATE);
        }
        return returnVal;
    }
    public static Map<String,String> dtCheckerCogIssueDate(String dtValues,Map<String,String> returnVal){
        DateCheckWrapper valCheckWrap = (DateCheckWrapper)JSON.deserialize(dtValues, DateCheckWrapper.class);
        if(valCheckWrap.issDt > System.Today()){
            returnVal.put(Constants.DOCTYPFIELDMAP_ISSUE_DATE,Constants.EPIC_ISS_DATE_FUT_DATE);
        }
        else if(valCheckWrap.expDt != null && valCheckWrap.issDt != null && (valCheckWrap.expDt < valCheckWrap.issDt)){
            returnVal.put(Constants.DOCTYPFIELDMAP_EXPIRATION_DATE,Constants.EPIC_EXP_ISS_DATE);
        }
        return returnVal;
    }
    public static Map<String,String> dtCheckerCogAttDate(String dtValues,Map<String,String> returnVal){
        DateCheckWrapper valCheckWrap = (DateCheckWrapper)JSON.deserialize(dtValues, DateCheckWrapper.class);
        if(valCheckWrap.attStDt != null && valCheckWrap.attStDt > System.Today()){
            returnVal.put(Constants.DOCTYPFIELDMAP_ATTENDANCE_START_DATE,Constants.EPIC_ATT_ST_DATE_FUT_DATE);
		}
        return returnVal;
    }
    // method to fetch epic report request details
	@AuraEnabled
	public static Case getEvrFieldValues(String catsId){
        Id caseId =[Select case__c From Contact_Association_Type_Staging__c Where id=: catsId WITH SECURITY_ENFORCED].Case__c;
        List<Case> evrList = [SELECT Id, Entity__c, Reference_Number__c, Do_Not_Know_Orgs_to_send_EPIC_Reports__c, Entity__r.Name, Entity__r.BillingStreet, Entity__r.BillingCity, Entity__r.BillingState, Entity__r.BillingCountry, Entity__r.BillingPostalCode, Entity__r.EPIC_Client_Special_Instructions_Languag__c, Entity__r.Parent_Authority__c, Entity__r.Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c, Entity__r.Parent_Authority__r.Use_same_instruction_for_child_entities__c FROM Case WHERE  Secondary_Parent_Case__c =: caseId WITH SECURITY_ENFORCED];
        if(!evrList.isEmpty()){
            return evrList[0];
        }
        return null;
    }
    // method to update epic report request details
    @AuraEnabled
    public static Boolean updateEvr(String evrWrapString, String evrId, String cvCaseId){
        EVRWrapper evrWrap = (EVRWrapper)JSON.deserialize(evrWrapString, EVRWrapper.class);
        List<Case> evReport = [SELECT Id FROM Case WHERE Id =: evrId WITH SECURITY_ENFORCED];
        List<Case> cvCase = [SELECT Id,Document_Type__c,ContactId,AccountId,Entity__c FROM Case WHERE Id =: cvCaseId WITH SECURITY_ENFORCED];
        Id serviceId = [SELECT Id FROM Service__c WHERE Name = :Constants.EPIC_SERVICENAME LIMIT 1].Id;
        
        if(evrWrap.program == 'EPIC' && String.isNotBlank(evrId)){
            Case  evr = new Case();
            evr.Id = evReport[0].Id;
            evr.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrap.regOrgDNK;
            if(evrWrap.regOrgDNK){
                evr.Entity__c = null;
                evr.Reference_Number__c = null;
                evr.Payment_History__c = null;
                evr.EPIC_Report_Status__c = null;
                evr.Report_Type__c = null;
            }else{
                evr.Entity__c = evrWrap.authId;
                evr.Reference_Number__c = evrWrap.ref;
                evr.Payment_History__c = Constants.CASE_PAYMENT_HISTORY_FREE_REPORT;
                evr.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_REQUESTED ;
                evr.Report_Type__c = Constants.CASE_REPORT_TYPE_VOLUME_ENTITY;
            }
            if(Schema.sObjectType.Case.isUpdateable()){
                UPDATE evr;
            }
        }else if(evrWrap.program == 'EPIC' && String.isNotBlank(cvCaseId)){//No evrId - create a new evr case- US#20936
            Case  evr = new Case();
            List<Account> entityList = new List<Account>();
            evr.recordTypeId = Constants.EPICVERREPORTREQRTID;
            evr.Internal_Status__c = Constants.CASE_STATUS_NEW;
            evr.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = evrWrap.regOrgDNK;
            evr.Secondary_Parent_Case__c = cvCase[0].Id;
            evr.Document_Type__c = cvCase[0].Document_Type__c;
            evr.ContactId = cvCase[0].ContactId;
            evr.AccountId = cvCase[0].AccountId;
            evr.Service_Name__c = serviceId;
            if(evrWrap.authId != null){
                entityList = [SELECT Id, Name, BillingAddress FROM Account 
                              WHERE Id=:evrWrap.authId WITH SECURITY_ENFORCED];
            }
            if(evrWrap.regOrgDNK){
                evr.Entity__c = null;
                evr.Reference_Number__c = null;
            }else{
                evr.Entity__c = evrWrap.authId;
                evr.Reference_Number__c = evrWrap.ref;
                evr.Payment_History__c = Constants.CASE_PAYMENT_HISTORY_FREE_REPORT;
                evr.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_REQUESTED ;
                evr.Report_Type__c = Constants.CASE_REPORT_TYPE_VOLUME_ENTITY;
                if(entityList.size() > 0){
                    evr.EPIC_Report_Entity__c = entityList[0].Name;
                    if(entityList[0].BillingAddress != null){
                        evr.EPIC_Report_Entity_Address__c = getAddressValue(entityList[0].BillingAddress);
                    }
                    evr.Issuing_Entity__c = cvCase[0].Entity__c;
                }
            }
            if(Schema.sObjectType.Case.isCreateable() && !evrWrap.regOrgDNK){
                INSERT evr;
            }
        }
        return true;
    }  
    @AuraEnabled
    public static List<Contact_Association_Type_Staging__c> getCredDocumentTypes(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Contact_Association_Type_Staging__c> catStagList = [Select Id, Case__c,Case__r.Internal_Status__c, Credential_Type__c, Account_Name__c, Account__r.name, Degree_Issue_Date__c, Issue_Date__c, Degree_Title__c,Requested_to_be_sent_to_ECFMG__c,Issued_in_the_last_90_days__c,
                                                                 Title__c,(SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND Asset.Type__c !=: 'Credential Sample' AND Asset.Type__c !=: 'Format' ORDER BY CreatedDate ASC, Type__c ASC),
                                                                 (SELECT Authority__c,Authority__r.Name,Regulatory_Org_Do_Not_Know__c FROM EPIC_Verification_Reports__r)
                                                                 FROM Contact_Association_Type_Staging__c where Case__r.RecordTypeId = :caseRecTypeId AND
                                                                 RecordTypeId = :catRecTypeId AND Contact__c = :contactId WITH SECURITY_ENFORCED];
        return catStagList;
    }
    @AuraEnabled(cacheable = false)
    public static Map<String,Map<String,String>> getCredProgDocTypeMap(List<String> docName,String programName){
        Map<String,Map<String,String>> retValFinal = new Map<String,Map<String,String>>();
        Map<String,String> returnVal = new Map<String,String>();
        List<Program_Document_type_Mapping__mdt> docList = [SELECT Id,DeveloperName,Program__c,Credential_Type__c,Label,MasterLabel 
                        FROM Program_Document_type_Mapping__mdt WHERE Credential_Type__c =: docName AND Program__c =: programName WITH SECURITY_ENFORCED];
        if(!docList.isEmpty()){
            List<Document_Type_Field_Mapping__mdt> proDocMapList = [SELECT Id,DeveloperName,Field_API_Name__c,Field_Label__c,Field_Order__c,Program_Document_Type_Mapping__c,Label,MasterLabel,Program_Document_Type_Mapping__r.Credential_Type__c 
                        FROM Document_Type_Field_Mapping__mdt WHERE Program_Document_Type_Mapping__c =: docList WITH SECURITY_ENFORCED ORDER BY Field_Order__c ASC];
            if(!proDocMapList.isEmpty()){
                for(Document_Type_Field_Mapping__mdt proDoc : proDocMapList){
                    if(retValFinal.containsKey(proDoc.Program_Document_Type_Mapping__r.Credential_Type__c)){
                        retValFinal.get(proDoc.Program_Document_Type_Mapping__r.Credential_Type__c).put(proDoc.Field_API_Name__c,proDoc.Field_Label__c);
                    }
                    else{
                        returnVal = new Map<String,String>();
                        returnVal.put(proDoc.Field_API_Name__c,proDoc.Field_Label__c);
                        retValFinal.put(proDoc.Program_Document_Type_Mapping__r.Credential_Type__c,returnVal);
                    }
                }
            }
        }
        return retValFinal;
    }
    @InvocableMethod(label='Delete Case and Cats' description='Delete the case and its related data if the Internal_Status__c is not changed from pending submission.')
    public static void deleteCaseAndCats(List<Id> caseId){
        List<Contact_Association_Type_Staging__c> catsList = [Select Id, Credential_Type__c, Account_Name__c, Account__r.name, Degree_Issue_Date__c, Issue_Date__c, Degree_Title__c,
                                                                 Title__c,(SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY  CreatedDate ASC, Type__c ASC),
                                                                 (SELECT Authority__c,Authority__r.Name,Regulatory_Org_Do_Not_Know__c FROM EPIC_Verification_Reports__r)
                                                                 FROM Contact_Association_Type_Staging__c where Case__r.Id = :caseId[0] AND Case__r.Internal_Status__c = :Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED];
        List<Asset> assetsToUpdateList = new List<Asset>();
        List<RecordType> recTypeId = new List<RecordType>();
        List<Id> catsIdList = new List<Id>();
        List<Case> casesToDelete = new List<Case>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            recTypeId = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        RecordType assetMarkedForDeletionRT = recTypeId[0];
        for(Contact_Association_Type_Staging__c eachCats: catsList){
            for(Asset a: eachCats.Assets__r){
                a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.Contact_Association_Type_Staging__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
                assetsToUpdateList.add(a);
            }
            catsIdList.add(eachCats.Id);
        }
        if(!assetsToUpdateList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            UPDATE assetsToUpdateList;
        }
        List<Case> epicVerRepListToDelete = new List<Case>();
        epicVerRepListToDelete = [SELECT Id FROM Case WHERE Secondary_Parent_Case__c =: caseId[0] WITH SECURITY_ENFORCED];
        Id usrId = UserInfo.getUserId();
        for(Case epicCase : epicVerRepListToDelete){
            epicCase.OwnerId = usrId;
            casesToDelete.add(epicCase);
        }
        if(Contact_Association_Type_Staging__c.SObjectType.getDescribe().isDeletable() && !catsList.isEmpty()){
            Delete catsList;
        }
        Case credVerCase = [SELECT Id,OwnerId FROM Case WHERE Id =:caseId[0] WITH SECURITY_ENFORCED];
        credVerCase.OwnerId = usrId;
        casesToDelete.add(credVerCase);
        if(Case.SObjectType.getDescribe().isUpdateable() && !casesToDelete.isEmpty()){       
            UPDATE casesToDelete;
            Delete casesToDelete; //CRUD permission not checked as Community user cannot be given the delete permission for Case Object.
        }
    }
    @AuraEnabled(Cacheable = true)
    public static List<Account> getEntities(){
        try{
            List<Account> accts = new List<Account>();
            Id entityRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
            accts = [SELECT Id, Name FROM Account WHERE RecordTypeId =: entityRecId WITH SECURITY_ENFORCED];
            return accts;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean createCATRec(String fieldvals, Id caseId, String nameOnDoc){
        try{
            Case extSubCase = [SELECT Id, ContactId, Document_Type__c FROM Case WHERE Id =: caseId];
            Id contactId = extSubCase.ContactId;
            Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
            Contact_Association_Type__c catRecord = (Contact_Association_Type__c) JSON.deserialize(fieldvals, Contact_Association_Type__c.class);
            catRecord.Contact__c = contactId;
            catRecord.Name_on_Document__c = nameOnDoc;
            catRecord.Case__c = caseId;
            catRecord.RecordtypeId = catRecTypeId;
            if(Schema.sObjectType.Contact_Association_Type_Staging__c.isCreateable()){
                INSERT catRecord;
            }
            extSubCase.Document_Type__c = catRecord.Credential_Type__c;
            UPDATE extSubCase;
            return true;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        } 
    }
    @AuraEnabled
    public static Boolean updateExtSubCase(Id caseId, Id entityId, Boolean verform){
        try{
            String verFormConfigId = EntityServiceRequestSharingDisabled.getDocConfigRecordId(Constants.DOCCONFIG_EPIC_EXTRACTION_VERIFICATION_FORM);
            Case extSubcase = [SELECT Id FROM Case WHERE Id =: caseId];
            List<Contact_Association_Type__c> cstDoc = new List<Contact_Association_Type__c>();
            cstDoc = [SELECT Id,Credential_Type__c FROM Contact_Association_Type__c WHERE Case__c =: caseId WITH SECURITY_ENFORCED];
            if (cstDoc.size()>0){
                extSubcase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
                extSubcase.Entity__c = entityId;
                extSubcase.Document_Type__c = cstDoc[0].Credential_Type__c;
                extSubcase.Document_type_selected_by_applicant__c = cstDoc[0].Credential_Type__c;
                if(Schema.sObjectType.Case.isUpdateable()){
                    UPDATE extSubCase;
                }
                List<Asset> asst = new List<Asset>();
                for(Asset a : [SELECT Id,RecordTypeId,Name,Type__c FROM ASSET WHERE Case__c =: caseId AND 
                            RecordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND Type__c='Verified Credential' 
                            WITH SECURITY_ENFORCED]){
                                a.Name = 'Verified '+cstDoc[0].Credential_Type__c;
                                a.Type__c = cstDoc[0].Credential_Type__c;
                                asst.add(a);
                }
                if(Schema.sObjectType.Asset.isUpdateable() && !asst.isEmpty()){
                    UPDATE asst;
                }
                if(verform){
                    PDFButlerCallout calloutClassVerificationForm = new PDFButlerCallout(verFormConfigId, caseId);
                    System.enqueueJob(calloutClassVerificationForm);
                }
            }
            return true;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        } 
    }
    @AuraEnabled
    public static String getEpicExtSubCaseStatus(Id caseId){
        try{
            Case cs = [SELECT Id, Internal_Status__c FROM Case WHERE Id =: caseId];
            String caseStatus = cs.Internal_Status__c;
            return caseStatus;
        }
        catch(DmlException e){
            throw new ControllerException(e.getMessage());
        } 
    }
}