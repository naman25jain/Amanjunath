@isTest
public with sharing class TaskTriggerTest extends ECFMGTestFactory{
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
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
    }
    // test method for after update
    @isTest
    static void testAfterUpdate(){
        test.startTest();
        Id recId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=recId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Task tsk=(Task)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTaskTestData.class, new Task(Subject='Email', WhoId=con.Id, WhatId=cas.Id));
        run();
        tsk.Status='Restriction Upheld';
        update tsk;
        tsk.Status='Restriction Release';
        update tsk;
        System.assert(tsk.WhoId != null,'Task Contact Should not be null');
        test.stopTest();
    }
    @isTest
    static void testAfterUpdate1(){
        Id recId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=recId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Task tsk=(Task)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTaskTestData.class, new Task(Subject='Email', WhoId=con.Id, WhatId=acc.Id));
        run();
        tsk.Subject='Phone';
        update tsk;
        test.startTest();
        	TaskTriggerHelper.handleRaiseplatformEventforWDOMS('Account',tsk);
        test.stopTest();
        System.assert(tsk.WhoId != null,'Task Contact Should not be null');
    }
}