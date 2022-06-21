//Handler class for SendRequestTrigger
public with sharing class SendRequestTriggerHandler{
    public static void handleBeforeInsertTrigger(List<Send_Request__c> newSendReqs){
        if(!System.isBatch()){
            handleAdhocResends(newSendReqs);
        }else{
            calculateNextSendDate(newSendReqs);
        }
    }
    public static void calculateNextSendDate(List<Send_Request__c> sendReqs){
        try{
            List<Service_Line_Resend_SLA__mdt> slaList = [SELECT Id, Service_Line__c, Entity__c, Duration_Days_Iteration_One__c, Duration_Days_Iteration_Two__c, Duration_Days_Iteration_Three__c, Number_of_Resend__c FROM Service_Line_Resend_SLA__mdt WITH SECURITY_ENFORCED];
            for(Send_Request__c req : sendReqs){
                if(req.Current_Send_Date__c != null){
                    getServiceLineDuration(slaList, req);
                }
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void beforeUpdateSendRequest(Map<Id, Send_Request__c> newSendReqMap, Map<Id, Send_Request__c> oldSendReqMap){
        try{
            List<Service_Line_Resend_SLA__mdt> slaList = [SELECT Id, Service_Line__c, Entity__c, Duration_Days_Iteration_One__c, Duration_Days_Iteration_Two__c, Duration_Days_Iteration_Three__c, Number_of_Resend__c FROM Service_Line_Resend_SLA__mdt WITH SECURITY_ENFORCED];
            for(Send_Request__c sendReq : newSendReqMap.values()){            
                if(sendReq.Current_Send_Date__c != null && sendReq.Current_Send_Date__c != oldSendReqMap.get(sendReq.Id).Current_Send_Date__c){
                    getServiceLineDuration(slaList, sendReq);
                }
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }       
    }
    public static void getServiceLineDuration(List<Service_Line_Resend_SLA__mdt> slaList, Send_Request__c req){
        try{            
            Service_Line_Resend_SLA__mdt currentSLA = new Service_Line_Resend_SLA__mdt();
            for(Service_Line_Resend_SLA__mdt sla : slaList){
                if((String.isNotBlank(req.Entity__c) && req.Entity__c == sla.Entity__c) || req.Service_Line__c == sla.Service_Line__c){
                    currentSLA = sla;
                }
            }
            if(currentSLA != Null){
                if(req.Current_Send_Count__c == 1){
                    req.Next_Send_Date__c = req.Current_Send_Date__c.addDays(Integer.valueOf(currentSLA.Duration_Days_Iteration_One__c));
                }else if(req.Current_Send_Count__c == 2){
                    req.Next_Send_Date__c = req.Current_Send_Date__c.addDays(Integer.valueOf(currentSLA.Duration_Days_Iteration_Two__c));
                }else if(req.Current_Send_Count__c == 3){
                    req.Next_Send_Date__c = req.Current_Send_Date__c.addDays(Integer.valueOf(currentSLA.Duration_Days_Iteration_Three__c));
                }
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // US 15481 - handling adhoc resend when creating Send_Request__c records - before insert trigger
    public static void handleAdhocResends(List<Send_Request__c> newSendReqs){
        try{        
            SET<Id> veriPacketSet = new SET<Id>();
            for(Send_Request__c newSendReq : newSendReqs){            
                if(newSendReq.Verification_Packet__c != null){
                    veriPacketSet.add(newSendReq.Verification_Packet__c);
                }
            }
            MAP<Id, Boolean> veriPacketMap = new MAP<Id, Boolean>();
            for(Id veriPacketId : veriPacketSet){
                Boolean checkAdhocProcess = checkAdhocResendProcess(veriPacketId);
                veriPacketMap.put(veriPacketId, checkAdhocProcess);
            }            
            for(Send_Request__c newSendRequest : newSendReqs){
                if(veriPacketMap.get(newSendRequest.Verification_Packet__c) == true){
                    showErrors(newSendRequest);
                }
            }
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }  
    // Checking Adhoc Resend Process will allow or not.
    public static Boolean checkAdhocResendProcess(Id veriPacketId){
		try{
			List<Send_Request__c> sendRequestList = [SELECT id, Send_Method__c, Verification_Packet__c 
														FROM Send_Request__c 
													WHERE Is_Deleted__c = false
                                                        AND Current_Send_Date__c != null
														AND Verification_Packet__c =: veriPacketId
													WITH SECURITY_ENFORCED
													ORDER BY CreatedDate DESC LIMIT 1];
			if(!sendRequestList.isEmpty()){               
				return true;
			}else{
				return false;
			}			
		}
		catch(DmlException e){
			throw new ControllerException(e.getMessage());
		}
	}
    public static void showErrors(Send_Request__c newSendRequest){
        if(newSendRequest.Send_Method__c == Constants.SEND_METHOD_ENTITY_PORTAL && !Constants.isupdatedbyNotVerifiedEntity){
            newSendRequest.addError(System.Label.TimedResends_Get_Send_Method);
        }else if(newSendRequest.Courier_fee_payable_by__c == Constants.COURIER_FEE_PAYABLE_BY_ECFMG && newSendRequest.Courier_Account__c != null){
            newSendRequest.addError(System.Label.TimedResends_Courier_Account_Empty);
        }else if(newSendRequest.Current_Send_Date__c != null && !Constants.isupdatedbyNotVerifiedEntity){
            newSendRequest.addError(System.Label.TimedResends_Current_Send_Date_Null);
        }else if(newSendRequest.Next_Send_Date__c != null){
            newSendRequest.addError(System.Label.TimedResends_Next_Send_Date_Null);
        }else if(newSendRequest.Received_Date__c != null){
            newSendRequest.addError(System.Label.TimedResends_Received_Send_Date_Null);
        }
    }
    // US 15481 - Update case status after creating Send Request Record
    public static void afterInsertSendRequest(List<Send_Request__c> newSendReqs){
        Set<Id> veriPacketSet = new Set<Id>();
        MAP<String, String> sendRequestMap = new MAP<String, String>();
        MAP<String, String> sendRequestIdMap = new MAP<String, String>();
        for(Send_Request__c newSendReq : newSendReqs){
            if(newSendReq.Current_Send_Date__c == null && (newSendReq.Send_Method__c == Constants.SEND_METHOD_PAPER || newSendReq.Send_Method__c == Constants.SEND_METHOD_EMAIL) && !sendRequestMap.containsKey(newSendReq.Verification_Packet__c)){
                sendRequestMap.put(newSendReq.Verification_Packet__c, newSendReq.Send_Method__c);
                sendRequestIdMap.put(newSendReq.Verification_Packet__c, newSendReq.Id);
            } 
            veriPacketSet.add(newSendReq.Verification_Packet__c);
        }
        if(!veriPacketSet.isEmpty()){
            updateNextSendDate(veriPacketSet);            
            MAP<String, String> caseVeriPackMap = new MAP<String, String>();
            for(Verification_Packet__c veriPacket : [SELECT Id, Case__c FROM Verification_Packet__c WHERE Id IN: veriPacketSet]){
                caseVeriPackMap.put(veriPacket.Id, veriPacket.Case__c);
            }
            if(!sendRequestMap.isEmpty() && !caseVeriPackMap.isEmpty()){
                for(Id veriPacketId : veriPacketSet){
                    String caseId = caseVeriPackMap.get(veriPacketId);
                    String sendMethod = sendRequestMap.get(veriPacketId);
                    String sendReq = sendRequestIdMap.get(veriPacketId);
                    TimedResendsController.updateCaseStatus(caseId, sendMethod, sendReq);
                }
            }
        }
	}
    public static void updateNextSendDate(Set<Id> veriPacketSet){
        List<Send_Request__c> sendReqUpdateList = new List<Send_Request__c>();
        List<Send_Request__c> sendReqList = [SELECT Id, Verification_Packet__c, Current_Send_Count__c 
                                                FROM Send_Request__c 
                                            WHERE Verification_Packet__c IN: veriPacketSet AND Next_Send_Date__c > today
                                            WITH SECURITY_ENFORCED];
        for(Send_Request__c sendReq : sendReqList){                
            Send_Request__c sendReqObj = new Send_Request__c();
            sendReqObj.Id = sendReq.Id;
            sendReqObj.Next_Send_Date__c = System.today() - 1;
            sendReqUpdateList.add(sendReqObj);
        }
        if(!sendReqUpdateList.isEmpty() && Send_Request__c.SObjectType.getDescribe().isUpdateable()){
            update sendReqUpdateList;
        }
    }    
}