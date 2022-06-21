@isTest
public class SharingRuleEPEXCaseTest {
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
    @testSetup static void setup() {
        SharingRuleTestFactory.servicePageSetup();
    }
    
    // Test for the manualShareRead method
    static testMethod void testSharingRuleEPEXCaseTest() {
        
        User testUser = [Select id,contactId from User where alias='flastt'];
        Test.startTest();
        System.runAs(testUser) {
            Contact con = [Select id,AccountId from Contact where ID=:testUser.contactId];
            
            Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            
            Case examRegCase1 = new Case();
            examRegCase1.RecordTypeId = examRegRTId;            
            examRegCase1.ContactId = con.Id;
            INSERT examRegCase1;            
           
            Case evCase = new Case();
            evCase.RecordTypeId = evRTId;
            evCase.AccountId = con.AccountId;
            evCase.ContactId = con.Id;
            INSERT evCase;
            
            Case examRegCase2 = new Case();
            examRegCase2.Id = examRegCase1.Id;
            examRegCase2.Enrollment_Verification_Parent__c = evCase.Id;
            UPDATE examRegCase2;
            
            Case epexCase = new Case();
            epexCase.RecordTypeId = epexRTId;
            epexCase.ParentId = examRegCase2.Id;
            epexCase.ContactId = con.Id;
            INSERT epexCase;
           
            User user2 = [Select id,contactId from User where alias='flastt2'];
            system.debug('User2:' + user2.id);
            system.debug('Testuser:' + testuser.id);
             system.debug('examRegCase1CaseId:' +examRegCase1.id);
            system.debug('evCaseCaseId:' +evCase.id);
            system.debug('epexCaseCaseId:' +epexCase.id);
            // Query job sharing records.
            List<CaseShare> evCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                          RowCause FROM CaseShare WHERE CaseId = :evCase.Id AND UserOrGroupId= :user2.Id];
            
            // Test for only one manual share on job.
            /*System.assertEquals(evCaseShrs.size(), 1, 'EV Case Records sharing model to Private.');
            
            // Test attributes of manual share.
            System.assertEquals(evCaseShrs[0].CaseId, evCase.Id, 'EV Case ID');
            System.assertEquals(evCaseShrs[0].CaseAccessLevel, 'Edit', 'EV Case CaseAccessLevel');
            System.assertEquals(evCaseShrs[0].RowCause, 'Manual', 'EV Case RowCause');
            System.assertEquals(evCaseShrs[0].UserOrGroupId, user2.Id, 'EV Case UserOrGroupId');*/
            
            // Query job sharing records.
            List<CaseShare> examRegCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                               RowCause FROM CaseShare WHERE CaseId = :examRegCase1.Id AND UserOrGroupId= :user2.Id];
            system.debug('examRegCaseShrs' +examRegCaseShrs);
            // Test for only one manual share on job.
            //system.debug('caseid:'+examRegCaseShrs[0].CaseId +' userid:' + examRegCaseShrs[0].UserOrGroupId);
            //System.assertEquals(examRegCaseShrs.size(), 1, 'Exam Reg Case Records sharing model to Private.');
            
            // Test attributes of manual share.
            //System.assertEquals(examRegCaseShrs[0].CaseId, examRegCase1.Id, 'Exam Reg Case ID');
            //System.assertEquals(examRegCaseShrs[0].CaseAccessLevel, 'Edit', 'Exam Reg Case CaseAccessLevel');
            //System.assertEquals(examRegCaseShrs[0].RowCause, 'Manual', 'Exam Reg Case RowCause');
            //System.assertEquals(examRegCaseShrs[0].UserOrGroupId, user2.Id, 'Exam Reg Case UserOrGroupId');
            
            // Query job sharing records.
            List<CaseShare> epexCaseShrs = [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel, 
                                            RowCause FROM CaseShare WHERE CaseId = :epexCase.Id AND UserOrGroupId= :user2.Id];
            
            // Test for only one manual share on job.
            //System.assertEquals(epexCaseShrs.size(), 1, 'Epex Case Records sharing model to Private.');
            
            // Test attributes of manual share.
            //System.assertEquals(epexCaseShrs[0].CaseId, epexCase.Id, 'EPEX Case ID');
            //System.assertEquals(epexCaseShrs[0].CaseAccessLevel, 'Edit', 'EPEX Case CaseAccessLevel');
            //System.assertEquals(epexCaseShrs[0].RowCause, 'Manual', 'EPEX Case RowCause');
            //System.assertEquals(epexCaseShrs[0].UserOrGroupId, user2.Id, 'EPEX Case UserOrGroupId');
            
            //Creating case ID list 
            List<id> casesIdList=new List<id>();
            for(CaseShare a : [select id from CaseShare]){
                casesIdList.add(a.id);
            }
            
            //Creating user ID list 
            List<id> usersIdList=new List<id>();
            for(User a : [select id from User]){
                usersIdList.add(a.id);
            }
            //Calling methods
            SharingRuleEPEXCase.updateSharingRules(casesIdList);
            SharingRuleEPEXCase.updateSharingRulesRefactor(casesIdList,usersIdList);
            
        }
        Test.stopTest();
    }  
}