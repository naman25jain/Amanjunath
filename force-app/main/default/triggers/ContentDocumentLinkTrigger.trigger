trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert){
        Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
        if(Null != dProcessSettings){
                //check disable triggers
                boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
                if(disableTriggers == false){
                        ContentDocumentLinkTriggerHelper.createAssetFromFile(trigger.new);
                }
        }
}