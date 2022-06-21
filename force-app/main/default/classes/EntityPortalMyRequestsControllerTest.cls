// Test Class for EntityPortalMyRequestsController class
@isTest
public with sharing class EntityPortalMyRequestsControllerTest extends ECFMGTestFactory{
	private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    public static final String CLIENT_PATH = 'Penguins.jpg';
	public static final String TEST_CONTENT = 'Test Content';
	@testSetup static void setup(){
		Contact c1 = new Contact(Firstname='firstname',Lastname='lastname',email=CommunitiesTestFactory.emailtest);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, c1);
        run();
        
        Profile p = [ Select id from Profile where name = '4-Customer Community Entity 360' limit 1];
		
        User u = new User();
        u.FirstName = 'Test User - 1';
        u.LastName = 'Entity_360';
        u.Email = 'tester@unknownmail.com';
        u.ContactId = c1.Id;
        u.Username = 'tester@un.com';
        u.Alias = 'second';     
        u.TimeZoneSidKey = 'America/Denver';
        u.LocaleSidKey =  'en_US';
        u.EmailEncodingKey = 'UTF-8';       
        u.ProfileId = p.Id;       
        u.LanguageLocaleKey = 'en_US';     
        insert u;
        
        Id entityAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        System.debug('@@@entityAccId    '+ entityAccId);
        Account acc = new Account(Name = 'Sample Entity',
                                   RecordTypeId = entityAccId,
                                   School__c = true,
                                   Sponsoring_Institution__c = true,                              
                                   BillingCountry = 'Brazil');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, acc);
        run();   
        Account acc1 = [Select Name,RecordTypeId, Sponsoring_Institution__c from Account where RecordTypeId =: entityAccId Limit 1];
        System.assert(acc1.Id != null,'Account is not created');
	}
	public static testmethod void testActiveRequestsFetch(){
		User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		System.runAs(testUser){
			Test.startTest();
            Service__c serv3 = new Service__c(Name = 'NSA');
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, serv3);
            run();
            CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
            settingsECFMGInstance.ECFMG_ID__c = '00000004';
            upsert settingsECFMGInstance;
			System.assert(serv3.Id!=null,'Service not found');
            Date birthdate3 = date.valueOf('2000-04-01');
            String emailTestCon4 = 'testerCon4@unknownmail.com';
            Id entityConId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();       
            String lastnameCon4 = 'LastCon4';
            String firstnameCon4 = 'FirstCon4';
            Id entityAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId(); 
            Account acc1 = [Select Name,RecordTypeId, Sponsoring_Institution__c, BillingCountry from Account where RecordTypeId =: entityAccId Limit 1 ];
            Contact con4 = new Contact(Firstname = firstnameCon4,
                                       Lastname = lastnameCon4,
                                       Birthdate = birthdate3,
                                       email = emailtestCon4,
                                       MailingCountry = 'Mexico',
                                       RecordTypeId = entityConId,
                                       AccountId = acc1.Id);
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, con4);
            run();
            ID eurCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Entity_User_Request').getRecordTypeId();
            Case eurCase2 = new Case(Internal_Status__c = 'Pending Coordinator Approval',
                                    RecordTypeId = eurCaseRecordTypeId,
                                    Request_Type_Value__c = 'Add Service',
                                    Service_Name__c = serv3.Id,
                                    ContactId = con4.Id,
                                    Approver__c = getContactId.Id,
                                    External_Status__c = Constants.CASE_STATUS,
                                    AccountId = getContactId.AccountId);
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, eurCase2);
            run();
            EntityPortalMyRequestsController.getCurrentContactId();
			List<EntityPortalMyRequestHelper.MyRequestCaseWrapper> requestList = new List<EntityPortalMyRequestHelper.MyRequestCaseWrapper>();
			requestList = EntityPortalMyRequestsController.getActiveRequests(String.Valueof(getContactId.AccountId));
            System.assert(requestList[0].caseId==eurCase2.Id,'Null value returned');
            Test.stopTest();
		}
	}
    public static testmethod void testSignedSignatureAssetFetch(){
        Test.startTest();
		User testUser = [SELECT Id, ContactId from User where alias = 'second'];
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
        caseobj.Request_Type_Value__c = 'Add User';
		ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);  
        run();
		// Content Version
		ContentVersion contentVersion1 = new ContentVersion( Title = 'Penguins',
															 PathOnClient = CLIENT_PATH,
															 VersionData = Blob.valueOf(TEST_CONTENT),
															 IsMajorVersion = true);
		ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContentVersionTestData.class, contentVersion1);  
        run();
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		//Create and Insert Asset
		Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
		Asset asst = new Asset( Name = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
								recordTypeId = assetRecordTypeId,
								ContactId = getContactId.Id,
                                Case__c= caseobj.Id,
								type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
								status = Constants.ASSET_STATUS_IN_PROGRESS);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst);  
        
        Asset asst2 = new Asset( Name = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
								recordTypeId = assetRecordTypeId,
								ContactId = getContactId.Id,
                                Case__c= caseobj.Id,
								type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
								status = 'Incomplete');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst2);  
        run();
		ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.ShareType = 'V';
		contentlink.LinkedEntityId = asst.id;
		contentlink.ContentDocumentId = documents[0].Id;
		contentlink.visibility = 'AllUsers';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContentDocumentLinkTestData.class, contentlink);  
        run();
		System.runAs(testUser){
		 	EntityPortalMyRequestsController.getRequestedServices(caseObj.id);
			String returnStr = EntityPortalMyRequestsController.getSignedSignatureAsset(getContactId.Id);
			system.assert(returnStr!='', 'Null value returned');
            Service__c serv3 = new Service__c(Name = 'NSA');
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, serv3);
            run();
            Case2Service__c case2Ser = new Case2Service__c();
            case2Ser.Case__c = caseObj.id;
            case2Ser.Service__c = serv3.Id;
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, case2Ser);
            run();
            List<EntityServiceRequestControllerHelper.ServicesRoleWrapper> wrap = EntityPortalMyRequestsController.getRequestedServices(caseObj.id);
            System.assertEquals(wrap[0].serviceName, 'NSA', 'Value is not null');
		}
        CloudStorageController.PayloadWrapper payload= EntityPortalMyRequestsController.getIncompleteSignedSignatureAsset(getContactId.Id);
        System.assert(payload!=null,'Null value retruned for payload');
        Test.stopTest();
	}
      public static testmethod void testUpdateCaseandAsset(){
        Test.startTest();
		User testUser = [SELECT Id, ContactId from User where alias = 'second'];
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		// Case
		String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Attestation').getRecordTypeId();

		Case caseob = new Case();
		caseob.ContactId = getContactId.Id;
		caseob.AccountId = getContactId.AccountId;
        caseob.recordTypeId= caseRecordTypeId;
		caseob.Internal_Status__c = 'Complete';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseob);  
        run();
        Case caseobj = [Select Id, Internal_Status__c from Case where Internal_Status__c = 'Complete' Limit 1];
        System.runAs(testUser){
			Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
			String fileUniqueName = getContactId.Id + '_' + Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
            Asset asst2 = new Asset( Name = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
                					 recordTypeId = assetRecordTypeId,
                					 ContactId = getContactId.Id,
									 Azure_Storage_URL__c = fileUniqueName,
                					 type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
                					 status = Constants.ASSET_STATUS_IN_PROGRESS);
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst2);  
            run();
            String returnStr = EntityPortalMyRequestsController.updateCaseandAsset(caseobj.id, asst2.Azure_Storage_URL__c, getContactId.Id);
            system.assert(returnStr=='true', 'Returned false');
            EntityPortalMyRequestsController.getCurrentContactId();
		}
        Test.stopTest();
	}
    
    public static testmethod void testdelAssetOnCancel(){
        Test.startTest();
		User testUser = [SELECT Id, ContactId from User where alias = 'second'];
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		// Case
		Case caseobj = new Case();
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);
        run();
		System.runAs(testUser){
			Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
			String fileUniqueName = getContactId.Id + '_' + Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
            Asset asst2 = new Asset( Name = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
                					 recordTypeId = assetRecordTypeId,
									 Azure_Storage_URL__c = fileUniqueName,
                                     AccountId = getContactId.AccountId,
                					 type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
                					 status = Constants.ASSET_STATUS_INPROGRESS);
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, asst2);  
            run();
            String returnStr = EntityPortalMyRequestsController.delAssetOnCancel(asst2.Azure_Storage_URL__c);
            system.assert(returnStr=='true', 'Returned false');
            EntityPortalMyRequestsController.getCurrentContactId();
		}
        Test.stopTest();
	}
    public static testmethod void testcheckServiceAndAcceptedSignForm(){
        Test.startTest();
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
		Contact getContactId = [Select Id, AccountId from Contact where Id =: testUser.contactId];
		// Case

		Service__c sr1 = new Service__c();
        sr1.Name = 'sr1';
        sr1.Signature_Required__c = true;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, sr1);
        run();

		Case caseobj = new Case();
		caseobj.ContactId = getContactId.Id;
		caseobj.AccountId = getContactId.AccountId;
		caseobj.Internal_Status__c = 'Accepted';
        caseobj.Service__c = 'J1';
		ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);  
        run();
        
        
        Case2Service__c serviceRcd = new Case2Service__c();

        serviceRcd.Service__c= sr1.Id;
        serviceRcd.Case__c= caseobj.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, serviceRcd);  
        run();
        System.runAs(testUser){

        String returnStr = EntityPortalMyRequestsController.checkServiceAndAcceptedSignForm(getContactId.Id , caseObj.Id);
        System.assert(returnStr == 'true','Return not true');
        }
        Test.stopTest();
    }
	
}