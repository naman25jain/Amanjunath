@isTest
public class PrintResponseEventTriggerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp() {
        
        Id idRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId();
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts'));
        for(Integer i = 0; i < 2; i++) {
            Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=idRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS));
        }
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS));
        run();
    }
    
    @isTest
    public static void invokePrintResponseEventTrigger(){
        Test.startTest();
        Case cas = [select id from Case limit 1];
        String payload='{"transactionId":"'+cas.Id+'","transactionStatus":"'+PlanetPressConstants.Trans_Status_Printed+'","caseId":"'+cas.Id+'","totalDocumentsReceived":1,"errorDetails":{"errorDescription":"Thespecifiedblobdoesnotexist."}}';
        String logMessage='';
        Print_Response_Event__e requestEvent = new Print_Response_Event__e(payload__c = payload);
        Database.SaveResult sr = EventBus.publish(requestEvent);
        Test.stopTest();
    }
}