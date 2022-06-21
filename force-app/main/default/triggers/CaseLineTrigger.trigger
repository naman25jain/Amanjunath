trigger CaseLineTrigger on Case_Line__c (after update) {
 
	CaseLineTriggerHandler handler = new CaseLineTriggerHandler (Trigger.isExecuting, Trigger.size);

	// if(Trigger.isInsert && Trigger.isBefore){
	// 	handler.OnBeforeInsert(Trigger.new);
	// }
	
	// else if(Trigger.isInsert && Trigger.isAfter){
	// 	handler.OnAfterInsert(Trigger.new);
	// 	//handler.OnAfterInsertAsync(Trigger.newMap.keySet());
	// }
	
	// if(Trigger.isUpdate && Trigger.isBefore){
	// 	handler.OnBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
	// }

	if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
		// CaseLineTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
	}

	// else if(Trigger.isDelete && Trigger.isBefore){
	// 	handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	// }

	// else if(Trigger.isDelete && Trigger.isAfter){
	// 	handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
	// 	//handler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
	// }

	// else if(Trigger.isUnDelete){
	// 	handler.OnUndelete(Trigger.new);
	// }
}