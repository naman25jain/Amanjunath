//Batch to create next send request based on current send count
global with sharing class SendRequestBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Entity__c, Service_Line__c, Next_Send_Date__c, Received_Date__c, Current_Send_Count__c, Current_Send_Date__c, Verification_Packet__c, Send_Method__c FROM Send_Request__c WHERE Next_Send_Date__c = TODAY AND (Case_Status__c =\''+Constants.CASE_STATUS_SENT_FOR_VERIFICATION+'\' OR Case_Status__c =\''+Constants.CASE_STATUS_RESENT_FOR_VERIFICATION+'\') AND Received_Date__c = Null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Send_Request__c> sendReqs){
        try{
            List<Service_Line_Resend_SLA__mdt> slaList = [SELECT Id, Service_Line__c, Entity__c, Duration_Days_Iteration_One__c, Duration_Days_Iteration_Two__c, Duration_Days_Iteration_Three__c, Number_of_Resend__c FROM Service_Line_Resend_SLA__mdt WITH SECURITY_ENFORCED];
            Service_Line_Resend_SLA__mdt currentSLA = new Service_Line_Resend_SLA__mdt();
            Set<Id> vpId=new Set<ID>();
            List<Send_Request__c> newSendReqs = new List<Send_Request__c>();
            for(Send_Request__c req :sendReqs){
                vpId.add(req.Verification_Packet__c);
            }
            List<Verification_Packet__c> vp=[Select Id, Name, Case__c, Case__r.Send_Method__c from Verification_Packet__c where Id IN: vpId];
            for(Send_Request__c req :sendReqs){
                for(Service_Line_Resend_SLA__mdt sla :slaList){
                    if((String.isNotBlank(req.Entity__c) && req.Entity__c == sla.Entity__c) || req.Service_Line__c == sla.Service_Line__c){
                        currentSLA = sla;
                    }
                }
                for(Verification_Packet__c vpList:vp){
                    if(vpList.id==req.Verification_Packet__c && vpList.Case__r.Send_Method__c!='Entity Portal' && currentSLA != Null && req.Current_Send_Count__c <= currentSLA.Number_of_Resend__c){
                        Send_Request__c sendReq = new Send_Request__c();
                        sendReq.Verification_Packet__c = req.Verification_Packet__c;
                        sendReq.Send_Method__c = vpList.Case__r.Send_Method__c;
                        sendReq.Current_Send_Count__c = req.Current_Send_Count__c + 1;
                        sendReq.Date_of_Last_Resend__c = req.Current_Send_Date__c;
                        newSendReqs.add(sendReq);
                    }
                }
            }
            if(Schema.sObjectType.Send_Request__c.isCreateable() && !newSendReqs.isEmpty()){
                INSERT newSendReqs;
            }
        }
        catch(Exception e){
            throw new ControllerException('Error Occured: ' + e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bc){
    }
}