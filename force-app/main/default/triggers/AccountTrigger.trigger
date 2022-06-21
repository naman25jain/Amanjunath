trigger AccountTrigger on Account (before insert, before update,  after insert, after update) {

    Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 

        if(disableTriggers == false){
            if (trigger.isAfter && trigger.isInsert && AccountTriggerHelper.firstRun) {  
                AccountTriggerHelper.firstRun = false;       
                AccountTriggerHandler.afterInsert(trigger.new);
            }
    
            if (trigger.isAfter && trigger.isUpdate && AccountTriggerHelper.firstRun) {
                AccountTriggerHelper.firstRun = false; 
                AccountTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
    
            if (trigger.isBefore && trigger.isInsert) {
                for(Account acct : trigger.New){
                    //Display error if someone manually tries to enter Entity ID
                    if(acct.Entity_ID__c != null){
                        acct.addError('You are not allowed to enter Entity ID manually. It is auto generated.');
                    }
                }
                AccountTriggerHandler.beforeInsert(trigger.new);
            }
    
            if (trigger.isBefore && trigger.isUpdate){      
                if (trigger.isUpdate) {                      
                    AccountTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
                }
            }
        }
    }
}