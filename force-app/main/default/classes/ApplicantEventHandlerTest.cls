@isTest
public class ApplicantEventHandlerTest{
   @isTest static void testEventHandler(){
		Test.startTest();
        Batch_Request_Log__c batchReqLogObj = new Batch_Request_Log__c();
        batchReqLogObj.Batch_Request_Id__c = '1001010';
        batchReqLogObj.Client_Name__c = 'ECFMG';
        insert batchReqLogObj;
        // Create a test event instance
        Applicant_Batch_Event__e eventObj = new Applicant_Batch_Event__e();
        eventObj.Batch_Request_log_Id__c = batchReqLogObj.Id;
        eventObj.Request_Id__c = 'Test Batch Request ID';
        eventObj.Client_Name__c = 'Test Batch';
        eventObj.Error_Code__c = 'Test Batch Error Code';
        // Publish test event
        Database.SaveResult sr = EventBus.publish(eventObj);
       // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess(), 'Applicant Event Handler Success');
       	ApplicantEventHandler.saveLogMessage('Error Message');
        Test.stopTest();
    }
}