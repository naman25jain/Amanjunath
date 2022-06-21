/** @name: ContactAssociationTypeTrigger
 *  @description: Process contact association type and related data based on trigger event type
**/
trigger ContactAssociationTypeTrigger on Contact_Association_Type__c (after insert) {
    Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 

        if(disableTriggers == false){
    
            TriggerFactory.createHandler(Contact_Association_Type__c.SObjectType);
        }
    }
}