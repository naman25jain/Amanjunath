//Test Class for MyOrganizationsEntityListViewController class
@isTest
public with sharing class MyOrgsEntityListViewControllerTest{
    
    @testSetup static void setup(){
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000001';
        upsert curEntitySetting;
        Id entityAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        Id entityServiceCaseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DEV_ENTITY_SERVICE_REQUEST).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'United States';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Philadelphia';
        acc.BillingState = 'Pennsylvania';
        acc.BillingPostalCode = '19342';
        acc.RecordTypeId = entityAccRecTypeId;
        INSERT acc;
        System.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'testuser@test.com';
        con.RecordTypeId = entityConRecTypeId;
        INSERT con;
        System.assert(con.Id != null, 'Contact creation failed');
        //insert user
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
        System.assert(user1.Id != null, 'User creation failed');
        //Insert cases
        Case tstCase = new Case();
        tstCase.AccountId = acc.Id;
        tstCase.ContactId = con.Id;
        tstCase.Type = Constants.CASE_TYPE_ENTITY_DETAILS_CHANGE;
        tstCase.Internal_Status__c = 'New';
        tstCase.RecordTypeId = entityServiceCaseTypeId;
        INSERT tstCase;
        System.assert(tstCase.Id != null, 'Test case creation failed');
    }

    @isTest
    public static void testGetContact(){
        User testUserId = [SELECT Id, ContactId FROM User WHERE username = 'testuser@test.com' WITH SECURITY_ENFORCED];
        Test.startTest();
		Id getContactId = MyOrganizationsEntityListViewController.getContact(testUserId.Id);
        System.assertNotEquals(getContactId, null,'Contact Id not fetched'); 
        Test.stopTest();
    }

    @isTest
    public static void testGetMyOrganizations(){
        List<Contact> currentUser = new List<Contact>();
        //get the contact id 
        currentUser = [SELECT Id, FirstName, LastName, AccountId,Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, 
        Account.BillingPostalCode,Account.LastModifiedDate FROM Contact WHERE LastName =: 'Test' WITH SECURITY_ENFORCED];
        //currentEntityContactId
        User testUser = [Select id, contactId from User where contactId=:currentUser[0].id];
        System.runAs(testUser){
            Test.startTest();
            List<MyOrganizationsEntityListViewHelper.MyOrgWrapper> myOrganizations = new List<MyOrganizationsEntityListViewHelper.MyOrgWrapper>();
            myOrganizations = MyOrganizationsEntityListViewController.getMyOrganizations(currentUser[0].id);
            System.assert(!myOrganizations.isEmpty(),'My Organizations not fetched'); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetMyCases(){
        List<Contact> currentUser = new List<Contact>();
        //get the contact id 
        currentUser = [SELECT Id, FirstName, LastName, AccountId,Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, 
        Account.BillingPostalCode,Account.LastModifiedDate FROM Contact WHERE LastName =: 'Test' WITH SECURITY_ENFORCED];
        //currentEntityContactId
        User testUser = [Select id, contactId from User where contactId=:currentUser[0].id];
        System.runAs(testUser){
            Test.startTest();
            List<MyOrganizationsEntityListViewHelper.myCasesWrapper> myCases = new List<MyOrganizationsEntityListViewHelper.myCasesWrapper>();
            myCases = MyOrganizationsEntityListViewController.getMyCases(currentUser[0].id);
            System.assert(!myCases.isEmpty(),'My cases not fetched'); 
            Test.stopTest();
        }
    }
}