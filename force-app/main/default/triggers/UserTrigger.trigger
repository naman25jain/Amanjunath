trigger UserTrigger on User(after insert, after update){
    Disable_Processes_for_Data_Migration__c disableProcessSetting = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(disableProcessSetting != Null){
        //check disable triggers
        boolean disableTriggers = disableProcessSetting.Disable_Triggers__c; 
        if(disableTriggers == false){
			if(trigger.isInsert){
				userTriggerHandler.handleInsert(trigger.New);
			}
			if(trigger.isUpdate){
				userTriggerHandler.handleUpdate(trigger.new, trigger.oldMap);
			}
		}
	}
}