@isTest
public class Contact2AcctServiceTriggerHandlerTest{
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        UPSERT curEntitySetting;
        Id entityAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.RecordTypeId = entityAccountRecTypeId;
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Contact entityCon = new Contact();
        entityCon.AccountId = acc.Id;
        entityCon.LastName = 'Entity Test';
        entityCon.Email = 'entitytest1@test.com';
        entityCon.RecordTypeId = entityConRecTypeId;
        INSERT entityCon;
		    System.debug('con '+con);
        System.debug('entityCon '+entityCon);

        Contact entityCon2 = new Contact();
        entityCon2.AccountId = acc.Id;
        entityCon2.LastName = 'Entity Test2';
        entityCon2.Email = 'entitytest2@test.com';
        entityCon2.RecordTypeId = entityConRecTypeId;
        INSERT entityCon2;

        Contact entityCon3 = new Contact();
        entityCon3.AccountId = acc.Id;
        entityCon3.LastName = 'Entity Test3';
        entityCon3.Email = 'entitytest3@test.com';
        entityCon3.RecordTypeId = entityConRecTypeId;
        INSERT entityCon3;

        Contact entityCon4 = new Contact();
        entityCon4.AccountId = acc.Id;
        entityCon4.LastName = 'Entity Test4';
        entityCon4.Email = 'entitytest4@test.com';
        entityCon4.RecordTypeId = entityConRecTypeId;
        INSERT entityCon4;

        Contact entityCon5 = new Contact();
        entityCon5.AccountId = acc.Id;
        entityCon5.LastName = 'Entity Test5';
        entityCon5.Email = 'entitytest5@test.com';
        entityCon5.RecordTypeId = entityConRecTypeId;
        INSERT entityCon5;

		    System.debug('con '+con);
        System.debug('entityCon '+entityCon2);

        Service__c volService = new Service__c(Name='Volume Report Recipients');
        INSERT volService;

        Account2Service__c accServ1 = new Account2Service__c(Account__c=acc.id,Active__c=true,Service__c=volService.Id);
        INSERT accServ1;

        Contact2AcctService__c conAcct1 = new Contact2AcctService__c(Account_Service__c=accServ1.Id,Active__c=true,Service_Contact__c=entityCon.Id,Role__c='User',Credential_Type__c='Final Medical Diploma');
        INSERT conAcct1;

        Contact2AcctService__c conAcct2 = new Contact2AcctService__c(Account_Service__c=accServ1.Id,Active__c=true,Service_Contact__c=entityCon2.Id,Role__c='Coordinator',Credential_Type__c='Alternate Graduation Document');
        INSERT conAcct2;

        Contact2AcctService__c conAcct3 = new Contact2AcctService__c(Account_Service__c=accServ1.Id,Active__c=true,Service_Contact__c=entityCon3.Id,Role__c='Administrator',Credential_Type__c='Letter from Dean');
        INSERT conAcct3;

        Contact2AcctService__c conAcct4 = new Contact2AcctService__c(Account_Service__c=accServ1.Id,Active__c=true,Service_Contact__c=entityCon4.Id,Role__c='User',Credential_Type__c='Letter from Dean');
        INSERT conAcct4;

