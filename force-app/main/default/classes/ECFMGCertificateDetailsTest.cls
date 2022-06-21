@isTest
public with sharing class ECFMGCertificateDetailsTest{   
    @isTest static void createRegenAssetTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingPostalCode = '123456';
        insert acc;
        System.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.accountId = acc.Id;
        insert con;
        System.assert(con.Id != null, 'Contact creation failed');
        Id ecfmgRecId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Case csEcfmgCert = new Case(ContactId = con.Id, 
        Service__c = 'EPIC', 
        RecordTypeId = ecfmgCertRecordTypeId, 
        Internal_Status__c = 'Sent');
        insert csEcfmgCert;
        System.Assert(csEcfmgCert.Id != null,'csEcfmgCert is not inserted');
        Asset asst = new Asset();
        asst.Name = 'ECFMG Certificate';
        asst.ContactId = con.Id;
        asst.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst.RecordTypeId = ecfmgRecId;
        asst.Case__c = csEcfmgCert.Id;
        insert asst;
        System.assert(asst.Id != null, 'Asset creation failed');
        Asset asst1 = new Asset();
        asst1.Name = 'Shipping Label';
        asst1.ContactId = con.Id;
        asst1.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst1.RecordTypeId = ecfmgRecId;
        asst1.Case__c = csEcfmgCert.Id;
        insert asst1;
        Profile prof = [SELECT Id FROM profile WHERE Name LIKE '4-Customer Community Plus Login'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.Id;
        user.username = 'test@test.com';
        user.email = 'test@test.com';
        user.ContactId = con.Id;
        user.Alias = 'test12';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        insert user;      
        system.runAs(user){
            Test.StartTest();
                ECFMGCertificateDetails.getECFMGCertificateInfo();
            Test.StopTest();
        }
    }
}