// Test class for EPICVerRepController
@isTest
public with sharing class EPICVerRepControllerTest{
    // Test setup
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        String billingCountry = 'India';
        BaseTestFactory.getCustomerCommunityPlusUser();
        User userRec = [SELECT Name,contactId,Id FROM User WHERE profile.Name =: ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN and contactId != '' ORDER BY CreatedDate Desc LIMIT 1];
        Id idAccountTypeId = GenericUtilities.getRecordTypeIdByDevName('Account','Entity');
        Id credRecTypId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constants.ASSET_RECORD_TYPE_CREDENTIAL);
        List<Account> acctList = new List<Account>();
        Account acct = new Account(Name='Account 1',RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=billingCountry);
        acctList.add(acct);
        Account acct1 = new Account(Name='Test account 2',RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=billingCountry);
        acctList.add(acct1);
        INSERT acctList;
        for(Account acc:acctList){
            System.assert(acc.Id!=null, 'Account failed to create');
        }
        Service__c newSer = new Service__c();
        newSer.Name = Constants.EPIC_SERVICENAME;
        Insert newSer;
        System.assert(newSer.Id != null,'Service creation failed');
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct1.Id;
        acctServ.Service__c = newSer.Id;
        Insert acctServ;
        System.assert(acctServ.Id != null,'Account2Service creation failed');
        Id credVerCaseRecordtypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
        String contactId = userRec.contactId;
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase.ContactId = contactId;
        credVerCase.Service__c = Constants.CASE_SERVICE_EPIC;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        credVerCase.Report_Type__c=System.Label.Report_Type_Other_Entity;
        credVerCase.Entity__c = acct.Id;
        credVerCase.document_Type__c = Constants.CASE_DOCUMENT_TYPE_TCT;
        Insert credVerCase;
        System.assert(credVerCase.Id!=null, 'CV case creation failed');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = credVerCase.Id;
        vp.Contact__c = contactId;
        vp.Is_Active__c = true;
        INSERT vp;
        System.assert(vp.Id!=null, 'vp creation failed');
        Asset asst = new Asset();
        asst.Name = Constants.ASSET_TYPE_TCT;
        asst.Status = Constants.ASSET_STATUS_NEW;
        asst.contactId = contactId;
        asst.Type__c = Constants.ASSET_TYPE_TCT;       
        asst.RecordTypeId = credRecTypId;
        asst.case__c = credVerCase.Id;
        Insert asst;
        System.assert(asst.Id!=null, 'Asset Creation Failed');
    }
    // test method for geting epic case list
    @isTest
    public static void getEpicCaseListTest(){
        User userRec = [SELECT Name,contactId,Id FROM User WHERE profile.Name =: ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN and contactId != '' ORDER BY CreatedDate Desc LIMIT 1];
        Test.startTest();
        System.runAs(userRec){
            System.assert(EPICVerRepController.getEpicCaseList()!=null,'getEpicCaseList did not return');
        }
        Test.stopTest();
    }
    @isTest
    public static void getAppForCertSummaryPDFUrl(){
        Case caseVar = new Case();
        User userRec = [SELECT Name,contactId,Id FROM User WHERE profile.Name =: ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN and contactId != '' ORDER BY CreatedDate Desc LIMIT 1];
        Test.startTest();
        System.runAs(userRec){
        System.assert(AppForCertHelper.getAppForCertSummaryPDFUrl(caseVar.Id)!=null,'getAppForCertSummaryPDFUrl did not return');
        }
        Test.stopTest();
    }
    // Test method for search reg org method
    @isTest
    public static void searchRegOrgTest(){
        Case csRecord = [SELECT Id,CaseNumber,Document_Type__c,Internal_Status__c,RecordType.DeveloperName,(SELECT Id,Type__c FROM Assets__R) FROM Case];
        EPICVerRepController.EpicVerRepWrap epicVerRepObj = new EPICVerRepController.EpicVerRepWrap();
        epicVerRepObj.key = csRecord.Id;
        epicVerRepObj.casNum = csRecord.CaseNumber;
        epicVerRepObj.docType = csRecord.Document_Type__c;
        epicVerRepObj.selected = true;
        epicVerRepObj.status = csRecord.Internal_Status__c;
        epicVerRepObj.recType = csRecord.RecordType.DeveloperName;
        epicVerRepObj.asst = csRecord.Assets__r[0].Id;
        epicVerRepObj.asstExist = true;
        epicVerRepObj.type = csRecord.Assets__r[0].Type__c;
        Test.startTest();
        System.assert(EPICVerRepController.searchRegOrg('Test account 2','['+JSON.serializePretty(epicVerRepObj)+']')!=null,'searchRegOrg did not return');
        Test.stopTest();
    }
    // Test method for Save Record Method
    @isTest
    public static void saveRecordTest(){
        Case csRecord = [SELECT Id,CaseNumber,Document_Type__c,Internal_Status__c,RecordType.DeveloperName,(SELECT Id,Type__c FROM Assets__R) FROM Case];
        executeTest(csRecord);
    }
    // Test Method for Save Record method for internal status as CV Accepted.
    @isTest
    public static void saveRecordTest1(){
        Case csRecord = [SELECT Id,CaseNumber,Document_Type__c,Internal_Status__c,RecordType.DeveloperName,(SELECT Id,Type__c FROM Assets__R) FROM Case];
        csRecord.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        executeTest(csRecord);
    }
    // Common method to test the saveRecord
    public static void executeTest(Case csRecord){
        EPICVerRepController.EpicVerRepWrap epicVerRepObj = new EPICVerRepController.EpicVerRepWrap();
        epicVerRepObj.key = csRecord.Id;
        epicVerRepObj.casNum = csRecord.CaseNumber;
        epicVerRepObj.docType = csRecord.Document_Type__c;
        epicVerRepObj.selected = true;
        epicVerRepObj.status = csRecord.Internal_Status__c;
        epicVerRepObj.recType = csRecord.RecordType.DeveloperName;
        epicVerRepObj.asst = csRecord.Assets__r[0].Id;
        epicVerRepObj.asstExist = true;
        epicVerRepObj.type = csRecord.Assets__r[0].Type__c;
        EPICVerRepController.EpicVerRepCreationWrap epicVerRepCreatObj = new EPICVerRepController.EpicVerRepCreationWrap();
        epicVerRepCreatObj.selectedAuthEntityId = [SELECT Id FROM Account WHERE Name = 'Test account 2'].Id;
        epicVerRepCreatObj.referenceNumber = '';
        epicVerRepCreatObj.emailAddress = '';
        epicVerRepCreatObj.verifyEmailAddress = '';
        epicVerRepCreatObj.contactPersonName = '';
        epicVerRepCreatObj.nameOfEntity = '';
        epicVerRepCreatObj.entityAddress = '';
        epicVerRepCreatObj.referenceNum = '';
        epicVerRepCreatObj.country = '';
        User userRec = [SELECT Name,contactId,Id FROM User WHERE profile.Name =: ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN and contactId != '' ORDER BY CreatedDate Desc LIMIT 1];
        Test.startTest();
        System.runAs(userRec){            
            System.assert(EPICVerRepController.saveRecord(System.Label.Applicant_can_search_for_an_Entity_which_will_receive_the_report, '['+JSON.serializePretty(epicVerRepObj)+']', JSON.serializePretty(epicVerRepCreatObj)).epicCase,'Entity search report was not created');
            epicVerRepCreatObj.selectedAuthEntityId = '';
            epicVerRepCreatObj.referenceNumber = '';
            epicVerRepCreatObj.emailAddress = '';
            epicVerRepCreatObj.verifyEmailAddress = '';
            epicVerRepCreatObj.contactPersonName = '';
            epicVerRepCreatObj.nameOfEntity = '';
            epicVerRepCreatObj.entityAddress = '';
            epicVerRepCreatObj.referenceNum = '';
            epicVerRepCreatObj.country = '';
            System.assert(EPICVerRepController.saveRecord(System.Label.Applicants_receive_a_report_for_themselves, '['+JSON.serializePretty(epicVerRepObj)+']', JSON.serializePretty(epicVerRepCreatObj)).epicCase,'Self report was not created');
            List<String> cvCases = new List<String>();
            cvCases.add(csRecord.Id);
            List<String> updatedRepCase = EPICVerRepController.epicReportStatusUpdate(cvCases);
            System.assert(!updatedRepCase.isEmpty(),'No epic report cases to be updated');
            epicVerRepCreatObj.selectedAuthEntityId = '';
            epicVerRepCreatObj.referenceNumber = '';
            epicVerRepCreatObj.emailAddress = 'test@test.com';
            epicVerRepCreatObj.verifyEmailAddress = 'test@test.com';
            epicVerRepCreatObj.contactPersonName = 'test';
            epicVerRepCreatObj.nameOfEntity = 'test';
            epicVerRepCreatObj.entityAddress = 'address';
            epicVerRepCreatObj.referenceNum = '';
            epicVerRepCreatObj.country = 'India';
            System.assert(EPICVerRepController.saveRecord(System.Label.Applicant_select_option_to_send_report_to_an_Entity_that_is_not_found_in_search, '['+JSON.serializePretty(epicVerRepObj)+']', JSON.serializePretty(epicVerRepCreatObj)).epicCase,'Entity not found report was not created');            
        }
        Test.stopTest();
    }
    // Checks if the report case is already created.
    @isTest
    public static void errorExisting(){
        Case csRecord = [SELECT ContactId,Id,CaseNumber,Document_Type__c,Internal_Status__c,Report_Type__c,
                         Secondary_Parent_Case__r.Internal_Status__c,RecordType.DeveloperName,(SELECT Id,Type__c FROM Assets__R) FROM Case];
        Id qId = [SELECT Id FROM Group WHERE type = 'Queue' AND Name =: Constants.CASE_QUEUE_EPIC_REP_REQ LIMIT 1].Id;
        Id recTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
        Case repCase = new Case();
        repCase.contactId = csRecord.ContactId;
        repCase.recordTypeId = recTypeId;
        repCase.Payment_History__c = 'Free report';
        repCase.OwnerId = qId;
        repCase.Internal_Status__c = 'Sent';
        repCase.External_Status__c = 'Sent';
        repCase.Report_Type__c = System.Label.Report_Type_Self;
        repCase.Secondary_Parent_Case__c = csRecord.Id;
        repCase.EPIC_Report_Status__c = 'Report Sent';
        repCase.EPIC_Report_Received_Date__c = System.today();
        Insert repCase;
        System.assert(repCase.Id!=null, 'EPIC report creation failed');
        EPICVerRepController.EpicVerRepWrap epicVerRepObj = new EPICVerRepController.EpicVerRepWrap();
        epicVerRepObj.key = csRecord.Id;
        epicVerRepObj.casNum = csRecord.CaseNumber;
        epicVerRepObj.docType = csRecord.Document_Type__c;
        epicVerRepObj.selected = true;
        epicVerRepObj.status = csRecord.Internal_Status__c;
        epicVerRepObj.recType = csRecord.RecordType.DeveloperName;
        epicVerRepObj.asst = csRecord.Assets__r[0].Id;
        epicVerRepObj.asstExist = true;
        epicVerRepObj.type = csRecord.Assets__r[0].Type__c;
        User userRec = [SELECT Name,contactId,Id FROM User WHERE profile.Name =: ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN and contactId != '' ORDER BY CreatedDate Desc LIMIT 1];
        Test.startTest();
        System.runAs(userRec){
            EPICVerRepController.EpicVerRepCreationWrap epicVerRepCreatObj = new EPICVerRepController.EpicVerRepCreationWrap();
            epicVerRepCreatObj.selectedAuthEntityId = '';
            epicVerRepCreatObj.referenceNumber = '';
            epicVerRepCreatObj.emailAddress = '';
            epicVerRepCreatObj.verifyEmailAddress = '';
            epicVerRepCreatObj.contactPersonName = '';
            epicVerRepCreatObj.nameOfEntity = '';
            epicVerRepCreatObj.entityAddress = '';
            epicVerRepCreatObj.referenceNum = '';
            epicVerRepCreatObj.country = '';
        }
        Test.stopTest();
    }
    
    @isTest
    public static void epicCaseListTest(){
        Test.startTest();
        List<String> stringListInput = new List<String>();
        stringListInput.add('Test');
        stringListInput.add('Test1');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case pCase = new Case();
        pCase.RecordTypeId = credVerRecTypeId;
        pCase.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        pCase.Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        INSERT pCase;
        System.assert(pCase.Id!=null, 'CV case insert failed');
        Case cCase = new Case();
        cCase.Secondary_Parent_Case__c = pCase.Id;
        pCase.Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        Insert cCase;
        System.assert(pCase.Id!=null, 'CV case insert failed');
        List<String> stringId = new List<String>();
        stringId.add(cCase.Id);
        stringId.add(pCase.Id);
        List<String> docName = new List<String>();
        docName.add('ECFMG_Certification');
        docName.add('EICS');
        docName.add('Final Medical Diploma');
        User userRec = [SELECT Name,contactId,Id FROM User WHERE profile.Name =: ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN and contactId != '' ORDER BY CreatedDate Desc LIMIT 1];
        System.runAs(userRec){
            List<Contact_Association_Type__c> getCredDocumentTypesCAT= EPICVerRepController.getCredDocumentTypesCAT(stringId);
            List<Contact_Association_Type_Staging__c> getCredDocumentTypes= EPICVerRepController.getCredDocumentTypes(stringId);  
            List<Case> getExtractionSubCase = EPICVerRepController.getExtractionSubCase(stringId);
            Map<String,Map<String,String>> getCredProgDocTypeMap = EPICVerRepController.getCredProgDocTypeMap(docName,'ECFMG_Certification');
        }
        Test.stopTest();
    }
}