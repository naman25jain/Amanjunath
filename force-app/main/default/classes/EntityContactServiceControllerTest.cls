@isTest
public class EntityContactServiceControllerTest{
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
    public static testMethod void method1(){
        test.startTest();
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19112',
                                   BillingState='Alaska');
        insert acct;
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Contact con2 = new Contact(FirstName = 'eccontact1', LastName = 'fmgcontact1', RecordTypeId = idContactTypeId, Email = 'entity1@esf.com', AccountId = acct.Id, Active_Entity_Portal_User__c = TRUE);
        insert con2;
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv2 = new Service__c(Name = 'GEMX', Signature_Required__c = TRUE);
        myServiceList.add(serv2);
        Service__c serv3 = new Service__c(Name = 'Performance Data', Signature_Required__c = FALSE);
        myServiceList.add(serv3);
        insert myServiceList;
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service2 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv2.Id);
        Account2Service__c acc2Service3 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv3.Id);
        myAccServList.add(acc2Service2);
        myAccServList.add(acc2Service3);
        insert myAccServList;
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService2 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service2.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Active__c = true);
        //CONTACT2ACCTSERVICE__c conService3 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Active__c = true);
        myCon2AccService.add(conService2);
        //myCon2AccService.add(conService3);
        insert myCon2AccService;
        List<EntityContactServiceHelper.EntityConWrapper> methodOne = new List<EntityContactServiceHelper.EntityConWrapper>();
        methodOne = EntityContactServiceController.getEntity(con.Id);
        System.assertNotEquals(0, methodOne[0].accName.size(), 'Entity accounts returned from method should not be empty');
        System.assertEquals('Entity User', methodOne[0].conName, 'Incorrect Contact Name returned');
        System.assertEquals('Entity Account', methodOne[0].accName[0].accName, 'Incorrect Entity Account Name returned');
        List<EntityContactServiceHelper.EntitySerWrapper> methodTwo = new List<EntityContactServiceHelper.EntitySerWrapper>();
        methodTwo = EntityContactServiceController.getServices(acct.Id, con.Id);
        EntityContactServiceController.updateRole(conService2.Id, 'User');
        Entity_Type__c myRec = new Entity_Type__c(Entity_Type__c = 'School');
        insert myRec;
        EntityType2Service__c myRec2 = new EntityType2Service__c();
        myRec2.Entity_Type__c = myRec.Id;
        myRec2.Service__c = serv3.Id;
        insert myRec2;
        List<Service__c> servList = new List<Service__c>();
        servList = EntityContactServiceController.getServicesOfEntity(acct.Id);
        List<Boolean> listBoolean = new List<Boolean>();
        List<Boolean> listBoolean2 = new List<Boolean>();
        Asset newAsset = new Asset(Name = 'Asset01',ContactId = con2.Id, Type__c = 'User Signature');
        insert newAsset;
        Asset newAsset2 = new Asset(Name = 'Asset02',AccountId = acct.Id, Type__c = 'Entity Seal');
        insert newAsset2;
        Asset newAsset3 = new Asset(Name = 'Asset03',AccountId = acct.Id, Type__c = 'Completed PIA');
        insert newAsset3;
        listBoolean = EntityContactServiceController.validateRecord(serv2.Id, 'User', acct.Id, con2.Id);
        listBoolean2 = EntityContactServiceController.validateRecord(serv3.Id, 'User', acct.Id, con2.Id);
        EntityContactServiceController.insertRec(serv2.Id, 'User', acct.Id, con2.Id,serv2.Name);
        EntityContactServiceController.checkSeal(acct.Id);
        Boolean result = EntityContactServiceController.changeRole(acct.Id, 'GEMX');
        System.assertEquals(false, result, 'no cordinator found with the role');
        List<CONTACT2ACCTSERVICE__c> rec = new List<CONTACT2ACCTSERVICE__c>();
        rec = [Select Id from CONTACT2ACCTSERVICE__c where Role__c = 'Coordinator' AND Active__c = TRUE];
        for(integer i = 0; i < rec.size(); i++){
            rec[i].Active__c = false;
        }
        update rec;
        Boolean resultOp = EntityContactServiceController.deleteRole(conService2.Id, acct.Id, con.Id);
        System.assertEquals(false, resultOp, 'Deleted the user with role');
        test.StopTest();
    }
}