trigger AccountLanguageTrigger on Account_Language__c(after insert, after update, before insert, before update){
    Disable_Processes_for_Data_Migration__c disableProcessSetting = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(disableProcessSetting != Null){
        //check disable triggers
        boolean disableTriggers = disableProcessSetting.Disable_Triggers__c; 
        if(disableTriggers == false){        
            if(trigger.isAfter){
                AccountLanguageTriggerHandler.handleAfterTrigger(trigger.isInsert, trigger.isUpdate, trigger.new, trigger.oldMap);
            }

            if(trigger.isBefore){
                AccountLanguageTriggerHandler.handleBeforeTrigger(trigger.isInsert, trigger.isUpdate, trigger.new, trigger.oldMap);
            }
        }
    }

}