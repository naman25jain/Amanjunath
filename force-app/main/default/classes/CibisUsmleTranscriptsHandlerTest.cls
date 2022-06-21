@isTest
public class CibisUsmleTranscriptsHandlerTest extends ECFMGTestFactory{
	@testSetup
    public static void setupDataForInnvocableMethod(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Region_Change').getRecordTypeId();
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='Cibis'));
        Case case1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, isCibisTranReqInit__C=false));
        for(Integer i = 0; i < 2; i++) {
            Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, ParentId=case1.Id, RecordTypeId=caseRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, isCibisTranReqInit__C=false));
        }
        Case casCibisTransquit = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, ParentId=case1.Id, RecordTypeId=caseRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, isCibisTranReqInit__C=true));
        
        run();
    }
    
    @isTest
    static void invokeCibisUsmleTranscriptsHandler(){
        Test.startTest();
        List<Id> caseIds = new List<Id>();
        List<Case> updateCaseParent = new List<Case>();
        Set<Id> conIds = new Set<Id>();
        List<Case> caseRecords = [SELECT Id, ParentId FROM Case];
        List<Contact> contacts = [SELECT Id FROM Contact];
        for(Integer i = 0 ; i < caseRecords.size(); i++){
            if(i > 0){
                updateCaseParent.add(new Case(Id=caseRecords[i].Id, ParentId=caseRecords[0].Id)); 
            }
        }
        System.debug('updateCaseParent '+updateCaseParent);
        update updateCaseParent;
        for(Case eachCase: caseRecords){
            caseIds.add(eachCase.Id);
        }
        
        for(Contact eachCon: contacts){
            conIds.add(eachCon.Id);
        }
        System.debug('caseIds => '+caseIds);
        CibisUsmleTranscriptsHandler.processUSMLETranscriptCases(caseIds);
        //CibisExamIrregularGenReqHandler.constructPayload(Constants.CIBIS_EXAM_IRREGULAR_BEHAVIOR_EVENT, conIds);
        Test.stopTest();
    }
}