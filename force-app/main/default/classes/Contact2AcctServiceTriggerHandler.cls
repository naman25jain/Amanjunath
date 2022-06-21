public with sharing class Contact2AcctServiceTriggerHandler{
	public static void handleInsert(List<CONTACT2ACCTSERVICE__c> newList){
		Map<Id, Contact> parentContact = new Map<Id, Contact>();
		Set<Id> setIds = new Set<Id>();
		for(CONTACT2ACCTSERVICE__c loopVar: newList){
			if(loopVar.Active__c == TRUE && loopVar.Service_Contact__c != NULL){
				setIds.add(loopVar.Service_Contact__c);
			}
		}
		parentContact = new Map<Id, Contact>([Select Id, Is_Coordinator__c, Is_User__c, (Select Id, Role__c, Active__c, Service_Contact__c FROM ServiceContacts__r) FROM Contact where ID in :setIds]);
		for(Contact2AcctService__c con2AccService : newList){
			Contact myCon = parentContact.get(con2AccService.Service_Contact__c);
			if(myCon != NULL){
				if(con2AccService.Role__c == 'Coordinator'){
					myCon.Is_Coordinator__c = TRUE;
				}
				else if(con2AccService.Role__c == 'User'){
					myCon.Is_User__c = TRUE;
				}
			}
		}
		upsert parentContact.values();
	} 	
	public static void generateUpdateList(List<CONTACT2ACCTSERVICE__c> newList, List<CONTACT2ACCTSERVICE__c> oldList){
		Set<Id> userSetIds = new Set<Id>();
		Set<Id> coordSetIds = new Set<Id>();
		for(CONTACT2ACCTSERVICE__c loopVar : oldList){
			if(loopVar.Role__c == 'User' && loopVar.Service_Contact__c != NULL){ 
				userSetIds.add(loopVar.Service_Contact__c);
			}
			else if(loopVar.Role__c == 'Coordinator' && loopVar.Service_Contact__c != NULL){ 
				coordSetIds.add(loopVar.Service_Contact__c);
			}
		}
		for(CONTACT2ACCTSERVICE__c loopVar : newList){
			if(loopVar.Role__c == 'User' && loopVar.Service_Contact__c != NULL){ 
				userSetIds.add(loopVar.Service_Contact__c);
			}
			else if(loopVar.Role__c == 'Coordinator' && loopVar.Service_Contact__c != NULL){ 
				coordSetIds.add(loopVar.Service_Contact__c);
			}
		}
		Contact2AcctServiceTriggerHandler.handleUpdate(userSetIds, coordSetIds);	
	}
	
	public static List<Contact> handleAggregateUser(AggregateResult[] groupedResultsUser, Set<Id> userSetIds){
		List<Contact> contactUserListToUpdate = new List<Contact>();
		if(groupedResultsUser.size() == 0){
			List<Id> myList = new List<Id>();
			myList.addAll(userSetIds);
			for(integer count = 0; count < myList.size(); count++){
				Contact userCon = new Contact(Id = myList[count]);
				userCon.Is_User__c = FALSE;
				contactUserListToUpdate.add(userCon);
			}
		}
		else{
			for(AggregateResult ar: groupedResultsUser){
				Id userContactId = (ID)ar.get('Service_Contact__c');
				Integer userCount = (Integer)ar.get('expr0');
				Contact userCon = new Contact(Id = userContactId);
				if(userCount > 0){
					userCon.Is_User__c = TRUE;
				}
				else{
					userCon.Is_User__c = FALSE;
				}
				contactUserListToUpdate.add(userCon);
			}
		}
		return contactUserListToUpdate;
	}
	public static List<Contact> handleAggregateCoordinator(AggregateResult[] groupedResultsCoord, Set<Id> coordSetIds){
		List<Contact> contactCoordListToUpdate = new List<Contact>();
		if(groupedResultsCoord.size() == 0){
			List<Id> myList = new List<Id>();
			myList.addAll(coordSetIds);
			for(integer count = 0; count < myList.size(); count++){
				Contact coordCon = new Contact(Id = myList[count]);
				coordCon.Is_Coordinator__c = FALSE;
				contactCoordListToUpdate.add(coordCon);
			}
		}
		else{
			for(AggregateResult ar: groupedResultsCoord){
				Id coordContactId = (ID)ar.get('Service_Contact__c');
				Integer coordCount = (Integer)ar.get('expr0');
				Contact coordCon = new Contact(Id = coordContactId);
				if(coordCount > 0){
					coordCon.Is_Coordinator__c = TRUE;
				}
				else{
					coordCon.Is_Coordinator__c = FALSE;
				}
				contactCoordListToUpdate.add(coordCon);
			}
		}
		return contactCoordListToUpdate;
	}
	public static void handleUpdate(Set<Id> userSetIds, Set<Id> coordSetIds){
	
    List<Contact> contactCoordListToUpdate = new List<Contact>();
    List<Contact> contactUserListToUpdate = new List<Contact>();
	AggregateResult[] groupedResultsUser = [SELECT COUNT(Id), Service_Contact__c, Role__c FROM CONTACT2ACCTSERVICE__c where Active__c = TRUE AND Service_Contact__c =: userSetIds AND Role__c ='User' GROUP BY Service_Contact__c, Role__c];
	contactUserListToUpdate = Contact2AcctServiceTriggerHandler.handleAggregateUser(groupedResultsUser, userSetIds);
	AggregateResult[] groupedResultsCoord = [SELECT COUNT(Id), Service_Contact__c, Role__c FROM CONTACT2ACCTSERVICE__c where Active__c = TRUE AND Service_Contact__c =: coordSetIds AND Role__c ='Coordinator' GROUP BY Service_Contact__c, Role__c];
	contactCoordListToUpdate = Contact2AcctServiceTriggerHandler.handleAggregateCoordinator(groupedResultsCoord, coordSetIds);
	if(contactUserListToUpdate.size()>0){
		update contactUserListToUpdate;
	}
	if(contactCoordListToUpdate.size()>0){
		update contactCoordListToUpdate;
	}
	}
	public static List<Contact> handleAggregateForZero(Set<Id> idSet, String role){
		List<Contact> contactListToUpdate = new List<Contact>();
		List<Id> myList = new List<Id>();
		myList.addAll(idSet);
		for(integer count = 0; count < myList.size(); count++){
			Contact conRecord = new Contact(Id = myList[count]);
			switch on Role{
				when 'User'{
					conRecord.Is_User__c = FALSE;
				}
				when 'Coordinator'{
					conRecord.Is_Coordinator__c = FALSE;
				}
				when else{
					//do Nothing
				}
			}
			contactListToUpdate.add(conRecord);
		}
		return contactListToUpdate;	
	}		
	public static List<Contact> handleAggregate(Set<Id> idSet, String role, AggregateResult[] groupedResults){
		List<Contact> contactListToUpdate = new List<Contact>();
		for(AggregateResult ar: groupedResults){
			Id contactId = (Id)ar.get('Service_Contact__c');
			Integer count = (Integer)ar.get('expr0');
			Contact con = new Contact(Id = contactId);
			if(count == 1){
				switch on Role{
					when 'User'{
						con.Is_User__c = FALSE;
					}
					when 'Coordinator'{
						con.Is_Coordinator__c = FALSE;
					}
					when else{
						//do Nothing
					}
				}
			}
			contactListToUpdate.add(con);
		}
		return contactListToUpdate;
	}
	public static void generateDeleteList(List<Contact2AcctService__c> oldList){
		Set<Id> userSetIds = new Set<Id>();
        Set<Id> coordSetIds = new Set<Id>();
		for(CONTACT2ACCTSERVICE__c loopVar : oldList){
			if(loopVar.Service_Contact__c != NULL){
				if(loopVar.Role__c == 'User'){
					userSetIds.add(loopVar.Service_Contact__c);
				}
				else if(loopVar.Role__c == 'Coordinator'){
					coordSetIds.add(loopVar.Service_Contact__c);
				}
			}
		}
		Contact2AcctServiceTriggerHandler.handleDelete(userSetIds, coordSetIds);
	}
	public static void handleDelete(Set<Id> userSetIds, Set<Id> coordSetIds){
		List<Contact> contactUserListToUpdate = new List<Contact>();
		List<Contact> contactCoordListToUpdate = new List<Contact>();
		
		//Update the Contact field before deleting the record, if count is 1. After deleting will be zero.
		if(userSetIds.size() > 0){
			AggregateResult[] groupedResultsUser = [SELECT COUNT(Id), Service_Contact__c, Role__c FROM CONTACT2ACCTSERVICE__c where Active__c = TRUE AND Service_Contact__c =: userSetIds AND Role__c = 'User' GROUP BY Service_Contact__c, Role__c];
			if(groupedResultsUser.size() == 0){
				contactUserListToUpdate = Contact2AcctServiceTriggerHandler.handleAggregateForZero(userSetIds, 'User');
			}
			else{
				contactUserListToUpdate = Contact2AcctServiceTriggerHandler.handleAggregate(userSetIds, 'User', groupedResultsUser);
			}
		}
		if(coordSetIds.size() > 0){
			AggregateResult[] groupedResultsCoord = [SELECT COUNT(Id), Service_Contact__c, Role__c FROM CONTACT2ACCTSERVICE__c where Active__c = TRUE AND Service_Contact__c =: coordSetIds AND Role__c = 'Coordinator' GROUP BY Service_Contact__c, Role__c];
			if(groupedResultsCoord.size() == 0){
				contactCoordListToUpdate = Contact2AcctServiceTriggerHandler.handleAggregateForZero(coordSetIds, 'Coordinator');
			}
			else{
				contactCoordListToUpdate = Contact2AcctServiceTriggerHandler.handleAggregate(coordSetIds, 'Coordinator', groupedResultsCoord);
			}
		}
        if(contactUserListToUpdate.size() > 0){
            update contactUserListToUpdate;
        }
        if(contactCoordListToUpdate.size() > 0){
            update contactCoordListToUpdate;
        }
	}
	public static void beforeInsert(List<CONTACT2ACCTSERVICE__c> newList){
		validateDupRecordsInsert(newList);
	}
	public static void beforeUpdate(List<CONTACT2ACCTSERVICE__c> newList, Map<Id, CONTACT2ACCTSERVICE__c> oldListMap){
		validateDupRecordsUpdate(newList, oldListMap);
	}
	public static MAP<String, List<String>> getCredentialType(SET<String> acc2ServiceIdSet, SET<String> contactServiceIdSet){
		MAP<String, List<String>> accCredentialTypeMap = new MAP<String, List<String>>();
		List<CONTACT2ACCTSERVICE__c> contact2ServiceList = [SELECT Account_Service__c,Service_Contact__c,Credential_Type__c
															FROM CONTACT2ACCTSERVICE__c	
															WHERE (Account_Service__c IN: acc2ServiceIdSet 
															OR Service_Contact__c IN: contactServiceIdSet)
															AND Active__c = true AND Service_Contact__c != null WITH SECURITY_ENFORCED];
		if(!contact2ServiceList.isEmpty()){
			for(CONTACT2ACCTSERVICE__c contact2Service : contact2ServiceList){
				if(accCredentialTypeMap.get(contact2Service.Account_Service__c+'--'+contact2Service.Service_Contact__c) == null){
					accCredentialTypeMap.put(contact2Service.Account_Service__c+'--'+contact2Service.Service_Contact__c, new List<String>{contact2Service.Credential_Type__c});
				}else{				
					List<String> crdentialTypes = accCredentialTypeMap.get(contact2Service.Account_Service__c+'--'+contact2Service.Service_Contact__c);
					crdentialTypes.add(contact2Service.Credential_Type__c);
					accCredentialTypeMap.put(contact2Service.Account_Service__c+'--'+contact2Service.Service_Contact__c, crdentialTypes);
				}				
			}
		}
		return accCredentialTypeMap;
	}
	// US 13914 - Makes sure there are no duplicate records of cont2acct2service with for credential type value.
	public static void validateDupRecordsInsert(List<CONTACT2ACCTSERVICE__c> newList){
		SET<String> acc2ServiceIdSet = new SET<String>();
		SET<String> contactServiceIdSet = new SET<String>();
		for(CONTACT2ACCTSERVICE__c con2AccService : newList){
			if(String.isNotBlank(con2AccService.Account_Service__c)){
				acc2ServiceIdSet.add(con2AccService.Account_Service__c);
			}
			if(String.isNotBlank(con2AccService.Service_Contact__c)){
				contactServiceIdSet.add(con2AccService.Service_Contact__c);
			}
		}
		acc2ServiceIdSet.remove(null);
		contactServiceIdSet.remove(null); 
		MAP<String, List<String>> accCredentialTypeMap = getCredentialType(acc2ServiceIdSet, contactServiceIdSet);
		if(!accCredentialTypeMap.isEmpty()){
			for(CONTACT2ACCTSERVICE__c conAccService : newList){
				if(accCredentialTypeMap.get(conAccService.Account_Service__c+'--'+conAccService.Service_Contact__c) != null){
					if(accCredentialTypeMap.get(conAccService.Account_Service__c+'--'+conAccService.Service_Contact__c).contains(conAccService.Credential_Type__c)){
						conAccService.addError(Constants.CREDENTIAL_VERF_EXIST_ERROR);
					}
				}
			}
		}
	}
	// US 13914 - Makes sure there are no duplicate records of cont2acct2service with for credential type value.
	public static void validateDupRecordsUpdate(List<CONTACT2ACCTSERVICE__c> newList, Map<Id, CONTACT2ACCTSERVICE__c> oldListMap){
		SET<String> acc2ServiceIdSet = new SET<String>();
		SET<String> contactServiceIdSet = new SET<String>();
		for(CONTACT2ACCTSERVICE__c con2AccService : newList){
			acc2ServiceIdSet.add(con2AccService.Account_Service__c);
			contactServiceIdSet.add(con2AccService.Service_Contact__c);
		}
		MAP<String, List<String>> accCredentialTypeMap = getCredentialType(acc2ServiceIdSet, contactServiceIdSet);
		if(!accCredentialTypeMap.isEmpty()){
			for(CONTACT2ACCTSERVICE__c conAccService : newList){
				if(accCredentialTypeMap.get(conAccService.Account_Service__c+'--'+conAccService.Service_Contact__c) != null){
					if(conAccService.Credential_Type__c != oldListMap.get(conAccService.Id).Credential_Type__c && accCredentialTypeMap.get(conAccService.Account_Service__c+'--'+conAccService.Service_Contact__c).contains(conAccService.Credential_Type__c)){
						conAccService.addError(Constants.CREDENTIAL_VERF_EXIST_ERROR);
					}
				}
			}
		}
	}
}