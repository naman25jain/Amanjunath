@isTest
public class ManageUsersControllerTest extends ECFMGTestFactory{
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
    public static final String RETURNED_NULL = 'Returned value is null';
    public static final String LIST_EMPTY = 'List should be empty';
    public static testMethod void unitTest(){
        test.startTest();
          
        String email1 = 'testUser@gmail.com';
        String email2 = 'testUser2@gmail.com';
        String email3 = 'testUser3@gmail.com';
        String email4 = 'testUser4@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        List<Contact> cons = new List<Contact>();
        List<User> users = new List<User>();
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, acct);
        run();
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        cons.add(con);
        Id profileId=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        Contact con2 = new Contact(FirstName = 'Entity', LastName = 'User2', RecordTypeId = idContactTypeId, Email = email2, AccountId = acct.Id);
        cons.add(con2);
		Contact con3 = new Contact(FirstName = 'Entity', LastName = 'User3', RecordTypeId = idContactTypeId, Email = email3, AccountId = acct.Id);
        cons.add(con3);
        Contact con4 = new Contact(FirstName = 'Entity', LastName = 'User4', RecordTypeId = idContactTypeId, Email = email4, AccountId = acct.Id);
        cons.add(con4);
        insert cons;
        User user = new User(alias='eUser', email=email1, emailencodingkey='UTF-8', lastname='User', languagelocalekey='en_US', localesidkey='en_US', profileid=profileId, country=country2, IsActive=true, ContactId=cons[0].Id, timezonesidkey=country, username=email1);
        users.add(user);
        User user2 = new User(alias='eUser2', email=email2, emailencodingkey='UTF-8', lastname='User2', languagelocalekey='en_US', localesidkey='en_US', profileid=profileId, country=country2, IsActive=true, ContactId=cons[1].Id, timezonesidkey=country, username=email2);
        users.add(user2);
        User user3 = new User(alias='eUser3', email=email3, emailencodingkey='UTF-8', lastname='User3', languagelocalekey='en_US', localesidkey='en_US', profileid=profileId, country=country2, IsActive=true, ContactId=cons[2].Id, timezonesidkey=country, username=email3);
        users.add(user3);
        User user4 = new User(alias='eUser4', email=email4, emailencodingkey='UTF-8', lastname='User4', languagelocalekey='en_US', localesidkey='en_US', profileid=profileId, country=country2, IsActive=true, ContactId=cons[3].Id, timezonesidkey=country, username=email4);
        users.add(user4);
        Insert users;
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Performance Data');
        myServiceList.add(serv);
        Service__c serv2 = new Service__c(Name = 'GEMX');
        myServiceList.add(serv2);
        Service__c serv3 = new Service__c(Name = 'Credential Review');
        myServiceList.add(serv3);
        Service__c serv4 = new Service__c(Name = 'Enrollment Verification');
        myServiceList.add(serv4);
        insert myServiceList;
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
        Account2Service__c acc2Service2 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv2.Id);
        Account2Service__c acc2Service3 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv3.Id);
        Account2Service__c acc2Service4 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv4.Id);
        myAccServList.add(acc2Service);
        myAccServList.add(acc2Service2);
        myAccServList.add(acc2Service3);
        myAccServList.add(acc2Service4);
        insert myAccServList;
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'User', Service_Contact__c=con.Id);
        CONTACT2ACCTSERVICE__c conService2 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'User', Service_Contact__c=con2.Id);
        CONTACT2ACCTSERVICE__c conService3 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'Coordinator', Service_Contact__c=con3.Id);
        CONTACT2ACCTSERVICE__c conService4 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service4.Id, Role__c = 'Verifier', Service_Contact__c=con4.Id);
        myCon2AccService.add(conService);
        myCon2AccService.add(conService2);
        myCon2AccService.add(conService3);
        myCon2AccService.add(conService4);
        insert myCon2AccService;
        system.runAs(user){
            String revealButtonOp = ManageUsersController.revealButton(acct.id);
            System.assertNotEquals(revealButtonOp, NULL, RETURNED_NULL);
            List<contact2AccServiceWrapper> getRecsListOp = ManageUsersController.getRecs(acct.id);
            System.assertNotEquals(getRecsListOp.size(), 0, LIST_EMPTY);
        }
        system.runAs(user2){
            String revealButtonOp = ManageUsersController.revealButton(acct.id);
            System.assertNotEquals(revealButtonOp, NULL, RETURNED_NULL);
            Boolean deactivateUserOp = ManageUsersController.deactivateUser(conService.Id);
            System.assertEquals(deactivateUserOp, TRUE, 'Returned value is false');
            List<contact2AccServiceWrapper> getRecsListOp2 = ManageUsersController.getRecs(acct.id);
            System.assertNotEquals(getRecsListOp2.size(), 0, LIST_EMPTY);
        }
        system.runAs(user3){
            String revealButtonOp = ManageUsersController.revealButton(acct.id);
            System.assertNotEquals(revealButtonOp, NULL, RETURNED_NULL);
            List<contact2AccServiceWrapper> getRecsListOp3 = ManageUsersController.getRecs(acct.id);
            System.assertNotEquals(getRecsListOp3.size(), 0, LIST_EMPTY);
        }
        system.runAs(user4){
            String revealButtonOp = ManageUsersController.revealButton(acct.id);
            System.assertEquals(revealButtonOp, NULL, 'Returned Value is Not null');
            List<contact2AccServiceWrapper> getRecsListOp4 = ManageUsersController.getRecs(acct.id);
            System.assertNotEquals(getRecsListOp4.size(), 0, 'List not empty');
        }
        test.StopTest();
    }
}