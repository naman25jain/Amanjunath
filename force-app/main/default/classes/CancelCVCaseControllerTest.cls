@IsTest
public with sharing class CancelCVCaseControllerTest{
    Static final String CONTACT_QUERY_ERROR = 'Contact not found';
    Static final String USER_QUERY_ERROR = 'User not found';
    Static final String ACCOUNT_QUERY_ERROR = 'Account not found';
    Static final String CASE_QUERY_ERROR = 'Case not found';
    Static final String ASSET_NOT_CREATED = 'Asset not created';
    Static final String CASE_ASSET_NOT_UPDATED = 'Case and related assets are not updated';
    Static final String CREDENTIAL_REQUEST = 'Credential Request';
    Static final String DAY = '12/1/1996';
    Static final String ADVANCED_DEGREE_IN_MEDICAL_SCIENCES = 'Advanced Degree in the Medical Sciences';
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = Date.parse(DAY);
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not created');
        Id profId = [Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user1 = new User(alias = 'testUser',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testuser@test.com');
        INSERT user1;
        System.assert(user1.Id!=null, USER_QUERY_ERROR);
    }
    @IsTest
    public static void testcheckCVStatus(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null, USER_QUERY_ERROR); 
        Account acc = [SELECT Id FROM Account LIMIT 1];
        System.assert(acc.Id != null, ACCOUNT_QUERY_ERROR);
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id fcvsRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_FCVS_REQUEST).getRecordTypeId();
        Id medFormCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW_AT_ENTITY;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.ContactId = usr.contactId;
        caseRecord.AccountId = acc.Id;
        caseList.add(caseRecord);
        Case caseRecordEICS = new Case();
        caseRecordEICS.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseRecordEICS.RecordTypeId = credVerRTId;
        caseRecordEICS.Service__c = 'EICS';
        caseRecordEICS.ContactId = usr.contactId;
        caseRecordEICS.AccountId = acc.Id;
        caseRecordEICS.Verification_Request_Source__c = 'MCC';
        caseList.add(caseRecordEICS);
        Case caseRecordFCVS = new Case();
        caseRecordFCVS.Internal_Status__c = Constants.CASE_STATUS_NEW;
        caseRecordFCVS.RecordTypeId = fcvsRecTypeId;
        caseRecordFCVS.Service__c = 'FCVS';
        caseRecordFCVS.ContactId = usr.contactId;
        caseRecordFCVS.AccountId = acc.Id;
        caseList.add(caseRecordFCVS);
        Case cv1 = new Case();
        cv1.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        cv1.RecordTypeId = credVerRTId;
        cv1.Service__c = 'FCVS';
        cv1.ContactId = usr.contactId;
        cv1.AccountId = acc.Id;
        cv1.ParentId = caseRecordFCVS.Id;
        cv1.Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        caseList.add(cv1);
        Case cv2 = new Case();
        cv2.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        cv2.RecordTypeId = credVerRTId;
        cv2.Service__c = 'FCVS';
        cv2.ContactId = usr.contactId;
        cv2.AccountId = acc.Id;
        cv2.ParentId = caseRecordFCVS.Id;
        cv2.Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
        caseList.add(cv2);
        Case medForm = new Case();
        medForm.Internal_Status__c = Constants.CASE_STATUS_NEW;
        medForm.RecordTypeId = medFormCaseRTId;
        medForm.Service__c = 'FCVS';
        medForm.ContactId = usr.contactId;
        medForm.AccountId = acc.Id;
        medForm.ParentId = caseRecordFCVS.Id;
        medForm.Document_Type__c = 'Medical Education Form';
        caseList.add(medForm);
        INSERT caseList;
        Id veriAssetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();  
        Id credAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id idenAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
        Id medformRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = caseRecord.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = veriAssetRecTypeId);
        INSERT asst1;
        System.assert(asst1.Id != null, ASSET_NOT_CREATED);
        Asset asst2 = new Asset(Name = CREDENTIAL_REQUEST,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = caseRecord.Id,
                                InstallDate = System.Today(),
                                Type__c	= ADVANCED_DEGREE_IN_MEDICAL_SCIENCES,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asst2;
        System.assert(asst2.Id != null, ASSET_NOT_CREATED);
        Verification_Packet__c verPckt = new Verification_Packet__c();
        verPckt.Case__c = caseRecord.Id;
        verPckt.Request_additional_information__c = null;
        verPckt.Entity_provide_the_credential__c = false;
        verPckt.Is_Active__c = true;
        INSERT verPckt;
        System.assert(verPckt.Id != null, 'verification packet not found');
        String error = '';
        String selectedValue = 'Cancelled by ECFMG';
        String reason = 'Testing comments';
        Asset asstEICS1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                ContactId = usr.contactId,
                                Case__c = caseRecordEICS.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = veriAssetRecTypeId);
        INSERT asstEICS1;
        System.assert(asstEICS1.Id != null, ASSET_NOT_CREATED);
        Asset asstEICS2 = new Asset(Name = CREDENTIAL_REQUEST,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = caseRecordEICS.Id,
                                InstallDate = System.Today(),
                                Type__c	= ADVANCED_DEGREE_IN_MEDICAL_SCIENCES,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asstEICS2;
        System.assert(asstEICS2.Id != null, ASSET_NOT_CREATED);
        Asset asstEICS3 = new Asset(Name = 'MCC Release Form',
                                Status = Constants.ASSET_STATUS_VERIFIED,
                                ContactId = usr.contactId,
                                Case__c = caseRecordEICS.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_RELEASE,
                               	RecordTypeId = idenAsstRecTypeId);
        INSERT asstEICS3;
        System.assert(asstEICS3.Id != null, ASSET_NOT_CREATED);
        Verification_Packet__c verPcktEICS = new Verification_Packet__c();
        verPcktEICS.Case__c = caseRecordEICS.Id;
        verPcktEICS.Request_additional_information__c = null;
        verPcktEICS.Entity_provide_the_credential__c = false;
        verPcktEICS.Is_Active__c = true;
        INSERT verPcktEICS;
        System.assert(verPcktEICS.Id != null, 'verification packet not found');
        Asset asstFCVS1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = cv1.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = veriAssetRecTypeId);
        INSERT asstFCVS1;
        System.assert(asstFCVS1.Id != null, ASSET_NOT_CREATED);
        Asset asstFCVS2 = new Asset(Name = CREDENTIAL_REQUEST,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = cv1.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asstFCVS2;
        System.assert(asstFCVS2.Id != null, ASSET_NOT_CREATED);
        Asset asstFCVS3 = new Asset(Name = 'Medical Education Form',
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = medForm.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.MED_EDU_FORM,
                               	RecordTypeId = medformRecTypeId);
        INSERT asstFCVS3;
        System.assert(asstFCVS3.Id != null, ASSET_NOT_CREATED);
        Verification_Packet__c vpFCVS1 = new Verification_Packet__c();
        vpFCVS1.Case__c = cv1.Id;
        vpFCVS1.Request_additional_information__c = null;
        vpFCVS1.Entity_provide_the_credential__c = false;
        vpFCVS1.Is_Active__c = true;
        INSERT vpFCVS1;
        System.assert(vpFCVS1.Id != null, 'vp not found');
        try{
            Test.startTest();
            Case cvCase = CancelCVCaseController.checkCVCaseStatus(caseRecord.Id);
            System.assert(cvCase.Internal_Status__c == Constants.CASE_STATUS_IN_REVIEW_AT_ENTITY, 'Returned CV case is wrong');
            Case cvCaseEICS = CancelCVCaseController.checkCVCaseStatus(caseRecordEICS.Id);
            System.assert(cvCaseEICS.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION, 'Returned CV case is wrong');
            Boolean updatedOrNot = CancelCVCaseController.updateCVCase(caseRecord.Id, selectedValue, reason);
            System.assert(updatedOrNot == true, CASE_ASSET_NOT_UPDATED);
            Boolean updatedOrNotEICS = CancelCVCaseController.updateCVCase(caseRecordEICS.Id, '' , reason);
            System.assert(updatedOrNotEICS == true, CASE_ASSET_NOT_UPDATED);
            Boolean updatedOrNotFCVS = CancelCVCaseController.updateCVCase(caseRecordFCVS.Id, '' , reason);
            System.assert(updatedOrNotFCVS == true, CASE_ASSET_NOT_UPDATED);
            CancelCVCaseController.checkCVCaseStatus(null);
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
}