trigger TaskTrigger on Task(before insert, after insert, after update){
    Disable_Processes_for_Data_Migration__c disableProcessSetting = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(disableProcessSetting != Null){
        //check disable triggers
        boolean disableTriggers = disableProcessSetting.Disable_Triggers__c; 
        if(disableTriggers == false && trigger.isAfter){
            if(trigger.isInsert && TaskTriggerHelper.firstRun){  
                TaskTriggerHelper.firstRun = false;       
                TaskTriggerHandler.afterInsert(trigger.new);
            } 
            if(trigger.isUpdate && AccountAffiliationTriggerHelper.firstRun){
                TaskTriggerHelper.firstRun = false; 
                TaskTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
        }
    }
    if(trigger.isBefore){
        TaskTriggerHelper.beforeInsert(trigger.new);
    }
}