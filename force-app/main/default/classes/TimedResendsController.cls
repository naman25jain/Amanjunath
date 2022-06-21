public with sharing class TimedResendsController{
	// Checking the case status as Sent for verification or Resent for verificaiton or Verification in Review at ECFMG
	@AuraEnabled
	public static Boolean checkCaseStatus(String caseId){
		try{
			List<Affirmation__c> listOfAff = new List<Affirmation__c>();			
			List<Case> caseList = new List<Case>();
			Id idVerifcnRevRecTy = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('Verification_Review').getRecordTypeId();
			listOfAff = [SELECT Id, Case__c, Verification_method_is_acceptable__c, Verification_response_returned__c, RecordTypeId FROM Affirmation__c WHERE RecordTypeId =: idVerifcnRevRecTy AND Case__c =:caseId WITH SECURITY_ENFORCED];
			if(!listOfAff.isEmpty()){
				List<String> caseSetId = new List<String>();
				for(Affirmation__c affr : listOfAff){
					if(affr.Case__c != NULL && affr.Verification_method_is_acceptable__c == 'No' && affr.Verification_response_returned__c == 'No'){
						caseSetId.add(affr.Case__c);
					}
				}
				if(caseSetId.size() > 0){
					caseList = [SELECT id FROM Case WHERE id =: caseSetId AND (Internal_Status__c =: Constants.CASE_STATUS_SENT_FOR_VERIFICATION OR Internal_Status__c =: Constants.CASE_STATUS_RESENT_FOR_VERIFICATION OR Internal_Status__c =: Constants.CASE_STATUS_VERIFICATION_IN_REVIEW OR Internal_Status__c =: Constants.CASE_STATUS_VERIFICATION_INCOMPLETE) WITH SECURITY_ENFORCED];
				}
			}else{
				caseList = [SELECT id FROM Case WHERE id =: caseId AND (Internal_Status__c =: Constants.CASE_STATUS_SENT_FOR_VERIFICATION OR Internal_Status__c =: Constants.CASE_STATUS_RESENT_FOR_VERIFICATION OR Internal_Status__c =: Constants.CASE_STATUS_VERIFICATION_IN_REVIEW OR Internal_Status__c =: Constants.CASE_STATUS_VERIFICATION_INCOMPLETE) WITH SECURITY_ENFORCED];
			}			
			if(!caseList.isEmpty()){
				return true;
			}
			return false;						 
		}catch(Exception e){
			throw new ControllerException(e.getMessage());
		}
    }
	// Getting Send Request record with Current_Send_Date__c should be null
	@AuraEnabled
	public static String getSendMethod(String caseId){
		try{
			List<Send_Request__c> sendRequestList = [SELECT id, Send_Method__c, Verification_Packet__c 
														FROM Send_Request__c 
													WHERE Is_Deleted__c = false 
														AND Current_Send_Date__c = null
														AND Verification_Packet__r.Is_Active__c = true 
														AND Verification_Packet__r.Case__c =: caseId
													WITH SECURITY_ENFORCED
													ORDER BY CreatedDate DESC LIMIT 1];
			if(!sendRequestList.isEmpty()){				
				return sendRequestList[0].Send_Method__c+':'+sendRequestList[0].id;			
			}else{
				Boolean checkRecordFlag = checkResendRecords(caseId);
				if(checkRecordFlag == true){
					return 'adhocsendrecord';
				}
				return 'norecord';
			}			
		}
		catch(DmlException e){
			throw new ControllerException(e.getMessage());
		}
	}
	// Getting Adhoc Send Request record with Current_Send_Date__c should be null
	@AuraEnabled
	public static Boolean checkResendRecords(String caseId){
		try{
			List<Send_Request__c> sendRequestList = [SELECT id, Send_Method__c, Verification_Packet__c 
														FROM Send_Request__c 
													WHERE Is_Deleted__c = false
														AND Verification_Packet__r.Is_Active__c = true 
														AND Verification_Packet__r.Case__c =: caseId
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
	// Updating the case status - if Send Method is Paper, Pending Print. if Send Method is Email, Pending Email Creation
	@AuraEnabled
	public static Boolean updateCaseStatus(String caseId, String sendMethod, String sendReq){
		Case caseObj = new Case();
		if(String.isNotBlank(caseId)){
			caseObj = [SELECT Id, Internal_Status__c FROM Case WHERE Id =:caseId WITH SECURITY_ENFORCED LIMIT 1];
		}		
		Send_Request__c sendReqRec = [SELECT Id, Request_sent_via_courier__c, Country__c FROM Send_Request__c WHERE Id =:sendReq WITH SECURITY_ENFORCED];
		if(sendMethod == Constants.SEND_METHOD_PAPER){
			Group printQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_PRINT_QUEUE);
			String queueId = printQueue.Id;
			caseObj.OwnerId = queueId;
			if(sendReqRec.Request_sent_via_courier__c == TRUE){
				caseObj.Send_Request__c = sendReq;
				if(sendReqRec.Country__c == 'United States'){
					// US 20458 - Changed Status to Pending Print - Verification Incomplete from Verification Incomplete
					if(caseObj.Internal_Status__c == Constants.CASE_STATUS_VERIFICATION_INCOMPLETE){						
						caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT_VERIFICATION_INCOMPLETE;
					}
					// US 20453 - Changed Status to Pending Print - Resend
					// BUG 20961 - Adding Verification in Review at ECFMG status
					else if(caseObj.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION || caseObj.Internal_Status__c == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION || caseObj.Internal_Status__c == Constants.CASE_STATUS_VERIFICATION_IN_REVIEW){
						caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT_RESEND;
					}	
					else{
						caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT;
					}									
				}else{
					caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_ADDRESS_REVIEW;
				}
			}else{
				// US 20453 - Changed Status to Pending Print - Resend
				// BUG 20961 - Adding Verification in Review at ECFMG status
				if(caseObj.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION || caseObj.Internal_Status__c == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION || caseObj.Internal_Status__c == Constants.CASE_STATUS_VERIFICATION_IN_REVIEW){
					caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT_RESEND;
				}
				// US 20458 - Changed Status to Pending Print - Verification Incomplete from Verification Incomplete
				else if(caseObj.Internal_Status__c == Constants.CASE_STATUS_VERIFICATION_INCOMPLETE){						
					 caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT_VERIFICATION_INCOMPLETE;
				}
				else{
					caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT;
				}	
			}
		}
		else if(sendMethod == Constants.SEND_METHOD_EMAIL){
			caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_EMAIL_CREATION;
		}
		if(Case.SObjectType.getDescribe().isUpdateable()){
			try{
				Update caseObj;
				return true;
			}catch(Exception e){
				throw new ControllerException(e.getMessage());
			}
		}
		return false;
	}
}