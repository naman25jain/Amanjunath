//Trigger to calculate next send date based on service line resend SLA
trigger SendRequestTrigger on Send_Request__c(after insert, after update, before insert, before update){
	Disable_Processes_for_Data_Migration__c disableProcessSetting = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(disableProcessSetting != Null){
        //check disable triggers
        boolean disableTriggers = disableProcessSetting.Disable_Triggers__c; 
        if(disableTriggers == false){
			if(trigger.isBefore && trigger.isInsert){
				SendRequestTriggerHandler.handleBeforeInsertTrigger(trigger.new);
			}
			if(trigger.isBefore && trigger.isUpdate){
				SendRequestTriggerHandler.beforeUpdateSendRequest(trigger.newMap, trigger.oldMap);
			}
			if(trigger.isAfter && trigger.isInsert && !System.isBatch()){
				SendRequestTriggerHandler.afterInsertSendRequest(trigger.new);
			}
		}
	}
}