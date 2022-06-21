@isTest
public class EntityAddUserTest{
    @testSetup static void setup() {
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
    }
    public static testMethod void insertTest(){
        test.startTest();
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19110',
                                   BillingState='Alaska');
        insert acct;
        System.assert(acct != null, 'Account Insert is failed');
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.assert(con != null, 'Contact Insert is failed');
        string type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        String fileUniqueName = con.Id + '_' + type + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        System.assert(user != null, 'User Insert is failed');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Performance Data', Signature_Required__c = TRUE);
        myServiceList.add(serv);
        Service__c serv2 = new Service__c(Name = 'GEMX', Signature_Required__c = TRUE);
        myServiceList.add(serv2);
        Service__c serv3 = new Service__c(Name = 'Credential Review', Signature_Required__c = FALSE);
        myServiceList.add(serv3);
        insert myServiceList;
        System.assert(myServiceList.size()>0, 'Service Insert is failed');
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
        Account2Service__c acc2Service2 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv2.Id);
        Account2Service__c acc2Service3 = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv3.Id);
        myAccServList.add(acc2Service);
        myAccServList.add(acc2Service2);
        myAccServList.add(acc2Service3);
        insert myAccServList;
        System.assert(myAccServList.size()>0, 'Account Service Insert is failed');
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id);
        CONTACT2ACCTSERVICE__c conService2 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service2.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id);
        CONTACT2ACCTSERVICE__c conService3 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service3.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id);
        myCon2AccService.add(conService);
        myCon2AccService.add(conService2);
        myCon2AccService.add(conService3);
        insert myCon2AccService;
        System.assert(myCon2AccService.size()>0, 'Contact Service Insert is failed');
        Id myId = con.Id;
        Schema.SObjectType sobjectType = myId.getSObjectType();
		String sobjectName = sobjectType.getDescribe().getName();
       	Asset newAsset = new Asset();
        newAsset.Name = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        newAsset.Status = Constants.IN_PROGRESS;
        newAsset.AccountId = acct.Id;
        newAsset.Type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        newAsset.Azure_Storage_URL__c = fileUniqueName;
        insert newAsset;
        System.assert(newAsset != null, 'Asset Insert is failed');
		SObject record = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :myId');
        system.runAs(user){
            String arg6 = acct.id;
        	EntityAddUser.getServices(arg6);
            EntityAddUser.fetchPickListValue(record, 'Generational_Suffix__c');
            String arg1 = 'Baker&&&Simon&&&false';
            String arg2 = '1988-07-21&&&Jr&&&simon.baker@gmail.com';
            String arg3 = '9884056751&&&Medicine&&&Lecturer';
            String arg4 = 'Australia';
            String arg7 = newAsset.Azure_Storage_URL__c;
            List<String> arg5 = new List<String>();
            arg5.add(serv2.Id);
            String returnVal = EntityAddUser.createContactCase(arg1, arg2, arg3, arg4, arg5,arg6, arg7);
            system.assertEquals(returnVal,'true','Exception occured while creating case and case2Services');
        }
        test.StopTest();
    }    
    public static testMethod void testFetchAssetId(){
        test.startTest();
        String email1 = 'testUser1@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'test', RecordTypeId = idAccountTypeId, School__c = true, 
                                   BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19112',
                                   BillingState='Alaska');
        insert acct;
        System.assert(acct != null, 'Account Insert failed');
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.assert(con != null, 'Contact Insert failed');
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        System.assert(user != null, 'User Insert failed');
        string type = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        String fileUniqueName = con.Id + '_' + type + '_' + String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_');
        List<asset> assetList = new List<Asset>();
        Asset newAsset = new Asset();
        newAsset.Azure_Storage_URL__c = fileUniqueName;
        newAsset.Name = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        newAsset.Status = Constants.IN_PROGRESS;
        newAsset.AccountId = acct.Id;
        newAsset.Type__c = Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM;
        assetList.add(newAsset);
        Asset newAsset1 = new Asset();
        insert assetList;        
        System.assert(assetList.size()>0, 'Asset Insert failed');
        EntityAddUser.deleteAssetList(acct.Id);
        EntityAddUser.delAssetOnCancel(newAsset1.Azure_Storage_URL__c);
        assetList.clear();
        system.assertEquals([SELECT id FROM Asset where Azure_Storage_URL__c =: newAsset1.Azure_Storage_URL__c AND Type__c =:Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM AND status =:Constants.ASSET_STATUS_INPROGRESS AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND ContactId = null AND Case__c = null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC],assetList,'Asset is not deleted');
        test.stopTest();
    }
}