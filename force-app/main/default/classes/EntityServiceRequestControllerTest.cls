//Test Class for EntityServiceRequestController
@isTest
public class EntityServiceRequestControllerTest{
    public static final String ASSET_NAME = 'Test Asset';
    public static final String DIPLOMA_DOCUMENT = 'DIPLOMA DOCUMENT';
    public static final String UNITED_STATES = 'United States';
    public static final String AMERICA_LA = 'America/Los_Angeles';
    @testSetup static void setup(){
        EntityServiceRequestTestFactory.servicePageSetup();
    }
    public static testMethod void findRecordstest(){ 
        string searchKey = 'Test Account';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Test Account',School__c = true, BillingCountry= 'Canada', BillingState='Alberta', BillingPostalCode='560066');
        insert acct;
        Entity_Type__c entityType = new Entity_Type__c(Entity_Type__c = 'School');
        insert entityType;
        List<account> acctList = new List<Account>();
        acctList.add(acct);
        List<Service__c> newServList = new List<Service__c>([Select id,name from service__c where name= 'EPIC' or name = 'NSA']);
        Map<string,string> servMap = new Map<string,string>();
        servMap.put(newServList[0].Name,string.valueof(newServList[0].Id));
        servMap.put(newServList[1].Name,string.valueof(newServList[1].Id));
        string finalSelectedRecorId = string.valueOf(acct.Id);
        test.startTest();
        //EntityServiceRequestController.findRecords(searchKey);
        //system.assertEquals(acctList[0].Id, EntityServiceRequestController.findRecords(searchKey)[0].Id,'Account is not found in the list');
        String S = EntityServiceRequestController.getEntityMetadataId();
        //system.assertEquals(servMap, EntityServiceRequestController.getEntityServices(finalSelectedRecorId),'No services found in the entity');
        test.stopTest();
    }
    public static testMethod void insertContactandCaseEntityRqeuesttest(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Test Account1',School__c = true,BillingCountry= 'India');
        insert acct;
        System.assert(acct.id != null, 'Failed to create account');
        string acctid = string.valueOf(acct.id);
        Service__c serv = new Service__c(Name = 'Performance Data',School__c = true);
        insert serv;
        System.assert(serv.id != null, 'Failed to create service');
        string servId = string.valueOf(serv.id);
        Map<String, Object> theObj = new Map<String, Object>();
        theObj.put('entityLastName','howdy');
        theObj.put('restOfName','hey');
        theObj.put('generationalSuffix', 'Jr');
        theObj.put('dateOfBirth', '1968-5-1');
        theObj.put('emailAddress', 'hhjk@gmail.com');
        theObj.put('phoneNumber', '825');
        theObj.put('department', 'department');
        theObj.put('jobTitle','jobTitle');
        theObj.put('finalSelectedRecordId', acctid);
        theObj.put('serviceValue', servId);
        theObj.put('countryVal', 'Azerbaijan');
        theObj.put('onlyOneName',false);
        string jsonString = JSON.serialize(theObj);
        Map<String, Object> theObjShareInfoNo = new Map<String, Object>();
        theObjShareInfoNo.put('entityLastName','bonjour');
        theObjShareInfoNo.put('restOfName','hey');
        theObjShareInfoNo.put('generationalSuffix', 'Jr');
        theObjShareInfoNo.put('dateOfBirth', '1968-6-1');
        theObjShareInfoNo.put('emailAddress', 'hbr@gmail.com');
        theObjShareInfoNo.put('phoneNumber', '825');
        theObjShareInfoNo.put('department', 'department');
        theObjShareInfoNo.put('jobTitle','jobTitle');
        theObjShareInfoNo.put('finalSelectedRecordId', acctid);
        theObjShareInfoNo.put('serviceValue',servId);
        theObjShareInfoNo.put('countryVal', 'Albania');
        theObjShareInfoNo.put('onlyOneName',true);
        string jsonStringShareInfoNo = JSON.serialize(theObjShareInfoNo);
        Map<String, Object> theObjException = new Map<String, Object>();
        theObjException.put('entityLastName','hi');
        theObjException.put('restOfName','hey');
        theObjException.put('generationalSuffix', 'Jr');
        theObjException.put('dateOfBirth', '1988-4-1');
        theObjException.put('emailAddress', 'jjecom@j.com');
        theObjException.put('phoneNumber', '825');
        theObjException.put('department', 'department');
        theObjException.put('jobTitle','jobTitle');
        theObjException.put('finalSelectedRecordId', acctid);
        theObjException.put('serviceValue', serv.Id);
        theObjException.put('countryVal', 'Albania');
        theObjException.put('onlyOneName',false);
        String selectedRecordId =  acctid;
        String lastName = 'hi';
        String restName = 'hey';
        String phoneNo = '825';
        String emailAdd= 'jjecom@j.com';
        String jobTit= 'jobTitle';
        String serviceVal= serv.Id;
        String depart = 'department';
        String countryValue= 'Albania';
        String generationSuffix= 'Jr';
        Date dob= system.today() - 12563;
        Boolean legalNameOnlyOneName= false;
        String caseNum = '';
        test.startTest();
        EntityServiceRequestControllerHelper.InsertContactandCaseEntityRqeuestWrapper wrp = new EntityServiceRequestControllerHelper.InsertContactandCaseEntityRqeuestWrapper(
        selectedRecordId,lastName, restName, phoneNo,emailAdd, jobTit, serviceVal, depart, countryValue, generationSuffix, dob, legalNameOnlyOneName);
        String inputString = JSON.serialize(wrp);
        EntityServiceRequestController.insertContactandCaseEntityRqeuest(inputString);
        casenum = EntityServiceRequestController.insertContactandCaseEntityRqeuest(jsonString);
        EntityServiceRequestController.insertContactandCaseEntityRqeuest(jsonStringShareInfoNo);
        System.assert(casenum != '', 'Case should be created');
        test.stopTest();
    }
    public static testMethod void testgetAvailableServicesForEntity(){       
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Contact con = [Select id, AccountId,Account.Account_Type__c from Contact where ID=:testUser.contactId]; 
        System.runAs(testUser){
            List< EntityServiceRequestControllerHelper.ServiceAccessWrapper > getAvailServicesList = new List< EntityServiceRequestControllerHelper.ServiceAccessWrapper >();
            Test.startTest();
            getAvailServicesList = EntityServiceRequestController.getAvailableServicesForEntity(String.valueOf(con.AccountId));
            Boolean isEURCaseCreated = EntityServiceRequestController.createEntityUserRequest(getAvailServicesList[0].serviceName, String.valueOf(con.AccountId));
            System.assertEquals(isEURCaseCreated, true,'Criteria didnot meet the requirement');
            Test.stopTest();
        }
    }
    public static testMethod void testgetListofContactsEntity(){       
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Contact con = [Select Id,AccountId from Contact where Id=: testUser.ContactId];
        System.assert(testUser.ContactId !=null,'Contact does not have account');
        System.runAs(testUser){
            Map<Id,string> listofContacts = new Map<Id,string>();
            Test.startTest();
            listofContacts = EntityServiceRequestController.getListOfContactsInEntity(String.Valueof(con.AccountId));
            Set<Id> contactId = new Set<Id>();
            contactId = listofContacts.keySet();
            string firstelement =new List<Id>(contactId).get(0);
            EntityServiceRequestController.getContactDetail(firstelement);
            EntityServiceRequestController.getServicesAndRole(firstelement, String.Valueof(con.AccountId));
            Test.stopTest();
        }
    }
    public static testMethod void testGetCaseManageRequestDetail(){
        // User
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Test.startTest();
        System.runAs(testUser){
            // Contact
        	Contact con = [Select id, AccountId from Contact where ID=:testUser.contactId]; 
            // Create new service
            Service__c serv = new Service__c(Name = 'Performance Data 1', School__c = true);
            insert serv;
            //create new case
            Id idEntUsrReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            Case caseRecord = new Case(
                AccountId		=	con.AccountId,
                ContactId		=	con.Id,
                Service_Name__c	=	serv.Id,
                Internal_Status__c			=	'New',
                RecordTypeId	=	idEntUsrReqRecordTypeId
            );
            insert caseRecord;
           	System.assert(EntityServiceRequestController.getCaseManageRequestDetail(caseRecord.ID) != null, 'Value should be returned');
        }  
        Test.stopTest();
    }
   	public static testMethod void testSignatuareUploadNo(){
        // User
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Test.startTest();
        System.runAs(testUser){
            // Contact
        	Contact con = [Select id, AccountId from Contact where ID=:testUser.contactId]; 
            // create service
            Service__c serv = new Service__c(Name = 'Performance Data 2', School__c = true);
            insert serv;
            //create new case
            Id idEntUsrReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            Case caseRecord = new Case(
                AccountId		=	con.AccountId,
                ContactId		=	con.Id,
                Service_Name__c	=	serv.Id,
                Internal_Status__c			=	'New',
                RecordTypeId	=	idEntUsrReqRecordTypeId
            );
            insert caseRecord;
            EntityServiceRequestController.checkSignatureAssetExist(caseRecord.ContactId);
        	String jsonStringFieldVal = '{"caseId":"'+caseRecord.Id+'","signatureUploadStatus":"No","caseStatus":"","contentDocumentId":""}';
        	System.assert(EntityServiceRequestController.manageServiceRequestsSignature(jsonStringFieldVal) == TRUE, 'Returned value false');
        }  
        Test.stopTest();
    }
    public static testMethod void testSignatuareUploadYesUploadLater(){
        // User
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Test.startTest();
        System.runAs(testUser){
            // Contact
        	Contact con = [Select id, AccountId from Contact where ID=:testUser.contactId]; 
            // create service
            Service__c serv = new Service__c(Name = 'Performance Data 3', School__c = true);
            insert serv;
            //create new case
            Id idEntUsrReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            Case caseRecord = new Case(
                AccountId		=	con.AccountId,
                ContactId		=	con.Id,
                Service_Name__c	=	serv.Id,
                Internal_Status__c			=	'New',
                RecordTypeId	=	idEntUsrReqRecordTypeId
            );
            insert caseRecord;
            //Create and Insert Asset
            Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();      
            Asset asst = new Asset(
                Name 			= 	Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
                recordTypeId 	= 	assetRecordTypeId,
                ContactId 		= 	testUser.ContactId,      
                type__c			= 	Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE
            );
            insert asst;
        	EntityServiceRequestController.checkSignatureAssetExist(caseRecord.ContactId);
        	String jsonStringFieldVal = '{"caseId":"'+caseRecord.Id+'","signatureUploadStatus":"Yes","caseStatus":"'+Constants.CASE_STATUS_APPROVED+'","contentDocumentId":""}';
        	System.assert(EntityServiceRequestController.manageServiceRequestsSignature(jsonStringFieldVal) == TRUE, 'Returned value is false');
        }  
        Test.stopTest();
    }
    public static testMethod void testDeleteDocumentSignatuareUpload(){
        Test.startTest();        
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];        
        	System.assert(EntityServiceRequestController.deleteSignatureContentDocument(documents[0].Id) == TRUE, 'Returned value is false');
        Test.stopTest();
    }
    public static testMethod void testSignatuareUploadYesUploaded(){
        // User
        User testUser = [Select id, contactId from User where alias='second'];
        Test.startTest(); 
        	// Contact
        	Contact con = [Select id, AccountId from Contact where ID=:testUser.contactId];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]; 
        	// Create new service
            Service__c serv = new Service__c(Name='Performance Data 4', School__c=true,Signature_Required__c=true);
            insert serv;
        	//create new case
            Id idEntUsrReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            Case caseRecord = new Case(
                AccountId		=	con.AccountId,
                ContactId		=	con.Id,
                Service_Name__c	=	serv.Id,
                Internal_Status__c			=	'New',
                RecordTypeId	=	idEntUsrReqRecordTypeId
            );
            insert caseRecord;
            String assetStatus = 'In Progress';
        	EntityServiceRequestController.getDocumentbyId(documents[0].Id); 
        	EntityServiceRequestController.getDocumentByAssetType(caseRecord.ContactId, assetStatus);
            EntityServiceRequestController.createAsset(documents[0].Id, caseRecord.Id, Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM, con.Id);    
			System.assert(EntityServiceRequestController.updateStatusSignedSignatureFormAsset(caseRecord.ContactId) == true, 'Returned false');        
        Test.stopTest();
    }
    public static testMethod void testcheckAssetSignatureInContact(){
        User testUser = [Select id, contactId from User where alias='second'];
        Contact con2 = [Select id from Contact where FirstName = 'FirstCon2'];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]; 
        Test.startTest();
        EntityServiceRequestController.deleteOrpahnedAssetInContact(string.valueof(testUser.contactId));
        system.assertEquals('True', EntityServiceRequestController.checkAssetSignatureInContact(string.valueof(testUser.contactId)),'No signature found in the asset');
        system.assertEquals('False', EntityServiceRequestController.checkAssetSignatureInContact(string.valueof(con2.Id)),'Signature found in the asset');
        Test.stopTest();
    }
    public static testMethod void testcreateCaseandCase2Services(){
        User testUser = [Select id, contactId from User where alias='second'];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]; 
        Contact accdetail = [Select id,Account.name,AccountId from Contact where Id = :testUser.contactId];
        List<Service__c> newServList = new List<Service__c>([Select id,name from service__c where name= 'EPIC' or name = 'NSA']);
		List<string> servicesSelectedList = new List<string>();
        servicesSelectedList.add(newServList[0].Id);
        servicesSelectedList.add(newServList[1].Id);
        string status = constants.CASE_STATUS_PENDING_REVIEW;       
        string type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        String email1 = 'testUser123@gmail.com';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct1 = new Account(Name = 'Entity Account1', School__c = true, BillingCountry = 'Brazil');
        insert acct1;
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct1.Id);
        insert con;
        String fileUniqueName = con.Id + '_' + type + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
        List<asset> assetList = new List<Asset>();
        Asset newAsset1 = new Asset();
        newAsset1.Azure_Storage_URL__c = fileUniqueName;
        newAsset1.Name = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        newAsset1.Status = Constants.IN_PROGRESS;
        newAsset1.AccountId = acct1.Id;
        newAsset1.Type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        assetList.add(newAsset1);
        insert assetList;
        Test.startTest();			
            String assetUrl = newAsset1.Azure_Storage_URL__c;
         	//system.assertEquals('success',EntityServiceRequestController.createCaseandCase2Services(servicesSelectedList,string.valueof(testUser.contactId),status,assetUrl,string.valueof(accdetail.AccountId)),'Method failed to create asset');
        EntityServiceRequestController.createCaseandCase2Services(servicesSelectedList,string.valueof(testUser.contactId),status,assetUrl,string.valueof(accdetail.AccountId));
        Test.stopTest();
    }
    public static testMethod void testupdateEcfmgAcceptableFlag(){
        User testUser = [Select id, contactId from User where alias='second'];
        List<Account> actList = new List<Account>();
        Contact con = [Select id, AccountId,Account.Account_Type__c from Contact where ID=:testUser.contactId];
        actList.add(con.Account);
        ID object2DegRecordTypeId = Schema.SObjectType.Object2Degree__c.getRecordTypeInfosByDeveloperName().get(Constants.OBJECT2DEGREE_RECORD_TYPE_SCHOOL).getRecordTypeId();
        Object2Degree__c objList = new Object2Degree__c();
        Degree__c deg = new Degree__c();
        deg.Name = 'Bachelor of Medicine';
        insert deg;
        objList.Degree__c = deg.Id;
		objList.Graduation_Year__c = '2020' ;  
        objList.RecordTypeId = object2DegRecordTypeId;
        objList.Account__c = con.AccountId;
        insert objList;
        Test.startTest();
        EntityServiceRequestController.updateEcfmgAcceptableFlag(actList); 
        actList.clear();
        Id entityAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId(); 
        Account acc = new Account(Name = 'Sample Entity',
                                   RecordTypeId = entityAccId,
                                   School__c = true,
                                   Sponsoring_Institution__c = true,
                                   BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19110',
                                   BillingState='Alaska');
        insert acc;
        System.assert(acc.Id != null, 'Account insert failed');
        actList.add(acc);
        EntityServiceRequestController.updateEcfmgAcceptableFlag(actList);
        Test.stopTest();
    }
    public static testMethod void testSignedSignatureMethods(){
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Test.startTest();
        // Contact
        Contact con = [Select id, AccountId from Contact where ID=:testUser.contactId]; 
        // Create new service
        Service__c serv = new Service__c(Name = 'Performance Data 1', School__c = true);
        insert serv;
        //create new case
        Id idEntUsrReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Case caseRecord = new Case(
                AccountId		=	con.AccountId,
                ContactId		=	con.Id,
                Service_Name__c	=	serv.Id,
                Internal_Status__c			=	Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL,
                RecordTypeId	=	idEntUsrReqRecordTypeId
            );
        insert caseRecord;
        Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Entity_Document').getRecordTypeId(); 
        Asset asst = new Asset(
                Name 			= 	Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
                recordTypeId 	= 	assetRecordTypeId,
                ContactId 		= 	testUser.ContactId,      
                type__c			= 	Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
            	case__c         =   caseRecord.Id,
            	status			= 	Constants.ASSET_STATUS_IN_PROGRESS
            );
       insert asst;
       String assetId = EntityServiceRequestController.getSignedSignFormId(caseRecord.Id);
       asst.status = Constants.ASSET_STATUS_INCOMPLETE;
       update asst;
       EntityServiceRequestController.getIncompleteSignFormId(caseRecord.Id);
       EntityServiceRequestController.deleteSignedSignForm(caseRecord.Id, Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL);
       //System.assert(assetId != null,'AssetId not fetched');
       Test.stopTest();
    }
    public static testMethod void testFetchAssetId(){
        test.startTest();
        String email1 = 'testUser1@gmail.com';
        String country = AMERICA_LA;
        String country2 = UNITED_STATES;
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', School__c = true, BillingCountry= 'Japan');
        insert acct;
        Account acct1 = new Account(Name = 'Entity Account1', RecordTypeId = idAccountTypeId, School__c = true,BillingCountry= 'India');
        //insert acct1;
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        string type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        String fileUniqueName = con.Id + '_' + type + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
        List<asset> assetList = new List<Asset>();
        Asset newAsset = new Asset();
        newAsset.Azure_Storage_URL__c = fileUniqueName;
        newAsset.Name = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        newAsset.Status = Constants.IN_PROGRESS;
        newAsset.AccountId = acct.Id;  
        newAsset.ContactId= con.Id;
        newAsset.Type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        assetList.add(newAsset);
        Asset newAsset1 = new Asset();
        newAsset1.Azure_Storage_URL__c = fileUniqueName;
        newAsset1.Name = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        newAsset1.Status = Constants.IN_PROGRESS;
        newAsset1.AccountId = acct1.Id;    
        newAsset1.ContactId= con.Id;
        newAsset1.Type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        assetList.add(newAsset1);
        insert assetList;
        Case caseRecord = new Case(
                AccountId		=	con.AccountId,
                ContactId		=	con.Id,
                Internal_Status__c			=	'New'
            );
        insert caseRecord;
        EntityServiceRequestController.updateCreatedAsset(assetList, con.Id, caseRecord);
        EntityServiceRequestController.updateCase(caseRecord);        
        EntityServiceRequestController.delAssetOnCancel(newAsset1.Azure_Storage_URL__c);
        assetList.clear();
        system.assertEquals([SELECT id FROM Asset where AccountId =: acct1.Id AND Type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =:Constants.ASSET_STATUS_INPROGRESS AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND ContactId = null AND Case__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC],assetList,'Asset in the account is not deleted');
        system.assertEquals([SELECT id FROM Asset where Id =: newAsset1.Id AND Type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =:Constants.ASSET_STATUS_INPROGRESS AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND ContactId = null AND Case__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC],assetList,'Asset is not deleted');
        test.stopTest();
    }
    public static testMethod void testFetchDocConfigs(){
        EntityServiceRequestSharingDisabled.getEnrollReverificationCoverLetter();
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = Constants.ASSET_NAME_ENROLLREV_COVER_LETTER;
		insert docConfig;
        System.assert(docConfig.Id != null, 'Failed to insert doc config');
        EntityServiceRequestSharingDisabled.getTemplateDocConfigId(docConfig.Id);
        System.assert(EntityServiceRequestSharingDisabled.getEnrollReverificationCoverLetter() != null, 'Doc config not found');
    }
}