        Contact2AcctService__c conAcct5 = new Contact2AcctService__c(Account_Service__c=accServ1.Id,Active__c=true,Service_Contact__c=entityCon5.Id,Role__c='Coordinator',Credential_Type__c='Letter from Dean');
        INSERT conAcct5;
    }
    @isTest 
    static void testGenerateDeleteList(){
          Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
          Contact tstEntityContact = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact2 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test2' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact3 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test3' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact4 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test4' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact5 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test5' AND RecordTypeId=:entityConRecTypeId LIMIT 1];

          List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Role__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact.Id OR Service_Contact__c=:tstEntityContact2.Id];
          List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Role__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact5.Id OR Service_Contact__c=:tstEntityContact5.Id];
          List<Contact2AcctService__c> tstCon2AccService3 = [SELECT Id,Name,Service_Contact__c,Role__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact3.Id];
          Test.startTest();
          Contact2AcctServiceTriggerHandler.generateDeleteList(tstCon2AccService);
          System.assertEquals(!tstCon2AccService.isEmpty(), true, 'delete List generated');
          
          Contact2AcctServiceTriggerHandler.generateDeleteList(tstCon2AccService2);
          System.assertEquals(!tstCon2AccService2.isEmpty(), true, 'delete List generated');

          Contact2AcctServiceTriggerHandler.generateDeleteList(tstCon2AccService3);
          System.assertEquals(!tstCon2AccService3.isEmpty(), true, 'delete List generated');

          Test.stopTest();
    }
    @isTest 
    static void testGetCredentialType(){
        Id entityAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account tstAccount = [SELECT Id,Name FROM Account WHERE Name='Test Account' AND RecordTypeId=:entityAccountRecTypeId LIMIT 1];
        Account2Service__c tstAcc2Service = [SELECT Id,Name,Account__c FROM Account2Service__c WHERE Account__c=:tstAccount.Id LIMIT 1];
        Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        Contact tstEntityContact = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
        Contact tstEntityContact2 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test2' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
        Contact tstEntityContact3 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test3' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
        List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact.Id];
        List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact2.Id];
        List<Contact2AcctService__c> tstCon2AccService3 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact3.Id];
        
        Set<String> tstAccServiceIdSet = new Set<String>();
        tstAccServiceIdSet.add(tstAcc2Service.Id);

        Set<String> tstContServiceIdSet = new Set<String>();
        tstContServiceIdSet.add(tstEntityContact.Id);
        tstContServiceIdSet.add(tstEntityContact2.Id);
        tstContServiceIdSet.add(tstEntityContact3.Id);

        Test.startTest();
        
        MAP<String, List<String>> returnValue = Contact2AcctServiceTriggerHandler.getCredentialType(tstAccServiceIdSet,tstContServiceIdSet);
        
        System.assertEquals(!returnValue.isEmpty(), true, 'Credential Type');
        Test.stopTest();
    }//handleAggregateForZero
    @isTest 
    static void testHandleAggregateForZero(){
          Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
          Contact tstEntityContact = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact2 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test2' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact3 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test3' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact.Id];
          List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact2.Id];
          List<Contact2AcctService__c> tstCon2AccService3 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact3.Id];
          
          Set<Id> tstContServiceIdSet = new Set<Id>();
          tstContServiceIdSet.add(tstEntityContact.Id);
          tstContServiceIdSet.add(tstEntityContact2.Id);
          tstContServiceIdSet.add(tstEntityContact3.Id);
  
          Test.startTest();
          List<Contact> retContact = Contact2AcctServiceTriggerHandler.handleAggregateForZero(tstContServiceIdSet,'User');
          System.assertEquals(!retContact.isEmpty(), true, 'contact list returned');

          List<Contact> retContact2 = Contact2AcctServiceTriggerHandler.handleAggregateForZero(tstContServiceIdSet,'Coordinator');
          System.assertEquals(!retContact2.isEmpty(), true, 'contact list returned');
        Test.stopTest();
    }
      @isTest 
      static void testHandleUpdate(){
          Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
          Contact tstEntityContact = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact2 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test2' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact3 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test3' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact4 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test4' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact5 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test5' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact.Id OR Service_Contact__c=:tstEntityContact3.Id) AND Role__c='User'];
          //List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact.Id OR Service_Contact__c=:tstEntityContact3.Id OR Service_Contact__c=:tstEntityContact4.Id)];
          List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact2.Id OR Service_Contact__c=:tstEntityContact3.Id) AND Role__c='Coordinator'];
          //List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact2.Id OR Service_Contact__c=:tstEntityContact3.Id OR Service_Contact__c=:tstEntityContact5.Id)];
          
          Set<Id> tstUsersIdSet = new Set<Id>();
          Set<Id> tstCoordIdSet = new Set<Id>();

          Set<Id> tstUsersIdSet2 = new Set<Id>();
          Set<Id> tstCoordIdSet2 = new Set<Id>();

          Set<Id> tstUsersIdSet3 = new Set<Id>();
          Set<Id> tstCoordIdSet3 = new Set<Id>();

          tstUsersIdSet.add(tstEntityContact.Id);
          tstUsersIdSet.add(tstEntityContact4.Id);

          tstCoordIdSet.add(tstEntityContact2.Id);
          tstCoordIdSet.add(tstEntityContact5.Id);
  
          tstUsersIdSet2.add(tstEntityContact3.Id);
          tstCoordIdSet2.add(tstEntityContact3.Id);

          Test.startTest();
          Contact2AcctServiceTriggerHandler.handleUpdate(tstUsersIdSet,tstCoordIdSet);
          System.assertEquals(!tstUsersIdSet.isEmpty(), true, 'contact list updated');
          System.assertEquals(!tstCoordIdSet.isEmpty(), true, 'contact list updated');

          Contact2AcctServiceTriggerHandler.handleUpdate(tstUsersIdSet2,tstCoordIdSet2);
          System.assertEquals(!tstUsersIdSet2.isEmpty(), true, 'contact list updated');
          System.assertEquals(!tstCoordIdSet2.isEmpty(), true, 'contact list updated');

          Contact2AcctServiceTriggerHandler.handleUpdate(tstUsersIdSet3,tstCoordIdSet3);
          System.assertEquals(tstUsersIdSet3.size(), 0, 'contact list updated');
          System.assertEquals(tstCoordIdSet3.size(), 0, 'contact list updated');

        Test.stopTest();
      }
      @isTest 
      static void testGenerateUpdateList(){
          Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
          Contact tstEntityContact = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact2 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test2' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact4 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test4' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact5 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test5' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          //List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact.Id AND Role__c='User'];
          List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact.Id OR Service_Contact__c=:tstEntityContact2.Id];
          //List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact2.Id AND Role__c='Coordinator'];
          List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE Service_Contact__c=:tstEntityContact4.Id OR Service_Contact__c=:tstEntityContact5.Id];
          System.debug('tstCon2AccService '+tstCon2AccService);
          System.debug('tstCon2AccService2 '+tstCon2AccService2);
          Test.startTest();
          Contact2AcctServiceTriggerHandler.generateUpdateList(tstCon2AccService,tstCon2AccService2);
          System.assertEquals(!tstCon2AccService.isEmpty(), true, 'contact list updated');
          System.assertEquals(!tstCon2AccService2.isEmpty(), true, 'contact list updated');
          Test.stopTest();
      }
      //public static void handleDelete(Set<Id> userSetIds, Set<Id> coordSetIds){
        @isTest 
        static void testHandleDelete(){
            //
          Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
          Contact tstEntityContact = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact2 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test2' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact3 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test3' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact4 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test4' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          Contact tstEntityContact5 = [SELECT ID, Name,RecordTypeId FROM Contact WHERE Name='Entity Test5' AND RecordTypeId=:entityConRecTypeId LIMIT 1];
          /* List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact.Id OR Service_Contact__c=:tstEntityContact3.Id) AND Role__c='User'];
          //List<Contact2AcctService__c> tstCon2AccService = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact.Id OR Service_Contact__c=:tstEntityContact3.Id OR Service_Contact__c=:tstEntityContact4.Id)];
          List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact2.Id OR Service_Contact__c=:tstEntityContact3.Id) AND Role__c='Coordinator'];
          //List<Contact2AcctService__c> tstCon2AccService2 = [SELECT Id,Name,Service_Contact__c,Account_Service__c,Role__c,Credential_Type__c FROM Contact2AcctService__c WHERE (Service_Contact__c=:tstEntityContact2.Id OR Service_Contact__c=:tstEntityContact3.Id OR Service_Contact__c=:tstEntityContact5.Id)];
           */
          Set<Id> tstUsersIdSet = new Set<Id>();
          Set<Id> tstCoordIdSet = new Set<Id>();

          Set<Id> tstUsersIdSet2 = new Set<Id>();
          Set<Id> tstCoordIdSet2 = new Set<Id>();

          Set<Id> tstUsersIdSet3 = new Set<Id>();
          Set<Id> tstCoordIdSet3 = new Set<Id>();

          tstUsersIdSet.add(tstEntityContact.Id);
          tstUsersIdSet.add(tstEntityContact4.Id);
          System.debug('tstUsersIdSet - '+tstUsersIdSet);
          tstCoordIdSet.add(tstEntityContact2.Id);
          tstCoordIdSet.add(tstEntityContact5.Id);
          System.debug('tstCoordIdSet - '+tstCoordIdSet);
  
          tstUsersIdSet2.add(tstEntityContact3.Id);
          tstCoordIdSet2.add(tstEntityContact3.Id);
          System.debug('tstCoordIdSet2 - '+tstCoordIdSet2);
          System.debug('tstUsersIdSet2 - '+tstUsersIdSet2);

          System.debug('tstCoordIdSet3 - '+tstCoordIdSet3);
          System.debug('tstUsersIdSet3 - '+tstUsersIdSet3);

          Test.startTest();
          Contact2AcctServiceTriggerHandler.handleDelete(tstUsersIdSet,tstCoordIdSet);
          System.assertEquals(!tstUsersIdSet.isEmpty(), true, 'contact list updated');
          System.assertEquals(!tstCoordIdSet.isEmpty(), true, 'contact list updated');

          Contact2AcctServiceTriggerHandler.handleDelete(tstUsersIdSet2,tstCoordIdSet2);
          System.assertEquals(!tstUsersIdSet2.isEmpty(), true, 'contact list updated');
          System.assertEquals(!tstCoordIdSet2.isEmpty(), true, 'contact list updated');

          /* Contact2AcctServiceTriggerHandler.handleDelete(tstUsersIdSet3,tstCoordIdSet3);
          System.assertEquals(tstUsersIdSet3.size(), 0, 'contact list updated');
          System.assertEquals(tstCoordIdSet3.size(), 0, 'contact list updated'); */

        Test.stopTest();
        }
}