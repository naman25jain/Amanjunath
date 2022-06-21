/**
* Test Class for EntitySelectionController class
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   3-Sep-2020
*/
@isTest
public class EntitySelectionControllerTest {
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
    public static testMethod void getEntityTest(){
        test.startTest();
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry='India');
        insert acct;
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Contact con2 = new Contact(FirstName = 'Second', LastName = 'Contact', RecordTypeId = idContactTypeId, Email = 'email@gmail.com', AccountId = acct.Id, Active_Entity_Portal_User__c = TRUE);
        insert con2;
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Credential Verification', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        myServiceList.add(serv);
        Service__c serv2 = new Service__c(Name = 'GEMX', Signature_Required__c = TRUE);
        myServiceList.add(serv2);
        Service__c serv3 = new Service__c(Name = 'Performance Data', Signature_Required__c = FALSE);
        myServiceList.add(serv3);
        Service__c serv4 = new Service__c(Name = 'ERAS', Signature_Required__c = FALSE);
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
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Credential_Type__c='Final Medical Diploma');
        CONTACT2ACCTSERVICE__c conService2 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service2.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Credential_Type__c='Final Medical Diploma');
        CONTACT2ACCTSERVICE__c conService3 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Credential_Type__c='Final Medical School Transcript');
        CONTACT2ACCTSERVICE__c conService4 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service4.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Credential_Type__c='Final Medical School Transcript');
        myCon2AccService.add(conService);
        myCon2AccService.add(conService2);
        myCon2AccService.add(conService3);
        myCon2AccService.add(conService4);
        insert myCon2AccService;
        system.runAs(user){
            List<EntityContactServiceHelper.EntityConWrapper> getEntList = new List<EntityContactServiceHelper.EntityConWrapper>();
            getEntList = EntitySelectionController.getEntity();
            System.assertEquals('Entity User', getEntList[0].conName, 'Incorrect Contact Name returned');
            System.assertEquals('Entity Account', getEntList[0].accName[0].accName, 'Incorrect Entity Account Name returned');
            System.assertEquals(true, getEntList.size() > 0, 'Incorrect number of Records returned');
            Boolean isService = EntitySelectionController.getServices(acct.Id);
            System.assertEquals(true, isService, 'It should have atleast one entity service');
            Boolean isVolumeEntity = EntitySelectionController.checkEntityIsVolumeReportRecpnt(acct.Id);
            System.assertEquals(false, isVolumeEntity, 'Entity is not volume recipient');
            Boolean isErasEntity = EntitySelectionController.checkEntityIsERAS(acct.Id);
            System.assertEquals(true, isErasEntity, 'Entity  is ERAS');
        }
     }
}