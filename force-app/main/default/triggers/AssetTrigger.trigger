/**
 	* Created by Ajoydhas M A
    * @name: AssetTrigger
    * @description: User Story : 6111 EP13: Check for New Service Form
 **/
trigger AssetTrigger on Asset (after insert, after update){
    Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 

        if(disableTriggers == false){
            if (trigger.isAfter && trigger.isInsert) {        
                AssetTriggerHandler.afterInsert(trigger.new);
            } 
            if (trigger.isAfter && trigger.isUpdate) {
                AssetTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
        }
    }
}