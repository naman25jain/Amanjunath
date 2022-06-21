@isTest
public with sharing class EpicPortalNotificationsControllerTest{
     @isTest
     public static void testGetNotifications(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Salesforce Admin'];
        User usr = new User(Alias = 'standt', Email='salesforceAdmin@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='salesfrceAdmin@testorg.com');
        INSERT usr;
        System.assert(usr.Id!= null,'User not created');
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!= null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id!= null,'contact not created');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Volume Report Recipients', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        myServiceList.add(serv);
        INSERT myServiceList;
        System.assert(serv.Id!= null,'Service not created');
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);
        myAccServList.add(acc2Service);
        INSERT myAccServList;
        System.assert(acc2Service.Id!= null,'Account2Service not created');
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, City__c='testCity', Street__c='Test Street', Country__c='India');
        myCon2AccService.add(conService);
        INSERT myCon2AccService;
        System.assert(conService.Id!= null,'Contact2Service not created');

        List<Id> cvCaseIds = new List<Id>();

        Case cvCase = new Case();
        cvCase.RecordTypeId = Constants.CVRECORDTYPEID;
        cvCase.ContactId = con.Id;
        cvCase.AccountId = acc.Id;
        cvCase.Entity__c = acc.Id;
        cvCase.Internal_Status__c = 'Sent for Verification';
        cvCase.Document_Type__c = 'Release';
        INSERT cvCase;
        System.assert(cvCase.Id!= null,'CV Case not created');
        Contact_Association_Type_Staging__c conAssTypeStaging =  new Contact_Association_Type_Staging__c();
        conAssTypeStaging.case__c = cvCase.Id;
        conAssTypeStaging.Contact__c = con.Id;
        conAssTypeStaging.Account__c = acc.Id;
        INSERT conAssTypeStaging;
        System.assert(conAssTypeStaging.Id!= null,'Contact Association Type Staging record not created');
        Case epicRpCase = new Case();
        epicRpCase.RecordTypeId = Constants.EPICVERREPORTREQRTID;
        epicRpCase.ContactId = con.Id;
        epicRpCase.AccountId = acc.Id;
        epicRpCase.Entity__c = acc.Id;
        epicRpCase.Notification_Archived_Status__c = true;
        epicRpCase.Internal_Status__c = 'New';
        epicRpCase.EPIC_Report_Archived_Status__c = false;
        epicRpCase.Document_Type__c = 'Release';
        epicRpCase.Reference_Number__c = '1234';
        epicRpCase.Entity_External_Status__c = 'Not Reviewed';
        epicRpCase.EPIC_Report_Received_Date__c = system.today();
        epicRpCase.Secondary_Parent_Case__c = cvCase.Id;
        INSERT epicRpCase;
        System.assert(epicRpCase.Id!= null,'EPIC Report case record not created');
        //create two assets - cred & trans
        cvCaseIds.add(epicRpCase.Secondary_Parent_Case__c);
        Id credRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        //create two assets - cred & trans
        //credentialasset
        String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        Asset asst = new Asset();
        asst.Name = 'Credential Request';
        asst.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst.contactId = con.Id;
        asst.Type__c = 'Letter from Dean';//'Constants.ASSET_TYPE_TRANSLATION';
        asst.Case__c = cvCase.Id;
        asst.RecordTypeId = credRecTypId;//ASSET_RECORD_TYPE_CREDENTIAL
        asst.Azure_Storage_URL__c = 'assetUrl';
        INSERT asst;
        System.assert(asst.Id != null, 'Asset creation failed');
        //translation asset
        Asset asstTrans = new Asset();
        asstTrans.Name = 'Translation';
        asstTrans.Status = Constants.ASSET_STATUS_ACCEPTED;
        asstTrans.contactId = con.Id;
        asstTrans.Type__c = Constants.ASSET_TYPE_TRANSLATION;
        asstTrans.Case__c = cvCase.Id;
        asstTrans.RecordTypeId = credRecTypId;//ASSET_RECORD_TYPE_CREDENTIAL
        asstTrans.Azure_Storage_URL__c = 'assetUrl';
        INSERT asstTrans;
        System.assert(asstTrans.Id != null, 'Asset creation failed');
        

        List<Asset> asstList = new List<Asset>();
        Map<String,Asset> asstCredMap = new Map<String,Asset>();
        Map<String,Asset> asstTransMap = new Map<String,Asset>();
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        asstList = [SELECT Id, Name, Case__c,Type__c,Status,RecordType.DeveloperName, Azure_Storage_URL__c FROM Asset WHERE Status NOT IN:statusId AND Case__c IN : cvCaseIds AND (Type__c = 'Translation' or Name='Credential Request')  WITH SECURITY_ENFORCED];
        for(Asset a: asstList){
            if(a.recordType.DeveloperName == Constants.ASSET_RECORD_TYPE_CREDENTIAL){
             if(a.Name == Constants.ASSET_TYPE_CREDENTIAL_REQUEST){
                 asstCredMap.put(a.Case__c,a);
             }  
             if(a.Type__c == Constants.ASSET_TYPE_TRANSLATION){
                 asstTransMap.put(a.Case__c,a);
                 }
            }
        }
        
        Test.startTest();
        System.runAs(usr){
            List<EpicPortalNotificationControllerHelper.EpicPortalNotificationWrapper> notificationList = EpicPortalNotificationsController.getNotifications(acc.Id,true);
            System.assert(notificationList != null, 'Case List should not empty');
            //Boolean archStatus = false;
            EpicPortalNotificationsController.updateArchivedStatus(epicRpCase.Id, true);
            //System.assert(archStatus != null, 'Archive status cannot be null');
        }
        Test.stopTest();   
    }
    @isTest
     public static void testGetNotificationsFailure(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Salesforce Admin'];
        User usr = new User(Alias = 'standt', Email='salesforceAdmin@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='salesfrceAdmin@testorg.com');
        INSERT usr;
        System.assert(usr.Id!= null,'User not created');
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!= null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id!= null,'Contact not created');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Volume Report Recipients', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        myServiceList.add(serv);

        INSERT myServiceList;
        System.assert(serv.Id!= null,'Service not created');
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);

        myAccServList.add(acc2Service);
        INSERT myAccServList;
        System.assert(acc2Service.Id!= null,'User not created');

        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, City__c='testCity', Street__c='Test Street', Country__c='India');
        myCon2AccService.add(conService);
        INSERT myCon2AccService;
        System.assert(conService.Id!= null,'User not created');
        List<Id> cvCaseIds = new List<Id>();

        Case cvCase = new Case();
        cvCase.RecordTypeId = Constants.CVRECORDTYPEID;
        cvCase.ContactId = con.Id;
        cvCase.AccountId = acc.Id;
        cvCase.Entity__c = acc.Id;
        cvCase.Internal_Status__c = 'Sent for Verification';
        cvCase.Document_Type__c = 'Release';
        INSERT cvCase;
        System.assert(cvCase.Id!= null,'User not created');
        Contact_Association_Type_Staging__c conAssTypeStaging =  new Contact_Association_Type_Staging__c();
        conAssTypeStaging.case__c = cvCase.Id;
        conAssTypeStaging.Contact__c = con.Id;
        conAssTypeStaging.Account__c = acc.Id;
        INSERT conAssTypeStaging;
        System.assert(conAssTypeStaging.Id!= null,'User not created');
        Case epicRpCase = new Case();
        epicRpCase.RecordTypeId = Constants.EPICVERREPORTREQRTID;
        epicRpCase.ContactId = con.Id;
        epicRpCase.AccountId = acc.Id;
        epicRpCase.Entity__c = acc.Id;
        epicRpCase.Notification_Archived_Status__c = true;
        epicRpCase.Internal_Status__c = 'New';
        epicRpCase.EPIC_Report_Archived_Status__c = false;
        epicRpCase.Document_Type__c = 'Release';
        epicRpCase.Reference_Number__c = '1234';
        epicRpCase.Entity_External_Status__c = 'Not Reviewed';
        epicRpCase.EPIC_Report_Received_Date__c = system.today();
        epicRpCase.Secondary_Parent_Case__c = cvCase.Id;
        INSERT epicRpCase;
        System.assert(epicRpCase.Id!= null,'User not created');

        cvCaseIds.add(epicRpCase.Secondary_Parent_Case__c);

        //create two assets - cred & trans
        List<Asset> asstList = new List<Asset>();
        Map<String,Asset> asstCredMap = new Map<String,Asset>();
        Map<String,Asset> asstTransMap = new Map<String,Asset>();
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        asstList = [SELECT Id, Name, Case__c,Type__c,Status,RecordType.DeveloperName, Azure_Storage_URL__c FROM Asset WHERE Status NOT IN:statusId AND Case__c IN : cvCaseIds AND (Type__c = 'Translation' or Name='Credential Request')  WITH SECURITY_ENFORCED];
        for(Asset a: asstList){
            if(a.recordType.DeveloperName == Constants.ASSET_RECORD_TYPE_CREDENTIAL){
                if(a.Name == Constants.ASSET_TYPE_CREDENTIAL_REQUEST){
                    asstCredMap.put(a.Case__c,a);
                }
                if(a.Type__c == Constants.ASSET_TYPE_TRANSLATION){
                    asstTransMap.put(a.Case__c,a);
                }
            }
        }
        Test.startTest();
        System.runAs(usr){
            List<EpicPortalNotificationControllerHelper.EpicPortalNotificationWrapper> notificationList = EpicPortalNotificationsController.getNotifications(acc.Id,true);
            System.assert(notificationList != null, 'Case List should not empty');
            EpicPortalNotificationsController.updateArchivedStatus(epicRpCase.Id, false);
        }
        Test.stopTest();
    }
}