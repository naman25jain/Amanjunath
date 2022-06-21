//Test class for EPICVerReportBatch
@isTest 
public class EPICVerReportBatchTest{
    @isTest
    static void epicVerReportBatchTestTestMethod(){
        List<Case> caseList= new List<Case>();
        for(Integer i=0 ;i <20;i++){
            Case c = new Case();
            c.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
            c.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
            caseList.add(c);
        }
        insert caseList;
        System.assert(!caseList.isEmpty(),'No case records found');
        Test.startTest();
        EPICVerReportBatch obj = new EPICVerReportBatch();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }    
}