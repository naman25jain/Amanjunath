@isTest
public class SharingRuleEVCaseTest extends ECFMGTestFactory{
    
	@testSetup static void setup() {
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
        SharingRuleTestFactory.servicePageSetup();
    }
 
    @isTest
   	// Test for the manualShareRead method
   	static void testSharingRuleEVCaseTest() {
		User testUser = [Select id,contactId from User where alias='flastt'];
       	User user2 = [Select id,contactId from User where alias='flastt2'];
        Contact con = [Select id,AccountId from Contact where ID=:user2.contactId];
		Test.startTest();
        Service__c serv1 = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name = 'Enrollment Verification'));
        run();
        Account2Service__c acc2Service1 = (Account2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new Account2Service__c(Account__c = con.AccountId, Active__c = TRUE, Service__c = serv1.Id));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCase2ServiceTestData.class, new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service1.Id, Role__c = 'User', Service_Contact__c=user2.contactId, Active__c = true));
        run();
        System.runAs(testUser) {
            
            Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        	Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
                        
            Case examRegCase1 = new Case();
            examRegCase1.RecordTypeId = examRegRTId;            
            examRegCase1.ContactId = con.Id;
            INSERT examRegCase1;
            
            Case epexCase = new Case();
            epexCase.RecordTypeId = epexRTId;
            epexCase.ParentId = examRegCase1.Id;
            epexCase.ContactId = con.Id;
            INSERT epexCase;
            
            Case evCase = new Case();
            evCase.RecordTypeId = evRTId;
            evCase.AccountId = con.AccountId;
            evCase.ContactId = con.Id;
            INSERT evCase;
            
            Case examRegCase2 = new Case();
            examRegCase2.Id = examRegCase1.Id;
            examRegCase2.Enrollment_Verification_Parent__c = evCase.Id;
            UPDATE examRegCase2;
            // Query job sharing records.
          	List<CaseShare> evCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
             RowCause FROM CaseShare WHERE CaseId = :evCase.Id AND UserOrGroupId= :user2.Id];
         
          	// Test for only one manual share on job.
          	System.assertEquals(evCaseShrs.size(), 1, 'EV Case Records sharing model to Private.');
            
            // Test attributes of manual share.
			System.assertEquals(evCaseShrs[0].CaseId, evCase.Id);
            System.assertEquals(evCaseShrs[0].CaseAccessLevel, 'Edit');
            System.assertEquals(evCaseShrs[0].RowCause, 'Manual');
            System.assertEquals(evCaseShrs[0].UserOrGroupId, user2.Id);
            
            // Query job sharing records.
          	List<CaseShare> examRegCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
             RowCause FROM CaseShare WHERE CaseId = :examRegCase1.Id AND UserOrGroupId= :user2.Id];
         
          	// Test for only one manual share on job.
          	System.assertEquals(examRegCaseShrs.size(), 1, 'Exam Reg Case Records sharing model to Private.');
          
          	// Test attributes of manual share.
			System.assertEquals(examRegCaseShrs[0].CaseId, examRegCase1.Id);
            System.assertEquals(examRegCaseShrs[0].CaseAccessLevel, 'Edit');
            System.assertEquals(examRegCaseShrs[0].RowCause, 'Manual');
            System.assertEquals(examRegCaseShrs[0].UserOrGroupId, user2.Id);
            
            // Query job sharing records.
          	List<CaseShare> epexCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
             RowCause FROM CaseShare WHERE CaseId = :epexCase.Id AND UserOrGroupId= :user2.Id];
         
          	// Test for only one manual share on job.
          	System.assertEquals(epexCaseShrs.size(), 1, 'Epex Case Records sharing model to Private.');
          
          	// Test attributes of manual share.
			System.assertEquals(epexCaseShrs[0].CaseId, epexCase.Id);
            System.assertEquals(epexCaseShrs[0].CaseAccessLevel, 'Edit');
            System.assertEquals(epexCaseShrs[0].RowCause, 'Manual');
            System.assertEquals(epexCaseShrs[0].UserOrGroupId, user2.Id);
       }
       Test.stopTest();
   	}  
}