@isTest
public class EntityManageAccountServiceControllerTest{
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
    public static testMethod void entityAccountService(){
        test.startTest();
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry='India');
        insert acct;
        System.assert(acct != null, 'Account is Empty');
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.assert(con != null, 'Contact is Empty');
        Contact con2 = new Contact(FirstName = 'Second', LastName = 'Contact', RecordTypeId = idContactTypeId, Email = 'email@gmail.com', AccountId = acct.Id, Active_Entity_Portal_User__c = TRUE);
        insert con2;
        System.assert(con2 != null, 'Contact is null');
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        System.assert(user != null, 'User is Empty');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Credential Verification', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        myServiceList.add(serv);
        Service__c serv2 = new Service__c(Name = 'GEMX', Signature_Required__c = TRUE);
        myServiceList.add(serv2);
        Service__c serv3 = new Service__c(Name = 'Performance Data', Signature_Required__c = FALSE);
        myServiceList.add(serv3);
        insert myServiceList;
        System.assert(myServiceList.size()>0, 'Service is not inserted');
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
        Account2Service__c acc2Service2 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv2.Id,isActiveEntity__c = TRUE,Mode_of_communication__c = 'Paper');
        Account2Service__c acc2Service3 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv3.Id);
        myAccServList.add(acc2Service);
        myAccServList.add(acc2Service2);
        myAccServList.add(acc2Service3);
        insert myAccServList;
        System.assert(myAccServList.size()>0, 'Account Service is not inserted');
        Entity_Type__c myRec = new Entity_Type__c(Entity_Type__c = 'School');
        insert myRec;
        System.assert(myRec != null, 'Entity is null');
        EntityType2Service__c myRec2 = new EntityType2Service__c();
        myRec2.Entity_Type__c = myRec.Id;
        myRec2.Service__c = serv3.Id;
        insert myRec2;
        System.assert(myRec2 != null, 'Entity Type is null');
        List<Account2Service__c> acc2SerList = EntityManageAccountServiceController.getServicesOfEntity(acct.Id);
        System.assert(acc2SerList.size()>0, 'List is Empty');
        Boolean isCreate = EntityManageAccountServiceController.createAccountService(acct.Id,'bb@gmm.com','No 3,Alx,Che',serv.Id,'Paper');
        Service__c serv4 = new Service__c(Name = 'Enrollment Verification', Signature_Required__c = TRUE);
        insert serv4;
        System.assert(serv4 != null, 'Service is null');
        Boolean isCreateNeg = EntityManageAccountServiceController.createAccountService(acct.Id,'bbiu@gmm.com','3,Alx,Che',serv4.Id,'Paper');
        Boolean isUpdate = EntityManageAccountServiceController.updateAccountService(acc2Service.Id,acct.Id,'bbiio@gmm.com','Alx,Che',serv.Id,'Paper');
        Boolean isDel = EntityManageAccountServiceController.deleteActiveAccount(acc2Service.Id);
        System.assertEquals(isCreate, TRUE, 'Account2Service not Created');
        System.assertEquals(isCreateNeg, TRUE, 'Account2Service not Created');
        System.assertEquals(isUpdate, TRUE, 'Account2Service not Updated');
        System.assertEquals(isDel, TRUE, 'Account2Service not Deleted');
        test.stopTest();
    }
}