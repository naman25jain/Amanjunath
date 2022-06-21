//Factory Class for Entity Service Request functionality
@isTest
public class EntityServiceRequestTestFactory{
    public static testMethod void servicePageSetup(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '000001';
        upsert settingsInstance;
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
        //create a new contact;
        Date birthdate1 = date.valueOf('2000-01-01');
        String emailTest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        Date birthdate2 = date.valueOf('2000-05-01');
        String emailTestCon2 = 'testerCon2@unknownmail.com';
        String lastnameCon2 = 'LastCon2';
        String firstnameCon2 = 'FirstCon2';
        Date birthdate3 = date.valueOf('2000-04-01');
        String emailTestCon3 = 'testerCon3@unknownmail.com';
        String lastnameCon3 = 'LastCon3';
        String firstnameCon3 = 'FirstCon3';
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
        Contact con1 = new Contact(Firstname = firstname,
                                   Lastname = lastname,
                                   Birthdate = birthdate1,
                                   email = emailtest,
                                   MailingCountry = 'Mexico',
                                   RecordTypeId = entityConId,
                                   AccountId = acc1.Id);
        insert con1;
		List<contact> contact1 = new List<contact>();
        contact1 =  [SELECT ID,AccountId
                        FROM contact
                        WHERE Id =: con1.Id];
        contact1[0].AccountId = acc1.Id;
        update contact1;
        Contact con2 = new Contact(Firstname = firstnameCon2,
                                   Lastname = lastnameCon2,
                                   Birthdate = birthdate2,
                                   email = emailtestCon2,
                                   MailingCountry = 'Mexico',
                                   RecordTypeId = entityConId,
                                   AccountId = acc1.Id);
        insert con2;
        Contact con3 = new Contact(Firstname = firstnameCon3,
                                   Lastname = lastnameCon3,
                                   Birthdate = birthdate3,
                                   email = emailtestCon3,
                                   MailingCountry = 'Mexico',
                                   RecordTypeId = entityConId,
                                   AccountId = acc1.Id);
        insert con3;
        Id p = [Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias = 'second',
                              email = emailtest,
                              emailencodingkey = 'UTF-8',
                              lastname = lastname,
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = p,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con1.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = userName);
        insert user1;
        //Create Services
        List<Service__c> servList = new List<Service__c>();
        Service__c serv1 = new Service__c(Name = 'EPIC');
        Service__c serv2 = new Service__c(Name = 'Performance Data');
        Service__c serv3 = new Service__c(Name = 'NSA');
        servList.add(serv1);
        servList.add(serv2);
        servList.add(serv3);
        insert servList;
        //Create Entity Types
        List<Entity_Type__c> entityTypeList = new List<Entity_Type__c>();
        Entity_Type__c et1 = new Entity_Type__c(Entity_Type__c = 'School');
        Entity_Type__c et2 = new Entity_Type__c(Entity_Type__c = 'Institution');
        entityTypeList.add(et1);
        entityTypeList.add(et2);
        insert entityTypeList;
        //Create EntityType2Service
        List<EntityType2Service__c> et2sList = new List<EntityType2Service__c>();
        EntityType2Service__c et2s1 = new EntityType2Service__c(Service__c = serv1.Id,
                                                                Entity_Type__c = et1.Id);
        EntityType2Service__c et2s2 = new EntityType2Service__c(Service__c = serv2.Id,
                                                                Entity_Type__c = et2.Id);
        EntityType2Service__c et2s3 = new EntityType2Service__c(Service__c = serv3.Id,
                                                                Entity_Type__c = et1.Id);
        et2sList.add(et2s1);
        et2sList.add(et2s2);
        et2sList.add(et2s3);
        insert et2sList;
        //Create Account2Service
        List<Account2Service__c> a2sList = new List<Account2Service__c>();
        Account2Service__c a2s1 = new Account2Service__c(Service__c = serv1.Id,
                                                         Account__c = acc1.Id,
                                                         Active__c = true);
        Account2Service__c a2s2 = new Account2Service__c(Service__c = serv3.Id,
                                                         Account__c = acc1.Id);
        a2sList.add(a2s1);
        a2sList.add(a2s2);
        insert a2sList;
        //Create Contact2AcctService
        List<Contact2AcctService__c> c2asList = new List<Contact2AcctService__c>();
        Contact2AcctService__c c2as1 = new Contact2AcctService__c(Account_Service__c = a2s1.Id,
                                                                  Service_Contact__c = con1.Id,Role__c = 'Coordinator',
                                                                  Active__c = true);
        Contact2AcctService__c c2as2 = new Contact2AcctService__c(Account_Service__c = a2s1.Id,
                                                                  Service_Contact__c = con3.Id,
                                                                  Active__c = true);
        Contact2AcctService__c c2as3 = new Contact2AcctService__c(Account_Service__c = a2s2.Id,
                                                                  Service_Contact__c = con1.Id,Role__c = 'Coordinator',
                                                                  Active__c = true);
        c2asList.add(c2as1);
        c2asList.add(c2as2);
        c2asList.add(c2as3);
        insert c2asList;
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'PIA Template';
        insert docConfig;
        ID eurCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Entity_User_Request').getRecordTypeId();
        Case eurCase = new Case(Internal_Status__c = 'Pending Coordinator Approval',
                                RecordTypeId = eurCaseRecordTypeId,
                                Request_Type_Value__c = 'Add Service',
                                Service_Name__c = serv3.Id,
                                ContactId = con1.Id);
        insert eurCase;
        // Content Version
        ContentVersion contentVersion1 = new ContentVersion(
            Title 			= 	'Penguins',
            PathOnClient 	= 	'Penguins.jpg',
            VersionData 	= 	Blob.valueOf('Test Content'),
            IsMajorVersion 	= 	true
        );
        insert contentVersion1; 
         // Content Version
        ContentVersion contentVersion2 = new ContentVersion(
            Title 			= 	'Penguins',
            PathOnClient 	= 	'Penguins.jpg',
            VersionData 	= 	Blob.valueOf('Test Content'),
            IsMajorVersion 	= 	true
        );
        insert contentVersion2; 
        //Create and Insert Asset
        List<Asset> assetList = new List<Asset>();
        Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();      
        Id assetRecordTypeIdVal = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId(); 
        Asset asst = new Asset(
            Name 			= 	Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
            recordTypeId 	= 	assetRecordTypeId,
            ContactId 		= 	user1.ContactId,      
            type__c			= 	Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE
        );
        assetList.add(asst);
        Asset asst1 = new Asset(
            Name 			= 	Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
            recordTypeId 	= 	assetRecordTypeId,
            ContactId 		= 	user1.ContactId,      
            type__c			= 	Constants.ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM,
            IsOrphan__c		=   True
        );
        assetList.add(asst1);
        Asset asst2 = new Asset(
            Name 			= 	Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
            recordTypeId 	= 	assetRecordTypeIdVal,
            ContactId 		= 	user1.ContactId,      
            type__c			= 	Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE,
            IsOrphan__c		=   False
        );
        assetList.add(asst2);
        insert assetList;
        System.assert(asst2.Id != null, 'Failed to insert assert');
    }
}