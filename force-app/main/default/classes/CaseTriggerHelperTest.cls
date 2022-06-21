// Test class for CaseTriggerHelper
@isTest
private class CaseTriggerHelperTest extends ECFMGTestFactory{
    // Test method for casePerformanceDataMapCheck
    @isTest
    static void casePerformanceDataMapCheck(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENTITY_USER_REQUEST').Value__c);
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', Account=acc));
        Service__c serviceRec = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name='Performance Data', Signature_Required__c = true));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,Account = acc, Entity__c=acc.Id, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c, Source__c = Constant_Case__mdt.getInstance('CASE_SOURCE_PORTAL_USER').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, new Case2Service__c(Case__c=cas.Id, Service__c=serviceRec.Id));
        run();
        System.assert(!(CaseTriggerHelper.casePerformanceDataMapCheck(new List<Case>{cas})).isEmpty(),'Performance Data not available');
    }
    // Test method for testGenerateUsmleIdReturnsSuccess
    @isTest
    static void testGenerateUsmleIdReturnsSuccess(){
        Id recordTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', Account=acc));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,Account = acc, Entity__c=acc.Id, RecordTypeId=recordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c, Source__c = Constant_Case__mdt.getInstance('CASE_SOURCE_PORTAL_USER').Value__c));
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,Account = acc, Entity__c=acc.Id, RecordTypeId=recordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED').Value__c, Source__c = Constant_Case__mdt.getInstance('CASE_SOURCE_PORTAL_USER').Value__c));
        run();
        Test.startTest();
        CaseTriggerHelper.generateUsmleId(cas1, cas);
        Test.stopTest();
        System.assert(!([SELECT Id FROM Contact WHERE Id =:con.Id AND USMLE_ID__c != null]).isEmpty(),'Generate Usmle Id Failed');
    }
    // Test method for getMapOfCaseIdCase2Service
    @isTest
    static void getMapOfCaseIdCase2ServiceTest(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENTITY_USER_REQUEST').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        Service__c evSer = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name='Enrollment Verification', Signature_Required__c = true));
        Service__c cvSer = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name='Credential Verification', Signature_Required__c = true));
        Service__c perSer = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name='Performance Data', Signature_Required__c = true));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,Account = acc, Entity__c=acc.Id, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c, Source__c = Constant_Case__mdt.getInstance('CASE_SOURCE_PORTAL_USER').Value__c));
        run();
        Case2Service__c ser = (Case2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, new Case2Service__c(Case__c=cas.Id, Service__c=evSer.Id));
        Case2Service__c ser1 = (Case2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, new Case2Service__c(Case__c=cas.Id, Service__c=cvSer.Id));
        Case2Service__c ser2 = (Case2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, new Case2Service__c(Case__c=cas.Id, Service__c=perSer.Id));
        Account2Service__c acc2Ser = (Account2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new Account2Service__c(Service__c=evSer.Id, Account__c = acc.Id));
        Account2Service__c acc2SerRec = (Account2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new Account2Service__c(Service__c=cvSer.Id, Account__c = acc.Id));
        run();
        System.assert(!(CasetriggerHelper.getMapOfCaseIdCase2Service(new List<case>{cas})).isEmpty(),'getMapOfCaseIdCase2Service Failed');
    }
    // Test method for getAltCaseIds
    @isTest
    static void getAltCaseIds(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact', Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Account Test'));
        run();
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName = 'Test', LastName = 'Contacts', USMLE_ID__c = '1234', RecordTypeId = conRecordTypeId, Account = acc));
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Id cvaffirmRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c);
        Case cvCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Entity__c = acc.Id,Alternate_Entity__c = acc.Id,Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_COMPILE_VF_PACKET').Value__c));
        run();
        Affirmation__c affRec = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(RecordTypeId = cvaffirmRecTypeId, Status__c = Constant_Case__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, Case__c = cvCase.Id));
        run();
        affRec.Verify_with_Alternate_Entity__c = true;
        update affRec;
        System.assert(!(CaseTriggerHelper.getAltCaseIds(new List<Case>{cvCase})).isEmpty(),'getAltCaseIds Failed');
    }
    // Test method for prepareEmail
    @isTest
    static void prepareEmailTest(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENTITY_USER_REQUEST').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,Account = acc, Entity__c=acc.Id, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c, Source__c = Constant_Case__mdt.getInstance('CASE_SOURCE_PORTAL_USER').Value__c));
        run();
        OrgWideEmailAddress addr = [Select Id FROM OrgWideEmailAddress where displayname =: Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c];
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: Constant_Case__mdt.getInstance('ENTITY_USER_REQUEST_REJECTED').Value__c];
        System.assert((CaseTriggerHelper.prepareEmail(cas,addr,emailTemplate))!=null,'prepareEmailTest Failed');
    }
    // Test method for getParentCaseChildCaseEntity
    @isTest
    static void getParentCaseChildCaseEntityTest(){
        Id cvaffirmRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c);
        Id appforcertcaseRTId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact', Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Account Test'));
        Service__c cvSer = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name='Credential Verification', Signature_Required__c = true));
        run();
        Account2Service__c acc2Ser = (Account2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new Account2Service__c(Service__c=cvSer.Id, Account__c = acc.Id));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName = 'Test', LastName = 'Contacts', USMLE_ID__c = '1234', RecordTypeId = conRecordTypeId, Account = acc));
        Case appForCertCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con,AccountId = con.AccountId, RecordTypeId = appforcertcaseRTId, Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        Case cvCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c, ParentId = appForCertCase.Id, Entity__c = con.AccountId,Alternate_Entity__c = con.AccountId));
        Case cvCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c, ParentId = appForCertCase.Id, Entity__c = con.AccountId,Alternate_Entity__c = con.AccountId));
        run();
        Affirmation__c affRec = (Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(RecordTypeId = cvaffirmRecTypeId, Status__c = Constant_Case__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, Case__c = cvCase.Id));
        run();
        affRec.Verify_with_Alternate_Entity__c = true;
        update affRec;
        Map<Id,Set<Id>> parentCaseEntity = CaseTriggerHelper.getParentCaseChildCaseEntity(new Set<Id>(),new Set<Id>{appForCertCase.Id});
        System.assert(!parentCaseEntity.isEmpty(),'getParentCaseChildCaseEntity Failed');
        System.assert(CaseTriggerHelper.checkParentCaseEntityAccess(appForCertCase.Id,cvCase.Entity__c,parentCaseEntity),'checkParentCaseEntityAccess Failed');
        System.assert(!CaseTriggerHelper.checkParentCaseEntityAccess(cvCase1.Id,cvCase.Entity__c,parentCaseEntity),'checkParentCaseEntityAccess Failed');
    }
    /*public static final Integer CHECK_DIGIT_INPUT_EQUAL_TEN = 10;
    public static final Integer CHECK_DIGIT_INPUT_GREATER_THAN_TEN = 11;
    public static final Integer CHECK_DIGIT_INPUT_LESS_THAN_TEN = 9;
    public static final String CASE_CREATION_FAILED='Case creation failed';
    public static final String ACCOUNT_CREATION_FAILED='account creation failed';
    public static final String ACCOUNT_NAME='Entity Account';
    public static final String ACCOUNT_NAME1='Entity Account1';
    public static final String PHY_ADDRESS = 'Test Address';
    public static final String CRED_TYPE = 'Letter from Dean';
    public static final String USER_NOT_INS = 'User is not inserted';
    public static final String BILLING_COUNTRY = 'India';
    /**
* * Setup Data (AAA-Arrange)
*/ 
    /*@testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        //Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        
        // Create a new case to be used in all applicable test functions
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User user = [SELECT id, contactId 
                     FROM User 
                     WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                     AND profileId =: profile.id
                     LIMIT 1];
        Contact contact = [SELECT id, AccountId 
                           FROM Contact 
                           WHERE Id =: user.contactId
                           LIMIT 1];
        // new case 
        Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                              AccountId = contact.AccountId,
                                              Internal_Status__c = Constants.CASE_STATUS_NEW);
        insert caseWithWorkingStatus;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetCheckDigitInputEqualsTen() {
        //Arrange
        // Setup()
        
        //Act
        Test.startTest();
        Integer result = CaseTriggerHelper.getCheckDigit(CHECK_DIGIT_INPUT_EQUAL_TEN);
        Test.stopTest();
        
        //Assert
        System.assertEquals(0, result,'Get Check Digit did not return zero');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetCheckDigitInputGreaterThan10() {
        //Arrange
        // Setup()
        
        //Act
        Test.startTest();
        Integer result = CaseTriggerHelper.getCheckDigit(CHECK_DIGIT_INPUT_GREATER_THAN_TEN);
        Test.stopTest();
        
        //Assert
        System.assertNotEquals(0, result,'Get Check Digit return zero');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetCheckDigitInputLessThan10() {
        //Arrange
        // Setup()
        
        //Act
        Test.startTest();
        Integer result = CaseTriggerHelper.getCheckDigit(CHECK_DIGIT_INPUT_LESS_THAN_TEN);
        Test.stopTest();
        
        //Assert
        System.assertEquals(1, result,'Get Check Digit did not return 1');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGenerateUsmleIdReturnsSuccess() {
        //Arrange
        // Setup()
        Case oldCase =  [SELECT Id, Internal_Status__c, ContactId
                         FROM Case
                         WHERE Internal_Status__c =: Constants.CASE_STATUS_NEW
                         LIMIT 1];
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        
        Case newCase = new Case(ContactId = oldCase.ContactId,
                                Internal_Status__c = Constants.CASE_STATUS_SUBMITTED,
                                recordTypeId = recordTypeId);
        
        insert newCase; 
        
        //Act
        Case testCase =  [SELECT Id, recordType.DeveloperName, Internal_Status__c, ContactId, Contact.USMLE_ID__c
                          FROM Case
                          WHERE Id =: newCase.Id
                          LIMIT 1];
        Test.startTest();
        CaseTriggerHelper.generateUsmleId(testCase, oldCase);
        Test.stopTest();
        
        //Assert
        System.assertEquals(true, true,'Generate Usmle Id Failed');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testReUpdateEVCaseForEpexSuccessUpdatesRecord() {
        //Arrange
        // Setup()
        Case workingCase =  [SELECT Id, Internal_Status__c, External_Status__c, Verification_Status__c, Status_Not_Reviewed_Date__c
                             FROM Case
                             WHERE Internal_Status__c =: Constants.CASE_STATUS_NEW
                             LIMIT 1];
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        
        workingCase.recordTypeId = recordTypeId; 
        
        update workingCase;
        
        List<Case> caseList = new List<Case>();
        caseList.add(workingCase);
        
        //Act
        Test.startTest();
        CaseTriggerHelper.reUpdateEVCaseForEpex(caseList);
        Test.stopTest();
        
        //Assert
        // Check if the case is updated
        Case updatedCase =  [SELECT Id, External_Status__c
                             FROM Case
                             WHERE Internal_Status__c =: Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL
                             LIMIT 1];
        
        System.assertEquals(updatedCase.External_Status__c, Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED,'Reupdate EV Case did not update');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGenerateManualReviewReasonReturnsNotNull() {
        //Arrange
        // Setup()
        Case oldCase =  [SELECT Id, Internal_Status__c, ContactId, Number_of_Years_Attended__c
                         FROM Case
                         WHERE Internal_Status__c =: Constants.CASE_STATUS_NEW
                         LIMIT 1];
        
        oldCase.Attendance_Start_Month__c = 'January';
        oldCase.Attendance_End_Month__c = 'February';
        oldCase.Graduation_Month__c = 'January';
        oldCase.Degree_Month__c = 'January';
        oldCase.Number_of_Years_Attended__c = 1;
        
        update oldCase;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        
        Case newCase = new Case(ContactId = oldCase.ContactId,
                                Internal_Status__c = Constants.CASE_STATUS_SUBMITTED,
                                recordTypeId = recordTypeId,
                                Attendance_Start_Month__c = 'March',
                                Attendance_End_Month__c = 'April',
                                Graduation_Month__c = 'March',
                                Degree_Month__c = 'March',
                                Number_of_Years_Attended__c = 2);
        
        insert newCase; 
        
        //Act
        Test.startTest();
        String output = CaseTriggerHelper.generateManualReviewReason(newCase, oldCase);
        Test.stopTest();
        
        //Assert
        System.assertNotEquals(String.isBlank(output), true,'Review reason is Blank');
    }
	// US 11136-To check if Send method is selected as Entity Portal, then Entity's Account2Service should be active else it should throw error.	
    @isTest
    static void testsendMethodErrorEntity(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<case>();        
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct);
        Account acct1 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct1);
        insert acctList;
        for(Account acc:acctList){
            System.assert(acc.Id != null,acc.Name+' '+ACCOUNT_CREATION_FAILED);
        }        
        Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con = [Select Id From Contact Limit 1];
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase.ContactId = con.Id;
        credVerCase.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase.Entity__c = acct.Id; 
        caseList.add(credVerCase);
        Case credVerCase1 = new Case();
        credVerCase1.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase1.ContactId = con.Id;
        credVerCase1.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase1.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase1.Entity__c = acct1.Id;
        caseList.add(credVerCase1);
        Case credVerCase2 = new Case();
        credVerCase2.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase2.ContactId = con.Id;
        credVerCase2.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase2.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase2.Entity__c = acct1.Id;
        caseList.add(credVerCase2);
        Insert caseList;
        for(Case cs:caseList){
            System.assert(cs.Id != null,CASE_CREATION_FAILED);
        } 
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct1.Id;
        acctServ.Service__c = newSer.Id;
        Insert acctServ;
        System.assert(acctServ.Id != null, 'Account2Service creation failed');
        for(case cs:caseList){
            cs.Send_Method__c = Constants.CASE_SEND_METHOD_ENTITY_PORTAL;
            cs.Send_Method_Override_Comments__c = 'test';
        }
        string errorMsg = '';
        try{
            test.startTest();
            RecursiveTriggerHandler.isFirstTimeBeforeUpdate = true;
            update caseList;
            test.stopTest();
        }
        catch(Exception ex){            
            errorMsg = ex.getMessage();
        }
        string actualErrorMsg = [Select Error_Message__c from Error_Message__mdt where DeveloperName = 'Send_Method_Entity' limit 1].Error_Message__c;
        system.assert(String.isNotBlank(errorMsg),'Send method- No error thrown');
        system.assert(errorMsg.contains(actualErrorMsg),'Send method- Error not present');
    }
    // US 11136 & US 16089-To check if Send method is selected as Entity Portal, then Alternate Entity's Account2Service should be active else it should throw error.	
    @isTest
    static void testsendMethodErrorAlternate(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<case>();        
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct);
        Account acct1 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct1);
        insert acctList;
        for(Account acc:acctList){
            System.assert(acc.Id!= null,acc.Name+' '+ACCOUNT_CREATION_FAILED);
        }        
        Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase.ContactId = con.Id;
        credVerCase.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase.Entity__c = acct.Id; 
        caseList.add(credVerCase);
        Case credVerCase1 = new Case();
        credVerCase1.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase1.ContactId = con.Id;
        credVerCase1.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase1.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase1.Entity__c = acct.Id;
        credVerCase1.Alternate_Entity__c = acct1.Id;
        caseList.add(credVerCase1);
        Case credVerCase2 = new Case();
        credVerCase2.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase2.ContactId = con.Id;
        credVerCase2.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase2.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase2.Entity__c = acct1.Id;
        caseList.add(credVerCase2);
        Insert caseList;
        for(Case cs:caseList){
            System.assert(cs.Id != null,CASE_CREATION_FAILED);
        }
        Id affCVRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Affirmation__c affirmation = new Affirmation__c();
        affirmation.RecordTypeId = affCVRecordTypeId;
        affirmation.Case__c = credVerCase1.Id;
        affirmation.Verify_with_Alternate_Entity__c = true;
        insert affirmation;
        System.assert(affirmation.Id != null, 'Affirmation creation failed');
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct1.Id;
        acctServ.Service__c = newSer.Id;
        Insert acctServ;
        System.assert(acctServ.Id != null, 'Account2Service creation failed');
        for(case cs:caseList){
            cs.Send_Method__c = Constants.CASE_SEND_METHOD_ENTITY_PORTAL;
            cs.Send_Method_Override_Comments__c = 'test';
        }
        string errorMsg = '';
        try{
            test.startTest();
            RecursiveTriggerHandler.isFirstTimeBeforeUpdate = true;
            update caseList;
            test.stopTest();
        }
        catch(Exception ex){
            errorMsg = ex.getMessage();
        }
        string actualErrorMsg = [SELECT Error_Message__c FROM Error_Message__mdt WHERE DeveloperName=:Constants.ERROR_SEND_METHOD_ENTITY LIMIT 1].Error_Message__c;
        system.assert(String.isNotBlank(errorMsg),'Send method- No error thrown');
        system.assert(errorMsg.contains(actualErrorMsg),'Send method- Error not present');
    }
    // US 11136 & US 16089-To check if Send method Comments is not blank and is changed when send method is changed without changing Entity/Alternate Entity Portal.	
    @isTest
    static void testsendMethodCommentError(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        List<Account> acctList = new List<Account>();  
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct);
        Account acct1 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct1);
        insert acctList;
        for(Account acc:acctList){
            System.assert(acc.Id!=null,acc.Name+' '+ACCOUNT_CREATION_FAILED);
        }
        Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase.ContactId = con.Id;
        credVerCase.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase.Entity__c = acct.Id;
        insert credVerCase;
        System.assert(credVerCase.Id!= null,CASE_CREATION_FAILED);
        credVerCase.Send_Method__c = Constants.CASE_SEND_METHOD_ENTITY_PORTAL;
        credVerCase.Send_Method_Override_Comments__c = ConstantsTest.TEST_STRING;
        update credVerCase;
        system.assertEquals(credVerCase.Send_Method_Override_Comments__c,[SELECT Id,Send_Method_Override_Comments__c FROM Case WHERE Id=:credVerCase.Id].Send_Method_Override_Comments__c,'Case record is not updated');
        string errorMsg = '';
        credVerCase.Send_Method__c = Constants.CASE_SEND_METHOD_EMAIL;
        credVerCase.List_of_emails__c = ConstantsTest.TEST_STRING;
        try{
            test.startTest();
            RecursiveTriggerHandler.isFirstTimeBeforeUpdate = true;
            Constants.isnotUpdatedbySendMethodFlow = true;
            update credVerCase;
            test.stopTest();
        }
        catch(Exception ex){
            errorMsg = ex.getMessage();
        }
        string actualErrorMsg = [SELECT Error_Message__c FROM Error_Message__mdt WHERE DeveloperName=:Constants.ERROR_SEND_METHOD_COMMENTS LIMIT 1].Error_Message__c;
        system.assert(String.isNotBlank(errorMsg),'Send method comments- No error thrown');
        system.assert(errorMsg.contains(actualErrorMsg),'Send method comments- Error not present');
    }
    //Fails to generate USMLE ID
    @isTest
    static void testGenerateUsmleIdReturnsFailure(){
        List<string> usmleIds = caseTriggerHelper.genUsmleId();
        caseTriggerHelper.updateSequence(usmleIds[1]);
        List<Contact> contactList = new List<Contact>();
        Contact c1 = new Contact(Firstname='firstname1',Lastname='lastname1',email='email@test1.com',USMLE_ID__c=usmleIds[0]);
        contactList.add(c1);
        usmleIds.clear();
        usmleIds = caseTriggerHelper.genUsmleId();
        Contact c2 = new Contact(Firstname='firstname2',Lastname='lastname2',email='email@test3.com',USMLE_ID__c=usmleIds[0]);
        contactList.add(c2);
        insert contactList;
        for(Contact con :contactList){
            System.assert(con.Id != null,'Contact creation failed');
        }        
        USMLE_Sequence__c t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
        t.Sequence__c = Constants.USMLE_SEQUENCE_START_VALUE;
        update t; 
        system.assertEquals(Constants.USMLE_SEQUENCE_START_VALUE,USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId()).Sequence__c,'Update of USMLE sequence failed.');
        Case oldCase = [SELECT Id, Internal_Status__c, ContactId
                         FROM Case
                         WHERE Internal_Status__c =: Constants.CASE_STATUS_NEW
                         LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Case newCase = new Case(ContactId = oldCase.ContactId,
                                Internal_Status__c = Constants.CASE_STATUS_SUBMITTED,
                                recordTypeId = recordTypeId);
        insert newCase;
        system.assert(newcase.Id != null,'Case insertion failed');
        Case testCase = [SELECT Id, recordType.DeveloperName, Internal_Status__c, ContactId, Contact.USMLE_ID__c
                          FROM Case
                          WHERE Id =: newCase.Id
                          LIMIT 1];
        Test.startTest();
        string errMsg = '';
        try{
            CaseTriggerHelper.generateUsmleId(testCase, oldCase);
        }
        catch(Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Error generating New USMLE_ID!',errMsg,'Error generation failed for Usmle Id generation');
    }
    // US 13410 - method to cover updateAssetOfVP, updateAssetOfVPRefactor, updateAssetOfVPRefactor2 in CaseTriggerHelper class 
    @isTest
    static void testupdateAssetOfVP(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id credRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id verfRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        List<Account> acctList = new List<Account>();  
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct);
        Account acct1 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct1);
        INSERT acctList;
        for(Account acc:acctList){
            System.assert(acc.Id!=null, 'Account failed to create');
        }        
        Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase.ContactId = con.Id;
        credVerCase.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase.Entity__c = acct.Id;
        credVerCase.Document_Type__c = constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        INSERT credVerCase;
        System.assert(credVerCase.Id!=null, 'CV case creation failed');
        RecursiveTriggerHandler.isFirstTime = true;
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = credVerCase.Id;
        vp.Contact__c = con.Id;
        vp.Is_Active__c = true;
        INSERT vp; 
        System.assert(vp.Id!=null, 'vp creation failed');
        Asset asst = new Asset();
        asst.Name = Constants.ASSET_TYPE_ONLINE_VERIFICATION;
        asst.Status = Constants.ASSET_STATUS_NEW;
        asst.contactId = con.Id;
        asst.Type__c = Constants.ASSET_TYPE_ONLINE_VERIFICATION;       
        asst.RecordTypeId = verfRecTypId;
        asst.case__c = credVerCase.Id;
        Asset asst2 = new Asset();
        asst2.Name = Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER;
        asst2.Status = Constants.ASSET_STATUS_NEW;
        asst2.contactId = con.Id;
        asst2.Type__c = Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER;     
        asst2.RecordTypeId = verfRecTypId;
        asst2.case__c = credVerCase.Id;
        Asset asst3 = new Asset();
        asst3.Name = 'Verified '+constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst3.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst3.contactId = con.Id;
        asst3.Type__c = 'Verified Credential';     
        asst3.RecordTypeId = credRecTypId;
        asst3.case__c = credVerCase.Id;
        List<Asset> assetList = new List<Asset>();
        assetList.add(asst);    
        assetList.add(asst2);  
        assetList.add(asst3);   
        INSERT assetList;
        for(Asset assetRec:assetList){      
            System.assert(assetRec.Id!=null, 'Asset Creation Failed');
        }
        Asset2Verification__c asset2Vp = new Asset2Verification__c();
        asset2Vp.Asset__c = assetList[0].Id;
        asset2Vp.Verification_Packet__c = vp.Id;
        Asset2Verification__c asset2Vp1 = new Asset2Verification__c();
        asset2Vp1.Asset__c = assetList[1].Id;
        asset2Vp1.Verification_Packet__c = vp.Id;
        Asset2Verification__c asset2Vp2 = new Asset2Verification__c();
        asset2Vp2.Asset__c = assetList[2].Id;
        asset2Vp2.Verification_Packet__c = vp.Id;
        List<Asset2Verification__c> asset2VpList = new List<Asset2Verification__c>();
        asset2VpList.add(asset2Vp);
        asset2VpList.add(asset2Vp1);
        asset2VpList.add(asset2Vp2);
        INSERT asset2VpList;
        for(Asset2Verification__c asset2VpRec:asset2VpList){
            System.assert(asset2VpRec.Id!=null, 'asset2VpRec failed to create');
        }
        credVerCase.Send_Method__c = 'Website';
        credVerCase.Send_Method_Override_Comments__c = 'test comments';
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        UPDATE credVerCase;
        List<case> newCases = new List<case>([SELECT Id,Send_Method_Override_Comments__c FROM Case WHERE Id=:credVerCase.Id]);
        system.assertEquals(credVerCase.Send_Method_Override_Comments__c, newCases[0].Send_Method_Override_Comments__c, 'Case record update failed');
    }
    // US 11951- Method to test update affirmation on changing Case status and owner to Not Verified
    @isTest
    static void testupdateAffirmation(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        Insert acct;
        System.assert(acct.Id != null,acct.Name+' '+ACCOUNT_CREATION_FAILED);
        Case caseCV = new Case();
        caseCV.RecordTypeId = Constants.CVRECORDTYPEID;
        caseCV.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseCV.Entity__c = acct.Id;
        caseCV.ContactId = [SELECT Id FROM Contact Limit 1].Id;
        Insert caseCV;
        System.assert(caseCV.Id != null,'CV case creation failed');
        Affirmation__c affCV = new Affirmation__c();
        affCV.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        affCV.Case__c = caseCV.Id;
        Insert affCV;
        System.assert(affCV.Id != null,'CV affirmation creation failed');
        Affirmation__c affNotVerified = new Affirmation__c();
        affNotVerified.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_NOT_VERIFIED).getRecordTypeId();
        affNotVerified.Case__c = caseCV.Id;
        affNotVerified.Comments__c = ConstantsTest.TEST_STRING;
        affNotVerified.Not_Verified_Next_Step__c = 'Not Authentic';
        Insert affNotVerified;
        System.assert(affNotVerified.Id != null,'Not Verified affirmation creation failed');
        Test.startTest();
        RecursiveTriggerHandler.isFirstTimeBeforeUpdate = true;
        caseCV.Internal_Status__c = Constants.CASE_STATUS_NOT_VERIFIED;
        caseCV.OwnerId = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_NOT_VERIFIED_NAME).Id;
        Update caseCV;
        System.assert(caseCV.Internal_Status__c == Constants.CASE_STATUS_NOT_VERIFIED,'CV case update failed');
        Test.stopTest();
        Affirmation__c affNotVeriPostUpd = [SELECT Id,Not_Verified_Next_Step__c,Comments__c FROM Affirmation__c WHERE Id=:affNotVerified.Id];
        system.assert(String.isBlank(affNotVeriPostUpd.Comments__c),'Affirmation Comment is not made as null');
        system.assert(String.isBlank(affNotVeriPostUpd.Not_Verified_Next_Step__c),'Affirmation Next Step is not made as null');
    }
    // US 11952- Method to test update asset status to unverified on changing Case status to Unable to certify credential.
    @isTest
    static void testupdateAssetUnverified(){
        Contact con = [SELECT Id FROM Contact Limit 1];
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id credRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id verfRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        Insert acct;
        System.assert(acct.Id != null,acct.Name+' '+ACCOUNT_CREATION_FAILED);
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = Constants.CVRECORDTYPEID;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        credVerCase.Entity__c = acct.Id;
        credVerCase.ContactId = con.Id;
        Insert credVerCase;
        System.assert(credVerCase.Id != null,'CV case creation failed');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = credVerCase.Id;
        vp.Contact__c = con.Id;
        vp.Is_Active__c = true;
        INSERT vp;
        System.assert(vp.Id!=null, 'vp creation failed');
        Asset asst = new Asset();
        asst.Name = Constants.ASSET_TYPE_VERIFICATION_FORM;
        asst.Status = Constants.ASSET_STATUS_NEW;
        asst.contactId = con.Id;
        asst.Type__c = Constants.ASSET_TYPE_VERIFICATION_FORM;       
        asst.RecordTypeId = verfRecTypId;
        asst.case__c = credVerCase.Id;
        Asset asst1 = new Asset();
        asst1.Name = Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER;
        asst1.Status = Constants.ASSET_STATUS_NEW;
        asst1.contactId = con.Id;
        asst1.Type__c = Constants.ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER;     
        asst1.RecordTypeId = verfRecTypId;
        asst1.case__c = credVerCase.Id;
        Asset asst2 = new Asset();
        asst2.Name = 'Verified '+constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst2.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst2.contactId = con.Id;
        asst2.Type__c = 'Verified Credential';     
        asst2.RecordTypeId = credRecTypId;
        asst2.case__c = credVerCase.Id;
        List<Asset> assetList = new List<Asset>();
        assetList.add(asst);    
        assetList.add(asst1);  
        assetList.add(asst2);   
        INSERT assetList;
        for(Asset assetRec:assetList){      
            System.assert(assetRec.Id!=null, 'Asset Creation Failed');
        }
        Asset2Verification__c asset2Vp = new Asset2Verification__c();
        asset2Vp.Asset__c = assetList[0].Id;
        asset2Vp.Verification_Packet__c = vp.Id;
        asset2Vp.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        Asset2Verification__c asset2Vp1 = new Asset2Verification__c();
        asset2Vp1.Asset__c = assetList[1].Id;
        asset2Vp1.Verification_Packet__c = vp.Id;
        asset2Vp.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SOURCE;
        Asset2Verification__c asset2Vp2 = new Asset2Verification__c();
        asset2Vp2.Asset__c = assetList[2].Id;
        asset2Vp2.Verification_Packet__c = vp.Id;
        asset2Vp2.Document_Type__c = Constants.ASSET2VER_DOCTYPE_ACC_VER_FORM;
        List<Asset2Verification__c> asset2VpList = new List<Asset2Verification__c>();
        asset2VpList.add(asset2Vp);
        asset2VpList.add(asset2Vp1);
        asset2VpList.add(asset2Vp2);
        INSERT asset2VpList;
        for(Asset2Verification__c asset2VpRec:asset2VpList){
            System.assert(asset2VpRec.Id!=null, 'asset2VpRec failed to create');
        }
        asset2Vp1.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        update asset2Vp1;
        System.assert(asset2Vp1.Document_Type__c == Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM,'asset2VpRec update failed');
        Test.startTest();
        RecursiveTriggerHandler.isFirstTimeBeforeUpdate = true;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_UNABLE_TO_VERIFY_CRED;
        Update credVerCase;
        System.assert(credVerCase.Internal_Status__c == Constants.CASE_STATUS_UNABLE_TO_VERIFY_CRED,'CV case update failed');
        Test.stopTest();
        system.assertEquals(2,[SELECT Count() FROM Asset WHERE Id in:assetList AND Status =: Constants.ASSET_STATUS_UNVERIFIED],'Asset is not updated');
    }
    // Test method to check the sharing rules for Credential verification and Entity User request cases on change of entity/alternate entity/Owner.
    @isTest
    static void testAlternateEntityChange(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<case>();        
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct);
        Account acct1 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct1);
        Account acct2 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct2);
        insert acctList;
        for(Account acc:acctList){
            System.assert(acc.Id!= null,acc.Name+' '+ACCOUNT_CREATION_FAILED);
        }
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        System.assert(newSer.Id != null,'Service creation failed');
        Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case credVerCase1 = new Case();
        credVerCase1.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase1.ContactId = con.Id;
        credVerCase1.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase1.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase1.Entity__c = acct.Id;
        credVerCase1.Alternate_Entity__c = acct1.Id;
        caseList.add(credVerCase1);
        Case credVerCase2 = new Case();
        credVerCase2.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase2.ContactId = con.Id;
        credVerCase2.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase2.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase2.Entity__c = acct1.Id;
        caseList.add(credVerCase2);
        Case credVerCase3 = new Case();
        credVerCase3.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase3.ContactId = con.Id;
        credVerCase3.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase3.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase3.Entity__c = acct.Id;
        credVerCase3.Alternate_Entity__c = acct1.Id;
        caseList.add(credVerCase3);
        Case credVerCase4 = new Case();
        credVerCase4.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase4.ContactId = con.Id;
        credVerCase4.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase4.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase4.Entity__c = acct.Id;
        credVerCase4.Alternate_Entity__c = acct1.Id;
        caseList.add(credVerCase4);
        Id entityUserRequestRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST);
    	Case entityUserServiceRequestCase2 = new Case();
        entityUserServiceRequestCase2.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase2.ContactId = con.Id;
        entityUserServiceRequestCase2.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase2.Service_Name__c = newSer.id;
        entityUserServiceRequestCase2.Entity__c = acct.id;
        caseList.add(entityUserServiceRequestCase2);
        Insert caseList;
        for(Case cs:caseList){
            System.assert(cs.Id != null,CASE_CREATION_FAILED);
        }
        Id affCVRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION);
        List<Affirmation__c> affList = new List<Affirmation__c>();
        Affirmation__c affirmation = new Affirmation__c();
        affirmation.RecordTypeId = affCVRecordTypeId;
        affirmation.Case__c = credVerCase1.Id;
        affirmation.Verify_with_Alternate_Entity__c = true;
        affList.add(affirmation);
        Affirmation__c affirmation1 = new Affirmation__c();
        affirmation1.RecordTypeId = affCVRecordTypeId;
        affirmation1.Case__c = credVerCase3.Id;
        affirmation1.Verify_with_Alternate_Entity__c = false;
        affList.add(affirmation1);
        Affirmation__c affirmation2 = new Affirmation__c();
        affirmation2.RecordTypeId = affCVRecordTypeId;
        affirmation2.Case__c = credVerCase4.Id;
        affirmation2.Verify_with_Alternate_Entity__c = false;
        affList.add(affirmation2);
        insert affList;
        System.assert(affirmation.Id != null, 'Affirmation creation failed');
        List<affirmation__c> updateAff = new List<Affirmation__c>();
        affirmation1.Verify_with_Alternate_Entity__c = true;
        updateAff.add(affirmation1);
        affirmation2.Verify_with_Alternate_Entity__c = true;
        updateAff.add(affirmation2);
        update updateAff;
        List<Account2Service__c> acc2SerList = new List<Account2Service__c>();
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct1.Id;
        acctServ.Service__c = newSer.Id;
        acc2SerList.add(acctServ);
        Account2Service__c acctServ1 = new Account2Service__c();
        acctServ1.active__c = true;
        acctServ1.Account__c = acct.Id;
        acctServ1.Service__c = newSer.Id;
        acc2SerList.add(acctServ1);
        Account2Service__c acctServ2 = new Account2Service__c();
        acctServ1.active__c = true;
        acctServ1.Account__c = acct.Id;
        acctServ1.Service__c = newSer.Id;
        acc2SerList.add(acctServ2);
        Insert acc2SerList;
        for(Account2Service__c acc2SerRec:acc2SerList){
            System.assert(acc2SerRec.Id != null,'Account2Service creation failed');
        }
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact(AccountID = acct2.id, FirstName = 'User', LastName = 'test', email = '1'+Constants.TEST_EMAIL_ID);
        conList.add(con1);
        Contact con2 = new Contact(AccountID = acct1.id, FirstName = 'User', LastName = 'test', email = Constants.TEST_EMAIL_ID);
        conList.add(con2);
        INSERT conList;
        for(Contact cont:conList){
            System.assert(cont.Id != null, 'Contact is not inserted');
        }
        List<CONTACT2ACCTSERVICE__c> con2AccserList = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj.Role__c = 'User';
        conAccServiceObj.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj.Physical_Address__c = PHY_ADDRESS;
        conAccServiceObj.List_of_emails__c = '';
        conAccServiceObj.Verification_Website_URL__c = '';
        conAccServiceObj.Credential_Type__c = 'Letter from Dean';
        conAccServiceObj.Account_Service__c = acctServ.Id;
        conAccServiceObj.Service_Contact__c = con.Id;
        conAccServiceObj.Active__c = true;
        con2AccserList.add(conAccServiceObj);
        CONTACT2ACCTSERVICE__c conAccServiceObj1 = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj1.Role__c = 'User';
        conAccServiceObj1.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj1.Physical_Address__c = PHY_ADDRESS;
        conAccServiceObj1.List_of_emails__c = '';
        conAccServiceObj1.Verification_Website_URL__c = '';
        conAccServiceObj1.Credential_Type__c = 'Letter from Dean';
        conAccServiceObj1.Account_Service__c = acctServ1.Id;
        conAccServiceObj1.Service_Contact__c = con1.Id;
        conAccServiceObj1.Active__c = true;
        con2AccserList.add(conAccServiceObj1);
        CONTACT2ACCTSERVICE__c conAccServiceObj2 = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj2.Role__c = 'User';
        conAccServiceObj2.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj2.Physical_Address__c = PHY_ADDRESS;
        conAccServiceObj2.List_of_emails__c = '';
        conAccServiceObj2.Verification_Website_URL__c = '';
        conAccServiceObj2.Credential_Type__c = 'Letter from Dean';
        conAccServiceObj2.Account_Service__c = acctServ2.Id;
        conAccServiceObj2.Service_Contact__c = con2.Id;
        conAccServiceObj2.Active__c = true;
        con2AccserList.add(conAccServiceObj2);
        INSERT con2AccserList;
        for(CONTACT2ACCTSERVICE__c cont2acc:con2AccserList){
            System.assert(cont2acc.Id != null, 'Contact2Acc is not inserted');
        }
        ID profileID = [Select id from Profile where name =: Constants.Entity_360_USER_PROFILE].id;
        User user2 = BaseTestFactory.getContactUser(Con2.id,profileID);
        System.assert(user2.Id != null, USER_NOT_INS);
        User user1 = BaseTestFactory.getContactUser(Con1.id,profileID);
        System.assert(user1.Id != null, USER_NOT_INS);        
        for(case cs:caseList){
            if(cs.Id != credVerCase3.Id){
                cs.Entity__c = acct2.Id;
                cs.Alternate_Entity__c = acct2.Id;
            }else{
                cs.OwnerId = user2.Id;
            }
        }
        string errorMsg = '';
        try{
            test.startTest();
            update caseList;
            test.stopTest();
        }
        catch(Exception ex){
            errorMsg = ex.getMessage();
        }
        system.assert(String.isBlank(errorMsg),'Error thrown ' + errorMsg);
    }
    // Test method to check the sharing rules for Entity User request cases on change of entity/Owner.
    @isTest
    public static void testEntityUserRequest(){
        Id idAccountTypeId = GenericUtilities.getRecordTypeIdByDevName('Account','Entity');
        List<Account> acctList = new List<Account>();
        Account acct = new Account(Name=ACCOUNT_NAME,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct);
        Account acct1 = new Account(Name=ACCOUNT_NAME1,RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        acctList.add(acct1);
        INSERT acctList;
        for(Account acc:acctList){
            System.assert(acc.Id!= null,acc.Name+' '+ACCOUNT_CREATION_FAILED);
        }
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Contact con1 = new Contact(AccountID = acct1.id, FirstName = 'User', LastName = 'test', email = '1'+Constants.TEST_EMAIL_ID);
        Insert con1;
        System.assert(con1.Id!= null,'Contact insertion failed');
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        System.assert(newSer.Id != null,'Service creation failed');
        List<Account2Service__c> acc2SerList = new List<Account2Service__c>();
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct1.Id;
        acctServ.Service__c = newSer.Id;
        acc2SerList.add(acctServ);
        Account2Service__c acctServ1 = new Account2Service__c();
        acctServ1.active__c = true;
        acctServ1.Account__c = acct.Id;
        acctServ1.Service__c = newSer.Id;
        acc2SerList.add(acctServ1);
        Insert acc2SerList;
        for(Account2Service__c acc2SerRec:acc2SerList){
            System.assert(acc2SerRec.Id != null,'Account2Service creation failed');
        }
        List<CONTACT2ACCTSERVICE__c> con2AccserList = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj.Role__c = 'User';
        conAccServiceObj.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj.Physical_Address__c = PHY_ADDRESS;
        conAccServiceObj.List_of_emails__c = '';
        conAccServiceObj.Verification_Website_URL__c = '';
        conAccServiceObj.Credential_Type__c = CRED_TYPE;
        conAccServiceObj.Account_Service__c = acctServ.Id;
        conAccServiceObj.Service_Contact__c = con.Id;
        conAccServiceObj.Active__c = true;
        con2AccserList.add(conAccServiceObj);
        CONTACT2ACCTSERVICE__c conAccServiceObj1 = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj1.Role__c = 'User';
        conAccServiceObj1.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj1.Physical_Address__c = PHY_ADDRESS;
        conAccServiceObj1.List_of_emails__c = '';
        conAccServiceObj1.Verification_Website_URL__c = '';
        conAccServiceObj1.Credential_Type__c = CRED_TYPE;
        conAccServiceObj1.Account_Service__c = acctServ1.Id;
        conAccServiceObj1.Service_Contact__c = con1.Id;
        conAccServiceObj1.Active__c = true;
        con2AccserList.add(conAccServiceObj1);
        CONTACT2ACCTSERVICE__c conAccServiceObj2 = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj2.Role__c = 'User';
        conAccServiceObj2.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj2.Physical_Address__c = PHY_ADDRESS;
        conAccServiceObj2.List_of_emails__c = '';
        conAccServiceObj2.Verification_Website_URL__c = '';
        conAccServiceObj2.Credential_Type__c = CRED_TYPE;
        conAccServiceObj2.Account_Service__c = acctServ.Id;
        conAccServiceObj2.Service_Contact__c = con.Id;
        conAccServiceObj2.Active__c = true;
        con2AccserList.add(conAccServiceObj2);
        INSERT con2AccserList;
        for(CONTACT2ACCTSERVICE__c cont2acc:con2AccserList){
            System.assert(cont2acc.Id != null, 'Contact2Acc is not inserted');
        }
        ID profileID = [Select id from Profile where name =: Constants.Entity_360_USER_PROFILE].id;
        User user1 = BaseTestFactory.getContactUser(Con1.id,profileid);
        System.assert(user1.Id != null, USER_NOT_INS);
        Id entityUserRequestRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST);
    	List<Case> caseList = new List<Case>();
        Case entityUserServiceRequestCase1 = new Case();
        entityUserServiceRequestCase1.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase1.ContactId = con1.Id;
        entityUserServiceRequestCase1.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase1.Service_Name__c = newSer.id;
        entityUserServiceRequestCase1.Entity__c = acct.id;
        caseList.add(entityUserServiceRequestCase1);
        Case entityUserServiceRequestCase2 = new Case();
        entityUserServiceRequestCase2.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase2.ContactId = con1.Id;
        entityUserServiceRequestCase2.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase2.Service_Name__c = newSer.id;
        entityUserServiceRequestCase2.Entity__c = acct.id;
        caseList.add(entityUserServiceRequestCase2);
        INSERT caseList;
        for(Case cs:caseList){
            System.assert(cs.Id != null,CASE_CREATION_FAILED);
        }
        for(case cs:caseList){
            cs.Entity__c = acct1.Id;
        }
        string errorMsg = '';
        try{
            test.startTest();
            update caseList;
            test.stopTest();
        }
        catch(Exception ex){
            errorMsg = ex.getMessage();
        }
        system.assert(String.isBlank(errorMsg),'Error thrown ' + errorMsg);        
    }*/
}