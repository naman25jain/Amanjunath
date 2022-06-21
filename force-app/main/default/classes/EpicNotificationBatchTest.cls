@isTest
public with sharing class EpicNotificationBatchTest{
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
    @isTest 
    static void testEpicNotification(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.Epic_Notifications__c = true;
        INSERT acc;
        System.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id != null, 'Contact creation failed');
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'Test';
        con1.Email = 'test1@test1.com';
        con1.RecordTypeId = applRecTypeId;
        INSERT con1;
        System.assert(con1.Id != null, 'contact1 creation failed');
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.LastName = 'Test';
        con2.Email = 'test1@test2.com';
        con2.RecordTypeId = applRecTypeId;
        INSERT con2;
        System.assert(con2.Id != null, 'Contact2 creation failed');
        Service__c ser = new Service__c();
        ser.Name = 'Volume Report Recipients';
        INSERT ser;
        System.assert(ser.Id != null, 'Service creation failed');
        Account2Service__c a2s = new Account2Service__c();
        a2s.Account__c = acc.Id;
        a2s.Active__c = true;
        a2s.isActiveEntity__c = true;
        a2s.Service__c = ser.Id;
        INSERT a2s;
        System.assert(a2s.Id != null, 'Account2Service creation failed');
        CONTACT2ACCTSERVICE__c c2as1 = new CONTACT2ACCTSERVICE__c();
        c2as1.Account_Service__c = a2s.Id;
        c2as1.Active__c = true;
        c2as1.Service_Contact__c = con.Id;
        INSERT c2as1;
        System.assert(c2as1.Id != null, 'Contact2AcctService1 creation failed');
        CONTACT2ACCTSERVICE__c c2as2 = new CONTACT2ACCTSERVICE__c();
        c2as2.Account_Service__c = a2s.Id;
        c2as2.Active__c = true;
        c2as2.Service_Contact__c = con1.Id;
        INSERT c2as2;
        System.assert(c2as2.Id != null, 'Contact2AcctService2 creation failed');
        CONTACT2ACCTSERVICE__c c2as3 = new CONTACT2ACCTSERVICE__c();
        c2as3.Account_Service__c = a2s.Id;
        c2as3.Active__c = true;
        c2as3.Service_Contact__c = con2.Id;
        INSERT c2as3;
        System.assert(c2as3.Id != null, 'Contact2AcctService3 creation failed');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypeId;
        credVerCase.ContactId = con.Id;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
        INSERT credVerCase;
        System.assert(credVerCase.Id != null, 'CredVer Case creation failed');
        Id epicVerfRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        Case epicReportCase1 = new Case();
        epicReportCase1.RecordTypeId = epicVerfRecTypeId;
        epicReportCase1.ContactId = con.Id;
        epicReportCase1.Internal_Status__c = Constants.CASE_STATUS_NEW;
        epicReportCase1.Secondary_Parent_Case__c = credVerCase.Id;
        epicReportCase1.Entity__c = acc.Id;
        INSERT epicReportCase1;
        System.assert(epicReportCase1.Id != null, 'Epic Report Case1 creation failed');
        Case epicReportCase2 = new Case();
        epicReportCase2.RecordTypeId = epicVerfRecTypeId;
        epicReportCase2.ContactId = con.Id;
        epicReportCase2.Internal_Status__c = Constants.CASE_STATUS_NEW;
        epicReportCase2.Secondary_Parent_Case__c = credVerCase.Id;
        epicReportCase2.Entity__c = acc.Id;
        INSERT epicReportCase2;
        System.assert(epicReportCase2.Id != null, 'EPIC REport Case2 creation failed');
        Id profId = [SELECT Id FROM Profile WHERE Name='4-Customer Community Entity 360' LIMIT 1].Id;
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
        System.assert(user1.Id != null, 'User1 creation failed');
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Test'LIMIT 1];
        Case epicReportCase = new Case();
        epicReportCase.RecordTypeId = epicVerfRecTypeId;
        epicReportCase.ContactId = cont.Id;
        epicReportCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        INSERT epicReportCase;
        System.assert(epicReportCase.Id != null, 'EPIC Report Case creation failed');
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(epicReportCase1.Id, yesterday); 
        Test.startTest();  
        EpicNotificationBatchScheduler obj = new EpicNotificationBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Territory Check', sch, obj); 
        Test.stopTest();  
    }
}