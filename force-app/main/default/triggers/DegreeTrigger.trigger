trigger DegreeTrigger on Degree__c (after insert, after update, before insert, before update){
    Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
        if(disableTriggers == false){
            if (trigger.isAfter && trigger.isInsert && DegreeTriggerHelper.firstRun){  
                DegreeTriggerHelper.firstRun = false; 
                DegreeTriggerHandler.afterInsert(trigger.new);
            } 
            if (trigger.isAfter && trigger.isUpdate && DegreeTriggerHelper.firstRun){
                DegreeTriggerHelper.firstRun = false; 
                DegreeTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
            if (trigger.isBefore){
                if (trigger.isInsert){
                    DegreeTriggerHandler.beforeInsert(trigger.new);
                }
                if (trigger.isUpdate) {
                    DegreeTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
                }
            }
        }
    }
}