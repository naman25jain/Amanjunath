@isTest
public with sharing class SendRequestTriggerTest{
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
    @isTest
    public static void testSendRequestTrigger(){
        Case caseRecord = new Case();
        // caseRecord.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        system.debug('@@@@@vp.Id    '+vp.Id);
        System.assert(vp.Id != null,'Verification Packet is not inserted');
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        
        
        /*SELECT id, Send_Method__c, Verification_Packet__c 
FROM Send_Request__c 
WHERE Is_Deleted__c = false
AND Current_Send_Date__c != null
AND Verification_Packet__c =: veriPacketId
WITH SECURITY_ENFORCED
ORDER BY CreatedDate DESC LIMIT 1*/
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Current_Send_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        
        System.assert(sendReq.Id != null,'Send Request is not inserted');
        
        sendReq.Current_Send_Count__c = 2;
        UPDATE sendReq;
        System.assert(sendReq.Id != null,'Send Request is not updated');
        
        sendReq.Current_Send_Count__c = 3;
        UPDATE sendReq;
        
        sendReq.Current_Send_Date__c = Date.today();
        Update sendReq;
        
        System.assert(sendReq.Id != null,'Send Request is not updated');
        
        //System.assertEquals([SELECT Next_Send_Date__c FROM Send_Request__c WHERE Id =:sendReq.Id][0].Next_Send_Date__c, sendReq.Current_Send_Date__c.addDays(60), 'Next send date not updated');
    }
    @isTest
    public static void testSendRequestInsertTrigger(){
        Case caseRecord = new Case();
        //caseRecord.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case 1 is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        system.debug('@@@@@vp.Id    '+vp.Id);
        System.assert(vp.Id != null,'Verification Packet 1 is not inserted');
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Current_Send_Date__c = null;
        sendReq.Is_Deleted__c = false;
        INSERT sendReq;
        System.assert(sendReq.Id != null,'Send Request 1 is not inserted');
        System.assertEquals([SELECT Current_Send_Date__c FROM Send_Request__c WHERE Id =:sendReq.Id][0].Current_Send_Date__c, null, 'Current send date is not updated');
    }
    @isTest
    Public static void testSendRequestInsertTrigger1(){
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Send_Method__c = 'Entity Portal';
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Current_Send_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        SendRequestTriggerHandler.calculateNextSendDate(newSendReqs);
        SendRequestTriggerHandler.showErrors(sendReq);
    }
    @isTest
    Public static void testSendRequestInsertTrigger2(){
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Courier_fee_payable_by__c = Constants.COURIER_FEE_PAYABLE_BY_ECFMG ;
        sendReq.Courier_Account__c = 'TEST Value';
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Current_Send_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        SendRequestTriggerHandler.calculateNextSendDate(newSendReqs);
        SendRequestTriggerHandler.showErrors(sendReq);
    }
    @isTest
    Public static void testSendRequestInsertTrigger3(){
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Courier_fee_payable_by__c = Constants.COURIER_FEE_PAYABLE_BY_ECFMG ;
        //sendReq.Courier_Account__c = 'TEST Value';
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Current_Send_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        SendRequestTriggerHandler.calculateNextSendDate(newSendReqs);
        SendRequestTriggerHandler.showErrors(sendReq);
    }
    @isTest
    Public static void testSendRequestInsertTrigger4(){
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Courier_fee_payable_by__c = Constants.COURIER_FEE_PAYABLE_BY_ECFMG ;
        //sendReq.Courier_Account__c = 'TEST Value';
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Next_Send_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        SendRequestTriggerHandler.calculateNextSendDate(newSendReqs);
        SendRequestTriggerHandler.showErrors(sendReq);
    }
    @isTest
    Public static void testSendRequestInsertTrigger5(){
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Courier_fee_payable_by__c = Constants.COURIER_FEE_PAYABLE_BY_ECFMG ;
        //sendReq.Courier_Account__c = 'TEST Value';
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Received_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        SendRequestTriggerHandler.calculateNextSendDate(newSendReqs);
        SendRequestTriggerHandler.showErrors(sendReq);
    }
   /* @isTest
    Public static void testafterInsertSendRequest(){
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='New';
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        caseRecord.Internal_Status__c='Accepted';
        Update caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Courier_fee_payable_by__c = Constants.COURIER_FEE_PAYABLE_BY_ECFMG ;
        sendReq.Send_Method__c =  'Email' ;
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Received_Date__c = date.parse('12/27/2015');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        SendRequestTriggerHandler.afterInsertSendRequest(newSendReqs);
        
        TimedResendsController.updateCaseStatus(caseRecord.Id ,'Email',sendReq.Id);
    }*/
    @isTest
    Public static void testupdateNextSendDate(){
        Id caserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Attestation').getRecordTypeId();
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c='Pending Print';
        caseRecord.recordtypeId = caserecordTypeId ;
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null, 'Case is not inserted');
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = caseRecord.Id;
        INSERT vp;
        List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Courier_fee_payable_by__c = Constants.COURIER_FEE_PAYABLE_BY_ECFMG ;
        sendReq.Send_Method__c =  'Paper' ;
        sendReq.Is_Deleted__c = false;
        sendReq.Verification_Packet__c = vp.Id;
        sendReq.Received_Date__c = date.parse('12/27/2015');
        sendReq.Next_Send_Date__c = date.parse('12/27/2023');
        newSendReqs.add(sendReq);
        INSERT newSendReqs;
        Constants.isupdatedbyNotVerifiedEntity = false;
        
        set<Id> veriPacketSet = new set<id>();
        for(Send_Request__c SR1 : newSendReqs){
            veriPacketSet.add(SR1.Id);
        }
        
        SendRequestTriggerHandler.updateNextSendDate(veriPacketSet);
    }
}