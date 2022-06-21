@isTest
public class ERASControllerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp(){
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
        Id entityContRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT);
        Id entityAccRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Account',Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY);
        Id caseAppforcertRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_APP_FOR_CERT);
        Id catsRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact_Association_Type_Staging__c',Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL);
        Id catRecordTypeId 	= GenericUtilities.getRecordTypeIdByDevName('Contact_Association_Type__c',Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL);
        Blob bodyBlob = Blob.valueOf('Test ContentVersion Body');
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        Account entityAcc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Entity Test', RecordTypeId=entityAccRecTypeId));
        Contact entityCon = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Entity', LastName='Contact', RecordTypeId=entityContRecTypeId, Account = entityAcc));
        ContentVersion conVer = (ContentVersion)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContentVersionTestData.class, new ContentVersion(Title='SampleTitle', PathOnClient ='SampleTitle.jpg', VersionData = bodyBlob, origin = 'H'));
        run();
        System.assert(acc.id!=null, 'Account failed');
        Id erasEPRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get(Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS).getRecordTypeId();
        // Create Eligibility Period records
        List<Eligibility_Period__c> elgList = new List<Eligibility_Period__c>();
        Eligibility_Period__c eligOutdate = new Eligibility_Period__c();
        //Change the soql query to use new formula field - #US22257
        //eligOutdate.Active__c = 'N';
        //eligOutdate.ERAS_Active__c = false; - Formula field will automatoically evaluate to true or false
        eligOutdate.EP_Start_Date__c = System.today().addDays(-100);
        eligOutdate.EP_End_Date__c = System.today().addDays(-50);
        eligOutdate.Period_Code__c = 'Outdated Season';
        eligOutdate.RecordTypeId = erasEPRecordTypeId;
        elgList.add(eligOutdate);
        Eligibility_Period__c eligcurrent = new Eligibility_Period__c();
        //eligcurrent.Active__c = 'Y';
        //Change the soql query to use new formula field - #US22257
        //eligcurrent.ERAS_Active__c = true; - Formula field will automatoically evaluate to true or false
        
        eligcurrent.EP_Start_Date__c = System.today().addDays(-10);
        eligcurrent.EP_End_Date__c = System.today().addDays(50);
        eligcurrent.Lockdown_Start_Date__c = System.today().addDays(-5);
        eligcurrent.Period_Code__c = 'Current Season';
        eligcurrent.RecordTypeId = erasEPRecordTypeId;
        elgList.add(eligcurrent);
        insert elgList;
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Pending Submission';
        caseobj.RecordTypeId = caseAppforcertRecordTypeId;
        insert caseObj;
        System.assert(caseObj.Id != NULL, 'Failed to create Case');

		Contact_Association_Type__c cat = new Contact_Association_Type__c();
		cat.recordTypeId 	= 	catRecordTypeId;
		cat.Account__c 	    = 	con.AccountId;
		cat.Case__c 		=	caseobj.Id;
        cat.Parent_Case__c =	caseobj.Id;
		cat.Contact__c		=	con.Id;
		cat.Status__c		=   'Graduate';
		insert cat;  
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId 	= 	catsRecordTypeId;
        cats.Account__c 	= 	con.AccountId;
        cats.Case__c 		=	caseObj.Id;
        cats.Parent_Case__c =	caseObj.Id;
        cats.Contact__c		=	con.Id;
        cats.Status__c		=   'Graduate';
        cats.Type__c		=	Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats;
        System.assert(cats.Id != null, 'Fail to insert Cats Record!');
        Service__c ser = new Service__c();
        ser.name = 'ERAS';
        insert ser;
        System.assert(cats.Id != null, 'Fail to insert Service Record!');
        Account2Service__c acc2Ser = new Account2Service__c();
        acc2Ser.Account__c = entityAcc.Id;
        acc2Ser.Active__c = true;
        acc2Ser.Service__c = ser.Id;
        insert acc2Ser;
        System.assert(cats.Id != null, 'Fail to insert acc2Ser Record!');
        Contact2AcctService__c con2AccSer= new Contact2AcctService__c();
        con2AccSer.Account_Service__c = acc2Ser.Id;
        con2AccSer.Service_Contact__c = entityCon.Id;
        con2AccSer.Active__c = true;
        insert con2AccSer;
        System.assert(cats.Id != null, 'Fail to insert con2AccSer Record!');
        Contact cont = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User userCon = new User(alias='userTest',email='testUser@gmail.com',emailencodingkey='UTF-8',lastname='UserTest', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=cont.Id, timezonesidkey='America/Los_Angeles',username='testuser3@gmail.com');
        insert userCon;
    }
    @isTest
    private static void creatERASTest(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(userCon){
            ERASController.createERASCase();
            Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
            List<Case> erasCase = [SELECT id FROM Case WHERE ContactId =: con.ID AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION LIMIT 1];
            System.assert(erasCase.size()>0, 'ERAS case not created');
            ERASController.createERASCase();
            erasCase = [SELECT id FROM Case WHERE ContactId =: con.ID AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION];
            System.assert(erasCase.size() == 1, 'ERAS created again, should not create if case already exist');
            ERASController.checkERASInternalRestriction();
            ERASController.checkERASLockdownDate();
        }
        Test.stopTest();
    }
    @isTest
    private static void checkEligibilityForErasTokenReqTest(){
        User testUser = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(testUser){
            Boolean checkEligibility;
            String restrictionMsg;
            checkEligibility = ERASController.checkEligibilityForErasTokenReq();
            System.assert(checkEligibility == true, 'Eligible for requesting ERAS token');
            Contact con = [SELECT Id, USMLE_ID__c FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
            con.USMLE_ID__c = null;
            Update con;
            checkEligibility = ERASController.checkEligibilityForErasTokenReq();
            System.assert(checkEligibility == false, 'Not eligible for requesting ERAS token');
            con.USMLE_ID__c = 'test';
            con.ServicesRestricted__c = 'ERAS - Internal and External';
            Update con;
            restrictionMsg = ERASController.checkRestriction();
            System.assert(restrictionMsg != null, 'No restriction');
            con.ServicesRestricted__c = null;
            Update con;
            restrictionMsg = ERASController.checkRestriction();
            System.assert(restrictionMsg == null, 'restriction exist');
            ERASController.checkApplicantBiographic();
        }
        Test.stopTest();
    }
    @isTest
    private static void checkExistingErasTokenReqTest(){
        User testUser = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(testUser){
            List<Case> caseList = ERASController.checkExistingErasTokenReq();
            System.assert(caseList.size() == 0, 'ERAS token Request does not exists');
        }
        Test.stopTest();
    }
    @isTest
    private static void getCatOrCatsRecords(){
        Id entityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account(Name='EntityAcctNameNew',RecordTypeId=entityAccountRecordTypeId,School__c=true, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Karnataka',billingpostalcode = '123257'); 
        insert acc;          
        Contact con = [SELECT Id,School_Enrollment_Status__c  FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Case caseObj = [SELECT Id,Internal_Status__c FROM Case 
                        WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
                        AND ContactId =: con.Id LIMIT 1];
        Contact_Association_Type_Staging__c cats  = [SELECT Id,Account__c,Account_Name__c FROM Contact_Association_Type_Staging__c
                                                    WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
                                                    AND Parent_Case__c =: caseObj.Id ];  
        Contact_Association_Type__c cat = [SELECT ID FROM Contact_Association_Type__c WHERE Contact__c =: con.Id 
                                                    AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];  
        List<Eligibility_Period__c> activeEligibilityPeriod = new List<Eligibility_Period__c>();
        activeEligibilityPeriod = [SELECT Id, EP_Start_Date__c, EP_End_Date__c FROM Eligibility_Period__c 
                                                        WHERE RecordType.DeveloperName = :Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS 
                                                        AND ERAS_Active__c = true];                                                                                                                  
        Test.startTest();
        System.runAs(userCon){
            List<Account> accList = ERASController.getSchoolRecords();
            Map<string, string> degreeMedicalSchool = ERASController.getSelectedValues();
            system.assertEquals(!degreeMedicalSchool.isEmpty(),true,'No Degree Medical School returned');
            ERASController.getContactAssociationOrStaging();
            caseObj.Internal_Status__c = 'Accepted';
            update caseObj;
            ERASController.getContactAssociationOrStaging();
            ERASController.getActiveErasSeason();
        }
        Test.stopTest();
    }
    @isTest
    private static void testDocUpload(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(userCon){
            ERASController.createERASCase();
            Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
            List<Case> erasCase = [SELECT id FROM Case WHERE ContactId =: con.ID AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION LIMIT 1];
            System.assert(erasCase.size()>0, 'ERAS case not created');
            erasCase[0].Internal_Status__c = 'New';
            update erasCase[0];
            String ret = ERASController.checkApplicantDocUploadDisabled();
            System.assertEquals(ret, erasCase[0].Id, 'Eras Case not found');
        }
        Test.stopTest();
    }
    @isTest
    private static void getERASPSubmissionCaseTest(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(userCon){
            ERASController.createERASCase();
            Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
            List<Case> erasCase = [SELECT id FROM Case WHERE ContactId =: con.ID AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION LIMIT 1];
            System.assert(erasCase.size()>0, 'ERAS case not created');
            ERASController.createERASCase();
            erasCase = [SELECT id FROM Case WHERE ContactId =: con.ID AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION];
            System.assert(erasCase.size() == 1, 'ERAS created again, should not create if case already exist');
            String erasCaseId = ERASController.getERASPSubmissionCase();
            System.assert(erasCaseId != null, 'ERAS Case is not created');
        }
        Test.stopTest();
    }
    @isTest
    private static void testcheckMedSchoolPortalAccessFalse(){
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(userCon){
            Boolean portalAccess = ERASController.checkMedSchoolPortalAccess();
            System.assert(!portalAccess,'Entity has portal access');
        }
        Test.stopTest();
    }
    @isTest
    private static void testcheckMedSchoolPortalAccessTrue(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        Account entityAcc = [SELECT Id FROM Account WHERE Name = 'Entity Test' LIMIT 1];
        Contact_Association_Type__c cat = [SELECT Id, Account__c FROM Contact_Association_Type__c WHERE Contact__c =: con.Id AND RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL LIMIT 1];
        cat.Account__c = entityAcc.Id;
        UPDATE cat;
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(userCon){
            Boolean portalAccess = ERASController.checkMedSchoolPortalAccess();
            System.assert(portalAccess,'Entity does not have portal access');
        }
        Test.stopTest();
    }
    @isTest
    static void testOFACrestriction(){
        //create ofac country
        Test.startTest();
        List<OFAC__c> ofacList = new List<OFAC__c>();
        OFAC__c ofac = new OFAC__c(Country__c='Albania', Type__c=System.Label.OFAC_NOT_ALLOWED);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultOfacTestData.class,ofac);
        OFAC__c ofacNBME = new OFAC__c(Country__c='Afghanistan', Type__c=System.Label.OFAC_NOT_ALLOWED1);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultOfacTestData.class,ofacNBME);
        OFAC__c ofacWarning = new OFAC__c(Country__c='India', Type__c=System.Label.OFAC_Country_Warning);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultOfacTestData.class,ofacWarning);
        run();
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        System.runAs(userCon){
            String restriction = ERASController.checkRestriction();
            System.assert(restriction==null,'There should not be any restriction');
            Contact con = [SELECT Id,MailingCountry FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
            con.MailingCountry = 'Albania';
            update con;
            restriction = ERASController.checkRestriction();
            System.assert(restriction == label.OFAC_Not_Allowed_Error_Message, 'Return should be "Applicant is from restricted country"');
        }
        Test.stopTest();
    }
    @isTest
    static void testCreateERASTranscriptReqTask(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        User userCon = [Select Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Test.startTest();
        System.runAs(userCon){
            //Create ERAS case
            Boolean returnValue1 = ERASController.createERASCase();
            Case erasCase = [SELECT id FROM Case WHERE ContactId =: con.ID AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION LIMIT 1];
            Boolean returnValue = ERASController.createERASTranscriptReqTask(erasCase.Id);
            System.assertNotEquals(returnValue,false,'Task not created'); 
            erasCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_DOCUMENT_UPLOAD').Value__c;
            UPDATE erasCase;
            String retCaseNumber = ERASController.checkTranReqEligible();
            System.assert(retCaseNumber==null,'Eligible for Transcript request');
            ERASController.getERASCase(erasCase.Id);
            String copy = 'No';
            String prev = 'No';
            Boolean upd = ERASController.updERASforTransReq(copy, prev, erasCase.Id);
            System.assert(upd == true, 'Case not updated');
        }
        Test.stopTest();
    }
    @isTest
    static void getFilesForMergeTest(){
        Test.startTest();
        List<ERASController.CvWrapper> returnValue = ERASController.getFilesForMerge('SampleTitle');
        System.assert(!returnValue.isEmpty(), 'File does not exist');
        Test.stopTest();
    }

    @isTest
    static void testGetPendingorCompletedErasCases(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        User userCon = [SELECT Id FROM User WHERE email ='testUser@gmail.com' LIMIT 1];
        Account acc = [SELECT Id from Account ORDER BY CreatedDate DESC LIMIT 1];
        Eligibility_Period__c activeEligibilityPeriod = [SELECT Id, EP_Start_Date__c, EP_End_Date__c FROM Eligibility_Period__c 
                                    WHERE RecordType.DeveloperName = :Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS 
                                    AND ERAS_Active__c = true ORDER BY CreatedDate DESC LIMIT 1];   
        Test.startTest();
        System.runAs(userCon){
            //Create ERAS case
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=erasRecordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW_WITH_AAMC').Value__c, MSPE__c = true, MS_Transcript__c = true, Entity__c = acc.Id, Eligibility_Period__c = activeEligibilityPeriod.Id));
            run();
            List<Case>erasCase = ERASController.getCompletedErasTokenReq(acc.Id);
            System.assert(!erasCase.isEmpty(),'No eras case returned'); 
            erasCase[0].Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_DOCUMENT_UPLOAD').Value__c;
            erasCase[0].MSPE__c = false;
            UPDATE erasCase[0];
            erasCase = ERASController.getPendingErasTokenReq(acc.Id);
            System.assert(!erasCase.isEmpty(),'No eras case returned'); 
        }
        Test.stopTest();
    }
}