@IsTest
public class EpicReptHistoryListControllerTest{
	 @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        UPSERT curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        UPSERT curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
        wdomsIdSeq.AKA_ID__c = 1000;
        UPSERT wdomsIdSeq;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = 'x123';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not created');
        Id profId1 = [SELECT Id FROM profile WHERE Name='4-Customer Community Plus Login' LIMIT 1].Id;
        User user2 = new User(alias = 'testUsr1',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId1,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testUserapp@test.com');
        INSERT user2;   
        System.assert(user2.Id != null, 'user2 creation failed');
    }
    public static testMethod void testgetReportData(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test1@test.com'];
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id assetRecTypeCredential = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id verificationAssetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        Id epicReportRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'United States';
        mainAcc.BillingState = 'New Jersey';
        mainAcc.BillingPostalCode = 'x123';
        INSERT mainAcc;
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypeId;
        credVerCase.ContactId = con.Id;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        credVerCase.Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        INSERT credVerCase;
        System.assert(credVerCase.Id != null, 'Case creation failed');
        Asset asst = new Asset();
        asst.Name = 'Verified Final Medical Diploma';
        asst.RecordTypeId = assetRecTypeCredential;
        asst.Case__c = credVerCase.Id;
        asst.ContactId = con.Id;
        asst.Azure_Storage_URL__c = 'testUrl';
        asst.Status = Constants.ASSET_STATUS_VERIFIED;
        INSERT asst;
        System.assert(asst.Id != null, 'asst creation failed');
        Case epicReportCase = new Case();
        epicReportCase.RecordTypeId = epicReportRecTypeId;
        epicReportCase.ContactId = con.Id;
        epicReportCase.Payment_History__c = 'Free report';
        epicReportCase.Report_Type__c = 'Self';
        epicReportCase.EPIC_Report_Status__c = 'Report Sent';
        epicReportCase.Secondary_Parent_Case__c = credVerCase.Id;
        epicReportCase.EPIC_Report_Entity__c = null;
        epicReportCase.Internal_Status__c = 'Sent';
        INSERT epicReportCase;
        System.assert(epicReportCase.Id!=null,'Epic report not created');
        Case epicReportCase1 = new Case();
        epicReportCase1.RecordTypeId = epicReportRecTypeId;
        epicReportCase1.ContactId = con.Id;
        epicReportCase1.Payment_History__c = 'Paid Report';
        epicReportCase1.Report_Type__c = 'Volume Entity';
        epicReportCase1.EPIC_Report_Status__c = 'Report Sent';
        epicReportCase1.Secondary_Parent_Case__c = credVerCase.Id;
        epicReportCase1.EPIC_Report_Entity__c = mainAcc.Id;
        epicReportCase1.Internal_Status__c = 'Sent';
        INSERT epicReportCase1;
        System.assert(epicReportCase1.Id!=null,'Epic report not created');
        Asset epicRep = new Asset();
        epicRep.Name = 'EPIC Verification Report';
        epicRep.RecordTypeId = verificationAssetRecTypeId;
        epicRep.Case__c = epicReportCase.Id;
        epicRep.ContactId = con.Id;
        epicRep.Azure_Storage_URL__c = 'testUrl';
        epicRep.Status = 'Sent';
        epicRep.Type__c = 'Verification Report';
        INSERT epicRep;
        System.assert(epicRep.Id != null, 'epicRep creation failed');
        User us = [SELECT Id, ContactId FROM User WHERE email = 'test2@test.com' AND ContactId =: con.Id LIMIT 1];
        String error='';
        try{
            System.runAs(us){
            	Test.startTest();
        		List<EpicReptHistoryListController.ReportWrapper> repWrp = EpicReptHistoryListController.getReportData();
        		System.assert(!repWrp.isEmpty(), 'return wrapper is empty');
                String verCredUrl = EpicReptHistoryListController.getVerifiedCredentialURL(epicReportCase1.Id);
                System.assert(!String.isBlank(verCredUrl), 'No url returned');
                String epicRepUrl = EpicReptHistoryListController.getEPICReport(epicReportCase.Id);
                System.assert(!String.isBlank(epicRepUrl), 'No url returned');
        		Test.stopTest();
        	}   
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
}