trigger AKATrigger on aka_Names__c (after insert, after update, before insert, before update) {
    Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 

        if(disableTriggers == false){
            if (trigger.isAfter){
                if (trigger.isInsert) {  
                    AKATriggerHelper.firstRun = false;       
                    AKATriggerHandler.afterInsert(trigger.new);           
                } 
                if (trigger.isUpdate && AKATriggerHelper.firstRun) {  
                    AKATriggerHelper.firstRun = false;      
                    AKATriggerHandler.afterUpdate(trigger.new, trigger.oldMap);                     
                }
            }

            if (trigger.isBefore){
                if (trigger.isInsert) {
                    AKATriggerHandler.beforeInsert(trigger.new);
                }
                if (trigger.isUpdate) {            
                    AKATriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
                }
            }
        }
    }
}