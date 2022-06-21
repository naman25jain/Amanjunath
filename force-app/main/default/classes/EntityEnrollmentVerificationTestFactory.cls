/**
* Factory Class for Not Reviewed Enrollment Verification notification
*
* @author        Nayana
* @version       1.0
* @createdDate   11-JUN-2020
*/
@isTest
public class EntityEnrollmentVerificationTestFactory {
    static string val='true';
    @isTest
    public static void servicePageSetup() {
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
        Id entityAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId(); 
        Account acc1 = new Account(Name = 'Sample Entity',
                                   RecordTypeId = entityAccId,
                                   School__c = true,
                                   Sponsoring_Institution__c = true,
                                   BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19110',
                                   BillingState='Alaska');
        insert acc1;
        Id entityConId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con1 = new Contact(Firstname = 'Sample',
                                   Lastname = 'Contact 01',
                                   Birthdate = date.valueOf('2000-01-01'),
                                   email = 'test1815@testmail.com',
                                   MailingCountry = 'Mexico',
                                   RecordTypeId = entityConId,
                                   AccountId = acc1.Id);
        insert con1;
        Contact con2 = new Contact(Firstname = 'Test',
                                   Lastname = 'Entity 2',
                                   Birthdate = date.valueOf('1965-01-01'),
                                   email = 'test0206@tmail.com',
                                   MailingCountry = 'Canada',
                                   RecordTypeId = entityConId,
                                   AccountId = acc1.Id);
        insert con2;
        //Create Service
        Service__c serv1 = new Service__c(Name = 'Enrollment Verification');
        insert serv1;
        System.assert(serv1.Id!=null, 'Service not created');
        //Create Account2Service
        Account2Service__c a2s1 = new Account2Service__c(Service__c = serv1.Id,
                                                         Account__c = acc1.Id,
                                                         Active__c = true);
        insert a2s1;
        System.assert(a2s1.Id!=null, 'Account2Service__c not created');
        //Create Contact2AcctService
        List<Contact2AcctService__c> c2asList = new List<Contact2AcctService__c>();
        Contact2AcctService__c c2as1 = new Contact2AcctService__c(Account_Service__c = a2s1.Id,
                                                                  Service_Contact__c = con1.Id,
                                                                  Role__c = 'Coordinator',
                                                                  Active__c = true);

        Contact2AcctService__c c2as2 = new Contact2AcctService__c(Account_Service__c = a2s1.Id,
                                                                  Service_Contact__c = con2.Id,
                                                                  Active__c = true);
        c2asList.add(c2as1);
        c2asList.add(c2as2);
        insert c2asList;
        System.assert(c2as1.Id!=null, 'Contact2AcctService__c not created');
        //Create Enrollment Verification Case
        ID evCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Verification').getRecordTypeId();
        List<Case> evCaseList = new List<Case>();
        Case evCase1 = new Case(Verification_Status__c = 'Not Reviewed',
                                RecordTypeId = evCaseRecordTypeId,
                                Status_Not_Reviewed_Date__c = System.today(),
                                AccountId = acc1.Id);

        Case evCase2 = new Case(Verification_Status__c = 'Not Reviewed',
                                RecordTypeId = evCaseRecordTypeId,
                                Status_Not_Reviewed_Date__c = System.today(),
                                AccountId = acc1.Id);
        evCaseList.add(evCase1);
        evCaseList.add(evCase2);
        insert evCaseList;
        System.assert(evCase1.Id!=null, 'EV case not created');
    }
}