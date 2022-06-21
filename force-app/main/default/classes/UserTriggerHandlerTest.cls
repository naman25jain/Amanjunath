@isTest
public class UserTriggerHandlerTest extends ECFMGTestFactory{
    public static testMethod void insertTest(){
        test.startTest();
        String email1 = 'testUser@gmail.com';
        String email2 = 'testUser1@gmail.com';
        String email3 = 'testUser3@gmail.com';
        String email4 = 'testUser4@gmail.com';
        
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        String country3 = 'India';
        
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id idHHAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();

        Account acct = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true));
        Account acct2 = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc', RecordTypeId = idAccountTypeId, School__c = true));
        Account acct3 = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc3', RecordTypeId = idHHAccountTypeId, School__c = false));
        Account acct4 = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc4', RecordTypeId = idHHAccountTypeId, School__c = false));
        run();
		
        
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Contact con2 = new Contact(FirstName = 'Entity', LastName = 'contact', RecordTypeId = idContactTypeId, Email = email2, AccountId = acct2.Id);
        insert con2;
        
        Id idAppContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();
        Contact con3 = new Contact(FirstName = 'Applicant', LastName = 'user', RecordTypeId = idAppContactTypeId, Email = email3, AccountId = acct3.Id);
        insert con3;
        Contact con4 = new Contact(FirstName = 'Applicant4', LastName = 'Contact4', RecordTypeId = idAppContactTypeId, Email = email4, AccountId = acct4.Id);
        insert con4;
        
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        User user1 = new User(alias='eUser',email=email2,emailencodingkey='UTF-8',lastname='User2', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=false,ContactId=con2.Id, timezonesidkey=country,username=email2);
        insert user1;
        
        Id p2=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User user3 = new User(alias='eUser3',email=email3,emailencodingkey='UTF-8',lastname='User3', languagelocalekey='en_US',localesidkey='en_US',profileid=p2,country=country3,IsActive=true,ContactId=con3.Id, timezonesidkey=country,username=email3);
        insert user3;
        User user4 = new User(alias='eUser4',email=email4,emailencodingkey='UTF-8',lastname='User4', languagelocalekey='en_US',localesidkey='en_US',profileid=p2,country=country3,IsActive=false,ContactId=con4.Id, timezonesidkey=country,username=email4);
        insert user4;
        
        test.StopTest();
    }
    public static testMethod void updateTest(){
        String email1 = 'testUser@gmail.com';
        String email2 = 'testUser1@gmail.com';
        String email3 = 'testUser3@gmail.com';
        String email4 = 'testUser4@gmail.com';
        
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        String country3 = 'India';
        
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id idHHAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();
        
        Account acct = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true));
        Account acct2 = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc', RecordTypeId = idAccountTypeId, School__c = true));
        Account acct3 = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc3', RecordTypeId = idHHAccountTypeId, School__c = false));
        Account acct4 = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc4', RecordTypeId = idHHAccountTypeId, School__c = false));
        run();
        
        
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Contact con2 = new Contact(FirstName = 'Entity', LastName = 'contact', RecordTypeId = idContactTypeId, Email = email2, AccountId = acct2.Id);
        insert con2;
        
        Id idAppContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();
        Contact con3 = new Contact(FirstName = 'Applicant', LastName = 'user', RecordTypeId = idAppContactTypeId, Email = email3, AccountId = acct3.Id);
        insert con3;
        Contact con4 = new Contact(FirstName = 'Applicant4', LastName = 'Contact4', RecordTypeId = idAppContactTypeId, Email = email4, AccountId = acct4.Id);
        insert con4;
        
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        Id p2=[Select id from profile where name='System Administrator' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p2,country=country2,IsActive=true, timezonesidkey=country,username=email1+'dev');
        insert user;
        User user1 = new User(alias='eUser',email=email2,emailencodingkey='UTF-8',lastname='User2', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con2.Id, timezonesidkey=country,username=email2);
        insert user1;
        Id p3=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User user3 = new User(alias='eUser3',email=email3,emailencodingkey='UTF-8',lastname='User3', languagelocalekey='en_US',localesidkey='en_US',profileid=p3,country=country3,IsActive=true,ContactId=con3.Id, timezonesidkey=country,username=email3);
        insert user3;
        
        test.startTest();
        System.runAs(user){
            user1.IsActive = false;
            update user1;
            user1.IsActive = true;
            update user1;
            user3.IsActive = false;
            update user3;
            user3.IsActive = true;
            update user3;
        }
        test.StopTest();
    }
}