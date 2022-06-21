@isTest
public with sharing class SendRequestSchedulerTest{
	@isTest
    public static void testSendRequestScheduler(){
        Case caseRecord = new Case();
        id recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Medical Education Form').getRecordTypeId();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseRecord.recordtypeid = recordtypeid;
        caseRecord.Send_Method__c = 'Paper';
        caseRecord.Send_Method_Override_Comments__c = 'Test';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        vp.Is_Active__c = true;
        INSERT vp;
        System.assert(vp.Id != null,'Verification Packet is not inserted');
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Send_Method__c = caseRecord.Send_Method__c;
        sendReq.Next_Send_Date__c = Date.today();
        sendReq.Current_Send_Date__c = Date.today().addDays(-60);
        sendReq.Received_Date__c = null;
        INSERT sendReq;
        System.assert(sendReq.Id != null,'Send Request is not inserted');
        Test.startTest();
        System.schedule('Send Request Scheduler'+System.now(), '0 30 1 * * ? *', new SendRequestScheduler());
        Database.executeBatch(new SendRequestBatch());
        Test.stopTest();
        System.assert([SELECT Current_Send_Count__c FROM Send_Request__c WHERE Verification_Packet__c =:vp.Id][1].Current_Send_Count__c == 2, 'Next send request not created');
    }
}