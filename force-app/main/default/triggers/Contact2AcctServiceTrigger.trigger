/** @name: Contact2AcctServiceTrigger
 *  @description: Trigger to check or uncheck Role, Coordinator and Dean check box in Contact record.
**/
trigger Contact2AcctServiceTrigger on CONTACT2ACCTSERVICE__c (before insert, before update, after insert, after update, before delete){
	Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 

    	if(disableTriggers == false){
			if(trigger.isBefore){		
				if(trigger.isInsert){
            		Contact2AcctServiceTriggerHandler.beforeInsert(trigger.new);
        		}
        		if(trigger.isUpdate){
            		Contact2AcctServiceTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        		}
			}
			if(trigger.isInsert){
				Contact2AcctServiceTriggerHandler.handleInsert(trigger.new);
			}
			if(trigger.isUpdate){
				Contact2AcctServiceTriggerHandler.generateUpdateList(trigger.new, trigger.old);
			}
			if(trigger.isDelete){
				Contact2AcctServiceTriggerHandler.generateDeleteList(trigger.old);
			}	
		}
	}	
}