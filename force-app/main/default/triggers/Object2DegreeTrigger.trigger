trigger Object2DegreeTrigger on Object2Degree__c(after insert,after update,after delete, before insert, before update){
    Disable_Processes_for_Data_Migration__c disableProcessSetting = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(disableProcessSetting != Null){
        //check disable triggers
        boolean disableTriggers = disableProcessSetting.Disable_Triggers__c; 
        if(disableTriggers == false){
            Object2DegreeTriggerHelper.updateEcfmgAcceptableFlag(trigger.new, trigger.oldMap, trigger.isUpdate);
            if(trigger.isAfter){
                Object2DegreeTriggerHandler.handleAfterInsert(trigger.isInsert, trigger.isUpdate, Object2DegreeTriggerHelper.firstRun, trigger.new, trigger.oldMap);
            }
            if(trigger.isBefore){
                Object2DegreeTriggerHandler.handleBeforeInsert(trigger.isInsert, trigger.isUpdate, trigger.new, trigger.oldMap);    
            }
        }
    }   
}