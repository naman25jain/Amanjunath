@isTest
public class AppForCertHelperTest extends ECFMGTestFactory{
    public static final String ASSET_NAME = 'Test Asset';
    public static final String DIPLOMA_DOCUMENT = 'DIPLOMA DOCUMENT';
    public static final String TEST_ACOUNT = 'Test Account';
    public static final String CLIENT_PATH = 'Penguins.jpg';
    public static final String TEST_CONTENT = 'Test Content';
    public static final String TRANSFER_CREDIT_TRANSCRIPT = 'Transfer Credit Transcript';    
    @testSetup static void setup() {
        AppforCertTestFactory.servicePageSetup();
    }        
    @isTest static void testStudentUpdateERVCaseRefactor() {
        Test.startTest();
		User testUser = [Select id,contactId from User where alias = 'user3' LIMIT 1];      
		Contact con = [Select id,AccountId from Contact where ID=:testUser.contactId];
        List<case> caseList = new List<case>();
        SET<Id> examRegCaseIdSet =   new SET<Id>(); 
        SET<Id> ervCaseIdSet =   new SET<Id>();
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();        
        // Case
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Accepted';
        caseobj.RecordTypeId = appCertRecordTypeId;
        insert caseObj;
        caseList.add(caseObj);
        // Exam Reg Case - INSERT
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case examRegCase = new Case();
        examRegCase.ContactId = con.Id;
        examRegCase.AccountId = con.AccountId;
        examRegCase.Internal_Status__c = 'Registered';
        examRegCase.RecordTypeId = examRegRecordTypeId;
        insert examRegCase;
        // EV Case  - INSERT
        Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Case evCase = new Case();
        evCase.ContactId = con.Id;
        evCase.AccountId = con.AccountId;
        evCase.Internal_Status__c = 'New';
        evCase.RecordTypeId = evRecordTypeId;
        insert evCase;
        // ERV Case  - INSERT
        Id ervRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
        Case ervCase = new Case();
        ervCase.ContactId = con.Id;
        ervCase.AccountId = con.AccountId;
        ervCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFIED;
        ervCase.RecordTypeId = ervRecordTypeId;
        insert ervCase;
        // Exam Reg Case - UPDATE 1
        Case examRegCase1 = new Case();
        examRegCase1.Id = examRegCase.Id;
        examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
        examRegCase1.Enrollment_Re_Verification_Parent__c = ervCase.Id;
        update examRegCase1;
        examRegCaseIdSet.add(examRegCase1.Id);
        ervCaseIdSet.add(examRegCase1.Enrollment_Re_Verification_Parent__c);
        List<Case> examRegCaseList = new List<Case>();
        examRegCaseList.add(examRegCase1);
        // Exam Registration Object (Exam_Registration__c)
        Map<Id, Exam_Registration__c> examRegCaseMap = new Map<Id, Exam_Registration__c>();
        Exam_Registration__c examRegObject = new Exam_Registration__c();
        examRegObject.Applicant__c = con.Id;
        examRegObject.Case__c = examRegCase.Id;
        examRegObject.Exam_taken_date__c = null;
        examRegObject.Exam_Status__c = null;
        examRegObject.Exam_Types__c = 'USMLE Step 1';
        insert examRegObject;
        examRegCaseMap.put(examRegObject.Case__c, examRegObject);
        // Contact_Association_Type_Staging__c
        Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId 	= 	recordTypeId;
        cats.Account__c 	= 	con.AccountId;
        cats.Case__c 		=	caseObj.Id;
        cats.Parent_Case__c =	caseObj.Id;
        cats.Contact__c		=	con.Id;
        cats.Status__c		=   'Student';
        cats.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats;
        System.assert(cats.Id != null, 'Fail to insert Cats Record!');
        // Contact_Association_Type__c
        Id recordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId 	= 	recordTypeIdCat;
        cat.Account__c 		= 	con.AccountId;
        cat.Case__c 		=	caseObj.Id;
        cat.Parent_Case__c	=	caseObj.Id;
        cat.Contact__c		=	con.Id;
        cat.Status__c		=   'Student';
        cat.Type__c			=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
        Transfer_Credit__c tc = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert tc;
        //Create and Insert Asset
        Asset asst1 = new Asset(
            Name = ASSET_NAME,
            Status = 'Installed',
            AccountId = con.AccountId,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Translation',
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert asst1;		
        Asset asst2 = new Asset(
            Name = Constants.ASSET_TYPE_PRE_MED_LETTER,
            Status = Constants.ASSET_STATUS_INPROGRESS,
            AccountId = con.AccountId,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c	=	Constants.ASSET_TYPE_PRE_MED_LETTER,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert asst2;
        Asset asst7 = new Asset(
            Name = 'Pre-Med Letter Translation',
            Status = Constants.ASSET_STATUS_INPROGRESS,
            AccountId = con.AccountId,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c	=	Constants.ASSET_TYPE_PRE_MED_LETTER,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert asst7;		
        System.assertNotEquals(NULL, asst7.Id, 'Asset Id is not null');
        Asset asst8 = new Asset(
            Name = Constants.ASSET_TYPE_NAME_DOC,
            Status = Constants.ASSET_STATUS_INPROGRESS,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            Type__c = Constants.ASSET_TYPE_NAME_DOC
        );
        asst8.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
        insert asst8;
        System.assertNotEquals(NULL, asst8.Id, 'Asset Id is not null');
        AppForCertHelper.studentUpdateERVCase(ervCaseIdSet);
        AppForCertHelper.studentUpdateEpexCase(examRegCaseIdSet);
        String retVal;
        retVal = AppForCertHelper.retrievePMLId(con.Id+'', caseObj.Id+'');
        Test.stopTest();
        System.runAs(testUser){
            retVal = AppForCertHelper.retrievePmlTranslationId(con.Id+'', caseObj.Id+'');
            retVal=AppForCertHelper.retrievePmlNameDocId(con.Id+'', caseObj.Id+'');
            List<Contact_Association_Type__c> catList = AppForCertHelper.getContactAssociationType();
            system.assertEquals(!catList.isEmpty(),true,'CAT List is empty');
            Map<string, string> valuesToReturn = AppForCertHelper.getSelectedValuesPart();
            system.assertEquals(!valuesToReturn.isEmpty(),true,'Map is empty');
            List<Contact_Association_Type_Staging__c > degreeList = AppForCertHelper.getAssetsDegreeChangeList(false);
            system.assertEquals(!degreeList.isEmpty(),true,'List is empty');
        }
        System.assertNotEquals(NULL, retVal, 'retVal is not null');
        Asset asst3 = new Asset(
            Name = Constants.ASSET_TYPE_PRE_MED_LETTER,
            Status = 'In Progress',
            AccountId = con.AccountId,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c	=	Constants.ASSET_TYPE_PRE_MED_LETTER
        );
        insert asst3;		
		
	}
    @isTest static void testcheckAppForCertStatus(){
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-04');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		string firstname5 = 'First5';
		string lastname5 = 'Last5';
		string emailtest5 = 'teste11r5@unknownmail1.com';
		Id p = [Select id from profile where name = '4-Customer Community Plus Login' LIMIT 1].id;
		String username5 = 'tester51@unknownmail.com_' + System.now();
		username5 = username5.replace(' ', '').replace(':', '-');
        Account testAccount2 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew'];
		System.assert(testAccount2.Id != null, 'Account ID is null here');
		Contact con5 = new Contact(AccountId = testAccount2.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
        insert con5;
        System.assert(con5.Id != null, 'Contact ID is null here');
		User user5 = new User(alias = 'user5', email = emailtest5, emailencodingkey = 'UTF-8', lastname = lastname5, languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = AppforCertTestFactory.UNITED_STATES, IsActive = true, ContactId = con5.Id, timezonesidkey = AppforCertTestFactory.AMERICA_LA, username = username5);
		insert user5;
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = testAccount2.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Rejected', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;        
        Id catRecordTypeId 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId 	= 	catRecordTypeId;
		cat.Account__c 	    = 	con5.AccountId;
		cat.Case__c 		=	csAppForCert.Id;
        cat.Parent_Case__c =	csAppForCert.Id;
		cat.Contact__c		=	con5.Id;
		cat.Status__c		=   'Graduate';
		insert cat;           
		Id assetrecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		List<Asset> assetList = new List<Asset> ();
		Asset asst1 = new Asset(
			Name =  Constants.ASSET_TYPE_TCT,
			Status = Constants.ASSET_STATUS_INPROGRESS,
			case__c = csAppForCert.Id,
			AccountId = testAccount2.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_TCT,
			RecordTypeId = assetrecordTypeId,
			Dean_s_Letter_Date__c = Constants.TODAY_DATE,
            Key__c = 'Transfer Credit Transcript Document'
		);
        	Asset asst2 = new Asset(
			Name =  Constants.ASSET_TYPE_TCT,
			Status = Constants.ASSET_STATUS_REJECTED,
			case__c = csAppForCert.Id,
			AccountId = testAccount2.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_TCT,
			RecordTypeId = assetrecordTypeId,
			Dean_s_Letter_Date__c = Constants.TODAY_DATE,
            Key__c = 'Transfer Credit Transcript Document'
		);
        assetList.add(asst1);
		assetList.add(asst2);
		insert assetList;
        Transfer_Credit__c tcc = new Transfer_Credit__c(
				Applicant__c = con5.Id,
				Case__c = csAppForCert.Id,
				Contact_Association_Type__c = cat.Id,
				To_School__c = con5.AccountId,
				From_School__c = con5.AccountId,
				Transfer_Credit_Course__c = 'Test',
				Transfer_Credit_Grade__c = 'A',
				Course_Outcome__c = 'Pass',
				Credits_Earned_Month__c = '05',
				Credits_Earned_Year__c = '2005'
			);
			insert tcc;
        List<AppForCertHelper.TcObjWrapper> tcList = new List<AppForCertHelper.TcObjWrapper>();
        tcList = AppForCertController.getOtherInstitutionConAssocTypeRefactorMethod(cat, string.valueof(cat.Account__c));
        List<AppForCertHelper.AssetObjWrapper > assetObjList = new List<AppForCertHelper.AssetObjWrapper > ();
        assetObjList = AppForCertController.getOtherInstitutionConAssocTypeRefactorAssetList(cat);
		system.runas(user5){
			boolean returnVal = AppForCertHelper.checkAppForCertStatus('Other_Institution');
            System.assertEquals(returnVal, true, 'App for cert is not rejected');
            AppForCertHelper.OtherSchoolObjWrapper tempJsObj;
            tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(string.valueof(cat.Id), 'EntityAcctNameNew', '', string.valueof(cat.Account__c), null, null, null, '', '', null, null, null, null, 'false', tcList, assetObjList, 'Contact_Association_Type__c', 'CV Accepted');
            List<AppForCertHelper.OtherSchoolObjWrapper> wrapperListExisting = new List<AppForCertHelper.OtherSchoolObjWrapper>();
            wrapperListExisting.add(tempJsObj);
            List<AppForCertHelper.OtherSchoolObjWrapper> wrapperList = AppForCertHelper.getOtherInstitutionConAssocType();
            system.assertEquals(wrapperList[0].otherSchool,wrapperListExisting[0].otherSchool,'Values are different than expected');
            AppForCertHelper.checkForRejectedCat(wrapperList);                     
		}
		Test.stopTest();
    }
    @isTest static void testcheckAppForCertFMDStatus(){
		Test.startTest();
		date birthdate2 = date.valueOf('2000-01-04');
		Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		string firstname5 = 'First51';
		string lastname5 = 'Last51';
		string emailtest5 = 'teste11r5@unknownmail1.com';
		Id p = [Select id from profile where name = '4-Customer Community Plus Login' LIMIT 1].id;
		String username5 = 'tester51@unknownmail.com_' + System.now();
		username5 = username5.replace(' ', '').replace(':', '-');
        Account testAccount3 = [SELECT Id,Name,RecordTypeId,School__c,Is_Final_Transcript_Required__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameforNegative' LIMIT 1];
		System.assert(testAccount3.Id != null, 'Account ID is null here');
		Contact con5 = new Contact(AccountId = testAccount3.Id, Firstname = firstname5, Lastname = lastname5, Birthdate = birthdate2, email = emailtest5, MailingCountry = 'India', School_Enrollment_Status__c = 'Graduate');
        insert con5;
        System.assert(con5.Id != null, 'Contact ID is null here');
		User user5 = new User(alias = 'user5', email = emailtest5, emailencodingkey = 'UTF-8', lastname = lastname5, languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = AppforCertTestFactory.UNITED_STATES, IsActive = true, ContactId = con5.Id, timezonesidkey = AppforCertTestFactory.AMERICA_LA, username = username5);
		insert user5;
        System.assert(user5.Id != null, 'User is not created here');
		Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		Case csAppForCert = new Case(AccountId = testAccount3.Id, ContactId = con5.Id, Service__c = 'EPIC', Internal_Status__c = 'Rejected', RecordTypeId = idAppForCertCaseRecordTypeId);
		insert csAppForCert;
        System.assert(csAppForCert.Id != null, 'AppForCert Case ID is null here');
		Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
		Contact_Association_Type__c cats = new Contact_Association_Type__c();
		cats.recordTypeId 	= 	recordTypeId;
		cats.Account__c 	= 	con5.AccountId;
		cats.Case__c 		=	csAppForCert.Id;
		cats.Contact__c		=	con5.Id;
		cats.Status__c		=   'Graduate';
		insert cats;
        System.assert(cats.Id != null, 'Contact_Association_Type__c is not created here');
		Id assetrecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
		List<Asset> assetList = new List<Asset> ();
		Asset asst1 = new Asset(
			Name =  Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			Status = Constants.ASSET_STATUS_REJECTED,
			case__c = csAppForCert.Id,
            Parent_Case__c = csAppForCert.Id,
			AccountId = testAccount3.id,
			ContactId = con5.Id,
			Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
			RecordTypeId = assetrecordTypeId,
			Dean_s_Letter_Date__c = Constants.TODAY_DATE,
            Key__c = 'DIPLOMA DOCUMENT'
		);
        assetList.add(asst1);
		insert assetList;
        System.assert(assetList[0].Id != null, 'assetList is not created here');
 		system.runas(user5){
            List<Asset> assetList1 = AppForCertHelper.getGraduateRejectedDocs('Degree_Medical_School', 'Final Medical Diploma');
            system.assertEquals(assetList1[0].Id,asst1.Id,'Values are different than expected');            
		}
        String returnVal = AppForCertHelper.getMetadataId();
        System.assert(returnVal != NULL, 'No confirmation message for app4Cert');
		Test.stopTest();
    }
    @isTest static void testDeleteCATRecAndAssets(){        
		User testUser = [Select id,contactId from User where alias='user3' LIMIT 1];      
		Contact con = [Select id, Name, AccountId from Contact where ID=:testUser.contactId];
        Account testAccount4 = [SELECT Id,Name,RecordTypeId,Is_Final_Transcript_Required__c,School__c,BillingCountry,BillingState,billingpostalcode FROM Account WHERE Name = 'EntityAcctNameNew'];
        System.assert(testAccount4.Id != NULL, 'Failed to insert Account');
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();        
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Pending Submission';
        caseobj.RecordTypeId = appCertRecordTypeId;
        insert caseObj;
        System.assert(caseObj.Id != NULL, 'Failed to create Case');
        // Contact_Association_Type_Staging__c
        Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId 	= 	recordTypeId;
        cats.Account__c 	= 	testAccount4.Id;
        cats.Case__c 		=	caseObj.Id;
        cats.Parent_Case__c	=	caseObj.Id;
        cats.Contact__c		=	con.Id;
        cats.Status__c		=   'Student';
        cats.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats;
        System.assert(cats.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert tc;
        Id dmsExamRegRecordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG).getRecordTypeId();
        Contact_Association_Type_Staging__c cats1 = new Contact_Association_Type_Staging__c();
        cats1.recordTypeId 	= 	dmsExamRegRecordTypeId;
        cats1.Account__c 	= 	testAccount4.Id;
        cats1.Case__c 		=	caseObj.Id;
        cats1.Parent_Case__c	=	caseObj.Id;
        cats1.Contact__c		=	con.Id;
        cats1.Status__c		=   'Student';
        cats1.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats1;
        System.assert(cats1.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc1 = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats1.Id
        );
        insert tc1;
        Id credRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Credential_Intake').getRecordTypeId();
        Contact_Association_Type_Staging__c cats2 = new Contact_Association_Type_Staging__c();
        cats2.recordTypeId 	= 	credRecordTypeId;
        cats2.Account__c 	= 	con.AccountId;
        cats2.Case__c 		=	caseObj.Id;
        cats2.Parent_Case__c=	caseObj.Id;
        cats2.Contact__c	=	con.Id;
        cats2.Status__c		=   'Student';
        cats2.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        cats2.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats2;
        System.assert(cats2.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc2 = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats2.Id
        );
        insert tc2;
        Id assetRecordTypeId	= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            RecordtypeId = assetRecordTypeId,
            Status = 'In Progress',
            AccountId = testAccount4.Id,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
            Document_is_not_in_English__c = false,
            Name_on_Document_is_Different__c = false,
            IsOrphan__c = True,
            Contact_Association_Type_Staging__c = cats.Id,
            Name_on_Document__c = con.Name
        );
        insert asst1;		
        System.assert(asst1.Id != NULL, 'Failed to create Asset Record');
        Asset asst2 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_IN_PROGRESS,
            AccountId = testAccount4.Id,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
            Document_is_not_in_English__c = false,
            Name_on_Document_is_Different__c = false,
            IsOrphan__c = True,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert asst2;		
        System.assert(asst2.Id != NULL, 'Failed to create Asset Record');
        Asset asst3 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_IN_PROGRESS,
            AccountId = testAccount4.Id,
            Case__c = caseObj.Id,
            Parent_Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
            Document_is_not_in_English__c = false,
            Name_on_Document_is_Different__c = false,
            IsExpired__c = FALSE,
            IsOrphan__c = FALSE,
            Contact_Association_Type_Staging__c = cats2.Id
        );
        insert asst3;		
        System.assert(asst3.Id != NULL, 'Failed to create Asset Record');
        List<Contact_Association_Type_Staging__c> recordsToUpdate = new List<Contact_Association_Type_Staging__c>();
        List<Transfer_Credit__c> tcsToUpsert = new List<Transfer_Credit__c>();
        List<Asset> assetsToUpdate = new List<Asset>();
        recordsToUpdate.add(cats1);
        tcsToUpsert.add(tc1);
        assetsToUpdate.add(asst1);
        Test.startTest();
        AppForCertHelper.updateCatsAndAssets(recordsToUpdate,tcsToUpsert,assetsToUpdate);    
        System.runAs(testUser){
            AppForCertHelper.deleteCATRecAndAssets(cats.Id+'',caseObj.Id+'');   
            String caseNumber = AppForCertHelper.getCaseNumber();         
            System.assert(caseNumber != NULL, 'Case Number is not retrieved');
            //AppForCertHelper.createAssetForInc(String.valueOf(asst1.Id),asst1.key__c);
            AppForCertHelper.createAssetForInc(asst1.Id+'"',asst1.key__c);
            AppForCertHelper.getContactAssTypeStagingStatus();
            AppForCertHelper.createAssetForIncRF(asst1);
            AppForCertHelper.updateIncompleteCaseStatus(caseObj.Id);            
            AppForCertHelper.getParentAssetId(con.Id,System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT);
            AppForCertHelper.updateParentId(asst2.Id,asst1.Id);
            AppForCertHelper.delDeanLetOrDipDocs(con.Id, caseObj.Id);
            AppForCertHelper.convertMonthTextToNumber('January');
            AppForCertHelper.getGraduateAssetAzureURL(con.Id,caseObj.Id,cats1.Id,True);
        }
        Test.stopTest();
    }
    @isTest static void testdeleteUncheckedTCAndAsset(){
		User testUser = [Select id, contactId from User where alias = 'user3'];
        Contact con = [Select id, AccountId from Contact where ID =: testUser.contactId];
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();        
        // Case
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Is_Reopened_Exam_Reg__c = false;
        caseobj.Internal_Status__c = 'Accepted';
        caseobj.RecordTypeId = appCertRecordTypeId;
        insert caseObj;
        // Contact_Association_Type_Staging__c
        Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId = recordTypeId;
        cats.Account__c = con.AccountId;
        cats.Case__c = caseObj.Id;
        cats.Parent_Case__c = caseObj.Id;
        cats.Contact__c = con.Id;
        cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats;
        System.assert(cats.Id != null, 'cats failed');
        Transfer_Credit__c tc = new Transfer_Credit__c(
            Applicant__c = con.Id,
            Case__c = caseObj.Id,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert tc;
        System.assert(tc.Id != null, 'tc failed');
        //Create and Insert Asset
        Asset asst1 = new Asset(
            Name = ASSET_NAME,
            Status = 'Installed',
            AccountId = con.AccountId,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c = DIPLOMA_DOCUMENT,
            Type__c = 'Translation',
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert asst1;
        Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats2 = new Contact_Association_Type_Staging__c();
        cats2.recordTypeId = catsRecordTypeId;
        cats2.Account__c = con.AccountId;
        cats2.Case__c = caseObj.Id;
        cats2.Parent_Case__c = caseObj.Id;
        cats2.Contact__c = con.Id;
        cats2.Status__c	= 'Student';
        cats2.Is_Reopened_Exam_Reg__c = FALSE;
        cats2.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats2;
        System.assert(cats2.Id != null, 'cats failed');
        Transfer_Credit__c tc2 = new Transfer_Credit__c(
            Applicant__c = con.Id,
            Case__c = caseObj.Id,
            Contact_Association_Type_Staging__c = cats2.Id
        );
        insert tc2;
        System.assert(tc2.Id != null, 'tc2 failed');
        //Create and Insert Asset
        Asset asst2 = new Asset(
            Name = ASSET_NAME,
            Parent_Case__c = caseObj.Id,
            Status = 'Installed',
            AccountId = con.AccountId,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c = DIPLOMA_DOCUMENT,
            Type__c = 'Translation',
            IsOrphan__c = False,
            Is_Expired_Exam_Reg__c = False,
            Contact_Association_Type_Staging__c = NULL
        );
        insert asst2;
        String recordtypeCVID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_DEGREE_SCHOOL).getRecordTypeId();
        Affirmation__c affm = new Affirmation__c();
        affm.Asset__c = asst2.Id;
        affm.Degree_School_Change_Status__c = Constants.CASE_STATUS;
        affm.RecordTypeId = recordtypeCVID; 
        affm.Contact_Association_Type_Staging__c = cats2.Id;
        affm.Comments__c = 'Test comments';
        insert affm;
        Test.startTest();
        System.runAs(testUser){
			AppForCertHelper.deleteUncheckedTCAndAsset(con.Id, caseObj.Id);
            AppForCertHelper.cancelIncomAsset(String.valueOf(caseObj.Id));
            AppForCertHelper.getDegIncompleteCaseProc();   
            String retVal = AppForCertHelper.markPmlAssetsForDeletion(con.Id+'', caseObj.Id+'');
            Boolean retValue = AppForCertHelper.isStudorGrad(cats2.Id);
            system.assertEquals(True,retValue,'Returned value is false since status is graduate');                         
		}
		Test.stopTest();
	}
    public static testMethod void testMarkAssetForDeletion(){
        List<Contact> testContact = [SELECT id,AccountId FROM Contact];
        String contactId = testContact[0].Id;
        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        //Create and Insert Asset
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                Status = 'In Progress',
                                ContactId = contactId,
                                InstallDate = System.Today(),
                                key__c = Constants.ASSET_TYPE_TCT,
                                Type__c	= 'Photo',
                                Azure_Storage_URL__c = assetUrl);
        insert asst1;
        System.assert(asst1.Id != null, 'asset Id is null');
        Asset asst2 = new Asset(Name = 'Credential Request',
                                Status = 'In Progress',
                                ContactId = contactId,
                                InstallDate = System.Today(),
                                key__c = Constants.ASSET_TYPE_TCT,
                                Type__c	= 'Photo',
                                Azure_Storage_URL__c = assetUrl);
        insert asst2;
        System.assert(asst2.Id != null, 'asset Id is null');
        Boolean deletionResult = AppForCertHelper.markAssetsForDeletionFromUrl(assetUrl);
        System.assert(deletionResult, 'Marking assets for deletion failed');
    }
    //Handling rejected Cases and its related records
    @isTest static void testRejectedCasesCATRecAndAssets(){
        User testUser = [Select id,contactId from User where alias='user3'];      
		Contact con = [Select id,Name,AccountId,Account.Is_Final_Transcript_Required__c from Contact where ID=:testUser.contactId];
        Map<Id,Case> cvCaseMap = new Map<Id,Case>();
        List<Contact_Association_Type_Staging__c> recordsToUpdate = new List<Contact_Association_Type_Staging__c>();
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();        
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();        
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Rejected';
        caseobj.RecordTypeId = appCertRecordTypeId;
        caseObj = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseObj);
        Case caseobj1 = new Case();
        caseobj1.ContactId = con.Id;
        caseobj1.AccountId = con.AccountId;
        caseobj1.Internal_Status__c = 'Accepted';
        caseobj1.RecordTypeId = appCertRecordTypeId;
        caseobj1.Document_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        caseobj1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj1);
        Case caseobj2 = new Case();
        caseobj2.ContactId = con.Id;
        caseobj2.AccountId = con.AccountId;
        caseobj2.Internal_Status__c = 'CV Accepted';
        caseobj2.RecordTypeId = cvRecordTypeId;
        caseObj2 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseObj2);
        run();
        System.assert(caseObj.Id != NULL, 'Failed to create Case');
        System.assert(caseObj1.Id != NULL, 'Failed to create Case');
        System.assert(caseObj2.Id != NULL, 'Failed to create CV Case');
        // Contact_Association_Type_Staging__c
        Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId 	= 	recordTypeId;
        cats.Account__c 	= 	con.AccountId;
        cats.Case__c 		=	caseObj.Id;
        cats.Parent_Case__c =	caseObj.Id;
        cats.Contact__c		=	con.Id;
        cats.Status__c		=   'Graduate';
        cats.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        cats.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert cats;
        System.assert(cats.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert tc;
        // Contact_Association_Type_Staging__c
        Id credRecordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Credential_Intake').getRecordTypeId();
        Contact_Association_Type_Staging__c cats1 = new Contact_Association_Type_Staging__c();
        cats1.recordTypeId 	= 	credRecordTypeId;
        cats1.Account__c 	= 	con.AccountId;
        cats1.Case__c 		=	caseObj1.Id;
        cats1.Parent_Case__c=	caseObj1.Id;
        cats1.Contact__c	=	con.Id;
        cats1.Status__c		=   'Student';
        cats1.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert cats1;
        System.assert(cats1.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc1 = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats1.Id
        );
        insert tc1;
        Id summaryAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Summary').getRecordTypeId();
        // Contact_Association_Type_Staging__c        
        Id catsDMSRecordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats2 = new Contact_Association_Type_Staging__c();
        cats2.recordTypeId 	= 	catsDMSRecordTypeId;
        cats2.Account__c 	= 	con.AccountId;
        cats2.Case__c 		=	caseObj2.Id;
        cats2.Parent_Case__c=	caseObj2.Id;
        cats2.Contact__c	=	con.Id;
        cats2.Status__c		=   'Student';
        cats2.Credential_Type__c = constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        cats2.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats2;
        cvCaseMap.put(cats2.Id,caseObj2);
        System.assert(cats2.Id != null, 'Fail to insert Cats Record!');
        Contact_Association_Type_Staging__c cats3 = new Contact_Association_Type_Staging__c();
        cats3.recordTypeId 	= 	credRecordTypeId;
        cats3.Account__c 	= 	con.AccountId;
        cats3.Case__c 		=	caseObj1.Id;
        cats3.Parent_Case__c=	caseObj1.Id;
        cats3.Contact__c	=	con.Id;
        cats3.Status__c		=   'Graduate';
        cats3.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert cats3;
        System.assert(cats3.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc3 = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj2.Id,
            Contact_Association_Type_Staging__c = cats3.Id,
            From_School__c = con.AccountId,
            Transfer_Credit_Course__c = 'Test',
            Course_Outcome__c = 'Pass',
            Transfer_Credit_Grade__c = '2',
            Credits_Earned_Month__c = 'January',
            Credits_Earned_Year__c = '2020'            
        );
        insert tc3;
        List < Transfer_Credit__c > tcsToUpsert = new List < Transfer_Credit__c >();
        tcsToUpsert.add(tc3);
        // Contact_Association_Type__c
        Id recordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Id recordTypeIdCatMed 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Id credRecordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Credential_Intake').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId 	= 	recordTypeIdCat;
        cat.Account__c 		= 	con.AccountId;
        cat.Case__c 		=	caseObj.Id;
        cat.Parent_Case__c	=	caseObj.Id;
        cat.Contact__c		=	con.Id;         
        cat.Status__c		=   'Student';       
        cat.Type__c			=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
        Contact_Association_Type__c cat2 = new Contact_Association_Type__c();
        cat2.recordTypeId 	= 	credRecordTypeIdCat;
        cat2.Account__c 	= 	con.AccountId;
        cat2.Case__c 		=	caseObj2.Id;
        cat2.Parent_Case__c	=	caseObj2.Id;
        cat2.Contact__c		=	con.Id;
        cat2.Status__c		=   'Student';
        cat2.Start_Date__c = System.today() - 365;
        cat2.End_Date__c = System.today() + 365;
        cat2.Graduation_Month__c = 'May'; 
        cat2.Graduation_Year__c = String.valueOf((System.today() + 365).year()); 
        cat2.Number_of_Years_Attended__c = 2;
        cat2.IsDeanLetter__c = true;
        cat2.Courier_service_for_an_additional_fee__c = true;
        cat2.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat2;      
        Set<String> tcDelStagingId = new Set<String>();
        tcDelStagingId.add(cats3.Id);
        Test.startTest();
        System.runAs(testUser){                                    
            String appforcertSummaryPdf = AppForCertHelper.getAppForCertSummaryPDFUrl(caseObj1.Id);
            System.assert(appforcertSummaryPdf != NULL, 'Application Summary PDF is not created');                        
            Boolean checkFMSTCVAccepted = AppForCertHelper.checkFMSTCVAccepted(con.Id);
            System.assert(checkFMSTCVAccepted = true, 'FMST CV Case is not CV Accepted');
            Boolean CATDeletedOnResubmission = AppForCertHelper.updateCATDeletedOnResubmission('Degree_Medical_School');
            System.assert(CATDeletedOnResubmission = true, 'Deleted on resubmission');
            Map<String, String> CATGraduateFMSTRecord = AppForCertHelper.getCATGraduateFMSTRecord(false,true,true);
            AppForCertHelper.getCATGraduateOnlyRecords(false,true,true,cat2.Id);            
            AppForCertHelper.createCVCaseForFMSTNotReq(con.Id,caseObj2.Id,false);
            Boolean finalTranscriptReqd = AppForCertHelper.checkFMST(con.AccountId);
            System.assert(finalTranscriptReqd = true, 'Final Transcript Not Reqd');
            con.Account.Is_Final_Transcript_Required__c = false;
            update con.Account;
            AppForCertHelper.createCATSCredIntakeRecord(con.Id,caseObj2.Id,cats2.Id);
            AppForCertHelper.getCatCourierFMST(con.AccountId);
            AppForCertHelper.creatCVCaseForAppForCert(false,caseobj1.Id,con.Id);
            AppForCertHelper.getCATSCredIntakeRecord(con.Id,caseObj2.Id,cats2.Id,'');
            AppForCertHelper.getCATSCredIntakeRecId(con.Id,caseObj1.Id);                            
        }
        Test.stopTest();
    }   
    @isTest static void testCATRecords(){        
        Test.startTest();
        User testUser = [Select id,contactId from User where alias='user3'];      
		Contact con = [Select id,Name,AccountId from Contact where ID=:testUser.contactId];
        List<Asset> assetListToUpdate = new List<Asset> ();
        Set<String> stagingIds = new Set<String>();
        List<String> allAssetSet = new List<String>();
        Set<String> allAssetId = new Set<String>();
        List<Asset> assetsToUpdate = new List<Asset>();
        Map<Id,Case> cvCaseMap = new Map<Id,Case>();
        List<Contact_Association_Type_Staging__c> recordsToUpdate = new List<Contact_Association_Type_Staging__c>();
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();        
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();        
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Rejected';
        caseobj.RecordTypeId = appCertRecordTypeId;
        insert caseObj;
        System.assert(caseObj.Id != NULL, 'Failed to create Case');
        Case caseobj1 = new Case();
        caseobj1.ContactId = con.Id;
        caseobj1.AccountId = con.AccountId;
        caseobj1.Internal_Status__c = 'Accepted';
        caseobj1.RecordTypeId = appCertRecordTypeId;
        caseobj1.Document_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert caseObj1;
        System.assert(caseObj1.Id != NULL, 'Failed to create Case');
        Case caseobj2 = new Case();
        caseobj2.ContactId = con.Id;
        caseobj2.AccountId = con.AccountId;
        caseobj2.Internal_Status__c = 'CV Accepted';
        caseobj2.RecordTypeId = cvRecordTypeId;
        insert caseObj2;
        System.assert(caseObj2.Id != NULL, 'Failed to create CV Case');
        // Contact_Association_Type_Staging__c
        Id recordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId 	= 	recordTypeId;
        cats.Account__c 	= 	con.AccountId;
        cats.Case__c 		=	caseObj.Id;
        cats.Parent_Case__c =	caseObj.Id;
        cats.Contact__c		=	con.Id;
        cats.Status__c		=   'Graduate';
        cats.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        cats.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert cats;
        System.assert(cats.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert tc;
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = 'Accepted',
            AccountId = con.AccountId,
            Case__c = caseObj.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            IsExpired__c = FALSE,
            IsOrphan__c = FALSE,
            Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/C-09121_Application_For_Certification_Summary_2022-2-2_13_20_16.pdf',
            Contact_Association_Type_Staging__c = cats.Id
        );
        insert asst1;		
        System.assert(asst1.Id != NULL, 'Failed to create Asset Record');
        // Contact_Association_Type_Staging__c
        Id credRecordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Credential_Intake').getRecordTypeId();
        Contact_Association_Type_Staging__c cats1 = new Contact_Association_Type_Staging__c();
        cats1.recordTypeId 	= 	credRecordTypeId;
        cats1.Account__c 	= 	con.AccountId;
        cats1.Case__c 		=	caseObj1.Id;
        cats1.Parent_Case__c=	caseObj1.Id;
        cats1.Contact__c	=	con.Id;
        cats1.Status__c		=   'Student';
        cats1.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert cats1;
        System.assert(cats1.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc1 = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj.Id,
            Contact_Association_Type_Staging__c = cats1.Id
        );
        insert tc1;
        Id summaryAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Summary').getRecordTypeId();
        Asset asst2 = new Asset(
            Name = Constants.ASSET_NAME_APPLICATION_FOR_CERTIFICATION_SUMMARY,
            RecordTypeId 	= 	summaryAssetRecordTypeId,
            Status = 'Accepted',
            AccountId = con.AccountId,
            Case__c = caseObj1.Id,
            Parent_Case__c = caseObj1.Id,
            ContactId = con.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c = 'Application Summary',
            key__c	=	System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
            ParentId = asst1.Id,
            IsExpired__c = FALSE,
            IsOrphan__c = FALSE,
            Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/C-09121_Application_For_Certification_Summary_2022-2-2_13_20_16.pdf',
            Contact_Association_Type_Staging__c = cats1.Id
        );
        insert asst2;        		
        System.assert(asst2.Id != NULL, 'Failed to create Asset Record');
        assetListToUpdate.add(asst1);
        List<String> assetsUrlsList = new List<String>();
        assetsUrlsList.add(asst2.Azure_Storage_URL__c);
        Map<String, Asset> assetsMap = new Map<String, Asset>();
        assetsMap.put(asst2.Azure_Storage_URL__c,asst2);
        // Contact_Association_Type_Staging__c        
        Id catsDMSRecordTypeId 	= 	Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats2 = new Contact_Association_Type_Staging__c();
        cats2.recordTypeId 	= 	catsDMSRecordTypeId;
        cats2.Account__c 	= 	con.AccountId;
        cats2.Case__c 		=	caseObj2.Id;
        cats2.Parent_Case__c=	caseObj2.Id;
        cats2.Contact__c	=	con.Id;
        cats2.Status__c		=   'Student';
        cats2.Credential_Type__c = constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        cats2.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats2;
        cvCaseMap.put(cats2.Id,caseObj2);
        System.assert(cats2.Id != null, 'Fail to insert Cats Record!');
        Contact_Association_Type_Staging__c cats3 = new Contact_Association_Type_Staging__c();
        cats3.recordTypeId 	= 	credRecordTypeId;
        cats3.Account__c 	= 	con.AccountId;
        cats3.Case__c 		=	caseObj2.Id;
        cats3.Parent_Case__c=	caseObj2.Id;
        cats3.Contact__c	=	con.Id;
        cats3.Status__c		=   'Student';
        cats3.Credential_Type__c  =  constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        insert cats3;
        Test.stopTest();
        System.assert(cats3.Id != null, 'Fail to insert Contact association type staging Record');
        Transfer_Credit__c tc3 = new Transfer_Credit__c(
            Applicant__c = 	con.Id,
            Case__c		=	caseObj2.Id,
            Contact_Association_Type_Staging__c = cats3.Id,
            From_School__c = con.AccountId,
            Transfer_Credit_Course__c = 'Test',
            Course_Outcome__c = 'Pass',
            Transfer_Credit_Grade__c = '2',
            Credits_Earned_Month__c = 'January',
            Credits_Earned_Year__c = '2020'            
        );
        insert tc3;
        Set<String> tcDelStagingId = new Set<String>();
        tcDelStagingId.add(cats3.Id);
        List < Transfer_Credit__c > tcsToUpsert = new List < Transfer_Credit__c >();
        tcsToUpsert.add(tc3);
        // Contact_Association_Type__c
        Id recordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Id recordTypeIdCatMed 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Id credRecordTypeIdCat 	= 	Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Credential_Intake').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId 	= 	recordTypeIdCat;
        cat.Account__c 		= 	con.AccountId;
        cat.Case__c 		=	caseObj.Id;
        cat.Parent_Case__c	=	caseObj.Id;
        cat.Contact__c		=	con.Id;         
        cat.Status__c		=   'Student';   
        cat.Start_Date__c = System.today() - 365;
        cat.End_Date__c = System.today() + 365;
        cat.Graduation_Month__c = 'May'; 
        cat.Degree_Issue_Date__c = System.today() - 365;
        cat.Graduation_Year__c = String.valueOf((System.today() + 365).year()); 
        cat.Number_of_Years_Attended__c = 2;    
        cat.Type__c			=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        System.assert(cat.Degree_Issue_Date__c <> null);
        insert cat;
        Contact_Association_Type__c cat2 = new Contact_Association_Type__c();
        cat2.recordTypeId 	= 	credRecordTypeIdCat;
        cat2.Account__c 	= 	con.AccountId;
        cat2.Case__c 		=	caseObj2.Id;
        cat2.Parent_Case__c	=	caseObj2.Id;
        cat2.Contact__c		=	con.Id;
        cat2.Status__c		=   'Student';
        cat2.Start_Date__c = System.today() - 365;
        cat2.End_Date__c = System.today() + 365;
        cat2.Graduation_Month__c = 'May'; 
        cat2.Graduation_Year__c = String.valueOf((System.today() + 365).year()); 
        cat2.Number_of_Years_Attended__c = 2;
        cat2.IsDeanLetter__c = true;
        cat2.Courier_service_for_an_additional_fee__c = true;
        cat2.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat2;
        stagingIds.add(cats.Id);
        stagingIds.add(cats1.Id);
        stagingIds.add(cats2.Id);
        stagingIds.add(cats3.Id);
        allAssetSet.add(asst1.Id);
        allAssetSet.add(asst2.Id);
        allAssetId.add(asst1.Id);
        allAssetId.add(asst2.Id);
        assetsToUpdate.add(asst1);
        assetsToUpdate.add(asst2);
        System.runAs(testUser){ 
            //methods
            String currentContactAssociatonTypeId = AppForCertHelper.getContactAssociationTypeStaging(false,String.valueOf(caseobj.Id),String.valueOf(con.Id));                        
            System.assert(currentContactAssociatonTypeId != NULL, 'CATS not created');
            String conAssocTypeStagCredIntakeId = AppForCertHelper.getConAssocTypeStageCredIntake();
            System.assert(conAssocTypeStagCredIntakeId != NULL, 'CATS not created');
            List<Contact_Association_Type__c> existingConAssoStagingObjList = AppForCertHelper.getContactAssociationType();
            System.assert(existingConAssoStagingObjList != NULL, 'CAT not created');
            Boolean acceptedFMDStatus = AppForCertHelper.getCATDegMedSchFMDStatus(con.Id);
            System.assert(acceptedFMDStatus = true, 'CAT list is empty');
            AppForCertHelper.getCATSCredIntakeRecord(con.Id,caseObj2.Id,cats2.Id,'');
            AppForCertHelper.getCATSCredIntakeRecId(con.Id,caseObj1.Id);
            AppForCertHelper.deleteCredIntakeCATS(con.Id,caseObj1.Id);
            AppForCertHelper.createCATSCredIntakeRecord(con.Id,caseObj2.Id,cats2.Id);
            //wrapper class
            AppForCertHelper.AssetObjWrapper assetObj;
            assetObj = new AppForCertHelper.AssetObjWrapper(String.valueOf(asst2.Id), 'No', con.Name, 'No', asst2.Type__c, asst2.key__c, asst2.Parent_key__c, String.valueOf(asst2.ParentId));
            List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
            assetObjList.add(assetObj);    
            AppForCertHelper.GraduateOnlyObjWrapper tempJsObj;
            tempJsObj = new AppForCertHelper.GraduateOnlyObjWrapper(string.valueof(cats2.Id), string.valueof(cats3.Id), string.valueof(con.Id), string.valueof(caseObj2.Id), TRUE, TRUE, Date.Today(), FALSE, TRUE, assetObjList);
            tempJsObj.isFinalTranscriptRequired = TRUE; 
            List<AppForCertHelper.GraduateOnlyObjWrapper> objectList = new List<AppForCertHelper.GraduateOnlyObjWrapper>();
            objectList.add(tempJsObj);
            String jsonString = JSON.serialize(objectList);           
            AppForCertHelper.saveGraduateOnlyRecords(jsonString,assetsUrlsList,false);  
            AppForCertHelper.getFMSTAssetStatusAndType(con.Id); 
            AppForCertHelper.IncompleteAssetObjWrapper incompleteAssetWrapper;
            incompleteAssetWrapper = new AppForCertHelper.IncompleteAssetObjWrapper(asst2.Id, 'No', asst2.Name, 'No', asst2.Type__c, System.Label.App_for_Cert_DIPLOMA_DOCUMENT, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, asst1.Id, String.valueOf(Date.Today())); 
            AppForCertHelper.UpdateParentAssetWrapper tempAssetObj;
            tempAssetObj = new AppForCertHelper.UpdateParentAssetWrapper(String.valueOf(con.Id), FALSE, asst2.Name, FALSE, TRUE, asst2.Name, FALSE, TRUE, TRUE, asst2.Name, FALSE, FALSE, Date.Today(), FALSE,TRUE);
            AppForCertHelper.TcObjWrapper tcObj;
            tcObj = new AppForCertHelper.TcObjWrapper(String.valueOf(tc3.Id), String.valueOf(tc3.From_School__c), tc3.Transfer_Credit_Course__c ,tc3.Course_Outcome__c,tc3.Transfer_Credit_Grade__c,tc3.Credits_Earned_Month__c,tc3.Credits_Earned_Year__c);
            AppForCertHelper.TcredObjWrapper TcredObj; 
            TcredObj = new AppForCertHelper.TcredObjWrapper(tcsToUpsert,tcDelStagingId);
            AppForCertHelper.AssetObjctWrapper AssetObjct; 
            AssetObjct = new AppForCertHelper.AssetObjctWrapper(stagingIds,allAssetSet, allAssetId, assetsToUpdate);
            AppForCertHelper.deansLetterOrFinalDiplomaError();   
        }
    }
}