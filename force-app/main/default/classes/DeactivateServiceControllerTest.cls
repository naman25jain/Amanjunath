@isTest
public class DeactivateServiceControllerTest{
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
    public static testMethod void testMethod1(){
        test.startTest();
        String email1 = 'testUser@gmail.com';
        String email2 = 'testUser2@gmail.com';
        String email3 = 'testUser3@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true,BillingCountry='Bhutan');
        insert acct;
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        Contact con2 = new Contact(FirstName = 'Entity', LastName = 'User2', RecordTypeId = idContactTypeId, Email = email2, AccountId = acct.Id);
        insert con2;
        User user2 = new User(alias='eUser2',email=email2,emailencodingkey='UTF-8',lastname='User2', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con2.Id, timezonesidkey=country,username=email2);
        insert user2;
		Contact con3 = new Contact(FirstName = 'Entity', LastName = 'User3', RecordTypeId = idContactTypeId, Email = email3, AccountId = acct.Id);
        insert con3;
        User user3 = new User(alias='eUser3',email=email3,emailencodingkey='UTF-8',lastname='User3', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con3.Id, timezonesidkey=country,username=email3);
        insert user3;
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Performance Data');
        myServiceList.add(serv);
        Service__c serv2 = new Service__c(Name = 'GEMX');
        myServiceList.add(serv2);
        Service__c serv3 = new Service__c(Name = 'Credential Verification');
        myServiceList.add(serv3);
        insert myServiceList;
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
        Account2Service__c acc2Service2 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv2.Id);
        Account2Service__c acc2Service3 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv3.Id);
        myAccServList.add(acc2Service);
        myAccServList.add(acc2Service2);
        myAccServList.add(acc2Service3);
        insert myAccServList;
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'User', Service_Contact__c=con.Id,Credential_Type__c='Final Medical Diploma');
        CONTACT2ACCTSERVICE__c conService2 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service2.Id, Role__c = 'User', Service_Contact__c=con2.Id,Credential_Type__c='Final Medical Diploma');
        CONTACT2ACCTSERVICE__c conService3 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'Coordinator', Service_Contact__c=con3.Id,Credential_Type__c='Final Medical Diploma');
        CONTACT2ACCTSERVICE__c conService4 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service2.Id, Role__c = 'User', Service_Contact__c=con2.Id,Credential_Type__c='Final Medical Diploma');
        CONTACT2ACCTSERVICE__c conService5 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'Coordinator', Service_Contact__c=con3.Id,Credential_Type__c='Final Medical Diploma');
        myCon2AccService.add(conService);
        myCon2AccService.add(conService2);
        myCon2AccService.add(conService3);
        myCon2AccService.add(conService4);
        myCon2AccService.add(conService5);
        insert myCon2AccService;
        String outputVal = DeactivateServiceController.deactivateService(acc2Service3.Id);  
        System.assertNotEquals(NULL, outputVal);   
        Boolean resultVal = DeactivateServiceController.perfDataCheck(acc2Service3.Id);
        System.assertNotEquals(NULL, resultVal);   
        test.StopTest();
    }
}