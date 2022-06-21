@isTest
public class SharingRuleNewEntityContactTest {
    
	@testSetup static void setup(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        UPSERT settingsInstance;
        System.assert(settingsInstance.Entity_ID__c != null, 'settingsInstance updation failed');
        CurrentECFMGIDSequence__c settingsInstanceEcfmgId = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsInstanceEcfmgId.ECFMG_ID__c = '0000001';
        UPSERT settingsInstanceEcfmgId;
        SharingRuleTestFactory.servicePageSetup();
    }
 
   	// Test for the manualShareRead method
   	static testMethod void testSharingRuleNewEntityContact() {
        
        User testUser1 = [Select id,contactId from User where alias='flastt'];
        Contact con1 = [Select id, AccountId from Contact where ID=:testUser1.contactId];
		
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id entityUsrReqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
               
        Case examRegCase1 = new Case();
        examRegCase1.RecordTypeId = examRegRTId;            
        examRegCase1.ContactId = con1.Id;
        INSERT examRegCase1;
        
        Case evCase = new Case();
        evCase.RecordTypeId = evRTId;
        evCase.AccountId = con1.AccountId;
        evCase.ContactId = con1.Id;
        INSERT evCase;
        
        Case examRegCase2 = new Case();
        examRegCase2.Id = examRegCase1.Id;
        examRegCase2.Enrollment_Verification_Parent__c = evCase.Id;
        UPDATE examRegCase2;
        
        Case epexCase = new Case();
        epexCase.RecordTypeId = epexRTId;
        epexCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        epexCase.ParentId = examRegCase1.Id;
        epexCase.AccountId = con1.AccountId;
        epexCase.ContactId = con1.Id;
        INSERT epexCase;
        Test.startTest();
        // Entity User Request
        Case entityUsrRequestCase = new Case();
        entityUsrRequestCase.RecordTypeId = entityUsrReqRTId;
        entityUsrRequestCase.ContactId = con1.Id;
        entityUsrRequestCase.Entity__C = con1.AccountId;
        entityUsrRequestCase.Source__c = Constants.CASE_SOURCE_COORDINATOR;
        entityUsrRequestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SIGNATURE_CHECK;
        INSERT entityUsrRequestCase;
        
        // Creating new Entity Contact
        User testUser3 = [Select id,contactId from User where alias='flastt3'];
        Contact con3 = [Select id, AccountId from Contact where ID=:testUser3.contactId];
        
        Service__c serv1 = new Service__c(Name = 'Enrollment Verification');
        insert serv1;
        
        Account2Service__c acc2Service1 = new Account2Service__c(Account__c = con3.AccountId, Active__c = TRUE, Service__c = serv1.Id);  
        insert acc2Service1;
        
        CONTACT2ACCTSERVICE__c conService1 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service1.Id, Role__c = 'User', Service_Contact__c=testUser3.contactId, Active__c = true);
        insert conService1;
        
        
        // Query job sharing records.
        List<CaseShare> evCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                      RowCause FROM CaseShare WHERE CaseId = :evCase.Id AND UserOrGroupId= :testUser3.Id];
        // Test for only one manual share on job.
        System.assertEquals(evCaseShrs.size(), 1, 'EV CASE is assigned to New Entity Contact');
        
        // Test attributes of manual share.
        System.assertEquals(evCaseShrs[0].CaseId, evCase.Id);
        System.assertEquals(evCaseShrs[0].CaseAccessLevel, 'Edit');
        System.assertEquals(evCaseShrs[0].RowCause, 'Manual');
        System.assertEquals(evCaseShrs[0].UserOrGroupId, testUser3.Id);
        
        // Query job sharing records.
        List<CaseShare> examRegCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                           RowCause FROM CaseShare WHERE CaseId = :examRegCase1.Id AND UserOrGroupId= :testUser3.Id];
        
        // Test for only one manual share on job.
        System.assertEquals(evCaseShrs.size(), 1, 'EXAM REG CASE is assigned to New Entity Contact');
        
        // Test attributes of manual share.
        System.assertEquals(examRegCaseShrs[0].CaseId, examRegCase1.Id);
        System.assertEquals(examRegCaseShrs[0].CaseAccessLevel, 'Edit');
        System.assertEquals(examRegCaseShrs[0].RowCause, 'Manual');
        System.assertEquals(examRegCaseShrs[0].UserOrGroupId, testUser3.Id);
        
        
        // Query job sharing records.
        List<CaseShare> epexCaseCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                           RowCause FROM CaseShare WHERE CaseId = :epexCase.Id AND UserOrGroupId= :testUser3.Id];
        
        // Test for only one manual share on job.
        System.assertEquals(epexCaseCaseShrs.size(), 1, 'EPEX CASE is assigned to New Entity Contact');
        
        // Test attributes of manual share.
        System.assertEquals(epexCaseCaseShrs[0].CaseId, epexCase.Id);
        System.assertEquals(epexCaseCaseShrs[0].CaseAccessLevel, 'Edit');
        System.assertEquals(epexCaseCaseShrs[0].RowCause, 'Manual');
        System.assertEquals(epexCaseCaseShrs[0].UserOrGroupId, testUser3.Id);
        
        // Query job sharing records.
        List<CaseShare> entityUsrReqCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                           RowCause FROM CaseShare WHERE CaseId = :entityUsrRequestCase.Id AND UserOrGroupId= :testUser3.Id];
        
        // Test for only one manual share on job.
        System.assertEquals(entityUsrReqCaseShrs.size(), 1, 'EXAM REG CASE is assigned to New Entity Contact');
        
        // Test attributes of manual share.
        System.assertEquals(entityUsrReqCaseShrs[0].CaseId, entityUsrRequestCase.Id);
        System.assertEquals(entityUsrReqCaseShrs[0].CaseAccessLevel, 'Edit');
        System.assertEquals(entityUsrReqCaseShrs[0].RowCause, 'Manual');
        System.assertEquals(entityUsrReqCaseShrs[0].UserOrGroupId, testUser3.Id);
        Test.stopTest();
   	}  
     // checks CV case sharing rules when a new contact2acctservice is inserted
     @isTest
     static void cvCaseSharing(){
          Set<Id> caseIds = new Set<Id>();
          User testUser1 = [Select id,contactId from User where alias='flastt2'];
          Contact con1 = [Select id, AccountId from Contact where ID=:testUser1.contactId];
          Service__c newSer = new Service__c();
          newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
          INSERT newSer;
          System.assert(newSer.Id != null, 'New service creation failed');
          Account2Service__c acctServ = new Account2Service__c();
          acctServ.active__c = true;
          acctServ.Account__c = con1.AccountId;
          acctServ.Service__c = newSer.Id;
          INSERT acctServ;
          System.assert(acctServ.Id != null, 'Account2Service creation failed');
          Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
          Case newCase = new Case(ContactId = con1.Id,Internal_Status__c = Constants.CASE_STATUS_SUBMITTED,recordTypeId = recordTypeId);
          INSERT newCase;
          System.assert(newCase.Id != null,'CASE CREATION FAILED');
          caseIds.add(newCase.Id);
          Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
          Contact con = [SELECT Id FROM Contact LIMIT 1];
          List<Case> caseList = new List<case>();
          Case credVerCase = new Case();
          credVerCase.RecordTypeId = credVerCaseRecordtypeId;
          credVerCase.ContactId = con.Id;
          credVerCase.Service__c = Constants.CASE_SERVICE_EPIC;
          credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
          credVerCase.Entity__c = con1.AccountId;
          caseList.add(credVerCase);
          Case credVerCase1 = new Case();
          credVerCase1.RecordTypeId = credVerCaseRecordtypeId;
          credVerCase1.ContactId = con.Id;
          credVerCase1.Service__c = Constants.CASE_SERVICE_EPIC;
          credVerCase1.Internal_Status__c = Constants.CASE_STATUS_NEW;
          credVerCase1.Entity__c = con1.AccountId;
          credVerCase1.Alternate_Entity__c = con1.AccountId;
          credVerCase1.ParentId = newCase.Id;
          caseList.add(credVerCase1);
          Insert caseList;
          for(Case cs:caseList){
               caseIds.add(cs.Id);
               System.assert(cs.Id != null,'CASE CREATION FAILED');
          }
          Id affCVRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
          Affirmation__c affirmation = new Affirmation__c();
          affirmation.RecordTypeId = affCVRecordTypeId;
          affirmation.Case__c = credVerCase1.Id;
          affirmation.Verify_with_Alternate_Entity__c = true;
          INSERT affirmation;
          System.assert(affirmation.Id != null, 'Affirmation creation failed');
          CONTACT2ACCTSERVICE__c conService1 = new CONTACT2ACCTSERVICE__c(Account_Service__c = acctServ.Id, Role__c = 'User', Service_Contact__c=testUser1.contactId,Credential_Type__c = Constants.CASE_DOCUMENT_TYPE_TCT);
          INSERT conService1;
          System.assert(conService1.Id != null,'CONTACT2ACCTSERVICE CREATION FAILED');
          System.assertEquals(3,[SELECT Count() FROM CaseShare WHERE CaseId IN:caseIds AND UserorGroupId =: testUser1.Id],'Case is not shared');
     }
}