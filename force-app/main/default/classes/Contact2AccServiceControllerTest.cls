@isTest
public class Contact2AccServiceControllerTest{
    @isTest static void createCnt2AccServiceRecsTest(){
        String email1 = 'testUser@gmail.com';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'India');
        insert acct;
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Performance Data');
        myServiceList.add(serv);
        insert myServiceList;
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
        myAccServList.add(acc2Service);
        insert myAccServList; 
        test.startTest();
        CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj.Role__c = 'User';
        conAccServiceObj.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj.Physical_Address__c = 'Test Address';
        conAccServiceObj.List_of_emails__c = '';
        conAccServiceObj.Verification_Website_URL__c = '';
        conAccServiceObj.Credential_Type__c = 'Letter from Dean';
        conAccServiceObj.Account_Service__c = acc2Service.Id;
        conAccServiceObj.Service_Contact__c = con.Id;
        conAccServiceObj.Active__c = true;
        conAccServiceObj.City__c = 'Test';
        conAccServiceObj.Street__c = 'Test';
        conAccServiceObj.Country__c = 'India';
        insert conAccServiceObj;
        String jsonString = '{"contactId":"'+con.Id+'","roleName":"User","preferrredModeOfCommunication":"Paper","physicalAddress":"Test Address","listOfEmails":"amirtharaj@enableconsulting.com","verificationWebsiteURL":"","credentialType":"Final Medical Diploma","cityName":"Test","countryName":"India","streetName":"Test"}';
        Contact2AccServiceController.createCnt2AccServiceRecs(jsonString, acc2Service.Id);
        System.assert(conAccServiceObj.Id != null, 'Contact2AccService is inserted');
        test.stopTest();
    }
    @isTest static void findRecordstest(){
        string searchKey = 'Test Contact';
        String email1 = 'testUser@gmail.com';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'India');
        insert acct;
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Test Contact', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        test.startTest();
        system.assertEquals(conList[0].Id, Contact2AccServiceController.findRecords(searchKey)[0].Id, 'Contact is not found in the list');
        test.stopTest();
    }
}